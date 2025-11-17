import 'dart:io';
import 'app.dart';

import 'package:googleapis_dart_storage/googleapis_dart_storage.dart'
    as storage_api;

class Storage {
  Storage(this.app) {
    String? apiEndpoint;

    // Check for Firebase Storage emulator host
    final firebaseStorageEmulatorHost =
        Platform.environment['FIREBASE_STORAGE_EMULATOR_HOST'];
    if (firebaseStorageEmulatorHost != null) {
      if (RegExp('https?://').hasMatch(firebaseStorageEmulatorHost)) {
        // TODO: Use exception class
        throw Exception(
            'FIREBASE_STORAGE_EMULATOR_HOST should not contain a protocol (http or https).');
      }
      apiEndpoint = 'http://$firebaseStorageEmulatorHost';
    }

    _delegate = storage_api.Storage(
      storage_api.StorageOptions(
        authClient: app.client,
        apiEndpoint: apiEndpoint,
      ),
    );
  }

  final FirebaseAdminApp app;
  late final storage_api.Storage _delegate;

  storage_api.Bucket bucket(String? name) {
    // final bucketName = name ?? app.options.storageBucket;
    final bucketName = name!; // TODO: This should come from options.
    if (bucketName.isEmpty) {
      // TODO: Use exception class
      throw Exception(
        'Bucket name not specified or invalid. Specify a valid bucket name via the '
        'storageBucket option when initializing the app, or specify the bucket name '
        'explicitly when calling the bucket() method.',
      );
    }

    assert(bucketName.isNotEmpty, 'Bucket name is required');

    return _delegate.bucket(name);
  }
}
