part of '../googleapis_dart_storage.dart';

class StorageOptions extends ServiceOptions {
  final String? apiEndpoint;
  final Crc32Generator? crc32cGenerator;
  final RetryOptions? retryOptions;

  const StorageOptions({
    this.apiEndpoint,
    this.crc32cGenerator,
    this.retryOptions,
    super.authClient,
    super.useAuthWithCustomEndpoint,
    super.universeDomain,
  });

  StorageOptions copyWith({
    String? apiEndpoint,
    Crc32Generator? crc32cGenerator,
    RetryOptions? retryOptions,
    Future<http.Client>? authClient,
    bool? useAuthWithCustomEndpoint,
    String? universeDomain,
  }) {
    return StorageOptions(
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      crc32cGenerator: crc32cGenerator ?? this.crc32cGenerator,
      retryOptions: retryOptions ?? this.retryOptions,
      authClient: authClient ?? super.authClient,
      useAuthWithCustomEndpoint:
          useAuthWithCustomEndpoint ?? super.useAuthWithCustomEndpoint,
      universeDomain: universeDomain ?? super.universeDomain,
    );
  }
}

class Storage extends Service<StorageOptions> {
  final Crc32Generator crc32cGenerator;

  Storage(StorageOptions options)
      : crc32cGenerator =
            options.crc32cGenerator ?? defaultCrc32cValidatorGenerator,
        super(_buildServiceConfig(options), _buildMergedOptions(options));

  /// Calculate the API endpoint and whether it's a custom endpoint.
  static ({String apiEndpoint, bool customEndpoint}) _calculateEndpoint(
      StorageOptions options) {
    final universe = options.universeDomain ?? 'googleapis.com';
    var apiEndpoint = 'https://storage.$universe';
    var customEndpoint = false;

    // Check Zone for test environment variables, fallback to Platform.environment
    final env = Zone.current[envSymbol] as Map<String, String>? ??
        io.Platform.environment;
    final emulatorHost = env['STORAGE_EMULATOR_HOST'];
    if (emulatorHost != null) {
      apiEndpoint = Storage._sanitizeEndpoint(emulatorHost);
      customEndpoint = true;
    }

    // Explicit apiEndpoint in options takes precedence
    if (options.apiEndpoint != null && options.apiEndpoint != apiEndpoint) {
      apiEndpoint = Storage._sanitizeEndpoint(options.apiEndpoint!);
      customEndpoint = true;
    }

    return (apiEndpoint: apiEndpoint, customEndpoint: customEndpoint);
  }

  static ServiceConfig _buildServiceConfig(StorageOptions options) {
    final (:apiEndpoint, :customEndpoint) = Storage._calculateEndpoint(options);

    return ServiceConfig(
      apiEndpoint: apiEndpoint,
      customEndpoint: customEndpoint,
      useAuthWithCustomEndpoint: options.useAuthWithCustomEndpoint,
      authClient: options.authClient,
    );
  }

  static StorageOptions _buildMergedOptions(StorageOptions options) {
    final result = Storage._calculateEndpoint(options);
    return options.copyWith(apiEndpoint: result.apiEndpoint);
  }

  static String _sanitizeEndpoint(String url) {
    if (!RegExp(r'^https?://').hasMatch(url)) {
      url = 'https://$url';
    }
    return url.replaceAll(RegExp(r'/+$'), ''); // Remove trailing slashes
  }

  /// Get the retry options, with a default if not set.
  RetryOptions get retryOptions => options.retryOptions ?? const RetryOptions();

  Bucket bucket(String name, [BucketOptions? options]) {
    if (name.isEmpty) {
      // TODO: Use exception class
      throw Exception('Bucket name is required');
    }

    return Bucket._(this, name, options);
  }

  Channel channel(String id, String resourceId) {
    if (id.isEmpty) {
      throw ArgumentError('Channel ID is required');
    }

    if (resourceId.isEmpty) {
      throw ArgumentError('Resource ID is required');
    }

    return Channel._(this, id, resourceId);
  }

