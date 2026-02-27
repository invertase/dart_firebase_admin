part of '../google_cloud_storage.dart';

// Constants
const _defaultParallelUploadLimit = 5;
const _defaultParallelDownloadLimit = 5;
const _defaultParallelChunkedDownloadLimit = 5;
const _defaultParallelChunkedUploadLimit = 5;
const _downloadInChunksFileSizeThreshold = 32 * 1024 * 1024;
const _downloadInChunksDefaultChunkSize = 32 * 1024 * 1024;
const _uploadInChunksDefaultChunkSize = 32 * 1024 * 1024;
const _emptyRegex = r'(?:)';

// GCCL GCS Command feature constants
const _gcclGcsCmdFeatureUploadSharded = 'tm.upload_sharded';

/// Error thrown when a multipart upload fails.
///
/// Contains the uploadId and partsMap for resuming the upload.
class MultiPartUploadError implements Exception {
  final String message;
  final String uploadId;
  final Map<int, String> partsMap;

  MultiPartUploadError._(this.message, this.uploadId, this.partsMap);

  @override
  String toString() => 'MultiPartUploadError: $message (uploadId: $uploadId)';
}

/// Helper class for XML multipart upload operations.
///
/// This class handles the low-level XML API requests for multipart uploads.
class XMLMultiPartUploadHelper {
  final Bucket bucket;
  final String fileName;
  String uploadId;
  final Map<int, String> partsMap;
  final Uri baseUrl;
  final RetryOptions retryOptions;

  XMLMultiPartUploadHelper(
    this.bucket,
    this.fileName, [
    this.uploadId = '',
    Map<int, String>? partsMap,
  ]) : partsMap = partsMap ?? <int, String>{},
       baseUrl = _buildBaseUrl(bucket, fileName),
       retryOptions = bucket.storage.retryOptions;

  static Uri _buildBaseUrl(Bucket bucket, String fileName) {
    final apiEndpoint = bucket.storage.config.apiEndpoint;
    final hostname = Uri.parse(apiEndpoint).host;
    return Uri.parse('https://${bucket.name}.$hostname/$fileName');
  }

  Map<String, String> _setGoogApiClientHeaders([Map<String, String>? headers]) {
    final result = <String, String>{...?headers};
    var headerFound = false;
    var userAgentFound = false;

    for (final entry in result.entries) {
      final key = entry.key.toLowerCase().trim();
      if (key == 'x-goog-api-client') {
        headerFound = true;
        final value = entry.value;
        if (!value.contains(_gcclGcsCmdFeatureUploadSharded)) {
          result[entry.key] =
              '$value gccl-gcs-cmd/$_gcclGcsCmdFeatureUploadSharded';
        }
      } else if (key == 'user-agent') {
        userAgentFound = true;
      }
    }

    if (!headerFound) {
      result['x-goog-api-client'] =
          'gl-dart/0.0.1 gccl-gcs-cmd/$_gcclGcsCmdFeatureUploadSharded';
    }

    if (!userAgentFound) {
      result['User-Agent'] = 'google_cloud_storage/$packageVersion (dart)';
    }

    return result;
  }

  /// Initiates a multipart upload (MPU) to the XML API and stores the resultant upload id.
  Future<void> initiateUpload([Map<String, String>? headers]) async {
    final url = baseUrl.replace(queryParameters: {'uploads': ''});
    final authClient = await bucket.storage.authClient;

    await _executeWithRetry(() async {
      try {
        final requestHeaders = _setGoogApiClientHeaders(headers);
        final request = http.Request('POST', url);
        request.headers.addAll(requestHeaders);

        final response = await authClient.send(request);
        final body = await response.stream.bytesToString();

        if (response.statusCode >= 400) {
          throw ApiError(
            'Upload initiation failed',
            code: response.statusCode,
            details: body,
          );
        }

        uploadId = XmlMultipartHelper.parseUploadId(body);
      } catch (e) {
        if (e is ApiError) rethrow;
        throw ApiError.fromException(e);
      }
    });
  }

