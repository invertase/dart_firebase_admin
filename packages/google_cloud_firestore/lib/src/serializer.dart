part of 'firestore.dart';

@internal
typedef ApiMapValue = Map<String, firestore_v1.Value>;

abstract base class _Serializable {
  firestore_v1.Value _toProto();
}

class _Serializer {
  _Serializer(this.firestore);

  final Firestore firestore;

  Object _createInteger(String n) {
    if (firestore._settings.useBigInt) {
      return BigInt.parse(n);
    } else {
      return int.parse(n);
    }
  }

  /// Encodes a Dart object into the Firestore 'Fields' representation.
  firestore_v1.MapValue encodeFields(DocumentData obj) {
    return firestore_v1.MapValue(
      fields: obj.map((key, value) {
        return MapEntry(key, encodeValue(value));
      }).whereValueNotNull(),
    );
  }

  /// Encodes a Dart value into the Firestore 'Value' representation.
  firestore_v1.Value? encodeValue(Object? value) {
    switch (value) {
      case _FieldTransform():
        return null;

      case String():
        return firestore_v1.Value(stringValue: value);

      case bool():
        return firestore_v1.Value(booleanValue: value);

      case int():
      case BigInt():
        return firestore_v1.Value(integerValue: value.toString());

      case double():
        return firestore_v1.Value(doubleValue: value);

      case DateTime():
        final timestamp = Timestamp.fromDate(value);
        return timestamp._toProto();

      case null:
        return firestore_v1.Value(nullValue: 'NULL_VALUE');

      case _Serializable():
        return value._toProto();

      case List():
        return firestore_v1.Value(
          arrayValue: firestore_v1.ArrayValue(
            values: value.map(encodeValue).nonNulls.toList(),
          ),
        );

      case Map():
        if (value.isEmpty) {
          return firestore_v1.Value(
            mapValue: firestore_v1.MapValue(fields: {}),
          );
        }

        final fields = encodeFields(Map.from(value));
        if (fields.fields!.isEmpty) return null;

        return firestore_v1.Value(mapValue: fields);

      default:
        throw ArgumentError.value(
          value,
          'value',
          'Unsupported field value: ${value.runtimeType}',
        );
    }
  }

  /// Decodes a single Firestore 'Value' Protobuf.
  Object? decodeValue(Object? proto) {
    if (proto is! firestore_v1.Value) {
      throw ArgumentError.value(
        proto,
        'proto',
        'Cannot decode type from Firestore Value: ${proto.runtimeType}',
      );
    }
    _assertValidProtobufValue(proto);

    switch (proto) {
      case firestore_v1.Value(:final stringValue?):
        return stringValue;
      case firestore_v1.Value(:final booleanValue?):
        return booleanValue;
      case firestore_v1.Value(:final integerValue?):
        return _createInteger(integerValue);
      case firestore_v1.Value(:final doubleValue?):
        return doubleValue;
      case firestore_v1.Value(:final timestampValue?):
        return Timestamp._fromString(timestampValue);
      case firestore_v1.Value(:final referenceValue?):
        final resourcePath = _QualifiedResourcePath.fromSlashSeparatedString(
          referenceValue,
        );
        return firestore.doc(resourcePath.relativeName);
      case firestore_v1.Value(:final arrayValue?):
        final values = arrayValue.values;
        return <Object?>[
          if (values != null)
            for (final value in values) decodeValue(value),
        ];
      case firestore_v1.Value(nullValue: != null):
        return null;
      case firestore_v1.Value(:final mapValue?):
        final fields = mapValue.fields;
        return <String, Object?>{
          if (fields != null)
            for (final entry in fields.entries)
              entry.key: decodeValue(entry.value),
        };
      case firestore_v1.Value(:final geoPointValue?):
        return GeoPoint._fromProto(geoPointValue);

      default:
        throw ArgumentError.value(
          proto,
          'proto',
          'Cannot decode type from Firestore Value: ${proto.runtimeType}',
        );
    }
  }
}
