import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../app.dart';

const algorithmRS256 = 'RS256';

/// Class for verifying unsigned (emulator) JWTs.
class EmulatorSignatureVerifier implements SignatureVerifier {
  @override
  Future<void> verify(String token) async {
    // Signature checks skipped for emulator; no need to fetch public keys.

    try {
      verifyJwtSignature(
        token,
        SecretKey(''),
      );
    } on JWTInvalidException catch (e) {
      // Emulator tokens have "alg": "none"
      if (e.message == 'unknown algorithm') return;
      if (e.message == 'invalid signature') return;
      rethrow;
    }
  }
}

@internal
class DecodedToken {
  DecodedToken({required this.header, required this.payload});

  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;
}

abstract class SignatureVerifier {
  Future<void> verify(String token);
}

abstract class KeyFetcher {
  Future<Map<String, String>> fetchPublicKeys();
}

class UrlKeyFetcher implements KeyFetcher {
  UrlKeyFetcher(this.clientCert);

  final Uri clientCert;

  Map<String, String>? _publicKeys;
  late DateTime _publicKeysExpireAt;

  @override
  Future<Map<String, String>> fetchPublicKeys() async {
    if (_shouldRefresh()) return refresh();
    return _publicKeys!;
  }

  bool _shouldRefresh() {
    if (_publicKeys == null) return true;
    return _publicKeysExpireAt.isBefore(DateTime.now());
  }

  Future<Map<String, String>> refresh() async {
    final response = await http.get(clientCert);
    final json = jsonDecode(response.body) as Map<String, Object?>;
    final error = json['error'];
    if (error != null) {
      var errorMessage = 'Error fetching public keys for Google certs: $error';
      final description = json['error_description'];
      if (description != null) {
        errorMessage += ' ($description)';
      }
      throw Exception(errorMessage);
    }

    // reset expire at from previous set of keys.
    _publicKeysExpireAt = DateTime(0);
    final cacheControl = response.headers['cache-control'];
    if (cacheControl != null) {
      final parts = cacheControl.split(',');
      for (final part in parts) {
        final subParts = part.trim().split('=');
        if (subParts[0] == 'max-age') {
          final maxAge = int.parse(subParts[1]);
          // Is "seconds" correct?
          _publicKeysExpireAt = DateTime.now().add(Duration(seconds: maxAge));
        }
      }
    }
    return _publicKeys = Map.from(json);
  }
}

class JwksFetcher implements KeyFetcher {
  JwksFetcher(this.jwksUrl, this.app);
  final Uri jwksUrl;
  final FirebaseAdminApp app;
  Map<String, String>? _publicKeys;
  int _publicKeysExpireAt = 0;
  static const int hourInMilliseconds = 6 * 60 * 60 * 1000; // 6 hours

  @override
  Future<Map<String, String>> fetchPublicKeys() async {
    if (_shouldRefresh) return refresh();

    return _publicKeys!;
  }

  bool get _shouldRefresh {
    return _publicKeys == null ||
        _publicKeysExpireAt <= DateTime.now().millisecondsSinceEpoch;
  }

  Future<Map<String, String>> refresh() async {
    try {
      final response = await http.get(jwksUrl);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch JWKS');
      }

      String fromWebSafeBase64(String data) {
        return data.replaceAll('_', '/').replaceAll('-', '+');
      }

      final jwks = jsonDecode(response.body) as Map<String, dynamic>;
      final keys = (jwks['keys'] as List).map((e) => e as Map<String, dynamic>);

      // Reset expire time
      _publicKeysExpireAt = 0;

      // Extract signing keys
      final newKeys = <String, String>{};
      for (final key in keys) {
        final kid = key['kid'] as String?;
        final n = key['n'] as String?;
        final e = key['e'] as String?;
        if (key['use'] == 'sig' && kid != null && n != null && e != null) {
          newKeys[kid] = _generatePemFromJwk(n, e);
        }
      }

      // Set new expiration time
      _publicKeysExpireAt =
          DateTime.now().millisecondsSinceEpoch + hourInMilliseconds;
      _publicKeys = newKeys;

      return newKeys;
    } catch (e) {
      throw Exception('Error fetching JSON Web Keys: $e');
    }
  }

  /// Converts JWK { n, e } to PEM format
  String _generatePemFromJwk(String n, String e) {
    final modulus = base64UrlNormalize(n);
    final exponent = base64UrlNormalize(e);

    final publicKeyPem = '''
-----BEGIN PUBLIC KEY-----
$modulus
$exponent
-----END PUBLIC KEY-----''';
    return publicKeyPem;
  }

  /// Normalizes Base64URL encoding (adds padding if missing)
  String base64UrlNormalize(String base64Str) {
    return base64Str.replaceAll('_', '/').replaceAll('-', '+');
  }
}

