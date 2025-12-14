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

/// Helper to create Auth instance for production tests.
/// Uses runZoned to temporarily disable emulator env vars.
Auth createProductionAuth() {
  late Auth auth;
  late FirebaseApp app;

  // Remove emulator env var from the zone environment
  final prodEnv = Map<String, String>.from(Platform.environment);
  prodEnv.remove(Environment.firebaseAuthEmulatorHost);

  runZoned(() {
    final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
    app = FirebaseApp.initializeApp(name: appName);
    auth = Auth(app);

    addTearDown(() async {
      // Clean up users
      try {
        final users = await auth.listUsers();
        await Future.wait([
          for (final user in users.users) auth.deleteUser(user.uid),
        ]);
      } catch (_) {
        // Ignore cleanup errors
      }
      await app.close();
    });
  }, zoneValues: {envSymbol: prodEnv});

  return auth;
}

void main() {
  group('setCustomUserClaims (Production)', () {
    late Auth auth;

    setUp(() {
      if (!hasGoogleEnv) return;
      auth = createProductionAuth();
    });

    test(
      'clears custom claims when null is passed',
      () async {
        final user = await auth.createUser(CreateRequest(uid: _uid.v4()));
        await auth.setCustomUserClaims(
          user.uid,
          customUserClaims: {'role': 'admin'},
        );

        await auth.setCustomUserClaims(user.uid);

        final updatedUser = await auth.getUser(user.uid);
        expect(updatedUser.customClaims, isNull);
      },
      skip: hasGoogleEnv
          ? false
          : 'Requires production (emulator returns {} instead of null)',
    );
  });

  group('Session Cookies (Production)', () {
    late Auth auth;

    setUp(() {
      if (!hasGoogleEnv) return;
      auth = createProductionAuth();
    });

    // Helper function to exchange custom token for ID token
    Future<String> getIdTokenFromCustomToken(String customToken) async {
      final client = await auth.app.client;
      final api = IdentityToolkitApi(client);

      final request = GoogleCloudIdentitytoolkitV1SignInWithCustomTokenRequest(
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

    test(
      'creates and verifies a valid session cookie',
      () async {
        final user = await auth.createUser(CreateRequest(uid: _uid.v4()));

        final customToken = await auth.createCustomToken(user.uid);
        final idToken = await getIdTokenFromCustomToken(customToken);

        const expiresIn = 24 * 60 * 60 * 1000; // 24 hours
        final sessionCookie = await auth.createSessionCookie(
          idToken,
          const SessionCookieOptions(expiresIn: expiresIn),
        );

        expect(sessionCookie, isNotEmpty);

        final decodedToken = await auth.verifySessionCookie(sessionCookie);
        expect(decodedToken.uid, equals(user.uid));
        expect(decodedToken.iss, contains('session.firebase.google.com'));
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require GCIP (not available in emulator)',
    );

    test(
      'creates a revocable session cookie',
      () async {
        final user = await auth.createUser(CreateRequest(uid: _uid.v4()));

        final customToken = await auth.createCustomToken(user.uid);
        final idToken = await getIdTokenFromCustomToken(customToken);

        const expiresIn = 24 * 60 * 60 * 1000;
        final sessionCookie = await auth.createSessionCookie(
          idToken,
          const SessionCookieOptions(expiresIn: expiresIn),
        );

        final decodedToken = await auth.verifySessionCookie(sessionCookie);
        expect(decodedToken.uid, equals(user.uid));

        await Future<void>.delayed(const Duration(seconds: 2));
        await auth.revokeRefreshTokens(user.uid);

        await auth.verifySessionCookie(sessionCookie);

        await expectLater(
          () => auth.verifySessionCookie(sessionCookie, checkRevoked: true),
          throwsA(
            isA<FirebaseAuthAdminException>().having(
              (e) => e.code,
              'code',
              'auth/session-cookie-revoked',
            ),
          ),
        );
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require GCIP (not available in emulator)',
    );

    test(
      'fails when ID token is revoked',
      () async {
        final user = await auth.createUser(CreateRequest(uid: _uid.v4()));

        final customToken = await auth.createCustomToken(user.uid);
        final idToken = await getIdTokenFromCustomToken(customToken);

        await Future<void>.delayed(const Duration(seconds: 2));
        await auth.revokeRefreshTokens(user.uid);

        const expiresIn = 24 * 60 * 60 * 1000;
        await expectLater(
          () => auth.createSessionCookie(
            idToken,
            const SessionCookieOptions(expiresIn: expiresIn),
          ),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require GCIP (not available in emulator)',
    );

    test(
      'verifySessionCookie rejects invalid session cookie',
      () async {
        await expectLater(
          () => auth.verifySessionCookie('invalid-session-cookie'),
          throwsA(
            isA<FirebaseAuthAdminException>().having(
              (e) => e.code,
              'code',
              'auth/argument-error',
            ),
          ),
        );
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require GCIP (not available in emulator)',
    );
  });

  group('getUsers (Production)', () {
    late Auth auth;

    setUp(() {
      if (!hasGoogleEnv) return;
      auth = createProductionAuth();
    });

    test(
      'gets multiple users by different identifiers',
      () async {
        final user1 = await auth.createUser(
          CreateRequest(
            uid: _uid.v4(),
            email: 'user1-${_uid.v4()}@example.com',
          ),
        );
        final user2 = await auth.createUser(
          CreateRequest(
            uid: _uid.v4(),
            phoneNumber:
                '+1${DateTime.now().millisecondsSinceEpoch % 10000000000}',
          ),
        );

        final result = await auth.getUsers([
          UidIdentifier(uid: user1.uid),
          EmailIdentifier(email: user1.email!),
          UidIdentifier(uid: user2.uid),
        ]);

        expect(result.users.length, greaterThanOrEqualTo(2));
        expect(result.users.map((u) => u.uid), contains(user1.uid));
        expect(result.users.map((u) => u.uid), contains(user2.uid));
      },
      skip: hasGoogleEnv
          ? false
          : 'getUsers not fully supported in Firebase Auth Emulator',
    );

    test(
      'reports not found users',
      () async {
        final user1 = await auth.createUser(CreateRequest(uid: _uid.v4()));

        final result = await auth.getUsers([
          UidIdentifier(uid: user1.uid),
          UidIdentifier(uid: 'non-existent-uid'),
          EmailIdentifier(email: 'nonexistent@example.com'),
        ]);

        expect(result.users, isNotEmpty);
        expect(result.users.map((u) => u.uid), contains(user1.uid));
        expect(result.notFound, isNotEmpty);
      },
      skip: hasGoogleEnv
          ? false
          : 'getUsers not fully supported in Firebase Auth Emulator',
    );
  });

  group('createProviderConfig (Production)', () {
    late Auth auth;

    setUp(() {
      if (!hasGoogleEnv) return;
      auth = createProductionAuth();
    });

    test(
      'creates OIDC provider config successfully',
      () async {
        final oidcConfig = OIDCAuthProviderConfig(
          providerId: 'oidc.test-provider',
          displayName: 'Test OIDC Provider',
          enabled: true,
          clientId: 'TEST_CLIENT_ID',
          issuer: 'https://oidc.example.com/issuer',
          clientSecret: 'TEST_CLIENT_SECRET',
        );

        final createdConfig = await auth.createProviderConfig(oidcConfig);

        expect(createdConfig, isA<OIDCAuthProviderConfig>());
        expect(createdConfig.providerId, equals('oidc.test-provider'));
        expect(createdConfig.displayName, equals('Test OIDC Provider'));
        expect(createdConfig.enabled, isTrue);

        await auth.deleteProviderConfig('oidc.test-provider');
      },
      skip: hasGoogleEnv
          ? false
          : 'Provider configs require GCIP (not available in emulator)',
    );

    test(
      'creates SAML provider config successfully',
      () async {
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

        final createdConfig = await auth.createProviderConfig(samlConfig);

        expect(createdConfig, isA<SAMLAuthProviderConfig>());
        expect(createdConfig.providerId, equals('saml.test-provider'));
        expect(createdConfig.displayName, equals('Test SAML Provider'));
        expect(createdConfig.enabled, isTrue);

        await auth.deleteProviderConfig('saml.test-provider');
      },
      skip: hasGoogleEnv
          ? false
          : 'Provider configs require GCIP (not available in emulator)',
    );
  });
}
