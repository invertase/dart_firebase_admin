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

import 'dart:io';

Future<void> main() async {
  final isWindows = Platform.isWindows;
  final npmCmd = isWindows ? 'npm.cmd' : 'npm';
  final firebaseCmd = isWindows ? 'firebase.cmd' : 'firebase';

  print('> Installing dependencies for test functions...');
  final npmResult = await Process.run(npmCmd, [
    'install',
  ], workingDirectory: '../test/fixtures/task_queue_functions');

  if (npmResult.exitCode != 0) {
    print('> npm install failed:');
    print(npmResult.stderr);
    exitCode = npmResult.exitCode;
    return;
  }
  print('> Dependencies installed successfully.');

  print('> Starting emulators and running example...');

  final process = await Process.start(
    firebaseCmd,
    [
      'emulators:exec',
      '--config',
      '../test/firebase.json',
      '--only',
      'auth,firestore,functions,tasks,storage',
      '${Platform.executable} run bin/example.dart',
    ],
    environment: {
      'FIRESTORE_EMULATOR_HOST': 'localhost:8080',
      'FIREBASE_AUTH_EMULATOR_HOST': 'localhost:9099',
      'CLOUD_TASKS_EMULATOR_HOST': 'localhost:9499',
      'FIREBASE_STORAGE_EMULATOR_HOST': 'localhost:9199',
      'GOOGLE_CLOUD_PROJECT': 'dart-firebase-admin',
    },
    mode: ProcessStartMode.inheritStdio,
  );

  exitCode = await process.exitCode;
}
