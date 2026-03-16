// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
