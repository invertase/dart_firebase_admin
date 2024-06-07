part of '../app.dart';

/// Represents a Firebase Emulator.
/// Now for Auth and Firestore.
class Emulator {
  Emulator(this.host, this.port);

  final String host;
  final int port;
}