import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// Class for verifying unsigned (emulator) JWTs.
class EmulatorSignatureVerifier implements SignatureVerifier {
  @override
  Future<void> verify(String token) async {
    // Signature checks skipped for emulator; no need to fetch public keys.
    try {
      return await verifyJwtSignature(
        token,
        SecretKey(''),
      );
    } on JWTInvalidException catch (e) {
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

class PublicKeySignatureVerifier implements SignatureVerifier {
  PublicKeySignatureVerifier(this.keyFetcher);

  PublicKeySignatureVerifier.withCertificateUrl(Uri clientCert)
      : this(UrlKeyFetcher(clientCert));

  final KeyFetcher keyFetcher;

  @override
  Future<bool> verify(String token) {
    throw UnimplementedError();
    // verifyJwtSignature(token);
  }
}

sealed class SecretOrPublicKey {}

@internal
Future<void> verifyJwtSignature(
  String token,
  JWTKey key, {
  Duration? issueAt,
  Audience? audience,
  String? subject,
  String? issuer,
  String? jwtId,
}) async {
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
      JwtError(
        JwtErrorCode.tokenExpired,
        'The provided token has expired. Get a fresh token from your '
        'client app and try again.',
      ),
      stackTrace,
    );
  } catch (e, stackTrace) {
    Error.throwWithStackTrace(
      JwtError(
        JwtErrorCode.invalidSignature,
        'Error while verifying signature of Firebase ID token: $e',
      ),
      stackTrace,
    );
  }
}

/// Jwt error code structure.
class JwtError extends Error {
  JwtError(this.code, this.message);

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
  keyFetchError('key-fetch-error');

  const JwtErrorCode(this.value);

  final String value;
}
