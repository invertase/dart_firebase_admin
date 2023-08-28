import 'package:meta/meta.dart';

/// Validates that 'value' is a host.
@internal
void validateHost(
  String value, {
  required String argName,
}) {
  final urlString = 'http://$value/';
  Uri parsed;
  try {
    parsed = Uri.parse(urlString);
  } catch (e) {
    throw ArgumentError.value(value, argName, 'Must be a valid host');
  }

  if (parsed.query.isNotEmpty ||
      parsed.path != '/' ||
      parsed.userName.isNotEmpty) {
    throw ArgumentError.value(value, argName, 'Must be a valid host');
  }
}

extension on Uri {
  String get userName => userInfo.split(':').first;
}
