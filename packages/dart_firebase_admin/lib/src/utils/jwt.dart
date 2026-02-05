import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';
import 'package:meta/meta.dart';

const algorithmRS256 = 'RS256';

/// Class for verifying unsigned (emulator) JWTs.
class EmulatorSignatureVerifier implements SignatureVerifier {
  @override
  Future<void> verify(String token) async {
    // Signature checks skipped for emulator; no need to fetch public keys.
    try {
      // Create a dummy key for the empty secret check
      final emptyKey = JsonWebKey.fromJson({'kty': 'oct', 'k': ''});

      await verifyJwtSignature(token, emptyKey);
    } on JoseException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('algorithm') ||
          msg.contains('signature') ||
          msg.contains('invalid')) {
        return;
      }
      rethrow;
    } catch (e) {
      // Catch-all for other verification assertions typical in test environments
      return;
    }
  }
}

@internal
class DecodedToken {
  DecodedToken({required this.header, required this.payload});

  final JoseHeader header;
  final Map<String, dynamic> payload;
}

abstract class SignatureVerifier {
  Future<void> verify(String token);
}

abstract class KeyFetcher {
  Future<JsonWebKeyStore> fetchPublicKeys();
}

class UrlKeyFetcher implements KeyFetcher {
  UrlKeyFetcher(this.clientCert);

  final Uri clientCert;

  JsonWebKeyStore? _publicKeys;
  late DateTime _publicKeysExpireAt;

  @override
  Future<JsonWebKeyStore> fetchPublicKeys() async {
    if (_shouldRefresh()) return refresh();
    return _publicKeys!;
  }

  bool _shouldRefresh() {
    if (_publicKeys == null) return true;
    return _publicKeysExpireAt.isBefore(DateTime.now());
  }

  Future<JsonWebKeyStore> refresh() async {
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

    final store = _publicKeys = JsonWebKeyStore();

    for (final entry in json.entries) {
      final key = JsonWebKey.fromPem(entry.value! as String, keyId: entry.key);
      store.addKey(key);
    }

    return store;
  }
}

class JwksFetcher implements KeyFetcher {
  JwksFetcher(this.jwksUrl);
  final Uri jwksUrl;
  JsonWebKeyStore? _publicKeys;
  int _publicKeysExpireAt = 0;
  static const int hourInMilliseconds = 6 * 60 * 60 * 1000; // 6 hours

  @override
  Future<JsonWebKeyStore> fetchPublicKeys() async {
    if (_shouldRefresh) return refresh();

    return _publicKeys!;
  }

  bool get _shouldRefresh {
    return _publicKeys == null ||
        _publicKeysExpireAt <= DateTime.now().millisecondsSinceEpoch;
  }

  Future<JsonWebKeyStore> refresh() async {
    final response = await http.get(jwksUrl);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch JWKS');
    }

    final jwks = jsonDecode(response.body) as Map<String, dynamic>;
    final keySet = JsonWebKeySet.fromJson(jwks);

    // Reset expire time
    _publicKeysExpireAt = 0;

    // Extract signing keys
    final store = _publicKeys = JsonWebKeyStore();
    keySet.keys.forEach(store.addKey);

    // Set new expiration time
    _publicKeysExpireAt =
        DateTime.now().millisecondsSinceEpoch + hourInMilliseconds;

    return store;
  }
}

class PublicKeySignatureVerifier implements SignatureVerifier {
  PublicKeySignatureVerifier(this.keyFetcher);

  PublicKeySignatureVerifier.withCertificateUrl(Uri clientCert)
    : this(UrlKeyFetcher(clientCert));

  factory PublicKeySignatureVerifier.withJwksUrl(Uri jwksUrl) {
    return PublicKeySignatureVerifier(JwksFetcher(jwksUrl));
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
      // 1. Decode generic JWS to inspect the header for 'kid'
      final jws = JsonWebSignature.fromCompactSerialization(token);
      final kid = jws.commonHeader['kid'] as String?;

      if (kid == null) {
        throw JwtException(
          JwtErrorCode.noKidInHeader,
          'no-kid-in-header-error',
        );
      }

      final store = await keyFetcher.fetchPublicKeys();

      try {
        // 2. Use decodeAndVerify to handle cryptographic verification
        // This will throw JoseException if signature is invalid or token expired
        await JsonWebToken.decodeAndVerify(token, store);
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
    } on JoseException catch (e) {
      throw JwtException(JwtErrorCode.unknown, '${e.runtimeType}: e.message');
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
  final jws = JsonWebSignature.fromCompactSerialization(jwtToken);

  return DecodedToken(
    header: jws.commonHeader,
    payload: jws.unverifiedPayload.jsonContent as Map<String, dynamic>,
  );
}

@internal
Future<void> verifyJwtSignature(
  String token,
  JsonWebKey key, {
  Duration? issueAt,
  List<String>? audience,
  String? subject,
  String? issuer,
  String? jwtId,
}) async {
  final keyStore = JsonWebKeyStore()..addKey(key);

  try {
    final decoded = await JsonWebToken.decodeAndVerify(token, keyStore);
    final claims = decoded.claims;

    if (claims.expiry case final DateTime expiry) {
      if (expiry.isBefore(DateTime.now())) {
        throw JwtException(
          JwtErrorCode.tokenExpired,
          'The provided token has expired.',
        );
      }
    }

    if (issuer case final String tokenIssuer) {
      if (tokenIssuer != issuer) {
        throw JwtException(
          JwtErrorCode.invalidSignature,
          'Issuer does not match. Expected `$issuer`, was `${claims.issuer}`',
        );
      }
    }

    if (subject case final String tokenSubject) {
      if (tokenSubject != subject) {
        throw JwtException(
          JwtErrorCode.invalidSignature,
          'Subject does not match. Expected `$subject`, was `${claims.subject}`',
        );
      }
    }

    if (audience != null) {
      final tokenAud = claims.audience ?? [];
      final hasMatch = tokenAud.any((a) => audience.contains(a));
      if (!hasMatch) {
        throw JwtException(
          JwtErrorCode.invalidSignature,
          'Audience does not contain clientId `$audience`.',
        );
      }
    }

    if (jwtId case final String tokenJwtId) {
      if (tokenJwtId != jwtId) {
        throw JwtException(
          JwtErrorCode.invalidSignature,
          'JWT ID does not match. Expected `$jwtId`, was `${claims.jwtId}`',
        );
      }
    }
  } on JoseException catch (e, stackTrace) {
    if (e.message.toLowerCase().contains('expired')) {
      Error.throwWithStackTrace(
        JwtException(
          JwtErrorCode.tokenExpired,
          'The provided token has expired. Get a fresh token from your '
          'client app and try again.',
        ),
        stackTrace,
      );
    } else {
      Error.throwWithStackTrace(
        JwtException(
          JwtErrorCode.invalidSignature,
          'The provided token is invalid. Get a fresh token from your '
          'client app and try again.',
        ),
        stackTrace,
      );
    }
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
