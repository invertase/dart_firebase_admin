import 'package:dart_firebase_admin/src/messaging.dart';
import 'package:firebaseapis/fcm/v1.dart' as fmc1;
import 'package:firebaseapis/fcm/v1.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';

class ProjectsMessagesResourceMock extends Mock
    implements ProjectsMessagesResource {}

class FirebaseMessagingRequestHandlerMock extends Mock
    implements FirebaseMessagingRequestHandler {}

class FirebaseCloudMessagingApiMock extends Mock
    implements FirebaseCloudMessagingApi {}

class ProjectsResourceMock extends Mock implements ProjectsResource {}

class SendMessageRequestFake extends Fake implements SendMessageRequest {}

void main() {
  late Messaging messaging;

  final requestHandler = FirebaseMessagingRequestHandlerMock();
  final messages = ProjectsMessagesResourceMock();
  final projectResourceMock = ProjectsResourceMock();
  final messagingApiMock = FirebaseCloudMessagingApiMock();

  setUpAll(() {
    registerFallbackValue(SendMessageRequestFake());
  });

  void mockV1<T>() {
    when(() => requestHandler.v1<T>(any())).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments.first as Function;

      final result = await Function.apply(callback, [messagingApiMock]);
      return result as T;
    });
  }

  setUp(() {
    when(() => projectResourceMock.messages).thenReturn(messages);
    when(() => messagingApiMock.projects).thenReturn(projectResourceMock);

    final sdk = createApp();
    sdk.useEmulator();
    messaging = Messaging(sdk, requestHandler: requestHandler);
  });

  tearDown(() {
    reset(requestHandler);
    reset(messages);
    reset(projectResourceMock);
    reset(messagingApiMock);
  });

  group('Messaging.send', () {
    setUp(() => mockV1<String>());

    test('should send a message', () async {
      when(() => messages.send(any(), any())).thenAnswer(
        (_) => Future.value(fmc1.Message(name: 'test')),
      );

      final result = await messaging.send(
        TopicMessage(topic: 'test'),
      );

      expect(result, 'test');

      final capture = verify(() => messages.send(captureAny(), captureAny()))
        ..called(1);
      verifyNoMoreInteractions(messages);

      final request = capture.captured.first as SendMessageRequest;
      final parent = capture.captured.last as String;

      expect(request.message?.topic, 'test');
      expect(parent, 'projects/$projectId');
    });

    test('throws internal error if response has no name', () {
      when(() => messages.send(any(), any())).thenAnswer(
        (_) => Future.value(fmc1.Message()),
      );

      expect(
        () => messaging.send(TopicMessage(topic: 'test')),
        throwsA(
          isA<FirebaseMessagingAdminException>()
              .having((e) => e.message, 'message', 'No name in response'),
        ),
      );
    });

    test('dryRun', () async {
      when(() => messages.send(any(), any())).thenAnswer(
        (_) => Future.value(fmc1.Message(name: 'test')),
      );

      await messaging.send(
        TopicMessage(topic: 'test'),
        dryRun: true,
      );

      final capture = verify(() => messages.send(captureAny(), captureAny()))
        ..called(1);

      final request = capture.captured.first as SendMessageRequest;

      expect(request.validateOnly, true);
    });
  });

  group('sendEach', () {
    setUp(() => mockV1<BatchResponse>());

    test('asserts list length >=1 <500', () {
      expect(
        () => messaging.sendEach([]),
        throwsA(
          isA<FirebaseMessagingAdminException>().having(
            (e) => e.message,
            'message',
            'messages must be a non-empty array',
          ),
        ),
      );

      expect(
        () => messaging.sendEach(
          List.generate(501, (index) => TopicMessage(topic: '$index')),
        ),
        throwsA(
          isA<FirebaseMessagingAdminException>().having(
            (e) => e.message,
            'message',
            'messages list must not contain more than 500 items',
          ),
        ),
      );
    });

    test('works', () async {
      when(() => messages.send(any(), any())).thenAnswer(
        (i) {
          final request = i.positionalArguments.first as SendMessageRequest;
          switch (request.message?.topic) {
            case 'test':
              // Voluntary cause "test" to resolve after "test2"
              return Future(() => Future.value(fmc1.Message(name: 'test')));
            case _:
              return Future.error('error');
          }
        },
      );

      final result = await messaging.sendEach([
        TopicMessage(topic: 'test'),
        TopicMessage(topic: 'test2'),
      ]);

      expect(result.successCount, 1);
      expect(result.failureCount, 1);

      expect(result.responses, [
        isA<SendResponse>()
            .having((r) => r.success, 'success', true)
            .having((r) => r.messageId, 'messageId', 'test')
            .having((r) => r.error, 'error', null),
        isA<SendResponse>()
            .having((r) => r.success, 'success', false)
            .having((r) => r.messageId, 'messageId', null)
            .having(
              (r) => r.error,
              'error',
              isA<FirebaseMessagingAdminException>()
                  .having((e) => e.message, 'message', 'error'),
            ),
      ]);

      final capture = verify(() => messages.send(captureAny(), any()))
        ..called(2);
      verifyNoMoreInteractions(messages);

      var request = capture.captured.first as SendMessageRequest;

      expect(request.validateOnly, null);

      request = capture.captured[1] as SendMessageRequest;

      expect(request.validateOnly, null);
    });

    test('dry run', () async {
      when(() => messages.send(any(), any())).thenAnswer(
        (i) => Future.value(fmc1.Message(name: 'test')),
      );

      await messaging.sendEach([
        TopicMessage(topic: 'test'),
        TopicMessage(topic: 'test2'),
      ], dryRun: true);

      final capture = verify(() => messages.send(captureAny(), any()))
        ..called(2);
      verifyNoMoreInteractions(messages);

      var request = capture.captured.first as SendMessageRequest;

      expect(request.validateOnly, true);

      request = capture.captured[1] as SendMessageRequest;

      expect(request.validateOnly, true);
    });
  });
}
