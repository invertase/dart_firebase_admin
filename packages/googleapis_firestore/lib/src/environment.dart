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
  /// If [environmentOverride] is provided, it will be checked first before
  /// falling back to Platform.environment.
  ///
  /// Example:
  /// ```dart
  /// final emulatorHost = Environment.getFirestoreEmulatorHost();
  /// if (emulatorHost != null) {
  ///   print('Using Firestore emulator at $emulatorHost');
  /// }
  /// ```
  static String? getFirestoreEmulatorHost([
    Map<String, String>? environmentOverride,
  ]) {
    // Check environment override first (for testing)
    if (environmentOverride != null &&
        environmentOverride.containsKey(firestoreEmulatorHost)) {
      return environmentOverride[firestoreEmulatorHost];
    }

    // Fall back to actual environment variables
    return Platform.environment[firestoreEmulatorHost];
  }

  /// Checks if the Firestore emulator is enabled via environment variable.
  ///
  /// Returns `true` if [firestoreEmulatorHost] is set in the environment.
  ///
  /// If [environmentOverride] is provided, it will be checked first before
  /// falling back to Platform.environment.
  ///
  /// Example:
  /// ```dart
  /// if (Environment.isFirestoreEmulatorEnabled()) {
  ///   print('Using Firestore emulator');
  /// }
  /// ```
  static bool isFirestoreEmulatorEnabled([
    Map<String, String>? environmentOverride,
  ]) {
    return getFirestoreEmulatorHost(environmentOverride) != null;
  }
}
