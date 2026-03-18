part of 'firestore.dart';

/// A helper for rate limiting operations using a token bucket algorithm.
///
/// Implements the Firebase 500/50/5 rule:
/// - Start at 500 operations per second
/// - Increase by 1.5x every 5 minutes
/// - Cap at a maximum (default 10,000 ops/sec)
///
/// Before each operation, the BulkWriter waits until it has enough capacity
/// to send the operation without exceeding the rate limit.
@internal
class RateLimiter {
  RateLimiter(
    this._initialCapacity,
    this._multiplier,
    this._multiplierMillis,
    this._maximumCapacity,
  ) : _availableTokens = _initialCapacity.toDouble(),
      _lastRefillTime = DateTime.now().millisecondsSinceEpoch;

  final int _initialCapacity;
  final double _multiplier;
  final int _multiplierMillis;
  final int _maximumCapacity;

  double _availableTokens;
  int _lastRefillTime;

  /// The current capacity (ops/sec).
  double get _currentCapacity {
    final now = DateTime.now().millisecondsSinceEpoch;
    final millisSinceLastRefill = now - _lastRefillTime;

    // Calculate how many times the capacity should have scaled up
    final timesScaled = (millisSinceLastRefill / _multiplierMillis).floor();

    if (timesScaled > 0) {
      var newCapacity = _initialCapacity.toDouble();
      for (var i = 0; i < timesScaled; i++) {
        newCapacity *= _multiplier;
      }

      return math.min(newCapacity, _maximumCapacity.toDouble());
    }

    return _availableTokens;
  }

  /// Tries to make the number of operations. Returns true if the request
  /// succeeded and false otherwise.
  bool tryMakeRequest(int numOperations) {
    _refillTokens();
    if (numOperations <= _availableTokens) {
      _availableTokens -= numOperations;
      return true;
    }
    return false;
  }

  /// Returns the number of ms needed to refill to the specified number of
  /// tokens, or 0 if capacity is already available.
  int getNextRequestDelayMs(int requestTokens) {
    _refillTokens();

    if (requestTokens <= _availableTokens) {
      return 0;
    }

    final capacity = _currentCapacity;

    // If the request is larger than capacity, it can never be fulfilled
    if (capacity < requestTokens) {
      return -1;
    }

    final tokensNeeded = requestTokens - _availableTokens;
    final refillTimeMs = (tokensNeeded * 1000 / capacity).ceil();

    return refillTimeMs;
  }

  /// Refills the number of available tokens based on how much time has elapsed
  /// since the last refill.
  void _refillTokens() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedTime = now - _lastRefillTime;

    final capacity = _currentCapacity;
    final tokensToAdd = elapsedTime * capacity / 1000;

    _availableTokens = math.min(_availableTokens + tokensToAdd, capacity);

    _lastRefillTime = now;
  }

  /// Requests the specified number of tokens. Waits until the tokens are
  /// available before returning.
  Future<void> request(int requestTokens) async {
    final delayMs = getNextRequestDelayMs(requestTokens);

    if (delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
      _refillTokens();
    }

    _availableTokens -= requestTokens;
  }

  /// For testing: Get available tokens.
  @visibleForTesting
  double get availableTokens => _availableTokens;

  /// For testing: Get maximum capacity.
  @visibleForTesting
  int get maximumCapacity => _maximumCapacity;
}
