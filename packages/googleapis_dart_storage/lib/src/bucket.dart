part of '../googleapis_dart_storage.dart';
// import 'dart:async';

// import 'package:googleapis/storage/v1.dart' as storage_v1;

// import 'internal/retry.dart';
// import 'internal/service_object.dart';
// // import 'channel.dart';
// // import 'file.dart';
// // import 'notification.dart';
// import 'storage.dart';

class BucketMetadata {
  final storage_v1.Bucket inner;

  BucketMetadata(this.inner);
}

class BucketOptions {
  final Object? crc32cGenerator;
  final String? kmsKeyName;
  final Object? preconditionOpts;
  final String? userProject;
  final int? generation;
  final bool? softDeleted;

  const BucketOptions({
    this.crc32cGenerator,
    this.kmsKeyName,
    this.preconditionOpts,
    this.userProject,
    this.generation,
    this.softDeleted,
  });
}

class Bucket extends ServiceObject<BucketMetadata> {
  @override
  final BucketMetadata metadata;

  final BucketOptions options;

  Storage get storage => service as Storage;

  Bucket._(Storage storage, String name, [BucketOptions? options])
      : options = options ?? const BucketOptions(),
        metadata = BucketMetadata(storage_v1.Bucket()..name = name),
        super(service: storage, id: name);

  /// Add one or more lifecycle rules to this bucket.
  ///
  /// TODO: Implement using bucket metadata `lifecycle` configuration.
  Future<void> addLifecycleRule() {
    throw UnimplementedError(
      'Bucket.addLifecycleRule() is not implemented yet.',
    );
  }

  /// Create this bucket.
  ///
  /// TODO: Implement using `buckets.insert` and appropriate options.
  Future<BucketMetadata> create() {
    throw UnimplementedError('Bucket.create() is not implemented yet.');
  }

  // /// Create a channel to watch for changes on this bucket.
  // ///
  // /// TODO: Implement using `objects.watchAll` and the `Channel` helper.
  // Future<Channel> createChannel(String id, Map<String, Object?> config) {
  //   throw UnimplementedError('Bucket.createChannel() is not implemented yet.');
  // }

  // /// Create a notification configuration for this bucket.
  // ///
  // /// TODO: Implement using `notifications.insert` and `NotificationConfig`.
  // Future<NotificationConfig> createNotification(
  //   String topic, {
  //   NotificationMetadata? metadata,
  // }) {
  //   throw UnimplementedError(
  //     'Bucket.createNotification() is not implemented yet.',
  //   );
  // }

  /// Create a [File] handle within this bucket.
  File file(String name) {
    return File._(this, name);
  }

