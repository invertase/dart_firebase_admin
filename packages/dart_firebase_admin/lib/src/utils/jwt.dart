import 'dart:convert';

import 'package:http/http.dart' as http;

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

Future<void> verifyJwtSignature(
  String token,
  SecretOrPublicKey secretOrPublicKey, [
  // TODO what about options?
  Object? options,
]) {
  throw UnimplementedError();
}
