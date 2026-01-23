part of '../googleapis_storage.dart';

/// Configuration for a resumable upload.
///
/// This is an internal implementation detail and should not be used directly.
class _ResumableUploadConfig {
  /// The storage instance.
  final Storage storage;

  /// The bucket name.
  final String bucket;

  /// The file name.
  final String file;

  /// The resumable upload URI. If not provided, will be created using [createUriCallback].
  final String? uri;

  /// The starting byte offset for resuming an interrupted upload.
  final int? offset;

  /// Chunk size for resumable uploads. Default: 256KB
  final int chunkSize;

  /// File metadata.
  final FileMetadata metadata;

  /// Encryption key for customer-supplied encryption.
  final EncryptionKey? encryptionKey;

  /// User project for billing.
  final String? userProject;

  /// Whether this is a partial upload.
  final bool isPartialUpload;

  /// Callback to create the resumable upload URI. Used when [uri] is not provided.
  final Future<String> Function()? createUriCallback;

  /// Callback when metadata is received from the server.
  final void Function(FileMetadata metadata)? onMetadataReceived;

  /// Callback for upload progress events.
  final void Function(UploadProgress)? onUploadProgress;

  const _ResumableUploadConfig({
    required this.storage,
    required this.bucket,
    required this.file,
    this.uri,
    this.offset,
    this.chunkSize = 256 * 1024, // 256KB default
    required this.metadata,
    this.encryptionKey,
    this.userProject,
    this.isPartialUpload = false,
    this.createUriCallback,
    this.onMetadataReceived,
    this.onUploadProgress,
  });
}

/// A stream sink that handles resumable uploads to Google Cloud Storage.
///
/// This class manages chunked uploads, retries, and resume logic for
/// resumable uploads. It buffers incoming data into chunks and uploads them
/// sequentially, handling retries and session expiration.
///
/// This is an internal implementation detail and should not be used directly.
class _ResumableUploadSink implements StreamSink<List<int>> {
  final _ResumableUploadConfig _config;
  final StreamController<List<int>> _controller;
  final Completer<String> _uploadUriCompleter = Completer<String>();
  final Completer<void> _uploadCompleter = Completer<void>();
  String? _uploadUri;
  int _bytesWritten;
  final List<List<int>> _chunkBuffer = [];
  int _chunkBufferSize = 0;
  bool _isUploading = false;
  int _numRetries = 0;
  late final DateTime _timeOfFirstRequest;
  bool _isProcessingChunks = false;

  /// Whether the upstream stream has ended.
  ///
  /// Used to determine if a chunk is the last one in the upload.
  bool _upstreamEnded = false;

  _ResumableUploadSink(this._config)
    : _controller = StreamController<List<int>>(),
      _bytesWritten = _config.offset ?? 0,
      _uploadUri = _config.uri,
      _timeOfFirstRequest = DateTime.now() {
    _initialize();
  }

