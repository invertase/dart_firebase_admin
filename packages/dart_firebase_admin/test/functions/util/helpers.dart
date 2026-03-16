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

import 'package:dart_firebase_admin/functions.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:test/test.dart';

import '../../helpers.dart';

/// Validates that Cloud Tasks emulator environment variable is set.
///
/// Call this in setUpAll() of integration test files to fail fast if
/// the emulator isn't configured.
void ensureCloudTasksEmulatorConfigured() {
  if (!Environment.isCloudTasksEmulatorEnabled()) {
    throw StateError(
      'Missing emulator configuration: ${Environment.cloudTasksEmulatorHost}\n\n'
      'Integration tests must run against the Cloud Tasks emulator.\n'
      'Set the following environment variable:\n'
      '  ${Environment.cloudTasksEmulatorHost}=localhost:9499\n\n'
      'Or run tests with: firebase emulators:exec "dart test"',
    );
  }
}

/// Creates a Functions instance for integration testing with the emulator.
///
/// No cleanup is needed since tasks are ephemeral and queue state is
/// managed by the emulator.
///
/// Note: Tests should be run with CLOUD_TASKS_EMULATOR_HOST=localhost:9499
/// environment variable set. The emulator will be auto-detected.
Functions createFunctionsForTest() {
  // CRITICAL: Ensure emulator is running to prevent hitting production
  if (!Environment.isCloudTasksEmulatorEnabled()) {
    throw StateError(
      '${Environment.cloudTasksEmulatorHost} environment variable must be set to run tests. '
      'This prevents accidentally writing test data to production. '
      'Set it to "localhost:9499" or your emulator host.',
    );
  }

  // Use unique app name for each test to avoid interference
  final appName = 'functions-test-${DateTime.now().microsecondsSinceEpoch}';

  final app = createApp(name: appName);

  return Functions.internal(app);
}

/// Creates a Functions instance for unit testing with a mock HTTP client.
///
/// This uses the internal constructor to inject a custom HTTP client,
/// allowing tests to run without the emulator.
Functions createFunctionsWithMockClient(AuthClient mockClient) {
  final appName =
      'functions-unit-test-${DateTime.now().microsecondsSinceEpoch}';

  final app = FirebaseApp.initializeApp(
    name: appName,
    options: AppOptions(projectId: projectId, httpClient: mockClient),
  );

  addTearDown(() async {
    await app.close();
  });

  return Functions.internal(app);
}

/// Creates a Functions instance for unit testing with a mock request handler.
///
/// This uses the internal constructor to inject a mock FunctionsRequestHandler,
/// allowing complete control over the request/response cycle.
Functions createFunctionsWithMockHandler(FunctionsRequestHandler mockHandler) {
  final appName =
      'functions-unit-test-${DateTime.now().microsecondsSinceEpoch}';

  final app = FirebaseApp.initializeApp(
    name: appName,
    options: const AppOptions(projectId: projectId),
  );

  addTearDown(() async {
    await app.close();
  });

  return Functions.internal(app, requestHandler: mockHandler);
}
