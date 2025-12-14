import 'dart:convert';
import 'dart:io';
import 'package:dart_firebase_admin/auth.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import '../google_cloud_firestore/util/helpers.dart';
import '../mock.dart';

Future<ProcessResult> run(
  String executable,
  List<String> arguments, {
  String? workDir,
}) async {
  final process = await Process.run(
    executable,
    arguments,
    stdoutEncoding: utf8,
    workingDirectory: workDir,
  );

  if (process.exitCode != 0) {
    throw Exception(process.stderr);
  }

  return process;
}

Future<void> npmInstall({String? workDir}) async =>
    run('npm', ['install'], workDir: workDir);

/// Run test/client/get_id_token.js
Future<String> getIdToken() async {
  final path = p.join(Directory.current.path, 'test', 'client');

  await npmInstall(workDir: path);

  final process = await run('node', ['get_id_token.js'], workDir: path);

  return (process.stdout as String).trim();
}

void main() {
  late Auth auth;

  setUp(() {
    final sdk = createApp();
    auth = Auth(sdk);
  });

  setUpAll(registerFallbacks);

  group('FirebaseAuth', () {
    group('verifyIdToken', () {
      test(
        'verifies ID token from Firebase Auth production',
        () async {
          final app = createApp();
          final authProd = Auth(app);

          final token = await getIdToken();
          final decodedToken = await authProd.verifyIdToken(token);

          expect(decodedToken.aud, 'dart-firebase-admin');
          expect(decodedToken.uid, 'TmpgnnHo3JRjzQZjgBaYzQDyyZi2');
          expect(decodedToken.sub, 'TmpgnnHo3JRjzQZjgBaYzQDyyZi2');
          expect(decodedToken.email, 'foo@google.com');
          expect(decodedToken.emailVerified, false);
          expect(decodedToken.phoneNumber, isNull);
          expect(decodedToken.firebase.identities, {
            'email': ['foo@google.com'],
          });
          expect(decodedToken.firebase.signInProvider, 'password');
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires production mode but runs with emulator auto-detection',
      );
    });

    group('Email Action Links', () {
      group('generatePasswordResetLink', () {
        test('generates link without ActionCodeSettings', () async {
          final clientMock = ClientMock();
          when(() => clientMock.send(any())).thenAnswer(
            (_) => Future.value(
              StreamedResponse(
                Stream.value(
                  utf8.encode(
                    jsonEncode({
                      'oobLink': 'https://example.com/reset?oobCode=ABC123',
                    }),
                  ),
                ),
                200,
                headers: {'content-type': 'application/json'},
              ),
            ),
          );

          final app = createApp(client: clientMock, name: 'test-reset-link');
          final testAuth = Auth(app);

          final link = await testAuth.generatePasswordResetLink(
            'test@example.com',
          );

          expect(link, equals('https://example.com/reset?oobCode=ABC123'));
        });

        test('validates email is required', () async {
          expect(
            () => auth.generatePasswordResetLink(''),
            throwsA(isA<FirebaseAuthAdminException>()),
          );
        });

        test('validates ActionCodeSettings.url is a valid URI', () async {
          final actionCodeSettings = ActionCodeSettings(url: 'not a valid url');

          expect(
            () => auth.generatePasswordResetLink(
              'test@example.com',
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
          final actionCodeSettings = ActionCodeSettings(
            url: 'https://example.com',
            linkDomain: '', // Empty string should fail
          );

          expect(
            () => auth.generatePasswordResetLink(
              'test@example.com',
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

        test('generates link with linkDomain (new property)', () async {
          final clientMock = ClientMock();

          when(() => clientMock.send(any())).thenAnswer((_) {
            return Future.value(
              StreamedResponse(
                Stream.value(
                  utf8.encode(
                    jsonEncode({
                      'oobLink': 'https://example.com/reset?oobCode=ABC123',
                    }),
                  ),
                ),
                200,
                headers: {'content-type': 'application/json'},
              ),
            );
          });

          final app = createApp(
            client: clientMock,
            name: 'test-reset-link-with-linkdomain',
          );
          final testAuth = Auth(app);

          final actionCodeSettings = ActionCodeSettings(
            url: 'https://myapp.example.com/finishReset',
            linkDomain: 'myapp.page.link', // Using new linkDomain property
          );

          final link = await testAuth.generatePasswordResetLink(
            'test@example.com',
            actionCodeSettings: actionCodeSettings,
          );

          expect(link, equals('https://example.com/reset?oobCode=ABC123'));

          // Verify that send was called (meaning ActionCodeSettings was processed)
          verify(() => clientMock.send(any())).called(1);
        });
      });

      group('generateEmailVerificationLink', () {
        test('generates link with linkDomain (new property)', () async {
          final clientMock = ClientMock();

          when(() => clientMock.send(any())).thenAnswer((_) {
            return Future.value(
              StreamedResponse(
                Stream.value(
                  utf8.encode(
                    jsonEncode({
                      'oobLink': 'https://example.com/verify?oobCode=XYZ789',
                    }),
                  ),
                ),
                200,
                headers: {'content-type': 'application/json'},
              ),
            );
          });

          final app = createApp(
            client: clientMock,
            name: 'test-verify-link-with-linkdomain',
          );
          final testAuth = Auth(app);

          final actionCodeSettings = ActionCodeSettings(
            url: 'https://myapp.example.com/finishVerification',
            linkDomain: 'myapp.page.link',
          );

          final link = await testAuth.generateEmailVerificationLink(
            'test@example.com',
            actionCodeSettings: actionCodeSettings,
          );

          expect(link, equals('https://example.com/verify?oobCode=XYZ789'));
          verify(() => clientMock.send(any())).called(1);
        });

        test('validates email is required', () async {
          expect(
            () => auth.generateEmailVerificationLink(''),
            throwsA(isA<FirebaseAuthAdminException>()),
          );
        });

        test('validates ActionCodeSettings.url is a valid URI', () async {
          final actionCodeSettings = ActionCodeSettings(url: 'not a valid url');

          expect(
            () => auth.generateEmailVerificationLink(
              'test@example.com',
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
          final actionCodeSettings = ActionCodeSettings(
            url: 'https://example.com',
            linkDomain: '',
          );

          expect(
            () => auth.generateEmailVerificationLink(
              'test@example.com',
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

      group('generateSignInWithEmailLink', () {
        test('generates link without ActionCodeSettings', () async {
          final clientMock = ClientMock();

          when(() => clientMock.send(any())).thenAnswer((_) {
            return Future.value(
              StreamedResponse(
                Stream.value(
                  utf8.encode(
                    jsonEncode({
                      'oobLink': 'https://example.com/signin?oobCode=DEF456',
                    }),
                  ),
                ),
                200,
                headers: {'content-type': 'application/json'},
              ),
            );
          });

          final app = createApp(client: clientMock, name: 'test-signin-link');
          final testAuth = Auth(app);

          final actionCodeSettings = ActionCodeSettings(
            url: 'https://myapp.example.com/finishSignIn',
            handleCodeInApp: true,
          );

          final link = await testAuth.generateSignInWithEmailLink(
            'test@example.com',
            actionCodeSettings,
          );

          expect(link, equals('https://example.com/signin?oobCode=DEF456'));
          verify(() => clientMock.send(any())).called(1);
        });

        test('generates link with linkDomain (new property)', () async {
          final clientMock = ClientMock();

          when(() => clientMock.send(any())).thenAnswer((_) {
            return Future.value(
              StreamedResponse(
                Stream.value(
                  utf8.encode(
                    jsonEncode({
                      'oobLink': 'https://example.com/signin?oobCode=DEF456',
                    }),
                  ),
                ),
                200,
                headers: {'content-type': 'application/json'},
              ),
            );
          });

          final app = createApp(
            client: clientMock,
            name: 'test-signin-link-with-linkdomain',
          );
          final testAuth = Auth(app);

          final actionCodeSettings = ActionCodeSettings(
            url: 'https://myapp.example.com/finishSignIn',
            handleCodeInApp: true,
            linkDomain: 'myapp.page.link',
          );

          final link = await testAuth.generateSignInWithEmailLink(
            'test@example.com',
            actionCodeSettings,
          );

          expect(link, equals('https://example.com/signin?oobCode=DEF456'));
          verify(() => clientMock.send(any())).called(1);
        });

        test('validates email is required', () async {
          final actionCodeSettings = ActionCodeSettings(
            url: 'https://example.com',
            handleCodeInApp: true,
          );

          expect(
            () => auth.generateSignInWithEmailLink('', actionCodeSettings),
            throwsA(isA<FirebaseAuthAdminException>()),
          );
        });
      });

      group('generateVerifyAndChangeEmailLink', () {
        test('generates link with ActionCodeSettings', () async {
          final clientMock = ClientMock();

          when(() => clientMock.send(any())).thenAnswer((_) {
            return Future.value(
              StreamedResponse(
                Stream.value(
                  utf8.encode(
                    jsonEncode({
                      'oobLink':
                          'https://example.com/changeEmail?oobCode=GHI789',
                    }),
                  ),
                ),
                200,
                headers: {'content-type': 'application/json'},
              ),
            );
          });

          final app = createApp(
            client: clientMock,
            name: 'test-change-email-link',
          );
          final testAuth = Auth(app);

          final actionCodeSettings = ActionCodeSettings(
            url: 'https://myapp.example.com/finishChangeEmail',
          );

          final link = await testAuth.generateVerifyAndChangeEmailLink(
            'old@example.com',
            'new@example.com',
            actionCodeSettings: actionCodeSettings,
          );

          expect(
            link,
            equals('https://example.com/changeEmail?oobCode=GHI789'),
          );
          verify(() => clientMock.send(any())).called(1);
        });

        test('generates link with linkDomain (new property)', () async {
          final clientMock = ClientMock();

          when(() => clientMock.send(any())).thenAnswer((_) {
            return Future.value(
              StreamedResponse(
                Stream.value(
                  utf8.encode(
                    jsonEncode({
                      'oobLink':
                          'https://example.com/changeEmail?oobCode=GHI789',
                    }),
                  ),
                ),
                200,
                headers: {'content-type': 'application/json'},
              ),
            );
          });

          final app = createApp(
            client: clientMock,
            name: 'test-change-email-link-with-linkdomain',
          );
          final testAuth = Auth(app);

          final actionCodeSettings = ActionCodeSettings(
            url: 'https://myapp.example.com/finishChangeEmail',
            linkDomain: 'myapp.page.link',
          );

          final link = await testAuth.generateVerifyAndChangeEmailLink(
            'old@example.com',
            'new@example.com',
            actionCodeSettings: actionCodeSettings,
          );

          expect(
            link,
            equals('https://example.com/changeEmail?oobCode=GHI789'),
          );
          verify(() => clientMock.send(any())).called(1);
        });

        test('validates email is required', () async {
          final actionCodeSettings = ActionCodeSettings(
            url: 'https://example.com',
          );

          expect(
            () => auth.generateVerifyAndChangeEmailLink(
              '',
              'new@example.com',
              actionCodeSettings: actionCodeSettings,
            ),
            throwsA(isA<FirebaseAuthAdminException>()),
          );
        });

        test('validates newEmail is required', () async {
          final actionCodeSettings = ActionCodeSettings(
            url: 'https://example.com',
          );

          expect(
            () => auth.generateVerifyAndChangeEmailLink(
              'old@example.com',
              '',
              actionCodeSettings: actionCodeSettings,
            ),
            throwsA(isA<FirebaseAuthAdminException>()),
          );
        });
      });
    });

    group('createCustomToken', () {
      test(
        'creates a valid JWT token',
        () async {
          final token = await auth.createCustomToken('test-uid');

          expect(token, isNotEmpty);
          expect(token, isA<String>());
          // Token should be in JWT format (3 parts separated by dots)
          expect(token.split('.').length, equals(3));
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GOOGLE_APPLICATION_CREDENTIALS for service account',
      );

      test(
        'creates token with developer claims',
        () async {
          final token = await auth.createCustomToken(
            'test-uid',
            developerClaims: {'admin': true, 'level': 5},
          );

          expect(token, isNotEmpty);
          expect(token, isA<String>());
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GOOGLE_APPLICATION_CREDENTIALS for service account',
      );

      test('throws when uid is empty', () async {
        expect(
          () => auth.createCustomToken(''),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });
    });

    group('setCustomUserClaims', () {
      test('sets custom claims for user', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(utf8.encode(jsonEncode({'localId': 'test-uid'}))),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-set-claims');
        final testAuth = Auth(app);

        await testAuth.setCustomUserClaims(
          'test-uid',
          customUserClaims: {'admin': true, 'role': 'editor'},
        );

        verify(() => clientMock.send(any())).called(1);
      });

      test('throws when uid is empty', () async {
        expect(
          () => auth.setCustomUserClaims(''),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });

      test('clears claims when null is passed', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(utf8.encode(jsonEncode({'localId': 'test-uid'}))),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-clear-claims');
        final testAuth = Auth(app);

        await testAuth.setCustomUserClaims('test-uid');

        verify(() => clientMock.send(any())).called(1);
      });
    });

    group('revokeRefreshTokens', () {
      test('revokes refresh tokens successfully', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({
                    'localId': 'test-uid',
                    'validSince':
                        '${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
                  }),
                ),
              ),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-revoke-tokens');
        final testAuth = Auth(app);

        await testAuth.revokeRefreshTokens('test-uid');

        verify(() => clientMock.send(any())).called(1);
      });

      test('throws when uid is empty', () async {
        expect(
          () => auth.revokeRefreshTokens(''),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });
    });

    group('deleteUser', () {
      test('deletes user successfully', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({'kind': 'identitytoolkit#DeleteAccountResponse'}),
                ),
              ),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-delete-user');
        final testAuth = Auth(app);

        await testAuth.deleteUser('test-uid');

        verify(() => clientMock.send(any())).called(1);
      });

      test('throws when uid is empty', () async {
        expect(
          () => auth.deleteUser(''),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });
    });

    group('deleteUsers', () {
      test('deletes multiple users successfully', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(utf8.encode(jsonEncode({'errors': <dynamic>[]}))),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-delete-users');
        final testAuth = Auth(app);

        final result = await testAuth.deleteUsers(['uid1', 'uid2', 'uid3']);

        expect(result.successCount, equals(3));
        expect(result.failureCount, equals(0));
        expect(result.errors, isEmpty);
        verify(() => clientMock.send(any())).called(1);
      });

      test('handles errors for some users', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({
                    'errors': [
                      {'index': 1, 'message': 'USER_NOT_FOUND'},
                    ],
                  }),
                ),
              ),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(
          client: clientMock,
          name: 'test-delete-users-errors',
        );
        final testAuth = Auth(app);

        final result = await testAuth.deleteUsers(['uid1', 'uid2', 'uid3']);

        expect(result.successCount, equals(2));
        expect(result.failureCount, equals(1));
        expect(result.errors, hasLength(1));
        verify(() => clientMock.send(any())).called(1);
      });

      test('handles empty array', () async {
        final result = await auth.deleteUsers([]);

        expect(result.successCount, equals(0));
        expect(result.failureCount, equals(0));
        expect(result.errors, isEmpty);
      });
    });

    group('listUsers', () {
      test('lists users successfully', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({
                    'users': [
                      {
                        'localId': 'uid1',
                        'email': 'user1@example.com',
                        'emailVerified': false,
                        'disabled': false,
                        'createdAt': '1234567890000',
                      },
                      {
                        'localId': 'uid2',
                        'email': 'user2@example.com',
                        'emailVerified': true,
                        'disabled': false,
                        'createdAt': '1234567890000',
                      },
                    ],
                    'nextPageToken': 'next-page-token',
                  }),
                ),
              ),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-list-users');
        final testAuth = Auth(app);

        final result = await testAuth.listUsers();

        expect(result.users, hasLength(2));
        expect(result.users[0].uid, equals('uid1'));
        expect(result.users[1].uid, equals('uid2'));
        expect(result.pageToken, equals('next-page-token'));
        verify(() => clientMock.send(any())).called(1);
      });

      test('supports pagination parameters', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(utf8.encode(jsonEncode({'users': <dynamic>[]}))),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(
          client: clientMock,
          name: 'test-list-users-pagination',
        );
        final testAuth = Auth(app);

        await testAuth.listUsers(maxResults: 10, pageToken: 'page-token');

        verify(() => clientMock.send(any())).called(1);
      });
    });

    group('getUsers', () {
      test('gets multiple users by identifiers', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({
                    'users': [
                      {
                        'localId': 'uid1',
                        'email': 'user1@example.com',
                        'emailVerified': false,
                        'disabled': false,
                        'createdAt': '1234567890000',
                      },
                      {
                        'localId': 'uid2',
                        'phoneNumber': '+1234567890',
                        'emailVerified': false,
                        'disabled': false,
                        'createdAt': '1234567890000',
                      },
                    ],
                  }),
                ),
              ),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-get-users');
        final testAuth = Auth(app);

        final result = await testAuth.getUsers([
          UidIdentifier(uid: 'uid1'),
          EmailIdentifier(email: 'user1@example.com'),
          UidIdentifier(uid: 'uid2'),
        ]);

        expect(result.users, hasLength(2));
        expect(result.users[0].uid, equals('uid1'));
        expect(result.users[1].uid, equals('uid2'));
        verify(() => clientMock.send(any())).called(1);
      });

      test('handles empty identifiers array', () async {
        final result = await auth.getUsers([]);

        expect(result.users, isEmpty);
        expect(result.notFound, isEmpty);
      });
    });

    group('createSessionCookie', () {
      test('creates session cookie successfully', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({'sessionCookie': 'session-cookie-string'}),
                ),
              ),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-session-cookie');
        final testAuth = Auth(app);

        final sessionCookie = await testAuth.createSessionCookie(
          'id-token',
          const SessionCookieOptions(
            expiresIn: 3600000,
          ), // 1 hour in milliseconds
        );

        expect(sessionCookie, equals('session-cookie-string'));
        verify(() => clientMock.send(any())).called(1);
      });

      test('throws when idToken is empty', () async {
        expect(
          () => auth.createSessionCookie(
            '',
            const SessionCookieOptions(expiresIn: 3600000),
          ),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });

      test('validates expiresIn duration - too short', () async {
        // expiresIn must be between 5 minutes (300000 ms) and 2 weeks (1209600000 ms)
        expect(
          () => auth.createSessionCookie(
            'id-token',
            const SessionCookieOptions(
              expiresIn: 60000,
            ), // 1 minute - too short
          ),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });

      test('validates expiresIn duration - too long', () async {
        // expiresIn must not exceed 2 weeks (1209600000 ms)
        expect(
          () => auth.createSessionCookie(
            'id-token',
            const SessionCookieOptions(
              expiresIn: 15 * 24 * 60 * 60 * 1000, // 15 days - too long
            ),
          ),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });

      test('validates expiresIn duration - minimum allowed', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({'sessionCookie': 'session-cookie-string'}),
                ),
              ),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-min-duration');
        final testAuth = Auth(app);

        // 5 minutes (300000 ms) is the minimum allowed
        final sessionCookie = await testAuth.createSessionCookie(
          'id-token',
          const SessionCookieOptions(expiresIn: 5 * 60 * 1000), // 5 minutes
        );

        expect(sessionCookie, equals('session-cookie-string'));
      });

      test('validates expiresIn duration - maximum allowed', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({'sessionCookie': 'session-cookie-string'}),
                ),
              ),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-max-duration');
        final testAuth = Auth(app);

        // 2 weeks (1209600000 ms) is the maximum allowed
        final sessionCookie = await testAuth.createSessionCookie(
          'id-token',
          const SessionCookieOptions(
            expiresIn: 14 * 24 * 60 * 60 * 1000, // 2 weeks
          ),
        );

        expect(sessionCookie, equals('session-cookie-string'));
      });

      test('handles backend error', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({
                    'error': {'code': 400, 'message': 'INVALID_ID_TOKEN'},
                  }),
                ),
              ),
              400,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-backend-error');
        final testAuth = Auth(app);

        await expectLater(
          () => testAuth.createSessionCookie(
            'invalid-id-token',
            const SessionCookieOptions(expiresIn: 3600000),
          ),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });
    });

    group('createProviderConfig', () {
      test('throws when provider ID is invalid', () async {
        // Provider ID must start with "oidc." or "saml."
        final invalidConfig = OIDCAuthProviderConfig(
          providerId: 'unsupported',
          displayName: 'OIDC provider',
          enabled: true,
          clientId: 'CLIENT_ID',
          issuer: 'https://oidc.com/issuer',
        );

        await expectLater(
          auth.createProviderConfig(invalidConfig),
          throwsA(
            isA<FirebaseAuthAdminException>().having(
              (e) => e.code,
              'code',
              'auth/invalid-provider-id',
            ),
          ),
        );
      });

      test('creates OIDC provider config successfully', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({
                    'name': 'projects/project_id/oauthIdpConfigs/oidc.provider',
                    'displayName': 'OIDC_DISPLAY_NAME',
                    'enabled': true,
                    'clientId': 'CLIENT_ID',
                    'issuer': 'https://oidc.com/issuer',
                    'clientSecret': 'CLIENT_SECRET',
                  }),
                ),
              ),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-create-oidc');
        final testAuth = Auth(app);

        final config = await testAuth.createProviderConfig(
          OIDCAuthProviderConfig(
            providerId: 'oidc.provider',
            displayName: 'OIDC_DISPLAY_NAME',
            enabled: true,
            clientId: 'CLIENT_ID',
            issuer: 'https://oidc.com/issuer',
            clientSecret: 'CLIENT_SECRET',
          ),
        );

        expect(config, isA<OIDCAuthProviderConfig>());
        expect(config.providerId, equals('oidc.provider'));
        expect(config.displayName, equals('OIDC_DISPLAY_NAME'));
        expect(config.enabled, isTrue);
        verify(() => clientMock.send(any())).called(1);
      });

      test('creates SAML provider config successfully', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({
                    'name':
                        'projects/project_id/inboundSamlConfigs/saml.provider',
                    'idpConfig': {
                      'idpEntityId': 'IDP_ENTITY_ID',
                      'ssoUrl': 'https://example.com/login',
                      'idpCertificates': [
                        {'x509Certificate': 'CERT1'},
                        {'x509Certificate': 'CERT2'},
                      ],
                    },
                    'spConfig': {
                      'spEntityId': 'RP_ENTITY_ID',
                      'callbackUri':
                          'https://project-id.firebaseapp.com/__/auth/handler',
                    },
                    'displayName': 'SAML_DISPLAY_NAME',
                    'enabled': true,
                  }),
                ),
              ),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        final app = createApp(client: clientMock, name: 'test-create-saml');
        final testAuth = Auth(app);

        final config = await testAuth.createProviderConfig(
          SAMLAuthProviderConfig(
            providerId: 'saml.provider',
            displayName: 'SAML_DISPLAY_NAME',
            enabled: true,
            idpEntityId: 'IDP_ENTITY_ID',
            ssoURL: 'https://example.com/login',
            x509Certificates: ['CERT1', 'CERT2'],
            rpEntityId: 'RP_ENTITY_ID',
            callbackURL: 'https://project-id.firebaseapp.com/__/auth/handler',
          ),
        );

        expect(config, isA<SAMLAuthProviderConfig>());
        expect(config.providerId, equals('saml.provider'));
        expect(config.displayName, equals('SAML_DISPLAY_NAME'));
        expect(config.enabled, isTrue);
        verify(() => clientMock.send(any())).called(1);
      });
    });

    group('verifySessionCookie', () {
      test(
        'verifies valid session cookie',
        () async {
          // Note: This requires a real session cookie which requires client SDK
          // We would need to mock the token verification process
          // Skipping detailed implementation for now
        },
        skip: 'Requires complex token verification mocking',
      );
    });
  });
}
