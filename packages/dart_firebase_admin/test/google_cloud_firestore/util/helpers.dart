import 'dart:async';

import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

const projectId = 'dart-firebase-admin';

/// Clears all data from the Firestore Emulator.
///
/// This function calls the emulator's clear data endpoint to remove all documents.
/// This ensures test isolation by providing a clean slate for each test.
Future<void> clearFirestoreEmulator() async {
  final client = Client();
  try {
    final response = await client.delete(
      Uri.parse(
          'http://localhost:8080/emulator/v1/projects/$projectId/databases/(default)/documents'),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Emulator cleared successfully
    } else {
      print(
          'WARNING: Failed to clear Firestore emulator: HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('WARNING: Exception while clearing Firestore emulator: $e');
  } finally {
    client.close();
  }
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
