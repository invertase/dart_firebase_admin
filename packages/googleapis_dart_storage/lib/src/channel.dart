part of '../googleapis_dart_storage.dart';

// TODO: Where should this go?
abstract class WatchAllOptions {
  final String? delimiter;
  final int? maxResults;
  final String? pageToken;
  final String? prefix;
  final String? projection;
  final String? userProject;
  final bool? versions;

  const WatchAllOptions({
    this.delimiter,
    this.maxResults,
    this.pageToken,
    this.prefix,
    this.projection,
    this.userProject,
    this.versions,
  });
}

class CreateChannelConfig extends WatchAllOptions {
  final String address;

  const CreateChannelConfig({
    required this.address,
    super.delimiter,
    super.maxResults,
    super.pageToken,
    super.prefix,
    super.projection,
    super.userProject,
    super.versions,
  });
}

class CreateChannelOptions {
  final String? userProject;

  const CreateChannelOptions({
    this.userProject,
  });
}

typedef ChannelMetadata = storage_v1.Channel;

/// Create a channel object to interact with a Cloud Storage channel.
///
/// See {@link https://cloud.google.com/storage/docs/object-change-notification| Object Change Notification}
///
/// Example:
/// ```dart
/// final storage = Storage(options);
/// final channel = storage.channel('id', 'resource-id');
/// ```
class Channel extends ServiceObject<ChannelMetadata> {
  /// A reference to the [Storage] associated with this [Channel] instance.
  Storage get storage => service as Storage;

  Channel._(Storage storage, String id, String resourceId)
      : super(
          service: storage,
          // Don't include an ID in the API requests: https://github.com/googleapis/google-cloud-node/issues/1145
          id: '',
          metadata: ChannelMetadata()
            ..id = id
            ..resourceId = resourceId,
        );

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
}
