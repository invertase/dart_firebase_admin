import 'dart:async';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

const projectId = 'dart-firebase-admin';

/// Validates that required emulator environment variables are set.
///
/// Call this in setUpAll() of test files to fail fast if emulators aren't
/// configured, preventing accidental writes to production.
///
/// Example:
/// ```dart
/// setUpAll(() {
///   ensureEmulatorConfigured();
/// });
/// ```
void ensureEmulatorConfigured({bool requireAuth = false}) {
  final missingVars = <String>[];

  if (!Environment.isFirestoreEmulatorEnabled()) {
    missingVars.add(Environment.firestoreEmulatorHost);
  }

  if (requireAuth && !Environment.isAuthEmulatorEnabled()) {
    missingVars.add(Environment.firebaseAuthEmulatorHost);
  }

  if (missingVars.isNotEmpty) {
    throw StateError(
      'Missing emulator configuration: ${missingVars.join(", ")}\n\n'
      'Tests must run against Firebase emulators to prevent writing to production.\n'
      'Set the following environment variables:\n'
      '  ${Environment.firestoreEmulatorHost}=localhost:8080\n'
      '  ${Environment.firebaseAuthEmulatorHost}=localhost:9099\n\n'
      'Or run tests with: firebase emulators:exec "dart test"',
    );
  }
}

// /// Clears all data from the Firestore Emulator.
// ///
// /// This function calls the emulator's clear data endpoint to remove all documents.
// /// This ensures test isolation by providing a clean slate for each test.
// Future<void> clearFirestoreEmulator() async {
//   final client = Client();
//   try {
//     final response = await client.delete(
//       Uri.parse(
//         'http://localhost:8080/emulator/v1/projects/$projectId/databases/(default)/documents',
//       ),
//     );
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       // Emulator cleared successfully
//     } else {
//       // ignore: avoid_print
//       print(
//         'WARNING: Failed to clear Firestore emulator: HTTP ${response.statusCode}',
//       );
//     }
//   } catch (e) {
//     // ignore: avoid_print
//     print('WARNING: Exception while clearing Firestore emulator: $e');
//   } finally {
//     client.close();
//   }
// }

/// Creates a FirebaseApp for testing.
///
/// Note: Tests should be run with the following environment variables set:
/// - FIRESTORE_EMULATOR_HOST=localhost:8080
/// - FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
///
/// The emulator will be auto-detected from these environment variables.
FirebaseApp createApp({
  FutureOr<void> Function()? tearDown,
  Client? client,
  String? name,
}) {
  final app = FirebaseApp.initializeApp(
    name: name,
    options: AppOptions(
      projectId: projectId,
      httpClient: client,
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

Future<void> _recursivelyDeleteAllDocuments(Firestore firestore) async {
  Future<void> handleCollection(CollectionReference<void> collection) async {
    final docs = await collection.listDocuments();

    for (final doc in docs) {
      await doc.delete();

      final subcollections = await doc.listCollections();
      for (final subcollection in subcollections) {
        await handleCollection(subcollection);
      }
    }
  }

  final collections = await firestore.listCollections();
  for (final collection in collections) {
    await handleCollection(collection);
  }
}

/// Creates a Firestore instance for testing.
///
/// Automatically cleans up all documents after each test.
///
/// Note: Tests should be run with FIRESTORE_EMULATOR_HOST=localhost:8080
/// environment variable set. The emulator will be auto-detected.
Future<Firestore> createFirestore({
  Settings? settings,
}) async {
  // CRITICAL: Ensure emulator is running to prevent hitting production
  if (!Environment.isFirestoreEmulatorEnabled()) {
    throw StateError(
      '${Environment.firestoreEmulatorHost} environment variable must be set to run tests. '
      'This prevents accidentally writing test data to production. '
      'Set it to "localhost:8080" or your emulator host.',
    );
  }

  // Use unique app name for each test to avoid interference
  final appName = 'firestore-test-${DateTime.now().microsecondsSinceEpoch}';

  final firestore = Firestore(
    createApp(name: appName),
    settings: settings,
  );

  addTearDown(() async {
    try {
      await _recursivelyDeleteAllDocuments(firestore);
    } on ClientException catch (e) {
      // Ignore if HTTP client was already closed by app teardown
      if (!e.message.contains('Client is already closed')) rethrow;
    }
  });

  return firestore;
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
