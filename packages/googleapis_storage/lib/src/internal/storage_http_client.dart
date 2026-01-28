import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// HTTP client that routes requests to appropriate underlying clients
/// based on compression handling needs.
///
/// OAuth/auth endpoints need auto-decompression to parse JSON responses.
/// Storage API endpoints need manual decompression control for data validation.
class StorageHttpClient extends http.BaseClient {
  final http.Client _withAutoDecompress;
  final http.Client _withoutAutoDecompress;

  StorageHttpClient(this._withAutoDecompress, this._withoutAutoDecompress);

  /// Factory that creates a StorageHttpClient with properly configured clients.
  factory StorageHttpClient.create() {
    final autoDecompressClient = IOClient(
      io.HttpClient()..autoUncompress = true,
    );

    // Client for Storage API requests - manual decompression for validation
    final noAutoDecompressClient = IOClient(
      io.HttpClient()..autoUncompress = false,
    );

    return StorageHttpClient(autoDecompressClient, noAutoDecompressClient);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Storage API handles compression manually for validation
    if (_isStorageRequest(request.url)) {
      return _withoutAutoDecompress.send(request);
    }
    // Everything else (auth, metadata API, etc.) uses auto-decompress
    return _withAutoDecompress.send(request);
  }

  /// Returns true if this is a Cloud Storage API request.
  bool _isStorageRequest(Uri url) {
    return url.host == 'storage.googleapis.com' ||
        url.host.endsWith('.storage.googleapis.com');
  }

  @override
  void close() {
    _withAutoDecompress.close();
    _withoutAutoDecompress.close();
  }
}
