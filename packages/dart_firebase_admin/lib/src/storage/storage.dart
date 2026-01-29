import 'package:googleapis_storage/googleapis_storage.dart'
    as googleapis_storage;
import 'package:meta/meta.dart';
import '../app.dart';

class Storage implements FirebaseService {
  /// Internal constructor
  Storage._(this.app) {
    String? apiEndpoint;
    final isEmulator = Environment.isStorageEmulatorEnabled();

    if (isEmulator) {
      final emulatorHost = Environment.getStorageEmulatorHost()!;

      if (RegExp('https?://').hasMatch(emulatorHost)) {
        throw FirebaseAppException(
          AppErrorCode.failedPrecondition,
          'FIREBASE_STORAGE_EMULATOR_HOST should not contain a protocol (http or https).',
        );
      }
      apiEndpoint = 'http://$emulatorHost';
    }

    _delegate = googleapis_storage.Storage(
      googleapis_storage.StorageOptions(
        authClient: isEmulator ? null : app.client,
        apiEndpoint: apiEndpoint,
        useAuthWithCustomEndpoint: false,
      ),
    );
  }

  /// Factory constructor that ensures singleton per app.
  @internal
  factory Storage.internal(FirebaseApp app) {
    return app.getOrInitService(FirebaseServiceType.storage.name, Storage._);
  }

  @override
  final FirebaseApp app;

  late final googleapis_storage.Storage _delegate;

  googleapis_storage.Bucket bucket(String? name) {
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
    await _delegate.terminate();
  }
}
