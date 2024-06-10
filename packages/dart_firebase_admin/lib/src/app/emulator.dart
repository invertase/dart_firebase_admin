part of '../app.dart';

/// Represents a Firebase Emulator.
/// Now for Auth and Firestore.
class Emulator {

  /// If there is no environment variable set, please use this constructor.
  /// For example, gcloud firestore emulators.
  const Emulator(this.host, this.port);

  /// The default Auth Emulator.
  const Emulator.defaultAuth()
      : host = '127.0.0.1',
        port = 9099;

  /// The default Firestore Emulator.
  const Emulator.defaultFirestore()
      : host = '127.0.0.1',
        port = 8080;

  /// Creates an [Emulator] from a firebase environment variable.
  /// For example, env key for auth is: FIREBASE_AUTH_EMULATOR_HOST
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

  final String host;
  final int port;
}
