import 'dart:async';
import 'dart:convert';

import 'package:googleapis/storage/v1.dart';
import 'package:google_cloud/google_cloud.dart' as google_cloud;
import 'package:googleapis_storage/googleapis_storage.dart';

/// Decide if an error should be retried, roughly mirroring Node's
/// Util.shouldRetryRequest (status codes + JSON error reasons).
bool defaultShouldRetryError(dynamic error) {
  if (error is! ApiError) return false;
  final apiError = error;
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
      retryOptions.idempotencyStrategy == IdempotencyStrategy.retryConditional;

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
typedef ShouldRetryMutationFn =
    bool Function(
      PreconditionOptions? callPreconditions,
      PreconditionOptions? instancePreconditions,
      RetryOptions retryOptions,
    );

/// Generic retry executor implementing exponential backoff.
class ApiExecutor {
  /// Creates a [RetryExecutor] that automatically determines retry behavior
  /// based on preconditions and idempotency strategy.
  ///
  /// [retryOptions] can be provided to explicitly set retry behavior.
  /// Otherwise, retry behavior is computed based on [shouldRetryMutation] and
  /// preconditions.
  ///
  /// [shouldRetryMutation] determines if retries should be allowed based on
  /// preconditions. Use [shouldRetryObjectMutation] for object mutations or
  /// [shouldRetryBucketMutation] for bucket mutations.
  ///
  /// If [shouldRetryMutation] is not provided, retries will always be allowed
  /// (unless disabled in [RetryOptions]).
  ApiExecutor(
    this.storage, {
    RetryOptions? retryOptions,
    PreconditionOptions? preconditionOptions,
    this.instancePreconditions,
    ShouldRetryMutationFn? shouldRetryMutation,
    bool Function(dynamic error)? classify,
  }) : preconditionOptions = preconditionOptions ?? const PreconditionOptions(),
       _classify = classify {
    // If retryOptions is explicitly provided, use it directly
    if (retryOptions != null) {
      _effectiveRetry = retryOptions;
      return;
    }

    // Otherwise, compute effective retry options based on preconditions and idempotency strategy
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

  /// Creates a [RetryExecutor] with retries explicitly disabled.
  ///
  /// Useful for non-idempotent operations that should not be retried.
  factory ApiExecutor.withoutRetries(Storage storage) {
    final noRetryOptions = storage.retryOptions.copyWith(
      autoRetry: false,
      maxRetries: 0,
    );
    return ApiExecutor(storage, retryOptions: noRetryOptions);
  }

  final Storage storage;
  final PreconditionOptions preconditionOptions;
  final PreconditionOptions? instancePreconditions;
  late final RetryOptions _effectiveRetry;
  final bool Function(dynamic error)? _classify;

  /// Execute an operation with retry logic.
  ///
  /// For operations that don't require a projectId (e.g., bucket-scoped operations).
  /// Use [executeWithProjectId] for operations that need a projectId.
  Future<T> execute<T>(Future<T> Function(StorageApi client) operation) async {
    return _executeWithRetry(() async {
      final storageClient = await storage.storageClient;
      return operation(storageClient);
    });
  }

  /// Execute an operation with retry logic and projectId resolution.
  ///
  /// Resolves projectId using: [projectIdOverride] ?? storage.options.projectId ?? computeProjectId()
  /// This matches Node.js behavior: `const projectId = query.projectId || this.projectId;`
  ///
  /// Throws [ArgumentError] if projectId cannot be resolved.
  Future<T> executeWithProjectId<T>(
    Future<T> Function(StorageApi client, String projectId) operation, {
    String? projectIdOverride,
  }) async {
    return _executeWithRetry(() async {
      final storageClient = await storage.storageClient;

      final explicitProjectId = projectIdOverride ?? storage.options.projectId;
      final resolvedProjectId =
          explicitProjectId ?? await google_cloud.computeProjectId();

      return operation(storageClient, resolvedProjectId);
    });
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    // If retries are disabled, execute the operation once and return the result.
    if (!_effectiveRetry.autoRetry || _effectiveRetry.maxRetries <= 0) {
      try {
        return await operation();
      } catch (e) {
        // Convert DetailedApiRequestError to ApiError before propagating
        if (e is! ApiError) {
          throw ApiError.fromException(e);
        }
        rethrow;
      }
    }

    final errorClassifier = _classify ?? defaultShouldRetryError;
    final start = DateTime.now();
    var attempt = 0;
    var delay = const Duration(seconds: 1);

    while (true) {
      try {
        return await operation();
      } catch (e) {
        // Convert DetailedApiRequestError to ApiError before retry logic
        final apiError = e is ApiError ? e : ApiError.fromException(e);

        attempt++;
        final elapsed = DateTime.now().difference(start);
        if (attempt > _effectiveRetry.maxRetries ||
            elapsed >= _effectiveRetry.totalTimeout) {
          throw apiError;
        }

        final shouldRetry =
            errorClassifier(apiError) ||
            (_effectiveRetry.retryableErrorFn?.call(apiError) ?? false);
        if (!shouldRetry) throw apiError;

        if (delay > _effectiveRetry.maxRetryDelay) {
          delay = _effectiveRetry.maxRetryDelay;
        }
        await Future<void>.delayed(delay);
        delay = Duration(
          milliseconds:
              (delay.inMilliseconds * _effectiveRetry.retryDelayMultiplier)
                  .toInt(),
        );
      }
    }
  }
}