  Future<Bucket> createBucket(BucketMetadata bucket) async {
    final executor = RetryExecutor.withoutRetries(this);

    if (bucket.name == null) {
      throw ArgumentError('Bucket name is required');
    }

    try {
      return await executor.retry(
        (client) async {
          final inner = await client.buckets.insert(
            bucket,
            options.projectId,
          );

          final instance = this.bucket(bucket.name!);
          instance.setInstanceMetadata(inner);
          return instance;
        },
      );
    } catch (e) {
      throw ApiError('Failed to create bucket', details: e);
    }
  }

  Future<HmacKey> createHmacKey(String serviceAccountEmail,
      [CreateHmacKeyOptions? options]) async {
    final executor = RetryExecutor.withoutRetries(this);

    try {
      return await executor.retry<HmacKey>(
        (client) async {
          final response = await client.projects.hmacKeys.create(
            options?.projectId ?? this.options.projectId,
            serviceAccountEmail,
            userProject: options?.userProject,
          );

          final metadata = response.metadata;

          if (metadata == null) {
            throw ApiError(
              'Failed to create HMAC key',
              details: 'No metadata returned',
            );
          }

          final hmacKey = HmacKey._(
            this,
            metadata.accessId!,
            options: HmacKeyOptions(projectId: metadata.projectId),
          );
          hmacKey.setInstanceMetadata(metadata);
          return hmacKey;
        },
      );
    } catch (e) {
      throw ApiError('Failed to create HMAC key', details: e);
    }
  }

  Future<(List<Bucket> buckets, GetBucketsOptions? nextQuery)> getBuckets(
      [GetBucketsOptions? options = const GetBucketsOptions()]) async {
    final opts = options ?? const GetBucketsOptions();
    final autoPaginate = opts.autoPaginate ?? true;

    if (autoPaginate) {
      // Collect all buckets from the stream
      final buckets = <Bucket>[];
      await for (final bucket in getBucketsStream(opts)) {
        buckets.add(bucket);
      }
      return (buckets, null);
    } else {
      // Single page request - no auto-pagination
      final executor = RetryExecutor(this);
      try {
        final response = await executor.retry(
          (client) async {
            return await client.buckets.list(
              opts.projectId ?? this.options.projectId,
              maxResults: opts.maxResults,
              pageToken: opts.pageToken,
              prefix: opts.prefix,
              projection: opts.projection?.name,
              softDeleted: opts.softDeleted,
              userProject: opts.userProject,
            );
          },
        );

        final itemsArray = response.items ?? [];
        final buckets = itemsArray.map((bucketMetadata) {
          final bucketInstance = bucket(bucketMetadata.id!);
          bucketInstance.setInstanceMetadata(bucketMetadata);
          return bucketInstance;
        }).toList();

        // Build nextQuery if there's a nextPageToken
        final nextQuery = response.nextPageToken != null
            ? opts.copyWith(pageToken: response.nextPageToken)
            : null;

        return (buckets, nextQuery);
      } catch (e) {
        throw ApiError('Failed to get buckets', details: e);
      }
    }
  }

  Future<(List<HmacKey> keys, GetHmacKeysOptions? nextQuery)> getHmacKeys(
      [GetHmacKeysOptions? options = const GetHmacKeysOptions()]) async {
    final opts = options ?? const GetHmacKeysOptions();
    final autoPaginate = opts.autoPaginate ?? true;

    if (autoPaginate) {
      // Collect all keys from the stream
      final keys = <HmacKey>[];
      await for (final key in getHmacKeysStream(opts)) {
        keys.add(key);
      }
      return (keys, null);
    } else {
      // Single page request - no auto-pagination
      final executor = RetryExecutor(this);
      try {
        final response = await executor.retry(
          (client) async {
            return await client.projects.hmacKeys.list(
              opts.projectId ?? this.options.projectId,
              serviceAccountEmail: opts.serviceAccountEmail,
              showDeletedKeys: opts.showDeletedKeys,
              maxResults: opts.maxResults,
              pageToken: opts.pageToken,
              userProject: opts.userProject,
            );
          },
        );

        final itemsArray = response.items ?? [];
        final keys = itemsArray.map((hmacKeyMetadata) {
          final hmacKeyInstance = hmacKey(
            hmacKeyMetadata.accessId!,
            HmacKeyOptions(projectId: hmacKeyMetadata.projectId),
          );
          hmacKeyInstance.setInstanceMetadata(hmacKeyMetadata);
          return hmacKeyInstance;
        }).toList();

        // Build nextQuery if there's a nextPageToken
        final nextQuery = response.nextPageToken != null
            ? opts.copyWith(pageToken: response.nextPageToken)
            : null;

        return (keys, nextQuery);
      } catch (e) {
        throw ApiError('Failed to get HMAC keys', details: e);
      }
    }
  }

