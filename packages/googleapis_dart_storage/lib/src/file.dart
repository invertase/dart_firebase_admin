part of '../googleapis_dart_storage.dart';

class FileMetadata {}

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

class File extends ServiceObject<FileMetadata>
    with
        GettableMixin<FileMetadata>,
        SettableMixin<FileMetadata>,
        DeletableMixin<FileMetadata> {
  File._(this.bucket, String name, [FileOptions? options])
      : options = (options ?? const FileOptions()).copyWith(
          // Inherit from bucket's storage options crc32cGenerator (which has a default) if not specified in file options
          crc32cGenerator: options?.crc32cGenerator ??
              bucket.storage.options.crc32cGenerator,
          userProject: options?.userProject ?? bucket.options.userProject,
          // Note: kmsKeyName and encryptionKey are NOT inherited - they are file-specific
        ),
        acl = Acl._objectAcl(bucket.storage, bucket.id, name),
        super(service: bucket.storage, id: name);

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
  Future<FileMetadata> get() {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  // TODO: implement metadata
  FileMetadata get metadata => throw UnimplementedError();

  @override
  Future<FileMetadata> setMetadata(FileMetadata metadata) {
    // TODO: implement setMetadata
    throw UnimplementedError();
  }
}
