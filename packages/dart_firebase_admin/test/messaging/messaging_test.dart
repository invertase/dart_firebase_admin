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

  setUp(() {
    when(() => projectResourceMock.messages).thenReturn(messages);
    when(() => messagingApiMock.projects).thenReturn(projectResourceMock);
    when(() => requestHandler.v1<String>(any())).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments.first as Function;

      final result = await Function.apply(callback, [messagingApiMock]);
      return result as String;
    });

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
  });
}
