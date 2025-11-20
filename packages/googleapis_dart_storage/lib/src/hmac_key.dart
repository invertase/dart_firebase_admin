part of '../googleapis_dart_storage.dart';

/// Options when constructing an [HmacKey] handle.
class HmacKeyOptions {
  final String? projectId;

  const HmacKeyOptions({this.projectId});
}

class CreateHmacKeyOptions {
  final String? projectId;
  final String? userProject;

  const CreateHmacKeyOptions({this.projectId, this.userProject});
}

class GetHmacKeysOptions {
  final bool? autoPaginate;
  final String? projectId;
  final String? serviceAccountEmail;
  final bool? showDeletedKeys;
  final int? maxApiCalls;
  final int? maxResults;
  final String? pageToken;
  final String? userProject;

  const GetHmacKeysOptions({
    this.autoPaginate = true,
    this.projectId,
    this.userProject,
    this.serviceAccountEmail,
    this.showDeletedKeys,
    this.maxApiCalls,
    this.maxResults,
    this.pageToken,
  });

  GetHmacKeysOptions copyWith({
    bool? autoPaginate,
    String? projectId,
    String? serviceAccountEmail,
    bool? showDeletedKeys,
    int? maxApiCalls,
    int? maxResults,
    String? pageToken,
    String? userProject,
  }) {
    return GetHmacKeysOptions(
      autoPaginate: autoPaginate ?? this.autoPaginate,
      projectId: projectId ?? this.projectId,
      serviceAccountEmail: serviceAccountEmail ?? this.serviceAccountEmail,
      showDeletedKeys: showDeletedKeys ?? this.showDeletedKeys,
      maxApiCalls: maxApiCalls ?? this.maxApiCalls,
      maxResults: maxResults ?? this.maxResults,
      pageToken: pageToken ?? this.pageToken,
      userProject: userProject ?? this.userProject,
    );
  }
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

typedef HmacKeyMetadata = storage_v1.HmacKeyMetadata;

/// A handle to a single HMAC key, analogous to the Node.js HmacKey class.
///
/// This class does not expose the secret; that is only returned at creation
/// time by `projects.hmacKeys.create`.
class HmacKey extends ServiceObject<HmacKeyMetadata>
    with
        GettableMixin<HmacKeyMetadata, HmacKey>,
        DeletableMixin<HmacKeyMetadata> {
  /// A reference to the [Storage] associated with this [HmacKey] instance.
  Storage get storage => service as Storage;

  final String accessId;
  final String projectId;

  HmacKey._(Storage storage, this.accessId, {HmacKeyOptions? options})
      : projectId = options?.projectId ?? storage.options.projectId,
        super(
          service: storage,
          id: accessId,
          metadata: HmacKeyMetadata()
            ..accessId = accessId
            ..projectId = options?.projectId ?? storage.options.projectId,
        ) {
    if (projectId.isEmpty) {
      throw ApiError(
        'Project ID is required to work with HMAC keys. '
        'Provide HmacKeyOptions.projectId.',
      );
    }
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
            projectId,
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
  @override
  Future<HmacKeyMetadata> getMetadata({String? userProject}) async {
    final executor = RetryExecutor(storage);

    try {
      final metadata = await executor.retry<HmacKeyMetadata>(
        (client) async => await client.projects.hmacKeys.get(
          projectId,
          accessId,
          userProject: userProject,
        ),
      );

      setInstanceMetadata(metadata);
      return metadata;
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError('Failed to get HMAC key metadata $accessId', details: e);
    }
  }

  /// Get the HMAC key metadata and return this instance.
  ///
  /// This follows the standard ServiceObject pattern: calls [getMetadata()]
  /// to fetch and update metadata, then returns this instance.
  ///
  /// Note: This method has a different signature than the mixin's `get()` method
  /// (no parameters vs. optional userProject), but it follows the same pattern
  /// by calling [getMetadata()] internally.
  // ignore: invalid_override
  Future<HmacKey> get() async {
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
    final executor = RetryExecutor(
      storage,
      shouldRetryMutation: _shouldRetryHmacKeyMutation,
    );

    final request = HmacKeyMetadata()
      ..state = updateMetadata.state
      ..etag = updateMetadata.etag;

    try {
      final metadata = await executor.retry<HmacKeyMetadata>(
        (client) async => await client.projects.hmacKeys.update(
          request,
          projectId,
          accessId,
        ),
      );
      setInstanceMetadata(metadata);
      return metadata;
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError('Failed to update HMAC key metadata $accessId',
          details: e);
    }
  }
}
