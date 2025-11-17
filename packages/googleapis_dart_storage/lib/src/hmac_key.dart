part of '../googleapis_dart_storage.dart';

/// Options when constructing an [HmacKey] handle.
class HmacKeyOptions {
  final String? projectId;

  const HmacKeyOptions({this.projectId});
}

enum HmacKeyState {
  active('ACTIVE'),
  inactive('INACTIVE'),
  deleted('DELETED');

  final String value;
  const HmacKeyState(this.value);
}

/// Subset of HMAC metadata that can be updated, mirroring Node's
/// SetHmacKeyMetadata.
class SetHmacKeyMetadata extends storage_v1.HmacKeyMetadata {
  /// New state: 'ACTIVE' or 'INACTIVE'.
  SetHmacKeyMetadata({HmacKeyState? state, super.etag})
      : super(state: state?.value);
}

/// A handle to a single HMAC key, analogous to the Node.js HmacKey class.
///
/// This class does not expose the secret; that is only returned at creation
/// time by `projects.hmacKeys.create`.
class HmacKey extends ServiceObject<storage_v1.HmacKeyMetadata>
    with
        GettableMixin<storage_v1.HmacKeyMetadata>,
        SettableMixin<storage_v1.HmacKeyMetadata>,
        DeletableMixin<storage_v1.HmacKeyMetadata> {
  /// A reference to the [Storage] associated with this [HmacKey] instance.
  Storage get storage => service as Storage;

  final String accessId;
  final String? projectId;

  /// Cached metadata; call [getMetadata] to refresh from the server.
  @override
  late storage_v1.HmacKeyMetadata metadata;

  HmacKey._(Storage storage, this.accessId, {HmacKeyOptions? options})
      : projectId = options?.projectId,
        super(service: storage, id: accessId) {
    if (projectId == null || projectId!.isEmpty) {
      throw ApiError(
        'Project ID is required to work with HMAC keys. '
        'Provide HmacKeyOptions.projectId.',
      );
    }
    metadata = storage_v1.HmacKeyMetadata()
      ..accessId = accessId
      ..projectId = options?.projectId;
  }

  /// Delete this HMAC key.
  ///
  /// The server requires the key to be `INACTIVE` before deletion.
  @override
  Future<void> delete({PreconditionOptions? options}) async {
    // HMAC key delete doesn't use preconditions, but we accept the parameter
    // for base class compatibility. userProject is not supported via options.
    final executor = RetryExecutor(storage);

    try {
      await executor.retry<void>(
        (client) async {
          await client.projects.hmacKeys.delete(
            projectId!,
            accessId,
          );
        },
      );
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError('Failed to delete HMAC key $accessId', details: e);
    }
  }

  /// Retrieve and populate this HMAC key's metadata, and return this [HmacKey]
  /// instance.
  ///
  /// This method does not give the HMAC key secret, as it is only returned
  /// on creation.
  ///
  /// The authenticated user must have `storage.hmacKeys.get` permission
  /// for the project in which the key exists.
  Future<HmacKey> getInstance({String? userProject}) async {
    await getMetadata(userProject: userProject);
    return this;
  }

  /// Retrieve and cache the latest metadata for this HMAC key.
  ///
  /// This method does not give the HMAC key secret, as it is only returned
  /// on creation.
  ///
  /// The authenticated user must have `storage.hmacKeys.get` permission
  /// for the project in which the key exists.
  ///
  /// Note: This method has a different signature than the mixin's `getMetadata()`
  /// (which takes no parameters), so both methods are available.
  Future<storage_v1.HmacKeyMetadata> getMetadata({String? userProject}) async {
    final executor = RetryExecutor(storage);

    try {
      metadata = await executor.retry<storage_v1.HmacKeyMetadata>(
        (client) async => await client.projects.hmacKeys.get(
          projectId!,
          accessId,
          userProject: userProject,
        ),
      );
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError('Failed to get HMAC key metadata $accessId', details: e);
    }

    return metadata;
  }

  @override
  Future<storage_v1.HmacKeyMetadata> get() async {
    return await getMetadata();
  }

  /// Helper for HMAC key mutations: only retry if idempotency strategy is retryAlways.
  ///
  /// ETag preconditions are not fully supported for HMAC keys, so we disable
  /// retries unless the strategy explicitly allows always retrying.
  static bool _shouldRetryHmacKeyMutation(
    PreconditionOptions? callPreconditions,
    PreconditionOptions? instancePreconditions,
    RetryOptions retryOptions,
  ) {
    return retryOptions.idempotencyStrategy == IdempotencyStrategy.retryAlways;
  }

  /// Update the metadata for this HMAC key (e.g. state, etag).
  ///
  /// Node disables retries here unless IdempotencyStrategy is RetryAlways,
  /// because ETag preconditions are not fully supported. We mirror that by
  /// using [shouldRetryHmacKeyMutation] with [RetryExecutor].
  ///
  /// This overrides [ServiceObject.setMetadata] to provide custom retry behavior.
  /// The [metadata] parameter should have [state] and/or [etag] set for updates.
  /// To use [SetHmacKeyMetadata], create an [HmacKeyMetadata] with the desired
  /// state and etag values.
  @override
  Future<storage_v1.HmacKeyMetadata> setMetadata(
      storage_v1.HmacKeyMetadata updateMetadata) async {
    final executor = RetryExecutor(
      storage,
      shouldRetryMutation: _shouldRetryHmacKeyMutation,
    );

    final request = storage_v1.HmacKeyMetadata()
      ..state = updateMetadata.state
      ..etag = updateMetadata.etag;

    try {
      metadata = await executor.retry<storage_v1.HmacKeyMetadata>(
        (client) async => await client.projects.hmacKeys.update(
          request,
          projectId!,
          accessId,
        ),
      );
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError('Failed to update HMAC key metadata $accessId',
          details: e);
    }

    return metadata;
  }
}
