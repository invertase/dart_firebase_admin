import 'dart:async';

import 'package:googleapis/firebaseappcheck/v1.dart' as appcheck1;
import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:googleapis_beta/firebaseappcheck/v1beta.dart' as appcheck1_beta;
import 'package:meta/meta.dart';

import '../app.dart';
import '../utils/crypto_signer.dart';
import '../utils/jwt.dart';
import 'app_check_api.dart';
import 'token_generator.dart';
import 'token_verifier.dart';

part 'app_check_exception.dart';
part 'app_check_http_client.dart';
part 'app_check_request_handler.dart';

class AppCheck implements FirebaseService {
  /// Creates or returns the cached AppCheck instance for the given app.
  factory AppCheck(FirebaseApp app) {
    return app.getOrInitService(FirebaseServiceType.appCheck.name, AppCheck._);
  }

  AppCheck._(this.app, {@internal AppCheckRequestHandler? requestHandler})
    : _requestHandler = requestHandler ?? AppCheckRequestHandler(app);

  @override
  final FirebaseApp app;
  final AppCheckRequestHandler _requestHandler;
  late final _tokenGenerator = AppCheckTokenGenerator(
    CryptoSigner.fromApp(app),
  );
  late final _appCheckTokenVerifier = AppCheckTokenVerifier(app);

  /// Creates a new [AppCheckToken] that can be sent
  /// back to a client.
  ///
  /// [appId] - The app ID to use as the JWT app_id.
  /// [options] - Optional options object when creating a new App Check Token.
  ///
  /// Returns a future that fulfills with a [AppCheckToken].
  Future<AppCheckToken> createToken(
    String appId, [
    AppCheckTokenOptions? options,
  ]) async {
    final customToken = await _tokenGenerator.createCustomToken(appId, options);

    return _requestHandler.exchangeToken(customToken, appId);
  }

  /// Verifies a Firebase App Check token (JWT). If the token is valid, the promise is
  /// fulfilled with the token's decoded claims; otherwise, the promise is
  /// rejected.
  ///
  /// @param appCheckToken - The App Check token to verify.
  /// @param options - Optional {@link VerifyAppCheckTokenOptions} object when verifying an App Check Token.
  ///
  /// @returns A promise fulfilled with the token's decoded claims
  ///   if the App Check token is valid; otherwise, a rejected promise.
  Future<VerifyAppCheckTokenResponse> verifyToken(
    String appCheckToken, [
    VerifyAppCheckTokenOptions? options,
  ]) async {
    final decodedToken = await _appCheckTokenVerifier.verifyToken(
      appCheckToken,
    );

    if (options?.consume ?? false) {
      final alreadyConsumed = await _requestHandler.verifyReplayProtection(
        appCheckToken,
      );
      return VerifyAppCheckTokenResponse(
        alreadyConsumed: alreadyConsumed,
        appId: decodedToken.appId,
        token: decodedToken,
      );
    }

    return VerifyAppCheckTokenResponse(
      alreadyConsumed: null,
      appId: decodedToken.appId,
      token: decodedToken,
    );
  }

  @override
  Future<void> delete() async {
    // AppCheck service cleanup if needed
  }
}
