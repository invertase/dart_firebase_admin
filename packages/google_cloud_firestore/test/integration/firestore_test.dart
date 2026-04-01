// Copyright 2026 Google LLC
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

import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:test/test.dart';

import '../fixtures/helpers.dart';

void main() {
  group('Firestore', () {
    late Firestore firestore;

    setUp(() async => firestore = await createFirestore());

    test('listCollections', () async {
      final a = firestore.collection('a');
      final b = firestore.collection('b');

      await a.doc('1').set({'a': 1});
      await b.doc('2').set({'b': 2});

      final collections = await firestore.listCollections();

      expect(collections, containsAll([a, b]));
    });

    group('map keys with "/" characters', () {
      test('set() round-trips a map with "/" in key', () async {
        final docRef = firestore.doc('activities/new-activity');

        await docRef.set({
          'activityType': 'activityA',
          'agents': {'products/product-a': 5.0},
        });

        final data = (await docRef.get()).data()!;
        expect(data['activityType'], 'activityA');
        expect(
          (data['agents']! as Map<String, Object?>)['products/product-a'],
          5.0,
        );
      });

      test('update() round-trips a map value with "/" in key', () async {
        final docRef = firestore.doc('activities/update-activity');
        await docRef.set({'activityType': 'activityA'});

        await docRef.update({
          'agents': {'products/product-b': 10.0},
        });

        final data = (await docRef.get()).data()!;
        expect(
          (data['agents']! as Map<String, Object?>)['products/product-b'],
          10.0,
        );
      });
    });
  });
}
