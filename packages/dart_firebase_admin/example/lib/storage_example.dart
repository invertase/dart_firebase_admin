import 'dart:convert';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

Future<void> storageExample(FirebaseApp admin) async {
  print('\n### Storage Example ###\n');

  await basicExample(admin);
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
    await bucket.storage.insertObject(
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
