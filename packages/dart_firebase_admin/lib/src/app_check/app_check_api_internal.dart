import 'package:googleapis/firebaseappcheck/v1.dart' as appcheck1;
import 'package:googleapis_beta/firebaseappcheck/v1beta.dart' as appcheck1_beta;
import 'package:meta/meta.dart';

import '../app.dart';
import '../utils/project_id_provider.dart';
import '../utils/crypto_signer.dart';
import '../utils/jwt.dart';
import 'app_check_api.dart';

/// Class that facilitates sending requests to the Firebase App Check backend API.
@internal
class AppCheckApiClient {
  AppCheckApiClient(this.app, [ProjectIdProvider? projectIdProvider])
      : _projectIdProvider = projectIdProvider ?? ProjectIdProvider(app);

  final FirebaseApp app;
  final ProjectIdProvider _projectIdProvider;

  Future<R> _v1<R>(
    Future<R> Function(appcheck1.FirebaseappcheckApi client, String projectId) fn,
  ) async {
    final projectId = await _projectIdProvider.discoverProjectId();
    return fn(appcheck1.FirebaseappcheckApi(await app.client), projectId);
  }

  Future<R> _v1Beta<R>(
    Future<R> Function(appcheck1_beta.FirebaseappcheckApi client, String projectId) fn,
  ) async {
    final projectId = await _projectIdProvider.discoverProjectId();
    return fn(appcheck1_beta.FirebaseappcheckApi(await app.client), projectId);
  }

  /// Exchange a signed custom token to App Check token
  ///
  /// [customToken] - The custom token to be exchanged.
  /// [appId] - The mobile App ID.
  ///
  /// Returns a future that fulfills with a [AppCheckToken].
  Future<AppCheckToken> exchangeToken(String customToken, String appId) {
    return _v1((client, projectId) async {
      final response = await client.projects.apps.exchangeCustomToken(
        appcheck1.GoogleFirebaseAppcheckV1ExchangeCustomTokenRequest(
          customToken: customToken,
        ),
        'projects/$projectId/apps/$appId',
      );

      return AppCheckToken(
        token: response.token!,
        ttlMillis: _stringToMilliseconds(response.ttl!),
      );
    });
  }

  Future<bool> verifyReplayProtection(String token) {
    return _v1Beta((client, projectId) async {
      final response = await client.projects.verifyAppCheckToken(
        appcheck1_beta.GoogleFirebaseAppcheckV1betaVerifyAppCheckTokenRequest(
          appCheckToken: token,
        ),
        'projects/$projectId',
      );

      return response.alreadyConsumed ?? false;
    });
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

final appCheckErrorCodeMapping = <String, AppCheckErrorCode>{
  'ABORTED': AppCheckErrorCode.aborted,
  'INVALID_ARGUMENT': AppCheckErrorCode.invalidArgument,
  'INVALID_CREDENTIAL': AppCheckErrorCode.invalidCredential,
  'INTERNAL': AppCheckErrorCode.internalError,
  'PERMISSION_DENIED': AppCheckErrorCode.permissionDenied,
  'UNAUTHENTICATED': AppCheckErrorCode.unauthenticated,
  'NOT_FOUND': AppCheckErrorCode.notFound,
  'UNKNOWN': AppCheckErrorCode.unknownError,
};

enum AppCheckErrorCode {
  aborted('aborted'),
  invalidArgument('invalid-argument'),
  invalidCredential('invalid-credential'),
  internalError('internal-error'),
  permissionDenied('permission-denied'),
  unauthenticated('unauthenticated'),
  notFound('not-found'),
  appCheckTokenExpired('app-check-token-expired'),
  unknownError('unknown-error');

  const AppCheckErrorCode(this.code);

  static AppCheckErrorCode from(String code) {
    switch (code) {
      case CryptoSignerErrorCode.invalidCredential:
        return AppCheckErrorCode.invalidCredential;
      case CryptoSignerErrorCode.invalidArgument:
        return AppCheckErrorCode.invalidArgument;
      default:
        return AppCheckErrorCode.internalError;
    }
  }

  final String code;
}

/// Firebase App Check error code structure. This extends PrefixedFirebaseError.
///
/// [code] - The error code.
/// [message] - The error message.
class FirebaseAppCheckException extends FirebaseAdminException {
  FirebaseAppCheckException(AppCheckErrorCode code, [String? _message])
      : super('app-check', code.code, _message);

  factory FirebaseAppCheckException.fromJwtException(JwtException error) {
    if (error.code == JwtErrorCode.tokenExpired) {
      const errorMessage =
          'The provided App Check token has expired. Get a fresh App Check token'
          ' from your client app and try again.';
      return FirebaseAppCheckException(
        AppCheckErrorCode.appCheckTokenExpired,
        errorMessage,
      );
    } else if (error.code == JwtErrorCode.invalidSignature) {
      const errorMessage =
          'The provided App Check token has invalid signature.';
      return FirebaseAppCheckException(
        AppCheckErrorCode.invalidArgument,
        errorMessage,
      );
    } else if (error.code == JwtErrorCode.noMatchingKid) {
      const errorMessage =
          'The provided App Check token has "kid" claim which does not '
          'correspond to a known public key. Most likely the provided App Check token '
          'is expired, so get a fresh token from your client app and try again.';
      return FirebaseAppCheckException(
        AppCheckErrorCode.invalidArgument,
        errorMessage,
      );
    }
    return FirebaseAppCheckException(
      AppCheckErrorCode.invalidArgument,
      error.message,
    );
  }
}
