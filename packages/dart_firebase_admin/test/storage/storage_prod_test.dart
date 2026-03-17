// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:google_cloud_storage/google_cloud_storage.dart' as gcs;
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  const testBucketName = 'dart-firebase-admin.firebasestorage.app';
  const productionEndpoint = 'https://firebasestorage.googleapis.com/v0';

  group('Storage (Production)', () {
    group('getDownloadURL()', () {
      test(
        'returns a URL that can be used to download the file',
        () {
          return runZoned(() async {
            final app = createApp();
            final storage = app.storage();
            final bucket = storage.bucket(testBucketName);
            final objectName =
                'download-url-${DateTime.now().millisecondsSinceEpoch}.txt';

            const uploadedContent = 'Download URL test';

            addTearDown(() async {
              try {
                await bucket.storage.deleteObject(bucket.name, objectName);
              } catch (_) {}
            });

            await bucket.storage.insertObject(
              bucket.name,
              objectName,
              Uint8List.fromList(uploadedContent.codeUnits),
              metadata: gcs.ObjectMetadata(contentType: 'text/plain'),
            );

            final url = await storage.getDownloadURL(bucket, objectName);

            expect(url, startsWith('$productionEndpoint/b/$testBucketName/o/'));
            expect(url, contains('?alt=media&token='));

            // Verify the URL actually serves the uploaded file content.
            final response = await http.get(Uri.parse(url));
            expect(response.statusCode, 200);
            expect(response.body, uploadedContent);
          }, zoneValues: {envSymbol: prodEnv()});
        },
        skip: hasProdEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
        timeout: const Timeout(Duration(seconds: 30)),
      );

      test(
        'URL-encodes object names with special characters',
        () {
          return runZoned(() async {
            final app = createApp();
            final storage = app.storage();
            final bucket = storage.bucket(testBucketName);
            final objectName =
                'folder/download url test ${DateTime.now().millisecondsSinceEpoch}.txt';

            const uploadedContent = 'content';

            addTearDown(() async {
              try {
                await bucket.storage.deleteObject(bucket.name, objectName);
              } catch (_) {}
            });

            await bucket.storage.insertObject(
              bucket.name,
              objectName,
              Uint8List.fromList(uploadedContent.codeUnits),
              metadata: gcs.ObjectMetadata(contentType: 'text/plain'),
            );

            final url = await storage.getDownloadURL(bucket, objectName);

            expect(url, contains(Uri.encodeComponent(objectName)));

            // Verify the encoded URL actually serves the uploaded file content.
            final response = await http.get(Uri.parse(url));
            expect(response.statusCode, 200);
            expect(response.body, uploadedContent);
          }, zoneValues: {envSymbol: prodEnv()});
        },
        skip: hasProdEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });
  });
}
