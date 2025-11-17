import 'dart:async';
import 'dart:convert';

import 'package:googleapis/storage/v1.dart';
import 'package:googleapis_dart_storage/src/internal/api_error.dart';

import '../../googleapis_dart_storage.dart' show Storage;

/// Matches the Node SDK IdempotencyStrategy enum semantics.
enum IdempotencyStrategy { retryAlways, retryConditional, retryNever }

typedef RetryableErrorFn = bool Function(Object error);

class RetryOptions {
  final bool autoRetry;
  final int maxRetries;
  final Duration totalTimeout;
  final Duration maxRetryDelay;
  final double retryDelayMultiplier;
  final RetryableErrorFn? retryableErrorFn;
  final IdempotencyStrategy idempotencyStrategy;

  const RetryOptions({
    this.autoRetry = true,
    this.maxRetries = 3,
    this.totalTimeout = const Duration(seconds: 600),
    this.maxRetryDelay = const Duration(seconds: 64),
    this.retryDelayMultiplier = 2.0,
    this.retryableErrorFn,
    this.idempotencyStrategy = IdempotencyStrategy.retryConditional,
  });

  RetryOptions copyWith({
    bool? autoRetry,
    int? maxRetries,
    Duration? totalTimeout,
    Duration? maxRetryDelay,
    double? retryDelayMultiplier,
    RetryableErrorFn? retryableErrorFn,
    IdempotencyStrategy? idempotencyStrategy,
  }) {
    return RetryOptions(
      autoRetry: autoRetry ?? this.autoRetry,
      maxRetries: maxRetries ?? this.maxRetries,
      totalTimeout: totalTimeout ?? this.totalTimeout,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      retryDelayMultiplier: retryDelayMultiplier ?? this.retryDelayMultiplier,
      retryableErrorFn: retryableErrorFn ?? this.retryableErrorFn,
      idempotencyStrategy: idempotencyStrategy ?? this.idempotencyStrategy,
    );
  }
}

class PreconditionOptions {
  final int? ifGenerationMatch;
  final int? ifGenerationNotMatch;
  final int? ifMetagenerationMatch;
  final int? ifMetagenerationNotMatch;

  const PreconditionOptions({
    this.ifGenerationMatch,
    this.ifGenerationNotMatch,
    this.ifMetagenerationMatch,
    this.ifMetagenerationNotMatch,
  });
}

/// Options for delete operations, mirroring Node's DeleteOptions.
///
/// Extends [PreconditionOptions] to include delete-specific options.
class DeleteOptions extends PreconditionOptions {
  /// If true, ignore 404 errors (treat as success if object doesn't exist).
  final bool ignoreNotFound;

  const DeleteOptions({
    this.ignoreNotFound = false,
    super.ifGenerationMatch,
    super.ifGenerationNotMatch,
    super.ifMetagenerationMatch,
    super.ifMetagenerationNotMatch,
  });
}

/// Decide if an error should be retried, roughly mirroring Node's
/// Util.shouldRetryRequest (status codes + JSON error reasons).
bool defaultShouldRetryError(Object error) {
  if (error is! ApiError) return false;
  final apiError = error as ApiError;
  final code = apiError.code;
  if (code != null && <int>[408, 429, 500, 502, 503, 504].contains(code)) {
    return true;
  }

  // Try to inspect JSON error payload for reasons.
  final details = apiError.details;
  Map<String, dynamic>? json;
  if (details is String) {
    try {
      final decoded = jsonDecode(details);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      }
    } catch (_) {
      // ignore parse failures
    }
  } else if (details is Map<String, dynamic>) {
    json = details;
  }

  if (json != null) {
    final errorField = json['error'];
    final errorsList = (errorField is Map<String, dynamic>)
        ? errorField['errors']
        : json['errors'];
    if (errorsList is List) {
      for (final e in errorsList) {
        if (e is Map<String, dynamic>) {
          final reason = e['reason']?.toString();
          if (reason == 'rateLimitExceeded' ||
              reason == 'userRateLimitExceeded' ||
              (reason != null && reason.contains('EAI_AGAIN'))) {
            return true;
          }
        }
      }
    }
  }

  return false;
}

/// Helper for determining if a mutation should be retried based on preconditions.
///
/// [getPreconditionValue] extracts the relevant precondition value to check
/// (e.g., `ifGenerationMatch` for objects, `ifMetagenerationMatch` for buckets).
bool _shouldRetryMutation(
  PreconditionOptions? callPreconditions,
  PreconditionOptions? instancePreconditions,
  RetryOptions retryOptions,
  int? Function(PreconditionOptions?) getPreconditionValue,
) {
  final conditionalWithoutPrecondition =
      getPreconditionValue(callPreconditions) == null &&
          getPreconditionValue(instancePreconditions) == null &&
          retryOptions.idempotencyStrategy ==
              IdempotencyStrategy.retryConditional;

  final neverStrategy =
      retryOptions.idempotencyStrategy == IdempotencyStrategy.retryNever;

  return !(conditionalWithoutPrecondition || neverStrategy);
}

