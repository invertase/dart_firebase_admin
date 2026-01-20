part of '../googleapis_storage.dart';

/// A handle to a single HMAC key, analogous to the Node.js HmacKey class.
///
/// This class does not expose the secret; that is only returned at creation
/// time by `projects.hmacKeys.create`.
class HmacKey extends ServiceObject<HmacKeyMetadata>
    with
        GettableMixin<HmacKeyMetadata, HmacKey>,
        DeletableMixin<HmacKeyMetadata> {
  /// A reference to the [Storage] associated with this [HmacKey] instance.
  final Storage storage;

  final String _accessId;

  HmacKey._(this.storage, this._accessId, {HmacKeyOptions? options})
    : super(
        service: storage,
        id: _accessId,
        metadata: HmacKeyMetadata()
          ..accessId = _accessId
          ..projectId = options?.projectId ?? storage.options.projectId,
      );

  /// Delete this HMAC key.
  ///
  /// The server requires the key to be `INACTIVE` before deletion.
  @override
  Future<void> delete({PreconditionOptions? options}) async {
    // HMAC key delete doesn't use preconditions, but we accept the parameter
    // for base class compatibility. userProject is not supported via options.
    final api = ApiExecutor(storage);

    await api.executeWithProjectId<void>((client, projectId) async {
      await client.projects.hmacKeys.delete(projectId, _accessId);
    });
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
  @override
  Future<HmacKeyMetadata> getMetadata({String? userProject}) async {
    final api = ApiExecutor(storage);

    final metadata = await api.executeWithProjectId<HmacKeyMetadata>(
      (client, projectId) async => await client.projects.hmacKeys.get(
        projectId,
        _accessId,
        userProject: userProject,
      ),
    );

    setInstanceMetadata(metadata);
    return metadata;
  }

  /// Get the HMAC key metadata and return this instance.
  ///
  /// This follows the standard ServiceObject pattern: calls [getMetadata()]
  /// to fetch and update metadata, then returns this instance.
  ///
  /// Note: HMAC keys don't support userProject, so this parameter is ignored.
  @override
  Future<HmacKey> get({String? userProject}) async {
    await getMetadata();
    return this;
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
  Future<HmacKeyMetadata> setMetadata(HmacKeyMetadata updateMetadata) async {
    final api = ApiExecutor(
      storage,
      shouldRetryMutation: _shouldRetryHmacKeyMutation,
    );

    final request = HmacKeyMetadata()
      ..state = updateMetadata.state
      ..etag = updateMetadata.etag;

    final metadata = await api.executeWithProjectId<HmacKeyMetadata>(
      (client, projectId) async =>
          await client.projects.hmacKeys.update(request, projectId, _accessId),
    );
    setInstanceMetadata(metadata);
    return metadata;
  }
}