  /// Uploads the provided chunk of data to the XML API using the previously created upload id.
  ///
  /// [partNumber] is the sequence number of this chunk.
  /// [chunk] is the chunk of data to be uploaded.
  /// [validation] if 'md5', includes the md5 hash in the headers to cause the server
  /// to validate the chunk was not corrupted.
  Future<void> uploadPart(
    int partNumber,
    Uint8List chunk, [
    ValidationType? validation,
  ]) async {
    final url = baseUrl.replace(
      queryParameters: {
        'partNumber': partNumber.toString(),
        'uploadId': uploadId,
      },
    );
    final authClient = await bucket.storage.authClient;

    await _executeWithRetry(() async {
      try {
        final requestHeaders = _setGoogApiClientHeaders();

        if (validation == ValidationType.md5) {
          final hash = crypto.md5.convert(chunk);
          requestHeaders['Content-MD5'] = base64Encode(hash.bytes);
        }

        final request = http.Request('PUT', url);
        request.headers.addAll(requestHeaders);
        request.bodyBytes = chunk;

        final response = await authClient.send(request);
        final body = await response.stream.bytesToString();

        if (response.statusCode >= 400) {
          throw ApiError(
            'Part upload failed',
            code: response.statusCode,
            details: body,
          );
        }

        final etag = response.headers['etag'];
        if (etag != null) {
          partsMap[partNumber] = etag;
        }
      } catch (e) {
        if (e is ApiError) rethrow;
        throw ApiError.fromException(e);
      }
    });
  }

  /// Sends the final request of the MPU to tell GCS the upload is now complete.
  Future<http.Response?> completeUpload() async {
    final url = baseUrl.replace(queryParameters: {'uploadId': uploadId});
    final authClient = await bucket.storage.authClient;

    return await _executeWithRetry(() async {
      try {
        final sortedParts = partsMap.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        final parts = sortedParts
            .map((e) => PartInfo(partNumber: e.key, etag: e.value))
            .toList();
        final body = XmlMultipartHelper.buildCompleteMultipartBody(parts);

        final requestHeaders = _setGoogApiClientHeaders();
        final request = http.Request('POST', url);
        request.headers.addAll(requestHeaders);
        request.body = body;
        request.headers['Content-Type'] = 'application/xml';

        final response = await authClient.send(request);
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode >= 400) {
          throw ApiError(
            'Upload completion failed',
            code: response.statusCode,
            details: responseBody,
          );
        }

        return http.Response(
          responseBody,
          response.statusCode,
          headers: response.headers,
        );
      } catch (e) {
        if (e is ApiError) rethrow;
        throw ApiError.fromException(e);
      }
    });
  }

  /// Aborts a multipart upload that is in progress.
  ///
  /// Once aborted, any parts in the process of being uploaded fail,
  /// and future requests using the upload ID fail.
  Future<void> abortUpload() async {
    final url = baseUrl.replace(queryParameters: {'uploadId': uploadId});
    final authClient = await bucket.storage.authClient;

    await _executeWithRetry(() async {
      try {
        final request = http.Request('DELETE', url);
        final response = await authClient.send(request);
        final body = await response.stream.bytesToString();

        if (response.statusCode >= 400) {
          throw ApiError(
            'Upload abort failed',
            code: response.statusCode,
            details: body,
          );
        }
      } catch (e) {
        if (e is ApiError) rethrow;
        throw ApiError.fromException(e);
      }
    });
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    if (!retryOptions.autoRetry || retryOptions.maxRetries <= 0) {
      return await operation();
    }

    final errorClassifier =
        retryOptions.retryableErrorFn ?? defaultShouldRetryError;
    final start = DateTime.now();
    var attempt = 0;
    var delay = const Duration(seconds: 1);

    while (true) {
      try {
        return await operation();
      } catch (e) {
        final apiError = e is ApiError ? e : ApiError.fromException(e);

        attempt++;
        final elapsed = DateTime.now().difference(start);
        if (attempt > retryOptions.maxRetries ||
            elapsed >= retryOptions.totalTimeout) {
          throw apiError;
        }

        final shouldRetry = errorClassifier(apiError);
        if (!shouldRetry) throw apiError;

        if (delay > retryOptions.maxRetryDelay) {
          delay = retryOptions.maxRetryDelay;
        }
        await Future<void>.delayed(delay);
        delay = Duration(
          milliseconds:
              (delay.inMilliseconds * retryOptions.retryDelayMultiplier)
                  .toInt(),
        );
      }
    }
  }
}

