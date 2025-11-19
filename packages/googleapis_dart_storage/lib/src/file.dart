part of '../googleapis_dart_storage.dart';

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

class File extends ServiceObject<FileMetadata>
    with GettableMixin<FileMetadata, File>, DeletableMixin<FileMetadata> {
  File._(this.bucket, String name, [FileOptions? options])
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
        super(service: bucket.storage, id: name, metadata: FileMetadata());

  final Bucket bucket;
  final FileOptions options;
  final Acl acl;

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
  Future<FileMetadata> getMetadata({String? userProject}) {
    // GET operations are idempotent, so retries are enabled by default
    // This matches TypeScript where getMetadata() makes the API request directly
    final executor = RetryExecutor(bucket.storage);
    return executor.retry<FileMetadata>(
      (client) async {
        // TODO: Implement getMetadata
        throw UnimplementedError('getMetadata() is not implemented');
      },
    );
  }

  Future<void> makePublic() async {
    throw UnimplementedError('makePublic() is not implemented');
  }

  Future<void> makePrivate() async {
    throw UnimplementedError('makePrivate() is not implemented');
  }
}
