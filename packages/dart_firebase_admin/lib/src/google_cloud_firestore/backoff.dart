import 'dart:async';
import 'dart:math';

class ExponentialBackoffSetting {
  const ExponentialBackoffSetting({
    this.initialDelayMs,
    this.backoffFactor,
    this.maxDelayMs,
    this.jitterFactor,
  });

  final int? initialDelayMs;
  final double? backoffFactor;
  final int? maxDelayMs;
  final double? jitterFactor;
}

/// A helper for running delayed tasks following an exponential backoff curve
/// between attempts.
///
/// Each delay is made up of a "base" delay which follows the exponential
/// backoff curve, and a "jitter" (+/- 50% by default) that is calculated and
/// added to the base delay. This prevents clients from accidentally
/// synchronizing their delays causing spikes of load to the backend.
///
/// @private
/// @internal
class ExponentialBackoff {
  ExponentialBackoff({
    ExponentialBackoffSetting options = const ExponentialBackoffSetting(),
  })  : initialDelayMs = options.initialDelayMs ?? defaultBackOffInitialDelayMs,
        backoffFactor = options.backoffFactor ?? defaultBackOffFactor,
        maxDelayMs = options.maxDelayMs ?? defaultBackOffMaxDelayMs,
        jitterFactor = options.jitterFactor ?? defaultJitterFactor;

  static const defaultBackOffInitialDelayMs = 100;
  static const defaultBackOffFactor = 2.0;
  static const defaultBackOffMaxDelayMs = 10000;
  static const defaultJitterFactor = 0.5;

  static const maxRetryAttempts = 25;

  final int initialDelayMs;
  final double backoffFactor;
  final int maxDelayMs;
  final double jitterFactor;

  int _retryCount = 0;
  int _currentBaseMs = 0;
  bool _awaitingBackoffCompletion = false;

  /// Returns a future that resolves after currentDelayMs, and increases the
  /// delay for any subsequent attempts.
  ///
  /// @return A [Future] that resolves when the current delay elapsed.
  Future<void> backoffAndWait() async {
    if (_awaitingBackoffCompletion) {
      throw Exception('A backoff operation is already in progress.');
    }

    if (_retryCount > maxRetryAttempts) {
      throw Exception('Exceeded maximum number of retries allowed.');
    }

    final delayWithJitterMs = _currentBaseMs + _jitterDelayMs();

    _currentBaseMs = (_currentBaseMs * backoffFactor).toInt();
    _currentBaseMs = _currentBaseMs.clamp(initialDelayMs, maxDelayMs);
    _retryCount += 1;

    await Future<void>.delayed(Duration(milliseconds: delayWithJitterMs));
    _awaitingBackoffCompletion = false;
  }

  /// Resets the backoff delay and retry count.
  ///
  /// The very next [backoffAndWait] will have no delay. If it is called again
  /// (i.e. due to an error), [initialDelayMs] (plus jitter) will be used, and
  /// subsequent ones will increase according to the [backoffFactor].
  void reset() {
    _retryCount = 0;
    _currentBaseMs = 0;
  }

  /// Resets the backoff delay to the maximum delay (e.g. for use after a
  /// RESOURCE_EXHAUSTED error).
  void resetToMax() {
    _currentBaseMs = maxDelayMs;
  }

  int _jitterDelayMs() {
    return ((Random().nextDouble() - 0.5) * jitterFactor * _currentBaseMs)
        .toInt();
  }
}
