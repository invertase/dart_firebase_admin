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
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:firebase_admin_sdk/storage.dart';

Future<void> storageExample(FirebaseApp admin) async {
  print('\n### Storage Example ###\n');

  await basicExample(admin);
  await getDownloadURLExample(admin);
}

Future<void> basicExample(FirebaseApp admin) async {
  print('> Basic Storage usage...\n');

  try {
    final storage = admin.storage();

    final bucket = storage.bucket('dart-firebase-admin.firebasestorage.app');
    print('> Using bucket: ${bucket.name}\n');

    const objectName = 'foo.txt';
    const fileContent = 'Hello from basicExample() in storage_example.dart';

    print('> Uploading "$objectName" to Storage...\n');
    await bucket.storage.uploadObject(
      bucket.name,
      objectName,
      utf8.encode(fileContent),
    );
    print('> ✓ File uploaded successfully!\n');

    final metadata = await bucket.storage.objectMetadata(
      bucket.name,
      objectName,
    );
    print('> File size: ${metadata.size} bytes\n');
    print('> Content type: ${metadata.contentType}\n');

    final downloaded = await bucket.storage.downloadObject(
      bucket.name,
      objectName,
    );
    print('> Downloaded content: ${utf8.decode(downloaded)}\n');

    print('> Deleting "$objectName"...\n');
    await bucket.storage.deleteObject(bucket.name, objectName);
    print('> ✓ File deleted successfully!\n');
  } catch (e, stackTrace) {
    print('> ✗ Error: $e\n');
    print('> Stack trace: $stackTrace\n');
  }
}

Future<void> getDownloadURLExample(FirebaseApp admin) async {
  print('> getDownloadURL usage...\n');

  final storage = admin.storage();
  final bucket = storage.bucket('dart-firebase-admin.firebasestorage.app');
  const objectName = 'download-url-example.txt';

  try {
    await bucket.storage.uploadObject(
      bucket.name,
      objectName,
      utf8.encode('Hello from getDownloadURLExample()!'),
    );
    print('> ✓ File uploaded\n');

    final url = await storage.getDownloadURL(bucket, objectName);
    print('> Download URL: $url\n');
  } on FirebaseStorageAdminException catch (e) {
    if (e.errorCode == StorageClientErrorCode.noDownloadToken) {
      print(
        '> No download token available. Create one in the Firebase Console.\n',
      );
    } else {
      print('> ✗ Error: $e\n');
    }
  } finally {
    await bucket.storage.deleteObject(bucket.name, objectName);
    print('> ✓ File cleaned up\n');
  }
}
