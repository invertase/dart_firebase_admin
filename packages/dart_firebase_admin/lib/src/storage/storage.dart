import 'package:google_cloud_storage/google_cloud_storage.dart' as gcs;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import '../app.dart';

/// An [http.BaseClient] that lazily resolves the real client on each request.
///
/// This allows [Storage] to be constructed synchronously even though
/// [FirebaseApp.client] is asynchronous. The underlying client lifecycle is
/// managed externally (by [FirebaseApp]), so [close] is a no-op here.
class _DeferredHttpClient extends http.BaseClient {
  _DeferredHttpClient(this._clientFuture);

  final Future<http.Client> _clientFuture;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return (await _clientFuture).send(request);
  }

  @override
  void close() {
    // The underlying client is managed externally; do not close it here.
  }
}

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
      // The new gcs.Storage adds the http:// scheme automatically when
      // useAuthWithCustomEndpoint is false, so pass only host:port.
      apiEndpoint = emulatorHost;
    }

    // For emulator, use the provided httpClient (e.g. a mock in tests) or a
    // plain unauthenticated client. For production, wrap the async auth client
    // in a _DeferredHttpClient so construction stays synchronous.
    final http.Client httpClient = isEmulator
        ? _DeferredHttpClient(
            Future.value(app.options.httpClient ?? http.Client()),
          )
        : _DeferredHttpClient(app.client);

    _delegate = gcs.Storage(
      client: httpClient,
      apiEndpoint: apiEndpoint,
      useAuthWithCustomEndpoint: false,
    );
  }

  /// Factory constructor that ensures singleton per app.
  @internal
  factory Storage.internal(FirebaseApp app) {
    return app.getOrInitService(FirebaseServiceType.storage.name, Storage._);
  }

  @override
  final FirebaseApp app;

  late final gcs.Storage _delegate;

  gcs.Bucket bucket(String? name) {
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
    // _delegate.close() calls close() on our _DeferredHttpClient, which is a
    // no-op, so the externally-managed http client is not closed here.
    _delegate.close();
  }
}
