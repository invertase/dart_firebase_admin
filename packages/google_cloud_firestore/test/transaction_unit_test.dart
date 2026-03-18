import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:test/test.dart';

Firestore _makeFirestore() =>
    Firestore(settings: const Settings(projectId: 'unit-test-project'));

void main() {
  group('Transaction (unit)', () {
    late Firestore firestore;

    setUp(() {
      firestore = _makeFirestore();
    });

    group('constants', () {
      test('defaultMaxTransactionsAttempts is 5', () {
        expect(Transaction.defaultMaxTransactionsAttempts, 5);
      });

      test('readAfterWriteErrorMsg describes ordering constraint', () {
        expect(
          Transaction.readAfterWriteErrorMsg,
          contains('reads to be executed before all writes'),
        );
      });

      test('readOnlyWriteErrorMsg describes read-only restriction', () {
        expect(
          Transaction.readOnlyWriteErrorMsg,
          contains('read-only transactions cannot execute writes'),
        );
      });
    });

    group('read-only transaction write guard', () {
      late Transaction readOnlyTx;

      setUp(() {
        readOnlyTx = Transaction(firestore, ReadOnlyTransactionOptions());
      });

      test('create() throws on read-only transaction', () {
        final docRef = firestore.doc('col/doc');
        expect(
          () => readOnlyTx.create(docRef, {'foo': 'bar'}),
          throwsA(
            isA<FirestoreException>().having(
              (e) => e.message,
              'message',
              contains('read-only transactions cannot execute writes'),
            ),
          ),
        );
      });

      test('set() throws on read-only transaction', () {
        final docRef = firestore.doc('col/doc');
        expect(
          () => readOnlyTx.set(docRef, {'foo': 'bar'}),
          throwsA(isA<FirestoreException>()),
        );
      });

      test('update() throws on read-only transaction', () {
        final docRef = firestore.doc('col/doc');
        expect(
          () => readOnlyTx.update(docRef, {'foo': 'bar'}),
          throwsA(isA<FirestoreException>()),
        );
      });

      test('delete() throws on read-only transaction', () {
        final docRef =
            firestore.doc('col/doc') as DocumentReference<Map<String, dynamic>>;
        expect(
          () => readOnlyTx.delete(docRef),
          throwsA(isA<FirestoreException>()),
        );
      });
    });

    group('read-after-write guard', () {
      test('get() after write throws', () async {
        final docRef = firestore.doc('col/doc');
        final tx = Transaction(firestore, null);

        tx.create(docRef, {'foo': 'bar'});

        await expectLater(
          tx.get(docRef),
          throwsA(
            isA<FirestoreException>().having(
              (e) => e.message,
              'message',
              contains('reads to be executed before all writes'),
            ),
          ),
        );
      });

      test('getQuery() after write throws', () async {
        final docRef = firestore.doc('col/doc');
        final query = firestore.collection('col');
        final tx = Transaction(firestore, null);

        tx.create(docRef, {'foo': 'bar'});

        await expectLater(
          tx.getQuery(query),
          throwsA(isA<FirestoreException>()),
        );
      });

      test('getAll() after write throws', () async {
        final docRef = firestore.doc('col/doc');
        final tx = Transaction(firestore, null);

        tx.create(docRef, {'foo': 'bar'});

        await expectLater(
          tx.getAll([docRef]),
          throwsA(isA<FirestoreException>()),
        );
      });
    });

    group('retry logic', () {
      final nonRetryableCodes = [
        (FirestoreClientErrorCode.notFound, 'notFound'),
        (FirestoreClientErrorCode.alreadyExists, 'alreadyExists'),
        (FirestoreClientErrorCode.permissionDenied, 'permissionDenied'),
        (FirestoreClientErrorCode.failedPrecondition, 'failedPrecondition'),
        (FirestoreClientErrorCode.outOfRange, 'outOfRange'),
        (FirestoreClientErrorCode.unimplemented, 'unimplemented'),
        (FirestoreClientErrorCode.dataLoss, 'dataLoss'),
      ];

      for (final (code, name) in nonRetryableCodes) {
        test('does not retry on non-retryable code: $name', () async {
          var callCount = 0;
          await expectLater(
            firestore.runTransaction((_) async {
              callCount++;
              throw FirestoreException(code, 'non-retryable error');
            }),
            throwsA(
              isA<FirestoreException>().having(
                (e) => e.errorCode,
                'errorCode',
                code,
              ),
            ),
          );
          expect(callCount, 1);
        });
      }

      final retryableCodes = [
        (FirestoreClientErrorCode.aborted, 'aborted'),
        (FirestoreClientErrorCode.cancelled, 'cancelled'),
        (FirestoreClientErrorCode.unknown, 'unknown'),
        (FirestoreClientErrorCode.deadlineExceeded, 'deadlineExceeded'),
        (FirestoreClientErrorCode.internal, 'internal'),
        (FirestoreClientErrorCode.unavailable, 'unavailable'),
        (FirestoreClientErrorCode.unauthenticated, 'unauthenticated'),
        (FirestoreClientErrorCode.resourceExhausted, 'resourceExhausted'),
      ];

      for (final (code, name) in retryableCodes) {
        test('retries on retryable code: $name (maxAttempts=1)', () async {
          var callCount = 0;
          await expectLater(
            firestore.runTransaction((_) async {
              callCount++;
              throw FirestoreException(code, 'retryable error');
            }, transactionOptions: ReadWriteTransactionOptions(maxAttempts: 1)),
            throwsA(
              isA<FirestoreException>().having(
                (e) => e.message,
                'message',
                contains('max attempts exceeded'),
              ),
            ),
          );
          expect(callCount, 1);
        });
      }

      test(
        'INVALID_ARGUMENT with "transaction has expired" is retried',
        () async {
          var callCount = 0;
          await expectLater(
            firestore.runTransaction((_) async {
              callCount++;
              throw FirestoreException(
                FirestoreClientErrorCode.invalidArgument,
                'The transaction has expired. Please retry.',
              );
            }, transactionOptions: ReadWriteTransactionOptions(maxAttempts: 1)),
            throwsA(
              isA<FirestoreException>().having(
                (e) => e.message,
                'message',
                contains('max attempts exceeded'),
              ),
            ),
          );
          expect(callCount, 1);
        },
      );

      test('INVALID_ARGUMENT without expiry message is not retried', () async {
        var callCount = 0;
        await expectLater(
          firestore.runTransaction((_) async {
            callCount++;
            throw FirestoreException(
              FirestoreClientErrorCode.invalidArgument,
              'some other invalid argument',
            );
          }),
          throwsA(
            isA<FirestoreException>().having(
              (e) => e.errorCode,
              'errorCode',
              FirestoreClientErrorCode.invalidArgument,
            ),
          ),
        );
        expect(callCount, 1);
      });

      test(
        'respects maxAttempts from ReadWriteTransactionOptions',
        () async {
          var callCount = 0;
          await expectLater(
            firestore.runTransaction((_) async {
              callCount++;
              throw FirestoreException(
                FirestoreClientErrorCode.aborted,
                'test abort',
              );
            }, transactionOptions: ReadWriteTransactionOptions(maxAttempts: 3)),
            throwsA(
              isA<FirestoreException>().having(
                (e) => e.message,
                'message',
                contains('max attempts exceeded'),
              ),
            ),
          );
          expect(callCount, 3);
        },
        timeout: const Timeout(Duration(seconds: 10)),
      );

      test('user-thrown non-FirestoreException is not retried', () async {
        var callCount = 0;
        await expectLater(
          firestore.runTransaction((_) async {
            callCount++;
            throw StateError('user error');
          }),
          throwsA(isA<StateError>()),
        );
        expect(callCount, 1);
      });
    });
  });
}
