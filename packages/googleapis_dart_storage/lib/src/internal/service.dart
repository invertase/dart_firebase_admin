import 'package:http/http.dart' as http;
import 'package:googleapis/storage/v1.dart' as storage_v1;

typedef RequestInterceptor = http.BaseRequest Function(http.BaseRequest);

/// Base options class for service configuration.
///
/// In the node SDK, this extends GoogleAuthOptions, but we only keep the
/// options that are actually used in our Dart implementation.
abstract class ServiceOptions {
  /// The authenticated HTTP client. If not provided, will be required
  /// unless using a custom endpoint without auth.
  final Future<http.Client>? authClient;

  /// Whether to use authentication with custom endpoints.
  /// Defaults to false (no auth) for custom endpoints/emulators.
  final bool? useAuthWithCustomEndpoint;

  /// The universe domain (e.g., 'googleapis.com').
  /// Used to construct the default API endpoint.
  final String? universeDomain;

  final String projectId;

  const ServiceOptions({
    this.authClient,
    this.useAuthWithCustomEndpoint,
    this.universeDomain,
    this.projectId = '{{projectId}}',
  });
}

class ServiceConfig {
  final String apiEndpoint;
  final Future<http.Client>? authClient;
  final bool? customEndpoint;
  final bool? useAuthWithCustomEndpoint;

  const ServiceConfig({
    required this.apiEndpoint,
    this.authClient,
    this.customEndpoint,
    this.useAuthWithCustomEndpoint,
  });
}

/// Creates a StorageApi instance with proper configuration.
///
/// StorageApi from googleapis takes:
/// - `Client client`: The HTTP client (can be AuthClient or plain http.Client)
/// - `rootUrl`: The base URL (defaults to 'https://storage.googleapis.com/')
/// - `servicePath`: The service path (defaults to 'storage/v1/')
///
/// For custom endpoints/emulators, we pass the custom rootUrl.
/// The node SDK constructs URLs manually, but we use googleapis which handles
/// URL construction internally using rootUrl + servicePath.
///
/// Node SDK authentication behavior:
/// - If `customEndpoint` is true AND `useAuthWithCustomEndpoint` is NOT true,
///   it bypasses authentication (uses plain HTTP client like gaxios)
/// - Otherwise, it uses the authenticated client
///
/// Since StorageApi handles the servicePath internally, we just need to pass
/// the rootUrl (apiEndpoint with trailing slash).
Future<storage_v1.StorageApi> _createStorageApi(
  ServiceConfig config,
  ServiceOptions options,
) async {
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
  // then it bypasses authentication
  if (config.customEndpoint == true &&
      config.useAuthWithCustomEndpoint != true) {
    // For custom endpoints without auth (e.g., emulators), use a plain HTTP client
    // This matches node SDK's behavior of using gaxios (plain HTTP client) instead
    // of the authenticated client
    final plainClient = http.Client();
    return storage_v1.StorageApi(
      plainClient,
      rootUrl: rootUrl,
      servicePath: servicePath,
    );
  }

  // For normal endpoints or custom endpoints with auth, use the authenticated client
  final authClient = config.authClient ?? options.authClient;

  if (authClient == null) {
    throw ArgumentError(
      'AuthClient is required. Provide authClient in StorageOptions, '
      'or set useAuthWithCustomEndpoint: false for custom endpoints without auth.',
    );
  }

  // Create StorageApi with the auth client and custom rootUrl
  return storage_v1.StorageApi(
    await authClient,
    rootUrl: rootUrl,
    servicePath: servicePath,
  );
}

/// Base service class, roughly analogous to the Node `Service` type.
abstract class Service<T extends ServiceOptions> {
  final ServiceConfig config;
  final T options;

  /// The Storage API client from googleapis package.
  /// This handles all the low-level API calls to Google Cloud Storage.
  storage_v1.StorageApi? _client;

  Future<storage_v1.StorageApi> get client async {
    return _client ??= await _createStorageApi(config, options);
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
  //         userAgent ?? 'googleapis_dart_storage/0.1.0 (dart)',
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

  //   return executor.retry<http.Response>(
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

  //   return executor.retry<http.StreamedResponse>(
  //     op,
  //     options,
  //     classify: (error) =>
  //         options.retryableErrorFn?.call(error) ??
  //         defaultShouldRetryError(error),
  //   );
  // }
}
