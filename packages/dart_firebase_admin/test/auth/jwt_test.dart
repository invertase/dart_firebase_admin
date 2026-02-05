import 'dart:convert';

import 'package:dart_firebase_admin/src/utils/jwt.dart';
import 'package:jose/jose.dart';
import 'package:test/test.dart';

import '../mock_service_account.dart';

void main() {
  JsonWebKey createHmacKey(String secret) {
    return JsonWebKey.fromJson({
      'kty': 'oct',
      'k': base64Url.encode(utf8.encode(secret)),
    });
  }

  String signToken(
    Map<String, dynamic> payload,
    JsonWebKey key, {
    String alg = 'HS256',
    Map<String, dynamic>? header,
  }) {
    final builder = JsonWebSignatureBuilder()
      ..jsonContent = payload
      ..addRecipient(key, algorithm: alg);
    for (final element in header?.entries ?? <MapEntry<String, dynamic>>[]) {
      builder.setProtectedHeader(element.key, element.value);
    }
    return builder.build().toCompactSerialization();
  }

  group('PublicKeySignatureVerifier', () {
    final privateJwk = JsonWebKey.fromPem(mockPrivateKey, keyId: 'key1');
    final keyFetcher = _TestKeyFetcher();

    final payload = {
      'a': '1',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    test('valid kid should pass', () async {
      final token = signToken(
        payload,
        privateJwk,
        alg: 'RS256',
        header: {'kid': 'key1', 'typ': 'JWT'},
      );

      await PublicKeySignatureVerifier(keyFetcher).verify(token);
    });

    test('no kid should throw', () async {
      final noIdKey = JsonWebKey.fromPem(mockPrivateKey);

      final token = signToken(
        payload,
        noIdKey, // Use the key with no ID
        alg: 'RS256',
        header: {'typ': 'JWT'},
      );

      await expectLater(
        PublicKeySignatureVerifier(keyFetcher).verify(token),
        throwsA(
          isA<JwtException>().having(
            (e) => e.code,
            'code',
            JwtErrorCode.noKidInHeader,
          ),
        ),
      );
    });

    test('invalid kid should throw', () async {
      expect(
        () => signToken(
          payload,
          privateJwk,
          alg: 'RS256',
          header: {'kid': 'key2', 'typ': 'JWT'},
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('withCertificateUrl factory should create verifier', () {
      final verifier = PublicKeySignatureVerifier.withCertificateUrl(
        Uri.parse('https://example.com/certs'),
      );
      expect(verifier, isA<PublicKeySignatureVerifier>());
    });

    test('withJwksUrl factory should create verifier', () {
      final verifier = PublicKeySignatureVerifier.withJwksUrl(
        Uri.parse('https://example.com/jwks'),
      );
      expect(verifier, isA<PublicKeySignatureVerifier>());
    });
  });

  group('EmulatorSignatureVerifier', () {
    test('should verify emulator tokens without signature', () async {
      final verifier = EmulatorSignatureVerifier();
      final payload = {
        'user_id': '123',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp':
            DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      };

      // Manually construct a token with 'alg': 'none'
      // package:jose makes it hard to create insecure tokens by design.
      String base64NoPad(Map<String, dynamic> input) =>
          base64Url.encode(utf8.encode(jsonEncode(input))).replaceAll('=', '');

      final header = base64NoPad({'alg': 'none', 'typ': 'JWT'});
      final body = base64NoPad(payload);
      final token = '$header.$body.';

      await expectLater(verifier.verify(token), completes);
    });
  });

  group('decodeJwt', () {
    test('should decode valid JWT', () async {
      final key = createHmacKey('secret');
      final builder = JsonWebSignatureBuilder()
        ..jsonContent = {
          'sub': 'user123',
          'name': 'John Doe',
          'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        }
        ..addRecipient(key, algorithm: 'HS256')
        ..setProtectedHeader('typ', 'JWT');

      final jws = builder.build();
      final token = jws.toCompactSerialization();

      final decoded = JsonWebSignature.fromCompactSerialization(token);
      final header = decoded.commonHeader;
      final claims =
          decoded.unverifiedPayload.jsonContent as Map<String, dynamic>;

      expect(header['alg'], equals('HS256'));
      expect(header['typ'], equals('JWT'));
      expect(claims['sub'], equals('user123'));
      expect(claims['name'], equals('John Doe'));
    });

    test('should handle payload with various types', () async {
      final payload = {
        'string': 'value',
        'number': 42,
        'bool': true,
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
      };

      final key = createHmacKey('secret');
      final token = signToken(payload, key);

      final decoded = JsonWebToken.unverified(token);

      expect(decoded.claims['string'], equals('value'));
      expect(decoded.claims['number'], equals(42));
      expect(decoded.claims['bool'], equals(true));
      expect(decoded.claims['list'], equals([1, 2, 3]));
      expect(decoded.claims['map'], equals({'nested': 'value'}));
    });
  });

  group('verifyJwtSignature', () {
    test('should throw JwtException for expired tokens', () async {
      final payload = {
        'sub': 'user123',
        'exp':
            DateTime.now()
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
        'iat':
            DateTime.now()
                .subtract(const Duration(hours: 2))
                .millisecondsSinceEpoch ~/
            1000,
      };

      final secretKey = createHmacKey('secret');
      final token = signToken(payload, secretKey);

      await expectLater(
        () => verifyJwtSignature(token, secretKey),
        throwsA(
          isA<JwtException>().having(
            (e) => e.code,
            'code',
            JwtErrorCode.tokenExpired,
          ),
        ),
      );
    });

    test('should verify valid token with issuer', () async {
      final payload = {
        'sub': 'user123',
        'iss': 'https://example.com',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp':
            DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      };

      final secretKey = createHmacKey('secret');
      final token = signToken(payload, secretKey);

      await expectLater(
        verifyJwtSignature(token, secretKey, issuer: 'https://example.com'),
        completes,
      );
    });

    test('should verify valid token with subject', () async {
      final payload = {
        'sub': 'user123',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp':
            DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      };

      final secretKey = createHmacKey('secret');
      final token = signToken(payload, secretKey);

      await expectLater(
        verifyJwtSignature(token, secretKey, subject: 'user123'),
        completes,
      );
    });
  });

  group('JwtException', () {
    test('should create exception with code and message', () {
      final exception = JwtException(
        JwtErrorCode.invalidSignature,
        'Invalid signature',
      );

      expect(exception.code, equals(JwtErrorCode.invalidSignature));
      expect(exception.message, equals('Invalid signature'));
    });
  });

  group('JwtErrorCode', () {
    test('should have correct error code values', () {
      expect(JwtErrorCode.invalidArgument.value, equals('invalid-argument'));
      expect(
        JwtErrorCode.invalidCredential.value,
        equals('invalid-credential'),
      );
      expect(JwtErrorCode.tokenExpired.value, equals('token-expired'));
      expect(JwtErrorCode.invalidSignature.value, equals('invalid-token'));
      expect(JwtErrorCode.noMatchingKid.value, equals('no-matching-kid-error'));
      expect(JwtErrorCode.noKidInHeader.value, equals('no-kid-error'));
      expect(JwtErrorCode.keyFetchError.value, equals('key-fetch-error'));
      expect(JwtErrorCode.unknown.value, equals('unknown'));
    });
  });

  group('DecodedToken', () {
    test('should create decoded token with header and payload', () {
      final payload = {'sub': 'user123', 'name': 'John'};

      final header = JoseHeader.fromJson({'alg': 'RS256', 'kid': 'key1'});
      final decoded = DecodedToken(header: header, payload: payload);

      expect(decoded.header, equals(header));
      expect(decoded.payload, equals(payload));
    });
  });
}

class _TestKeyFetcher implements KeyFetcher {
  @override
  Future<JsonWebKeyStore> fetchPublicKeys() async {
    final store = JsonWebKeyStore();

    // Public key corresponding to the test private key above
    const key = mockPrivateKey;

    store.addKey(JsonWebKey.fromPem(key, keyId: 'key1'));

    return store;
  }
}
