// Firebase Messaging Integration Tests
//
// SAFETY: FCM has no emulator support, so these tests hit the real API.
// However, we use fake tokens that won't actually deliver messages.
//
// The tests verify that the SDK correctly communicates with the FCM API
// and handles responses, but the tokens themselves are not valid.
//
// To run these tests:
//   dart test test/messaging/messaging_integration_test.dart

import 'package:dart_firebase_admin/src/messaging/messaging.dart';
import 'package:test/test.dart';

import '../helpers.dart';

// Properly formatted but fake FCM registration token (same approach as Node.js SDK)
// This token has the correct format but won't actually deliver messages.
// The tests verify API communication, not actual message delivery.
const registrationToken =
    'fGw0qy4TGgk:APA91bGtWGjuhp4WRhHXgbabIYp1jxEKI08ofj_v1bKhWAGJQ4e3arRCW'
    'zeTfHaLz83mBnDh0aPWB1AykXAVUUGl2h1wT4XI6XazWpvY7RBUSYfoxtqSWGIm2nvWh2BOP1YG501SsRoE';

const testTopic = 'mock-topic';
const invalidTopic = r'topic-$%#^';

void main() {
  late Messaging messaging;

  setUp(() {
    final app = createApp(
      name: 'messaging-integration-${DateTime.now().microsecondsSinceEpoch}',
    );
    messaging = Messaging.internal(app);
  });

  group(
    'Send Message Integration',
    () {
      test('send(message, dryRun) returns a message ID', () async {
        final messageId = await messaging.send(
          TopicMessage(
            topic: 'foo-bar',
            notification: Notification(
              title: 'Integration Test',
              body: 'Testing send() method',
            ),
          ),
          dryRun: true,
        );

        // Should return a message ID matching the pattern
        expect(messageId, matches(RegExp(r'^projects/.*/messages/.*$')));
      });

      test('sendEach()', () async {
        final messages = [
          TopicMessage(
            topic: 'foo-bar',
            notification: Notification(title: 'Test 1'),
          ),
          TopicMessage(
            topic: 'foo-bar',
            notification: Notification(title: 'Test 2'),
          ),
          TopicMessage(
            topic: 'foo-bar',
            notification: Notification(title: 'Test 3'),
          ),
        ];

        final response = await messaging.sendEach(messages, dryRun: true);

        expect(response.responses.length, equals(messages.length));
        expect(response.successCount, equals(messages.length));
        expect(response.failureCount, equals(0));

        for (final resp in response.responses) {
          expect(resp.success, isTrue);
          expect(resp.messageId, matches(RegExp(r'^projects/.*/messages/.*$')));
        }
      });

      test('sendEach() validates empty messages list', () async {
        await expectLater(
          () => messaging.sendEach([]),
          throwsA(
            isA<FirebaseMessagingAdminException>().having(
              (e) => e.message,
              'message',
              contains('non-empty'),
            ),
          ),
        );
      });

      test(
        'sendEachForMulticast() with invalid token returns invalid argument error',
        () async {
          // Use invalid tokens to test error handling (like Node.js SDK)
          final multicastMessage = MulticastMessage(
            tokens: ['not-a-token', 'also-not-a-token'],
            notification: Notification(title: 'Multicast Test'),
          );

          final response = await messaging.sendEachForMulticast(
            multicastMessage,
            dryRun: true,
          );

          expect(response.responses.length, equals(2));
          expect(response.successCount, equals(0));
          expect(response.failureCount, equals(2));

          for (final resp in response.responses) {
            expect(resp.success, isFalse);
            expect(resp.messageId, isNull);
            expect(
              resp.error,
              isA<FirebaseMessagingAdminException>().having(
                (e) => e.errorCode,
                'errorCode',
                MessagingClientErrorCode.invalidArgument,
              ),
            );
          }
        },
      );

      test('sendEachForMulticast() validates empty tokens list', () async {
        await expectLater(
          () => messaging.sendEachForMulticast(MulticastMessage(tokens: [])),
          throwsA(
            isA<FirebaseMessagingAdminException>().having(
              (e) => e.message,
              'message',
              contains('non-empty'),
            ),
          ),
        );
      });
    },
    skip: hasGoogleEnv
        ? false
        : 'Requires Application Default Credentials (gcloud auth application-default login)',
  );

  group(
    'Topic Management Integration',
    () {
      test(
        'subscribeToTopic() returns a response with correct structure',
        () async {
          final response = await messaging.subscribeToTopic([
            registrationToken,
          ], testTopic);

          // Verify response structure (token might be invalid, so we just check types)
          expect(response.successCount, isA<int>());
          expect(response.failureCount, isA<int>());
          expect(response.errors, isA<List<Object?>>());

          // Total should equal number of tokens
          expect(response.successCount + response.failureCount, equals(1));
        },
      );

      test(
        'unsubscribeFromTopic() returns a response with correct structure',
        () async {
          final response = await messaging.unsubscribeFromTopic([
            registrationToken,
          ], testTopic);

          // Verify response structure
          expect(response.successCount, isA<int>());
          expect(response.failureCount, isA<int>());
          expect(response.errors, isA<List<Object?>>());

          // Total should equal number of tokens
          expect(response.successCount + response.failureCount, equals(1));
        },
      );

      test(
        'subscribeToTopic() with multiple tokens returns correct count',
        () async {
          final response = await messaging.subscribeToTopic([
            registrationToken,
            registrationToken,
          ], testTopic);

          // Should return 2 results (even if both fail due to invalid tokens)
          expect(response.successCount + response.failureCount, equals(2));
        },
      );

      test('subscribeToTopic() fails with invalid topic format', () async {
        await expectLater(
          () => messaging.subscribeToTopic([registrationToken], invalidTopic),
          throwsA(
            isA<FirebaseMessagingAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              MessagingClientErrorCode.invalidArgument,
            ),
          ),
        );
      });

      test('unsubscribeFromTopic() fails with invalid topic format', () async {
        await expectLater(
          () =>
              messaging.unsubscribeFromTopic([registrationToken], invalidTopic),
          throwsA(
            isA<FirebaseMessagingAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              MessagingClientErrorCode.invalidArgument,
            ),
          ),
        );
      });

      test('subscribeToTopic() handles topic normalization', () async {
        // Both should work (with and without /topics/ prefix)
        final response1 = await messaging.subscribeToTopic([
          registrationToken,
        ], 'test-normalization');
        expect(response1.successCount + response1.failureCount, equals(1));

        final response2 = await messaging.subscribeToTopic([
          registrationToken,
        ], '/topics/test-normalization');
        expect(response2.successCount + response2.failureCount, equals(1));
      });

      test('subscribeToTopic() with array validates properly', () async {
        // Empty array should fail
        await expectLater(
          () => messaging.subscribeToTopic([], testTopic),
          throwsA(
            isA<FirebaseMessagingAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              MessagingClientErrorCode.invalidArgument,
            ),
          ),
        );
      });

      test('unsubscribeFromTopic() with array validates properly', () async {
        // Empty array should fail
        await expectLater(
          () => messaging.unsubscribeFromTopic([], testTopic),
          throwsA(
            isA<FirebaseMessagingAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              MessagingClientErrorCode.invalidArgument,
            ),
          ),
        );
      });
    },
    skip: hasGoogleEnv
        ? false
        : 'Requires Application Default Credentials (gcloud auth application-default login)',
  );
}
