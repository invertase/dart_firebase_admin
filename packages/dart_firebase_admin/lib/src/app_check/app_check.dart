import '../app.dart';
import '../utils/crypto_signer.dart';
import 'app_check_api.dart';
import 'app_check_api_internal.dart';
import 'token_generator.dart';
import 'token_verifier.dart';

class AppCheck implements FirebaseService {
  /// Creates or returns the cached AppCheck instance for the given app.
  factory AppCheck(FirebaseApp app) {
    return app.getOrInitService(
      'app-check',
      AppCheck._,
    ) as AppCheck;
  }

  AppCheck._(this.app);

  @override
  final FirebaseApp app;
  late final _tokenGenerator =
      AppCheckTokenGenerator(CryptoSigner.fromApp(app));
  late final _client = AppCheckApiClient(app);
  late final _appCheckTokenVerifier = AppCheckTokenVerifier(app, _client);

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

    return _client.exchangeToken(customToken, appId);
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
    final decodedToken =
        await _appCheckTokenVerifier.verifyToken(appCheckToken);

    if (options?.consume ?? false) {
      final alreadyConsumed =
          await _client.verifyReplayProtection(appCheckToken);
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
