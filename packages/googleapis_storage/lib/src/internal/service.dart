import 'dart:async';

import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:googleapis_storage/googleapis_storage.dart'; // Try importing to see StorageOptions
import 'package:http/http.dart' as http;
import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_auth/auth_io.dart' as auth_io;

typedef RequestInterceptor = http.BaseRequest Function(http.BaseRequest);

/// Base options class for service configuration.
///
/// In the node SDK, this extends GoogleAuthOptions, but we only keep the
/// options that are actually used in our Dart implementation.
abstract class ServiceOptions {
  /// The authenticated HTTP client. If not provided, will be required
  /// unless using a custom endpoint without auth.
  final FutureOr<auth_io.AuthClient>? authClient;

  /// Whether to use authentication with custom endpoints.
  /// Defaults to false (no auth) for custom endpoints/emulators.
  final bool? useAuthWithCustomEndpoint;

  /// The universe domain (e.g., 'googleapis.com').
  /// Used to construct the default API endpoint.
  final String? universeDomain;

  final String? projectId;

  const ServiceOptions({
    this.authClient,
    this.useAuthWithCustomEndpoint,
    this.universeDomain,
    this.projectId,
  });
}

class ServiceConfig {
  final String apiEndpoint;
  final bool? customEndpoint;
  final bool? useAuthWithCustomEndpoint;

  const ServiceConfig({
    required this.apiEndpoint,
    this.customEndpoint,
    this.useAuthWithCustomEndpoint,
  });
}

/// Base service class, roughly analogous to the Node `Service` type.
abstract class Service<T extends ServiceOptions> {
  final ServiceConfig config;
  final T options;

  /// The Storage API client from googleapis package.
  /// This handles all the low-level API calls to Google Cloud Storage.
  storage_v1.StorageApi? _storageClient;
  auth_io.AuthClient? _authClient;

  Future<storage_v1.StorageApi> get storageClient async {
    return _storageClient ??= await _createStorageClient();
  }

  /// Get or create the authenticated client.
  ///
  /// This is always created, even for custom endpoints without auth,
  /// because it's needed for projectId resolution (similar to Node.js SDK).
  /// The authClient is created lazily on first access.
  ///
  /// Priority:
  /// 1. Explicit authClient in options (advanced use)
  /// 2. Credentials/keyFilename in StorageOptions → GoogleCredential → AuthClient
  /// 3. Application Default Credentials (ADC)
  Future<auth_io.AuthClient> get authClient async {
    if (_authClient != null) {
      return _authClient!;
    }

    // Priority 1: Explicit authClient (for advanced use cases)
    if (options.authClient != null) {
      return _authClient = await options.authClient!;
    }

    // Priority 2: If StorageOptions with credentials/keyFilename, use GoogleCredential
    GoogleCredential? googleCredential;
    if (options is StorageOptions) {
      final storageOpts = options as StorageOptions;
      if (storageOpts.credentials != null || storageOpts.keyFilename != null) {
        googleCredential = storageOpts.extractCredential();
      }
    }

    // Priority 3: Use createAuthClient (with GoogleCredential or ADC if null)
    // Using the same scopes as Node.js SDK (storage.ts lines 778-782)
    return _authClient = await createAuthClient(
      googleCredential, // null = ADC
      [
        'https://www.googleapis.com/auth/iam',
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/devstorage.full_control',
      ],
    );
  }

  Future<storage_v1.StorageApi> _createStorageClient() async {
    // Calculate rootUrl from apiEndpoint
    // StorageApi expects rootUrl to be the base URL (e.g., 'https://storage.googleapis.com/')
    // The servicePath ('storage/v1/') is handled internally by StorageApi
    var rootUrl = config.apiEndpoint;

    // Ensure rootUrl ends with a slash (required by StorageApi)
    if (!rootUrl.endsWith('/')) {
      rootUrl = '$rootUrl/';
    }

    final servicePath = 'storage/v1/';

    // Handle authentication based on custom endpoint settings
    // This matches the node SDK's behavior in util.ts:makeAuthenticatedRequestFactory
    // where it checks: if (reqConfig.customEndpoint && !reqConfig.useAuthWithCustomEndpoint)
    // then it bypasses authentication for API requests
    //
    // Note: We still create the authClient (above) even for custom endpoints
    // because it's needed for projectId resolution, but we use a plain client
    // for the actual API requests when auth is disabled.
    if (config.customEndpoint == true &&
        config.useAuthWithCustomEndpoint != true) {
      // For custom endpoints without auth (e.g., emulators), use a plain HTTP client
      // This matches node SDK's behavior of using gaxios (plain HTTP client) instead
      // of the authenticated client for requests
      //
      // However, we still ensure authClient is available (via lazy getter above)
      // for projectId resolution, even though we don't use it for requests here
      final plainClient = http.Client();
      return storage_v1.StorageApi(
        plainClient,
        rootUrl: rootUrl,
        servicePath: servicePath,
      );
    }

    // For normal endpoints or custom endpoints with auth, use the authenticated client
    // Ensure authClient is created (this will auto-create from ADC if needed)
    return storage_v1.StorageApi(
      await authClient,
      rootUrl: rootUrl,
      servicePath: servicePath,
    );
  }

