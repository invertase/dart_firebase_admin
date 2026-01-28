import 'dart:io';

import 'package:googleapis_storage/googleapis_storage.dart' as storage;

/// Whether Google Application Default Credentials are available.
/// Used to skip tests that require Google Cloud credentials.
final hasGoogleEnv =
    Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'] != null;

/// Waits for a file to exist, polling at regular intervals.
/// Returns true if the file exists within the timeout, false otherwise.
Future<bool> waitForFileExists(
  storage.BucketFile file, {
  Duration timeout = const Duration(seconds: 30),
  Duration pollInterval = const Duration(milliseconds: 500),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await file.exists()) {
      return true;
    }
    await Future<void>.delayed(pollInterval);
  }
  return false;
}
