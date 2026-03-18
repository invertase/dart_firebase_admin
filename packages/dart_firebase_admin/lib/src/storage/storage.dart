// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:google_cloud_storage/google_cloud_storage.dart' as gcs;
import 'package:meta/meta.dart';
import '../app.dart';
import '../utils/native_environment.dart';

part 'storage_exception.dart';

class Storage implements FirebaseService {
  Storage._(this.app) {
    final isEmulator = Environment.isStorageEmulatorEnabled();

    if (isEmulator) {
      final emulatorHost = Environment.getStorageEmulatorHost()!;

      if (RegExp('https?://').hasMatch(emulatorHost)) {
        throw FirebaseAppException(
          AppErrorCode.failedPrecondition,
          'FIREBASE_STORAGE_EMULATOR_HOST should not contain a protocol (http or https).',
        );
      }
      setNativeEnvironmentVariable('STORAGE_EMULATOR_HOST', emulatorHost);
    }
    _delegate = gcs.Storage();
  }

  @internal
  factory Storage.internal(FirebaseApp app) {
    return app.getOrInitService(FirebaseServiceType.storage.name, Storage._);
  }

  @override
  final FirebaseApp app;

  late final gcs.Storage _delegate;

  gcs.Bucket bucket([String? name]) {
    final bucketName = name ?? app.options.storageBucket;
    if (bucketName == null || bucketName.isEmpty) {
      throw FirebaseAppException(
        AppErrorCode.failedPrecondition,
        'Bucket name not specified or invalid. Specify a valid bucket name via the '
        'storageBucket option when initializing the app, or specify the bucket name '
        'explicitly when calling the bucket() method.',
      );
    }

    return _delegate.bucket(bucketName);
  }

  /// Returns a long-lived download URL for the given object.
  ///
  /// The URL is signed with a download token from the Firebase Storage REST
  /// API, making it suitable for sharing with end-users. The token must exist
  /// on the object — if none is present, create one in the Firebase Console or
  /// via the Firebase Storage REST API first.
  ///
  /// Example:
  /// ```dart
  /// final storage = app.storage();
  /// final bucket = storage.bucket('my-bucket.appspot.com');
  /// final url = await storage.getDownloadURL(bucket, 'images/photo.jpg');
  /// ```
  Future<String> getDownloadURL(gcs.Bucket bucket, String objectName) async {
    final emulatorHost = Environment.getStorageEmulatorHost();
    final endpoint = emulatorHost != null
        ? 'http://$emulatorHost/v0'
        : 'https://firebasestorage.googleapis.com/v0';

    final encodedName = Uri.encodeComponent(objectName);
    final uri = Uri.parse('$endpoint/b/${bucket.name}/o/$encodedName');

    final client = await app.client;
    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw FirebaseStorageAdminException(
        StorageClientErrorCode.internalError,
        'Failed to retrieve object metadata. Status: ${response.statusCode}.',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final downloadTokens = json['downloadTokens'] as String?;

    if (downloadTokens == null || downloadTokens.isEmpty) {
      throw FirebaseStorageAdminException(
        StorageClientErrorCode.noDownloadToken,
      );
    }

    final token = downloadTokens.split(',').first;
    return '$endpoint/b/${bucket.name}/o/$encodedName?alt=media&token=$token';
  }

  @override
  Future<void> delete() async {
    _delegate.close();
  }
}
