import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/src/utils/crypto_signer.dart';
import 'package:test/test.dart';

import '../mock_service_account.dart';

void main() {
  group('CryptoSigner', () {
    group('ServiceAccountSigner', () {
      late CryptoSigner signer;

      setUp(() {
        final app = FirebaseApp.initializeApp(
          name: '$mockProjectId-crypto',
          options: AppOptions(
            credential: Credential.fromServiceAccountParams(
              clientId: 'test-client-id',
              privateKey: mockPrivateKey,
              email: mockClientEmail,
            ),
          ),
        );
        signer = CryptoSigner.fromApp(app);
      });

      test('algorithm should be RS256', () {
        expect(signer.algorithm, equals('RS256'));
      });

      test('getAccountId should return service account email', () async {
        final accountId = await signer.getAccountId();
        expect(accountId, equals(mockClientEmail));
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
