part of '../app.dart';

/// Represents a Firebase Emulator.
/// Now for Auth and Firestore.
class Emulator {

  /// If there is no environment variable set, please use this constructor.
  /// For example, gcloud firestore emulators.
  const Emulator(this.host, this.port);

  /// Creates an [Emulator] from an environment variable.
  /// For example, env key for auth is: FIREBASE_AUTH_EMULATOR_HOST
  @internal
  factory Emulator.fromEnvString(String envString) {
    final parts = envString.split(':');
    if (parts.length != 2) {
      throw ArgumentError.value(envString, 'envString', 'Invalid format');
    }
    final host = parts[0];
    final port = int.tryParse(parts[1]);
    if (port == null) {
      throw ArgumentError.value(envString, 'envString', 'Invalid port');
    }
    return Emulator(host, port);
  }

  /// The default Auth Emulator.
  const Emulator._defaultAuth()
      : host = '127.0.0.1',
        port = 9099;

  /// The default Firestore Emulator.
  const Emulator._defaultFirestore()
      : host = '127.0.0.1',
        port = 8080;

  /// Try to get the Auth Emulator from the environment variable.
  /// If not found, use the default Auth Emulator.
  factory Emulator.auth() {
    if (!Platform.environment.containsKey('FIREBASE_AUTH_EMULATOR_HOST')) {
      return const Emulator._defaultAuth();
    } else {
      return Emulator.fromEnvString(
        Platform.environment['FIREBASE_AUTH_EMULATOR_HOST']!,
      );
    }
  }

  /// Try to get the Firestore Emulator from the environment variable.
  /// If not found, use the default Firestore Emulator.
  factory Emulator.firestore() {
    if (!Platform.environment.containsKey('FIRESTORE_EMULATOR_HOST')) {
      return const Emulator._defaultFirestore();
    } else {
      return Emulator.fromEnvString(
        Platform.environment['FIRESTORE_EMULATOR_HOST']!,
      );
    }
  }

  final String host;
  final int port;
}
