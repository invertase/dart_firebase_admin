part of '../app.dart';

/// Represents a Firebase Emulator.
/// Now for Auth and Firestore.
class Emulator {
  const Emulator._(this.host, this.port);

  const Emulator.defaultAuth()
      : host = '127.0.0.1',
        port = 9099;

  const Emulator.defaultFirestore()
      : host = '127.0.0.1',
        port = 8080;

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
    return Emulator._(host, port);
  }

  final String host;
  final int port;
}
