import 'dart:convert';

import 'package:dart_firebase_admin/src/messaging.dart';
import 'package:firebaseapis/fcm/v1.dart' as fmc1;
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';
import '../mock.dart';

class ProjectsMessagesResourceMock extends Mock
    implements fmc1.ProjectsMessagesResource {}

class FirebaseMessagingRequestHandlerMock extends Mock
    implements FirebaseMessagingRequestHandler {}

class FirebaseCloudMessagingApiMock extends Mock
    implements fmc1.FirebaseCloudMessagingApi {}

class ProjectsResourceMock extends Mock implements fmc1.ProjectsResource {}

extension on Object? {
  T cast<T>() => this as T;
}

void main() {
  late Messaging messaging;

  final requestHandler = FirebaseMessagingRequestHandlerMock();
  final messages = ProjectsMessagesResourceMock();
  final projectResourceMock = ProjectsResourceMock();
  final messagingApiMock = FirebaseCloudMessagingApiMock();

  setUpAll(registerFallbacks);

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

  group('Error handling', () {
    for (final (:code, :error) in [
      (code: 400, error: MessagingClientErrorCode.invalidArgument),
      (code: 401, error: MessagingClientErrorCode.authenticationError),
      (code: 403, error: MessagingClientErrorCode.authenticationError),
      (code: 500, error: MessagingClientErrorCode.internalError),
      (code: 503, error: MessagingClientErrorCode.serverUnavailable),
      (code: 505, error: MessagingClientErrorCode.unknownError),
    ]) {
      test('converts $code codes into errors', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(Stream.value(utf8.encode('')), code),
          ),
        );

        final app = createApp(client: clientMock);
        final handler = Messaging(app);

        await expectLater(
          () => handler.send(TokenMessage(token: '123')),
          throwsA(
            isA<FirebaseMessagingAdminException>()
                .having((e) => e.errorCode, 'errorCode', error),
          ),
        );
      });
    }

    for (final MapEntry(key: messagingError, value: code)
        in messagingServerToClientCode.entries) {
      test('converts $messagingError error codes', () async {
        final clientMock = ClientMock();
        when(() => clientMock.send(any())).thenAnswer(
          (_) => Future.value(
            StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({
                    'error': {'message': messagingError},
                  }),
                ),
              ),
              400,
              headers: {
                'content-type': 'application/json',
              },
            ),
          ),
        );

        final app = createApp(client: clientMock);
        final handler = Messaging(app);

        await expectLater(
          () => handler.send(TokenMessage(token: '123')),
          throwsA(
            isA<FirebaseMessagingAdminException>()
                .having((e) => e.errorCode, 'errorCode', code)
                .having((e) => e.code, 'code', 'messaging/${code.code}'),
          ),
        );
      });
    }
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

      final request = capture.captured.first as fmc1.SendMessageRequest;
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
              .having(
                (e) => e.errorCode,
                'errorCode',
                MessagingClientErrorCode.internalError,
              )
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

      final request = capture.captured.first as fmc1.SendMessageRequest;

      expect(request.validateOnly, true);
    });

    test('supports booleans', () async {
      when(() => messages.send(any(), any())).thenAnswer(
        (_) => Future.value(fmc1.Message(name: 'test')),
      );

      await messaging.send(
        TopicMessage(
          topic: 'test',
          apns: ApnsConfig(
            payload: ApnsPayload(
              aps: Aps(
                contentAvailable: true,
                mutableContent: true,
                sound: CriticalSound(critical: true, name: 'default'),
              ),
            ),
          ),
          webpush: WebpushConfig(
            notification: WebpushNotification(renotify: true),
          ),
        ),
      );

      final capture = verify(() => messages.send(captureAny(), captureAny()))
        ..called(1);
      final request = capture.captured.first as fmc1.SendMessageRequest;

      expect(
        request.message!.apns!.payload!['aps']!
            .cast<Map<Object?, Object?>>()['content-available'],
        1,
      );
      expect(
        request.message!.apns!.payload!['aps']!
            .cast<Map<Object?, Object?>>()['mutable-content'],
        1,
      );
      expect(
        request.message!.apns!.payload!['aps']!
            .cast<Map<Object?, Object?>>()['sound']
            .cast<Map<Object?, Object?>>()['critical'],
        1,
      );

      expect(
        request.message!.webpush!.notification!['renotify'],
        1,
      );
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
          final request =
              i.positionalArguments.first as fmc1.SendMessageRequest;
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

      var request = capture.captured.first as fmc1.SendMessageRequest;

      expect(request.validateOnly, null);

      request = capture.captured[1] as fmc1.SendMessageRequest;

      expect(request.validateOnly, null);
    });

    test('dry run', () async {
      when(() => messages.send(any(), any())).thenAnswer(
        (i) => Future.value(fmc1.Message(name: 'test')),
      );

      await messaging.sendEach(dryRun: true, [
        TopicMessage(topic: 'test'),
        TopicMessage(topic: 'test2'),
      ]);

      final capture = verify(() => messages.send(captureAny(), any()))
        ..called(2);
      verifyNoMoreInteractions(messages);

      var request = capture.captured.first as fmc1.SendMessageRequest;

      expect(request.validateOnly, true);

      request = capture.captured[1] as fmc1.SendMessageRequest;

      expect(request.validateOnly, true);
    });
  });
}
