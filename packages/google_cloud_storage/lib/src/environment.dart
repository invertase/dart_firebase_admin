import 'dart:async';
import 'dart:io';

import '../google_cloud_storage.dart';

/// Environment variable names used by Google Cloud Storage.
///
/// These constants provide type-safe access to environment variables
/// that configure Storage behavior and emulator connections.
abstract class Environment {
  /// Storage Emulator host address.
  ///
  /// When set, Storage automatically connects to the emulator instead of production.
  /// Format: `host:port` (e.g., `localhost:9199`)
  ///
  /// Example:
  /// ```bash
  /// export STORAGE_EMULATOR_HOST=localhost:9199
  /// ```
  static const storageEmulatorHost = 'STORAGE_EMULATOR_HOST';

  /// Gets the Storage emulator host from environment variables.
  ///
  /// Returns the host:port string if [storageEmulatorHost] is set, otherwise null.
  ///
  /// Priority order:
  /// 1. Zone.current[envSymbol] (for package tests using runZoned)
  /// 2. Platform.environment (actual system environment)
  ///
  /// Note: Use [StorageOptions.apiEndpoint] to explicitly override the endpoint
  /// in client code, which takes precedence over environment variables.
  ///
  /// Example:
  /// ```dart
  /// final emulatorHost = Environment.getStorageEmulatorHost();
  /// if (emulatorHost != null) {
  ///   print('Using Storage emulator at $emulatorHost');
  /// }
  /// ```
  static String? getStorageEmulatorHost() {
    final env =
        Zone.current[envSymbol] as Map<String, String?>? ??
        Platform.environment;
    return env[storageEmulatorHost];
  }

  /// Checks if the Storage emulator is enabled via environment variable.
  ///
  /// Returns `true` if [storageEmulatorHost] is set in the environment.
  ///
  /// Example:
  /// ```dart
  /// if (Environment.isStorageEmulatorEnabled()) {
  ///   print('Using Storage emulator');
  /// }
  /// ```
  static bool isStorageEmulatorEnabled() {
    return getStorageEmulatorHost() != null;
  }
}
