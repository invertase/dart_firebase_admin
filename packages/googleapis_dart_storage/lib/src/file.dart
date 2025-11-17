part of '../googleapis_dart_storage.dart';

class FileMetadata {}

class File extends ServiceObject<FileMetadata> {
  File._(this.bucket, String name) : super(service: bucket.storage, id: name);

  final Bucket bucket;

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
