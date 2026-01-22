import 'dart:convert';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/storage.dart';
import 'package:googleapis_storage/googleapis_storage.dart' hide Storage;

Future<void> storageExample(FirebaseApp admin) async {
  print('\n### Storage Example ###\n');

  // await basicExample(admin);

  await signedUrlExample(admin);
}

Future<void> basicExample(FirebaseApp admin) async {
  print('> Basic Storage usage...\n');

  final storage = Storage(admin);

  final bucket = storage.bucket('dart-firebase-admin.firebasestorage.app');

  final file = bucket.file('foo.txt');

  await file.delete();
}

Future<void> signedUrlExample(FirebaseApp admin) async {
  print('> Signed URL Storage usage...\n');

  String? url;
  try {
    final storage = Storage(admin);

    final bucket = storage.bucket('dart-firebase-admin.firebasestorage.app');
    print('> Using bucket: ${bucket.id}\n');

    final file = bucket.file('signed-url-example.txt');

    const fileContent = 'Hello from signed url example!';
    print('> Uploading file "${file.name}" to Storage...\n');
    await file.save(utf8.encode(fileContent));
    print('> ✓ File uploaded successfully!\n');

    // Verify the file exists by getting its metadata with retry logic
    // (handles eventual consistency - file might not be immediately queryable)
    FileMetadata? metadata;
    for (var i = 0; i < 3; i++) {
      try {
        metadata = await file.getMetadata();
        break;
      } catch (e) {
        if (i < 2) {
          print('> Retrying metadata fetch (${i + 1}/3)...\n');
          await Future<void>.delayed(const Duration(milliseconds: 300));
        } else {
          rethrow;
        }
      }
    }

    if (metadata != null) {
      print('> ✓ File verified in bucket: ${metadata.bucket}\n');
      print('> File size: ${metadata.size} bytes\n');
      print('> File created: ${metadata.timeCreated}\n');
    }

    final expires = DateTime.now().add(const Duration(minutes: 30));
    url = await file.getSignedUrl(
      GetFileSignedUrlOptions(action: 'read', expires: expires),
    );
    print('> ✓ Signed URL generated for ${file.name}\n');
  } catch (e, stackTrace) {
    print('> ✗ Error: $e\n');
    print('> Stack trace: $stackTrace\n');
  }

  print('Signed URL: $url\n');
  if (url != null) {
    print('You can access the file at the URL above for 30 minutes.\n');
  }
}
