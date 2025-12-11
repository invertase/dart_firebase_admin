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
  });
}
