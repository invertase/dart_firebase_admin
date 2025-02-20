part of 'firestore.dart';

/// Verifies that a `Value` only has a single type set.
void _assertValidProtobufValue(firestore1.Value proto) {
  final values = [
    proto.booleanValue,
    proto.doubleValue,
    proto.integerValue,
    proto.stringValue,
    proto.timestampValue,
    proto.nullValue,
    proto.mapValue,
    proto.arrayValue,
    proto.referenceValue,
    proto.geoPointValue,
    proto.bytesValue,
  ];

  if (values.nonNulls.length != 1) {
    throw ArgumentError.value(
      proto,
      'proto',
      'Unable to infer type value',
    );
  }
}
