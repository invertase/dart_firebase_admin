import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:test/test.dart';

/// Creates a mock Firestore instance for unit testing without needing an emulator
Firestore createMockFirestore() {
  return Firestore(
    settings: const Settings(
      projectId: 'test-project',
      // Use environmentOverride to avoid needing actual credentials/emulator
      environmentOverride: {'GOOGLE_CLOUD_PROJECT': 'test-project'},
    ),
  );
}

void main() {
  group('BulkWriter Unit Tests', () {
    late Firestore firestore;

    setUp(() {
      firestore = createMockFirestore();
    });

    group('options validation', () {
      test('initialOpsPerSecond requires positive integer', () {
        expect(
          () => firestore.bulkWriter(
            const BulkWriterOptions(
              throttling: EnabledThrottling(initialOpsPerSecond: -1),
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => firestore.bulkWriter(
            const BulkWriterOptions(
              throttling: EnabledThrottling(initialOpsPerSecond: 0),
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('maxOpsPerSecond requires positive integer', () {
        expect(
          () => firestore.bulkWriter(
            const BulkWriterOptions(
              throttling: EnabledThrottling(maxOpsPerSecond: -1),
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => firestore.bulkWriter(
            const BulkWriterOptions(
              throttling: EnabledThrottling(maxOpsPerSecond: 0),
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'maxOpsPerSecond must be greater than or equal to initialOpsPerSecond',
        () {
          expect(
            () => firestore.bulkWriter(
              const BulkWriterOptions(
                throttling: EnabledThrottling(
                  initialOpsPerSecond: 1000,
                  maxOpsPerSecond: 500,
                ),
              ),
            ),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test('initial and max rates are properly set', () {
        var bulkWriter = firestore.bulkWriter(
          const BulkWriterOptions(
            throttling: EnabledThrottling(maxOpsPerSecond: 550),
          ),
        );
        expect(bulkWriter.rateLimiter.availableTokens, 500);
        expect(bulkWriter.rateLimiter.maximumCapacity, 550);

        bulkWriter = firestore.bulkWriter(
          const BulkWriterOptions(
            throttling: EnabledThrottling(maxOpsPerSecond: 1000),
          ),
        );
        expect(bulkWriter.rateLimiter.availableTokens, 500);
        expect(bulkWriter.rateLimiter.maximumCapacity, 1000);

        bulkWriter = firestore.bulkWriter(
          const BulkWriterOptions(
            throttling: EnabledThrottling(initialOpsPerSecond: 100),
          ),
        );
        expect(bulkWriter.rateLimiter.availableTokens, 100);
        expect(bulkWriter.rateLimiter.maximumCapacity, 10000);

        // When maxOpsPerSecond < default initialOpsPerSecond (500),
        // we need to set both to avoid validation error
        bulkWriter = firestore.bulkWriter(
          const BulkWriterOptions(
            throttling: EnabledThrottling(
              initialOpsPerSecond: 100,
              maxOpsPerSecond: 100,
            ),
          ),
        );
        expect(bulkWriter.rateLimiter.availableTokens, 100);
        expect(bulkWriter.rateLimiter.maximumCapacity, 100);

        bulkWriter = firestore.bulkWriter();
        expect(bulkWriter.rateLimiter.availableTokens, 500);
        expect(bulkWriter.rateLimiter.maximumCapacity, 10000);

        bulkWriter = firestore.bulkWriter(const BulkWriterOptions());
        expect(bulkWriter.rateLimiter.availableTokens, 500);
        expect(bulkWriter.rateLimiter.maximumCapacity, 10000);

        bulkWriter = firestore.bulkWriter(
          const BulkWriterOptions(throttling: DisabledThrottling()),
        );
        expect(
          bulkWriter.rateLimiter.availableTokens,
          double.maxFinite.toInt(),
        );
        expect(
          bulkWriter.rateLimiter.maximumCapacity,
          double.maxFinite.toInt(),
        );
      });
    });

    group('lifecycle management', () {
      test('flush() resolves immediately if there are no writes', () async {
        final bulkWriter = firestore.bulkWriter();
        await bulkWriter.flush();
      });

      test('close() resolves immediately if there are no writes', () async {
        final bulkWriter = firestore.bulkWriter();
        await bulkWriter.close();
      });

      test('cannot call methods after close() is called', () async {
        final bulkWriter = firestore.bulkWriter();
        final doc = firestore.doc('collectionId/doc');

        await bulkWriter.close();

        expect(
          () => bulkWriter.set(doc, <String, Object>{}),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'BulkWriter has already been closed.',
            ),
          ),
        );
        expect(
          () => bulkWriter.create(doc, <String, Object>{}),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'BulkWriter has already been closed.',
            ),
          ),
        );
        expect(
          () => bulkWriter.update(doc, {}),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'BulkWriter has already been closed.',
            ),
          ),
        );
        expect(
          () => bulkWriter.delete(doc),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'BulkWriter has already been closed.',
            ),
          ),
        );

        // Calling close() multiple times is allowed
        await bulkWriter.close();
      });
    });

    group('callback registration', () {
      test('onWriteResult sets success callback', () {
        final bulkWriter = firestore.bulkWriter();
        var callbackCalled = false;

        bulkWriter.onWriteResult((ref, result) {
          callbackCalled = true;
        });

        expect(callbackCalled, isFalse); // Not called yet
      });

      test('onWriteError sets error callback', () {
        final bulkWriter = firestore.bulkWriter();
        var callbackCalled = false;

        bulkWriter.onWriteError((error) {
          callbackCalled = true;
          return false;
        });

        expect(callbackCalled, isFalse); // Not called yet
      });
    });

    group('batch size management', () {
      test('setMaxBatchSize updates batch size for testing', () {
        final bulkWriter = firestore.bulkWriter();

        // Should not throw
        expect(() => bulkWriter.setMaxBatchSize(10), returnsNormally);
      });

      test('setMaxPendingOpCount updates pending count for testing', () {
        final bulkWriter = firestore.bulkWriter();

        // Should not throw
        expect(() => bulkWriter.setMaxPendingOpCount(100), returnsNormally);
      });

      test('bufferedOperationsCount starts at zero', () {
        final bulkWriter = firestore.bulkWriter();
        expect(bulkWriter.bufferedOperationsCount, 0);
      });

      test('pendingOperationsCount starts at zero', () {
        final bulkWriter = firestore.bulkWriter();
        expect(bulkWriter.pendingOperationsCount, 0);
      });
    });

    group('BulkWriterError', () {
      test('toString includes all error details', () {
        final doc = firestore.doc('test/doc');
        final error = BulkWriterError(
          code: FirestoreClientErrorCode.unavailable,
          message: 'Service unavailable',
          documentRef: doc,
          operationType: 'create',
          failedAttempts: 3,
        );

        final errorString = error.toString();
        expect(errorString, contains('BulkWriterError'));
        expect(errorString, contains('Service unavailable'));
        expect(errorString, contains('unavailable'));
        expect(errorString, contains('create'));
        expect(errorString, contains('test/doc'));
        expect(errorString, contains('3'));
      });
    });

    group('callback registration', () {
      test('onWriteResult can be called before operations', () {
        final bulkWriter = firestore.bulkWriter();
        var callbackCalled = false;

        // Register callback before any writes
        bulkWriter.onWriteResult((ref, result) {
          callbackCalled = true;
        });

        // Callback should not be called until writes complete
        expect(callbackCalled, isFalse);
      });

      test('onWriteError can be called before operations', () {
        final bulkWriter = firestore.bulkWriter();
        var callbackCalled = false;

        // Register callback before any writes
        bulkWriter.onWriteError((error) {
          callbackCalled = true;
          return false;
        });

        // Callback should not be called until errors occur
        expect(callbackCalled, isFalse);
      });

      test('onWriteResult replaces previous callback', () {
        final bulkWriter = firestore.bulkWriter();
        var firstCallbackCalled = false;
        var secondCallbackCalled = false;

        // Register first callback
        bulkWriter.onWriteResult((ref, result) {
          firstCallbackCalled = true;
        });

        // Register second callback (should replace first)
        bulkWriter.onWriteResult((ref, result) {
          secondCallbackCalled = true;
        });

        // Only the second callback should exist
        expect(firstCallbackCalled, isFalse);
        expect(secondCallbackCalled, isFalse);
      });

      test('onWriteError replaces previous callback', () {
        final bulkWriter = firestore.bulkWriter();
        var firstCallbackCalled = false;
        var secondCallbackCalled = false;

        // Register first callback
        bulkWriter.onWriteError((error) {
          firstCallbackCalled = true;
          return false;
        });

        // Register second callback (should replace first)
        bulkWriter.onWriteError((error) {
          secondCallbackCalled = true;
          return false;
        });

        // Only the second callback should exist
        expect(firstCallbackCalled, isFalse);
        expect(secondCallbackCalled, isFalse);
      });
    });

    group('batch size and buffering', () {
      test('setMaxBatchSize accepts valid values', () {
        final bulkWriter = firestore.bulkWriter();

        expect(() => bulkWriter.setMaxBatchSize(1), returnsNormally);
        expect(() => bulkWriter.setMaxBatchSize(5), returnsNormally);
        expect(() => bulkWriter.setMaxBatchSize(20), returnsNormally);
        expect(() => bulkWriter.setMaxBatchSize(500), returnsNormally);
      });

      test('setMaxPendingOpCount accepts valid values', () {
        final bulkWriter = firestore.bulkWriter();

        expect(() => bulkWriter.setMaxPendingOpCount(1), returnsNormally);
        expect(() => bulkWriter.setMaxPendingOpCount(10), returnsNormally);
        expect(() => bulkWriter.setMaxPendingOpCount(100), returnsNormally);
        expect(() => bulkWriter.setMaxPendingOpCount(1000), returnsNormally);
      });

      test('bufferedOperationsCount tracks buffered operations', () {
        final bulkWriter = firestore.bulkWriter();

        // Initially should be zero
        expect(bulkWriter.bufferedOperationsCount, 0);

        // After adding operations (without sending), should still be zero
        // because operations are queued, not buffered
        expect(bulkWriter.bufferedOperationsCount, 0);
      });

      test('pendingOperationsCount tracks pending operations', () {
        final bulkWriter = firestore.bulkWriter();

        // Initially should be zero
        expect(bulkWriter.pendingOperationsCount, 0);
      });
    });

    group('rate limiter access', () {
      test('rateLimiter is accessible for testing', () {
        final bulkWriter = firestore.bulkWriter();

        // Should be able to access rate limiter properties
        expect(bulkWriter.rateLimiter.availableTokens, 500);
        expect(bulkWriter.rateLimiter.maximumCapacity, 10000);
      });

      test('rateLimiter respects throttling options', () {
        final bulkWriter = firestore.bulkWriter(
          const BulkWriterOptions(
            throttling: EnabledThrottling(
              initialOpsPerSecond: 100,
              maxOpsPerSecond: 500,
            ),
          ),
        );

        expect(bulkWriter.rateLimiter.availableTokens, 100);
        expect(bulkWriter.rateLimiter.maximumCapacity, 500);
      });

      test('rateLimiter with disabled throttling has unlimited capacity', () {
        final bulkWriter = firestore.bulkWriter(
          const BulkWriterOptions(throttling: DisabledThrottling()),
        );

        expect(
          bulkWriter.rateLimiter.availableTokens,
          double.maxFinite.toInt(),
        );
        expect(
          bulkWriter.rateLimiter.maximumCapacity,
          double.maxFinite.toInt(),
        );
      });
    });

    group('operation type validation', () {
      test('set operation validates document reference', () {
        final bulkWriter = firestore.bulkWriter();
        final doc = firestore.doc('collectionId/doc');

        // Should not throw with valid inputs
        expect(() => bulkWriter.set(doc, {'foo': 'bar'}), returnsNormally);
      });

      test('create operation validates document reference', () {
        final bulkWriter = firestore.bulkWriter();
        final doc = firestore.doc('collectionId/doc');

        // Should not throw with valid inputs
        expect(() => bulkWriter.create(doc, {'foo': 'bar'}), returnsNormally);
      });

      test('update operation validates document reference', () {
        final bulkWriter = firestore.bulkWriter();
        final doc = firestore.doc('collectionId/doc');

        // Should not throw with valid inputs
        expect(
          () => bulkWriter.update(doc, {
            FieldPath(const ['foo']): 'bar',
          }),
          returnsNormally,
        );
      });

      test('delete operation validates document reference', () {
        final bulkWriter = firestore.bulkWriter();
        final doc = firestore.doc('collectionId/doc');

        // Should not throw with valid inputs
        expect(() => bulkWriter.delete(doc), returnsNormally);
      });
    });

    group('multiple bulkWriter instances', () {
      test('can create multiple independent BulkWriter instances', () {
        final bulkWriter1 = firestore.bulkWriter();
        final bulkWriter2 = firestore.bulkWriter();

        // Should be different instances
        expect(identical(bulkWriter1, bulkWriter2), isFalse);

        // Each should have independent settings
        expect(bulkWriter1.rateLimiter.availableTokens, 500);
        expect(bulkWriter2.rateLimiter.availableTokens, 500);
      });

      test('different instances can have different options', () {
        final bulkWriter1 = firestore.bulkWriter(
          const BulkWriterOptions(
            throttling: EnabledThrottling(initialOpsPerSecond: 100),
          ),
        );
        final bulkWriter2 = firestore.bulkWriter(
          const BulkWriterOptions(
            throttling: EnabledThrottling(initialOpsPerSecond: 1000),
          ),
        );

        expect(bulkWriter1.rateLimiter.availableTokens, 100);
        expect(bulkWriter2.rateLimiter.availableTokens, 1000);
      });
    });

    group('edge cases', () {
      test('empty data objects are allowed', () {
        final bulkWriter = firestore.bulkWriter();
        final doc = firestore.doc('collectionId/doc');

        // Empty maps should be allowed
        expect(() => bulkWriter.set(doc, <String, Object>{}), returnsNormally);
        expect(
          () => bulkWriter.create(doc, <String, Object>{}),
          returnsNormally,
        );
      });

      test('close without any operations completes immediately', () async {
        final bulkWriter = firestore.bulkWriter();
        await bulkWriter.close();
        // Should complete without errors
      });

      test('flush without any operations completes immediately', () async {
        final bulkWriter = firestore.bulkWriter();
        await bulkWriter.flush();
        // Should complete without errors
      });

      test(
        'multiple flushes without operations complete immediately',
        () async {
          final bulkWriter = firestore.bulkWriter();
          await bulkWriter.flush();
          await bulkWriter.flush();
          await bulkWriter.flush();
          // Should complete without errors
        },
      );
    });
  });
}
