import 'dart:async';

/// A semaphore-like mechanism to limit the number of concurrent operations.
///
/// This class allows you to limit how many operations can run in parallel,
/// queuing additional operations until a slot becomes available.
///
/// Example:
/// ```dart
/// final limit = ParallelLimit(maxConcurrency: 10);
///
/// // Option 1: Manual acquire/release
/// await limit.acquire();
/// try {
///   await doWork();
/// } finally {
///   limit.release();
/// }
///
/// // Option 2: Using run() helper
/// await limit.run(() => doWork());
/// ```
class ParallelLimit {
  final int maxConcurrency;
  int _activeCount = 0;
  final _waitingQueue = <Completer<void>>[];

  /// Creates a [ParallelLimit] that allows at most [maxConcurrency] operations
  /// to run concurrently.
  ParallelLimit({required this.maxConcurrency})
      : assert(maxConcurrency > 0, 'maxConcurrency must be greater than 0');

  /// Acquires a permit to run an operation.
  ///
  /// If the limit has not been reached, this returns immediately.
  /// Otherwise, it waits until a slot becomes available.
  Future<void> acquire() async {
    if (_activeCount < maxConcurrency) {
      _activeCount++;
      return;
    }
    final completer = Completer<void>();
    _waitingQueue.add(completer);
    await completer.future;
  }

  /// Releases a permit, allowing the next waiting operation to proceed.
  void release() {
    assert(_activeCount > 0, 'release() called without matching acquire()');
    _activeCount--;
    if (_waitingQueue.isNotEmpty) {
      final next = _waitingQueue.removeAt(0);
      _activeCount++;
      next.complete();
    }
  }

  /// Runs [operation] with a permit, automatically acquiring and releasing.
  ///
  /// This is a convenience method that ensures [release] is always called,
  /// even if [operation] throws an exception.
  Future<T> run<T>(Future<T> Function() operation) async {
    await acquire();
    try {
      return await operation();
    } finally {
      release();
    }
  }

  /// The current number of active operations.
  int get activeCount => _activeCount;

  /// The number of operations waiting for a permit.
  int get waitingCount => _waitingQueue.length;
}

/// Manages a bounded queue of futures with automatic stream subscription control.
///
/// When the queue reaches [maxSize], the associated stream subscription is paused,
/// all pending futures are awaited, and then the subscription is resumed.
///
/// Example:
/// ```dart
/// final queue = BoundedQueue<void>(
///   maxSize: 1000,
///   subscription: streamSubscription,
///   onError: (error) {
///     // Handle queue overflow errors
///   },
/// );
///
/// // Add futures to the queue
/// queue.add(someFuture);
///
/// // Manually wait for queue to drain if needed
/// await queue.waitIfNeeded();
///
/// // Wait for all remaining futures
/// await queue.waitForAll();
/// ```
class BoundedQueue<T> {
  final int maxSize;
  StreamSubscription? subscription;
  final void Function(Object error)? onError;
  final List<Future<T>> _futures = [];
  var _isWaiting = false;

  /// Creates a [BoundedQueue] with the specified [maxSize].
  ///
  /// When the queue reaches [maxSize], [subscription] will be paused while
  /// waiting for futures to complete. If [onError] is provided, it will be
  /// called if an error occurs while waiting for futures.
  BoundedQueue({
    required this.maxSize,
    this.subscription,
    this.onError,
  }) : assert(maxSize > 0, 'maxSize must be greater than 0');

  /// Adds a future to the queue.
  void add(Future<T> future) {
    _futures.add(future);
  }

  /// The current number of futures in the queue.
  int get length => _futures.length;

  /// Whether the queue is currently waiting for futures to complete.
  bool get isWaiting => _isWaiting;

  /// Waits for the queue to drain if it has reached [maxSize].
  ///
  /// This will pause [subscription] (if provided), wait for all futures to
  /// complete, clear the queue, and then resume the subscription.
  ///
  /// If an error occurs while waiting, [onError] will be called (if provided).
  Future<void> waitIfNeeded() async {
    if (_futures.length >= maxSize && !_isWaiting) {
      _isWaiting = true;
      subscription?.pause();
      try {
        await Future.wait(_futures);
        _futures.clear();
      } catch (e) {
        onError?.call(e);
        rethrow;
      } finally {
        _isWaiting = false;
        subscription?.resume();
      }
    }
  }

  /// Waits for all remaining futures in the queue to complete.
  ///
  /// This does not pause/resume the subscription - it simply waits for
  /// all pending futures.
  Future<void> waitForAll() async {
    if (_futures.isNotEmpty) {
      await Future.wait(_futures);
      _futures.clear();
    }
  }

  /// Clears all futures from the queue without waiting for them.
  void clear() {
    _futures.clear();
  }
}
