import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:meta/meta.dart';

/// HTTP client that routes requests to appropriate underlying clients
/// based on compression handling needs.
///
/// OAuth/auth endpoints need auto-decompression to parse JSON responses.
/// Storage API endpoints need manual decompression control for data validation.
class StorageHttpClient extends http.BaseClient {
  final http.Client _withAutoDecompress;
  final http.Client _withoutAutoDecompress;
  final String _storageHost;

  StorageHttpClient._(
    this._withAutoDecompress,
    this._withoutAutoDecompress,
    String? storageEndpoint,
  ) : _storageHost = _extractStorageHost(storageEndpoint);

  static String _extractStorageHost(String? storageEndpoint) {
    if (storageEndpoint == null) {
      return 'storage.googleapis.com';
    }
    try {
      final uri = Uri.parse(storageEndpoint);
      return uri.host.isNotEmpty ? uri.host : 'storage.googleapis.com';
    } catch (_) {
      return 'storage.googleapis.com';
    }
  }

  /// Factory that creates a StorageHttpClient with properly configured clients.
  ///
  /// [storageEndpoint] The configured storage API endpoint (e.g., 'https://storage.googleapis.com').
  /// If not provided, defaults to 'storage.googleapis.com' for backward compatibility.
  factory StorageHttpClient.create([String? storageEndpoint]) {
    final autoDecompressClient = IOClient(
      io.HttpClient()..autoUncompress = true,
    );

    // Client for Storage API requests - manual decompression for validation
    final noAutoDecompressClient = IOClient(
      io.HttpClient()..autoUncompress = false,
    );

    return StorageHttpClient._(
      autoDecompressClient,
      noAutoDecompressClient,
      storageEndpoint,
    );
  }

  /// Factory for testing that allows injecting mocked clients.
  ///
  /// [withAutoDecompress] Client for non-Storage API requests (auth, metadata).
  /// [withoutAutoDecompress] Client for Storage API requests.
  /// [storageEndpoint] The configured storage API endpoint.
  @visibleForTesting
  factory StorageHttpClient.forTesting({
    required http.Client withAutoDecompress,
    required http.Client withoutAutoDecompress,
    String? storageEndpoint,
  }) {
    return StorageHttpClient._(
      withAutoDecompress,
      withoutAutoDecompress,
      storageEndpoint,
    );
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
    // Check against the configured storage host (supports custom universe domains)
    return url.host == _storageHost || url.host.endsWith('.$_storageHost');
  }

  @override
  void close() {
    _withAutoDecompress.close();
    _withoutAutoDecompress.close();
  }
}
