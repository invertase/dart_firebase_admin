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
//
// SPDX-License-Identifier: Apache-2.0

import 'package:google_cloud_firestore/src/firestore.dart';
import 'package:googleapis/firestore/v1.dart' as firestore_v1;
import 'package:test/test.dart';

void main() {
  group('Firestore Value Ordering', () {
    group('compare()', () {
      test('compares null values', () {
        final left = firestore_v1.Value(nullValue: 'NULL_VALUE');
        final right = firestore_v1.Value(nullValue: 'NULL_VALUE');
        expect(compare(left, right), equals(0));
      });

      test('compares boolean values', () {
        final falseValue = firestore_v1.Value(booleanValue: false);
        final trueValue = firestore_v1.Value(booleanValue: true);

        expect(compare(falseValue, trueValue), lessThan(0));
        expect(compare(trueValue, falseValue), greaterThan(0));
        expect(compare(falseValue, falseValue), equals(0));
      });

      test('compares integer values', () {
        final left = firestore_v1.Value(integerValue: '10');
        final right = firestore_v1.Value(integerValue: '20');

        expect(compare(left, right), lessThan(0));
        expect(compare(right, left), greaterThan(0));
        expect(compare(left, left), equals(0));
      });

      test('compares double values', () {
        final left = firestore_v1.Value(doubleValue: 1.5);
        final right = firestore_v1.Value(doubleValue: 2.5);

        expect(compare(left, right), lessThan(0));
        expect(compare(right, left), greaterThan(0));
        expect(compare(left, left), equals(0));
      });

      test('compares NaN values correctly', () {
        final nan1 = firestore_v1.Value(doubleValue: double.nan);
        final nan2 = firestore_v1.Value(doubleValue: double.nan);
        final regular = firestore_v1.Value(doubleValue: 1);

        // NaN == NaN
        expect(compare(nan1, nan2), equals(0));
        // NaN < regular number
        expect(compare(nan1, regular), lessThan(0));
        expect(compare(regular, nan1), greaterThan(0));
      });

      test('compares mixed integer and double values', () {
        final intValue = firestore_v1.Value(integerValue: '10');
        final doubleValue = firestore_v1.Value(doubleValue: 10.5);

        expect(compare(intValue, doubleValue), lessThan(0));
        expect(compare(doubleValue, intValue), greaterThan(0));
      });

      test('compares string values', () {
        final left = firestore_v1.Value(stringValue: 'abc');
        final right = firestore_v1.Value(stringValue: 'xyz');

        expect(compare(left, right), lessThan(0));
        expect(compare(right, left), greaterThan(0));
        expect(compare(left, left), equals(0));
      });

      test('compares timestamp values', () {
        final left = firestore_v1.Value(timestampValue: '2020-01-01T00:00:00Z');
        final right = firestore_v1.Value(
          timestampValue: '2021-01-01T00:00:00Z',
        );

        expect(compare(left, right), lessThan(0));
        expect(compare(right, left), greaterThan(0));
        expect(compare(left, left), equals(0));
      });

      test('compares reference values', () {
        final left = firestore_v1.Value(
          referenceValue:
              'projects/test/databases/(default)/documents/coll/doc1',
        );
        final right = firestore_v1.Value(
          referenceValue:
              'projects/test/databases/(default)/documents/coll/doc2',
        );

        expect(compare(left, right), lessThan(0));
        expect(compare(right, left), greaterThan(0));
        expect(compare(left, left), equals(0));
      });

      test('compares blob values', () {
        final left = firestore_v1.Value(bytesValue: 'YWJj'); // "abc" in base64
        final right = firestore_v1.Value(bytesValue: 'eHl6'); // "xyz" in base64

        expect(compare(left, right), lessThan(0));
        expect(compare(right, left), greaterThan(0));
        expect(compare(left, left), equals(0));
      });

      test('compares geopoint values', () {
        final left = firestore_v1.Value(
          geoPointValue: firestore_v1.LatLng(latitude: 37.7, longitude: -122.4),
        );
        final right = firestore_v1.Value(
          geoPointValue: firestore_v1.LatLng(latitude: 37.8, longitude: -122.4),
        );

        expect(compare(left, right), lessThan(0));
        expect(compare(right, left), greaterThan(0));
        expect(compare(left, left), equals(0));
      });

      test('compares array values', () {
        final left = firestore_v1.Value(
          arrayValue: firestore_v1.ArrayValue(
            values: [
              firestore_v1.Value(integerValue: '1'),
              firestore_v1.Value(integerValue: '2'),
            ],
          ),
        );
        final right = firestore_v1.Value(
          arrayValue: firestore_v1.ArrayValue(
            values: [
              firestore_v1.Value(integerValue: '1'),
              firestore_v1.Value(integerValue: '3'),
            ],
          ),
        );

        expect(compare(left, right), lessThan(0));
        expect(compare(right, left), greaterThan(0));
        expect(compare(left, left), equals(0));
      });

      test('compares arrays of different lengths', () {
        final shorter = firestore_v1.Value(
          arrayValue: firestore_v1.ArrayValue(
            values: [firestore_v1.Value(integerValue: '1')],
          ),
        );
        final longer = firestore_v1.Value(
          arrayValue: firestore_v1.ArrayValue(
            values: [
              firestore_v1.Value(integerValue: '1'),
              firestore_v1.Value(integerValue: '2'),
            ],
          ),
        );

        expect(compare(shorter, longer), lessThan(0));
        expect(compare(longer, shorter), greaterThan(0));
      });

      test('compares map values', () {
        final left = firestore_v1.Value(
          mapValue: firestore_v1.MapValue(
            fields: {
              'a': firestore_v1.Value(integerValue: '1'),
              'b': firestore_v1.Value(integerValue: '2'),
            },
          ),
        );
        final right = firestore_v1.Value(
          mapValue: firestore_v1.MapValue(
            fields: {
              'a': firestore_v1.Value(integerValue: '1'),
              'b': firestore_v1.Value(integerValue: '3'),
            },
          ),
        );

        expect(compare(left, right), lessThan(0));
        expect(compare(right, left), greaterThan(0));
        expect(compare(left, left), equals(0));
      });

      test('compares values of different types using type ordering', () {
        final nullValue = firestore_v1.Value(nullValue: 'NULL_VALUE');
        final boolValue = firestore_v1.Value(booleanValue: false);
        final numberValue = firestore_v1.Value(integerValue: '1');
        final timestampValue = firestore_v1.Value(
          timestampValue: '2020-01-01T00:00:00Z',
        );
        final stringValue = firestore_v1.Value(stringValue: 'abc');
        final blobValue = firestore_v1.Value(bytesValue: 'YWJj');
        final refValue = firestore_v1.Value(
          referenceValue:
              'projects/test/databases/(default)/documents/coll/doc1',
        );
        final geoValue = firestore_v1.Value(
          geoPointValue: firestore_v1.LatLng(latitude: 0, longitude: 0),
        );
        final arrayValue = firestore_v1.Value(
          arrayValue: firestore_v1.ArrayValue(values: []),
        );
        final mapValue = firestore_v1.Value(
          mapValue: firestore_v1.MapValue(fields: {}),
        );

        // Type ordering: null < bool < number < timestamp < string < blob < ref < geopoint < array < object
        expect(compare(nullValue, boolValue), lessThan(0));
        expect(compare(boolValue, numberValue), lessThan(0));
        expect(compare(numberValue, timestampValue), lessThan(0));
        expect(compare(timestampValue, stringValue), lessThan(0));
        expect(compare(stringValue, blobValue), lessThan(0));
        expect(compare(blobValue, refValue), lessThan(0));
        expect(compare(refValue, geoValue), lessThan(0));
        expect(compare(geoValue, arrayValue), lessThan(0));
        expect(compare(arrayValue, mapValue), lessThan(0));
      });
    });

    group('compareArrays()', () {
      test('compares arrays element by element', () {
        final left = [
          firestore_v1.Value(integerValue: '1'),
          firestore_v1.Value(integerValue: '2'),
        ];
        final right = [
          firestore_v1.Value(integerValue: '1'),
          firestore_v1.Value(integerValue: '3'),
        ];

        expect(compareArrays(left, right), lessThan(0));
        expect(compareArrays(right, left), greaterThan(0));
        expect(compareArrays(left, left), equals(0));
      });

      test('compares empty arrays', () {
        final empty = <firestore_v1.Value>[];
        final nonEmpty = [firestore_v1.Value(integerValue: '1')];

        expect(compareArrays(empty, empty), equals(0));
        expect(compareArrays(empty, nonEmpty), lessThan(0));
        expect(compareArrays(nonEmpty, empty), greaterThan(0));
      });

      test('handles partition cursor comparison (reference values)', () {
        // This matches the use case in CollectionGroup.getPartitions
        final partition1 = [
          firestore_v1.Value(
            referenceValue:
                'projects/test/databases/(default)/documents/coll/doc1',
          ),
        ];
        final partition2 = [
          firestore_v1.Value(
            referenceValue:
                'projects/test/databases/(default)/documents/coll/doc2',
          ),
        ];

        expect(compareArrays(partition1, partition2), lessThan(0));
        expect(compareArrays(partition2, partition1), greaterThan(0));
      });
    });

    group('UTF-8 string comparison', () {
      test('handles surrogate pairs correctly', () {
        // U+FFFD (Replacement Character) vs U+1F600 (Grinning Face emoji)
        // In UTF-8: 0xEF 0xBF 0xBD vs 0xF0 0x9F 0x98 0x80
        // Replacement should come before emoji
        final replacement = firestore_v1.Value(stringValue: '\uFFFD');
        final emoji = firestore_v1.Value(stringValue: '😀');

        expect(compare(replacement, emoji), lessThan(0));
      });

      test('compares strings character by character', () {
        final str1 = firestore_v1.Value(stringValue: 'abc');
        final str2 = firestore_v1.Value(stringValue: 'abd');

        expect(compare(str1, str2), lessThan(0));
      });
    });
  });
}
