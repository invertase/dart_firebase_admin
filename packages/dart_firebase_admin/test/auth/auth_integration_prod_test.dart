// Firebase Auth Integration Tests - Production Only
//
// These tests require production Firebase (GOOGLE_APPLICATION_CREDENTIALS)
// because they test features not available in the emulator:
// - Session cookies (require GCIP)
// - getUsers (not fully supported in emulator)
// - Provider configs (require GCIP)
// - Custom claims null behavior (emulator returns {} instead of null)
//
// **IMPORTANT:** These tests use runZoned with zoneValues to temporarily
// disable the emulator environment variable. This allows them to run in the
// coverage script (which has emulator vars set) by connecting to production
// only for these specific tests.
//
// Run standalone with:
//   GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json dart test test/auth/auth_integration_prod_test.dart
//
// Or as part of coverage (they auto-detect and disable emulator):
//   FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json dart test

import 'dart:async';
import 'dart:io';

import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:googleapis/identitytoolkit/v1.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../google_cloud_firestore/util/helpers.dart';

const _uid = Uuid();

void main() {
  group('setCustomUserClaims (Production)', () {
    test(
      'clears custom claims when null is passed',
      () {
        // Remove emulator env var from the zone environment
        final prodEnv = Map<String, String>.from(Platform.environment);
        prodEnv.remove(Environment.firebaseAuthEmulatorHost);

        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final testAuth = Auth.internal(app);

          UserRecord? user;
          try {
            user = await testAuth.createUser(CreateRequest(uid: _uid.v4()));
            await testAuth.setCustomUserClaims(
              user.uid,
              customUserClaims: {'role': 'admin'},
            );

            await testAuth.setCustomUserClaims(user.uid);

            final updatedUser = await testAuth.getUser(user.uid);
            // When custom claims are cleared, Firebase returns an empty map, not null
            // This matches Node SDK behavior: expect(userRecord.customClaims).to.deep.equal({})
            expect(updatedUser.customClaims, isEmpty);
          } finally {
            if (user != null) {
              await testAuth.deleteUser(user.uid);
            }
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv});
      },
      skip: hasGoogleEnv
          ? false
          : 'Requires production to verify custom claims clearing',
    );
  });

  group('Session Cookies (Production)', () {
    // Note: Session cookies require GCIP (Google Cloud Identity Platform)
    // and are not available in the Auth Emulator. Most tests wrap the test body
    // in runZoned to ensure the zone environment (without emulator) stays active.
    test(
      'creates and verifies a valid session cookie',
      () {
        // Remove emulator env var from the zone environment
        final prodEnv = Map<String, String>.from(Platform.environment);
        prodEnv.remove(Environment.firebaseAuthEmulatorHost);

        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final testAuth = Auth.internal(app);

          // Helper function to exchange custom token for ID token
          Future<String> getIdTokenFromCustomToken(String customToken) async {
            final client = await testAuth.app.client;
            final api = IdentityToolkitApi(client);

            final request =
                GoogleCloudIdentitytoolkitV1SignInWithCustomTokenRequest(
                  token: customToken,
                  returnSecureToken: true,
                );

            final response = await api.accounts.signInWithCustomToken(request);

            if (response.idToken == null || response.idToken!.isEmpty) {
              throw Exception(
                'Failed to exchange custom token for ID token: No idToken in response',
              );
            }

            return response.idToken!;
          }

          UserRecord? user;
          try {
            user = await testAuth.createUser(CreateRequest(uid: _uid.v4()));

            final customToken = await testAuth.createCustomToken(user.uid);
            final idToken = await getIdTokenFromCustomToken(customToken);

            const expiresIn = 24 * 60 * 60 * 1000; // 24 hours
            final sessionCookie = await testAuth.createSessionCookie(
              idToken,
              const SessionCookieOptions(expiresIn: expiresIn),
            );

            expect(sessionCookie, isNotEmpty);

            final decodedToken = await testAuth.verifySessionCookie(
              sessionCookie,
            );
            expect(decodedToken.uid, equals(user.uid));
            expect(decodedToken.iss, contains('session.firebase.google.com'));
          } finally {
            if (user != null) {
              await testAuth.deleteUser(user.uid);
            }
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv});
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require GCIP (not available in emulator)',
    );

    // Note: Session cookies require GCIP (Google Cloud Identity Platform)
    // and are not available in the Auth Emulator. This test wraps the test body
    // in runZoned to ensure the zone environment (without emulator) stays active.
    test(
      'creates a revocable session cookie',
      () {
        // Remove emulator env var from the zone environment
        final prodEnv = Map<String, String>.from(Platform.environment);
        prodEnv.remove(Environment.firebaseAuthEmulatorHost);

        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final testAuth = Auth.internal(app);

          // Helper function to exchange custom token for ID token
          Future<String> getIdTokenFromCustomToken(String customToken) async {
            final client = await testAuth.app.client;
            final api = IdentityToolkitApi(client);

            final request =
                GoogleCloudIdentitytoolkitV1SignInWithCustomTokenRequest(
                  token: customToken,
                  returnSecureToken: true,
                );

            final response = await api.accounts.signInWithCustomToken(request);

            if (response.idToken == null || response.idToken!.isEmpty) {
              throw Exception(
                'Failed to exchange custom token for ID token: No idToken in response',
              );
            }

            return response.idToken!;
          }

          try {
            final user = await testAuth.createUser(
              CreateRequest(uid: _uid.v4()),
            );

            final customToken = await testAuth.createCustomToken(user.uid);
            final idToken = await getIdTokenFromCustomToken(customToken);

            const expiresIn = 24 * 60 * 60 * 1000;
            final sessionCookie = await testAuth.createSessionCookie(
              idToken,
              const SessionCookieOptions(expiresIn: expiresIn),
            );

            final decodedToken = await testAuth.verifySessionCookie(
              sessionCookie,
            );
            expect(decodedToken.uid, equals(user.uid));

            await Future<void>.delayed(const Duration(seconds: 2));
            await testAuth.revokeRefreshTokens(user.uid);

            // Without checkRevoked, should not throw
            await testAuth.verifySessionCookie(sessionCookie);

            // With checkRevoked: true, should throw
            await expectLater(
              () => testAuth.verifySessionCookie(
                sessionCookie,
                checkRevoked: true,
              ),
              throwsA(
                isA<FirebaseAuthAdminException>().having(
                  (e) => e.code,
                  'code',
                  'auth/session-cookie-revoked',
                ),
              ),
            );
            await testAuth.deleteUser(user.uid);
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv});
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require GCIP (not available in emulator)',
    );

    // Note: Session cookies require GCIP (Google Cloud Identity Platform)
    // and are not available in the Auth Emulator. This test wraps the test body
    // in runZoned to ensure the zone environment (without emulator) stays active.
    test(
      'fails when ID token is revoked',
      () {
        // Remove emulator env var from the zone environment
        final prodEnv = Map<String, String>.from(Platform.environment);
        prodEnv.remove(Environment.firebaseAuthEmulatorHost);

        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final testAuth = Auth.internal(app);

          // Helper function to exchange custom token for ID token
          Future<String> getIdTokenFromCustomToken(String customToken) async {
            final client = await testAuth.app.client;
            final api = IdentityToolkitApi(client);

            final request =
                GoogleCloudIdentitytoolkitV1SignInWithCustomTokenRequest(
                  token: customToken,
                  returnSecureToken: true,
                );

            final response = await api.accounts.signInWithCustomToken(request);

            if (response.idToken == null || response.idToken!.isEmpty) {
              throw Exception(
                'Failed to exchange custom token for ID token: No idToken in response',
              );
            }

            return response.idToken!;
          }

          UserRecord? user;
          try {
            user = await testAuth.createUser(CreateRequest(uid: _uid.v4()));

            final customToken = await testAuth.createCustomToken(user.uid);
            final idToken = await getIdTokenFromCustomToken(customToken);

            await Future<void>.delayed(const Duration(seconds: 2));
            await testAuth.revokeRefreshTokens(user.uid);

            const expiresIn = 24 * 60 * 60 * 1000;
            await expectLater(
              () => testAuth.createSessionCookie(
                idToken,
                const SessionCookieOptions(expiresIn: expiresIn),
              ),
              throwsA(isA<FirebaseAuthAdminException>()),
            );
          } finally {
            if (user != null) {
              await testAuth.deleteUser(user.uid);
            }
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv});
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require GCIP (not available in emulator)',
    );

    test(
      'verifySessionCookie rejects invalid session cookie',
      () {
        // Remove emulator env var from the zone environment
        final prodEnv = Map<String, String>.from(Platform.environment);
        prodEnv.remove(Environment.firebaseAuthEmulatorHost);

        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final testAuth = Auth.internal(app);

          try {
            await expectLater(
              () => testAuth.verifySessionCookie('invalid-session-cookie'),
              throwsA(
                isA<FirebaseAuthAdminException>().having(
                  (e) => e.code,
                  'code',
                  'auth/argument-error',
                ),
              ),
            );
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv});
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require GCIP (not available in emulator)',
    );
  });

  group('getUsers (Production)', () {
    test(
      'gets multiple users by different identifiers',
      () {
        // Remove emulator env var from the zone environment
        final prodEnv = Map<String, String>.from(Platform.environment);
        prodEnv.remove(Environment.firebaseAuthEmulatorHost);

        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final testAuth = Auth.internal(app);

          UserRecord? user1;
          UserRecord? user2;
          try {
            user1 = await testAuth.createUser(
              CreateRequest(
                uid: _uid.v4(),
                email: 'user1-${_uid.v4()}@example.com',
              ),
            );
            user2 = await testAuth.createUser(
              CreateRequest(
                uid: _uid.v4(),
                phoneNumber:
                    '+1${DateTime.now().millisecondsSinceEpoch % 10000000000}',
              ),
            );

            final result = await testAuth.getUsers([
              UidIdentifier(uid: user1.uid),
              EmailIdentifier(email: user1.email!),
              UidIdentifier(uid: user2.uid),
            ]);

            expect(result.users.length, greaterThanOrEqualTo(2));
            expect(result.users.map((u) => u.uid), contains(user1.uid));
            expect(result.users.map((u) => u.uid), contains(user2.uid));
          } finally {
            await Future.wait([
              if (user1 != null) testAuth.deleteUser(user1.uid),
              if (user2 != null) testAuth.deleteUser(user2.uid),
            ]);
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv});
      },
      skip: hasGoogleEnv
          ? false
          : 'getUsers not fully supported in Firebase Auth Emulator',
    );

    test(
      'reports not found users',
      () {
        // Remove emulator env var from the zone environment
        final prodEnv = Map<String, String>.from(Platform.environment);
        prodEnv.remove(Environment.firebaseAuthEmulatorHost);

        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final testAuth = Auth.internal(app);

          UserRecord? user1;
          try {
            user1 = await testAuth.createUser(CreateRequest(uid: _uid.v4()));

            final result = await testAuth.getUsers([
              UidIdentifier(uid: user1.uid),
              UidIdentifier(uid: 'non-existent-uid'),
              EmailIdentifier(email: 'nonexistent@example.com'),
            ]);

            expect(result.users, isNotEmpty);
            expect(result.users.map((u) => u.uid), contains(user1.uid));
            expect(result.notFound, isNotEmpty);
          } finally {
            if (user1 != null) {
              await testAuth.deleteUser(user1.uid);
            }
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv});
      },
      skip: hasGoogleEnv
          ? false
          : 'getUsers not fully supported in Firebase Auth Emulator',
    );
  });

  group('createProviderConfig (Production)', () {
    // Note: These tests create their own Auth instances inside runZoned
    // to ensure the zone environment stays active during test execution.

    // Note: OIDC provider configs require GCIP (Google Cloud Identity Platform)
    // and are not available in the Auth Emulator. This test wraps the test body
    // in runZoned to ensure the zone environment (without emulator) stays active.
    test(
      'creates OIDC provider config successfully',
      () {
        // Remove emulator env var from the zone environment
        final prodEnv = Map<String, String>.from(Platform.environment);
        prodEnv.remove(Environment.firebaseAuthEmulatorHost);

        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final testAuth = Auth.internal(app);

          try {
            final oidcConfig = OIDCAuthProviderConfig(
              providerId: 'oidc.test-provider',
              displayName: 'Test OIDC Provider',
              enabled: true,
              clientId: 'TEST_CLIENT_ID',
              issuer: 'https://oidc.example.com/issuer',
              clientSecret: 'TEST_CLIENT_SECRET',
            );

            final createdConfig = await testAuth.createProviderConfig(
              oidcConfig,
            );

            expect(createdConfig, isA<OIDCAuthProviderConfig>());
            expect(createdConfig.providerId, equals('oidc.test-provider'));
            expect(createdConfig.displayName, equals('Test OIDC Provider'));
            expect(createdConfig.enabled, isTrue);

            await testAuth.deleteProviderConfig('oidc.test-provider');
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv});
      },
      skip: hasGoogleEnv
          ? false
          : 'Provider configs require GCIP (not available in emulator)',
    );

    // Note: SAML provider configs require GCIP (Google Cloud Identity Platform)
    // and are not available in the Auth Emulator. This test wraps the test body
    // in runZoned to ensure the zone environment (without emulator) stays active.
    test(
      'creates SAML provider config successfully',
      () {
        // Remove emulator env var from the zone environment
        final prodEnv = Map<String, String>.from(Platform.environment);
        prodEnv.remove(Environment.firebaseAuthEmulatorHost);

        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final testAuth = Auth.internal(app);

          try {
            final samlConfig = SAMLAuthProviderConfig(
              providerId: 'saml.test-provider',
              displayName: 'Test SAML Provider',
              enabled: true,
              idpEntityId: 'TEST_IDP_ENTITY_ID',
              ssoURL: 'https://example.com/login',
              x509Certificates: ['TEST_CERT'],
              rpEntityId: 'TEST_RP_ENTITY_ID',
              callbackURL: 'https://project-id.firebaseapp.com/__/auth/handler',
            );

            final createdConfig = await testAuth.createProviderConfig(
              samlConfig,
            );

            expect(createdConfig, isA<SAMLAuthProviderConfig>());
            expect(createdConfig.providerId, equals('saml.test-provider'));
            expect(createdConfig.displayName, equals('Test SAML Provider'));
            expect(createdConfig.enabled, isTrue);

            await testAuth.deleteProviderConfig('saml.test-provider');
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv});
      },
      skip: hasGoogleEnv
          ? false
          : 'Provider configs require GCIP (not available in emulator)',
    );
  });
}