/// TransferManager for performing parallel transfer operations on a Cloud Storage bucket.
class TransferManager {
  final Bucket bucket;

  TransferManager(this.bucket);

  /// Upload multiple files in parallel to the bucket.
  ///
  /// This is a convenience method that utilizes [Bucket.upload] to perform the upload.
  ///
  /// Example:
  /// ```dart
  /// final transferManager = TransferManager(bucket);
  /// final response = await transferManager.uploadManyFiles(
  ///   TransferSource.files(['/local/path/file1.txt', '/local/path/file2.txt']),
  /// );
  /// ```
  Future<List<BucketFile>> uploadManyFiles(
    TransferSource source, [
    UploadManyFilesOptions options = const UploadManyFilesOptions(),
  ]) async {
    // Note: skipIfExists logic is handled per-file in the upload loop

    final limit = ParallelLimit(
      maxConcurrency: options.concurrencyLimit ?? _defaultParallelUploadLimit,
    );
    final futures = <Future<BucketFile>>[];

    // Get all paths from TransferSource
    final allPaths = <String>[];
    await for (final path in _getAllPaths(source)) {
      allPaths.add(path);
    }

    for (final filePath in allPaths) {
      final fileEntity = await io.FileSystemEntity.type(filePath);
      if (fileEntity == io.FileSystemEntityType.directory) {
        continue;
      }

      // Build destination path
      String destination = filePath.split(io.Platform.pathSeparator).join('/');
      if (options.customDestinationBuilder != null) {
        destination = options.customDestinationBuilder!(filePath, options);
      }
      if (options.prefix != null) {
        destination = '${options.prefix}/$destination';
      }

      futures.add(
        limit.run(() async {
          final file = io.File(filePath);

          // Build UploadOptions from passthroughOptions and destination
          final passthrough = options.passthroughOptions;
          final existingPreconditionOpts = passthrough?.preconditionOpts;

          // Merge precondition options: if skipIfExists is true, set ifGenerationMatch to 0
          // while preserving other precondition options from passthrough
          final preconditionOpts = options.skipIfExists == true
              ? PreconditionOptions(
                  ifGenerationMatch: 0,
                  ifGenerationNotMatch:
                      existingPreconditionOpts?.ifGenerationNotMatch,
                  ifMetagenerationMatch:
                      existingPreconditionOpts?.ifMetagenerationMatch,
                  ifMetagenerationNotMatch:
                      existingPreconditionOpts?.ifMetagenerationNotMatch,
                )
              : existingPreconditionOpts;

          // Merge passthrough options with destination and updated precondition options
          final uploadOptions = (passthrough ?? const UploadOptions()).copyWith(
            destination: UploadDestination.path(destination),
            preconditionOpts: preconditionOpts,
          );

          return await bucket.upload(file, uploadOptions);
        }),
      );
    }

    return Future.wait(futures);
  }

