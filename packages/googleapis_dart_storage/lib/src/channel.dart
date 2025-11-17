part of '../googleapis_dart_storage.dart';

/// Create a channel object to interact with a Cloud Storage channel.
///
/// See {@link https://cloud.google.com/storage/docs/object-change-notification| Object Change Notification}
///
/// Example:
/// ```dart
/// final storage = Storage(options);
/// final channel = storage.channel('id', 'resource-id');
/// ```
class Channel extends ServiceObject<storage_v1.Channel> {
  /// A reference to the [Storage] associated with this [Channel] instance.
  Storage get storage => service as Storage;

  /// Cached metadata containing the channel id and resourceId.
  @override
  late storage_v1.Channel metadata;

  Channel._(Storage storage, String id, String resourceId)
      : super(service: storage, id: '') {
    // An ID shouldn't be included in the API requests.
    // RE: https://github.com/GoogleCloudPlatform/google-cloud-node/issues/1145
    metadata = storage_v1.Channel()
      ..id = id
      ..resourceId = resourceId;
  }

  /// Stop this channel.
  ///
  /// This sends a `channels.stop` request to GCS with the `id` and
  /// `resourceId` that were originally returned from the watch call.
  /// The operation is retried according to the [Storage] client's
  /// [RetryOptions].
  ///
  /// Example:
  /// ```dart
  /// final storage = Storage(options);
  /// final channel = storage.channel('id', 'resource-id');
  /// await channel.stop();
  /// ```
  Future<void> stop() async {
    final executor = RetryExecutor(storage);

    await executor.retry<void>(
      (client) async {
        try {
          await client.channels.stop(metadata);
        } catch (e) {
          throw ApiError('Failed to stop channel ${metadata.id}', details: e);
        }
      },
    );
  }

  // Note: Channel does not use GettableMixin, SettableMixin, or DeletableMixin
  // because it doesn't support get(), setMetadata(), or delete() operations.
  // The base ServiceObject will throw UnimplementedError for these methods.
}
