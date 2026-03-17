// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

part of 'firestore.dart';

/// Verifies that a `Value` only has a single type set.
void _assertValidProtobufValue(firestore_v1.Value proto) {
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
    throw ArgumentError.value(proto, 'proto', 'Unable to infer type value');
  }
}