  /// Initialize the upload sink by creating the upload URI if needed and
  /// setting up the stream listener to buffer and process incoming data.
  void _initialize() {
    // Create resumable upload session URI if not provided
    if (_uploadUri == null) {
      _createUploadUri()
          .then((uri) {
            _uploadUri = uri;
            _uploadUriCompleter.complete(uri);
            // Trigger chunk processing once URI is ready
            _processChunks();
          })
          .catchError((error) {
            _uploadUriCompleter.completeError(error);
          });
    } else {
      _uploadUriCompleter.complete(_uploadUri);
    }

    _controller.stream.listen(
      (data) {
        _chunkBuffer.add(data);
        _chunkBufferSize += data.length;

        // Trigger chunk processing (non-blocking) - will process if URI is ready
        _processChunks();
      },
      onDone: () async {
        _upstreamEnded = true;
        try {
          // Ensure upload URI is ready before processing final chunks
          _uploadUri ??= await _uploadUriCompleter.future;

          // Process any remaining full chunks first
          await _processChunks();

          // Wait for any in-flight uploads to complete before handling final chunk
          while (_isUploading) {
            await Future.delayed(const Duration(milliseconds: 10));
          }

          // Upload any remaining buffered data as the final chunk
          if (_chunkBuffer.isNotEmpty || _chunkBufferSize > 0) {
            _isUploading = true;
            try {
              final chunk = <int>[];
              for (final buf in _chunkBuffer) {
                chunk.addAll(buf);
              }
              _chunkBuffer.clear();
              _chunkBufferSize = 0;

              final startByte = _bytesWritten;
              final endByte = _bytesWritten + chunk.length;

              await _uploadChunk(chunk, startByte, endByte, true);
              _bytesWritten = endByte;

              // Report progress after final chunk is uploaded
              _config.onUploadProgress?.call(
                UploadProgress(
                  bytesWritten: _bytesWritten,
                  totalBytes: _config.metadata.size != null
                      ? int.tryParse(_config.metadata.size!)
                      : null,
                ),
              );
            } finally {
              _isUploading = false;
            }
          } else if (_bytesWritten == 0) {
            // Empty file - upload empty chunk
            _isUploading = true;
            try {
              await _uploadChunk([], 0, 0, true);
            } finally {
              _isUploading = false;
            }
          } else {
            // All chunks already uploaded - check if upload is complete
            // Query the server to see if upload is complete
            _isUploading = true;
            try {
              final statusResponse = await _checkUploadStatus();
              if (statusResponse.statusCode == 200 ||
                  statusResponse.statusCode == 201) {
                // Upload is complete
                // Parse metadata if available
                try {
                  final body = await statusResponse.stream.bytesToString();
                  if (body.isNotEmpty) {
                    final json = jsonDecode(body) as Map<String, dynamic>;
                    final metadata = FileMetadata.fromJson(json);
                    _config.onMetadataReceived?.call(metadata);
                  }
                } catch (e) {
                  // Ignore parse errors
                }
              } else if (statusResponse.statusCode == 308) {
                // Upload not complete - server is waiting for more data.
                // This can happen if the last chunk wasn't marked as final.
                // Get the current offset from the Range header
                final rangeHeader = statusResponse.headers['range'];
                int currentOffset = _bytesWritten;
                if (rangeHeader != null) {
                  final parts = rangeHeader.split('-');
                  if (parts.length >= 2) {
                    try {
                      currentOffset = int.parse(parts[1]) + 1;
                    } catch (e) {
                      // Ignore parse errors, use _bytesWritten as fallback
                    }
                  }
                }

                // If server has all bytes but returned 308, the upload is complete.
                // This can happen due to timing - the server may not have processed
                // the final chunk yet, but all data has been uploaded.
                if (currentOffset >= _bytesWritten && _bytesWritten > 0) {
                  // Upload is complete, all bytes have been uploaded
                } else {
                  throw ApiError(
                    'Server offset ($currentOffset) is less than bytes written ($_bytesWritten)',
                    code: 500,
                  );
                }
              } else if (statusResponse.statusCode == 400 &&
                  _config.storage.config.customEndpoint == true) {
                // Firebase Storage emulator may not support status check queries.
                // If we've uploaded all bytes, assume upload is complete.
                if (_bytesWritten > 0) {
                  // Upload is complete - emulator doesn't support status check
                } else {
                  throw ApiError(
                    'Unexpected status when checking upload completion: ${statusResponse.statusCode}',
                    code: statusResponse.statusCode,
                  );
                }
              } else {
                throw ApiError(
                  'Unexpected status when checking upload completion: ${statusResponse.statusCode}',
                  code: statusResponse.statusCode,
                );
              }
            } finally {
              _isUploading = false;
            }
          }

          await _controller.close();

          // Complete the upload completer to signal that all uploads are done
          if (!_uploadCompleter.isCompleted) {
            _uploadCompleter.complete();
          }
        } catch (e, stackTrace) {
          // If controller is already closed, the error will be ignored
          // Otherwise, add the error before closing
          try {
            _controller.addError(e, stackTrace);
          } catch (_) {
            // Controller might already be closed, ignore
          }
          try {
            await _controller.close();
          } catch (_) {
            // Controller might already be closed, ignore
          }

          // Complete with error
          if (!_uploadCompleter.isCompleted) {
            _uploadCompleter.completeError(e, stackTrace);
          }
        }
      },
      onError: (error, stackTrace) {
        // If controller is already closed, the error will be ignored
        try {
          _controller.addError(error, stackTrace);
        } catch (_) {
          // Controller might already be closed, ignore
        }
      },
      cancelOnError: false,
    );
  }

