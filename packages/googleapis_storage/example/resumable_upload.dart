import 'dart:io' as io;

import 'package:googleapis_storage/googleapis_storage.dart';

/// Example demonstrating resumable uploads with Google Cloud Storage.
///
/// This example shows two ways to upload files:
/// 1. Using [Bucket.upload()] - convenient method for uploading from filesystem
/// 2. Using [File.createWriteStream()] - more control over the upload process
///
/// Note: Storage automatically uses Application Default Credentials (ADC) when
/// no authClient is provided. ADC checks in this order:
/// 1. GOOGLE_APPLICATION_CREDENTIALS environment variable
/// 2. gcloud CLI credentials (gcloud auth application-default login)
/// 3. GCE/Cloud Run metadata service (when running on Google Cloud)
void main() async {
  final storage = Storage(
    StorageOptions(
      projectId: 'probable-anchor-479210-j7',
      // Uncomment to use emulator:
      // apiEndpoint: 'http://localhost:9000',
    ),
  );

  final bucket = storage.bucket('probable-anchor-test-bucket');

  if (await bucket.exists()) {
    print('Bucket already exists');
  } else {
    await bucket.create(BucketMetadata()..name = 'probable-anchor-test-bucket');
  }

  try {
    print('');
    final largeFile = io.File('example/three-mb-file.tif');

    // Example 1: Upload using Bucket.upload() - simplest method
    print('Example 1: Uploading using Bucket.upload()...');
    print('largeFile: ${largeFile.absolute.path}');
    final uploadedFile = await bucket.upload(
      largeFile,
      UploadOptions(
        destination: UploadDestination.path('uploaded-three-mb-file.tif'),
        // Optional: set metadata
        metadata: FileMetadata()
          ..contentType = 'image/tiff'
          ..metadata = {'uploaded-by': 'resumable_upload_example'},
        // Optional: enable gzip compression (auto-detects based on content type)
        gzip: null, // null = auto-detect
        // Optional: validation
        validation: ValidationType.crc32c,
      ),
    );
    print('✓ Upload complete! File: ${uploadedFile.name}');
    print('  Size: ${uploadedFile.metadata.size} bytes');
    print('  CRC32C: ${uploadedFile.metadata.crc32c}');

    // Example 2: Upload using File.createWriteStream() - more control
    // print('\nExample 2: Uploading using File.createWriteStream()...');
    // final file = bucket.file('streamed-three-mb-file.tif');
    // final writeStream = file.createWriteStream(
    //   CreateWriteStreamOptions(
    //     contentType: 'image/tiff',
    //     gzip: null, // auto-detect
    //     validation: ValidationType.crc32c,
    //     metadata: FileMetadata()
    //       ..metadata = {'uploaded-by': 'createWriteStream'},
    //   ),
    // );

    // // Read file and write to stream
    // final fileStream = largeFile.openRead();

    // await for (final chunk in fileStream) {
    //   writeStream.add(chunk);
    // }

    // await writeStream.close();
    // await writeStream.done;

    // print('✓ Stream upload complete!');

    // // Get metadata to verify
    // final metadata = await file.getMetadata();
    // print('  File: ${metadata.name}');
    // print('  Size: ${metadata.size} bytes');
    // print('  CRC32C: ${metadata.crc32c}');

    // Example 3: Create resumable upload URI (for advanced use cases)
    // print('\nExample 3: Creating resumable upload URI...');
    // final resumableFile = bucket.file('resumable-three-mb-file.tif');
    // final uploadUri = await resumableFile.createResumableUpload(
    //   CreateResumableUploadOptions(
    //     metadata: FileMetadata()
    //       ..contentType = 'image/tiff'
    //       ..metadata = {'uploaded-by': 'createResumableUpload'},
    //     userProject: null,
    //   ),
    // );
    // print('✓ Resumable upload URI created: $uploadUri');
    // print('  You can use this URI to resume uploads later');

    print('\n✓ All examples completed successfully!');
    print(
      '\nNote: The bucket "probable-anchor-test-bucket" was created for this example.',
    );
    print('You may want to delete it when done:');
    print('  await bucket.delete();');
    io.exit(0);
  } catch (e, stackTrace) {
    print('✗ Error: $e');
    print('Stack trace: $stackTrace');
    io.exit(1);
  }
}
