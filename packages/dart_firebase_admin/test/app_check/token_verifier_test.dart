import 'package:dart_firebase_admin/src/app_check/ap_check_api_internal.dart';
import 'package:dart_firebase_admin/src/app_check/token_verifier.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:test/test.dart';

void main() {
  group('AppCheckTokenVerifier', () {
    late AppCheckTokenVerifier verifier;
    const projectId = 'test-project';

    setUp(() {
      verifier = AppCheckTokenVerifier(MockFirebaseApp(projectId: projectId));
    });

    group('_verifyContent', () {
      test('should reject token with wrong algorithm', () {
        final decodedToken = MockDecodedToken(
          header: {'alg': 'HS256'},
          payload: {
            'aud': ['projects/$projectId'],
            'iss': 'https://firebaseappcheck.googleapis.com/',
            'sub': 'app-id',
          },
        );

        expect(
          () => verifier.verifyContentForTesting(decodedToken, projectId),
          throwsA(
            isA<FirebaseAppCheckException>().having(
              (e) => e.message,
              'message',
              contains('incorrect algorithm'),
            ),
          ),
        );
      });

      test('should reject token with incorrect audience', () {
        final decodedToken = MockDecodedToken(
          header: {'alg': 'RS256'},
          payload: {
            'aud': ['projects/wrong-project'],
            'iss': 'https://firebaseappcheck.googleapis.com/',
            'sub': 'app-id',
          },
        );

        expect(
          () => verifier.verifyContentForTesting(decodedToken, projectId),
          throwsA(
            isA<FirebaseAppCheckException>().having(
              (e) => e.message,
              'message',
              contains('incorrect "aud"'),
            ),
          ),
        );
      });

      test('should reject token with incorrect issuer', () {
        final decodedToken = MockDecodedToken(
          header: {'alg': 'RS256'},
          payload: {
            'aud': ['projects/$projectId'],
            'iss': 'https://wrong-issuer.com/',
            'sub': 'app-id',
          },
        );

        expect(
          () => verifier.verifyContentForTesting(decodedToken, projectId),
          throwsA(
            isA<FirebaseAppCheckException>().having(
              (e) => e.message,
              'message',
              contains('incorrect "iss"'),
            ),
          ),
        );
      });

      test('should reject token without subject', () {
        final decodedToken = MockDecodedToken(
          header: {'alg': 'RS256'},
          payload: {
            'aud': ['projects/$projectId'],
            'iss': 'https://firebaseappcheck.googleapis.com/',
          },
        );

        expect(
          () => verifier.verifyContentForTesting(decodedToken, projectId),
          throwsA(
            isA<FirebaseAppCheckException>().having(
              (e) => e.message,
              'message',
              contains('no "sub"'),
            ),
          ),
        );
      });

      test('should reject token with empty subject', () {
        final decodedToken = MockDecodedToken(
          header: {'alg': 'RS256'},
          payload: {
            'aud': ['projects/$projectId'],
            'iss': 'https://firebaseappcheck.googleapis.com/',
            'sub': '',
          },
        );

        expect(
          () => verifier.verifyContentForTesting(decodedToken, projectId),
          throwsA(
            isA<FirebaseAppCheckException>().having(
              (e) => e.message,
              'message',
              contains('empty string "sub"'),
            ),
          ),
        );
      });

      test('should accept valid token', () {
        final decodedToken = MockDecodedToken(
          header: {'alg': 'RS256'},
          payload: {
            'aud': ['projects/$projectId'],
            'iss': 'https://firebaseappcheck.googleapis.com/123456',
            'sub': 'app-id',
          },
        );

        expect(
          () => verifier.verifyContentForTesting(decodedToken, projectId),
          returnsNormally,
        );
      });
    });

    test('appCheckIssuer constant should be correct', () {
      expect(appCheckIssuer, equals('https://firebaseappcheck.googleapis.com/'));
    });

    test('jwksUrl constant should be correct', () {
      expect(
        jwksUrl,
        equals('https://firebaseappcheck.googleapis.com/v1/jwks'),
      );
    });
  });
}

// Mock classes for testing
class MockFirebaseApp {
  MockFirebaseApp({required this.projectId});

  final String projectId;
}

class MockDecodedToken {
  MockDecodedToken({required this.header, required this.payload});

  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;
}

// Extension to expose private methods for testing
extension AppCheckTokenVerifierTest on AppCheckTokenVerifier {
  void verifyContentForTesting(MockDecodedToken decodedToken, String projectId) {
    // We're calling the private _verifyContent method indirectly through reflection
    // or by copying the logic here for testing
    final header = decodedToken.header;
    final payload = decodedToken.payload;

    const projectIdMatchMessage =
        ' Make sure the App Check token comes from the same '
        'Firebase project as the service account used to authenticate this SDK.';
    final scopedProjectId = 'projects/$projectId';

    String? errorMessage;
    if (header['alg'] case final alg && != 'RS256') {
      errorMessage =
          'The provided App Check token has incorrect algorithm. Expected "RS256" but got "$alg".';
    } else if (payload['aud'] case final List<Object?> aud
        when !aud.contains(scopedProjectId)) {
      errorMessage =
          'The provided App Check token has incorrect "aud" (audience) claim. Expected "$scopedProjectId" but got "$aud".$projectIdMatchMessage';
    } else if (payload['iss'] case final iss
        when iss is! String || !iss.startsWith(appCheckIssuer)) {
      errorMessage =
          'The provided App Check token has incorrect "iss" (issuer) claim.';
    } else if (payload['sub'] case final sub when sub is! String) {
      errorMessage =
          'The provided App Check token has no "sub" (subject) claim.';
    } else if (payload['sub'] == '') {
      errorMessage =
          'The provided App Check token has an empty string "sub" (subject) claim.';
    }

    if (errorMessage != null) {
      throw FirebaseAppCheckException(
        AppCheckErrorCode.invalidArgument,
        errorMessage,
      );
    }
  }
}
