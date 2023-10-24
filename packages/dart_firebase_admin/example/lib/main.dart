import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

Future<void> main() async {
  final admin = FirebaseAdminApp.initializeApp(
    'dart-firebase-admin',
    Credential.fromApplicationDefaultCredentials(),
  );

  admin.useEmulator();

  final firestore = Firestore(admin);

  final collection = firestore.collection('users');

  await collection.doc('123').set({
    'name': 'John Doe',
    'age': 30,
  });

  final snapshot = await collection.get();

  for (final doc in snapshot.docs) {
    print(doc.data());
  }

  await admin.close();
}
