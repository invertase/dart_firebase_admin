import 'dart:async';
import 'dart:io';

import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

import '../../google_cloud_firestore/util/helpers.dart';

Future<void> cleanup(Auth auth) async {
  // Only cleanup if we're using the emulator
  // Mock clients used in error handling tests won't have the emulator enabled
  if (!Environment.isAuthEmulatorEnabled()) {
    return; // Skip cleanup for non-emulator tests
  }

  try {
    final users = await auth.listUsers();
    await Future.wait([
      for (final user in users.users) auth.deleteUser(user.uid),
    ]);
  } catch (e) {
    // Ignore cleanup errors - they're not critical for test execution
  }
}

/// Creates an Auth instance for testing.
///
/// Automatically cleans up all users after each test.
///
/// By default, requires Firebase Auth Emulator to prevent accidental writes to production.
/// For tests that require production (e.g., session cookies with GCIP), set [requireEmulator] to false.
///
/// Note: Tests should be run with FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
/// environment variable set. The emulator will be auto-detected.
Auth createAuthForTest({bool requireEmulator = true}) {
  // CRITICAL: Ensure emulator is running to prevent hitting production
  // unless explicitly disabled for production-only tests
  if (requireEmulator && !Environment.isAuthEmulatorEnabled()) {
    throw StateError(
      '${Environment.firebaseAuthEmulatorHost} environment variable must be set to run tests. '
      'This prevents accidentally writing test data to production. '
      'Set it to "localhost:9099" or your emulator host.\n\n'
      'For production-only tests, use createAuthForTest(requireEmulator: false)',
    );
  }

  late Auth auth;
  late FirebaseApp app;

  // Remove production credentials from zone environment to force emulator usage
  // This prevents accidentally hitting production when both emulator and credentials are set
  final emulatorEnv = Map<String, String>.from(Platform.environment);
  emulatorEnv.remove(Environment.googleApplicationCredentials);

  runZoned(() {
    // Use unique app name for each test to avoid interference
    final appName = 'auth-test-${DateTime.now().microsecondsSinceEpoch}';

    app = createApp(
      name: appName,
      tearDown: () async {
        // Cleanup will be handled by addTearDown below
      },
    );

    auth = Auth(app);

    addTearDown(() async {
      await cleanup(auth);
    });
  }, zoneValues: {envSymbol: emulatorEnv});

  return auth;
}
