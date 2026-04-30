// Copyright 2026 Google LLC
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

import 'dart:async';
import 'dart:io';

import 'package:firebase_admin_sdk/src/app.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart'
    as google_cloud_firestore;
import 'package:googleapis_auth/googleapis_auth.dart' as googleapis_auth;
import 'package:test/test.dart';

const projectId = 'dart-firebase-admin';

/// Mock Firestore settings that use emulator override to avoid ADC loading.
/// Use this in tests that need to initialize Firestore without real credentials.
const mockFirestoreSettings = google_cloud_firestore.Settings(
  projectId: projectId,
  environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
);

/// Creates mock Firestore settings with a custom database ID.
google_cloud_firestore.Settings mockFirestoreSettingsWithDb(
  String databaseId,
) => google_cloud_firestore.Settings(
  projectId: projectId,
  databaseId: databaseId,
  environmentOverride: const {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
);

/// Returns a copy of [Platform.environment] with all emulator host variables
/// removed, so tests can connect to production Firebase even when emulators
/// are configured in the outer environment.
Map<String, String> prodEnv() {
  final env = Map<String, String>.from(Platform.environment);
  env.remove(Environment.firebaseAuthEmulatorHost);
  env.remove(Environment.firestoreEmulatorHost);
  env.remove(Environment.firebaseStorageEmulatorHost);
  env.remove(Environment.cloudTasksEmulatorHost);
  return env;
}

/// Creates a FirebaseApp for testing.
///
/// Note: Tests should be run with the following environment variables set:
/// - FIRESTORE_EMULATOR_HOST=localhost:8080
/// - FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
///
/// The emulator will be auto-detected from these environment variables.
FirebaseApp createApp({
  FutureOr<void> Function()? tearDown,
  googleapis_auth.AuthClient? client,
  String? name,
  Credential? credential,
}) {
  final app = FirebaseApp.initializeApp(
    name: name,
    options: AppOptions(
      projectId: projectId,
      httpClient: client,
      credential: credential,
    ),
  );

  addTearDown(() async {
    if (tearDown != null) {
      await tearDown();
    }
    await app.close();
  });

  return app;
}

Matcher isArgumentError({String? message}) {
  var matcher = isA<ArgumentError>();
  if (message != null) {
    matcher = matcher.having((e) => e.message, 'message', message);
  }

  return matcher;
}

Matcher throwsArgumentError({String? message}) {
  return throwsA(isArgumentError(message: message));
}
