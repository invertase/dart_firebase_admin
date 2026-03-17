// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import '../google_cloud_firestore.dart';

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
  /// Priority order:
  /// 1. Zone.current[envSymbol] (for package tests using runZoned)
  /// 2. [environmentOverride] parameter (for client code tests)
  /// 3. Platform.environment (actual system environment)
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
    // First check Zone (for package tests)
    final zoneEnv = Zone.current[envSymbol] as Map<String, String>?;
    if (zoneEnv != null) {
      return zoneEnv[firestoreEmulatorHost];
    }

    // Then check environmentOverride (for client code)
    // This allows tests to explicitly remove environment variables
    if (environmentOverride != null) {
      return environmentOverride[firestoreEmulatorHost];
    }

    // Finally fall back to actual environment variables
    return Platform.environment[firestoreEmulatorHost];
  }

  /// Checks if the Firestore emulator is enabled via environment variable.
  ///
  /// Returns `true` if [firestoreEmulatorHost] is set in the environment.
  ///
  /// Priority order (same as [getFirestoreEmulatorHost]):
  /// 1. Zone.current[envSymbol] (for package tests using runZoned)
  /// 2. [environmentOverride] parameter (for client code tests)
  /// 3. Platform.environment (actual system environment)
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
