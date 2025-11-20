part of '../googleapis_dart_storage.dart';

final _GS_UTIL_URL_REGEX = RegExp(r'^gs://([a-z0-9_.-]+)/(.+)$');
final _HTTPS_PUBLIC_URL_REGEX =
    RegExp(r'^https://storage\.googleapis\.com/([a-z0-9_.-]+)/(.+)$');

typedef FileMetadata = storage_v1.Object;

class FileOptions {
  final Crc32Generator? crc32cGenerator;
  final String? encryptionKey;
  final int? generation;
  final String? restoreToken;
  final String? kmsKeyName;
  final PreconditionOptions? preconditionOpts;
  final String? userProject;

  const FileOptions({
    this.crc32cGenerator,
    this.encryptionKey,
    this.generation,
    this.restoreToken,
    this.kmsKeyName,
    this.preconditionOpts,
    this.userProject,
  });

  FileOptions copyWith({
    Crc32Generator? crc32cGenerator,
    String? encryptionKey,
    int? generation,
    String? restoreToken,
    String? kmsKeyName,
    PreconditionOptions? preconditionOpts,
    String? userProject,
  }) {
    return FileOptions(
      crc32cGenerator: crc32cGenerator ?? this.crc32cGenerator,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      generation: generation ?? this.generation,
      restoreToken: restoreToken ?? this.restoreToken,
      kmsKeyName: kmsKeyName ?? this.kmsKeyName,
      preconditionOpts: preconditionOpts ?? this.preconditionOpts,
      userProject: userProject ?? this.userProject,
    );
  }
}

class GetFilesOptions {
  final bool? autoPaginate;
  final String? delimiter;
  final String? endOffset;
  final bool? includeFoldersAsPrefixes;
  final bool? includeTrailingDelimiter;
  final String? prefix;
  final String? matchGlob;
  final int? maxApiCalls;
  final int? maxResults;
  final String? pageToken;
  final bool? softDeleted;
  final String? startOffset;
  final String? userProject;
  final bool? versions;
  final String? fields;

  const GetFilesOptions({
    this.autoPaginate = true,
    this.delimiter,
    this.endOffset,
    this.includeFoldersAsPrefixes,
    this.includeTrailingDelimiter,
    this.prefix,
    this.matchGlob,
    this.maxApiCalls,
    this.maxResults,
    this.pageToken,
    this.softDeleted,
    this.startOffset,
    this.userProject,
    this.versions,
    this.fields,
  });

  GetFilesOptions copyWith({
    bool? autoPaginate,
    String? delimiter,
    String? endOffset,
    bool? includeFoldersAsPrefixes,
    bool? includeTrailingDelimiter,
    String? prefix,
    String? matchGlob,
    int? maxApiCalls,
    int? maxResults,
    String? pageToken,
    bool? softDeleted,
    String? startOffset,
    String? userProject,
    bool? versions,
    String? fields,
  }) {
    return GetFilesOptions(
      autoPaginate: autoPaginate ?? this.autoPaginate,
      delimiter: delimiter ?? this.delimiter,
      endOffset: endOffset ?? this.endOffset,
      includeFoldersAsPrefixes:
          includeFoldersAsPrefixes ?? this.includeFoldersAsPrefixes,
      includeTrailingDelimiter:
          includeTrailingDelimiter ?? this.includeTrailingDelimiter,
      prefix: prefix ?? this.prefix,
      matchGlob: matchGlob ?? this.matchGlob,
      maxApiCalls: maxApiCalls ?? this.maxApiCalls,
      maxResults: maxResults ?? this.maxResults,
      pageToken: pageToken ?? this.pageToken,
      softDeleted: softDeleted ?? this.softDeleted,
      startOffset: startOffset ?? this.startOffset,
      userProject: userProject ?? this.userProject,
      versions: versions ?? this.versions,
      fields: fields ?? this.fields,
    );
  }
}

