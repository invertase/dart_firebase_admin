import 'package:dart_firebase_admin/src/app_check/app_check_api_internal.dart';
import 'package:dart_firebase_admin/src/utils/jwt.dart';
import 'package:test/test.dart';

void main() {
  group('AppCheckErrorCode', () {
    test('should have correct error code values', () {
      expect(AppCheckErrorCode.aborted.code, equals('aborted'));
      expect(
        AppCheckErrorCode.invalidArgument.code,
        equals('invalid-argument'),
      );
      expect(
        AppCheckErrorCode.invalidCredential.code,
        equals('invalid-credential'),
      );
      expect(AppCheckErrorCode.internalError.code, equals('internal-error'));
      expect(
        AppCheckErrorCode.permissionDenied.code,
        equals('permission-denied'),
      );
      expect(
        AppCheckErrorCode.unauthenticated.code,
        equals('unauthenticated'),
      );
      expect(AppCheckErrorCode.notFound.code, equals('not-found'));
      expect(
        AppCheckErrorCode.appCheckTokenExpired.code,
        equals('app-check-token-expired'),
      );
      expect(AppCheckErrorCode.unknownError.code, equals('unknown-error'));
    });

    test('from should map crypto signer error codes', () {
      expect(
        AppCheckErrorCode.from('invalid-credential'),
        equals(AppCheckErrorCode.invalidCredential),
      );
      expect(
        AppCheckErrorCode.from('invalid-argument'),
        equals(AppCheckErrorCode.invalidArgument),
      );
      expect(
        AppCheckErrorCode.from('unknown-code'),
        equals(AppCheckErrorCode.internalError),
      );
    });
  });

  group('FirebaseAppCheckException', () {
    test('should create exception with code and message', () {
      final exception = FirebaseAppCheckException(
        AppCheckErrorCode.invalidArgument,
        'Test error message',
      );

      expect(exception.code, equals('app-check/invalid-argument'));
      expect(exception.message, equals('Test error message'));
    });

    test('should create exception without message', () {
      final exception = FirebaseAppCheckException(
        AppCheckErrorCode.permissionDenied,
      );

      expect(exception.code, equals('app-check/permission-denied'));
      // Base class provides a default message when none is specified
      expect(exception.message, isNotEmpty);
    });

    test('fromJwtException should handle tokenExpired error', () {
      final jwtError = JwtException(
        JwtErrorCode.tokenExpired,
        'Token expired',
      );

      final exception = FirebaseAppCheckException.fromJwtException(jwtError);

      expect(exception.code, equals('app-check/app-check-token-expired'));
      expect(
        exception.message,
        contains('The provided App Check token has expired'),
      );
    });

    test('fromJwtException should handle invalidSignature error', () {
      final jwtError = JwtException(
        JwtErrorCode.invalidSignature,
        'Invalid signature',
      );

      final exception = FirebaseAppCheckException.fromJwtException(jwtError);

      expect(exception.code, equals('app-check/invalid-argument'));
      expect(
        exception.message,
        contains('The provided App Check token has invalid signature'),
      );
    });

    test('fromJwtException should handle noMatchingKid error', () {
      final jwtError = JwtException(
        JwtErrorCode.noMatchingKid,
        'No matching kid',
      );

      final exception = FirebaseAppCheckException.fromJwtException(jwtError);

      expect(exception.code, equals('app-check/invalid-argument'));
      expect(
        exception.message,
        contains('The provided App Check token has "kid" claim which does not'),
      );
    });

    test('fromJwtException should handle other errors', () {
      final jwtError = JwtException(
        JwtErrorCode.unknown,
        'Unknown error',
      );

      final exception = FirebaseAppCheckException.fromJwtException(jwtError);

      expect(exception.code, equals('app-check/invalid-argument'));
      expect(exception.message, equals('Unknown error'));
    });
  });

  group('appCheckErrorCodeMapping', () {
    test('should have correct mappings', () {
      expect(
        appCheckErrorCodeMapping['ABORTED'],
        equals(AppCheckErrorCode.aborted),
      );
      expect(
        appCheckErrorCodeMapping['INVALID_ARGUMENT'],
        equals(AppCheckErrorCode.invalidArgument),
      );
      expect(
        appCheckErrorCodeMapping['INVALID_CREDENTIAL'],
        equals(AppCheckErrorCode.invalidCredential),
      );
      expect(
        appCheckErrorCodeMapping['INTERNAL'],
        equals(AppCheckErrorCode.internalError),
      );
      expect(
        appCheckErrorCodeMapping['PERMISSION_DENIED'],
        equals(AppCheckErrorCode.permissionDenied),
      );
      expect(
        appCheckErrorCodeMapping['UNAUTHENTICATED'],
        equals(AppCheckErrorCode.unauthenticated),
      );
      expect(
        appCheckErrorCodeMapping['NOT_FOUND'],
        equals(AppCheckErrorCode.notFound),
      );
      expect(
        appCheckErrorCodeMapping['UNKNOWN'],
        equals(AppCheckErrorCode.unknownError),
      );
    });
  });
}