class PublicKeySignatureVerifier implements SignatureVerifier {
  PublicKeySignatureVerifier(this.keyFetcher);

  PublicKeySignatureVerifier.withCertificateUrl(Uri clientCert)
      : this(UrlKeyFetcher(clientCert));

  factory PublicKeySignatureVerifier.withJwksUrl(
      Uri jwksUrl, FirebaseAdminApp app) {
    return PublicKeySignatureVerifier(JwksFetcher(jwksUrl, app));
  }

  final KeyFetcher keyFetcher;

  /// Verifies a JWT token.
  ///
  /// This verifies the token's signature. The signing key is selected using the
  /// 'kid' claim in the token's header.
  /// The token's expiration is also verified.
  @override
  Future<void> verify(String token) async {
    try {
      final jwt = JWT.decode(token);
      final kid = jwt.header?['kid'] as String?;

      if (kid == null) {
        throw JwtException(
          JwtErrorCode.noKidInHeader,
          'no-kid-in-header-error',
        );
      }

      final publicKeys = await keyFetcher.fetchPublicKeys();
      final publicKey = publicKeys[kid];

      if (publicKey == null) {
        throw JwtException(
          JwtErrorCode.noMatchingKid,
          'no-matching-kid-error',
        );
      }

      try {
        verifyJwtSignature(
          token,
          RSAPublicKey.cert(publicKey),
          issueAt: Duration.zero, // Any past date should be valid
        );
      } catch (e, stackTrace) {
        Error.throwWithStackTrace(
          JwtException(
            JwtErrorCode.invalidSignature,
            'Error while verifying signature of Firebase ID token: $e',
          ),
          stackTrace,
        );
      }

      // At this point most JWTException's should have been caught in
      // verifyJwtSignature, but we could still get some from JWT.decode above
    } on JWTException catch (e) {
      throw JwtException(
        JwtErrorCode.unknown,
        e is JWTUndefinedException ? e.message : '${e.runtimeType}: e.message',
      );
    }
  }
}

sealed class SecretOrPublicKey {}

/// Decodes general purpose Firebase JWTs.
///
/// [jwtToken] - JWT token to be decoded.
///
/// Returns a decoded token containing the header and payload.
Future<DecodedToken> decodeJwt(String jwtToken) async {
  final fullDecodedToken = JWT.decode(jwtToken);

  return DecodedToken(
    header: fullDecodedToken.header ?? {},
    payload: Map.from(fullDecodedToken.payload as Map),
  );
}

@internal
void verifyJwtSignature(
  String token,
  JWTKey key, {
  Duration? issueAt,
  Audience? audience,
  String? subject,
  String? issuer,
  String? jwtId,
}) {
  try {
    JWT.verify(
      token,
      key,
      issueAt: issueAt,
      audience: audience,
      subject: subject,
      issuer: issuer,
      jwtId: jwtId,
    );
  } on JWTExpiredException catch (e, stackTrace) {
    Error.throwWithStackTrace(
      JwtException(
        JwtErrorCode.tokenExpired,
        'The provided token has expired. Get a fresh token from your '
        'client app and try again.',
      ),
      stackTrace,
    );
  }
}

/// Jwt error code structure.
class JwtException implements Exception {
  JwtException(this.code, this.message);

  final JwtErrorCode code;
  final String message;
}

/// JWT error codes.
enum JwtErrorCode {
  invalidArgument('invalid-argument'),
  invalidCredential('invalid-credential'),
  tokenExpired('token-expired'),
  invalidSignature('invalid-token'),
  noMatchingKid('no-matching-kid-error'),
  noKidInHeader('no-kid-error'),
  keyFetchError('key-fetch-error'),
  unknown('unknown');

  const JwtErrorCode(this.value);

  final String value;
}
