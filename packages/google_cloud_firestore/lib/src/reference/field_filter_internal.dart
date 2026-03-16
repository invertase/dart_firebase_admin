// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of '../firestore.dart';

class _FieldFilterInternal extends _FilterInternal {
  _FieldFilterInternal({
    required this.field,
    required this.op,
    required this.value,
    required this.serializer,
  });

  final FieldPath field;
  final WhereFilter op;
  final Object? value;
  final Serializer serializer;

  @override
  List<_FieldFilterInternal> get flattenedFilters => [this];

  @override
  List<_FieldFilterInternal> get filters => [this];

  @override
  FieldPath? get firstInequalityField => isInequalityFilter ? field : null;

  bool get isInequalityFilter {
    return op == WhereFilter.lessThan ||
        op == WhereFilter.lessThanOrEqual ||
        op == WhereFilter.greaterThan ||
        op == WhereFilter.greaterThanOrEqual;
  }

  @override
  firestore_v1.Filter toProto() {
    final value = this.value;
    if (value is num && value.isNaN) {
      return firestore_v1.Filter(
        unaryFilter: firestore_v1.UnaryFilter(
          field: firestore_v1.FieldReference(fieldPath: field._formattedName),
          op: op == WhereFilter.equal ? 'IS_NAN' : 'IS_NOT_NAN',
        ),
      );
    }

    if (value == null) {
      return firestore_v1.Filter(
        unaryFilter: firestore_v1.UnaryFilter(
          field: firestore_v1.FieldReference(fieldPath: field._formattedName),
          op: op == WhereFilter.equal ? 'IS_NULL' : 'IS_NOT_NULL',
        ),
      );
    }

    return firestore_v1.Filter(
      fieldFilter: firestore_v1.FieldFilter(
        field: firestore_v1.FieldReference(fieldPath: field._formattedName),
        op: op.proto,
        value: serializer.encodeValue(value),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _FieldFilterInternal &&
        field == other.field &&
        op == other.op &&
        value == other.value;
  }

  @override
  int get hashCode => Object.hash(field, op, value);
}
