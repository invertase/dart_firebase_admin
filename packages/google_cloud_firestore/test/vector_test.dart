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

import 'dart:async';

import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:test/test.dart';

void main() {
  // Shared Firestore instance for unit tests (no emulator needed)
  late Firestore firestore;

  setUpAll(() {
    runZoned(
      () {
        firestore = Firestore(
          settings: const Settings(projectId: 'test-project'),
        );
      },
      zoneValues: {
        envSymbol: <String, String>{'GOOGLE_CLOUD_PROJECT': 'test-project'},
      },
    );
  });
  group('VectorValue', () {
    test('constructor creates VectorValue from list', () {
      final vector = VectorValue(const [1.0, 2.0, 3.0]);
      expect(vector.toArray(), [1.0, 2.0, 3.0]);
    });

    test('constructor creates immutable copy of list', () {
      final originalList = [1.0, 2.0, 3.0];
      final vector = VectorValue(originalList);

      // Modifying original list shouldn't affect VectorValue
      originalList[0] = 100.0;
      expect(vector.toArray(), [1.0, 2.0, 3.0]);
    });

    test('toArray returns a copy', () {
      final vector = VectorValue(const [1.0, 2.0, 3.0]);
      final array1 = vector.toArray();
      final array2 = vector.toArray();

      // Arrays should be equal but not identical
      expect(array1, array2);
      expect(identical(array1, array2), false);

      // Modifying returned array shouldn't affect VectorValue
      array1[0] = 100.0;
      expect(vector.toArray(), [1.0, 2.0, 3.0]);
    });

    test('isEqual returns true for equal vectors', () {
      final vector1 = VectorValue(const [1.0, 2.0, 3.0]);
      final vector2 = VectorValue(const [1.0, 2.0, 3.0]);

      expect(vector1.isEqual(vector2), true);
    });

    test('isEqual returns false for different vectors', () {
      final vector1 = VectorValue(const [1.0, 2.0, 3.0]);
      final vector2 = VectorValue(const [1.0, 2.0, 4.0]);

      expect(vector1.isEqual(vector2), false);
    });

    test('isEqual returns false for vectors of different lengths', () {
      final vector1 = VectorValue(const [1.0, 2.0, 3.0]);
      final vector2 = VectorValue(const [1.0, 2.0]);

      expect(vector1.isEqual(vector2), false);
    });

    test('operator == works correctly', () {
      final vector1 = VectorValue(const [1.0, 2.0, 3.0]);
      final vector2 = VectorValue(const [1.0, 2.0, 3.0]);
      final vector3 = VectorValue(const [1.0, 2.0, 4.0]);

      expect(vector1 == vector2, true);
      expect(vector1 == vector3, false);
    });

    test('hashCode is consistent for equal vectors', () {
      final vector1 = VectorValue(const [1.0, 2.0, 3.0]);
      final vector2 = VectorValue(const [1.0, 2.0, 3.0]);

      expect(vector1.hashCode, vector2.hashCode);
    });

    test('empty vector is allowed', () {
      final vector = VectorValue(const []);
      expect(vector.toArray(), isEmpty);
    });
  });

  group('FieldValue.vector', () {
    test('creates VectorValue', () {
      final vector = FieldValue.vector([1.0, 2.0, 3.0]);

      expect(vector, isA<VectorValue>());
      expect(vector.toArray(), [1.0, 2.0, 3.0]);
    });
  });

  group('DistanceMeasure', () {
    test('has correct string values', () {
      expect(DistanceMeasure.euclidean.value, 'EUCLIDEAN');
      expect(DistanceMeasure.cosine.value, 'COSINE');
      expect(DistanceMeasure.dotProduct.value, 'DOT_PRODUCT');
    });
  });

  group('VectorQueryOptions', () {
    test('constructor with required parameters', () {
      const options = VectorQueryOptions(
        vectorField: 'embedding',
        queryVector: [1.0, 2.0, 3.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      expect(options.vectorField, 'embedding');
      expect(options.queryVector, [1.0, 2.0, 3.0]);
      expect(options.limit, 10);
      expect(options.distanceMeasure, DistanceMeasure.cosine);
      expect(options.distanceResultField, isNull);
      expect(options.distanceThreshold, isNull);
    });

    test('constructor with all parameters', () {
      final options = VectorQueryOptions(
        vectorField: 'embedding',
        queryVector: FieldValue.vector([1.0, 2.0, 3.0]),
        limit: 10,
        distanceMeasure: DistanceMeasure.euclidean,
        distanceResultField: 'distance',
        distanceThreshold: 0.5,
      );

      expect(options.vectorField, 'embedding');
      expect(options.queryVector, isA<VectorValue>());
      expect(options.limit, 10);
      expect(options.distanceMeasure, DistanceMeasure.euclidean);
      expect(options.distanceResultField, 'distance');
      expect(options.distanceThreshold, 0.5);
    });

    test('equality', () {
      const options1 = VectorQueryOptions(
        vectorField: 'embedding',
        queryVector: [1.0, 2.0, 3.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      const options2 = VectorQueryOptions(
        vectorField: 'embedding',
        queryVector: [1.0, 2.0, 3.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      const options3 = VectorQueryOptions(
        vectorField: 'embedding',
        queryVector: [1.0, 2.0, 3.0],
        limit: 5, // different limit
        distanceMeasure: DistanceMeasure.cosine,
      );

      expect(options1 == options2, true);
      expect(options1 == options3, false);
    });
  });

  group('Query.findNearest', () {
    test('validates empty queryVector throws error', () {
      final query = firestore.collection('collectionId');

      expect(
        () => query.findNearest(
          vectorField: 'embedding',
          queryVector: <double>[],
          limit: 10,
          distanceMeasure: DistanceMeasure.euclidean,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validates limit must be positive', () {
      final query = firestore.collection('collectionId');

      expect(
        () => query.findNearest(
          vectorField: 'embedding',
          queryVector: [10.0, 1000.0],
          limit: 0,
          distanceMeasure: DistanceMeasure.euclidean,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => query.findNearest(
          vectorField: 'embedding',
          queryVector: [10.0, 1000.0],
          limit: -1,
          distanceMeasure: DistanceMeasure.euclidean,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validates limit must be at most 1000', () {
      final query = firestore.collection('collectionId');

      expect(
        () => query.findNearest(
          vectorField: 'embedding',
          queryVector: [10.0, 1000.0],
          limit: 1001,
          distanceMeasure: DistanceMeasure.euclidean,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('accepts VectorValue as queryVector', () {
      final query = firestore.collection('collectionId');
      final vectorQuery = query.findNearest(
        vectorField: 'embedding',
        queryVector: FieldValue.vector([1.0, 2.0, 3.0]),
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      expect(vectorQuery, isA<VectorQuery<DocumentData>>());
    });

    test('accepts List<double> as queryVector', () {
      final query = firestore.collection('collectionId');
      final vectorQuery = query.findNearest(
        vectorField: 'embedding',
        queryVector: [1.0, 2.0, 3.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      expect(vectorQuery, isA<VectorQuery<DocumentData>>());
    });

    test('accepts FieldPath as vectorField', () {
      final query = firestore.collection('collectionId');
      final vectorQuery = query.findNearest(
        vectorField: FieldPath(const ['nested', 'embedding']),
        queryVector: [1.0, 2.0, 3.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      expect(vectorQuery, isA<VectorQuery<DocumentData>>());
    });
  });

  group('VectorQuery.isEqual', () {
    test('returns true for equal vector queries', () {
      final queryA = firestore
          .collection('collectionId')
          .where('foo', WhereFilter.equal, 42);
      final queryB = firestore
          .collection('collectionId')
          .where('foo', WhereFilter.equal, 42);

      final vectorQueryA = queryA.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      final vectorQueryB = queryB.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      expect(vectorQueryA.isEqual(vectorQueryB), true);
      expect(vectorQueryA == vectorQueryB, true);
    });

    test('returns false for different base queries', () {
      final queryA = firestore
          .collection('collectionId')
          .where('foo', WhereFilter.equal, 42);
      final queryB = firestore.collection('collectionId'); // No where clause

      final vectorQueryA = queryA.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      final vectorQueryB = queryB.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      expect(vectorQueryA.isEqual(vectorQueryB), false);
    });

    test('returns false for different queryVector', () {
      final queryA = firestore.collection('collectionId');
      final queryB = firestore.collection('collectionId');

      final vectorQueryA = queryA.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      final vectorQueryB = queryB.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 42.0], // Different vector
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      expect(vectorQueryA.isEqual(vectorQueryB), false);
    });

    test('returns false for different limit', () {
      final queryA = firestore.collection('collectionId');
      final queryB = firestore.collection('collectionId');

      final vectorQueryA = queryA.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      final vectorQueryB = queryB.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 1000, // Different limit
        distanceMeasure: DistanceMeasure.cosine,
      );

      expect(vectorQueryA.isEqual(vectorQueryB), false);
    });

    test('returns false for different distanceMeasure', () {
      final queryA = firestore.collection('collectionId');
      final queryB = firestore.collection('collectionId');

      final vectorQueryA = queryA.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      final vectorQueryB = queryB.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.euclidean, // Different measure
      );

      expect(vectorQueryA.isEqual(vectorQueryB), false);
    });

    test('returns false for different distanceThreshold', () {
      final queryA = firestore.collection('collectionId');
      final queryB = firestore.collection('collectionId');

      final vectorQueryA = queryA.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.euclidean,
        distanceThreshold: 1.125,
      );

      final vectorQueryB = queryB.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.euclidean,
        distanceThreshold: 0.125, // Different threshold
      );

      expect(vectorQueryA.isEqual(vectorQueryB), false);
    });

    test('returns false when one has distanceThreshold and other does not', () {
      final queryA = firestore.collection('collectionId');
      final queryB = firestore.collection('collectionId');

      final vectorQueryA = queryA.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.euclidean,
        distanceThreshold: 1,
      );

      final vectorQueryB = queryB.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.euclidean,
        // No distanceThreshold
      );

      expect(vectorQueryA.isEqual(vectorQueryB), false);
    });

    test('returns false for different distanceResultField', () {
      final queryA = firestore.collection('collectionId');
      final queryB = firestore.collection('collectionId');

      final vectorQueryA = queryA.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.euclidean,
        distanceResultField: 'distance',
      );

      final vectorQueryB = queryB.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.euclidean,
        distanceResultField: 'result', // Different field
      );

      expect(vectorQueryA.isEqual(vectorQueryB), false);
    });

    test('returns true with distanceResultField as String vs FieldPath', () {
      final queryA = firestore.collection('collectionId');
      final queryB = firestore.collection('collectionId');

      final vectorQueryA = queryA.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.euclidean,
        distanceResultField: 'distance',
      );

      final vectorQueryB = queryB.findNearest(
        vectorField: 'embedding',
        queryVector: [40.0, 41.0, 42.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.euclidean,
        distanceResultField: FieldPath(const ['distance']),
      );

      expect(vectorQueryA.isEqual(vectorQueryB), true);
    });

    test('returns true for all distance measures', () {
      for (final measure in DistanceMeasure.values) {
        final queryA = firestore.collection('collectionId');
        final queryB = firestore.collection('collectionId');

        final vectorQueryA = queryA.findNearest(
          vectorField: 'embedding',
          queryVector: [1.0],
          limit: 2,
          distanceMeasure: measure,
        );

        final vectorQueryB = queryB.findNearest(
          vectorField: 'embedding',
          queryVector: [1.0],
          limit: 2,
          distanceMeasure: measure,
        );

        expect(
          vectorQueryA.isEqual(vectorQueryB),
          true,
          reason: 'Failed for $measure',
        );
      }
    });
  });

  group('VectorQuery.query', () {
    test('returns the underlying query', () {
      final baseQuery = firestore
          .collection('collectionId')
          .where('foo', WhereFilter.equal, 42);

      final vectorQuery = baseQuery.findNearest(
        vectorField: 'embedding',
        queryVector: [1.0, 2.0, 3.0],
        limit: 10,
        distanceMeasure: DistanceMeasure.cosine,
      );

      expect(vectorQuery.query, baseQuery);
    });
  });
}