  /// Process chunks from the buffer, uploading them as they reach chunkSize.
  /// This method is called whenever new data arrives or when the URI becomes ready.
  /// It processes all available full chunks sequentially.
  Future<void> _processChunks() async {
    // Prevent concurrent calls to _processChunks
    if (_isProcessingChunks) {
      return;
    }
    _isProcessingChunks = true;

    try {
      // Ensure URI is ready before processing
      if (_uploadUri == null) {
        // URI not ready yet, will be triggered when URI is ready
        return;
      }

      // Process all chunks that are ready (must be at least chunkSize, or stream is done)
      // Continue processing until buffer is less than chunkSize AND stream hasn't ended
      // If stream has ended, process all remaining chunks regardless of size
      while (_chunkBufferSize >= _config.chunkSize ||
          (_upstreamEnded && _chunkBufferSize > 0)) {
        // Only process if not already uploading a chunk
        if (_isUploading) {
          // Wait for current upload to finish
          while (_isUploading) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
          continue;
        }

        _isUploading = true;
        try {
          final chunk = <int>[];
          var chunkLength = 0;
          while (chunkLength < _config.chunkSize && _chunkBuffer.isNotEmpty) {
            final next = _chunkBuffer.removeAt(0);
            chunk.addAll(next);
            chunkLength += next.length;
            _chunkBufferSize -= next.length;
          }

          final startByte = _bytesWritten;
          final endByte = _bytesWritten + chunkLength;

          // Determine if this is the last chunk in the upload.
          // A chunk is the last one if:
          // 1. The upstream stream has ended (_upstreamEnded is true)
          // 2. After extracting this chunk, the buffer is empty
          // This ensures we mark the final chunk correctly so the server knows
          // the upload is complete.
          final isLast =
              _upstreamEnded && (_chunkBuffer.isEmpty && _chunkBufferSize == 0);

          await _uploadChunk(chunk, startByte, endByte, isLast);
          _bytesWritten = endByte;

          // Report progress after chunk is uploaded
          _config.onUploadProgress?.call(
            UploadProgress(
              bytesWritten: _bytesWritten,
              totalBytes: _config.metadata.size != null
                  ? int.tryParse(_config.metadata.size!)
                  : null,
            ),
          );
        } catch (e, stackTrace) {
          // If controller is already closed, the error will be ignored
          try {
            _controller.addError(e, stackTrace);
          } catch (_) {
            // Controller might already be closed, ignore
          }
          return;
        } finally {
          _isUploading = false;
        }
      }
    } finally {
      _isProcessingChunks = false;
    }
  }

  Future<String> _createUploadUri() async {
    if (_config.createUriCallback != null) {
      return await _config.createUriCallback!();
    }

    // Fallback: create URI directly (simpler case without preconditions, etc.)
    final apiEndpoint = _config.storage.config.apiEndpoint;
    final queryParams = <String, String>{
      'uploadType': 'resumable',
      'name': _config.file,
    };

    if (_config.metadata.contentType != null) {
      queryParams['contentType'] = _config.metadata.contentType!;
    }

    if (_config.userProject != null) {
      queryParams['userProject'] = _config.userProject!;
    }

    final uri = Uri.parse(apiEndpoint).replace(
      path: '/upload/storage/v1/b/${_config.bucket}/o',
      queryParameters: queryParams,
    );

    final authClient = await _config.storage.authClient;
    final request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'application/json; charset=utf-8';
    request.headers['x-upload-content-type'] =
        _config.metadata.contentType ?? 'application/octet-stream';

    if (_config.metadata.size != null) {
      request.headers['x-upload-content-length'] = _config.metadata.size
          .toString();
    }

    // Add encryption headers if encryption key is set
    if (_config.encryptionKey != null) {
      request.headers['x-goog-encryption-algorithm'] = 'AES256';
      request.headers['x-goog-encryption-key'] =
          _config.encryptionKey!.keyBase64;
      request.headers['x-goog-encryption-key-sha256'] =
          _config.encryptionKey!.keyHash;
    }

    // Serialize metadata to JSON
    final metadataJson = <String, dynamic>{};
    if (_config.metadata.name != null) {
      metadataJson['name'] = _config.metadata.name;
    }
    if (_config.metadata.contentType != null) {
      metadataJson['contentType'] = _config.metadata.contentType;
    }
    if (_config.metadata.contentEncoding != null) {
      metadataJson['contentEncoding'] = _config.metadata.contentEncoding;
    }
    if (_config.metadata.metadata != null) {
      metadataJson['metadata'] = _config.metadata.metadata;
    }
    request.body = jsonEncode(metadataJson);

    final response = await authClient.send(request);
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiError(
        'Failed to create resumable upload URI',
        code: response.statusCode,
        details: body,
      );
    }

    final location = response.headers['location'];
    if (location == null) {
      throw ApiError(
        'Invalid response for resumable upload attempt: missing location header',
        code: response.statusCode,
      );
    }

