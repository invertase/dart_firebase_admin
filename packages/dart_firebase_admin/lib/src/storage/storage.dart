import 'package:google_cloud_storage/google_cloud_storage.dart'
    as google_cloud_storage;
import 'package:meta/meta.dart';
import '../app.dart';
import '../utils/native_environment.dart';

class Storage implements FirebaseService {
  /// Internal constructor
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

    _delegate = google_cloud_storage.Storage();
  }

  /// Factory constructor that ensures singleton per app.
  @internal
  factory Storage.internal(FirebaseApp app) {
    return app.getOrInitService(FirebaseServiceType.storage.name, Storage._);
  }

  @override
  final FirebaseApp app;

  late final google_cloud_storage.Storage _delegate;

  google_cloud_storage.Bucket bucket([String? name]) {
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

  @override
  Future<void> delete() async {
    _delegate.close();
  }
}
