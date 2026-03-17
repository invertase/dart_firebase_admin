// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:dart_firebase_admin/dart_firebase_admin.dart';

Future<void> main() async {
  final admin = FirebaseApp.initializeApp();

  // Uncomment to run auth example
  // await authExample(admin);

  // Uncomment to run project config example
  // await projectConfigExample(admin);

  // Uncomment to run tenant example (requires Identity Platform upgrade)
  // await tenantExample(admin);

  // await firestoreExample(admin);

  // await functionsExample(admin);

  // Uncomment to run messaging example (requires valid fcm token)
  // await messagingExample(admin);

  // Uncomment to run storage example
  // await storageExample(admin);

  // Uncomment to run app check example
  // await appCheckExample(admin);

  // Uncomment to run security rules example
  // await securityRulesExample(admin);

  await admin.close();
}
