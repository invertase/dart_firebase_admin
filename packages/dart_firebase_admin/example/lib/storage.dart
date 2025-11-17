import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/storage.dart';

void main() async {
  final admin = FirebaseAdminApp.initializeApp(
    'dart-firebase-admin',
    Credential.fromApplicationDefaultCredentials(),
  );

  final storage = Storage(admin);

  final bucket = storage.bucket('dart-firebase-admin.firebasestorage.app');

  final file = bucket.file('foo.txt');

  await file.delete();

  await admin.close();
}