  /// Download multiple files in parallel to the local filesystem.
  ///
  /// This is a convenience method that utilizes [File.download] to perform the download.
  ///
  /// Example:
  /// ```dart
  /// final transferManager = TransferManager(bucket);
  /// final response = await transferManager.downloadManyFiles(
  ///   TransferSource.files(['file1.txt', 'file2.txt']),
  /// );
  /// ```
  Future<List<List<int>>> downloadManyFiles(
    TransferSource source, [
    DownloadManyFilesOptions options = const DownloadManyFilesOptions(),
  ]) async {
    final limit = ParallelLimit(
      maxConcurrency: options.concurrencyLimit ?? _defaultParallelDownloadLimit,
    );
    final futures = <Future<List<int>>>[];
    final files = <BucketFile>[];

    // Get files based on TransferSource
    switch (source) {
      case DirectoryTransferSource(:final path):
        await for (final file in bucket.getFilesStream(
          GetFilesOptions(prefix: path),
        )) {
          files.add(file);
        }
      case FilesTransferSource(:final paths):
        for (final path in paths) {
          files.add(bucket.file(path));
        }
      case FileTransferSource(:final path):
        files.add(bucket.file(path));
    }

    final stripRegexString = options.stripPrefix != null
        ? '^${options.stripPrefix}'
        : _emptyRegex;
    final regex = RegExp(stripRegexString);

    for (final file in files) {
      String? destination;
      final passthroughDestination = options.passthroughOptions?.destination;

      // Build destination path: if passthrough has destination, use it directly
      // Otherwise build from prefix/stripPrefix + file name
      if (passthroughDestination != null) {
        destination = passthroughDestination.path;
      } else {
        if (options.prefix != null) {
          destination = '${options.prefix}/${file.name}';
        }
        if (options.stripPrefix != null) {
          destination = file.name.replaceAll(regex, '');
        }
      }

      if (options.skipIfExists == true &&
          destination != null &&
          io.File(destination).existsSync()) {
        continue;
      }

      futures.add(
        limit.run(() async {
          if (destination != null &&
              destination.endsWith(io.Platform.pathSeparator)) {
            await io.Directory(destination).create(recursive: true);
            return <int>[];
          }

          // Merge passthrough options with computed destination
          // If passthrough already has a destination, use it; otherwise use computed destination
          final passthrough = options.passthroughOptions;
          final downloadOptions = (passthrough ?? const DownloadOptions())
              .copyWith(
                destination:
                    passthroughDestination ??
                    (destination != null ? io.File(destination) : null),
              );

          return await file.download(downloadOptions);
        }),
      );
    }

    return Future.wait(futures);
  }

