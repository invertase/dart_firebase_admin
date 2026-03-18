import 'dart:convert';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:dart_firebase_admin/src/auth.dart';
import 'package:test/test.dart';

void main() {
  group('FirebaseAppException', () {
    test('has correct code and message properties', () {
      final exception = FirebaseAppException(
        AppErrorCode.invalidAppName,
        'Custom message',
      );

      expect(exception.code, 'app/invalid-app-name');
      expect(exception.message, 'Custom message');
    });

    test('uses default message when none provided', () {
      final exception = FirebaseAppException(AppErrorCode.invalidAppName);

      expect(exception.code, 'app/invalid-app-name');
      expect(exception.message, AppErrorCode.invalidAppName.message);
    });

    group('toJson()', () {
      test('returns correct JSON structure', () {
        final exception = FirebaseAppException(
          AppErrorCode.invalidAppName,
          'Custom message',
        );

        final json = exception.toJson();

        expect(json, {
          'code': 'app/invalid-app-name',
          'message': 'Custom message',
        });
      });

      test('can be serialized with jsonEncode', () {
        final exception = FirebaseAppException(
          AppErrorCode.networkError,
          'Connection failed',
        );

        final jsonString = jsonEncode(exception.toJson());

        expect(
          jsonString,
          '{"code":"app/network-error","message":"Connection failed"}',
        );
      });

      test('serializes with default message', () {
        final exception = FirebaseAppException(AppErrorCode.duplicateApp);

        final json = exception.toJson();

        expect(json, {
          'code': 'app/duplicate-app',
          'message': AppErrorCode.duplicateApp.message,
        });
      });

      test('works for all error codes', () {
        for (final errorCode in AppErrorCode.values) {
          final exception = FirebaseAppException(errorCode);
          final json = exception.toJson();

          expect(json['code'], 'app/${errorCode.code}');
          expect(json['message'], errorCode.message);
        }
      });
    });
  });

  group('FirebaseAdminException', () {
    test('has correct code and message properties', () {
      final exception = FirebaseAuthAdminException(
        AuthClientErrorCode.invalidUid,
        'Custom UID error',
      );

      expect(exception.code, 'auth/invalid-uid');
      expect(exception.message, 'Custom UID error');
    });

    test('uses default message when none provided', () {
      final exception = FirebaseAuthAdminException(
        AuthClientErrorCode.invalidEmail,
      );

      expect(exception.code, 'auth/invalid-email');
      expect(exception.message, AuthClientErrorCode.invalidEmail.message);
    });

    group('toJson()', () {
      test('returns correct JSON structure', () {
        final exception = FirebaseAuthAdminException(
          AuthClientErrorCode.emailAlreadyExists,
          'The email is taken',
        );

        final json = exception.toJson();

        expect(json, {
          'code': 'auth/email-already-exists',
          'message': 'The email is taken',
        });
      });

      test('can be serialized with jsonEncode', () {
        final exception = FirebaseAuthAdminException(
          AuthClientErrorCode.userNotFound,
        );

        final jsonString = jsonEncode(exception.toJson());

        expect(jsonString, contains('"code":"auth/user-not-found"'));
        expect(jsonString, contains('"message"'));
      });

      test('serializes platform error codes correctly', () {
        final exception = FirebaseAuthAdminException(
          AuthClientErrorCode.internalError,
        );

        final json = exception.toJson();

        expect(json['code'], 'auth/internal-error');
        expect(json['message'], isNotEmpty);
      });
    });
  });

  group('FirebaseArrayIndexError', () {
    test('has correct index and error properties', () {
      final authException = FirebaseAuthAdminException(
        AuthClientErrorCode.invalidUid,
        'Bad UID',
      );
      final arrayError = FirebaseArrayIndexError(
        index: 5,
        error: authException,
      );

      expect(arrayError.index, 5);
      expect(arrayError.error, authException);
    });

    group('toJson()', () {
      test('returns correct JSON structure', () {
        final authException = FirebaseAuthAdminException(
          AuthClientErrorCode.invalidEmail,
          'Invalid email format',
        );
        final arrayError = FirebaseArrayIndexError(
          index: 3,
          error: authException,
        );

        final json = arrayError.toJson();

        expect(json, {
          'index': 3,
          'error': {
            'code': 'auth/invalid-email',
            'message': 'Invalid email format',
          },
        });
      });

      test('can be serialized with jsonEncode', () {
        final appException = FirebaseAppException(
          AppErrorCode.invalidCredential,
          'Bad credentials',
        );
        final arrayError = FirebaseArrayIndexError(
          index: 0,
          error: appException,
        );

        final jsonString = jsonEncode(arrayError.toJson());

        expect(jsonString, contains('"index":0'));
        expect(jsonString, contains('"code":"app/invalid-credential"'));
        expect(jsonString, contains('"message":"Bad credentials"'));
      });

      test('works with nested error object', () {
        final authException = FirebaseAuthAdminException(
          AuthClientErrorCode.userNotFound,
        );
        final arrayError = FirebaseArrayIndexError(
          index: 10,
          error: authException,
        );

        final json = arrayError.toJson();

        expect(json['index'], 10);
        expect(json['error'], isA<Map<String, dynamic>>());
        final errorMap = json['error'] as Map<String, dynamic>;
        expect(errorMap['code'], 'auth/user-not-found');
        expect(errorMap['message'], isNotEmpty);
      });
    });
  });

  group('Error logging use case', () {
    test('can log errors to structured logging systems', () {
      // Simulates logging to GCP Cloud Logging
      final errors = <Map<String, dynamic>>[];

      try {
        throw FirebaseAppException(
          AppErrorCode.invalidCredential,
          'Service account file is invalid',
        );
      } catch (e) {
        if (e is FirebaseAppException) {
          errors.add({
            'severity': 'ERROR',
            'error': e.toJson(),
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }

      expect(errors, hasLength(1));
      final firstError = errors[0];
      final errorDetail = firstError['error'] as Map<String, dynamic>;
      expect(errorDetail['code'], 'app/invalid-credential');
      expect(errorDetail['message'], 'Service account file is invalid');
    });

    test('can serialize batch errors for logging', () {
      final batchErrors = [
        FirebaseArrayIndexError(
          index: 0,
          error: FirebaseAuthAdminException(
            AuthClientErrorCode.emailAlreadyExists,
          ),
        ),
        FirebaseArrayIndexError(
          index: 2,
          error: FirebaseAuthAdminException(
            AuthClientErrorCode.invalidPhoneNumber,
          ),
        ),
      ];

      final serializedErrors = batchErrors.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode({'errors': serializedErrors});

      expect(jsonString, contains('"index":0'));
      expect(jsonString, contains('"index":2'));
      expect(jsonString, contains('email-already-exists'));
      expect(jsonString, contains('invalid-phone-number'));
    });
  });
}
