import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

Future<void> main() async {
  final admin = FirebaseApp.initializeApp();
  await authExample(admin);
  await firestoreExample(admin);
  await admin.close();
}

Future<void> authExample(FirebaseApp admin) async {
  print('\n### Auth Example ###\n');

  final auth = Auth(admin);

  late UserRecord user;
  try {
    print('> Check if user with email exists: test@example.com\n');
    user = await auth.getUserByEmail('test@example.com');
    print('> User found by email\n');
  } on FirebaseAuthAdminException catch (e) {
    if (e.errorCode == AuthClientErrorCode.userNotFound) {
      print('\n> User not found, creating new user');
      user = await auth.createUser(
        CreateRequest(
          email: 'test@example.com',
          password: 'Test@123',
        ),
      );
    }
  }

  print('Fetched user email: ${user.email}');
}

Future<void> firestoreExample(FirebaseApp admin) async {
  print('\n### Firestore Example ###\n');

  final firestore = Firestore(admin);

  try {
    final collection = firestore.collection('users');
    await collection.doc('123').set({
      'name': 'John Doe',
      'age': 27,
    });
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      print('> Document data: ${doc.data()}');
    }
  } catch (e) {
    print('> Error setting document: $e');
  }
}
