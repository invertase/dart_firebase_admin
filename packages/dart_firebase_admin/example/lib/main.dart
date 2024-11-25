import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/messaging.dart';

Future<void> main() async {
  final admin = FirebaseAdminApp.initializeApp(
    'dart-firebase-admin',
    Credential.fromApplicationDefaultCredentials(),
  );

  // // admin.useEmulator();

  final messaging = Messaging(admin);

  final result = await messaging.send(
    TokenMessage(
      token:
          'e8Ap1n9UTQenyB-UEjNQt9:APA91bHhgc9RZYDcCKb7U1scQo1K0ZTSMItop8IqctrOcgvmN__oBo4vgbFX-ji4atr1PVw3Loug-eOCBmj4HVZjUE0aQBA0mGry7uL-7JuMaojhtl13MpvQtbZptvX_8f6vDcqei88O',
      notification: Notification(
        title: 'Hello',
        body: 'World',
      ),
    ),
  );

  print(result);

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