/// Helper mirroring Node's File.shouldRetryBasedOnPreconditionAndIdempotencyStrat.
///
/// For object-level mutations whose idempotency is controlled by
/// `ifGenerationMatch`:
/// - If `idempotencyStrategy` is RetryNever -> do not retry.
/// - If `idempotencyStrategy` is RetryConditional AND neither call-level nor
///   instance-level `ifGenerationMatch` is set -> do not retry.
/// - Otherwise -> allow retries.
bool shouldRetryObjectMutation(
  PreconditionOptions? callPreconditions,
  PreconditionOptions? instancePreconditions,
  RetryOptions retryOptions,
) {
  return _shouldRetryMutation(
    callPreconditions,
    instancePreconditions,
    retryOptions,
    (opts) => opts?.ifGenerationMatch,
  );
}

/// Helper for bucket-level metadata/delete mutations whose idempotency is
/// controlled by `ifMetagenerationMatch`.
bool shouldRetryBucketMutation(
  PreconditionOptions? callPreconditions,
  PreconditionOptions? instancePreconditions,
  RetryOptions retryOptions,
) {
  return _shouldRetryMutation(
    callPreconditions,
    instancePreconditions,
    retryOptions,
    (opts) => opts?.ifMetagenerationMatch,
  );
}

/// Function type for determining if a mutation should be retried based on preconditions.
typedef ShouldRetryMutationFn = bool Function(
  PreconditionOptions? callPreconditions,
  PreconditionOptions? instancePreconditions,
  RetryOptions retryOptions,
);

/// Generic retry executor implementing exponential backoff.
class RetryExecutor {
  /// Creates a [RetryExecutor] that automatically determines retry behavior
  /// based on preconditions and idempotency strategy.
  ///
  /// [shouldRetryMutation] determines if retries should be allowed based on
  /// preconditions. Use [shouldRetryObjectMutation] for object mutations or
  /// [shouldRetryBucketMutation] for bucket mutations.
  ///
  /// If [shouldRetryMutation] is not provided, retries will always be allowed
  /// (unless disabled in [RetryOptions]).
  RetryExecutor(
    this.storage, {
    PreconditionOptions? preconditionOptions,
    PreconditionOptions? instancePreconditions,
    ShouldRetryMutationFn? shouldRetryMutation,
  })  : preconditionOptions =
            preconditionOptions ?? const PreconditionOptions(),
        instancePreconditions = instancePreconditions {
    // Compute effective retry options based on preconditions and idempotency strategy
    final baseRetry = storage.retryOptions;
    if (shouldRetryMutation != null) {
      final allowRetry = shouldRetryMutation(
        preconditionOptions ?? const PreconditionOptions(),
        instancePreconditions,
        baseRetry,
      );
      _effectiveRetry = allowRetry
          ? baseRetry
          : baseRetry.copyWith(autoRetry: false, maxRetries: 0);
    } else {
      _effectiveRetry = baseRetry;
    }
  }

  final Storage storage;
  final PreconditionOptions preconditionOptions;
  final PreconditionOptions? instancePreconditions;
  late final RetryOptions _effectiveRetry;

  /// Execute an operation with retry logic.
  ///
  /// Uses the effective retry options computed during construction, unless
  /// [retryOptions] is explicitly provided to override them.
  ///
  /// [classify] determines if an error should be retried. Defaults to
  /// [defaultShouldRetryError] if not provided.
  Future<T> retry<T>(
    Future<T> Function(StorageApi client) operation, {
    RetryOptions? retryOptions,
    bool Function(Object error)? classify,
  }) async {
    final options = retryOptions ?? _effectiveRetry;
    final client = await storage.client;

    if (!options.autoRetry || options.maxRetries <= 0) {
      return operation(client);
    }

    final errorClassifier = classify ?? defaultShouldRetryError;
    final start = DateTime.now();
    var attempt = 0;
    var delay = const Duration(seconds: 1);

    while (true) {
      try {
        return await operation(client);
      } catch (e) {
        attempt++;
        final elapsed = DateTime.now().difference(start);
        if (attempt > options.maxRetries || elapsed >= options.totalTimeout) {
          rethrow;
        }

        final shouldRetry = errorClassifier(e as dynamic) ||
            (options.retryableErrorFn?.call(e as dynamic) ?? false);
        if (!shouldRetry) rethrow;

        if (delay > options.maxRetryDelay) {
          delay = options.maxRetryDelay;
        }
        await Future<void>.delayed(delay);
        delay = Duration(
          milliseconds:
              (delay.inMilliseconds * options.retryDelayMultiplier).toInt(),
        );
      }
    }
  }
}
