import 'package:google_cloud_storage/google_cloud_storage.dart';

void main() async {
  final storage = Storage(
    StorageOptions(
      // apiEndpoint: 'http://localhost:9000',
    ),
  );

  final bucket = storage.bucket('test-bucket');

  final file = bucket.file('test-file.txt');

  await file.delete();
}