  Future<storage_v1.ServiceAccount> getServiceAccount(
      [GetServiceAccountOptions? options]) async {
    final executor = RetryExecutor(this);

    try {
      return await executor.retry(
        (client) async {
          return client.projects.serviceAccount.get(
            this.options.projectId,
            userProject: options?.userProject,
          );
        },
      );
    } catch (e) {
      throw ApiError('Failed to get service account', details: e);
    }
  }

  HmacKey hmacKey(String accessId, [HmacKeyOptions? options]) {
    if (accessId.isEmpty) {
      // TODO: Use exception class
      throw Exception('Access ID is required');
    }

    return HmacKey._(this, accessId, options: options);
  }

  /// Stream buckets in this storage instance.
  ///
  /// Automatically handles pagination and yields buckets as they arrive.
  /// Similar to Node's `getBucketsStream`.
  Stream<Bucket> getBucketsStream(
      [GetBucketsOptions? options = const GetBucketsOptions()]) {
    final opts = options ?? const GetBucketsOptions();
    final executor = RetryExecutor(this);

    return Streaming<Bucket, GetBucketsOptions>(
      fetcher: (GetBucketsOptions pageOptions) async {
        final response = await executor.retry(
          (client) async {
            return await client.buckets.list(
              pageOptions.projectId ?? this.options.projectId,
              maxResults: pageOptions.maxResults,
              pageToken: pageOptions.pageToken,
              prefix: pageOptions.prefix,
              projection: pageOptions.projection?.name,
              softDeleted: pageOptions.softDeleted,
              userProject: pageOptions.userProject,
            );
          },
        );

        final itemsArray = response.items ?? [];
        final buckets = itemsArray.map((bucketMetadata) {
          final bucketInstance = bucket(bucketMetadata.id!);
          bucketInstance.setInstanceMetadata(bucketMetadata);
          return bucketInstance;
        });

        return (buckets, response.nextPageToken);
      },
      initialOptions: opts,
      maxApiCalls: opts.maxApiCalls,
      updatePageToken: (options, pageToken) =>
          options.copyWith(pageToken: pageToken),
    );
  }

  /// Stream HMAC keys in this storage instance.
  ///
  /// Automatically handles pagination and yields HMAC keys as they arrive.
  /// Similar to Node's `getHmacKeysStream`.
  Stream<HmacKey> getHmacKeysStream(
      [GetHmacKeysOptions? options = const GetHmacKeysOptions()]) {
    final opts = options ?? const GetHmacKeysOptions();
    final executor = RetryExecutor(this);

    return Streaming<HmacKey, GetHmacKeysOptions>(
      fetcher: (GetHmacKeysOptions pageOptions) async {
        final response = await executor.retry(
          (client) async {
            return await client.projects.hmacKeys.list(
              pageOptions.projectId ?? this.options.projectId,
              serviceAccountEmail: pageOptions.serviceAccountEmail,
              showDeletedKeys: pageOptions.showDeletedKeys,
              maxResults: pageOptions.maxResults,
              pageToken: pageOptions.pageToken,
              userProject: pageOptions.userProject,
            );
          },
        );

        final itemsArray = response.items ?? [];
        final keys = itemsArray.map((hmacKeyMetadata) {
          final hmacKeyInstance = hmacKey(
            hmacKeyMetadata.accessId!,
            HmacKeyOptions(projectId: hmacKeyMetadata.projectId),
          );
          hmacKeyInstance.setInstanceMetadata(hmacKeyMetadata);
          return hmacKeyInstance;
        });

        return (keys, response.nextPageToken);
      },
      initialOptions: opts,
      maxApiCalls: opts.maxApiCalls,
      updatePageToken: (options, pageToken) =>
          options.copyWith(pageToken: pageToken),
    );
  }
}

class GetServiceAccountOptions {
  final String? userProject;

  const GetServiceAccountOptions({this.userProject});
}
