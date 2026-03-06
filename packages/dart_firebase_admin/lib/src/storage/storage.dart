import 'dart:convert';

import 'package:google_cloud_storage/google_cloud_storage.dart' as gcs;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import '../app.dart';

part 'storage_exception.dart';

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
    // _delegate.close() calls close() on our _DeferredHttpClient, which is a
    // no-op, so the externally-managed http client is not closed here.
    _delegate.close();
  }
}