  @override
  Future<void> delete({PreconditionOptions? options}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<BucketMetadata> get() {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<BucketMetadata> setMetadata(BucketMetadata metadata) {
    // TODO: implement setMetadata
    throw UnimplementedError();
  }

  // @override
  // Future<BucketMetadata> get() async {
  //   final api = storage.storageApi;
  //   final bucket = await api.buckets.get(id);
  //   return BucketMetadata(bucket);
  // }

  // /// Check if this bucket exists.
  // ///
  // /// TODO: Implement using `buckets.get` and 404 handling.
  // Future<bool> exists() {
  //   throw UnimplementedError('Bucket.exists() is not implemented yet.');
  // }

  // @override
  // Future<void> delete({PreconditionOptions? options}) async {
  //   final api = storage.storageApi;
  //   final baseRetry = storage.retryOptions;
  //   final allowRetry = shouldRetryBucketMutation(options, null, baseRetry);
  //   final effectiveRetry = allowRetry
  //       ? baseRetry
  //       : baseRetry.copyWith(autoRetry: false, maxRetries: 0);

  //   final executor = RetryExecutor();

  //   await executor.retry<void>(
  //     () async {
  //       await api.buckets.delete(
  //         id,
  //         ifMetagenerationMatch: options?.ifMetagenerationMatch?.toString(),
  //         ifMetagenerationNotMatch:
  //             options?.ifMetagenerationNotMatch?.toString(),
  //       );
  //     },
  //     effectiveRetry,
  //     classify: defaultShouldRetryError,
  //   );
  // }

  // @override
  // Future<BucketMetadata> setMetadata(BucketMetadata metadata) async {
  //   final api = storage.storageApi;
  //   final baseRetry = storage.retryOptions;
  //   final preconditions = const PreconditionOptions(); // placeholder
  //   final allowRetry = shouldRetryBucketMutation(
  //     preconditions,
  //     null,
  //     baseRetry,
  //   );
  //   final effectiveRetry = allowRetry
  //       ? baseRetry
  //       : baseRetry.copyWith(autoRetry: false, maxRetries: 0);

  //   final executor = RetryExecutor();

  //   final updated = await executor.retry<storage_v1.Bucket>(
  //     () async => await api.buckets.patch(metadata.inner, id),
  //     effectiveRetry,
  //     classify: defaultShouldRetryError,
  //   );
  //   return BucketMetadata(updated);
  // }

  // /// Delete files in this bucket matching the given options.
  // ///
  // /// TODO: Implement using `getFiles` and `File.delete`.
  // Future<void> deleteFiles() {
  //   throw UnimplementedError('Bucket.deleteFiles() is not implemented yet.');
  // }

  // /// List files in this bucket.
  // ///
  // /// TODO: Implement using `objects.list` with paging and options.
  // Future<List<File>> getFiles() {
  //   throw UnimplementedError('Bucket.getFiles() is not implemented yet.');
  // }

  // /// Stream files in this bucket.
  // ///
  // /// TODO: Implement using `objects.list` and an async* stream, similar to
  // /// Node's `getFilesStream`.
  // Stream<File> getFilesStream() {
  //   throw UnimplementedError('Bucket.getFilesStream() is not implemented yet.');
  // }

  // /// Get the labels configured on this bucket.
  // ///
  // /// TODO: Implement via `getMetadata` and `labels` field.
  // Future<Map<String, String>> getLabels() {
  //   throw UnimplementedError('Bucket.getLabels() is not implemented yet.');
  // }

  // /// Get this bucket's metadata (alias for [get]).
  // ///
  // /// TODO: Decide whether to alias to [get] or expose additional options.
  // Future<BucketMetadata> getMetadata() {
  //   throw UnimplementedError('Bucket.getMetadata() is not implemented yet.');
  // }

  // /// Get all notification configurations for this bucket.
  // ///
  // /// TODO: Implement using `notifications.list` and `NotificationConfig`.
  // Future<List<NotificationConfig>> getNotifications() {
  //   throw UnimplementedError(
  //     'Bucket.getNotifications() is not implemented yet.',
  //   );
  // }

  // /// Get a signed URL for this bucket (e.g. for listing objects).
  // ///
  // /// TODO: Implement using `UrlSigner` and bucket-level signing config.
  // Future<String> getSignedUrl() {
  //   throw UnimplementedError('Bucket.getSignedUrl() is not implemented yet.');
  // }

  // /// Lock an existing retention policy on this bucket.
  // ///
  // /// TODO: Implement using `buckets.lockRetentionPolicy`.
  // Future<BucketMetadata> lock(String metageneration) {
  //   throw UnimplementedError('Bucket.lock() is not implemented yet.');
  // }

  // /// Make the bucket private (optionally including all files).
  // ///
  // /// TODO: Implement using ACL helpers and `File.makePrivate`.
  // Future<List<File>> makePrivate() {
  //   throw UnimplementedError('Bucket.makePrivate() is not implemented yet.');
  // }

  // /// Make the bucket public (optionally including all files).
  // ///
  // /// TODO: Implement using ACL helpers and `File.makePublic`.
  // Future<List<File>> makePublic() {
  //   throw UnimplementedError('Bucket.makePublic() is not implemented yet.');
  // }

  // /// Get a `NotificationConfig` handle for the given notification ID.
  // ///
  // /// TODO: Wire this to `NotificationConfig` factory.
  // NotificationConfig notification(String id) {
  //   throw UnimplementedError('Bucket.notification() is not implemented yet.');
  // }

  // /// Remove the retention period from this bucket.
  // ///
  // /// TODO: Implement using `buckets.patch` with `retentionPolicy` cleared.
  // Future<BucketMetadata> removeRetentionPeriod() {
  //   throw UnimplementedError(
  //     'Bucket.removeRetentionPeriod() is not implemented yet.',
  //   );
  // }

  // /// Restore a soft-deleted bucket (if applicable).
  // ///
  // /// TODO: Implement using `buckets.restore` if available.
  // Future<BucketMetadata> restore() {
  //   throw UnimplementedError('Bucket.restore() is not implemented yet.');
  // }

  // /// Set the retention period for this bucket.
  // ///
  // /// TODO: Implement using `buckets.patch` and `retentionPolicy.retentionPeriod`.
  // Future<BucketMetadata> setRetentionPeriod(Duration duration) {
  //   throw UnimplementedError(
  //     'Bucket.setRetentionPeriod() is not implemented yet.',
  //   );
  // }

  // /// Set the CORS configuration for this bucket.
  // ///
  // /// TODO: Implement using `setMetadata` and `cors` field.
  // Future<void> setCorsConfiguration() {
  //   throw UnimplementedError(
  //     'Bucket.setCorsConfiguration() is not implemented yet.',
  //   );
  // }

  // /// Set labels on this bucket.
  // ///
  // /// TODO: Implement as a convenience wrapper over `setMetadata`.
  // Future<BucketMetadata> setLabels(Map<String, String> labels) {
  //   throw UnimplementedError('Bucket.setLabels() is not implemented yet.');
  // }

  // /// Set the default storage class for this bucket.
  // ///
  // /// TODO: Implement using `setMetadata` and `storageClass` field.
  // Future<BucketMetadata> setStorageClass(String storageClass) {
  //   throw UnimplementedError(
  //     'Bucket.setStorageClass() is not implemented yet.',
  //   );
  // }

  // /// Set the user project to be billed for requests made via this bucket
  // /// handle (and derived file/notification handles).
  // ///
  // /// TODO: Store the user project on the bucket instance and ensure it is
  // /// threaded into all subsequent API calls (e.g. via request options).
  // void setUserProject(String userProject) {
  //   throw UnimplementedError('Bucket.setUserProject() is not implemented yet.');
  // }

  // /// Convenience upload method mirroring Node's `bucket.upload`.
  // Future<File> upload(
  //   String path, {
  //   PreconditionOptions? preconditionOptions,
  // }) async {
  //   final f = file(path.split('/').last);
  //   await f.saveFromPath(path, preconditionOptions: preconditionOptions);
  //   return f;
  // }
}

// extension on storage_v1.StorageApi {
//   storage_v1.Bucket bucketFromName(String name) =>
//       storage_v1.Bucket()..name = name;
// }
