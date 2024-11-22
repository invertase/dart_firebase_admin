// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';
import 'dart:math';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';
import 'util/helpers.dart' as helpers;

void main() {
  group(
    'Transaction',
    () {
      late Firestore firestore;

      setUp(() => firestore = helpers.createFirestore());

      Future<DocumentReference<Map<String, dynamic>>> initializeTest(
        String path,
      ) async {
        final String prefixedPath = 'flutter-tests/$path';
        await firestore.doc(prefixedPath).delete();
        return firestore.doc(prefixedPath);
      }

      test(
        'get a document in a transaction',
        () async {
          final DocumentReference<Map<String, dynamic>> docRef =
              await initializeTest('simpleDocument');

          await docRef.set({'value': 42});

          expect(
            await firestore.runTransactionRemake(
              (transaction) async {
                final snapshot = await transaction.get(docRef);
                return snapshot.data()!['value'];
              },
            ),
            42,
          );
        },
      );

      test(
        'set a document in a transaction',
        () async {
          final DocumentReference<Map<String, dynamic>> docRef =
              await initializeTest('simpleDocument');

          await firestore.runTransactionRemake(
            (transaction) async {
              transaction.set(docRef, {'value': 44});
            },
          );

          expect(
            (await docRef.get()).data()!['value'],
            44,
          );
        },
      );
      test(
        'get and set a document in a transaction',
        () async {
          final DocumentReference<Map<String, dynamic>> docRef =
              await initializeTest('simpleDocument');

          await docRef.set({'value': 42});

          DocumentSnapshot<Map<String, dynamic>> getData;
          DocumentSnapshot<Map<String, dynamic>> setData;

          getData = await firestore.runTransactionRemake(
            (transaction) async {
              var _getData = await transaction.get(docRef);
              transaction.set(docRef, {'value': 44});
              return _getData;
            },
          );

          setData = await docRef.get();

          expect(
            getData.data()!['value'],
            42,
          );

          expect(
            setData.data()!['value'],
            44,
          );
        },
      );
    },
  );
}