    return location;
  }

  /// Check the upload status by querying the server.
  /// Returns the HTTP response.
  Future<http.StreamedResponse> _checkUploadStatus() async {
    _uploadUri ??= await _uploadUriCompleter.future;

    final authClient = await _config.storage.authClient;
    final uri = Uri.parse(_uploadUri!);
    final request = http.Request('PUT', uri);
    request.headers['Content-Range'] = 'bytes */*';
    request.headers['Content-Length'] = '0';

    return await authClient.send(request);
  }

  /// Query the server to get the current upload offset.
  Future<int> _queryUploadOffset() async {
    _uploadUri ??= await _uploadUriCompleter.future;

    final authClient = await _config.storage.authClient;
    final uri = Uri.parse(_uploadUri!);
    final request = http.Request('PUT', uri);
    request.headers['Content-Range'] = 'bytes */*';
    request.headers['Content-Length'] = '0';

    final response = await authClient.send(request);

    if (response.statusCode == 308) {
      final rangeHeader = response.headers['range'];
      if (rangeHeader != null) {
        // Parse Range header: "bytes=0-123" -> split('-')[1] -> "123"
        final parts = rangeHeader.split('-');
        if (parts.length >= 2) {
          try {
            final offset = int.parse(parts[1]) + 1;
            return offset;
          } catch (e) {
            // Ignore parse errors
          }
        }
      }
    }

    // If no range header, assume 0
    return 0;
  }

  Future<void> _uploadChunk(
    List<int> chunk,
    int startByte,
    int endByte,
    bool isLastChunk,
  ) async {
    return _uploadChunkWithRetry(chunk, startByte, endByte, isLastChunk, 0);
  }

  Future<void> _uploadChunkWithRetry(
    List<int> chunk,
    int startByte,
    int endByte,
    bool isLastChunk,
    int attempt,
  ) async {
    _uploadUri ??= await _uploadUriCompleter.future;

    final authClient = await _config.storage.authClient;
    final uri = Uri.parse(_uploadUri!);

    final request = http.Request('PUT', uri);
    request.headers['Content-Type'] =
        _config.metadata.contentType ?? 'application/octet-stream';
    request.headers['Content-Length'] = chunk.length.toString();

    // Build Content-Range header according to GCS resumable upload spec.
    // Format: "bytes startByte-endByte/totalSize" for final chunks,
    // or "bytes startByte-endByte/*" for intermediate chunks.
    // Note: endByte is exclusive in our code, so we use endByte-1 in the header.
    String contentRange;
    if (isLastChunk && chunk.isEmpty && startByte == 0 && endByte == 0) {
      // Empty file: "bytes 0-*/0"
      contentRange = 'bytes 0-*/0';
    } else if (isLastChunk && chunk.isEmpty) {
      // Final empty chunk to signal completion when all data already uploaded.
      // Use the last uploaded byte as both start and end: "bytes lastByte-lastByte/totalSize"
      if (endByte > 0) {
        final lastByte = endByte - 1;
        contentRange = 'bytes $lastByte-$lastByte/$endByte';
      } else {
        contentRange = 'bytes 0-*/0';
      }
    } else if (isLastChunk) {
      // Final chunk with data: include total size
      contentRange = 'bytes $startByte-${endByte - 1}/$endByte';
    } else {
      // Intermediate chunk: use * for unknown total size
      contentRange = 'bytes $startByte-${endByte - 1}/*';
    }
    request.headers['Content-Range'] = contentRange;
    request.bodyBytes = Uint8List.fromList(chunk);

    if (_config.encryptionKey != null) {
      request.headers['x-goog-encryption-algorithm'] = 'AES256';
      request.headers['x-goog-encryption-key'] =
          _config.encryptionKey!.keyBase64;
      request.headers['x-goog-encryption-key-sha256'] =
          _config.encryptionKey!.keyHash;
    }

    final response = await authClient.send(request);
    final body = await response.stream.bytesToString();

    // Determine if this error should be retried.
    // Retries are allowed if: error is retryable, autoRetry is enabled,
    // and we haven't exceeded maxRetries.
    final retryOptions = _config.storage.retryOptions;
    final error = ApiError(
      'Resumable upload chunk failed',
      code: response.statusCode,
      details: body,
    );
    final retryableErrorFn =
        retryOptions.retryableErrorFn ?? defaultShouldRetryError;
    final isRetryable = retryableErrorFn(error);
    final shouldRetry =
        isRetryable &&
        retryOptions.autoRetry &&
        _numRetries < retryOptions.maxRetries;

    if (isLastChunk) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        if (shouldRetry) {
          _numRetries++;
          // Query server for current upload offset before retrying.
          // The server may have received part of the chunk, so we need to
          // resume from the actual offset, not from startByte.
          final actualOffset = await _queryUploadOffset();
          final retryDelay = _getRetryDelay(retryOptions);
          if (retryDelay.inMilliseconds <= 0) {
            throw ApiError(
              'Retry total time limit exceeded',
              code: null,
              details: {
                'originalStatusCode': response.statusCode,
                'originalResponse': body,
              },
            );
          }
          await Future.delayed(retryDelay);
          // Retry from the actual server offset
          final adjustedStartByte = actualOffset;
          final adjustedEndByte = adjustedStartByte + chunk.length;
          return _uploadChunkWithRetry(
            chunk,
            adjustedStartByte,
            adjustedEndByte,
            isLastChunk,
            attempt + 1,
          );
        }
        throw ApiError(
          'Resumable upload failed on final chunk',
          code: response.statusCode,
          details: body,
        );
      }

      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final uploadedMetadata = storage_v1.Object.fromJson(json);
        _config.onMetadataReceived?.call(uploadedMetadata);
      } catch (e) {
        // Ignore parse errors, metadata might be in headers
      }
    } else {
      if (response.statusCode != 308) {
        if (shouldRetry) {
          _numRetries++;
          // Query server for current upload offset before retrying.
          // The server may have received part of the chunk, so we need to
          // resume from the actual offset, not from startByte.
          final actualOffset = await _queryUploadOffset();
          final retryDelay = _getRetryDelay(retryOptions);
          if (retryDelay.inMilliseconds <= 0) {
            throw ApiError(
              'Retry total time limit exceeded',
              code: null,
              details: {
                'originalStatusCode': response.statusCode,
                'originalResponse': body,
              },
            );
          }
          await Future.delayed(retryDelay);
          // Retry from the actual server offset
          final adjustedStartByte = actualOffset;
          final adjustedEndByte = adjustedStartByte + chunk.length;
          return _uploadChunkWithRetry(
            chunk,
            adjustedStartByte,
            adjustedEndByte,
            isLastChunk,
            attempt + 1,
          );
        }
        throw ApiError(
          'Resumable upload failed: expected status 308, got ${response.statusCode}',
          code: response.statusCode,
          details: body,
        );
      }

      // Update bytes written from Range header in 308 response.
      // The server reports the last byte it received, so we add 1 to get
      // the next byte to send.
      final rangeHeader = response.headers['range'];
      if (rangeHeader != null) {
        // Parse Range header: "bytes=0-123" -> split('-')[1] -> "123"
        final parts = rangeHeader.split('-');
        if (parts.length >= 2) {
          try {
            _bytesWritten = int.parse(parts[1]) + 1;
          } catch (e) {
            // Ignore parse errors
          }
        }
      }
    }
  }

  /// Calculate retry delay with exponential backoff and jitter.
  ///
  /// The delay increases exponentially with each retry attempt, with added
  /// random jitter to prevent thundering herd problems. The final delay is
  /// capped by maxRetryDelay and the remaining totalTimeout.
  Duration _getRetryDelay(RetryOptions retryOptions) {
    // Add random jitter (0-1000ms) to prevent synchronized retries
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    // Calculate exponential backoff: multiplier^numRetries * 1000ms
    // We calculate this iteratively since Dart doesn't have Math.pow
    double baseDelayMs = 1000.0; // Start with 1 second
    for (int i = 0; i < _numRetries; i++) {
      baseDelayMs *= retryOptions.retryDelayMultiplier;
    }
    final waitTime = baseDelayMs.round() + random;

    // Calculate max allowable delay based on total timeout
    final elapsed = DateTime.now().difference(_timeOfFirstRequest);
    final maxAllowableDelay =
        retryOptions.totalTimeout.inMilliseconds - elapsed.inMilliseconds;
    final maxRetryDelay = retryOptions.maxRetryDelay.inMilliseconds;

    final delay = [
      waitTime,
      maxRetryDelay,
      maxAllowableDelay,
    ].where((d) => d > 0).reduce((a, b) => a < b ? a : b);

    return Duration(milliseconds: delay);
  }

  @override
  void add(List<int> data) {
    _controller.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  @override
  Future<void> close() async {
    await _controller.close();
  }

  @override
  Future<void> get done => _uploadCompleter.future;

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await _controller.addStream(stream);
  }
}