class DeleteFileOptions extends GetFilesOptions {
  final bool? force;
  // PreconditionOptions fields
  final int? ifGenerationMatch;
  final int? ifGenerationNotMatch;
  final int? ifMetagenerationMatch;
  final int? ifMetagenerationNotMatch;

  const DeleteFileOptions({
    this.force,
    // GetFilesOptions fields
    super.autoPaginate,
    super.delimiter,
    super.endOffset,
    super.includeFoldersAsPrefixes,
    super.includeTrailingDelimiter,
    super.prefix,
    super.matchGlob,
    super.maxApiCalls,
    super.maxResults,
    super.pageToken,
    super.softDeleted,
    super.startOffset,
    super.userProject,
    super.versions,
    super.fields,
    // PreconditionOptions fields
    this.ifGenerationMatch,
    this.ifGenerationNotMatch,
    this.ifMetagenerationMatch,
    this.ifMetagenerationNotMatch,
  });
}

class GetFileMetadataOptions {
  final String? userProject;

  const GetFileMetadataOptions({this.userProject});
}

class SetFileMetadataOptions extends PreconditionOptions {
  final String? userProject;

  const SetFileMetadataOptions({
    this.userProject,
    super.ifMetagenerationMatch,
    super.ifMetagenerationNotMatch,
    super.ifGenerationMatch,
    super.ifGenerationNotMatch,
  });
}

class CopyOptions {
  final String? cacheControl;
  final String? contentEncoding;
  final String? contentType;
  final String? contentDisposition;
  final String? destinationKmsKeyName;
  final Map<String, String>? metadata;
  final String? predefinedAcl;
  final String? token;
  final String? userProject;
  final PreconditionOptions? preconditionOpts;

  const CopyOptions({
    this.cacheControl,
    this.contentEncoding,
    this.contentType,
    this.contentDisposition,
    this.destinationKmsKeyName,
    this.metadata,
    this.predefinedAcl,
    this.token,
    this.userProject,
    this.preconditionOpts,
  });
}

class MoveOptions {
  final String? userProject;
  final PreconditionOptions? preconditionOpts;

  const MoveOptions({
    this.userProject,
    this.preconditionOpts,
  });
}

class MakeFilePrivateOptions {
  final FileMetadata? metadata;
  final bool? strict;
  final String? userProject;
  final PreconditionOptions? preconditionOpts;

  const MakeFilePrivateOptions({
    this.metadata,
    this.strict,
    this.userProject,
    this.preconditionOpts,
  });
}

class GetFileSignedUrlOptions {
  final Uri? host; // inherited from SignedUrlConfig
  final Uri? signingEndpoint; // inherited from SignedUrlConfig

  final String action;
  final SignedUrlVersion? version;
  final String? cname;
  final bool? virtualHostedStyle;
  final DateTime expires;
  final Map<String, String>? extensionHeaders;
  final Map<String, String>? queryParams;
  final String? contentMd5;
  final String? contentType;
  final String? promptSaveAs;
  final String? responseDisposition;
  final String? responseType;
  final DateTime? accessibleAt;

  const GetFileSignedUrlOptions({
    this.host,
    this.signingEndpoint,
    required this.action,
    this.version,
    this.cname,
    this.virtualHostedStyle = false,
    required this.expires,
    this.extensionHeaders,
    this.queryParams,
    this.contentMd5,
    this.contentType,
    this.promptSaveAs,
    this.responseDisposition,
    this.responseType,
    this.accessibleAt,
  });
}

class SetFileStorageClassOptions extends SetFileMetadataOptions {
  const SetFileStorageClassOptions({
    super.userProject,
    super.ifMetagenerationMatch,
    super.ifMetagenerationNotMatch,
    super.ifGenerationMatch,
    super.ifGenerationNotMatch,
  });
}

