import 'dart:convert';
import 'dart:io';

import 'package:dart_firebase_admin/auth.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';

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

Future<void> npmInstall({
  String? workDir,
}) async =>
    run('npm', ['install'], workDir: workDir);

/// Run test/client/get_id_token.js
Future<String> getIdToken() async {
  final path = p.join(
    Directory.current.path,
    'test',
    'client',
  );

  await npmInstall(workDir: path);

  final process = await run(
    'node',
    ['get_id_token.js'],
    workDir: path,
  );

  return (process.stdout as String).trim();
}

void main() {
  group('FirebaseAuth', () {
    group('verifyIdToken', () {
      test(
        'verifies ID token from Firebase Auth production',
        () async {
          final app = createApp();
          final auth = Auth(app);

          final token = await getIdToken();
          final decodedToken = await auth.verifyIdToken(token);

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
        skip: 'Requires production mode but runs with emulator auto-detection',
      );
    });
  });
}
