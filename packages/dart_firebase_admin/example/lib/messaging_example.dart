// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/messaging.dart';

Future<void> messagingExample(FirebaseApp admin) async {
  print('\n### Messaging Example ###\n');

  final messaging = admin.messaging();

  // Example 1: Send a message to a topic
  try {
    print('> Sending message to topic: fcm_test_topic\n');
    final messageId = await messaging.send(
      TopicMessage(
        topic: 'fcm_test_topic',
        notification: Notification(
          title: 'Hello World',
          body: 'Dart Firebase Admin SDK works!',
        ),
        data: {'timestamp': DateTime.now().toIso8601String()},
      ),
    );
    print('Message sent successfully!');
    print('  - Message ID: $messageId');
    print('');
  } on FirebaseMessagingAdminException catch (e) {
    print('> Messaging error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error sending message: $e');
  }

  // Example 2: Send multiple messages
  try {
    print('> Sending multiple messages...\n');
    final response = await messaging.sendEach([
      TopicMessage(
        topic: 'topic1',
        notification: Notification(title: 'Message 1'),
      ),
      TopicMessage(
        topic: 'topic2',
        notification: Notification(title: 'Message 2'),
      ),
    ]);

    print('Batch send completed!');
    print('  - Success: ${response.successCount}');
    print('  - Failures: ${response.failureCount}');
    for (var i = 0; i < response.responses.length; i++) {
      final resp = response.responses[i];
      if (resp.success) {
        print('  - Message $i: ${resp.messageId}');
      } else {
        print('  - Message $i failed: ${resp.error?.message}');
      }
    }
    print('');
  } on FirebaseMessagingAdminException catch (e) {
    print('> Messaging error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error sending batch: $e');
  }

  // Example 3: Send multicast message to multiple tokens
  try {
    print('> Sending multicast message...\n');
    // Note: Using fake tokens for demonstration
    final response = await messaging.sendEachForMulticast(
      MulticastMessage(
        tokens: ['fake-token-1', 'fake-token-2'],
        notification: Notification(
          title: 'Multicast Message',
          body: 'This goes to multiple devices',
        ),
      ),
      dryRun: true, // Use dry run to validate without actually sending
    );

    print('Multicast send completed!');
    print('  - Success: ${response.successCount}');
    print('  - Failures: ${response.failureCount}');
    print('');
  } on FirebaseMessagingAdminException catch (e) {
    print('> Messaging error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error sending multicast: $e');
  }

  // Example 4: Subscribe tokens to a topic
  try {
    print('> Subscribing tokens to topic: test-topic\n');
    // Note: Using fake token for demonstration
    final response = await messaging.subscribeToTopic([
      'fake-registration-token',
    ], 'test-topic');

    print('Subscription completed!');
    print('  - Success: ${response.successCount}');
    print('  - Failures: ${response.failureCount}');
    if (response.errors.isNotEmpty) {
      for (final error in response.errors) {
        print('  - Token ${error.index} error: ${error.error.message}');
      }
    }
    print('');
  } on FirebaseMessagingAdminException catch (e) {
    if (e.errorCode == MessagingClientErrorCode.invalidArgument) {
      print('> Invalid topic format or empty tokens list');
    } else {
      print('> Messaging error: ${e.code} - ${e.message}');
    }
  } catch (e) {
    print('> Error subscribing to topic: $e');
  }

  // Example 5: Send with platform-specific options
  try {
    print('> Sending message with platform-specific options...\n');
    final messageId = await messaging.send(
      TokenMessage(
        token: 'fake-device-token',
        notification: Notification(
          title: 'Platform-specific message',
          body: 'With Android and iOS options',
        ),
        android: AndroidConfig(
          priority: AndroidConfigPriority.high,
          notification: AndroidNotification(color: '#FF0000', sound: 'default'),
        ),
        apns: ApnsConfig(
          payload: ApnsPayload(
            aps: Aps(
              contentAvailable: true,
              sound: CriticalSound(critical: true, name: 'default'),
            ),
          ),
        ),
      ),
      dryRun: true, // Use dry run to validate
    );

    print('Platform-specific message validated!');
    print('  - Message ID: $messageId');
  } on FirebaseMessagingAdminException catch (e) {
    if (e.errorCode == MessagingClientErrorCode.invalidRegistrationToken) {
      print('> Invalid registration token format');
    } else {
      print('> Messaging error: ${e.code} - ${e.message}');
    }
  } catch (e) {
    print('> Error sending platform-specific message: $e');
  }
}
