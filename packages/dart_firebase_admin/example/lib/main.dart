import 'dart:io';

import 'package:dart_firebase_admin/dart_firebase_admin.dart';

Future<void> main() async {
  final admin = FirebaseAdminApp.initializeApp(
    Credential.fromServiceAccount(File('../service-account.json')),
  );

  final auth = FirebaseAdminAuth(admin);

  await auth.deleteUser('867gK70vkJNjOzlj4uQoMcg7a1d2');

  print('Deleted!');
}
