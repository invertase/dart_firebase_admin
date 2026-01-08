import 'dart:io';

/// Environment variable names used by Google Cloud Firestore.
///
/// These constants provide type-safe access to environment variables
/// that configure Firestore behavior and emulator connections.
abstract class Environment {
  /// Firestore Emulator host address.
  ///
  /// When set, Firestore automatically connects to the emulator instead of production.
  /// Format: `host:port` (e.g., `localhost:8080`)
  ///
  /// Example:
  /// ```bash
  /// export FIRESTORE_EMULATOR_HOST=localhost:8080
  /// ```
  static const firestoreEmulatorHost = 'FIRESTORE_EMULATOR_HOST';

  /// Gets the Firestore emulator host from environment variables.
  ///
  /// Returns the host:port string if [firestoreEmulatorHost] is set, otherwise null.
  ///
  /// Example:
  /// ```dart
  /// final emulatorHost = Environment.getFirestoreEmulatorHost();
  /// if (emulatorHost != null) {
  ///   print('Using Firestore emulator at $emulatorHost');
  /// }
  /// ```
  static String? getFirestoreEmulatorHost() {
    return Platform.environment[firestoreEmulatorHost];
  }

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
    return getFirestoreEmulatorHost() != null;
  }
}