  Service(this.config, this.options);

  // final String apiEndpoint;
  // final String? projectId;
  // final http.Client httpClient;
  // final AuthClient authClient;
  // final storage_v1.StorageApi storageApi;
  // final RetryOptions retryOptions;
  // final Duration? timeout;
  // final String? userAgent;
  // final List<RequestInterceptor> _globalInterceptors;

  // /// Per-instance interceptors that can be added by resources.
  // final List<RequestInterceptor> interceptors = [];

  // Service({
  //   required this.apiEndpoint,
  //   required this.httpClient,
  //   required this.authClient,
  //   required this.storageApi,
  //   this.projectId,
  //   this.retryOptions = const RetryOptions(),
  //   this.timeout,
  //   this.userAgent,
  //   List<RequestInterceptor>? interceptors,
  // }) : _globalInterceptors = List.unmodifiable(interceptors ?? const []);

  // /// Hook for subclasses to customize headers.
  // @protected
  // Map<String, String> buildHeaders([Map<String, String>? extra]) {
  //   final headers = <String, String>{
  //     HttpHeaders.userAgentHeader:
  //         userAgent ?? 'googleapis_storage/0.1.0 (dart)',
  //     'x-goog-api-client': 'gl-dart/3 gccl/0.1.0',
  //   };
  //   if (extra != null) {
  //     headers.addAll(extra);
  //   }
  //   return headers;
  // }

  // /// Execute a JSON-oriented HTTP request with retry.
  // Future<http.Response> sendJson(
  //   http.BaseRequest request, {
  //   RetryOptions? retry,
  // }) async {
  //   final executor = RetryExecutor();
  //   final options = retry ?? retryOptions;

  //   // Apply interceptors.
  //   for (final interceptor in _globalInterceptors) {
  //     request = interceptor(request);
  //   }
  //   for (final interceptor in interceptors) {
  //     request = interceptor(request);
  //   }

  //   // Apply default headers if not already present.
  //   request.headers.addAll(buildHeaders(request.headers));

  //   Future<http.Response> op() async {
  //     final streamed = await httpClient
  //         .send(request)
  //         .timeout(timeout ?? const Duration(days: 365));
  //     final response = await http.Response.fromStream(streamed);
  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       return response;
  //     }
  //     throw ApiError(
  //       'Request failed with status ${response.statusCode}',
  //       code: response.statusCode,
  //       details: response.body,
  //     );
  //   }

  //   return api.execute<http.Response>(
  //     op,
  //     options,
  //     classify: (error) =>
  //         options.retryableErrorFn?.call(error) ??
  //         defaultShouldRetryError(error),
  //   );
  // }

  // /// Execute a streaming HTTP request without JSON decoding.
  // Future<http.StreamedResponse> sendStream(
  //   http.BaseRequest request, {
  //   RetryOptions? retry,
  // }) async {
  //   final executor = RetryExecutor();
  //   final options = retry ?? retryOptions;

  //   for (final interceptor in _globalInterceptors) {
  //     request = interceptor(request);
  //   }
  //   for (final interceptor in interceptors) {
  //     request = interceptor(request);
  //   }

  //   request.headers.addAll(buildHeaders(request.headers));

  //   Future<http.StreamedResponse> op() async {
  //     final response = await httpClient
  //         .send(request)
  //         .timeout(timeout ?? const Duration(days: 365));
  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       return response;
  //     }
  //     final body = await http.Response.fromStream(response);
  //     throw ApiError(
  //       'Request failed with status ${response.statusCode}',
  //       code: response.statusCode,
  //       details: body.body,
  //     );
  //   }

  //   return api.execute<http.StreamedResponse>(
  //     op,
  //     options,
  //     classify: (error) =>
  //         options.retryableErrorFn?.call(error) ??
  //         defaultShouldRetryError(error),
  //   );
  // }
}
