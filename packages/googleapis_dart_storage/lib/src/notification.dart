part of '../googleapis_dart_storage.dart';

class GetNotificationsOptions {
  final String? userProject;

  const GetNotificationsOptions({
    this.userProject,
  });
}

typedef NotificationMetadata = storage_v1.Notification;

class Notification extends ServiceObject<NotificationMetadata>
    with
        GettableMixin<NotificationMetadata, Notification>,
        DeletableMixin<NotificationMetadata>,
        CreatableMixin<NotificationMetadata, Notification> {
  final Bucket bucket;

  Notification._(this.bucket, String id)
      : super(
          service: bucket.storage,
          id: id,
          metadata: NotificationMetadata()..id = id,
        );

  @override
  Future<Notification> create(NotificationMetadata metadata) {
    // Extract topic from metadata - it's required for createNotification
    var topic = metadata.topic;
    if (topic == null || topic.isEmpty) {
      throw ArgumentError('Topic is required to create a notification.');
    }

    // Strip universe domain prefix if present (e.g., "//pubsub.googleapis.com/projects/...")
    // This allows metadata from getMetadata() to be reused for create()
    if (topic.startsWith('//pubsub.')) {
      // Find the position after "//pubsub.{domain}/"
      final domainEndIndex = topic.indexOf('/', 9); // Skip "//pubsub."
      if (domainEndIndex != -1 && domainEndIndex < topic.length - 1) {
        // Extract everything after "//pubsub.{domain}/"
        topic = topic.substring(domainEndIndex + 1);
      }
    }

    // Extract options from metadata
    final options = CreateNotificationOptions(
      customAttributes: metadata.customAttributes,
      eventTypes: metadata.eventTypes,
      objectNamePrefix: metadata.objectNamePrefix,
      payloadFormat: metadata.payloadFormat,
    );

    // Delegate to bucket.createNotification, matching JS behavior
    return bucket.createNotification(topic, options: options);
  }

  @override
  Future<void> delete({DeleteOptions? options}) {
    final executor = RetryExecutor(bucket.storage);
    return executor.retry<void>((client) async {
      try {
        await client.notifications.delete(
          bucket.id,
          id,
        );
      } on ApiError catch (e) {
        if (e.code == 404 && options?.ignoreNotFound == true) {
          return;
        }
        rethrow;
      }
    });
  }

  @override
  Future<NotificationMetadata> getMetadata({String? userProject}) async {
    final executor = RetryExecutor(bucket.storage);
    return executor.retry<NotificationMetadata>((client) async {
      final metadata = await client.notifications.get(
        bucket.id,
        id,
        userProject: userProject,
      );

      setInstanceMetadata(metadata);
      return metadata;
    });
  }
}
