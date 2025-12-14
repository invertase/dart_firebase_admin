// Firebase Auth Integration Tests
//
// SAFETY: These tests require Firebase Auth Emulator by default to prevent
// accidental writes to production. Tests are organized as follows:
//
// 1. **Emulator-Safe Tests** (default):
//    - Use the global `auth` instance from main setUp()
//    - Automatically require FIREBASE_AUTH_EMULATOR_HOST to be set
//    - Safe to run without production credentials
//
// 2. **Production-Only Tests**:
//    - Marked with "(Production)" suffix in group names
//    - Have their own setUp() using createAuthForTest(requireEmulator: false)
//    - Only run when GOOGLE_APPLICATION_CREDENTIALS is set (hasGoogleEnv)
//    - Examples: Session Cookies, getUsers, Provider Configs, etc.
//    - These tests require features not available in emulator (GCIP, etc.)
//
// To run emulator tests:
//   FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 dart test
//
// To run production tests:
//   GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json dart test

import 'dart:convert';

import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:googleapis/identitytoolkit/v1.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../google_cloud_firestore/util/helpers.dart';
import '../mock.dart';

const _uid = Uuid();

void main() {
  late Auth auth;

  setUp(() {
    // By default, require emulator to prevent accidental production writes
    // Production-only tests should override this in their own setUp
    auth = createAuthForTest();
  });

  setUpAll(registerFallbacks);

  group('Error handling', () {
    for (final MapEntry(key: messagingError, value: code)
        in authServerToClientCode.entries) {
      test('converts $messagingError error codes', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({
                    'error': {'message': messagingError},
                  }),
                ),
              ),
              400,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        // Use unique app name so we get a new app with the mock client
        final app = createApp(client: clientMock, name: 'test-$messagingError');
        final handler = Auth(app);

        await expectLater(
          () => handler.getUser('123'),
          throwsA(
            isA<FirebaseAuthAdminException>()
                .having((e) => e.errorCode, 'errorCode', code)
                .having((e) => e.code, 'code', 'auth/${code.code}'),
          ),
        );
      });
    }
  });

  group('createUser', () {
    test('supports no specified uid', () async {
      final user = await auth.createUser(
        CreateRequest(email: 'example@gmail.com'),
      );

      expect(user.uid, isNotEmpty);
      expect(user.email, 'example@gmail.com');
    });

    test('supports specifying uid', () async {
      final user = await auth.createUser(
        CreateRequest(email: 'example@gmail.com', uid: '42'),
      );

      expect(user.uid, '42');
      expect(user.email, 'example@gmail.com');
    });

    test('supports users with enrolled second factors', () async {
      const phoneNumber = '+16505550002';

      final user = await auth.createUser(
        CreateRequest(
          email: 'example@gmail.com',
          multiFactor: MultiFactorCreateSettings(
            enrolledFactors: [
              CreatePhoneMultiFactorInfoRequest(
                displayName: 'home phone',
                phoneNumber: phoneNumber,
              ),
            ],
          ),
        ),
      );

      expect(user.email, 'example@gmail.com');
      expect(user.multiFactor?.enrolledFactors, hasLength(1));
      expect(
        user.multiFactor?.enrolledFactors.cast<PhoneMultiFactorInfo>().map(
          (e) => (e.phoneNumber, e.displayName),
        ),
        [(phoneNumber, 'home phone')],
      );
    });

    test('Fails when uid is already in use', () async {
      final user = await auth.createUser(
        CreateRequest(email: 'example@gmail.com'),
      );

      final user2 = auth.createUser(
        CreateRequest(uid: user.uid, email: 'user2@gmail.com'),
      );

      expect(
        user2,
        throwsA(
          isA<FirebaseAuthAdminException>().having(
            (e) => e.errorCode,
            'errorCode',
            AuthClientErrorCode.uidAlreadyExists,
          ),
        ),
      );
    });
  });

  test('getUserByEmail', () async {
    final user = await auth.createUser(
      CreateRequest(email: 'example@gmail.com'),
    );

    final user2 = await auth.getUserByEmail(user.email!);

    expect(user2.uid, user.uid);
    expect(user2.email, user.email);
  });

  test('getUserByPhoneNumber', () async {
    const phoneNumber = '+16505550002';
    final user = await auth.createUser(CreateRequest(phoneNumber: phoneNumber));

    final user2 = await auth.getUserByPhoneNumber(user.phoneNumber!);

    expect(user2.uid, user.uid);
    expect(user2.phoneNumber, user.phoneNumber);
  });

  group('getUserByProviderUid', () {
    test('works', () async {
      final importUser = UserImportRecord(
        uid: 'import_${_uid.v4()}',
        email: 'user@example.com',
        phoneNumber: '+15555550000',
        providerData: [
          UserProviderRequest(
            displayName: 'User Name',
            email: 'user@example.com',
            phoneNumber: '+15555550000',
            photoURL: 'http://example.com/user',
            providerId: 'google.com',
            uid: 'google_uid',
          ),
        ],
      );

      await auth.importUsers([importUser]);

      final user = await auth.getUserByProviderUid(
        providerId: 'google.com',
        uid: 'google_uid',
      );

      expect(user.uid, importUser.uid);
    });
  });

  group('updateUser', () {
    test('supports updating email', () async {
      final user = await auth.createUser(
        CreateRequest(email: 'testuser@example.com'),
      );

      final updatedUser = await auth.updateUser(
        user.uid,
        UpdateRequest(email: 'updateduser@example.com'),
      );

      expect(updatedUser.email, equals('updateduser@example.com'));

      final user2 = await auth.getUserByEmail(updatedUser.email!);
      expect(user2.uid, equals(user.uid));
    });
  });

  group('Email Action Links Integration', () {
    group('generatePasswordResetLink', () {
      test(
        'generates password reset link without ActionCodeSettings',
        () async {
          // Create a test user first
          final user = await auth.createUser(
            CreateRequest(email: 'reset-test@example.com'),
          );

          final link = await auth.generatePasswordResetLink(user.email!);

          expect(link, isNotEmpty);
          expect(link, contains('oobCode='));
          expect(link, contains('mode=resetPassword'));
        },
      );

      test('generates password reset link with ActionCodeSettings', () async {
        // Create a test user first
        final user = await auth.createUser(
          CreateRequest(email: 'reset-settings-test@example.com'),
        );

        final actionCodeSettings = ActionCodeSettings(
          url: 'https://example.com/finishReset',
          handleCodeInApp: false,
        );

        final link = await auth.generatePasswordResetLink(
          user.email!,
          actionCodeSettings: actionCodeSettings,
        );

        expect(link, isNotEmpty);
        expect(link, contains('oobCode='));
        expect(link, contains('mode=resetPassword'));
        expect(link, contains('continueUrl='));
      });

      test(
        'generates password reset link with ActionCodeSettings including linkDomain (new property)',
        () async {
          // Create a test user first
          final user = await auth.createUser(
            CreateRequest(email: 'reset-linkdomain-test@example.com'),
          );

          final actionCodeSettings = ActionCodeSettings(
            url: 'https://example.com/finishReset',
            handleCodeInApp: true,
            linkDomain: 'example.page.link', // Using new linkDomain property
          );

          final link = await auth.generatePasswordResetLink(
            user.email!,
            actionCodeSettings: actionCodeSettings,
          );

          expect(link, isNotEmpty);
          expect(link, contains('oobCode='));
          expect(link, contains('mode=resetPassword'));
        },
      );
    });

    group('generateEmailVerificationLink', () {
      test(
        'generates email verification link without ActionCodeSettings',
        () async {
          // Create a test user first
          final user = await auth.createUser(
            CreateRequest(email: 'verify-test@example.com'),
          );

          final link = await auth.generateEmailVerificationLink(user.email!);

          expect(link, isNotEmpty);
          expect(link, contains('oobCode='));
          expect(link, contains('mode=verifyEmail'));
        },
      );

      test(
        'generates email verification link with ActionCodeSettings',
        () async {
          // Create a test user first
          final user = await auth.createUser(
            CreateRequest(email: 'verify-settings-test@example.com'),
          );

          final actionCodeSettings = ActionCodeSettings(
            url: 'https://example.com/finishVerification',
          );

          final link = await auth.generateEmailVerificationLink(
            user.email!,
            actionCodeSettings: actionCodeSettings,
          );

          expect(link, isNotEmpty);
          expect(link, contains('oobCode='));
          expect(link, contains('mode=verifyEmail'));
        },
      );
    });

    group('generateSignInWithEmailLink', () {
      test('generates sign-in with email link', () async {
        final actionCodeSettings = ActionCodeSettings(
          url: 'https://example.com/finishSignIn',
          handleCodeInApp: true,
        );

        final link = await auth.generateSignInWithEmailLink(
          'signin-test@example.com',
          actionCodeSettings,
        );

        expect(link, isNotEmpty);
        expect(link, contains('oobCode='));
        expect(link, contains('mode=signIn'));
      });

      test('validates ActionCodeSettings.url is a valid URI', () async {
        final actionCodeSettings = ActionCodeSettings(
          url: 'not a valid url',
          handleCodeInApp: true,
        );

        expect(
          () => auth.generateSignInWithEmailLink(
            'test@example.com',
            actionCodeSettings,
          ),
          throwsA(
            isA<FirebaseAuthAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              AuthClientErrorCode.invalidContinueUri,
            ),
          ),
        );
      });

      test('validates ActionCodeSettings.linkDomain is not empty', () async {
        final actionCodeSettings = ActionCodeSettings(
          url: 'https://example.com',
          handleCodeInApp: true,
          linkDomain: '',
        );

        expect(
          () => auth.generateSignInWithEmailLink(
            'test@example.com',
            actionCodeSettings,
          ),
          throwsA(
            isA<FirebaseAuthAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              AuthClientErrorCode.invalidHostingLinkDomain,
            ),
          ),
        );
      });
    });

    group('generateVerifyAndChangeEmailLink', () {
      test(
        'generates verify and change email link without ActionCodeSettings',
        () async {
          final user = await auth.createUser(
            CreateRequest(email: 'change-email-test@example.com'),
          );

          final link = await auth.generateVerifyAndChangeEmailLink(
            user.email!,
            'newemail@example.com',
          );

          expect(link, isNotEmpty);
          expect(link, contains('oobCode='));
          expect(link, contains('mode=verifyAndChangeEmail'));
        },
      );

      test(
        'generates verify and change email link with ActionCodeSettings',
        () async {
          final user = await auth.createUser(
            CreateRequest(email: 'change-email-settings-test@example.com'),
          );

          final actionCodeSettings = ActionCodeSettings(
            url: 'https://example.com/finishChangeEmail',
          );

          final link = await auth.generateVerifyAndChangeEmailLink(
            user.email!,
            'newemail2@example.com',
            actionCodeSettings: actionCodeSettings,
          );

          expect(link, isNotEmpty);
          expect(link, contains('oobCode='));
          expect(link, contains('mode=verifyAndChangeEmail'));
        },
      );

      test('generates verify and change email link with linkDomain', () async {
        final user = await auth.createUser(
          CreateRequest(email: 'change-email-linkdomain-test@example.com'),
        );

        final actionCodeSettings = ActionCodeSettings(
          url: 'https://example.com/finishChangeEmail',
          linkDomain: 'example.page.link',
        );

        final link = await auth.generateVerifyAndChangeEmailLink(
          user.email!,
          'newemail3@example.com',
          actionCodeSettings: actionCodeSettings,
        );

        expect(link, isNotEmpty);
        expect(link, contains('oobCode='));
        expect(link, contains('mode=verifyAndChangeEmail'));
      });

      test('validates ActionCodeSettings.url is a valid URI', () async {
        final user = await auth.createUser(
          CreateRequest(email: 'change-email-validation-test@example.com'),
        );

        final actionCodeSettings = ActionCodeSettings(url: 'not a valid url');

        expect(
          () => auth.generateVerifyAndChangeEmailLink(
            user.email!,
            'new@example.com',
            actionCodeSettings: actionCodeSettings,
          ),
          throwsA(
            isA<FirebaseAuthAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              AuthClientErrorCode.invalidContinueUri,
            ),
          ),
        );
      });

      test('validates ActionCodeSettings.linkDomain is not empty', () async {
        final user = await auth.createUser(
          CreateRequest(email: 'change-email-validation3-test@example.com'),
        );

        final actionCodeSettings = ActionCodeSettings(
          url: 'https://example.com',
          linkDomain: '',
        );

        expect(
          () => auth.generateVerifyAndChangeEmailLink(
            user.email!,
            'new@example.com',
            actionCodeSettings: actionCodeSettings,
          ),
          throwsA(
            isA<FirebaseAuthAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              AuthClientErrorCode.invalidHostingLinkDomain,
            ),
          ),
        );
      });
    });
  });

  group('createCustomToken', () {
    test('creates custom token and verifies it works', () async {
      final user = await auth.createUser(CreateRequest(uid: _uid.v4()));

      final customToken = await auth.createCustomToken(user.uid);

      expect(customToken, isNotEmpty);
      expect(customToken, isA<String>());
    });

    test('creates custom token with developer claims', () async {
      final user = await auth.createUser(CreateRequest(uid: _uid.v4()));

      final customToken = await auth.createCustomToken(
        user.uid,
        developerClaims: {'role': 'admin', 'level': 5},
      );

      expect(customToken, isNotEmpty);
      expect(customToken, isA<String>());
    });
  });

  group('setCustomUserClaims', () {
    test('sets and retrieves custom claims', () async {
      final user = await auth.createUser(CreateRequest(uid: _uid.v4()));

      await auth.setCustomUserClaims(
        user.uid,
        customUserClaims: {'role': 'admin', 'level': 5},
      );

      final updatedUser = await auth.getUser(user.uid);
      expect(updatedUser.customClaims, isNotNull);
      expect(updatedUser.customClaims!['role'], equals('admin'));
      expect(updatedUser.customClaims!['level'], equals(5));
    });
  });

  group('setCustomUserClaims (Production)', () {
    late Auth prodAuth;

    setUp(() {
      // This test requires production - emulator returns {} instead of null
      if (!hasGoogleEnv) return;
      prodAuth = createAuthForTest(requireEmulator: false);
    });

    tearDown(() async {
      if (hasGoogleEnv) {
        await cleanup(prodAuth);
      }
    });

    test(
      'clears custom claims when null is passed',
      () async {
        final user = await prodAuth.createUser(CreateRequest(uid: _uid.v4()));
        await prodAuth.setCustomUserClaims(
          user.uid,
          customUserClaims: {'role': 'admin'},
        );

        await prodAuth.setCustomUserClaims(user.uid);

        final updatedUser = await prodAuth.getUser(user.uid);
        expect(updatedUser.customClaims, isNull);
      },
      skip: hasGoogleEnv
          ? false
          : 'Emulator returns {} instead of null when claims are cleared',
    );
  });

  group('revokeRefreshTokens', () {
    test('revokes tokens and updates tokensValidAfterTime', () async {
      final user = await auth.createUser(CreateRequest(uid: _uid.v4()));
      final beforeRevoke = await auth.getUser(user.uid);

      await auth.revokeRefreshTokens(user.uid);

      final afterRevoke = await auth.getUser(user.uid);
      expect(afterRevoke.tokensValidAfterTime, isNotNull);
      // tokensValidAfterTime should be updated after revocation
      if (beforeRevoke.tokensValidAfterTime != null) {
        expect(
          afterRevoke.tokensValidAfterTime!.isAfter(
            beforeRevoke.tokensValidAfterTime!,
          ),
          isTrue,
        );
      }
    });
  });

  group('Session Cookies (Production)', () {
    late Auth sessionCookieAuth;

    setUp(() {
      // Session cookies require production (GCIP) - emulator doesn't support them
      // Only run these tests if GOOGLE_APPLICATION_CREDENTIALS is set
      if (!hasGoogleEnv) {
        return; // Skip setup, tests will be skipped anyway
      }
      sessionCookieAuth = createAuthForTest(requireEmulator: false);
    });

    tearDown(() async {
      if (hasGoogleEnv) {
        await cleanup(sessionCookieAuth);
      }
    });

    // Helper function to exchange custom token for ID token using Firebase Auth API
    Future<String> getIdTokenFromCustomToken(String customToken) async {
      // Use the authenticated client from the app
      final client = await sessionCookieAuth.app.client;
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
        final user = await sessionCookieAuth.createUser(
          CreateRequest(uid: _uid.v4()),
        );

        // Step 1: Create custom token
        final customToken = await sessionCookieAuth.createCustomToken(user.uid);

        // Step 2: Exchange custom token for ID token (using Firebase Auth REST API)
        final idToken = await getIdTokenFromCustomToken(customToken);

        // Step 3: Create session cookie from ID token
        const expiresIn = 24 * 60 * 60 * 1000; // 24 hours in milliseconds
        final sessionCookie = await sessionCookieAuth.createSessionCookie(
          idToken,
          const SessionCookieOptions(expiresIn: expiresIn),
        );

        expect(sessionCookie, isNotEmpty);
        expect(sessionCookie, isA<String>());

        // Step 4: Verify session cookie
        final decodedToken = await sessionCookieAuth.verifySessionCookie(
          sessionCookie,
        );
        expect(decodedToken.uid, equals(user.uid));

        // Verify issuer changed from securetoken to session
        expect(decodedToken.iss, contains('session.firebase.google.com'));

        // Verify expiration time is approximately 24 hours from now
        final expectedExp = DateTime.now().add(const Duration(hours: 24));
        final actualExp = DateTime.fromMillisecondsSinceEpoch(
          decodedToken.exp * 1000,
        );
        expect(
          actualExp.difference(expectedExp).abs().inMinutes,
          lessThan(5), // Allow 5 minutes variance
        );
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require Google Cloud Identity Platform (not available in emulator)',
    );

    test(
      'creates a revocable session cookie',
      () async {
        final user = await sessionCookieAuth.createUser(
          CreateRequest(uid: _uid.v4()),
        );

        // Create custom token and exchange for ID token
        final customToken = await sessionCookieAuth.createCustomToken(user.uid);
        final idToken = await getIdTokenFromCustomToken(customToken);

        // Create session cookie
        const expiresIn = 24 * 60 * 60 * 1000;
        final sessionCookie = await sessionCookieAuth.createSessionCookie(
          idToken,
          const SessionCookieOptions(expiresIn: expiresIn),
        );

        // Verify it works initially
        final decodedToken = await sessionCookieAuth.verifySessionCookie(
          sessionCookie,
        );
        expect(decodedToken.uid, equals(user.uid));

        // Wait a moment for token validity timestamp to update
        await Future<void>.delayed(const Duration(seconds: 2));

        // Revoke refresh tokens
        await sessionCookieAuth.revokeRefreshTokens(user.uid);

        // verifySessionCookie without checkRevoked should still succeed
        await sessionCookieAuth.verifySessionCookie(sessionCookie);

        // verifySessionCookie with checkRevoked=true should fail
        await expectLater(
          () => sessionCookieAuth.verifySessionCookie(
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
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require Google Cloud Identity Platform (not available in emulator)',
    );

    test(
      'fails when ID token is revoked',
      () async {
        final user = await sessionCookieAuth.createUser(
          CreateRequest(uid: _uid.v4()),
        );

        // Create custom token and exchange for ID token
        final customToken = await sessionCookieAuth.createCustomToken(user.uid);
        final idToken = await getIdTokenFromCustomToken(customToken);

        // Revoke refresh tokens
        await Future<void>.delayed(const Duration(seconds: 2));
        await sessionCookieAuth.revokeRefreshTokens(user.uid);

        // Attempt to create session cookie should fail
        const expiresIn = 24 * 60 * 60 * 1000;
        await expectLater(
          () => sessionCookieAuth.createSessionCookie(
            idToken,
            const SessionCookieOptions(expiresIn: expiresIn),
          ),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      },
      skip: hasGoogleEnv
          ? false
          : 'Session cookies require Google Cloud Identity Platform (not available in emulator)',
    );

    test('verifySessionCookie rejects invalid session cookie', () async {
      // verifySessionCookie should throw FirebaseAuthAdminException
      // with code 'auth/argument-error' for invalid tokens
      // This test works in both emulator and production
      final authInstance = hasGoogleEnv ? sessionCookieAuth : auth;

      await expectLater(
        () => authInstance.verifySessionCookie('invalid-session-cookie'),
        throwsA(
          isA<FirebaseAuthAdminException>().having(
            (e) => e.code,
            'code',
            'auth/argument-error',
          ),
        ),
      );
    });
  });

  group('deleteUser', () {
    test('deletes user and verifies deletion', () async {
      final user = await auth.createUser(CreateRequest(uid: _uid.v4()));

      await auth.deleteUser(user.uid);

      await expectLater(
        () => auth.getUser(user.uid),
        throwsA(isA<FirebaseAuthAdminException>()),
      );
    });
  });

  group('deleteUsers', () {
    test('deletes multiple users successfully', () async {
      final user1 = await auth.createUser(CreateRequest(uid: _uid.v4()));
      final user2 = await auth.createUser(CreateRequest(uid: _uid.v4()));
      final user3 = await auth.createUser(CreateRequest(uid: _uid.v4()));

      final result = await auth.deleteUsers([user1.uid, user2.uid, user3.uid]);

      expect(result.successCount, equals(3));
      expect(result.failureCount, equals(0));
      expect(result.errors, isEmpty);
    });

    test('reports errors for non-existent users', () async {
      final user1 = await auth.createUser(CreateRequest(uid: _uid.v4()));

      final result = await auth.deleteUsers([
        user1.uid,
        'non-existent-uid-1',
        'non-existent-uid-2',
      ]);

      // Emulator behavior may differ - it might succeed for non-existent users
      expect(result.successCount, greaterThanOrEqualTo(1));
      expect(result.successCount + result.failureCount, equals(3));
    });
  });

  group('listUsers', () {
    test('lists all users', () async {
      // Create some test users
      await auth.createUser(CreateRequest(uid: _uid.v4()));
      await auth.createUser(CreateRequest(uid: _uid.v4()));
      await auth.createUser(CreateRequest(uid: _uid.v4()));

      final result = await auth.listUsers();

      expect(result.users, isNotEmpty);
      expect(result.users.length, greaterThanOrEqualTo(3));
      expect(result.users, everyElement(isA<UserRecord>()));
    });

    test('supports pagination with maxResults', () async {
      // Create several users
      for (var i = 0; i < 5; i++) {
        await auth.createUser(CreateRequest(uid: _uid.v4()));
      }

      final firstPage = await auth.listUsers(maxResults: 2);

      expect(firstPage.users.length, equals(2));
      if (firstPage.pageToken != null) {
        expect(firstPage.pageToken, isNotEmpty);
      }
    });

    test('supports pagination with pageToken', () async {
      // Create several users
      for (var i = 0; i < 5; i++) {
        await auth.createUser(CreateRequest(uid: _uid.v4()));
      }

      final firstPage = await auth.listUsers(maxResults: 2);

      if (firstPage.pageToken != null) {
        final secondPage = await auth.listUsers(
          maxResults: 2,
          pageToken: firstPage.pageToken,
        );

        expect(secondPage.users.length, greaterThan(0));
        expect(
          secondPage.users.first.uid,
          isNot(equals(firstPage.users.first.uid)),
        );
      }
    });
  });

  group('getUsers (Production)', () {
    late Auth prodAuth;

    setUp(() {
      // getUsers not fully supported in Firebase Auth Emulator
      if (!hasGoogleEnv) return;
      prodAuth = createAuthForTest(requireEmulator: false);
    });

    tearDown(() async {
      if (hasGoogleEnv) {
        await cleanup(prodAuth);
      }
    });

    test(
      'gets multiple users by different identifiers',
      () async {
        final user1 = await prodAuth.createUser(
          CreateRequest(
            uid: _uid.v4(),
            email: 'user1-${_uid.v4()}@example.com',
          ),
        );
        final user2 = await prodAuth.createUser(
          CreateRequest(
            uid: _uid.v4(),
            phoneNumber:
                '+1${DateTime.now().millisecondsSinceEpoch % 10000000000}',
          ),
        );

        final result = await prodAuth.getUsers([
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
        final user1 = await prodAuth.createUser(CreateRequest(uid: _uid.v4()));

        final result = await prodAuth.getUsers([
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

  // TODO(demolaf): verify this locally first
  group('createProviderConfig (Production)', () {
    late Auth prodAuth;

    setUp(() {
      // Provider configs require GCIP - not available in emulator
      if (!hasGoogleEnv) return;
      prodAuth = createAuthForTest(requireEmulator: false);
    });

    tearDown(() async {
      if (hasGoogleEnv) {
        await cleanup(prodAuth);
      }
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

        final createdConfig = await prodAuth.createProviderConfig(oidcConfig);

        expect(createdConfig, isA<OIDCAuthProviderConfig>());
        expect(createdConfig.providerId, equals('oidc.test-provider'));
        expect(createdConfig.displayName, equals('Test OIDC Provider'));
        expect(createdConfig.enabled, isTrue);

        // Clean up
        await prodAuth.deleteProviderConfig('oidc.test-provider');
      },
      skip: hasGoogleEnv
          ? false
          : 'Provider configs require Google Cloud Identity Platform (GCIP) which is not available in Firebase Auth Emulator',
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

        final createdConfig = await prodAuth.createProviderConfig(samlConfig);

        expect(createdConfig, isA<SAMLAuthProviderConfig>());
        expect(createdConfig.providerId, equals('saml.test-provider'));
        expect(createdConfig.displayName, equals('Test SAML Provider'));
        expect(createdConfig.enabled, isTrue);

        // Clean up
        await prodAuth.deleteProviderConfig('saml.test-provider');
      },
      skip: hasGoogleEnv
          ? false
          : 'Provider configs require Google Cloud Identity Platform (GCIP) which is not available in Firebase Auth Emulator',
    );
  });
}

Future<void> cleanup(Auth auth) async {
  // Only cleanup if we're using the emulator
  // Mock clients used in error handling tests won't have the emulator enabled
  if (!Environment.isAuthEmulatorEnabled()) {
    return; // Skip cleanup for non-emulator tests
  }

  try {
    final users = await auth.listUsers();
    await Future.wait([
      for (final user in users.users) auth.deleteUser(user.uid),
    ]);
  } catch (e) {
    // Ignore cleanup errors - they're not critical for test execution
  }
}

/// Creates an Auth instance for testing.
///
/// Automatically cleans up all users after each test.
///
/// By default, requires Firebase Auth Emulator to prevent accidental writes to production.
/// For tests that require production (e.g., session cookies with GCIP), set [requireEmulator] to false.
///
/// Note: Tests should be run with FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
/// environment variable set. The emulator will be auto-detected.
Auth createAuthForTest({bool requireEmulator = true}) {
  // CRITICAL: Ensure emulator is running to prevent hitting production
  // unless explicitly disabled for production-only tests
  if (requireEmulator && !Environment.isAuthEmulatorEnabled()) {
    throw StateError(
      '${Environment.firebaseAuthEmulatorHost} environment variable must be set to run tests. '
      'This prevents accidentally writing test data to production. '
      'Set it to "localhost:9099" or your emulator host.\n\n'
      'For production-only tests, use createAuthForTest(requireEmulator: false)',
    );
  }

  // Use unique app name for each test to avoid interference
  final appName = 'auth-test-${DateTime.now().microsecondsSinceEpoch}';

  final app = createApp(
    name: appName,
    tearDown: () async {
      // Cleanup will be handled by addTearDown below
    },
  );

  final auth = Auth(app);

  addTearDown(() async {
    await cleanup(auth);
  });

  return auth;
}
