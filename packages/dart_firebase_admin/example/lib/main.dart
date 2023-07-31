import 'package:dart_firebase_admin/dart_firebase_admin.dart';

Future<void> main() async {
  final admin = FirebaseAdminApp.initializeApp(
    'dart-firebase-admin',
    Credential.fromApplicationDefaultCredentials(),
  );

  final auth = FirebaseAdminAuth(admin);

  // await auth.deleteUser('867gK70vkJNjOzlj4uQoMcg7a1d2');
  // await auth.createSessionCookie('867gK70vkJNjOzlj4uQoMcg7a1d2');
  final d = await auth.deleteUsers(['p9bj9If2i4eQlr7NxnaxWGZsmgq1']);
  print(d.errors);
  print(d.failureCount);
  print('Deleted!');
}
