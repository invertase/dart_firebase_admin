// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';
import 'dart:math';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';
import 'util/helpers.dart' as helpers;

void main() {
  group(
    'Transaction',
    () {
      late Firestore firestore;

      setUp(() => firestore = helpers.createFirestore());

      Future<DocumentReference<Map<String, dynamic>>> initializeTest(
        String path,
      ) async {
        final String prefixedPath = 'flutter-tests/$path';
        await firestore.doc(prefixedPath).delete();
        return firestore.doc(prefixedPath);
      }

      test('works with withConverter', () async {
        final DocumentReference<Map<String, dynamic>> rawDoc =
            await initializeTest('with-converter-batch');

        final DocumentReference<int> doc = rawDoc.withConverter(
          fromFirestore: (snapshot) {
            return snapshot.data()['value']! as int;
          },
          toFirestore: (value) => {'value': value},
        );

        await doc.set(42);

        expect(
          await firestore.runTransaction<int?>((transaction) async {
            final snapshot = await transaction.get<int>(doc);
            return snapshot.data();
          }),
          42,
        );

        await firestore.runTransaction((transaction) async {
          transaction.set(doc, 21);
        });

        expect(await doc.get().then((s) => s.data()), 21);

        await firestore.runTransaction((transaction) async {
          transaction.update(doc, {'value': 0});
        });

        expect(await doc.get().then((s) => s.data()), 0);
      });

      test('should resolve with user value', () async {
        final int randomValue = Random().nextInt(9999);
        final int response =
            await firestore.runTransaction<int>((transaction) async {
          return randomValue;
        });
        expect(response, equals(randomValue));
      });

      test('should abort if thrown and not continue', () async {
        final DocumentReference<Map<String, dynamic>> documentReference =
            await initializeTest('transaction-abort');

        await documentReference.set({'foo': 'bar'});

        try {
          await firestore.runTransaction((transaction) async {
            transaction.set(documentReference, {
              'foo': 'baz',
            });
            throw 'Stop';
          });
          // ignore: dead_code
          fail('Should have thrown');
        } catch (e) {
          final DocumentSnapshot<Map<String, dynamic>> snapshot =
              await documentReference.get();
          expect(snapshot.data()!['foo'], equals('bar'));
        }
      });

      test(
        'should not collide if number of maxAttempts is enough',
        () async {
          final DocumentReference<Map<String, dynamic>> doc1 =
              await initializeTest('transaction-maxAttempts-1');

          await doc1.set({'test': 0});

          await Future.wait([
            firestore.runTransaction(
              (transaction) async {
                final value = await transaction.get(doc1);
                transaction.set(doc1, {
                  'test': (value.data()!['test'] as int) + 1,
                });
              },
              maxAttempts: 15,
            ),
            firestore.runTransaction(
              (transaction) async {
                await Future<void>.delayed(
                  // Add some random delay to prevent collision.
                  // If delay is not enought it will collide.
                  Duration(microseconds: Random().nextInt(2000)),
                );
                final value = await transaction.get(doc1);
                transaction.set(doc1, {
                  'test': (value.data()!['test'] as int) + 1,
                });
              },
              maxAttempts: 15,
            ),
          ]);

          final DocumentSnapshot<Map<String, dynamic>> snapshot1 =
              await doc1.get();
          expect(snapshot1.data()!['test'], equals(2));
        },
        retry: 2,
      );

      test('should collide if number of maxAttempts is too low', () async {
        final DocumentReference<Map<String, dynamic>> doc1 =
            await initializeTest('transaction-maxAttempts-2');

        await doc1.set({'test': 0});

        await expectLater(
          Future.wait([
            firestore.runTransaction(
              (transaction) async {
                final value = await transaction.get(doc1);
                transaction.set(doc1, {
                  'test': (value.data()!['test'] as int) + 1,
                });
              },
              maxAttempts: 1,
            ),
            firestore.runTransaction(
              (transaction) async {
                final value = await transaction.get(doc1);
                transaction.set(doc1, {
                  'test': (value.data()!['test'] as int) + 1,
                });
              },
              maxAttempts: 1,
            ),
          ]),
          throwsA(
            isA<FirebaseFirestoreAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              FirestoreClientErrorCode.failedPrecondition,
            ),
          ),
        );
      });

      test('runs multiple transactions in parallel', () async {
        final DocumentReference<Map<String, dynamic>> doc1 =
            await initializeTest('transaction-multi-1');
        final DocumentReference<Map<String, dynamic>> doc2 =
            await initializeTest('transaction-multi-2');

        await doc1.set({'test': 'value1'});
        await doc2.set({'test': 'value2'});

        await Future.wait([
          firestore.runTransaction((transaction) async {
            transaction.set(doc1, {
              'test': 'value3',
            });
          }),
          firestore.runTransaction((transaction) async {
            transaction.set(doc2, {
              'test': 'value4',
            });
          }),
        ]);

        final DocumentSnapshot<Map<String, dynamic>> snapshot1 =
            await doc1.get();
        expect(snapshot1.data()!['test'], equals('value3'));
        final DocumentSnapshot<Map<String, dynamic>> snapshot2 =
            await doc2.get();
        expect(snapshot2.data()!['test'], equals('value4'));
      });

      test('should abort if timeout is exceeded', () async {
        await expectLater(
          firestore.runTransaction(
            (transaction) => Future<void>.delayed(const Duration(seconds: 2)),
            timeout: const Duration(seconds: 1),
          ),
          throwsA(
            isA<FirebaseFirestoreAdminException>()
                .having((e) => e.code, 'code', 'firestore/deadline-exceeded'),
          ),
        );
      });

      test('should throw with exception', () async {
        try {
          await firestore.runTransaction((transaction) async {
            throw StateError('foo');
          });
          // ignore: dead_code
          fail('Transaction should not have resolved');
          // ignore: avoid_catching_errors
        } on StateError catch (e) {
          expect(e.message, equals('foo'));
          return;
        } catch (e) {
          fail('Transaction threw invalid exeption');
        }
      });

      group('Transaction.get()', () {
        test(
          'should throw if get is called after a command',
          () async {
            final DocumentReference<Map<String, dynamic>> documentReference =
                firestore.doc('flutter-tests/foo');

            expect(
              () async {
                await firestore.runTransaction((transaction) async {
                  transaction.set(documentReference, {'foo': 'bar'});
                  await transaction.get(documentReference);
                });
                fail('Transaction should not have resolved');
              },
              throwsA(isA<AssertionError>()),
            );
          },
        );

        test(
            'should throw a native error, and convert to a [FirebaseException]',
            () async {
          final DocumentReference<Map<String, dynamic>> documentReference =
              firestore.doc('non-existent/document');

          try {
            await firestore.runTransaction((transaction) async {
              await transaction.get(documentReference);
            });
            fail('Transaction should not have resolved');
          } on FirebaseFirestoreAdminException catch (e) {
            expect(e.errorCode, equals(FirestoreClientErrorCode.notFound));
            return;
          } catch (e) {
            fail('Transaction threw invalid exception. $e');
          }
        });

        // ignore: todo
        // TODO(Salakar): Test seems to fail sometimes. Will look at in a future PR.
        // testWidgets('support returning any value, e.g. a [DocumentSnapshot]', (_) async {
        //   DocumentReference<Map<String, dynamic>> documentReference =
        //       await initializeTest('transaction-get');

        //   DocumentSnapshot<Map<String, dynamic>> snapshot =
        //       await firestore.runTransaction((Transaction transaction) async {
        //     DocumentSnapshot<Map<String, dynamic>> returned = await transaction.get(documentReference);
        //     // required:
        //     transaction.set(documentReference, {'foo': 'bar'});
        //     return returned;
        //   });

        //   expect(snapshot, isA<DocumentSnapshot>());
        //   expect(snapshot.reference.path, equals(documentReference.path));
        // }, skip: kUseFirestoreEmulator);
      });

      group('Transaction.delete()', () {
        test('should delete a document', () async {
          final DocumentReference<Map<String, dynamic>> documentReference =
              await initializeTest('transaction-delete');

          await documentReference.set({'foo': 'bar'});

          await firestore.runTransaction((transaction) async {
            transaction.delete(documentReference);
          });

          final DocumentSnapshot<Map<String, dynamic>> snapshot =
              await documentReference.get();
          expect(snapshot.exists, isFalse);
        });
      });

      group('Transaction.update()', () {
        test('should update a document', () async {
          final DocumentReference<Map<String, dynamic>> documentReference =
              await initializeTest('transaction-update');

          await documentReference.set({'foo': 'bar', 'bar': 1});

          await firestore.runTransaction((transaction) async {
            final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                await transaction.get(documentReference);
            transaction.update(documentReference, {
              'bar': (documentSnapshot.data()!['bar'] as int) + 1,
            });
          });

          final DocumentSnapshot<Map<String, dynamic>> snapshot =
              await documentReference.get();
          expect(snapshot.exists, isTrue);
          expect(snapshot.data()!['bar'], equals(2));
          expect(snapshot.data()!['foo'], equals('bar'));
        });
      });

      group(
        'Transaction.set()',
        () {
          test('sets a document', () async {
            final DocumentReference<Map<String, dynamic>> documentReference =
                await initializeTest('transaction-set');

            await documentReference.set({'foo': 'bar', 'bar': 1});

            await firestore.runTransaction((transaction) async {
              final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                  await transaction.get(documentReference);
              transaction.set(documentReference, {
                'bar': (documentSnapshot.data()!['bar'] as int) + 1,
              });
            });

            final DocumentSnapshot<Map<String, dynamic>> snapshot =
                await documentReference.get();
            expect(snapshot.exists, isTrue);
            expect(
              snapshot.data(),
              equals(<String, dynamic>{'bar': 2}),
            );
          });

          //TODO Tests to be done after Merge on set be
          // test('merges a document with set', () async {
          //   final DocumentReference<Map<String, dynamic>> documentReference =
          //       await initializeTest('transaction-set-merge');

          //   await documentReference.set({'foo': 'bar', 'bar': 1});

          //   await firestore.runTransaction((transaction) async {
          //     final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          //         await transaction.get(documentReference);
          //     transaction.set(
          //       documentReference,
          //       {'bar': documentSnapshot.data()!['bar'] + 1},
          //       SetOptions(merge: true),
          //     );
          //   });

          //   final DocumentSnapshot<Map<String, dynamic>> snapshot =
          //       await documentReference.get();
          //   expect(snapshot.exists, isTrue);
          //   expect(snapshot.data()!['bar'], equals(2));
          //   expect(snapshot.data()!['foo'], equals('bar'));
          // });

          // test('merges fields a document with set', () async {
          //     final DocumentReference<Map<String, dynamic>> documentReference =
          //         await initializeTest('transaction-set-merge-fields');

          //     await documentReference.set({'foo': 'bar', 'bar': 1, 'baz': 1});

          //     await firestore.runTransaction((transaction) async {
          //       final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          //           await transaction.get(documentReference);
          //       transaction.set(
          //         documentReference,
          //         {
          //           'bar': documentSnapshot.data()!['bar'] + 1,
          //           'baz': 'ben',
          //         },
          //         SetOptions(mergeFields: ['bar']),
          //       );
          //     });

          //     final DocumentSnapshot<Map<String, dynamic>> snapshot =
          //         await documentReference.get();
          //     expect(snapshot.exists, isTrue);
          //     expect(
          //       snapshot.data(),
          //       equals(<String, dynamic>{'foo': 'bar', 'bar': 2, 'baz': 1}),
          //     );
          //   });
          // });

          test('runs all commands in a single transaction', () async {
            final DocumentReference<Map<String, dynamic>> documentReference =
                await initializeTest('transaction-all');

            final DocumentReference<Map<String, dynamic>> documentReference2 =
                firestore.doc('flutter-tests/delete');

            await documentReference2.set({'foo': 'bar'});
            await documentReference.set({'foo': 1});

            final String result =
                await firestore.runTransaction<String>((transaction) async {
              final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                  await transaction.get(documentReference);

              transaction.set(documentReference, {
                'foo': (documentSnapshot.data()!['foo'] as int) + 1,
              });

              transaction.update(documentReference, {'bar': 'baz'});

              transaction.delete(documentReference2);

              return 'done';
            });

            expect(result, equals('done'));

            final DocumentSnapshot<Map<String, dynamic>> snapshot =
                await documentReference.get();
            expect(snapshot.exists, isTrue);
            expect(
              snapshot.data(),
              equals(<String, dynamic>{'foo': 2, 'bar': 'baz'}),
            );

            final DocumentSnapshot<Map<String, dynamic>> snapshot2 =
                await documentReference2.get();
            expect(snapshot2.exists, isFalse);
          });
        },
      );
    },
  );
}