  /// Download a large file in chunks utilizing parallel download operations.
  ///
  /// This is a convenience method that utilizes [File.download] to perform the download.
  ///
  /// Example:
  /// ```dart
  /// final transferManager = TransferManager(bucket);
  /// final response = await transferManager.downloadFileInChunks(
  ///   bucket.file('large-file.txt'),
  /// );
  /// ```
  Future<List<int>?> downloadFileInChunks(
    BucketFile fileOrName, [
    DownloadFileInChunksOptions options = const DownloadFileInChunksOptions(),
  ]) async {
    var chunkSize = options.chunkSizeBytes ?? _downloadInChunksDefaultChunkSize;
    var limit = ParallelLimit(
      maxConcurrency:
          options.concurrencyLimit ?? _defaultParallelChunkedDownloadLimit,
    );

    final file = fileOrName;
    final fileInfo = await file.getMetadata();
    final size = int.parse(fileInfo.size ?? '0');

    // If the file size does not meet the threshold download it as a single chunk.
    if (size < _downloadInChunksFileSizeThreshold) {
      limit = ParallelLimit(maxConcurrency: 1);
      chunkSize = size;
    }

    var start = 0;
    final destinationFile =
        options.destination ?? io.File(file.name.split('/').last);
    final fileToWrite = await destinationFile.open(mode: io.FileMode.write);

    final futures = <Future<Uint8List?>>[];

    try {
      while (start < size) {
        final chunkStart = start;
        var chunkEnd = start + chunkSize - 1;
        if (chunkEnd > size) chunkEnd = size;

        futures.add(
          limit.run(() async {
            // Download chunk with range headers
            final downloadOptions = DownloadOptions(
              start: chunkStart,
              end: chunkEnd,
              validation: options.validation,
            );

            final chunkData = await file.download(downloadOptions);
            final chunkBytes = Uint8List.fromList(chunkData);

            // Write chunk to file at the correct position
            await fileToWrite.setPosition(chunkStart);
            await fileToWrite.writeFrom(chunkBytes);

            if (options.noReturnData == true) return null;
            return chunkBytes;
          }),
        );

        start += chunkSize;
      }

      final chunks = await Future.wait(futures);

      if (options.validation == ValidationType.crc32c &&
          fileInfo.crc32c != null) {
        final downloadedCrc32C = await Crc32c.fromFile(destinationFile);
        if (!downloadedCrc32C.validate(fileInfo.crc32c!)) {
          throw ApiError(
            'Content download mismatch: CRC32C checksum validation failed',
          );
        }
      }

      if (options.noReturnData == true) return null;

      // Concatenate all chunks
      final totalLength = chunks.fold<int>(
        0,
        (sum, chunk) => sum + (chunk?.length ?? 0),
      );
      final result = Uint8List(totalLength);
      var offset = 0;
      for (final chunk in chunks) {
        if (chunk != null) {
          result.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
      }
      return result.toList();
    } finally {
      await fileToWrite.close();
    }
  }

  /// Upload a large file in chunks utilizing parallel upload operations.
  ///
  /// If the upload fails, an uploadId and map containing all the successfully uploaded parts
  /// will be returned to the caller. These arguments can be used to resume the upload.
  ///
  /// Example:
  /// ```dart
  /// final transferManager = TransferManager(bucket);
  /// final response = await transferManager.uploadFileInChunks('/path/to/large-file.txt');
  /// ```
  Future<http.Response?> uploadFileInChunks(
    String filePath, [
    UploadFileInChunksOptions options = const UploadFileInChunksOptions(),
  ]) async {
    final chunkSize = options.chunkSizeBytes ?? _uploadInChunksDefaultChunkSize;
    final limit = ParallelLimit(
      maxConcurrency:
          options.concurrencyLimit ?? _defaultParallelChunkedUploadLimit,
    );
    final maxQueueSize =
        options.maxQueueSize ??
        options.concurrencyLimit ??
        _defaultParallelChunkedUploadLimit;
    final fileName =
        options.uploadName ?? filePath.split(io.Platform.pathSeparator).last;

    final mpuHelper = XMLMultiPartUploadHelper(
      bucket,
      fileName,
      options.uploadId ?? '',
      options.partsMap,
    );

    var partNumber = options.partsMap?.length ?? 0;
    partNumber = partNumber > 0 ? partNumber + 1 : 1;
    final futures = <Future<void>>[];

    try {
      if (options.uploadId == null) {
        await mpuHelper.initiateUpload(options.headers);
      }

      final startOrResumptionByte = mpuHelper.partsMap.length * chunkSize;
      final file = io.File(filePath);
      final fileStream = file.openRead(startOrResumptionByte);

      await for (final chunk in fileStream) {
        if (futures.length >= maxQueueSize) {
          await Future.wait(futures);
          futures.clear();
        }

        final currentPartNumber = partNumber++;
        futures.add(
          limit.run(
            () => mpuHelper.uploadPart(
              currentPartNumber,
              Uint8List.fromList(chunk),
              options.validation,
            ),
          ),
        );
      }

      await Future.wait(futures);
      return await mpuHelper.completeUpload();
    } catch (e) {
      if ((options.autoAbortFailure ?? true) && mpuHelper.uploadId.isNotEmpty) {
        try {
          await mpuHelper.abortUpload();
        } catch (abortError) {
          throw MultiPartUploadError._(
            abortError.toString(),
            mpuHelper.uploadId,
            mpuHelper.partsMap,
          );
        }
      }
      throw MultiPartUploadError._(
        e.toString(),
        mpuHelper.uploadId,
        mpuHelper.partsMap,
      );
    }
  }

  /// Get all file paths from a TransferSource.
  Stream<String> _getAllPaths(TransferSource source) async* {
    switch (source) {
      case FileTransferSource(:final path):
        yield path;
      case FilesTransferSource(:final paths):
        for (final path in paths) {
          yield path;
        }
      case DirectoryTransferSource(:final path):
        yield* _getPathsFromDirectory(path);
    }
  }

  /// Recursively get all file paths from a directory.
  Stream<String> _getPathsFromDirectory(String directory) async* {
    final dir = io.Directory(directory);
    if (!await dir.exists()) {
      return;
    }

    await for (final entity in dir.list(recursive: false)) {
      if (entity is io.File) {
        yield entity.path;
      } else if (entity is io.Directory) {
        yield* _getPathsFromDirectory(entity.path);
      }
    }
  }
}
