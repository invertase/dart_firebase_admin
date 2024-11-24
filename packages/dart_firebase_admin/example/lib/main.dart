import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

Future<void> main() async {
  final admin = FirebaseAdminApp.initializeApp(
    'cronometropassaros',
    Credential.fromApplicationDefaultCredentials(),
  );

  admin.useEmulator();

  final firestore = Firestore(admin);

  final collection = firestore.collection('users');

  final docRef = collection.doc('123');

//  var x = await docRefDontExist.get();

  // await firestore.runTransaction((transaction) async {
  //   await transaction.get(docRef);
  // });

  await firestore.runTransaction((transaction) async {
    transaction.set(docRef, {
      'name': 'John Doe',
      'age': 30,
    });
  });

  await admin.close();
}
