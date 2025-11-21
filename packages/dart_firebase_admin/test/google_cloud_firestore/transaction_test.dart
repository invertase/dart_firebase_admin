// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';
import 'dart:math';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/src/google_cloud_firestore/status_code.dart';
import 'package:test/test.dart';
import 'util/helpers.dart' as helpers;

void main() {
  group('Transaction', () {
    late Firestore firestore;

    setUp(() async {
      await helpers.clearFirestoreEmulator();
      firestore = await helpers.createFirestore();
    });

    Future<DocumentReference<Map<String, dynamic>>> initializeTest(
      String path,
    ) async {
      final String prefixedPath = 'flutter-tests/$path';
      await firestore.doc(prefixedPath).delete();
      addTearDown(() => firestore.doc(prefixedPath).delete());

      return firestore.doc(prefixedPath);
    }

    test('get a document in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      await docRef.set({'value': 42});

      expect(
        await firestore.runTransaction(
          (transaction) async {
            final snapshot = await transaction.get(docRef);
            return Future.value(snapshot.data()!['value']);
          },
        ),
        42,
      );
    });

    test('getAll documents in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef1 =
          await initializeTest('simpleDocument');
      final DocumentReference<Map<String, dynamic>> docRef2 =
          await initializeTest('simpleDocument2');
      final DocumentReference<Map<String, dynamic>> docRef3 =
          await initializeTest('simpleDocument3');

      await docRef1.set({'value': 42});
      await docRef2.set({'value': 44});
      await docRef3.set({'value': 'foo'});

      expect(
        await firestore.runTransaction(
          (transaction) async {
            final snapshot =
                await transaction.getAll([docRef1, docRef2, docRef3]);
            return Future.value(snapshot)
                .then((v) => v.map((e) => e.data()!['value']).toList());
          },
        ),
        [42, 44, 'foo'],
      );
    });

    test('getAll documents with FieldMask in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef1 =
          await initializeTest('simpleDocument');
      final DocumentReference<Map<String, dynamic>> docRef2 =
          await initializeTest('simpleDocument2');
      final DocumentReference<Map<String, dynamic>> docRef3 =
          await initializeTest('simpleDocument3');

      await docRef1.set({'value': 42, 'otherValue': 'bar'});
      await docRef2.set({'value': 44, 'otherValue': 'bar'});
      await docRef3.set({'value': 'foo', 'otherValue': 'bar'});

      expect(
        await firestore.runTransaction(
          (transaction) async {
            final snapshot = await transaction.getAll(
              [
                docRef1,
                docRef2,
                docRef3,
              ],
              fieldMasks: [
                FieldPath(const ['value']),
              ],
            );
            return Future.value(snapshot)
                .then((v) => v.map((e) => e.data()!).toList());
          },
        ),
        [
          {'value': 42},
          {'value': 44},
          {'value': 'foo'},
        ],
      );
    });

    test('set a document in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      await firestore.runTransaction(
        (transaction) async {
          transaction.set(docRef, {'value': 44});
        },
      );

      expect(
        (await docRef.get()).data()!['value'],
        44,
      );
    });

    test('update a document in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      await firestore.runTransaction(
        (transaction) async {
          transaction.set(docRef, {'value': 44, 'foo': 'bar'});
          transaction.update(docRef, {'value': 46});
        },
      );

      expect(
        (await docRef.get()).data()!['value'],
        46,
      );
    });

    test('update a non existing document in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      final nonExistingDocRef = await initializeTest('simpleDocument2');

      expect(
        () async {
          await firestore.runTransaction(
            (transaction) async {
              transaction.set(docRef, {'value': 44, 'foo': 'bar'});
              transaction.update(nonExistingDocRef, {'value': 46});
            },
          );
        },
        throwsA(
          isA<FirebaseFirestoreAdminException>().having(
            (e) => e.errorCode.statusCode,
            'statusCode',
            StatusCode.notFound,
          ),
        ),
      );
    });

    test('update a document with precondition in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      final setResult = await docRef.set({'value': 42});

      final precondition = Precondition.timestamp(setResult.writeTime);

      await firestore.runTransaction(
        (transaction) async {
          transaction.update(
            docRef,
            {'value': 44},
            precondition: precondition,
          );
        },
      );

      expect((await docRef.get()).data()!['value'], 44);

      expect(
        () async {
          await firestore.runTransaction(
            (transaction) async {
              transaction.update(
                docRef,
                {'value': 46},
                precondition: precondition,
              );
            },
          );
        },
        throwsA(
          isA<FirebaseFirestoreAdminException>().having(
            (e) => e.errorCode.statusCode,
            'statusCode',
            StatusCode.failedPrecondition,
          ),
        ),
      );
    });

    test('get and set a document in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');
      await docRef.set({'value': 42});
      DocumentSnapshot<Map<String, dynamic>> getData;
      DocumentSnapshot<Map<String, dynamic>> setData;

      getData = await firestore.runTransaction(
        (transaction) async {
          final _getData = await transaction.get(docRef);
          transaction.set(docRef, {'value': 44});
          return _getData;
        },
      );

      setData = await docRef.get();

      expect(
        getData.data()!['value'],
        42,
      );

      expect(
        setData.data()!['value'],
        44,
      );
    });

    test('delete a existing document in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      await docRef.set({'value': 42});

      await firestore.runTransaction(
        (transaction) async {
          transaction.delete(docRef);
        },
      );

      expect(
        await docRef.get(),
        isA<DocumentSnapshot<Map<String, dynamic>>>()
            .having((e) => e.exists, 'exists', false),
      );
    });

    test('delete a non existing document in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      expect(
        await firestore.runTransaction(
          (transaction) async {
            transaction.delete(docRef);
          },
        ),
        null,
      );
    });

    test(
        'delete a non existing document with existing precondition in a transaction',
        () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');
      final precondition = Precondition.exists(true);
      expect(
        () async {
          await firestore.runTransaction(
            (transaction) async {
              transaction.delete(docRef, precondition: precondition);
            },
          );
        },
        throwsA(
          isA<FirebaseFirestoreAdminException>().having(
            (e) => e.errorCode.statusCode,
            'statusCode',
            StatusCode.notFound,
          ),
        ),
      );
    });

    test('delete a document with precondition in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      final writeResult = await docRef.set({'value': 42});
      var precondition = Precondition.timestamp(
        Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      expect(
        () async {
          await firestore.runTransaction(
            (transaction) async {
              transaction.delete(docRef, precondition: precondition);
            },
          );
        },
        throwsA(
          isA<FirebaseFirestoreAdminException>().having(
            (e) => e.errorCode.statusCode,
            'statusCode',
            StatusCode.failedPrecondition,
          ),
        ),
      );

      expect(
        await docRef.get(),
        isA<DocumentSnapshot<Map<String, dynamic>>>()
            .having((e) => e.exists, 'exists', true),
      );
      precondition = Precondition.timestamp(writeResult.writeTime);

      await firestore.runTransaction(
        (transaction) async {
          transaction.delete(docRef, precondition: precondition);
        },
      );

      expect(
        await docRef.get(),
        isA<DocumentSnapshot<Map<String, dynamic>>>()
            .having((e) => e.exists, 'exists', false),
      );
    });

    test('prevent get after set in a transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      expect(
        () async {
          await firestore.runTransaction(
            (transaction) async {
              transaction.set(docRef, {'value': 42});
              return transaction.get(docRef);
            },
          );
          fail('Transaction should not have resolved');
        },
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains(Transaction.readAfterWriteErrorMsg),
          ),
        ),
      );
    });

    test('prevent set in a readOnly transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      expect(
        () async {
          await firestore.runTransaction(
            (transaction) async {
              transaction.set(docRef, {'value': 42});
            },
            transactionOptions: ReadOnlyTransactionOptions(),
          );
          fail('Transaction should not have resolved');
        },
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains(Transaction.readOnlyWriteErrorMsg),
          ),
        ),
      );
    });

    test('detects document change during transaction', () async {
      final DocumentReference<Map<String, dynamic>> docRef =
          await initializeTest('simpleDocument');

      expect(
        () async {
          await firestore.runTransaction(
            (transaction) async {
              // ignore: unused_local_variable
              final data = await transaction.get(docRef);

              // Intentionally set doc during transaction
              await docRef.set({'value': 46});

              transaction.set(docRef, {'value': 42});
            },
            transactionOptions: ReadWriteTransactionOptions(maxAttempts: 1),
          );
          fail('Transaction should not have resolved');
        },
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Transaction max attempts exceeded'),
          ),
        ),
      );
    });

    test('runs multiple transactions in parallel', () async {
      final DocumentReference<Map<String, dynamic>> doc1 =
          await initializeTest('transaction-multi-1');
      final DocumentReference<Map<String, dynamic>> doc2 =
          await initializeTest('transaction-multi-2');

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

      final DocumentSnapshot<Map<String, dynamic>> snapshot1 = await doc1.get();
      expect(snapshot1.data()!['test'], equals('value3'));
      final DocumentSnapshot<Map<String, dynamic>> snapshot2 = await doc2.get();
      expect(snapshot2.data()!['test'], equals('value4'));
    });

    test('should not collide transaction if number of maxAttempts is enough',
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
        ),
        firestore.runTransaction(
          (transaction) async {
            final value = await transaction.get(doc1);
            transaction.set(doc1, {
              'test': (value.data()!['test'] as int) + 1,
            });
          },
        ),
      ]);

      final DocumentSnapshot<Map<String, dynamic>> snapshot1 = await doc1.get();
      expect(snapshot1.data()!['test'], equals(2));
    }, skip: 'Flaky: Firestore emulator data inconsistency',);

    test('should collide transaction if number of maxAttempts is not enough',
        retry: 2, () async {
      final DocumentReference<Map<String, dynamic>> doc1 =
          await initializeTest('transaction-maxAttempts-1');

      await doc1.set({'test': 0});
      expect(
        () async => Future.wait([
          firestore.runTransaction(
            (transaction) async {
              final value = await transaction.get(doc1);
              transaction.set(doc1, {
                'test': (value.data()!['test'] as int) + 1,
              });
            },
            transactionOptions: ReadWriteTransactionOptions(maxAttempts: 1),
          ),
          firestore.runTransaction(
            (transaction) async {
              final value = await transaction.get(doc1);
              transaction.set(doc1, {
                'test': (value.data()!['test'] as int) + 1,
              });
            },
            transactionOptions: ReadWriteTransactionOptions(maxAttempts: 1),
          ),
        ]),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Transaction max attempts exceeded'),
          ),
        ),
      );
    });

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
  });
}
