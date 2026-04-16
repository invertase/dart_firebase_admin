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

import 'dart:convert';
import 'dart:io';

import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../fixtures/helpers.dart';

/// Seeds a Firestore document directly via the emulator REST API, bypassing
/// the Dart SDK's serializer. This lets us create documents with special double
/// values (Infinity, -Infinity, NaN) that the SDK's write path currently can't
/// encode, so we can test the read path independently.
Future<void> _seedDocumentWithSpecialDoubles(
  String docPath,
  Map<String, Object?> fields,
) async {
  final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST']!;
  final uri = Uri.http(
    emulatorHost,
    '/v1/projects/$projectId/databases/(default)/documents/$docPath',
  );

  final encodedFields = fields.map((key, value) {
    final encoded = switch (value) {
      double.infinity => {'doubleValue': 'Infinity'},
      double.negativeInfinity => {'doubleValue': '-Infinity'},
      _ when value is double && value.isNaN => {'doubleValue': 'NaN'},
      _ => throw ArgumentError('Unsupported seed value: $value'),
    };
    return MapEntry(key, encoded);
  });

  final response = await http.patch(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'fields': encodedFields}),
  );

  if (response.statusCode != 200) {
    throw StateError(
      'Failed to seed document at $docPath: '
      '${response.statusCode} ${response.body}',
    );
  }
}

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

    group('special IEEE 754 double values', () {
      group('write path', () {
        test('set() round-trips double.infinity', () async {
          final ref = firestore.collection('special-doubles').doc();
          await ref.set({'value': double.infinity});

          final data = (await ref.get()).data()!;
          expect(data['value'], double.infinity);
        });

        test('set() round-trips double.negativeInfinity', () async {
          final ref = firestore.collection('special-doubles').doc();
          await ref.set({'value': double.negativeInfinity});

          final data = (await ref.get()).data()!;
          expect(data['value'], double.negativeInfinity);
        });

        test('set() round-trips double.nan', () async {
          final ref = firestore.collection('special-doubles').doc();
          await ref.set({'value': double.nan});

          final data = (await ref.get()).data()!;
          expect(data['value'], isNaN);
        });
      });

      group('read path', () {
        test('get() decodes Infinity seeded via REST API', () async {
          final ref = firestore.collection('special-doubles').doc();
          await _seedDocumentWithSpecialDoubles('special-doubles/${ref.id}', {
            'value': double.infinity,
          });

          final data = (await ref.get()).data()!;
          expect(data['value'], double.infinity);
        });

        test('get() decodes -Infinity seeded via REST API', () async {
          final ref = firestore.collection('special-doubles').doc();
          await _seedDocumentWithSpecialDoubles('special-doubles/${ref.id}', {
            'value': double.negativeInfinity,
          });

          final data = (await ref.get()).data()!;
          expect(data['value'], double.negativeInfinity);
        });

        test('get() decodes NaN seeded via REST API', () async {
          final ref = firestore.collection('special-doubles').doc();
          await _seedDocumentWithSpecialDoubles('special-doubles/${ref.id}', {
            'value': double.nan,
          });

          final data = (await ref.get()).data()!;
          expect(data['value'], isNaN);
        });
      });

      group('query path', () {
        test('query results decode documents with Infinity', () async {
          final ref = firestore.collection('special-doubles-query').doc();
          await _seedDocumentWithSpecialDoubles(
            'special-doubles-query/${ref.id}',
            {'value': double.infinity},
          );

          final results = await firestore
              .collection('special-doubles-query')
              .get();

          expect(results.docs, isNotEmpty);
          final data = results.docs.first.data();
          expect(data['value'], double.infinity);
        });
      });
    });
  });
}
