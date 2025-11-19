import 'package:meta/meta.dart';

import '../app.dart';
import '../utils/base_http_client.dart';
import '../utils/jwt.dart';
import 'app_check_api.dart';
import 'app_check_api_internal.dart';

const appCheckIssuer = 'https://firebaseappcheck.googleapis.com/';
const jwksUrl = 'https://firebaseappcheck.googleapis.com/v1/jwks';

/// Class for verifying Firebase App Check tokens.
///
@internal
class AppCheckTokenVerifier {
  AppCheckTokenVerifier(this.app, this._httpClient);

  final FirebaseApp app;
  final BaseHttpClient _httpClient;
  final _signatureVerifier =
      PublicKeySignatureVerifier.withJwksUrl(Uri.parse(jwksUrl));

  Future<DecodedAppCheckToken> verifyToken(String token) async {
    final projectId = await _httpClient.discoverProjectId();
    final decoded = await _decodeAndVerify(token, projectId);

    return DecodedAppCheckToken.fromMap(decoded.payload);
  }

  Future<DecodedToken> _decodeAndVerify(String token, String projectId) async {
    final decodedToken = await _safeDecode(token);

    _verifyContent(decodedToken, projectId);
    await _verifySignature(token);
    return decodedToken;
  }

  Future<DecodedToken> _safeDecode(String jwtToken) async {
    try {
      return await decodeJwt(jwtToken);
    } catch (err) {
      const errorMessage =
          'Decoding App Check token failed. Make sure you passed '
          'the entire string JWT which represents the Firebase App Check token.';
      throw FirebaseAppCheckException(
        AppCheckErrorCode.invalidArgument,
        errorMessage,
      );
    }
  }

  /// Verifies the content of a Firebase App Check JWT.
  ///
  /// [fullDecodedToken] - The decoded JWT.
  /// [projectId] - The Firebase Project Id.
  void _verifyContent(DecodedToken fullDecodedToken, String? projectId) {
    final header = fullDecodedToken.header;
    final payload = fullDecodedToken.payload;

    const projectIdMatchMessage =
        ' Make sure the App Check token comes from the same '
        'Firebase project as the service account used to authenticate this SDK.';
    final scopedProjectId = 'projects/$projectId';

    String? errorMessage;
    if (header['alg'] case final alg && != algorithmRS256) {
      errorMessage =
          'The provided App Check token has incorrect algorithm. Expected "$algorithmRS256" but got "$alg".';
    } else if (payload['aud'] case final List<Object?> aud
        when !aud.contains(scopedProjectId)) {
      errorMessage =
          'The provided App Check token has incorrect "aud" (audience) claim. Expected "$scopedProjectId" but got "$aud".$projectIdMatchMessage';
    } else if (payload['iss'] case final iss
        when iss is! String || !iss.startsWith(appCheckIssuer)) {
      errorMessage =
          'The provided App Check token has incorrect "iss" (issuer) claim.';
    } else if (payload['sub'] case final sub when sub is! String) {
      errorMessage =
          'The provided App Check token has no "sub" (subject) claim.';
    } else if (payload['sub'] == '') {
      errorMessage =
          'The provided App Check token has an empty string "sub" (subject) claim.';
    }

    if (errorMessage != null) {
      throw FirebaseAppCheckException(
        AppCheckErrorCode.invalidArgument,
        errorMessage,
      );
    }
  }

  Future<void> _verifySignature(String jwtToken) async {
    try {
      await _signatureVerifier.verify(jwtToken);
    } on JwtException catch (error, stack) {
      Error.throwWithStackTrace(
        FirebaseAppCheckException.fromJwtException(error),
        stack,
      );
    }
  }
}
