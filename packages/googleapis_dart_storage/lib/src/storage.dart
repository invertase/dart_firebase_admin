part of '../googleapis_dart_storage.dart';

class StorageOptions extends ServiceOptions {
  final String? apiEndpoint;
  final Object? crc32cGenerator; // TODO
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
    Object? crc32cGenerator,
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

class Storage extends Service {
  final StorageOptions options;
  final Object acl = {}; // TODO
  final Object crc32cGenerator = {}; // TODO

  Storage(this.options)
      : super(
          _buildServiceConfig(options),
          _buildMergedOptions(options),
        );

  /// Calculate the API endpoint and whether it's a custom endpoint.
  static ({String apiEndpoint, bool customEndpoint}) _calculateEndpoint(
      StorageOptions options) {
    final universe = options.universeDomain ?? 'googleapis.com';
    var apiEndpoint = 'https://storage.$universe';
    var customEndpoint = false;

    // Check Zone for test environment variables, fallback to Platform.environment
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
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

  Object channel(String id, String resourceId) {
    throw UnimplementedError();
  }

  Future<void> createBucket() {
    throw UnimplementedError();
  }

  Future<void> createHmacKey() {
    throw UnimplementedError();
  }

  Future<void> getBuckets() {
    throw UnimplementedError();
  }

  Future<void> getHmacKeys() {
    throw UnimplementedError();
  }

  Future<void> getServiceAccount() {
    throw UnimplementedError();
  }

  Object hmacKey(String accessId, Object? options) {
    throw UnimplementedError();
  }

  Future<void> getBucketsStream() {
    throw UnimplementedError();
  }

  Future<void> getHmacKeysStream() {
    throw UnimplementedError();
  }
}
