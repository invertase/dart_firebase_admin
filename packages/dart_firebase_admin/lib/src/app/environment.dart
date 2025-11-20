part of '../app.dart';

/// Environment variable names used by the Firebase Admin SDK.
///
/// These constants provide type-safe access to environment variables
/// that configure SDK behavior, credentials, and emulator connections.
abstract class Environment {
  /// Path to Google Application Credentials JSON file.
  ///
  /// Used by Application Default Credentials to load service account credentials.
  /// Example: `/path/to/serviceAccountKey.json`
  static const googleApplicationCredentials = 'GOOGLE_APPLICATION_CREDENTIALS';

  /// Google Cloud project ID.
  ///
  /// Used to explicitly specify the project ID when not available from credentials.
  static const googleCloudProject = 'GOOGLE_CLOUD_PROJECT';

  /// Legacy Google Cloud project ID (gcloud CLI).
  ///
  /// Alternative to [googleCloudProject], used by gcloud CLI.
  static const gcloudProject = 'GCLOUD_PROJECT';

  /// Firebase Auth Emulator host address.
  ///
  /// When set, Auth service automatically connects to the emulator instead of production.
  /// Format: `host:port` (e.g., `localhost:9099`)
  static const firebaseAuthEmulatorHost = 'FIREBASE_AUTH_EMULATOR_HOST';

  /// Firestore Emulator host address.
  ///
  /// When set, Firestore service automatically connects to the emulator instead of production.
  /// Format: `host:port` (e.g., `localhost:8080`)
  static const firestoreEmulatorHost = 'FIRESTORE_EMULATOR_HOST';

  /// Checks if the Firestore emulator is enabled via environment variable.
  ///
  /// Returns `true` if [firestoreEmulatorHost] is set in the environment.
  ///
  /// Example:
  /// ```dart
  /// if (Environment.isFirestoreEmulatorEnabled()) {
  ///   print('Using Firestore emulator');
  /// }
  /// ```
  static bool isFirestoreEmulatorEnabled() {
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    return env[firestoreEmulatorHost] != null;
  }

  /// Checks if the Auth emulator is enabled via environment variable.
  ///
  /// Returns `true` if [firebaseAuthEmulatorHost] is set in the environment.
  ///
  /// Example:
  /// ```dart
  /// if (Environment.isAuthEmulatorEnabled()) {
  ///   print('Using Auth emulator');
  /// }
  /// ```
  static bool isAuthEmulatorEnabled() {
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    return env[firebaseAuthEmulatorHost] != null;
  }
}
