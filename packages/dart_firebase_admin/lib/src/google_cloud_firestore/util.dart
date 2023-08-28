import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

@internal
extension MapWhereValue<K, V> on Map<K, V?> {
  Map<K, V> whereValueNotNull() {
    return Map<K, V>.fromEntries(
      entries
          .where((e) => e.value != null)
          // ignore: null_check_on_nullable_type_parameter
          .map((e) => MapEntry(e.key, e.value!)),
    );
  }
}

@internal
Uint8List randomBytes(int length) {
  final rnd = Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (i) => rnd.nextInt(256)),
  );
}

/// Generate a unique client-side identifier.
///
/// Used for the creation of new documents.
/// Returns a unique 20-character wide identifier.
@internal
String autoId() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var autoId = '';
  while (autoId.length < 20) {
    final bytes = randomBytes(40);
    for (final b in bytes) {
      // Length of `chars` is 62. We only take bytes between 0 and 62*4-1
      // (both inclusive). The value is then evenly mapped to indices of `char`
      // via a modulo operation.
      const maxValue = 62 * 4 - 1;
      if (autoId.length < 20 && b <= maxValue) {
        autoId += chars[b % 62];
      }
    }
  }
  return autoId;
}

/// Generate a short and semi-random client-side identifier.
///
/// Used for the creation of request tags.
@internal
String requestTag() => autoId().substring(0, 5);

/// Parses the value of the environment variable FIRESTORE_PREFER_REST, and
/// returns a value indicating if the environment variable enables or disables
/// preferRest.
///
/// This function will warn to the console if the environment variable is set
/// to an unsupported value.
///
/// Return `true` if the environment variable enables `preferRest`,
/// `false` if the environment variable disables `preferRest`, or `null`
/// if the environment variable is not set or is set to an unsupported value.
@internal
bool? tryGetPreferRestEnvironmentVariable() {
  final rawValue =
      Platform.environment['FIRESTORE_PREFER_REST']?.trim().toLowerCase();

  if (rawValue == null) {
    return null;
  } else if (rawValue == '1' || rawValue == 'true') {
    return true;
  } else if (rawValue == '0' || rawValue == 'false') {
    return false;
  } else {
    stderr.writeln(
      'An unsupported value was specified for the environment variable FIRESTORE_PREFER_REST. '
      'Value $rawValue is unsupported.',
    );
    return null;
  }
}

@internal
String? get firebaseEmulatorHostEnv =>
    Platform.environment['FIRESTORE_EMULATOR_HOST'];