class RestoreFileOptions extends PreconditionOptions {
  final int generation;
  final String? restoreToken;
  final Projection? projection;
  final String? userProject;

  const RestoreFileOptions({
    required this.generation,
    this.restoreToken,
    this.projection,
    this.userProject,
    super.ifMetagenerationMatch,
    super.ifMetagenerationNotMatch,
    super.ifGenerationMatch,
    super.ifGenerationNotMatch,
  });
}

class File extends ServiceObject<FileMetadata>
    with
        GettableMixin<FileMetadata, File>,
        DeletableMixin<FileMetadata>,
        SettableMixin<FileMetadata> {
  File._(this.bucket, this.name, [FileOptions? options])
      : options = (options ?? const FileOptions()).copyWith(
          // Inherit from bucket's storage options crc32cGenerator (which has a default) if not specified in file options
          crc32cGenerator: options?.crc32cGenerator ??
              bucket.storage.options.crc32cGenerator,
          // Use provided userProject, or fall back to bucket's instance-level userProject
          // This ensures setUserProject() on the bucket is reflected in newly created files
          userProject: options?.userProject ?? bucket.userProject,
          // Note: kmsKeyName and encryptionKey are NOT inherited - they are file-specific
        ),
        acl = Acl._objectAcl(bucket.storage, bucket.id, name),
        userProject = options?.userProject ?? bucket.userProject,
        super(service: bucket.storage, id: name, metadata: FileMetadata());

  final String name;
  final Bucket bucket;
  final FileOptions options;
  final Acl acl;
  URLSigner? _signer;

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

  factory File.from(String publicUrlOrGsUrl, Storage storage,
      [FileOptions? options]) {
    final gsMatches = _GS_UTIL_URL_REGEX.firstMatch(publicUrlOrGsUrl);
    final httpsMatches = _HTTPS_PUBLIC_URL_REGEX.firstMatch(publicUrlOrGsUrl);

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
    final executor = RetryExecutor(
      bucket.storage,
      preconditionOptions: options,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    try {
      await executor.retry<void>((client) async {
        await client.objects.delete(
          bucket.id,
          id,
          generation: options?.ifGenerationMatch?.toString(),
          ifGenerationMatch: options?.ifGenerationMatch?.toString(),
          ifGenerationNotMatch: options?.ifGenerationNotMatch?.toString(),
          ifMetagenerationMatch: options?.ifMetagenerationMatch?.toString(),
          ifMetagenerationNotMatch:
              options?.ifMetagenerationNotMatch?.toString(),
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
    // This matches TypeScript where getMetadata() makes the API request directly
    final executor = RetryExecutor(bucket.storage);
    final response = await executor.retry<FileMetadata>(
      (client) async {
        // Use provided userProject or fall back to instance-level userProject
        final result = await client.objects.get(
          bucket.id,
          id,
          generation: options.generation?.toString(),
          userProject: userProject ?? this.userProject ?? options.userProject,
        );
        // Cast to FileMetadata (which is storage_v1.Object)
        return result as FileMetadata;
      },
    );
    setInstanceMetadata(response);
    return response;
  }

  @override
  Future<FileMetadata> setMetadata(
    FileMetadata metadata, {
    SetFileMetadataOptions? options = const SetFileMetadataOptions(),
  }) {
    final executor = RetryExecutor(
      bucket.storage,
      preconditionOptions: options,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    return executor.retry<FileMetadata>(
      (client) async {
        // Use provided userProject or fall back to instance-level userProject
        final updated = await client.objects.patch(
          metadata,
          bucket.id,
          id,
          generation: this.options.generation?.toString(),
          ifMetagenerationMatch: options?.ifMetagenerationMatch?.toString(),
          ifMetagenerationNotMatch:
              options?.ifMetagenerationNotMatch?.toString(),
          ifGenerationMatch: options?.ifGenerationMatch?.toString(),
          ifGenerationNotMatch: options?.ifGenerationNotMatch?.toString(),
          userProject: options?.userProject ?? userProject,
        );
        setInstanceMetadata(updated);
        return updated;
      },
    );
  }

  /// Copy this file to another file.
  ///
  /// By default, this will copy the file to the same bucket, but you can choose
  /// to copy it to another Bucket by providing a Bucket or File object or a URL
  /// starting with "gs://". The generation of the file will not be preserved.
  Future<File> copy(
    FileBucketDestination destination, {
    CopyOptions? options,
  }) async {
    final copyOptions = options ?? const CopyOptions();
    late Bucket destBucket;
    late File newFile;

    if (destination is _FileInstanceDestination) {
      destBucket = destination.file.bucket;
      newFile = destination.file;
    } else if (destination is _BucketDestination) {
      destBucket = destination.bucket;
      newFile = destBucket.file(name);
    } else if (destination is _PathDestination) {
      final gsMatch =
          RegExp(r'^gs://([a-z0-9_.-]+)/(.+)$').firstMatch(destination.path);
      if (gsMatch != null) {
        destBucket = storage.bucket(gsMatch.group(1)!);
        newFile = destBucket.file(gsMatch.group(2)!);
      } else {
        destBucket = bucket;
        newFile = destBucket.file(destination.path);
      }
    }

    final executor = RetryExecutor(
      bucket.storage,
      preconditionOptions: copyOptions.preconditionOpts,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    return await executor.retry<File>(
      (client) async {
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
          destinationPredefinedAcl: copyOptions.predefinedAcl,
          ifGenerationMatch:
              copyOptions.preconditionOpts?.ifGenerationMatch?.toString(),
          ifGenerationNotMatch:
              copyOptions.preconditionOpts?.ifGenerationNotMatch?.toString(),
          ifMetagenerationMatch:
              copyOptions.preconditionOpts?.ifMetagenerationMatch?.toString(),
          ifMetagenerationNotMatch: copyOptions
              .preconditionOpts?.ifMetagenerationNotMatch
              ?.toString(),
          userProject: copyOptions.userProject ?? userProject,
        );

        // If rewriteToken is present, we need to continue the copy
        if (response.rewriteToken != null &&
            response.rewriteToken!.isNotEmpty) {
          return await copy(
            FileBucketDestination.file(newFile),
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
      },
    );
  }

  Stream<List<int>> createReadStream([Map<String, dynamic>? options]) {
    throw UnimplementedError('createReadStream() is not implemented');
  }

  Future<String> createResumableUpload([Map<String, dynamic>? options]) {
    throw UnimplementedError('createResumableUpload() is not implemented');
  }

  StreamSink<List<int>> createWriteStream([Map<String, dynamic>? options]) {
    throw UnimplementedError('createWriteStream() is not implemented');
  }

  Future<List<int>> download([Map<String, dynamic>? options]) {
    throw UnimplementedError('download() is not implemented');
  }

  void setEncryptionKey() {
    throw UnimplementedError('setEncryptionKey() is not implemented');
  }

  /// Get a Date object representing the earliest time this file will expire.
  ///
  /// If this bucket has a retention policy defined, use this method to get a
  /// Date object representing the earliest time this file will expire.
  Future<DateTime> getExpirationDate() async {
    final metadata = await getMetadata();
    if (metadata.retentionExpirationTime == null) {
      // TODO: Should this be a custom error?
      throw ApiError('An expiration time is not available.');
    }
    // retentionExpirationTime is already a DateTime
    return metadata.retentionExpirationTime!;
  }

  Future<Map<String, dynamic>> generateSignedPostPolicyV2(
      [Map<String, dynamic>? options]) {
    throw UnimplementedError('generateSignedPostPolicyV2() is not implemented');
  }

  Future<Map<String, dynamic>> generateSignedPostPolicyV4(
      [Map<String, dynamic>? options]) {
    throw UnimplementedError('generateSignedPostPolicyV4() is not implemented');
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
      extensionHeaders: options.extensionHeaders,
      queryParams: queryParams,
      contentMd5: options.contentMd5,
      contentType: options.contentType,
      host: options.host,
      signingEndpoint: options.signingEndpoint,
    );

    // Lazy initialize the signer
    _signer ??= URLSigner._(bucket, this);

    return await _signer!.getSignedUrl(configWithQueryParams);
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

  Future<void> makePrivate(
      [MakeFilePrivateOptions? options =
          const MakeFilePrivateOptions()]) async {
    final makePrivateOptions = options ?? const MakeFilePrivateOptions();
    // Merge options.metadata with acl: null
    // You aren't allowed to set both predefinedAcl & acl properties on a file
    // so acl must explicitly be nullified.
    final metadata = (makePrivateOptions.metadata ?? FileMetadata())
      ..acl = null;

    // Note: predefinedAcl is set via patch method parameter, not in SetFileMetadataOptions
    // We need to use a different approach - setMetadata doesn't support predefinedAcl directly
    // So we'll need to call patch with predefinedAcl parameter
    final executor = RetryExecutor(
      bucket.storage,
      preconditionOptions: makePrivateOptions.preconditionOpts,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    await executor.retry<void>(
      (client) async {
        final updated = await client.objects.patch(
          metadata,
          bucket.id,
          id,
          generation: this.options.generation?.toString(),
          predefinedAcl:
              makePrivateOptions.strict == true ? 'private' : 'projectPrivate',
          ifMetagenerationMatch: makePrivateOptions
              .preconditionOpts?.ifMetagenerationMatch
              ?.toString(),
          ifMetagenerationNotMatch: makePrivateOptions
              .preconditionOpts?.ifMetagenerationNotMatch
              ?.toString(),
          ifGenerationMatch: makePrivateOptions
              .preconditionOpts?.ifGenerationMatch
              ?.toString(),
          ifGenerationNotMatch: makePrivateOptions
              .preconditionOpts?.ifGenerationNotMatch
              ?.toString(),
          userProject: makePrivateOptions.userProject ?? userProject,
        );
        setInstanceMetadata(updated);
      },
    );
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
  Future<File> moveFileAtomic(
    FileDestination destination, {
    MoveOptions? options,
  }) async {
    final moveOptions = options ?? const MoveOptions();
    String destName;
    File? newFile;

    if (destination is _PathDestination) {
      // Check for gs:// URL format (but must be same bucket)
      final gsMatch =
          RegExp(r'^gs://([a-z0-9_.-]+)/(.+)$').firstMatch(destination.path);
      if (gsMatch != null) {
        if (gsMatch.group(1) != bucket.id) {
          throw ArgumentError(
              'moveFileAtomic can only move within the same bucket');
        }
        destName = gsMatch.group(2)!;
      } else {
        destName = destination.path;
      }
    } else if (destination is _FileInstanceDestination) {
      if (destination.file.bucket.id != bucket.id) {
        throw ArgumentError(
            'moveFileAtomic can only move within the same bucket');
      }
      destName = destination.file.id;
      newFile = destination.file;
    } else {
      throw ArgumentError('Destination file should have a name.');
    }

    newFile ??= bucket.file(destName);
    final destinationFile = newFile;

    final executor = RetryExecutor(
      bucket.storage,
      preconditionOptions: moveOptions.preconditionOpts,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    return await executor.retry<File>(
      (client) async {
        final response = await client.objects.move(
          bucket.id,
          id,
          destName,
          ifGenerationMatch:
              moveOptions.preconditionOpts?.ifGenerationMatch?.toString(),
          userProject: moveOptions.userProject ?? userProject,
        );

        destinationFile.setInstanceMetadata(response);
        return destinationFile;
      },
    );
  }

  /// Move this file to another location.
  ///
  /// **Warning**: There is currently no atomic `move` method in the Cloud Storage API,
  /// so this method is a composition of [copy] (to the new location) and [delete]
  /// (from the old location). While unlikely, it is possible that an error could be
  /// triggered from either one of these API calls failing.
  Future<File> move(
    FileBucketDestination destination, {
    MoveOptions? options,
  }) async {
    final moveOptions = options ?? const MoveOptions();

    try {
      final copiedFile = await copy(
        destination,
        options: CopyOptions(
          userProject: moveOptions.userProject ?? userProject,
          preconditionOpts: moveOptions.preconditionOpts,
        ),
      );

      // Only delete if the destination is different
      if (id != copiedFile.id || bucket.id != copiedFile.bucket.id) {
        await delete(
          options: PreconditionOptions(
            ifGenerationMatch: moveOptions.preconditionOpts?.ifGenerationMatch,
            ifGenerationNotMatch:
                moveOptions.preconditionOpts?.ifGenerationNotMatch,
            ifMetagenerationMatch:
                moveOptions.preconditionOpts?.ifMetagenerationMatch,
            ifMetagenerationNotMatch:
                moveOptions.preconditionOpts?.ifMetagenerationNotMatch,
          ),
        );
      }

      return copiedFile;
    } catch (e) {
      throw ApiError('file#copy failed with an error - ${e.toString()}');
    }
  }

  Future<File> rename(
    FileBucketDestination destinationFile, {
    MoveOptions? options,
  }) async {
    return await move(destinationFile, options: options);
  }

  /// Restore a soft-deleted file.
  Future<File> restore(RestoreFileOptions options) async {
    final executor = RetryExecutor(
      bucket.storage,
      preconditionOptions: options,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    return await executor.retry<File>(
      (client) async {
        final response = await client.objects.restore(
          bucket.id,
          id,
          options.generation.toString(),
          restoreToken: options.restoreToken,
          projection: options.projection?.name,
          ifGenerationMatch: options.ifGenerationMatch?.toString(),
          ifGenerationNotMatch: options.ifGenerationNotMatch?.toString(),
          ifMetagenerationMatch: options.ifMetagenerationMatch?.toString(),
          ifMetagenerationNotMatch:
              options.ifMetagenerationNotMatch?.toString(),
          userProject: options.userProject ?? userProject,
        );

        setInstanceMetadata(response);
        return this;
      },
    );
  }

  Future<File> rotateEncryptionKey([dynamic options]) {
    throw UnimplementedError('rotateEncryptionKey() is not implemented');
  }

  Future<void> save(dynamic data, [Map<String, dynamic>? options]) {
    throw UnimplementedError('save() is not implemented');
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
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
            (Match match) => '${match[1]}_${match[2]}')
        .toUpperCase();

    // Use copy to update storage class - copy to same file with new storage class
    await copy(
      FileBucketDestination.file(this),
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
    // TODO: In node this calls bucket.setUserProject(userProject), which is not implemented in dart
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

sealed class FileDestination {
  const FileDestination._();
  const factory FileDestination.file(File file) = _FileInstanceDestination;
  const factory FileDestination.path(String path) = _PathDestination;
}

sealed class FileBucketDestination extends FileDestination {
  const FileBucketDestination._() : super._();
  const factory FileBucketDestination.file(File file) =
      _FileInstanceDestination;
  const factory FileBucketDestination.bucket(Bucket bucket) =
      _BucketDestination;
  const factory FileBucketDestination.path(String path) = _PathDestination;
}

class _FileInstanceDestination extends FileBucketDestination {
  final File file;
  const _FileInstanceDestination(this.file) : super._();
}

class _BucketDestination extends FileBucketDestination {
  final Bucket bucket;
  const _BucketDestination(this.bucket) : super._();
}

class _PathDestination extends FileBucketDestination {
  final String path;
  const _PathDestination(this.path) : super._();
}
