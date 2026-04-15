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

// Run example against Firebase production
//
// Authentication Options:
//
// Option 1: Service Account Key (used by this script)
//   1. Download your service account key from Firebase Console:
//      - Go to Project Settings > Service Accounts
//      - Click "Generate New Private Key"
//      - Save as service-account-key.json in this directory
//   2. The script is configured to use this file via GOOGLE_APPLICATION_CREDENTIALS.
//
// Option 2: Application Default Credentials (alternative)
//   1. Run: gcloud auth application-default login
//   2. The SDK will automatically find these credentials if GOOGLE_APPLICATION_CREDENTIALS is not set.
//
// For available environment variables, see:
// packages/firebase_admin_sdk/lib/src/app/environment.dart

import 'dart:io';

Future<void> main() async {
  print('> Running example against production...');

  final process = await Process.start(
    Platform.resolvedExecutable,
    ['run', 'bin/example.dart'],
    environment: {'GOOGLE_APPLICATION_CREDENTIALS': 'service-account-key.json'},
    mode: ProcessStartMode.inheritStdio,
  );

  exitCode = await process.exitCode;
}
