import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

void main() {
  group('FirebaseAuthAdminException', () {
    group('Basic construction', () {
      test('should initialize successfully with no message specified', () {
        final error = FirebaseAuthAdminException(
          AuthClientErrorCode.userNotFound,
        );
        expect(error.code, equals('auth/user-not-found'));
        expect(
          error.message,
          equals(
            'There is no user record corresponding to the provided identifier.',
          ),
        );
        expect(error.errorCode, equals(AuthClientErrorCode.userNotFound));
      });

      test('should initialize successfully with a message specified', () {
        final error = FirebaseAuthAdminException(
          AuthClientErrorCode.userNotFound,
          'Custom message',
        );
        expect(error.code, equals('auth/user-not-found'));
        expect(error.message, equals('Custom message'));
        expect(error.errorCode, equals(AuthClientErrorCode.userNotFound));
      });

      test('toString() should include error code and message', () {
        final error = FirebaseAuthAdminException(
          AuthClientErrorCode.userNotFound,
          'Custom message',
        );
        expect(
          error.toString(),
          equals(
            'firebaseAuthAdminException: auth/user-not-found: Custom message',
          ),
        );
      });
    });

    group('fromServerError() - Edge cases', () {
      test('should fallback to INTERNAL_ERROR for unexpected server code', () {
        final error = FirebaseAuthAdminException.fromServerError(
          serverErrorCode: 'UNEXPECTED_ERROR',
        );
        expect(error.code, equals('auth/internal-error'));
        expect(error.message, equals('An internal error has occurred.'));
        expect(error.errorCode, equals(AuthClientErrorCode.internalError));
      });

      test('should handle empty server code', () {
        final error = FirebaseAuthAdminException.fromServerError(
          serverErrorCode: '',
        );
        expect(error.code, equals('auth/internal-error'));
        expect(error.message, equals('An internal error has occurred.'));
      });

      test(
        'should extract detailed message from server error with colon separator',
        () {
          // Error code should be separated from detailed message at first colon.
          final error = FirebaseAuthAdminException.fromServerError(
            serverErrorCode:
                'CONFIGURATION_NOT_FOUND : more details key: value',
          );
          expect(error.code, equals('auth/configuration-not-found'));
          expect(error.message, equals('more details key: value'));
          expect(
            error.errorCode,
            equals(AuthClientErrorCode.configurationNotFound),
          );
        },
      );

      test('should handle server code with colon but no message', () {
        final error = FirebaseAuthAdminException.fromServerError(
          serverErrorCode: 'USER_NOT_FOUND:',
        );
        expect(error.code, equals('auth/user-not-found'));
        // Should use default message when detailed message is empty
        expect(
          error.message,
          equals(
            'There is no user record corresponding to the provided identifier.',
          ),
        );
      });

      test(
        'should handle server code with multiple colons (use first as separator)',
        () {
          final error = FirebaseAuthAdminException.fromServerError(
            serverErrorCode: 'USER_NOT_FOUND : field: value : extra',
          );
          expect(error.code, equals('auth/user-not-found'));
          expect(error.message, equals('field: value : extra'));
        },
      );
    });

    group('fromServerError() - Raw server response', () {
      final mockRawServerResponse = {
        'error': {
          'code': 'UNEXPECTED_ERROR',
          'message': 'An unexpected error occurred.',
        },
      };

      test('should NOT include raw response for expected server codes', () {
        final error = FirebaseAuthAdminException.fromServerError(
          serverErrorCode: 'USER_NOT_FOUND',
          rawServerResponse: mockRawServerResponse,
        );
        expect(error.code, equals('auth/user-not-found'));
        expect(
          error.message,
          equals(
            'There is no user record corresponding to the provided identifier.',
          ),
        );
        expect(error.message, isNot(contains('Raw server response')));
      });

      test('should include raw response for unexpected server codes', () {
        final error = FirebaseAuthAdminException.fromServerError(
          serverErrorCode: 'UNEXPECTED_ERROR',
          rawServerResponse: mockRawServerResponse,
        );
        expect(error.code, equals('auth/internal-error'));
        expect(error.message, contains('An internal error has occurred.'));
        expect(error.message, contains('Raw server response:'));
        expect(error.message, contains('UNEXPECTED_ERROR'));
      });

      test(
        'should handle server detailed message with raw response for unexpected errors',
        () {
          final error = FirebaseAuthAdminException.fromServerError(
            serverErrorCode: 'UNKNOWN_CODE : custom details',
            rawServerResponse: mockRawServerResponse,
          );
          expect(error.code, equals('auth/internal-error'));
          expect(error.message, contains('custom details'));
          expect(error.message, contains('Raw server response:'));
        },
      );

      test('should handle non-serializable raw response gracefully', () {
        // Create a circular reference that can't be JSON encoded
        final circular = <String, dynamic>{};
        circular['self'] = circular;

        final error = FirebaseAuthAdminException.fromServerError(
          serverErrorCode: 'UNEXPECTED_ERROR',
          rawServerResponse: circular,
        );
        expect(error.code, equals('auth/internal-error'));
        // Should still create the error even if JSON encoding fails
        expect(error.message, isNotEmpty);
        // Should not crash or throw
      });
    });

    group('Newly added error codes', () {
      test('should map INVALID_SERVICE_ACCOUNT correctly', () {
        final error = FirebaseAuthAdminException.fromServerError(
          serverErrorCode: 'INVALID_SERVICE_ACCOUNT',
        );
        expect(
          error.errorCode,
          equals(AuthClientErrorCode.invalidServiceAccount),
        );
        expect(error.code, equals('auth/invalid-service-account'));
        expect(error.message, equals('Invalid service account.'));
      });

      test('should map INVALID_HOSTING_LINK_DOMAIN correctly', () {
        final error = FirebaseAuthAdminException.fromServerError(
          serverErrorCode: 'INVALID_HOSTING_LINK_DOMAIN',
        );
        expect(
          error.errorCode,
          equals(AuthClientErrorCode.invalidHostingLinkDomain),
        );
        expect(error.code, equals('auth/invalid-hosting-link-domain'));
        expect(
          error.message,
          equals(
            'The provided hosting link domain is not configured or authorized '
            'for the current project.',
          ),
        );
      });
    });

    group('Exception type hierarchy', () {
      test('should be catchable as Exception', () {
        expect(
          () => throw FirebaseAuthAdminException(
            AuthClientErrorCode.userNotFound,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should be catchable as FirebaseAdminException', () {
        expect(
          () => throw FirebaseAuthAdminException(
            AuthClientErrorCode.userNotFound,
          ),
          throwsA(isA<FirebaseAdminException>()),
        );
      });

      test('should be catchable as FirebaseAuthAdminException', () {
        expect(
          () => throw FirebaseAuthAdminException(
            AuthClientErrorCode.userNotFound,
          ),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });

      test('should match on specific error code', () {
        expect(
          () => throw FirebaseAuthAdminException(
            AuthClientErrorCode.userNotFound,
          ),
          throwsA(
            isA<FirebaseAuthAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              AuthClientErrorCode.userNotFound,
            ),
          ),
        );
      });
    });
  });
}
