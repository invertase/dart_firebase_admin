import 'package:dart_firebase_admin/src/utils/jwt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:jose/jose.dart';
import 'package:test/test.dart';

import '../mock_service_account.dart';

void main() {
  group('PublicKeySignatureVerifier', () {
    final privateKey = RSAPrivateKey(mockPrivateKey);
    final keyFetcher = _TestKeyFetcher();
    final payload = {
      'a': '1',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    test('valid kid should pass', () async {
      final jwt = JWT(
        payload,
        header: {'kid': 'key1'},
      );
      final token = jwt.sign(
        privateKey,
        algorithm: JWTAlgorithm.RS256,
      );
      await PublicKeySignatureVerifier(keyFetcher).verify(token);
    });

    test('no kid should throw', () async {
      final jwt = JWT(payload);
      final token = jwt.sign(
        privateKey,
        algorithm: JWTAlgorithm.RS256,
      );
      await expectLater(
        PublicKeySignatureVerifier(keyFetcher).verify(token),
        throwsA(isA<JwtException>()),
      );
    });

    test('invalid kid should throw', () async {
      final jwt = JWT(
        payload,
        header: {'kid': 'key2'},
      );
      final token = jwt.sign(
        privateKey,
        algorithm: JWTAlgorithm.RS256,
      );
      await expectLater(
        PublicKeySignatureVerifier(keyFetcher).verify(token),
        throwsA(isA<JwtException>()),
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
        'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
            1000,
      };

      // Create token with 'none' algorithm (emulator tokens)
      final jwt = JWT(payload);
      final token = jwt.sign(
        SecretKey(''),
        algorithm: JWTAlgorithm.HS256,
        noIssueAt: true,
      );

      await expectLater(
        verifier.verify(token),
        completes,
      );
    });
  });

  group('decodeJwt', () {
    test('should decode valid JWT', () async {
      final payload = {
        'sub': 'user123',
        'name': 'John Doe',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
      final jwt = JWT(payload, header: {'alg': 'HS256', 'typ': 'JWT'});
      final token = jwt.sign(SecretKey('secret'));

      final decoded = await decodeJwt(token);

      expect(decoded.header['alg'], equals('HS256'));
      expect(decoded.header['typ'], equals('JWT'));
      expect(decoded.payload['sub'], equals('user123'));
      expect(decoded.payload['name'], equals('John Doe'));
    });

    test('should handle payload with various types', () async {
      final payload = {
        'string': 'value',
        'number': 42,
        'bool': true,
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
      };
      final jwt = JWT(payload);
      final token = jwt.sign(SecretKey('secret'));

      final decoded = await decodeJwt(token);

      expect(decoded.payload['string'], equals('value'));
      expect(decoded.payload['number'], equals(42));
      expect(decoded.payload['bool'], equals(true));
      expect(decoded.payload['list'], equals([1, 2, 3]));
      expect(decoded.payload['map'], equals({'nested': 'value'}));
    });
  });

  group('verifyJwtSignature', () {
    test('should throw JwtException for expired tokens', () {
      final payload = {
        'sub': 'user123',
        'exp': DateTime.now()
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
        'iat': DateTime.now()
                .subtract(const Duration(hours: 2))
                .millisecondsSinceEpoch ~/
            1000,
      };
      final jwt = JWT(payload);
      final token = jwt.sign(SecretKey('secret'));

      expect(
        () => verifyJwtSignature(token, SecretKey('secret')),
        throwsA(
          isA<JwtException>().having(
            (e) => e.code,
            'code',
            JwtErrorCode.tokenExpired,
          ),
        ),
      );
    });

    test('should verify valid token with issuer', () {
      final payload = {
        'sub': 'user123',
        'iss': 'https://example.com',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
            1000,
      };
      final jwt = JWT(payload);
      final token = jwt.sign(SecretKey('secret'));

      expect(
        () => verifyJwtSignature(
          token,
          SecretKey('secret'),
          issuer: 'https://example.com',
        ),
        returnsNormally,
      );
    });

    test('should verify valid token with subject', () {
      final payload = {
        'sub': 'user123',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
            1000,
      };
      final jwt = JWT(payload);
      final token = jwt.sign(SecretKey('secret'));

      expect(
        () => verifyJwtSignature(
          token,
          SecretKey('secret'),
          subject: 'user123',
        ),
        returnsNormally,
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
      expect(JwtErrorCode.invalidCredential.value, equals('invalid-credential'));
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
      final header = {'alg': 'RS256', 'kid': 'key1'};
      final payload = {'sub': 'user123', 'name': 'John'};

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
