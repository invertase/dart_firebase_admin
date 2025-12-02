part of 'app_check.dart';

/// Request handler for Firebase App Check API operations.
///
/// Handles complex business logic, request/response transformations,
/// and validation. Delegates simple API calls to [AppCheckHttpClient].
@internal
class AppCheckRequestHandler {
  AppCheckRequestHandler(FirebaseApp app)
    : _httpClient = AppCheckHttpClient(app);

  final AppCheckHttpClient _httpClient;

  /// Exchange a signed custom token to App Check token.
  ///
  /// Delegates to HTTP client for the API call, then transforms
  /// the response by converting TTL from duration string to milliseconds.
  ///
  /// [customToken] - The custom token to be exchanged.
  /// [appId] - The mobile App ID.
  ///
  /// Returns a future that fulfills with a [AppCheckToken].
  Future<AppCheckToken> exchangeToken(String customToken, String appId) async {
    final response = await _httpClient.exchangeCustomToken(customToken, appId);

    return AppCheckToken(
      token: response.token!,
      ttlMillis: _stringToMilliseconds(response.ttl!),
    );
  }

  /// Verify an App Check token with replay protection.
  ///
  /// Delegates to HTTP client for the API call, then transforms
  /// the response by extracting the alreadyConsumed field.
  ///
  /// [token] - The App Check token to verify.
  ///
  /// Returns true if token was already consumed, false otherwise.
  Future<bool> verifyReplayProtection(String token) async {
    final response = await _httpClient.verifyAppCheckToken(token);

    return response.alreadyConsumed ?? false;
  }

  /// Converts a duration string with the suffix `s` to milliseconds.
  ///
  /// [duration] - The duration as a string with the suffix "s" preceded by the
  /// number of seconds, with fractional seconds. For example, 3 seconds with 0 nanoseconds
  /// is expressed as "3s", while 3 seconds and 1 nanosecond is expressed as "3.000000001s",
  /// and 3 seconds and 1 microsecond is expressed as "3.000001s".
  ///
  /// Returns the duration in milliseconds.
  int _stringToMilliseconds(String duration) {
    if (duration.isEmpty || !duration.endsWith('s')) {
      throw FirebaseAppCheckException(
        AppCheckErrorCode.invalidArgument,
        '`ttl` must be a valid duration string with the suffix `s`.',
      );
    }

    final seconds = duration.substring(0, duration.length - 1);
    return (double.parse(seconds) * 1000).floor();
  }
}
