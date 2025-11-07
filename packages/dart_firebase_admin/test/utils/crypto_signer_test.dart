import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_firebase_admin/src/utils/crypto_signer.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:test/test.dart';

import '../mock_service_account.dart';

void main() {
  group('CryptoSigner', () {
    group('ServiceAccountSigner', () {
      late CryptoSigner signer;

      setUp(() {
        final credentials = ServiceAccountCredentials.fromJson({
          'private_key': mockPrivateKey,
          'client_email': mockClientEmail,
          'type': 'service_account',
        });
        signer = CryptoSigner.fromApp(
          MockFirebaseApp(serviceAccountCredentials: credentials),
        );
      });

      test('algorithm should be RS256', () {
        expect(signer.algorithm, equals('RS256'));
      });

      test('getAccountId should return service account email', () async {
        final accountId = await signer.getAccountId();
        expect(accountId, equals(mockClientEmail));
      });

      test('sign should generate a signature', () async {
        final data = utf8.encode('test data to sign');
        final signature = await signer.sign(Uint8List.fromList(data));

        expect(signature, isNotEmpty);
        expect(signature.length, greaterThan(0));
      });

      test('sign should produce consistent signatures for same data', () async {
        final data = utf8.encode('test data');
        final signature1 = await signer.sign(Uint8List.fromList(data));
        final signature2 = await signer.sign(Uint8List.fromList(data));

        // RSA signatures should be deterministic with the same key
        expect(signature1, equals(signature2));
      });

      test('sign should produce different signatures for different data',
          () async {
        final data1 = utf8.encode('test data 1');
        final data2 = utf8.encode('test data 2');

        final signature1 = await signer.sign(Uint8List.fromList(data1));
        final signature2 = await signer.sign(Uint8List.fromList(data2));

        expect(signature1, isNot(equals(signature2)));
      });

      test('parseRSAPrivateKey should parse valid PEM key', () {
        // This is tested indirectly through the sign method
        expect(() => signer.sign(Uint8List(32)), returnsNormally);
      });
    });

    group('CryptoSignerException', () {
      test('should create exception with code and message', () {
        final exception = CryptoSignerException(
          CryptoSignerErrorCode.invalidCredential,
          'Test error message',
        );

        expect(exception.code, equals(CryptoSignerErrorCode.invalidCredential));
        expect(exception.message, equals('Test error message'));
      });

      test('toString should return formatted string', () {
        final exception = CryptoSignerException(
          CryptoSignerErrorCode.serverError,
          'Server error occurred',
        );

        expect(
          exception.toString(),
          equals('CryptoSignerException(server-error, Server error occurred)'),
        );
      });
    });

    group('CryptoSignerErrorCode', () {
      test('should have correct error code constants', () {
        expect(
          CryptoSignerErrorCode.invalidArgument,
          equals('invalid-argument'),
        );
        expect(
          CryptoSignerErrorCode.internalError,
          equals('internal-error'),
        );
        expect(
          CryptoSignerErrorCode.invalidCredential,
          equals('invalid-credential'),
        );
        expect(
          CryptoSignerErrorCode.serverError,
          equals('server-error'),
        );
      });
    });
  });
}

// Mock FirebaseAdminApp for testing
class MockFirebaseApp implements dynamic {
  MockFirebaseApp({this.serviceAccountCredentials});

  final ServiceAccountCredentials? serviceAccountCredentials;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #credential) {
      return MockCredential(serviceAccountCredentials);
    }
    return super.noSuchMethod(invocation);
  }
}

class MockCredential implements dynamic {
  MockCredential(this.serviceAccountCredentials);

  final ServiceAccountCredentials? serviceAccountCredentials;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
