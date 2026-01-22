import 'dart:io';

/// Whether Google Application Default Credentials are available.
/// Used to skip tests that require Google Cloud credentials.
final hasGoogleEnv =
    Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'] != null;
