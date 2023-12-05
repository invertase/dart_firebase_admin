import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final token = await FirebaseMessaging.instance.getToken();

  print('token $token');

  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dart Firebase Admin'),
        ),
        body: Center(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('foo').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data!.docs.firstOrNull?.data().toString() ??
                      'No data',
                );
              }

              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              return const Text('Loading...');
            },
          ),
        ),
      ),
    ),
  );

  // final admin = FirebaseAdminApp.initializeApp(
  //   'dart-firebase-admin',
  //   Credential.fromApplicationDefaultCredentials(),
  // );

  // // admin.useEmulator();

  // final messaging = Messaging(admin);

  // final result = await messaging.send(
  //   TopicMessage(topic: 'test'),
  // );

  // print(result);

  // final firestore = Firestore(admin);

  // final collection = firestore.collection('users');

  // await collection.doc('123').set({
  //   'name': 'John Doe',
  //   'age': 30,
  // });

  // final snapshot = await collection.get();

  // for (final doc in snapshot.docs) {
  //   print(doc.data());
  // }

  // await admin.close();
}
