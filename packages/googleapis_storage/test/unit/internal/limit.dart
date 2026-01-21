import 'dart:async';

import 'package:googleapis_storage/src/internal/limit.dart';
import 'package:test/test.dart';

void main() {
  group('ParallelLimit', () {
    group('constructor', () {
      test('should create with valid maxConcurrency', () {
        final limit = ParallelLimit(maxConcurrency: 5);
        expect(limit.maxConcurrency, 5);
        expect(limit.activeCount, 0);
        expect(limit.waitingCount, 0);
      });

      test('should create with maxConcurrency of 1', () {
        final limit = ParallelLimit(maxConcurrency: 1);
        expect(limit.maxConcurrency, 1);
      });

      test('should throw assertion error with maxConcurrency of 0', () {
        expect(
          () => ParallelLimit(maxConcurrency: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should throw assertion error with negative maxConcurrency', () {
        expect(
          () => ParallelLimit(maxConcurrency: -1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('acquire and release', () {
      test('should acquire immediately when under limit', () async {
        final limit = ParallelLimit(maxConcurrency: 2);
        await limit.acquire();
        expect(limit.activeCount, 1);
        expect(limit.waitingCount, 0);
      });

      test('should allow multiple acquires up to maxConcurrency', () async {
        final limit = ParallelLimit(maxConcurrency: 3);
        await limit.acquire();
        await limit.acquire();
        await limit.acquire();
        expect(limit.activeCount, 3);
        expect(limit.waitingCount, 0);
      });

      test('should queue operations when limit is reached', () async {
        final limit = ParallelLimit(maxConcurrency: 2);
        await limit.acquire();
        await limit.acquire();

        // Start acquiring a third one (should wait)
        final acquireFuture = limit.acquire();
        // Give it a moment to queue
        await Future.delayed(Duration(milliseconds: 10));

        expect(limit.activeCount, 2);
        expect(limit.waitingCount, 1);

        // Release one, should allow queued to proceed
        limit.release();
        await acquireFuture;

        expect(limit.activeCount, 2);
        expect(limit.waitingCount, 0);
      });

      test('should process queue in order', () async {
        final limit = ParallelLimit(maxConcurrency: 1);
        final order = <int>[];

        // Acquire first
        await limit.acquire();

        // Queue multiple operations
        final futures = <Future<void>>[];
        for (var i = 0; i < 5; i++) {
          final index = i;
          futures.add(
            limit.acquire().then((_) {
              order.add(index);
              limit.release();
            }),
          );
        }

        // Give time for all to queue
        await Future.delayed(Duration(milliseconds: 10));
        expect(limit.waitingCount, 5);

        // Release first, should process queue
        limit.release();

        // Wait for all to complete
        await Future.wait(futures);

        // Should process in order
        expect(order, [0, 1, 2, 3, 4]);
      });

      test('should throw assertion error on release without acquire', () {
        final limit = ParallelLimit(maxConcurrency: 1);
        expect(() => limit.release(), throwsA(isA<AssertionError>()));
      });

      test('should handle multiple releases correctly', () async {
        final limit = ParallelLimit(maxConcurrency: 3);
        await limit.acquire();
        await limit.acquire();
        await limit.acquire();

        limit.release();
        expect(limit.activeCount, 2);

        limit.release();
        expect(limit.activeCount, 1);

        limit.release();
        expect(limit.activeCount, 0);
      });
    });

    group('run', () {
      test('should run operation and return result', () async {
        final limit = ParallelLimit(maxConcurrency: 1);
        final result = await limit.run(() async => 42);
        expect(result, 42);
        expect(limit.activeCount, 0);
      });

      test('should run operation with string result', () async {
        final limit = ParallelLimit(maxConcurrency: 1);
        final result = await limit.run(() async => 'hello');
        expect(result, 'hello');
      });

      test('should release permit even if operation throws', () async {
        final limit = ParallelLimit(maxConcurrency: 1);
        try {
          await limit.run(() async {
            throw Exception('test error');
          });
        } catch (e) {
          expect(e, isA<Exception>());
        }
        // The finally block should have executed, releasing the permit
        expect(limit.activeCount, 0);
      });

      test('should limit concurrency with run', () async {
        final limit = ParallelLimit(maxConcurrency: 2);
        final activeOperations = <int>[];
        final completer = Completer<void>();

        // Start 4 operations, but only 2 should run concurrently
        final futures = <Future<void>>[];
        for (var i = 0; i < 4; i++) {
          futures.add(
            limit.run(() async {
              activeOperations.add(i);
              await completer.future;
            }),
          );
        }

        // Give time for operations to start
        await Future.delayed(Duration(milliseconds: 50));

        // Should have at most 2 active
        expect(activeOperations.length, lessThanOrEqualTo(2));
        expect(limit.activeCount, lessThanOrEqualTo(2));

        completer.complete();
        await Future.wait(futures);

        expect(limit.activeCount, 0);
        expect(activeOperations.length, 4);
      });

      test('should handle nested run calls', () async {
        // With maxConcurrency > 1, nested calls should work
        final limit = ParallelLimit(maxConcurrency: 2);
        final result = await limit.run(() async {
          // This should be able to run since we have concurrency of 2
          return await limit.run(() async => 42);
        });
        expect(result, 42);
        expect(limit.activeCount, 0);
      });
    });

    group('activeCount and waitingCount', () {
      test('should track active count correctly', () async {
        final limit = ParallelLimit(maxConcurrency: 3);
        expect(limit.activeCount, 0);

        await limit.acquire();
        expect(limit.activeCount, 1);

        await limit.acquire();
        expect(limit.activeCount, 2);

        limit.release();
        expect(limit.activeCount, 1);
      });

      test('should track waiting count correctly', () async {
        final limit = ParallelLimit(maxConcurrency: 1);
        await limit.acquire();

        final future1 = limit.acquire();
        await Future.delayed(Duration(milliseconds: 10));
        expect(limit.waitingCount, 1);

        final future2 = limit.acquire();
        await Future.delayed(Duration(milliseconds: 10));
        expect(limit.waitingCount, 2);

        limit.release();
        await future1;
        expect(limit.waitingCount, 1);

        limit.release();
        await future2;
        expect(limit.waitingCount, 0);
      });
    });

    group('concurrency scenarios', () {
      test('should handle maxConcurrency of 1 (serial execution)', () async {
        final limit = ParallelLimit(maxConcurrency: 1);
        final executionOrder = <int>[];
        final completers = List.generate(5, (_) => Completer<void>());

        // Start all operations
        final futures = <Future<void>>[];
        for (var i = 0; i < 5; i++) {
          final index = i;
          futures.add(
            limit.run(() async {
              executionOrder.add(index);
              await completers[index].future;
            }),
          );
        }

        // First should start immediately
        await Future.delayed(Duration(milliseconds: 10));
        expect(executionOrder, [0]);
        expect(limit.activeCount, 1);

        // Complete first, second should start
        completers[0].complete();
        await Future.delayed(Duration(milliseconds: 10));
        expect(executionOrder, [0, 1]);

        // Complete all
        for (var i = 1; i < 5; i++) {
          completers[i].complete();
        }
        await Future.wait(futures);

        expect(executionOrder, [0, 1, 2, 3, 4]);
      });

      test('should handle high concurrency', () async {
        final limit = ParallelLimit(maxConcurrency: 10);
        final activeCounts = <int>[];

        // Start 20 operations
        final futures = <Future<void>>[];
        for (var i = 0; i < 20; i++) {
          futures.add(
            limit.run(() async {
              activeCounts.add(limit.activeCount);
              await Future.delayed(Duration(milliseconds: 10));
            }),
          );
        }

        await Future.wait(futures);

        // All active counts should be <= 10
        expect(activeCounts.every((count) => count <= 10), isTrue);
        expect(limit.activeCount, 0);
      });

      test('should handle rapid acquire/release cycles', () async {
        final limit = ParallelLimit(maxConcurrency: 5);
        final futures = <Future<void>>[];

        for (var i = 0; i < 100; i++) {
          futures.add(
            limit.run(() async {
              // Very short operation
            }),
          );
        }

        await Future.wait(futures);
        expect(limit.activeCount, 0);
        expect(limit.waitingCount, 0);
      });
    });

    group('error handling', () {
      test('should release permit when run throws synchronously', () async {
        final limit = ParallelLimit(maxConcurrency: 1);
        try {
          await limit.run(() {
            throw Exception('sync error');
          });
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<Exception>());
        }
        // The finally block should execute, releasing the permit
        expect(limit.activeCount, 0);
      });

      test('should release permit when run throws asynchronously', () async {
        final limit = ParallelLimit(maxConcurrency: 1);
        try {
          await limit.run(() async {
            throw Exception('async error');
          });
        } on Exception {
          // Expected exception
        }
        expect(limit.activeCount, 0);
      });

      test('should handle errors in queued operations', () async {
        final limit = ParallelLimit(maxConcurrency: 1);
        await limit.acquire();

        // Queue an operation that will throw
        final errorFuture = limit.run(() async {
          throw Exception('queued error');
        });

        // Give time to queue
        await Future.delayed(Duration(milliseconds: 10));
        expect(limit.waitingCount, 1);

        // Release to allow queued operation to run
        limit.release();

        // Should throw error
        expect(() => errorFuture, throwsA(isA<Exception>()));

        // Permit should still be released
        await Future.delayed(Duration(milliseconds: 10));
        expect(limit.activeCount, 0);
      });
    });
  });

  group('BoundedQueue', () {
    group('constructor', () {
      test('should create with valid maxSize', () {
        final queue = BoundedQueue<int>(maxSize: 100);
        expect(queue.maxSize, 100);
        expect(queue.length, 0);
        expect(queue.isWaiting, false);
      });

      test('should create with subscription', () {
        final controller = StreamController<int>();
        final subscription = controller.stream.listen((_) {});
        final queue = BoundedQueue<int>(
          maxSize: 50,
          subscription: subscription,
        );

        expect(queue.subscription, subscription);
        subscription.cancel();
        controller.close();
      });

      test('should create with onError callback', () {
        var errorCaught = false;
        final queue = BoundedQueue<int>(
          maxSize: 50,
          onError: (error) {
            errorCaught = true;
          },
        );

        expect(queue.onError, isNotNull);
        queue.onError?.call(Exception('test'));
        expect(errorCaught, isTrue);
      });

      test('should throw assertion error with maxSize of 0', () {
        expect(
          () => BoundedQueue<int>(maxSize: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should throw assertion error with negative maxSize', () {
        expect(
          () => BoundedQueue<int>(maxSize: -1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('add', () {
      test('should add futures to queue', () {
        final queue = BoundedQueue<int>(maxSize: 10);
        final future1 = Future.value(1);
        final future2 = Future.value(2);

        queue.add(future1);
        expect(queue.length, 1);

        queue.add(future2);
        expect(queue.length, 2);
      });

      test('should track length correctly', () {
        final queue = BoundedQueue<String>(maxSize: 5);
        for (var i = 0; i < 5; i++) {
          queue.add(Future.value('item $i'));
        }
        expect(queue.length, 5);
      });
    });

    group('waitIfNeeded', () {
      test('should not wait when under maxSize', () async {
        final queue = BoundedQueue<int>(maxSize: 10);
        queue.add(Future.value(1));
        queue.add(Future.value(2));

        await queue.waitIfNeeded();
        expect(queue.length, 2);
        expect(queue.isWaiting, false);
      });

      test('should wait when at maxSize', () async {
        final queue = BoundedQueue<int>(maxSize: 3);
        final completers = List.generate(3, (_) => Completer<int>());

        for (var completer in completers) {
          queue.add(completer.future);
        }

        expect(queue.length, 3);

        // Start waiting (should pause subscription and wait)
        final waitFuture = queue.waitIfNeeded();

        // Give time to start waiting
        await Future.delayed(Duration(milliseconds: 10));
        expect(queue.isWaiting, true);

        // Complete all futures
        for (var completer in completers) {
          completer.complete(1);
        }

        await waitFuture;
        expect(queue.length, 0);
        expect(queue.isWaiting, false);
      });

      test('should pause and resume subscription', () async {
        final controller = StreamController<int>();
        final subscription = controller.stream.listen((_) {});

        final queue = BoundedQueue<int>(maxSize: 2, subscription: subscription);

        final completers = List.generate(2, (_) => Completer<int>());
        for (var completer in completers) {
          queue.add(completer.future);
        }

        // Verify subscription is not paused initially
        expect(subscription.isPaused, false);

        final waitFuture = queue.waitIfNeeded();
        await Future.delayed(Duration(milliseconds: 10));

        // Subscription should be paused while waiting
        expect(subscription.isPaused, true);

        for (var completer in completers) {
          completer.complete(1);
        }

        await waitFuture;

        // Subscription should be resumed after waiting
        expect(subscription.isPaused, false);

        subscription.cancel();
        controller.close();
      });

      test('should not wait if already waiting', () async {
        final queue = BoundedQueue<int>(maxSize: 2);
        final completers = List.generate(2, (_) => Completer<int>());

        for (var completer in completers) {
          queue.add(completer.future);
        }

        // Start first wait
        final wait1 = queue.waitIfNeeded();
        await Future.delayed(Duration(milliseconds: 10));
        expect(queue.isWaiting, true);

        // Try to wait again (should not start new wait)
        final wait2 = queue.waitIfNeeded();
        await Future.delayed(Duration(milliseconds: 10));

        // Complete futures
        for (var completer in completers) {
          completer.complete(1);
        }

        await wait1;
        await wait2;

        expect(queue.length, 0);
        expect(queue.isWaiting, false);
      });

      test('should call onError when future throws', () async {
        var errorCaught = false;
        Object? caughtError;

        final queue = BoundedQueue<int>(
          maxSize: 2,
          onError: (error) {
            errorCaught = true;
            caughtError = error;
          },
        );

        final errorFuture = Future<int>.error(Exception('test error'));
        queue.add(Future.value(1));
        queue.add(errorFuture);

        try {
          await queue.waitIfNeeded();
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<Exception>());
          // onError should be called before the exception is rethrown
          expect(errorCaught, isTrue);
          expect(caughtError, isA<Exception>());
        }
      });

      test('should rethrow error after calling onError', () async {
        final queue = BoundedQueue<int>(
          maxSize: 2,
          onError: (error) {
            // Error handler called but doesn't prevent rethrow
          },
        );

        queue.add(Future.value(1));
        queue.add(Future<int>.error(Exception('test')));

        expect(() => queue.waitIfNeeded(), throwsA(isA<Exception>()));
      });

      test('should clear queue after waiting', () async {
        final queue = BoundedQueue<int>(maxSize: 2);
        queue.add(Future.value(1));
        queue.add(Future.value(2));

        await queue.waitIfNeeded();
        expect(queue.length, 0);
      });
    });

    group('waitForAll', () {
      test('should wait for all futures', () async {
        final queue = BoundedQueue<int>(maxSize: 10);
        final completers = List.generate(5, (_) => Completer<int>());

        for (var completer in completers) {
          queue.add(completer.future);
        }

        expect(queue.length, 5);

        // Start waiting
        final waitFuture = queue.waitForAll();

        // Complete futures
        for (var i = 0; i < completers.length; i++) {
          completers[i].complete(i);
        }

        await waitFuture;
        expect(queue.length, 0);
      });

      test('should do nothing when queue is empty', () async {
        final queue = BoundedQueue<int>(maxSize: 10);
        await queue.waitForAll();
        expect(queue.length, 0);
      });

      test('should not pause/resume subscription', () async {
        final controller = StreamController<int>();
        final subscription = controller.stream.listen((_) {});

        final queue = BoundedQueue<int>(
          maxSize: 10,
          subscription: subscription,
        );

        queue.add(Future.value(1));
        await queue.waitForAll();

        // Subscription should not be paused by waitForAll
        expect(subscription.isPaused, false);

        subscription.cancel();
        controller.close();
      });

      test('should handle errors in futures', () async {
        final queue = BoundedQueue<int>(maxSize: 10);
        queue.add(Future.value(1));
        queue.add(Future<int>.error(Exception('error')));

        expect(() => queue.waitForAll(), throwsA(isA<Exception>()));
      });
    });

    group('clear', () {
      test('should clear all futures from queue', () {
        final queue = BoundedQueue<int>(maxSize: 10);
        queue.add(Future.value(1));
        queue.add(Future.value(2));
        queue.add(Future.value(3));

        expect(queue.length, 3);
        queue.clear();
        expect(queue.length, 0);
      });

      test('should clear empty queue', () {
        final queue = BoundedQueue<int>(maxSize: 10);
        queue.clear();
        expect(queue.length, 0);
      });

      test('should not wait for futures when clearing', () async {
        final queue = BoundedQueue<int>(maxSize: 10);
        final completer = Completer<int>();
        queue.add(completer.future);

        queue.clear();
        expect(queue.length, 0);

        // Completing the future should not affect queue
        completer.complete(1);
        await Future.delayed(Duration(milliseconds: 10));
        expect(queue.length, 0);
      });
    });

    group('isWaiting', () {
      test('should be false initially', () {
        final queue = BoundedQueue<int>(maxSize: 10);
        expect(queue.isWaiting, false);
      });

      test('should be true while waiting', () async {
        final queue = BoundedQueue<int>(maxSize: 2);
        final completers = List.generate(2, (_) => Completer<int>());

        for (var completer in completers) {
          queue.add(completer.future);
        }

        final waitFuture = queue.waitIfNeeded();
        await Future.delayed(Duration(milliseconds: 10));

        expect(queue.isWaiting, true);

        for (var completer in completers) {
          completer.complete(1);
        }

        await waitFuture;
        expect(queue.isWaiting, false);
      });
    });

    group('complex scenarios', () {
      test('should handle multiple waitIfNeeded calls', () async {
        final queue = BoundedQueue<int>(maxSize: 3);

        // First batch
        final batch1 = List.generate(3, (i) => Completer<int>());
        for (var c in batch1) {
          queue.add(c.future);
        }

        final wait1 = queue.waitIfNeeded();
        await Future.delayed(Duration(milliseconds: 10));
        expect(queue.isWaiting, true);

        for (var c in batch1) {
          c.complete(1);
        }
        await wait1;

        // Second batch
        final batch2 = List.generate(3, (i) => Completer<int>());
        for (var c in batch2) {
          queue.add(c.future);
        }

        final wait2 = queue.waitIfNeeded();
        await Future.delayed(Duration(milliseconds: 10));
        expect(queue.isWaiting, true);

        for (var c in batch2) {
          c.complete(2);
        }
        await wait2;

        expect(queue.length, 0);
      });

      test('should handle mixed successful and failing futures', () async {
        var errorCaught = false;
        final queue = BoundedQueue<int>(
          maxSize: 3,
          onError: (error) {
            errorCaught = true;
          },
        );

        queue.add(Future.value(1));
        queue.add(Future.value(2));
        queue.add(Future<int>.error(Exception('error')));

        try {
          await queue.waitIfNeeded();
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<Exception>());
          // onError should be called before the exception is rethrown
          expect(errorCaught, isTrue);
        }
      });

      test('should handle rapid add/clear cycles', () {
        final queue = BoundedQueue<int>(maxSize: 100);
        for (var i = 0; i < 1000; i++) {
          queue.add(Future.value(i));
          if (i % 10 == 0) {
            queue.clear();
          }
        }
        // Final state depends on last clear
        expect(queue.length, lessThanOrEqualTo(10));
      });
    });
  });
}
