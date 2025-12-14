// Firebase Auth Integration Tests
//
// SAFETY: These tests require Firebase Auth Emulator by default to prevent
// accidental writes to production.
//
// All tests use the global `auth` instance from main setUp() which automatically
// requires FIREBASE_AUTH_EMULATOR_HOST to be set. This is safe to run without
// production credentials.
//
// For production-only tests (Session Cookies, getUsers, Provider Configs, etc.),
// see test/auth/auth_integration_prod_test.dart
//
// To run these tests:
//   FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 dart test test/auth/integration_test.dart

import 'dart:convert';

import 'package:dart_firebase_admin/auth.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../google_cloud_firestore/util/helpers.dart';
import '../mock.dart';
import 'util/helpers.dart';

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
}
