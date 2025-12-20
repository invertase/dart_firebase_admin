import 'package:dart_firebase_admin/functions.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';

class MockAuthClient extends Mock implements auth.AuthClient {}

class FakeBaseRequest extends Fake implements BaseRequest {}

void main() {
  late MockAuthClient mockClient;
  late FunctionsRequestHandler handler;
  late FunctionsHttpClient httpClient;

  setUpAll(() {
    registerFallbackValue(FakeBaseRequest());
  });

  setUp(() {
    mockClient = MockAuthClient();

    final app = FirebaseApp.initializeApp(
      name: 'handler-test-${DateTime.now().microsecondsSinceEpoch}',
      options: AppOptions(projectId: projectId, httpClient: mockClient),
    );

    httpClient = FunctionsHttpClient(app);
    handler = FunctionsRequestHandler(app, httpClient: httpClient);

    addTearDown(() async {
      await app.close();
    });
  });

  group('FunctionsRequestHandler', () {
    group('enqueue validation', () {
      test('throws on empty function name', () {
        expect(
          () => handler.enqueue({}, '', null, null),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws on invalid function name format', () {
        expect(
          () => handler.enqueue(
            {},
            'project/abc/locations/east/fname',
            null,
            null,
          ),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on invalid function name with double slashes', () {
        expect(
          () => handler.enqueue({}, '//', null, null),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });
    });

    group('delete validation', () {
      test('throws on empty task ID', () {
        expect(
          () => handler.delete('', 'helloWorld', null),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws on empty function name', () {
        expect(
          () => handler.delete('task-id', '', null),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws on invalid task ID with special characters', () {
        expect(
          () => handler.delete('task!', 'helloWorld', null),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on invalid task ID with colons', () {
        expect(
          () => handler.delete('id:0', 'helloWorld', null),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on invalid task ID with brackets', () {
        expect(
          () => handler.delete('[1234]', 'helloWorld', null),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on invalid task ID with parentheses', () {
        expect(
          () => handler.delete('(1234)', 'helloWorld', null),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on invalid task ID with slashes', () {
        expect(
          () => handler.delete('invalid/task/id', 'helloWorld', null),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });
    });

    group('TaskOptions validation', () {
      test('throws on dispatch deadline too low', () {
        expect(
          () => TaskOptions(dispatchDeadlineSeconds: 10),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on dispatch deadline too high', () {
        expect(
          () => TaskOptions(dispatchDeadlineSeconds: 2000),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on invalid task ID format in options', () {
        expect(
          () => TaskOptions(id: 'task!invalid'),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('accepts valid dispatch deadline', () {
        expect(
          () => TaskOptions(dispatchDeadlineSeconds: 300),
          returnsNormally,
        );
      });

      test('accepts valid task ID', () {
        expect(() => TaskOptions(id: 'valid-task-id_123'), returnsNormally);
      });
    });
  });
}
