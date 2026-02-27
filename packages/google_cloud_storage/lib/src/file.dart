part of '../google_cloud_storage.dart';

final _gsUtilUrlRegex = RegExp(r'^gs://([a-z0-9_.-]+)/(.+)$');
final _httpsPublicUrlRegex = RegExp(
  r'^https://storage\.googleapis\.com/([a-z0-9_.-]+)/(.+)$',
);

/// Factory for creating streams used by BucketFile.
/// This allows for dependency injection in tests.
abstract class FileStreamFactory {
  Stream<List<int>> createReadStream(
    BucketFile file,
    CreateReadStreamOptions options,
  );

  StreamSink<List<int>> createWriteStream(
    BucketFile file,
    CreateWriteStreamOptions options,
  );
}

/// Default implementation that delegates to the actual stream methods.
class DefaultFileStreamFactory implements FileStreamFactory {
  const DefaultFileStreamFactory();

  @override
  Stream<List<int>> createReadStream(
    BucketFile file,
    CreateReadStreamOptions options,
  ) {
    return file.createReadStream(options);
  }

  @override
  StreamSink<List<int>> createWriteStream(
    BucketFile file,
    CreateWriteStreamOptions options,
  ) {
    return file.createWriteStream(options);
  }
}

class BucketFile extends ServiceObject<FileMetadata>
    with
        GettableMixin<FileMetadata, BucketFile>,
        DeletableMixin<FileMetadata>,
        SettableMixin<FileMetadata> {
  @internal
  BucketFile.internal(
    this.bucket,
    this.name, [
    FileOptions? options,
    URLSigner? signer,
    FileStreamFactory? streamFactory,
  ]) : options = (options ?? const FileOptions()).copyWith(
         // Inherit from bucket's storage options crc32cGenerator (which has a default) if not specified in file options
         crc32cGenerator:
             options?.crc32cGenerator ?? bucket.storage.options.crc32cGenerator,
         // Use provided userProject, or fall back to bucket's instance-level userProject
         // This ensures setUserProject() on the bucket is reflected in newly created files
         userProject: options?.userProject ?? bucket.userProject,
         // kmsKeyName and encryptionKey are file-specific and not inherited
       ),
       acl = Acl._objectAcl(bucket.storage, bucket.id, name),
       userProject = options?.userProject ?? bucket.userProject,
       preconditionOpts = options?.preconditionOpts,
       crc32cGenerator = options?.crc32cGenerator ?? bucket.crc32cGenerator,
       kmsKeyName = options?.kmsKeyName,
       _signer = signer,
       _streamFactory = streamFactory ?? const DefaultFileStreamFactory(),
       super(service: bucket.storage, id: name, metadata: FileMetadata());

  BucketFile._(Bucket bucket, String name, [FileOptions? options])
    : this.internal(bucket, name, options, null);

  final String name;
  final Bucket bucket;
  final FileOptions options;
  final Acl acl;
  final PreconditionOptions? preconditionOpts;
  final Crc32Generator crc32cGenerator;
  final String? kmsKeyName;
  final FileStreamFactory _streamFactory;
  URLSigner? _signer;
  EncryptionKey? _encryptionKey;

  URLSigner get signer => _signer ??= URLSigner._(bucket, this);

  /// A user project to apply to each request from this file.
  ///
  /// This can be set via constructor options or using [setUserProject()].
  /// When making requests, if a method doesn't provide a `userProject` in its
  /// options, this instance-level `userProject` will be used automatically.
  String? userProject;

  Storage get storage => service as Storage;

  Uri get cloudStorageURI {
    final uri = bucket.cloudStorageURI;
    return uri.replace(path: name);
  }

  factory BucketFile.from(
    String publicUrlOrGsUrl,
    Storage storage, [
    FileOptions? options,
  ]) {
    final gsMatches = _gsUtilUrlRegex.firstMatch(publicUrlOrGsUrl);
    final httpsMatches = _httpsPublicUrlRegex.firstMatch(publicUrlOrGsUrl);

    if (gsMatches != null) {
      final bucket = storage.bucket(gsMatches.group(1)!);
      return bucket.file(gsMatches.group(2)!, options);
    } else if (httpsMatches != null) {
      final bucket = storage.bucket(httpsMatches.group(1)!);
      return bucket.file(httpsMatches.group(2)!, options);
    } else {
      throw ArgumentError(
        'URL string must be of format gs://bucket/file or https://storage.googleapis.com/bucket/file',
      );
    }
  }

  @override
  Future<void> delete({PreconditionOptions? options}) async {
    final api = ApiExecutor(
      bucket.storage,
      preconditionOptions: options,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    try {
      await api.execute<void>((client) async {
        await client.objects.delete(
          bucket.id,
          id,
          generation: options?.ifGenerationMatch?.toString(),
          ifGenerationMatch: options?.ifGenerationMatch?.toString(),
          ifGenerationNotMatch: options?.ifGenerationNotMatch?.toString(),
          ifMetagenerationMatch: options?.ifMetagenerationMatch?.toString(),
          ifMetagenerationNotMatch: options?.ifMetagenerationNotMatch
              ?.toString(),
        );
      });
    } on ApiError catch (e) {
      if (options is DeleteOptions && options.ignoreNotFound && e.code == 404) {
        return;
      }

      rethrow;
    }
  }

  @override
  Future<FileMetadata> getMetadata({String? userProject}) async {
    // GET operations are idempotent, so retries are enabled by default
    // getMetadata() makes the API request directly and sets instance metadata
    final api = ApiExecutor(bucket.storage);
    final response = await api.execute<FileMetadata>((client) async {
      // Use provided userProject or fall back to instance-level userProject
      final result = await client.objects.get(
        bucket.id,
        id,
        generation: options.generation?.toString(),
        userProject: userProject ?? this.userProject ?? options.userProject,
      );
      // Cast to FileMetadata (which is storage_v1.Object)
      return result as FileMetadata;
    });
    setInstanceMetadata(response);
    return response;
  }

  @override
  Future<FileMetadata> setMetadata(
    FileMetadata metadata, {
    SetFileMetadataOptions? options = const SetFileMetadataOptions(),
  }) {
    final api = ApiExecutor(
      bucket.storage,
      preconditionOptions: options,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    return api.execute<FileMetadata>((client) async {
      // Use provided userProject or fall back to instance-level userProject
      final updated = await client.objects.patch(
        metadata,
        bucket.id,
        id,
        generation: this.options.generation?.toString(),
        ifMetagenerationMatch: options?.ifMetagenerationMatch?.toString(),
        ifMetagenerationNotMatch: options?.ifMetagenerationNotMatch?.toString(),
        ifGenerationMatch: options?.ifGenerationMatch?.toString(),
        ifGenerationNotMatch: options?.ifGenerationNotMatch?.toString(),
        userProject: options?.userProject ?? userProject,
      );
      setInstanceMetadata(updated);
      return updated;
    });
  }

  /// Copy this file to another file.
  ///
  /// By default, this will copy the file to the same bucket, but you can choose
  /// to copy it to another Bucket by providing a Bucket or File object or a URL
  /// starting with "gs://". The generation of the file will not be preserved.
  Future<BucketFile> copy(
    CopyDestination destination, {
    CopyOptions? options,
  }) async {
    final copyOptions = options ?? const CopyOptions();
    late Bucket destBucket;
    late BucketFile newFile;

    if (destination is FileCopyDestination) {
      destBucket = destination.file.bucket;
      newFile = destination.file;
    } else if (destination is BucketCopyDestination) {
      destBucket = destination.bucket;
      newFile = destBucket.file(name);
    } else if (destination is PathCopyDestination) {
      final gsMatch = RegExp(
        r'^gs://([a-z0-9_.-]+)/(.+)$',
      ).firstMatch(destination.path);
      if (gsMatch != null) {
        destBucket = storage.bucket(gsMatch.group(1)!);
        newFile = destBucket.file(gsMatch.group(2)!);
      } else {
        destBucket = bucket;
        newFile = destBucket.file(destination.path);
      }
    }

    final api = ApiExecutor(
      bucket.storage,
      preconditionOptions: copyOptions.preconditionOpts,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    return await api.execute((client) async {
      // Build destination metadata from options
      final destinationMetadata = storage_v1.Object()
        ..cacheControl = copyOptions.cacheControl
        ..contentEncoding = copyOptions.contentEncoding
        ..contentType = copyOptions.contentType
        ..contentDisposition = copyOptions.contentDisposition
        ..metadata = copyOptions.metadata
        ..kmsKeyName =
            newFile.options.kmsKeyName ?? copyOptions.destinationKmsKeyName;

      final response = await client.objects.rewrite(
        destinationMetadata,
        bucket.id,
        id,
        destBucket.name,
        newFile.name,
        sourceGeneration: this.options.generation?.toString(),
        rewriteToken: copyOptions.token,
        destinationKmsKeyName: copyOptions.destinationKmsKeyName,
        destinationPredefinedAcl: copyOptions.predefinedAcl?.value,
        ifGenerationMatch: copyOptions.preconditionOpts?.ifGenerationMatch
            ?.toString(),
        ifGenerationNotMatch: copyOptions.preconditionOpts?.ifGenerationNotMatch
            ?.toString(),
        ifMetagenerationMatch: copyOptions
            .preconditionOpts
            ?.ifMetagenerationMatch
            ?.toString(),
        ifMetagenerationNotMatch: copyOptions
            .preconditionOpts
            ?.ifMetagenerationNotMatch
            ?.toString(),
        userProject: copyOptions.userProject ?? userProject,
      );

      // If rewriteToken is present, we need to continue the copy
      if (response.rewriteToken != null && response.rewriteToken!.isNotEmpty) {
        return await copy(
          FileCopyDestination(newFile),
          options: CopyOptions(
            token: response.rewriteToken,
            destinationKmsKeyName: copyOptions.destinationKmsKeyName,
            userProject: copyOptions.userProject ?? userProject,
          ),
        );
      }

      // Update destination file metadata
      if (response.resource != null) {
        newFile.setInstanceMetadata(response.resource!);
      }

      return newFile;
    });
  }

  Stream<List<int>> createReadStream([CreateReadStreamOptions? options]) {
    final opts = options ?? const CreateReadStreamOptions();
    final decompress = opts.decompress ?? true;

    // Check if this is a range request
    final rangeRequest = opts.start != null || opts.end != null;
    final tailRequest = opts.end != null && opts.end! < 0;

    var (crc32c, md5) = switch (opts.validation) {
      ValidationType.crc32c => (true, false),
      ValidationType.md5 => (false, true),
      ValidationType.none => (false, false),
      null => (true, false),
    };

    // Range requests can't receive data integrity checks (per JS SDK)
    if (rangeRequest) {
      if (opts.validation != null && opts.validation != ValidationType.none) {
        throw ArgumentError(
          'Validation cannot be used with range requests. '
          'Range requests do not support data integrity checks.',
        );
      }
      crc32c = false;
      md5 = false;
    }

    final shouldRunValidation = !rangeRequest && (crc32c || md5);

    // Create a stream controller for the output stream
    final controller = StreamController<List<int>>();
    bool streamStarted = false;

    // Make the HTTP request asynchronously
    Future<void> makeRequest() async {
      if (streamStarted) return;
      streamStarted = true;

      try {
        // Build query parameters
        final queryParams = <String, String>{'alt': 'media'};

        if (this.options.generation != null) {
          queryParams['generation'] = this.options.generation.toString();
        }

        final effectiveUserProject =
            opts.userProject ?? userProject ?? this.options.userProject;
        if (effectiveUserProject != null) {
          queryParams['userProject'] = effectiveUserProject;
        }

        // Build request URI
        final apiEndpoint = storage.config.apiEndpoint;
        final uri = Uri.parse(apiEndpoint).replace(
          path: '/storage/v1/b/${bucket.id}/o/${Uri.encodeComponent(name)}',
          queryParameters: queryParams,
        );

        // Build request headers
        // Request gzip encoding so we can validate compressed data before decompressing
        final headers = <String, String>{
          'Accept-Encoding': 'gzip',
          'Cache-Control': 'no-store',
        };

        // Add Range header if needed
        if (rangeRequest) {
          final start = opts.start ?? 0;
          if (tailRequest) {
            headers['Range'] = 'bytes=${opts.end}';
          } else {
            final end = opts.end?.toString() ?? '';
            headers['Range'] = 'bytes=$start-$end';
          }
        }

        // Add encryption headers if encryption key is set
        if (_encryptionKey != null) {
          headers['x-goog-encryption-algorithm'] = 'AES256';
          headers['x-goog-encryption-key'] = _encryptionKey!.keyBase64;
          headers['x-goog-encryption-key-sha256'] = _encryptionKey!.keyHash;
        }

        // Create and send the request
        final authClient = await storage.authClient;
        final request = http.Request('GET', uri);
        request.headers.addAll(headers);

        final response = await authClient.send(request);

        // Handle error responses - check status code first
        if (response.statusCode < 200 || response.statusCode >= 300) {
          final body = await response.stream.bytesToString();
          final error = ApiError(
            'Download failed',
            code: response.statusCode,
            details: body,
          );
          controller.addError(error);
          await controller.close();
          return;
        }

        // Parse response headers (available before consuming stream)
        final responseHeaders = response.headers;
        final isCompressed =
            responseHeaders['content-encoding']?.toLowerCase() == 'gzip';
        final storedContentEncoding =
            responseHeaders['x-goog-stored-content-encoding'];

        // The object is safe to validate if:
        // 1. It was stored gzip and returned to us gzip OR
        // 2. It was never stored as gzip
        // We disabled autoUncompress on HttpClient, so we can validate before decompressing
        final safeToValidate =
            (storedContentEncoding == 'gzip' && isCompressed) ||
            storedContentEncoding == 'identity';

        // Extract expected hashes from x-goog-hash header
        String? expectedCrc32c;
        String? expectedMd5;
        if (shouldRunValidation) {
          final hashHeader = responseHeaders['x-goog-hash'];
          if (hashHeader != null) {
            final hashPairs = hashHeader.split(',');
            for (final pair in hashPairs) {
              final delimiterIndex = pair.indexOf('=');
              if (delimiterIndex > 0) {
                final hashType = pair.substring(0, delimiterIndex).trim();
                final hashValue = pair.substring(delimiterIndex + 1).trim();
                if (hashType == 'crc32c') {
                  expectedCrc32c = hashValue;
                } else if (hashType == 'md5') {
                  expectedMd5 = hashValue;
                }
              }
            }
          }
        }

        // Check if MD5 is required but not available
        if (md5 && expectedMd5 == null) {
          final error = ApiError(
            'MD5 hash is not available for this object',
            code: null,
            details: {'code': 'MD5_NOT_AVAILABLE'},
          );
          controller.addError(error);
          await controller.close();
          return;
        }

        // Build the processing pipeline from the response stream
        Stream<List<int>> pipeline = response.stream;

        // Apply validation FIRST if safe (validates compressed data before decompression)
        // This matches Node.js SDK behavior
        HashStreamValidator? validateStream;
        if (safeToValidate && shouldRunValidation) {
          validateStream = HashStreamValidator(
            HashStreamValidatorOptions(
              crc32c: crc32c,
              md5: md5,
              crc32cExpected: expectedCrc32c,
              md5Expected: expectedMd5,
              crc32cGenerator: crc32cGenerator,
            ),
          );
          pipeline = pipeline.transform(validateStream);
        }

        // Apply decompression SECOND if needed (after validation)
        if (isCompressed && decompress) {
          pipeline = pipeline.transform(io.gzip.decoder);
        }

        // Forward the stream to the controller
        final subscription = pipeline.listen(
          (data) {
            controller.add(data);
          },
          onError: (error, stackTrace) {
            controller.addError(error, stackTrace);
          },
          onDone: () {
            controller.close();
          },
          cancelOnError: false,
        );

        // Handle controller cancellation
        controller.onCancel = () {
          subscription.cancel();
        };
      } catch (e, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(e, stackTrace);
          await controller.close();
        }
      }
    }

    // Start the request when the stream is listened to
    controller.onListen = makeRequest;

    return controller.stream;
  }

  Future<String> createResumableUpload([
    CreateResumableUploadOptions? options,
  ]) async {
    final opts = options ?? const CreateResumableUploadOptions();
    final metadata = opts.metadata ?? FileMetadata();

    // Determine predefinedAcl
    PredefinedAcl? predefinedAcl = opts.predefinedAcl;
    if (opts.private == true) {
      predefinedAcl = PredefinedAcl.private;
    } else if (opts.public == true) {
      predefinedAcl = PredefinedAcl.publicRead;
    }

    // Build query parameters
    final queryParams = <String, String>{
      'uploadType': 'resumable',
      'name': name,
    };

    if (this.options.generation != null) {
      queryParams['ifGenerationMatch'] = this.options.generation.toString();
    }

    if (kmsKeyName != null) {
      queryParams['kmsKeyName'] = kmsKeyName!;
    }

    final effectiveUserProject = opts.userProject ?? userProject;
    if (effectiveUserProject != null) {
      queryParams['userProject'] = effectiveUserProject;
    }

    if (predefinedAcl != null) {
      queryParams['predefinedAcl'] = predefinedAcl.value;
    }

    // Add precondition options
    final preconditions = opts.preconditionOpts ?? preconditionOpts;
    if (preconditions != null) {
      if (preconditions.ifGenerationMatch != null) {
        queryParams['ifGenerationMatch'] = preconditions.ifGenerationMatch
            .toString();
      }
      if (preconditions.ifGenerationNotMatch != null) {
        queryParams['ifGenerationNotMatch'] = preconditions.ifGenerationNotMatch
            .toString();
      }
      if (preconditions.ifMetagenerationMatch != null) {
        queryParams['ifMetagenerationMatch'] = preconditions
            .ifMetagenerationMatch
            .toString();
      }
      if (preconditions.ifMetagenerationNotMatch != null) {
        queryParams['ifMetagenerationNotMatch'] = preconditions
            .ifMetagenerationNotMatch
            .toString();
      }
    }

    // Build request URI
    final apiEndpoint = storage.config.apiEndpoint;
    final uri = Uri.parse(apiEndpoint).replace(
      path: '/upload/storage/v1/b/${bucket.id}/o',
      queryParameters: queryParams,
    );

    // Create request
    final authClient = await storage.authClient;
    final request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'application/json; charset=utf-8';
    request.headers['x-upload-content-type'] =
        metadata.contentType ?? 'application/octet-stream';

    if (metadata.size != null) {
      request.headers['x-upload-content-length'] = metadata.size.toString();
    }

    // Add encryption headers if encryption key is set
    if (_encryptionKey != null) {
      request.headers['x-goog-encryption-algorithm'] = 'AES256';
      request.headers['x-goog-encryption-key'] = _encryptionKey!.keyBase64;
      request.headers['x-goog-encryption-key-sha256'] = _encryptionKey!.keyHash;
    }

    // Serialize metadata to JSON
    final metadataJson = <String, dynamic>{};
    if (metadata.name != null) metadataJson['name'] = metadata.name;
    if (metadata.contentType != null) {
      metadataJson['contentType'] = metadata.contentType;
    }
    if (metadata.contentEncoding != null) {
      metadataJson['contentEncoding'] = metadata.contentEncoding;
    }
    if (metadata.metadata != null) {
      metadataJson['metadata'] = metadata.metadata;
    }
    request.body = jsonEncode(metadataJson);

    // Execute request
    final api = ApiExecutor(
      storage,
      preconditionOptions: preconditions,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    return await api.execute<String>((client) async {
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
    });
  }

  StreamSink<List<int>> createWriteStream([CreateWriteStreamOptions? options]) {
    final opts = options ?? const CreateWriteStreamOptions();
    final controller = StreamController<List<int>>();

    // Determine content type
    String? contentType = opts.contentType;
    if (contentType == 'auto' || contentType == null) {
      final detected = lookupMimeType(name);
      contentType = detected;
    }

    // Prepare metadata
    final metadata = opts.metadata ?? FileMetadata();
    if (contentType != null && metadata.contentType == null) {
      metadata.contentType = contentType;
    }

    // Handle gzip
    bool shouldGzip = false;
    if (opts.gzip == true) {
      shouldGzip = true;
    } else if (opts.gzip == null) {
      // Auto-detect: Check if content type is compressible
      final ct = metadata.contentType ?? '';
      shouldGzip =
          ct.startsWith('text/') ||
          ct == 'application/javascript' ||
          ct == 'application/json' ||
          ct == 'application/xml';
    }

    if (shouldGzip) {
      metadata.contentEncoding = 'gzip';
    }

    // Determine validation type
    bool crc32c = true;
    bool md5 = false;
    switch (opts.validation) {
      case ValidationType.crc32c:
        crc32c = true;
        md5 = false;
        break;
      case ValidationType.md5:
        crc32c = false;
        md5 = true;
        break;
      case ValidationType.none:
        crc32c = false;
        md5 = false;
        break;
      case null:
        // Default: use CRC32C
        crc32c = true;
        md5 = false;
        break;
    }

    // Validate offset/validation combination
    if (opts.offset != null && opts.offset! > 0) {
      if (md5) {
        throw ArgumentError(
          'MD5 cannot be used with a continued resumable upload as MD5 cannot be extended from an existing value',
        );
      }
      if (crc32c && opts.isPartialUpload != true && opts.resumeCRC32C == null) {
        throw ArgumentError(
          'The CRC32C is missing for the final portion of a resumed upload, which is required for validation. Please provide resumeCRC32C if validation is required, or disable validation.',
        );
      }
    }

    // Create hash validator if needed
    HashStreamValidator? hashValidator;
    if (crc32c || md5) {
      Crc32cValidator? crc32cInstance;
      if (opts.resumeCRC32C != null) {
        crc32cInstance = Crc32c.from(opts.resumeCRC32C!);
      }

      hashValidator = HashStreamValidator(
        HashStreamValidatorOptions(
          crc32c: crc32c,
          crc32cInstance: crc32cInstance,
          md5: md5,
          crc32cGenerator: crc32cGenerator,
          updateHashesOnly: true,
        ),
      );
    }

    // Create the upload sink
    late StreamSink<List<int>> uploadSink;
    bool metadataReceived = false;

    // Determine upload method
    final useResumable = opts.resumable ?? true;

    if (useResumable) {
      uploadSink = _startResumableUpload(
        controller,
        opts,
        metadata,
        hashValidator,
        () {
          metadataReceived = true;
        },
      );
    } else {
      uploadSink = _startSimpleUpload(
        controller,
        opts,
        metadata,
        hashValidator,
        () {
          metadataReceived = true;
        },
      );
    }

    // Set up the data processing pipeline.
    // Data flows: controller.stream -> [gzip] -> [hash validation] -> upload sink
    // When gzip is enabled, hash is calculated on COMPRESSED data (matching Node.js SDK)
    // because the server stores the hash of the compressed bytes.
    Stream<List<int>> pipeline = controller.stream;

    // Apply gzip compression FIRST if enabled
    if (shouldGzip) {
      pipeline = pipeline.transform(io.gzip.encoder);
    }

    // Apply hash validation SECOND if enabled (calculates CRC32C or MD5 on compressed data)
    if (hashValidator != null) {
      pipeline = pipeline.transform(hashValidator);
    }

    // Connect the pipeline to the upload sink
    final subscription = pipeline.listen(
      (data) {
        uploadSink.add(data);
      },
      onError: (error, stackTrace) {
        uploadSink.addError(error, stackTrace);
      },
      onDone: () async {
        await uploadSink.close();
      },
      cancelOnError: false,
    );

    // Return a sink that forwards to the controller
    return _UploadSink(
      controller,
      subscription,
      uploadSink,
      hashValidator,
      metadata,
      crc32c,
      md5,
      () => metadataReceived,
    );
  }

  /// Helper method to collect all data from a stream into a single byte list.
  Future<List<int>> _getBufferFromStream(Stream<List<int>> stream) async {
    final buffer = <int>[];
    await for (final chunk in stream) {
      buffer.addAll(chunk);
    }
    return buffer;
  }

  Future<List<int>> download([DownloadOptions? options]) async {
    final opts = options ?? const DownloadOptions();

    // Extract destination and encryptionKey from options
    final destination = opts.destination;
    final encryptionKey = opts.encryptionKey;

    // Set encryption key if provided
    if (encryptionKey != null) {
      setEncryptionKey(encryptionKey);
    }

    // Create read stream options (without destination and encryptionKey)
    final readStreamOptions = CreateReadStreamOptions(
      userProject: opts.userProject,
      validation: opts.validation,
      start: opts.start,
      end: opts.end,
      decompress: opts.decompress,
    );

    // Create the read stream
    final fileStream = _streamFactory.createReadStream(this, readStreamOptions);

    if (destination != null) {
      // Download to file
      final completer = Completer<List<int>>();
      bool receivedData = false;
      final writeStream = destination.openWrite();

      final subscription = fileStream.listen(
        (data) {
          if (!receivedData) {
            receivedData = true;
            // We know the file exists on the server - now we can write to the file
          }
          writeStream.add(data);
        },
        onError: (error, stackTrace) {
          writeStream.addError(error, stackTrace);
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        },
        onDone: () async {
          try {
            await writeStream.close();
            // In the case of an empty file, no data will be received before the end event fires
            if (!receivedData) {
              // File is empty - ensure it exists
              if (!await destination.exists()) {
                await destination.writeAsBytes(<int>[]);
              }
              if (!completer.isCompleted) {
                completer.complete(<int>[]);
              }
            } else {
              // Read the file back to return the bytes
              final bytes = await destination.readAsBytes();
              if (!completer.isCompleted) {
                completer.complete(bytes);
              }
            }
          } catch (e, stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(e, stackTrace);
            }
          }
        },
        cancelOnError: false,
      );

      // Handle completer cancellation
      completer.future.catchError((_) {
        subscription.cancel();
        writeStream.close();
        return <int>[]; // Return empty list on error
      });

      return completer.future;
    } else {
      // Download to memory
      return await _getBufferFromStream(fileStream);
    }
  }

  BucketFile setEncryptionKey(EncryptionKey encryptionKey) {
    _encryptionKey = encryptionKey;
    return this;
  }

  /// Get a Date object representing the earliest time this file will expire.
  ///
  /// If this bucket has a retention policy defined, use this method to get a
  /// Date object representing the earliest time this file will expire.
  Future<DateTime> getExpirationDate() async {
    final metadata = await getMetadata();
    if (metadata.retentionExpirationTime == null) {
      throw Exception('An expiration time is not available.');
    }

    return metadata.retentionExpirationTime!;
  }

  /// Get a signed policy document to allow a user to upload data with a POST
  /// request.
  ///
  /// See https://cloud.google.com/storage/docs/xml-api/post-object-v2
  ///
  /// Throws [ArgumentError] if expiration date is in the past or if condition
  /// arrays don't have exactly 2 elements.
  /// Throws [SigningError] if signing fails.
  ///
  /// Example:
  /// ```dart
  /// final policy = await file.generateSignedPostPolicyV2(
  ///   GenerateSignedPostPolicyV2Options(
  ///     expires: DateTime.now().add(Duration(hours: 1)),
  ///     equals: [['\$Content-Type', 'image/jpeg']],
  ///     contentLengthRange: ContentLengthRange(min: 0, max: 1024 * 1024),
  ///   ),
  /// );
  /// // Use policy.string, policy.base64, policy.signature for form upload
  /// ```
  Future<PolicyDocument> generateSignedPostPolicyV2(
    GenerateSignedPostPolicyV2Options options,
  ) async {
    // Validate expiration
    final expires = options.expires;
    if (expires.isBefore(DateTime.now())) {
      throw ArgumentError('Expiration date cannot be in the past.');
    }

    // Build conditions array
    final conditions = <Object>[
      ['eq', '\$key', name],
      {'bucket': bucket.name},
    ];

    // Add equals conditions
    if (options.equals != null) {
      for (final condition in options.equals!) {
        if (condition.length != 2) {
          throw ArgumentError(
            'Each equals condition must have exactly 2 elements.',
          );
        }
        conditions.add(['eq', condition[0], condition[1]]);
      }
    }

    // Add startsWith conditions
    if (options.startsWith != null) {
      for (final condition in options.startsWith!) {
        if (condition.length != 2) {
          throw ArgumentError(
            'Each startsWith condition must have exactly 2 elements.',
          );
        }
        conditions.add(['starts-with', condition[0], condition[1]]);
      }
    }

    // Add optional conditions
    if (options.acl != null) {
      conditions.add({'acl': options.acl});
    }
    if (options.successRedirect != null) {
      conditions.add({'success_action_redirect': options.successRedirect});
    }
    if (options.successStatus != null) {
      conditions.add({'success_action_status': options.successStatus});
    }
    if (options.contentLengthRange != null) {
      conditions.add([
        'content-length-range',
        options.contentLengthRange!.min,
        options.contentLengthRange!.max,
      ]);
    }

    // Create policy object
    final policy = {
      'expiration': _formatPolicyExpiration(expires),
      'conditions': conditions,
    };

    // Encode policy
    final policyString = jsonEncode(policy);
    final policyStringBytes = utf8.encode(policyString);
    final policyStringBase64 = base64Encode(policyStringBytes);

    // Sign the policy
    try {
      final authClient = await storage.authClient;
      final signature = await authClient.sign(
        policyStringBytes,
        serviceAccountCredentials:
            bucket.storage.options.credential?.serviceAccountCredentials,
        endpoint: options.signingEndpoint?.toString(),
      );

      return PolicyDocument(
        string: policyString,
        base64: policyStringBase64,
        signature: signature,
      );
    } catch (e) {
      throw SigningError(e.toString());
    }
  }

  /// Get a v4 signed policy document to allow a user to upload data with a POST
  /// request.
  ///
  /// Maximum expiration is 7 days.
  /// See https://cloud.google.com/storage/docs/xml-api/post-object
  ///
  /// Throws [ArgumentError] if expiration date is in the past or exceeds 7 days.
  /// Throws [StateError] if service account email cannot be determined.
  /// Throws [SigningError] if signing fails.
  ///
  /// Example:
  /// ```dart
  /// final policy = await file.generateSignedPostPolicyV4(
  ///   GenerateSignedPostPolicyV4Options(
  ///     expires: DateTime.now().add(Duration(hours: 1)),
  ///     fields: {'x-goog-meta-test': 'data'},
  ///   ),
  /// );
  /// // Use policy.url and policy.fields for form upload
  /// ```
  Future<SignedPostPolicyV4Output> generateSignedPostPolicyV4(
    GenerateSignedPostPolicyV4Options options,
  ) async {
    // Validate expiration
    final expires = options.expires;
    final now = DateTime.now();

    if (expires.isBefore(now)) {
      throw ArgumentError('Expiration date cannot be in the past.');
    }

    const sevenDays = 7 * 24 * 60 * 60; // seconds
    if (expires.difference(now).inSeconds > sevenDays) {
      throw ArgumentError(
        'Max allowed expiration is seven days ($sevenDays seconds).',
      );
    }

    // Get auth client and credentials
    final authClient = await storage.authClient;
    final clientEmail =
        bucket.storage.options.credential?.serviceAccountCredentials?.email ??
        await authClient.getServiceAccountEmail();

    // Build credential string
    final todayISO = _formatDateStamp(now);
    final credentialScope = '$todayISO/auto/storage/goog4_request';
    final credentialString = '$clientEmail/$credentialScope';
    final nowISO = _formatDateISO(now);

    // Build fields
    var fields = Map<String, String>.from(options.fields ?? {});
    fields = {
      ...fields,
      'key': name,
      'x-goog-date': nowISO,
      'x-goog-credential': credentialString,
      'x-goog-algorithm': 'GOOG4-RSA-SHA256',
    };

    // Build conditions from fields (skip x-ignore-* prefixed)
    final conditions = List<Object>.from(options.conditions ?? []);
    conditions.add({'bucket': bucket.name});

    for (final entry in fields.entries) {
      if (!entry.key.startsWith('x-ignore-')) {
        conditions.add({entry.key: entry.value});
      }
    }

    // Create and encode policy
    final policy = {
      'conditions': conditions,
      'expiration': _formatPolicyExpiration(expires),
    };

    final policyString = _unicodeJSONStringify(policy);
    final policyStringBytes = utf8.encode(policyString);
    final policyStringBase64 = base64Encode(policyStringBytes);

    // Sign and convert to hex
    try {
      final signature = await authClient.sign(
        policyStringBytes,
        serviceAccountCredentials:
            bucket.storage.options.credential?.serviceAccountCredentials,
        endpoint: options.signingEndpoint?.toString(),
      );

      final signatureBytes = base64Decode(signature);
      final signatureHex = signatureBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      // Add policy and signature to fields
      fields['policy'] = policyStringBase64;
      fields['x-goog-signature'] = signatureHex;

      // Build URL
      String url;
      final universeDomain = storage.options.universeDomain ?? 'googleapis.com';

      if (options.virtualHostedStyle) {
        url = 'https://${bucket.name}.storage.$universeDomain/';
      } else if (options.bucketBoundHostname != null) {
        url = '${options.bucketBoundHostname}/';
      } else {
        url = 'https://storage.$universeDomain/${bucket.name}/';
      }

      return SignedPostPolicyV4Output(url: url, fields: fields);
    } catch (e) {
      throw SigningError(e.toString());
    }
  }

  /// Format date as UTC ISO string for policy expiration.
  /// Returns format like '2024-01-15T10:30:00Z' with delimiters.
  String _formatPolicyExpiration(DateTime date) {
    final utc = date.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}T'
        '${utc.hour.toString().padLeft(2, '0')}:'
        '${utc.minute.toString().padLeft(2, '0')}:'
        '${utc.second.toString().padLeft(2, '0')}Z';
  }

  /// Format date as YYYYMMDD for credential scope.
  String _formatDateStamp(DateTime date) {
    final utc = date.toUtc();
    return '${utc.year}${utc.month.toString().padLeft(2, '0')}'
        '${utc.day.toString().padLeft(2, '0')}';
  }

  /// Format date as YYYYMMDDTHHmmssZ for x-goog-date.
  String _formatDateISO(DateTime date) {
    final utc = date.toUtc();
    return '${utc.year}${utc.month.toString().padLeft(2, '0')}'
        '${utc.day.toString().padLeft(2, '0')}T'
        '${utc.hour.toString().padLeft(2, '0')}'
        '${utc.minute.toString().padLeft(2, '0')}'
        '${utc.second.toString().padLeft(2, '0')}Z';
  }

  /// JSON stringify with unicode escaping for non-ASCII characters.
  String _unicodeJSONStringify(Object obj) {
    return jsonEncode(obj).replaceAllMapped(
      RegExp(r'[\u0080-\uFFFF]'),
      (match) =>
          '\\u${match.group(0)!.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}',
    );
  }

  /// Get a signed URL to allow limited time access to the file.
  Future<String> getSignedUrl(GetFileSignedUrlOptions options) async {
    final method = _fileActionToHttpMethod(options.action);

    // Add response parameters to queryParams
    final queryParams = Map<String, String>.from(options.queryParams ?? {});
    if (options.responseType != null) {
      queryParams['response-content-type'] = options.responseType!;
    }
    if (options.promptSaveAs != null && options.responseDisposition == null) {
      queryParams['response-content-disposition'] =
          'attachment; filename="${options.promptSaveAs}"';
    }
    if (options.responseDisposition != null) {
      queryParams['response-content-disposition'] =
          options.responseDisposition!;
    }
    if (this.options.generation != null) {
      queryParams['generation'] = this.options.generation.toString();
    }

    final configWithQueryParams = SignedUrlConfig(
      method: method,
      expires: options.expires,
      accessibleAt: options.accessibleAt,
      version: options.version,
      cname: options.cname,
      virtualHostedStyle: options.virtualHostedStyle,
      extensionHeaders: options.extensionHeaders,
      queryParams: queryParams,
      contentMd5: options.contentMd5,
      contentType: options.contentType,
      host: options.host,
      signingEndpoint: options.signingEndpoint,
    );

    return await signer.getSignedUrl(configWithQueryParams);
  }

  /// Check whether this file is public or not.
  ///
  /// Sends a HEAD request without credentials. No errors from the server indicates
  /// that the current file is public. A 403-Forbidden error indicates that file is private.
  Future<bool> isPublic() async {
    final publicUrl = this.publicUrl();
    try {
      final response = await http.head(Uri.parse(publicUrl));
      return response.statusCode == 200;
    } catch (e) {
      // Check if it's a 403 error (file is private)
      if (e is http.ClientException) {
        // Try to parse status code from the exception
        final statusMatch = RegExp(r'(\d{3})').firstMatch(e.toString());
        if (statusMatch != null && statusMatch.group(1) == '403') {
          return false;
        }
      }
      // For other errors, rethrow
      rethrow;
    }
  }

  Future<void> makePrivate([
    MakeFilePrivateOptions? options = const MakeFilePrivateOptions(),
  ]) async {
    final makePrivateOptions = options ?? const MakeFilePrivateOptions();
    // Merge options.metadata with acl: null
    // You aren't allowed to set both predefinedAcl & acl properties on a file
    // so acl must explicitly be nullified.
    final metadata = (makePrivateOptions.metadata ?? FileMetadata())
      ..acl = null;

    // predefinedAcl is set via patch method parameter, not in SetFileMetadataOptions
    final api = ApiExecutor(
      bucket.storage,
      preconditionOptions: makePrivateOptions.preconditionOpts,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    await api.execute<void>((client) async {
      final updated = await client.objects.patch(
        metadata,
        bucket.id,
        id,
        generation: this.options.generation?.toString(),
        predefinedAcl: makePrivateOptions.strict == true
            ? PredefinedAcl.private.value
            : PredefinedAcl.projectPrivate.value,
        ifMetagenerationMatch: makePrivateOptions
            .preconditionOpts
            ?.ifMetagenerationMatch
            ?.toString(),
        ifMetagenerationNotMatch: makePrivateOptions
            .preconditionOpts
            ?.ifMetagenerationNotMatch
            ?.toString(),
        ifGenerationMatch: makePrivateOptions
            .preconditionOpts
            ?.ifGenerationMatch
            ?.toString(),
        ifGenerationNotMatch: makePrivateOptions
            .preconditionOpts
            ?.ifGenerationNotMatch
            ?.toString(),
        userProject: makePrivateOptions.userProject ?? userProject,
      );
      setInstanceMetadata(updated);
    });
  }

  Future<void> makePublic() async {
    await acl.add(
      entity: 'allUsers',
      role: 'READER',
      userProject: userProject ?? options.userProject,
    );
  }

  /// The public URL of this File.
  ///
  /// Use [makePublic] to enable anonymous access via the returned URL.
  String publicUrl() {
    return '${storage.config.apiEndpoint}/${bucket.name}/${Uri.encodeComponent(name)}';
  }

  /// Move this file within the same bucket atomically.
  ///
  /// The source object must exist and be a live object.
  /// The source and destination object IDs must be different.
  /// Overwriting the destination object is allowed by default, but can be prevented
  /// using preconditions.
  Future<BucketFile> moveFileAtomic(
    MoveFileAtomicDestination destination, {
    MoveOptions? options,
  }) async {
    final moveOptions = options ?? const MoveOptions();
    String destName;
    BucketFile? newFile;

    if (destination is PathMoveFileAtomicDestination) {
      // Check for gs:// URL format (but must be same bucket)
      final gsMatch = RegExp(
        r'^gs://([a-z0-9_.-]+)/(.+)$',
      ).firstMatch(destination.path);
      if (gsMatch != null) {
        if (gsMatch.group(1) != bucket.id) {
          throw ArgumentError(
            'moveFileAtomic can only move within the same bucket',
          );
        }
        destName = gsMatch.group(2)!;
      } else {
        destName = destination.path;
      }
    } else if (destination is FileMoveFileAtomicDestination) {
      if (destination.file.bucket.id != bucket.id) {
        throw ArgumentError(
          'moveFileAtomic can only move within the same bucket',
        );
      }
      destName = destination.file.id;
      newFile = destination.file;
    } else {
      throw ArgumentError('Destination file should have a name.');
    }

    newFile ??= bucket.file(destName);
    final destinationFile = newFile;

    final api = ApiExecutor(
      bucket.storage,
      preconditionOptions: moveOptions.preconditionOpts,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    return await api.execute<BucketFile>((client) async {
      final response = await client.objects.move(
        bucket.id,
        id,
        destName,
        ifGenerationMatch: moveOptions.preconditionOpts?.ifGenerationMatch
            ?.toString(),
        userProject: moveOptions.userProject ?? userProject,
      );

      destinationFile.setInstanceMetadata(response);
      return destinationFile;
    });
  }

  /// Move this file to another location.
  ///
  /// **Warning**: There is currently no atomic `move` method in the Cloud Storage API,
  /// so this method is a composition of [copy] (to the new location) and [delete]
  /// (from the old location). While unlikely, it is possible that an error could be
  /// triggered from either one of these API calls failing.
  Future<BucketFile> move(
    CopyDestination destination, {
    MoveOptions? options,
  }) async {
    final moveOptions = options ?? const MoveOptions();

    final copiedFile = await copy(
      destination,
      options: CopyOptions(
        userProject: moveOptions.userProject ?? userProject,
        preconditionOpts: moveOptions.preconditionOpts,
      ),
    );

    // Only delete if the destination is different
    if (id != copiedFile.id || bucket.id != copiedFile.bucket.id) {
      await delete(options: moveOptions.preconditionOpts);
    }

    return copiedFile;
  }

  Future<BucketFile> rename(
    CopyDestination destinationFile, {
    MoveOptions? options,
  }) async {
    return await move(destinationFile, options: options);
  }

  /// Restore a soft-deleted file.
  Future<BucketFile> restore(RestoreFileOptions options) async {
    final api = ApiExecutor(
      bucket.storage,
      preconditionOptions: options,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    return await api.execute<BucketFile>((client) async {
      final response = await client.objects.restore(
        bucket.id,
        id,
        options.generation.toString(),
        restoreToken: options.restoreToken,
        projection: options.projection?.name,
        ifGenerationMatch: options.ifGenerationMatch?.toString(),
        ifGenerationNotMatch: options.ifGenerationNotMatch?.toString(),
        ifMetagenerationMatch: options.ifMetagenerationMatch?.toString(),
        ifMetagenerationNotMatch: options.ifMetagenerationNotMatch?.toString(),
        userProject: options.userProject ?? userProject,
      );

      setInstanceMetadata(response);
      return this;
    });
  }

  /// Rotates the encryption key for this file.
  ///
  /// This method allows you to update the encryption key associated with this
  /// file by copying it to a new file with the new encryption key.
  ///
  /// The [options] parameter contains:
  /// - [RotateEncryptionKeyOptions.encryptionKey]: An [EncryptionKey] instance
  ///   representing the new AES-256 customer-supplied encryption key. You can
  ///   create an [EncryptionKey] using [EncryptionKey.fromString] or
  ///   [EncryptionKey.fromBuffer].
  /// - [RotateEncryptionKeyOptions.kmsKeyName]: A Cloud KMS key name (alternative
  ///   to customer-supplied encryption key).
  /// - [RotateEncryptionKeyOptions.preconditionOpts]: Precondition options for
  ///   the copy operation (e.g., ifGenerationMatch).
  ///
  /// See https://cloud.google.com/storage/docs/encryption#customer-supplied
  Future<BucketFile> rotateEncryptionKey([
    RotateEncryptionKeyOptions? options,
  ]) async {
    final opts = options ?? const RotateEncryptionKeyOptions();

    // Create new file with encryption key options
    final newFileOptions = FileOptions(
      encryptionKey: opts.encryptionKey,
      kmsKeyName: opts.kmsKeyName,
    );
    final newFile = bucket.file(name, newFileOptions);

    // Prepare copy options with precondition options if ifGenerationMatch is defined
    final copyOptions = opts.preconditionOpts?.ifGenerationMatch != null
        ? CopyOptions(preconditionOpts: opts.preconditionOpts)
        : const CopyOptions();

    // Copy this file to the new file
    return await copy(CopyDestination.file(newFile), options: copyOptions);
  }

  Future<void> save(SaveData data, [SaveOptions? options]) async {
    final opts = options ?? const SaveOptions();
    // Use ApiExecutor for retry logic
    // ApiExecutor will automatically disable retries based on preconditions and idempotency strategy
    final api = ApiExecutor(
      storage,
      preconditionOptions: opts.preconditionOpts,
      instancePreconditions: preconditionOpts,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    await api.execute<void>((client) async {
      await _saveData(data, opts);
    });
  }

  Future<void> _saveData(Object data, SaveOptions options) async {
    final completer = Completer<void>();
    final writable = _streamFactory.createWriteStream(this, options);

    // Progress events are handled in createWriteStream

    Stream<List<int>> dataStream;
    if (data is String) {
      dataStream = Stream.value(utf8.encode(data));
    } else if (data is Uint8List) {
      dataStream = Stream.value(data.toList());
    } else if (data is List<int>) {
      dataStream = Stream.value(data);
    } else if (data is Stream<List<int>>) {
      dataStream = data;
    } else {
      throw ArgumentError(
        'Data must be String, Uint8List, List<int>, or Stream<List<int>>',
      );
    }

    final subscription = dataStream.listen(
      (chunk) {
        writable.add(chunk);
      },
      onError: (error, stackTrace) {
        writable.addError(error, stackTrace);
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
      onDone: () async {
        try {
          await writable.close();
          if (!completer.isCompleted) {
            completer.complete();
          }
        } catch (e, stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(e, stackTrace);
          }
        }
      },
    );

    writable.done
        .then((_) {
          subscription.cancel();
          if (!completer.isCompleted) {
            completer.complete();
          }
        })
        .catchError((error, stackTrace) {
          subscription.cancel();
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        });

    return completer.future;
  }

  StreamSink<List<int>> _startResumableUpload(
    StreamController<List<int>> controller,
    CreateWriteStreamOptions options,
    FileMetadata metadata,
    HashStreamValidator? hashValidator,
    void Function() onMetadataReceived,
  ) {
    // Validate chunk size: must be at least 256KB and a multiple of 256KB
    // This matches GCS requirements: https://cloud.google.com/storage/docs/performing-resumable-uploads#chunked-upload
    final chunkSize = options.chunkSize ?? 256 * 1024;
    if (chunkSize < 256 * 1024 || chunkSize % (256 * 1024) != 0) {
      throw ArgumentError(
        'chunkSize must be at least 256KB (262144 bytes) and a multiple of 256KB. Got: $chunkSize bytes',
      );
    }

    // Create resumable upload sink to handle chunked uploads
    final config = _ResumableUploadConfig(
      storage: storage,
      bucket: bucket.id,
      file: name,
      uri: options.uri,
      offset: options.offset,
      chunkSize: chunkSize,
      metadata: metadata,
      encryptionKey: _encryptionKey,
      userProject: options.userProject ?? userProject,
      isPartialUpload: options.isPartialUpload ?? false,
      createUriCallback: options.uri == null
          ? () => createResumableUpload(
              CreateResumableUploadOptions(
                metadata: metadata,
                offset: options.offset,
                predefinedAcl: options.predefinedAcl,
                private: options.private,
                public: options.public,
                userProject: options.userProject,
                preconditionOpts: options.preconditionOpts,
                chunkSize: options.chunkSize,
                highWaterMark: options.highWaterMark,
                isPartialUpload: options.isPartialUpload,
              ),
            )
          : null,
      onMetadataReceived: (uploadedMetadata) {
        setInstanceMetadata(uploadedMetadata);
        onMetadataReceived();
      },
      onUploadProgress: options.onUploadProgress,
    );

    return _ResumableUploadSink(config);
  }

  StreamSink<List<int>> _startSimpleUpload(
    StreamController<List<int>> controller,
    CreateWriteStreamOptions options,
    FileMetadata metadata,
    HashStreamValidator? hashValidator,
    void Function() onMetadataReceived,
  ) {
    final sinkController = StreamController<List<int>>();
    final dataBuffer = <int>[];
    final uploadCompleter = Completer<void>();
    var bytesWritten = 0;

    sinkController.stream.listen(
      (data) {
        dataBuffer.addAll(data);
        bytesWritten += data.length;

        // Report progress as data is buffered
        options.onUploadProgress?.call(
          UploadProgress(
            bytesWritten: bytesWritten,
            totalBytes: metadata.size != null
                ? int.tryParse(metadata.size!)
                : null,
          ),
        );
      },
      onDone: () async {
        try {
          await _performSimpleUpload(
            dataBuffer,
            options,
            metadata,
            onMetadataReceived,
          );
          await sinkController.close();
          if (!uploadCompleter.isCompleted) {
            uploadCompleter.complete();
          }
        } catch (e, stackTrace) {
          // Don't call sinkController.addError here - the stream is already
          // closed (onDone means the stream finished). Just propagate the
          // error through the uploadCompleter.
          if (!uploadCompleter.isCompleted) {
            uploadCompleter.completeError(e, stackTrace);
          }
        }
      },
      onError: (error, stackTrace) {
        // Stream error occurred before onDone - propagate through completer
        if (!uploadCompleter.isCompleted) {
          uploadCompleter.completeError(error, stackTrace);
        }
      },
      cancelOnError: false,
    );

    // Wrap the sink so that done waits for _performSimpleUpload to complete.
    // This ensures bucket.upload() waits for the actual upload, not just
    // the stream to close.
    return _SimpleUploadSink(sinkController.sink, uploadCompleter.future);
  }

  Future<void> _performSimpleUpload(
    List<int> data,
    CreateWriteStreamOptions options,
    FileMetadata metadata,
    void Function() onMetadataReceived,
  ) async {
    // Build query parameters
    final queryParams = <String, String>{
      'uploadType': 'multipart',
      'name': name,
    };

    if (this.options.generation != null) {
      queryParams['ifGenerationMatch'] = this.options.generation.toString();
    }

    if (kmsKeyName != null) {
      queryParams['kmsKeyName'] = kmsKeyName!;
    }

    final effectiveUserProject = options.userProject ?? userProject;
    if (effectiveUserProject != null) {
      queryParams['userProject'] = effectiveUserProject;
    }

    // Determine predefinedAcl
    PredefinedAcl? predefinedAcl = options.predefinedAcl;
    if (options.private == true) {
      predefinedAcl = PredefinedAcl.private;
    } else if (options.public == true) {
      predefinedAcl = PredefinedAcl.publicRead;
    }

    if (predefinedAcl != null) {
      queryParams['predefinedAcl'] = predefinedAcl.value;
    }

    // Add precondition options
    final preconditions = options.preconditionOpts ?? preconditionOpts;
    if (preconditions != null) {
      if (preconditions.ifGenerationMatch != null) {
        queryParams['ifGenerationMatch'] = preconditions.ifGenerationMatch
            .toString();
      }
      if (preconditions.ifGenerationNotMatch != null) {
        queryParams['ifGenerationNotMatch'] = preconditions.ifGenerationNotMatch
            .toString();
      }
      if (preconditions.ifMetagenerationMatch != null) {
        queryParams['ifMetagenerationMatch'] = preconditions
            .ifMetagenerationMatch
            .toString();
      }
      if (preconditions.ifMetagenerationNotMatch != null) {
        queryParams['ifMetagenerationNotMatch'] = preconditions
            .ifMetagenerationNotMatch
            .toString();
      }
    }

    // Build request URI
    final apiEndpoint = storage.config.apiEndpoint;
    final uri = Uri.parse(apiEndpoint).replace(
      path: '/upload/storage/v1/b/${bucket.id}/o',
      queryParameters: queryParams,
    );

    // Build multipart request
    final boundary =
        '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';
    final authClient = await storage.authClient;

    // Serialize metadata
    final metadataJson = <String, dynamic>{};
    if (metadata.name != null) metadataJson['name'] = metadata.name;
    if (metadata.contentType != null) {
      metadataJson['contentType'] = metadata.contentType;
    }
    if (metadata.contentEncoding != null) {
      metadataJson['contentEncoding'] = metadata.contentEncoding;
    }
    if (metadata.metadata != null) {
      metadataJson['metadata'] = metadata.metadata;
    }

    // Build multipart body according to RFC 2388.
    // Format: boundary + metadata part (JSON) + boundary + data part + closing boundary
    final multipartBody = <int>[];
    final metadataPart = utf8.encode(
      '--$boundary\r\n'
      'Content-Type: application/json; charset=UTF-8\r\n'
      '\r\n'
      '${jsonEncode(metadataJson)}\r\n'
      '--$boundary\r\n'
      'Content-Type: ${metadata.contentType ?? 'application/octet-stream'}\r\n'
      '\r\n',
    );
    multipartBody.addAll(metadataPart);
    multipartBody.addAll(data);
    multipartBody.addAll(utf8.encode('\r\n--$boundary--\r\n'));

    final request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'multipart/related; boundary=$boundary';
    request.headers['Content-Length'] = multipartBody.length.toString();

    // Add encryption headers if needed
    if (_encryptionKey != null) {
      request.headers['x-goog-encryption-algorithm'] = 'AES256';
      request.headers['x-goog-encryption-key'] = _encryptionKey!.keyBase64;
      request.headers['x-goog-encryption-key-sha256'] = _encryptionKey!.keyHash;
    }

    request.bodyBytes = multipartBody;

    // Execute request
    final api = ApiExecutor(
      storage,
      preconditionOptions: preconditions,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    await api.execute<void>((client) async {
      final response = await authClient.send(request);
      final body = await response.stream.bytesToString();

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiError(
          'Simple upload failed',
          code: response.statusCode,
          details: body,
        );
      }

      // Parse response metadata
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final uploadedMetadata = storage_v1.Object.fromJson(json);
        setInstanceMetadata(uploadedMetadata);
        onMetadataReceived();
      } catch (e) {
        // Ignore parse errors
      }
    });
  }

  /// Set the storage class for this file.
  Future<void> setStorageClass(
    String storageClass, {
    SetFileStorageClassOptions? options,
  }) async {
    final setStorageClassOptions =
        options ?? const SetFileStorageClassOptions();

    // Convert storage class to SNAKE_CASE
    final modified = storageClass
        .replaceAll('-', '_')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (Match match) => '${match[1]}_${match[2]}',
        )
        .toUpperCase();

    // Use copy to update storage class - copy to same file with new storage class
    await copy(
      CopyDestination.file(this),
      options: CopyOptions(
        userProject: setStorageClassOptions.userProject ?? userProject,
        preconditionOpts: setStorageClassOptions,
      ),
    );
    // Update this instance's metadata with the new storage class
    final updatedMetadata = metadata..storageClass = modified;
    setInstanceMetadata(updatedMetadata);
  }

  /// Set a user project to be billed for all requests made from this File object.
  void setUserProject(String userProject) {
    this.userProject = userProject;
  }
}

/// Helper function to convert file action to HTTP method for signed URLs.
SignedUrlMethod _fileActionToHttpMethod(String action) {
  switch (action) {
    case 'read':
      return SignedUrlMethod.get;
    case 'write':
      return SignedUrlMethod.put;
    case 'delete':
      return SignedUrlMethod.delete;
    case 'resumable':
      return SignedUrlMethod.post;
    default:
      throw ArgumentError('Invalid action: $action');
  }
}

/// A wrapper around StreamSink that ensures 'done' waits for the upload to complete.
///
/// For simple (multipart) uploads, the actual HTTP request happens asynchronously
/// in the stream's onDone handler. This wrapper ensures that the sink's done future
/// completes only after the upload request finishes, not just when the stream closes.
class _SimpleUploadSink implements StreamSink<List<int>> {
  final StreamSink<List<int>> _sink;
  final Future<void> _uploadFuture;

  _SimpleUploadSink(this._sink, this._uploadFuture);

  @override
  void add(List<int> data) => _sink.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _sink.addError(error, stackTrace);

  @override
  Future<void> close() => _sink.close();

  @override
  Future<void> get done => _uploadFuture;

  @override
  Future<void> addStream(Stream<List<int>> stream) => _sink.addStream(stream);
}

/// Internal sink that wraps the upload stream and handles validation.
class _UploadSink implements StreamSink<List<int>> {
  final StreamController<List<int>> _controller;
  final StreamSink<List<int>> _uploadSink;
  final HashStreamValidator? _hashValidator;
  final FileMetadata _metadata;
  final bool _crc32c;
  final bool _md5;
  final bool Function() _isMetadataReceived;

  StreamSubscription<List<int>>? _subscription;

  _UploadSink(
    this._controller,
    StreamSubscription<List<int>> subscription,
    this._uploadSink,
    this._hashValidator,
    this._metadata,
    this._crc32c,
    this._md5,
    this._isMetadataReceived,
  ) {
    // Keep the subscription alive - it forwards data from controller.stream
    // through the pipeline (gzip/hash) to uploadSink
    _subscription = subscription;
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
    // Cancel the pipeline subscription now that we're closing
    await _subscription?.cancel();
    await _uploadSink.close();

    // Wait briefly for metadata to be received if it hasn't been yet.
    // This handles the case where the upload completes asynchronously.
    if (!_isMetadataReceived()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Validate data integrity by comparing calculated hashes with server response.
    // This ensures the uploaded data matches what the server received.
    final validator = _hashValidator;
    if (validator != null && _isMetadataReceived()) {
      final serverCrc32c = _metadata.crc32c;
      final serverMd5 = _metadata.md5Hash;

      if (_crc32c && serverCrc32c != null) {
        final calculatedCrc32c = validator.crc32c;
        if (calculatedCrc32c != null &&
            !validator.test('crc32c', serverCrc32c)) {
          throw ApiError(
            'The uploaded data did not match the data from the server. '
            'To be sure the content is the same, you should try uploading the file again.',
          );
        }
      }

      if (_md5 && serverMd5 != null) {
        // MD5 validation would need to be implemented in HashStreamValidator
        // For now, we'll skip it
      }
    }
  }

  @override
  Future<void> get done => _uploadSink.done;

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await _controller.addStream(stream);
  }
}
