import 'dart:async';
import 'dart:convert';

import 'package:dart_firebase_admin/functions.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import '../mock_service_account.dart';
import 'util/helpers.dart';

// =============================================================================
// Mocks and Test Utilities
// =============================================================================

class MockRequestHandler extends Mock implements FunctionsRequestHandler {}

class MockAuthClient extends Mock implements auth.AuthClient {}

class FakeBaseRequest extends Fake implements BaseRequest {}

/// Creates a mock HTTP client that handles OAuth token requests and
/// optionally Cloud Tasks API requests.
MockClient createMockHttpClient({
  String? idToken,
  Response Function(Request)? apiHandler,
}) {
  return MockClient((request) async {
    // Handle OAuth token endpoint (JWT flow)
    if (request.url.toString().contains('oauth2') ||
        request.url.toString().contains('token')) {
      return Response(
        jsonEncode({
          'access_token': 'mock-access-token',
          'expires_in': 3600,
          'token_type': 'Bearer',
          if (idToken != null) 'id_token': idToken,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    // Handle Cloud Tasks API requests
    if (request.url.toString().contains('cloudtasks')) {
      if (apiHandler != null) {
        return apiHandler(request);
      }
      // Default: successful task creation
      return Response(
        jsonEncode({
          'name': 'projects/test/locations/us-central1/queues/q/tasks/123',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    // Default response
    return Response('{}', 200);
  });
}

/// Creates an AuthClient with service account credentials for testing.
///
/// This creates a real AuthClient properly associated with a GoogleCredential,
/// so extension methods like `credential` and `getServiceAccountEmail()` work.
Future<auth.AuthClient> createTestAuthClient({
  required String email,
  String? idToken,
  Response Function(Request)? apiHandler,
}) async {
  final baseClient = createMockHttpClient(
    idToken: idToken,
    apiHandler: apiHandler,
  );

  // Create real credential from service account parameters
  final credential = GoogleCredential.fromServiceAccountParams(
    privateKey: mockPrivateKey,
    email: email,
    clientId: 'test-client-id',
    projectId: projectId,
  );

  // Create real auth client (properly associated with credential via Expando)
  return createAuthClient(credential, [
    'https://www.googleapis.com/auth/cloud-platform',
  ], baseClient: baseClient);
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBaseRequest());
  });

  // ===========================================================================
  // Functions and TaskQueue Tests (with mocked handler)
  // ===========================================================================
  group('Functions', () {
    late MockRequestHandler mockHandler;
    late Functions functions;

    setUp(() {
      mockHandler = MockRequestHandler();
      functions = createFunctionsWithMockHandler(mockHandler);
    });

    group('taskQueue', () {
      test('creates TaskQueue with function name', () {
        final queue = functions.taskQueue('helloWorld');
        expect(queue, isNotNull);
      });

      test('creates TaskQueue with full resource name', () {
        final queue = functions.taskQueue(
          'projects/my-project/locations/us-central1/functions/helloWorld',
        );
        expect(queue, isNotNull);
      });

      test('creates TaskQueue with partial resource name', () {
        final queue = functions.taskQueue(
          'locations/us-east1/functions/helloWorld',
        );
        expect(queue, isNotNull);
      });

      test('creates TaskQueue with extension ID', () {
        final queue = functions.taskQueue(
          'helloWorld',
          extensionId: 'my-extension',
        );
        expect(queue, isNotNull);
      });

      test('throws on empty function name', () {
        expect(() => functions.taskQueue(''), throwsA(isA<ArgumentError>()));
      });
    });

    group('TaskQueue.enqueue', () {
      test('enqueues task with data', () async {
        when(
          () => mockHandler.enqueue(any(), any(), any(), any()),
        ).thenAnswer((_) async {});

        final queue = functions.taskQueue('helloWorld');
        await queue.enqueue({'message': 'Hello, World!'});

        verify(
          () => mockHandler.enqueue(
            {'message': 'Hello, World!'},
            'helloWorld',
            null,
            null,
          ),
        ).called(1);
      });

      test('enqueues task with schedule delay', () async {
        when(
          () => mockHandler.enqueue(any(), any(), any(), any()),
        ).thenAnswer((_) async {});

        final queue = functions.taskQueue('helloWorld');
        final options = TaskOptions(schedule: DelayDelivery(60));

        await queue.enqueue({'message': 'Delayed task'}, options);

        verify(
          () => mockHandler.enqueue(
            {'message': 'Delayed task'},
            'helloWorld',
            null,
            options,
          ),
        ).called(1);
      });

      test('enqueues task with absolute schedule time', () async {
        when(
          () => mockHandler.enqueue(any(), any(), any(), any()),
        ).thenAnswer((_) async {});

        final queue = functions.taskQueue('helloWorld');
        final scheduleTime = DateTime.now().add(const Duration(hours: 1));
        final options = TaskOptions(schedule: AbsoluteDelivery(scheduleTime));

        await queue.enqueue({'message': 'Scheduled task'}, options);

        verify(
          () => mockHandler.enqueue(
            {'message': 'Scheduled task'},
            'helloWorld',
            null,
            options,
          ),
        ).called(1);
      });

      test('enqueues task with custom ID', () async {
        when(
          () => mockHandler.enqueue(any(), any(), any(), any()),
        ).thenAnswer((_) async {});

        final queue = functions.taskQueue('helloWorld');
        final options = TaskOptions(id: 'my-custom-id');

        await queue.enqueue({'message': 'Task with ID'}, options);

        verify(
          () => mockHandler.enqueue(
            {'message': 'Task with ID'},
            'helloWorld',
            null,
            options,
          ),
        ).called(1);
      });

      test('enqueues task with extension ID', () async {
        when(
          () => mockHandler.enqueue(any(), any(), any(), any()),
        ).thenAnswer((_) async {});

        final queue = functions.taskQueue(
          'helloWorld',
          extensionId: 'my-extension',
        );
        await queue.enqueue({'data': 'test'});

        verify(
          () => mockHandler.enqueue(
            {'data': 'test'},
            'helloWorld',
            'my-extension',
            null,
          ),
        ).called(1);
      });

      test('throws on duplicate task ID (409 conflict)', () async {
        when(() => mockHandler.enqueue(any(), any(), any(), any())).thenThrow(
          FirebaseFunctionsAdminException(
            FunctionsClientErrorCode.taskAlreadyExists,
            'Task already exists',
          ),
        );

        final queue = functions.taskQueue('helloWorld');

        expect(
          () =>
              queue.enqueue({'data': 'test'}, TaskOptions(id: 'duplicate-id')),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });
    });

    group('TaskQueue.delete', () {
      test('deletes task by ID', () async {
        when(
          () => mockHandler.delete(any(), any(), any()),
        ).thenAnswer((_) async {});

        final queue = functions.taskQueue('helloWorld');
        await queue.delete('task-to-delete');

        verify(
          () => mockHandler.delete('task-to-delete', 'helloWorld', null),
        ).called(1);
      });

      test('deletes task with extension ID', () async {
        when(
          () => mockHandler.delete(any(), any(), any()),
        ).thenAnswer((_) async {});

        final queue = functions.taskQueue(
          'helloWorld',
          extensionId: 'my-extension',
        );
        await queue.delete('task-id');

        verify(
          () => mockHandler.delete('task-id', 'helloWorld', 'my-extension'),
        ).called(1);
      });

      test('succeeds silently when task not found (404)', () async {
        when(
          () => mockHandler.delete(any(), any(), any()),
        ).thenAnswer((_) async {});

        final queue = functions.taskQueue('helloWorld');
        await queue.delete('non-existent-task');

        verify(
          () => mockHandler.delete('non-existent-task', 'helloWorld', null),
        ).called(1);
      });

      test('throws on empty task ID', () async {
        when(
          () => mockHandler.delete(any(), any(), any()),
        ).thenThrow(ArgumentError('id must be a non-empty string'));

        final queue = functions.taskQueue('helloWorld');

        expect(() => queue.delete(''), throwsA(isA<ArgumentError>()));
      });

      test('throws on invalid task ID format', () async {
        when(() => mockHandler.delete(any(), any(), any())).thenThrow(
          FirebaseFunctionsAdminException(
            FunctionsClientErrorCode.invalidArgument,
            'Invalid task ID format',
          ),
        );

        final queue = functions.taskQueue('helloWorld');

        expect(
          () => queue.delete('invalid/task/id'),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });
    });
  });

  // ===========================================================================
  // FunctionsRequestHandler Validation Tests
  // ===========================================================================
  group('FunctionsRequestHandler', () {
    late MockAuthClient mockClient;
    late FunctionsRequestHandler handler;
    late FunctionsHttpClient httpClient;

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

      test('throws on function name with trailing slash', () {
        expect(
          () => handler.enqueue({}, 'location/west/', null, null),
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
  });

  // ===========================================================================
  // TaskOptions Validation Tests
  // ===========================================================================
  group('TaskOptions validation', () {
    group('dispatchDeadlineSeconds', () {
      test('throws on dispatch deadline too low (14)', () {
        expect(
          () => TaskOptions(dispatchDeadlineSeconds: 14),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on dispatch deadline too high (1801)', () {
        expect(
          () => TaskOptions(dispatchDeadlineSeconds: 1801),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on dispatch deadline exactly at boundary (10)', () {
        expect(
          () => TaskOptions(dispatchDeadlineSeconds: 10),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on dispatch deadline exactly at boundary (2000)', () {
        expect(
          () => TaskOptions(dispatchDeadlineSeconds: 2000),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on negative dispatch deadline', () {
        expect(
          () => TaskOptions(dispatchDeadlineSeconds: -1),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('accepts dispatch deadline at minimum (15)', () {
        expect(() => TaskOptions(dispatchDeadlineSeconds: 15), returnsNormally);
      });

      test('accepts dispatch deadline at maximum (1800)', () {
        expect(
          () => TaskOptions(dispatchDeadlineSeconds: 1800),
          returnsNormally,
        );
      });

      test('accepts valid dispatch deadline (300)', () {
        expect(
          () => TaskOptions(dispatchDeadlineSeconds: 300),
          returnsNormally,
        );
      });
    });

    group('id', () {
      test('throws on invalid task ID format', () {
        expect(
          () => TaskOptions(id: 'task!invalid'),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on empty task ID', () {
        expect(
          () => TaskOptions(id: ''),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on task ID with colons', () {
        expect(
          () => TaskOptions(id: 'id:0'),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on task ID with brackets', () {
        expect(
          () => TaskOptions(id: '[1234]'),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on task ID with parentheses', () {
        expect(
          () => TaskOptions(id: '(1234)'),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('throws on task ID exceeding 500 characters', () {
        final longId = 'a' * 501;
        expect(
          () => TaskOptions(id: longId),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test(
        'accepts valid task ID with letters, numbers, hyphens, underscores',
        () {
          expect(() => TaskOptions(id: 'valid-task-id_123'), returnsNormally);
        },
      );

      test('accepts task ID at maximum length (500)', () {
        final maxId = 'a' * 500;
        expect(() => TaskOptions(id: maxId), returnsNormally);
      });
    });

    group('scheduleDelaySeconds', () {
      test('throws on negative scheduleDelaySeconds', () {
        expect(
          () => TaskOptions(schedule: DelayDelivery(-1)),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      });

      test('accepts scheduleDelaySeconds of 0', () {
        expect(() => TaskOptions(schedule: DelayDelivery(0)), returnsNormally);
      });

      test('accepts positive scheduleDelaySeconds', () {
        expect(
          () => TaskOptions(schedule: DelayDelivery(3600)),
          returnsNormally,
        );
      });
    });
  });

  // ===========================================================================
  // Task Authentication Tests (_updateTaskAuth)
  // ===========================================================================
  group('Task Authentication', () {
    group('emulator mode', () {
      test('uses emulated service account when emulator is enabled', () async {
        Map<String, dynamic>? capturedTaskBody;

        // Create an auth client that captures requests
        final authClient = await createTestAuthClient(
          email: mockClientEmail,
          apiHandler: (request) {
            capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
            return Response(
              jsonEncode({'name': 'task/123'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          },
        );

        await runZoned(
          () async {
            final app = FirebaseApp.initializeApp(
              name: 'emulator-test-${DateTime.now().microsecondsSinceEpoch}',
              options: AppOptions(projectId: projectId, httpClient: authClient),
            );

            try {
              final functions = Functions.internal(app);
              final queue = functions.taskQueue('helloWorld');
              await queue.enqueue({'data': 'test'});

              expect(capturedTaskBody, isNotNull);
              final task = capturedTaskBody!['task'] as Map<String, dynamic>;
              final httpRequest = task['httpRequest'] as Map<String, dynamic>;
              final oidcToken =
                  httpRequest['oidcToken'] as Map<String, dynamic>?;

              expect(oidcToken, isNotNull);
              // When emulator is enabled, uses the default emulated service account
              expect(
                oidcToken!['serviceAccountEmail'],
                equals('emulated-service-acct@email.com'),
              );
            } finally {
              await app.close();
            }
          },
          zoneValues: {
            envSymbol: {'CLOUD_TASKS_EMULATOR_HOST': 'localhost:9499'},
          },
        );
      });
    });

    group('production mode with service account credentials', () {
      test('uses service account email from credential for OIDC token', () async {
        Map<String, dynamic>? capturedTaskBody;

        final authClient = await createTestAuthClient(
          email: mockClientEmail,
          apiHandler: (request) {
            capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
            return Response(
              jsonEncode({'name': 'task/123'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          },
        );

        // Use runZoned to disable emulator env var (set by firebase emulators:exec)
        await runZoned(() async {
          final app = FirebaseApp.initializeApp(
            name: 'sa-test-${DateTime.now().microsecondsSinceEpoch}',
            options: AppOptions(projectId: projectId, httpClient: authClient),
          );

          try {
            final functions = Functions.internal(app);
            final queue = functions.taskQueue('helloWorld');
            await queue.enqueue({'data': 'test'});

            expect(capturedTaskBody, isNotNull);
            final task = capturedTaskBody!['task'] as Map<String, dynamic>;
            final httpRequest = task['httpRequest'] as Map<String, dynamic>;
            final oidcToken = httpRequest['oidcToken'] as Map<String, dynamic>?;

            expect(oidcToken, isNotNull);
            expect(oidcToken!['serviceAccountEmail'], equals(mockClientEmail));

            // Should NOT have Authorization header (that's for extensions)
            expect(
              (httpRequest['headers']
                  as Map<String, dynamic>?)?['Authorization'],
              isNull,
            );
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: <String, String>{}});
      });

      test('sets correct function URL in task', () async {
        Map<String, dynamic>? capturedTaskBody;

        final authClient = await createTestAuthClient(
          email: mockClientEmail,
          apiHandler: (request) {
            capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
            return Response(
              jsonEncode({'name': 'task/123'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          },
        );

        final app = FirebaseApp.initializeApp(
          name: 'url-test-${DateTime.now().microsecondsSinceEpoch}',
          options: AppOptions(projectId: projectId, httpClient: authClient),
        );

        try {
          final functions = Functions.internal(app);
          final queue = functions.taskQueue('helloWorld');
          await queue.enqueue({'data': 'test'});

          expect(capturedTaskBody, isNotNull);
          final task = capturedTaskBody!['task'] as Map<String, dynamic>;
          final httpRequest = task['httpRequest'] as Map<String, dynamic>;

          expect(
            httpRequest['url'],
            equals(
              'https://us-central1-$projectId.cloudfunctions.net/helloWorld',
            ),
          );
        } finally {
          await app.close();
        }
      });

      test('uses custom location from partial resource name', () async {
        Map<String, dynamic>? capturedTaskBody;
        String? capturedUrl;

        final authClient = await createTestAuthClient(
          email: mockClientEmail,
          apiHandler: (request) {
            capturedUrl = request.url.toString();
            capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
            return Response(
              jsonEncode({'name': 'task/123'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          },
        );

        final app = FirebaseApp.initializeApp(
          name: 'partial-test-${DateTime.now().microsecondsSinceEpoch}',
          options: AppOptions(projectId: projectId, httpClient: authClient),
        );

        try {
          final functions = Functions.internal(app);
          final queue = functions.taskQueue(
            'locations/us-west1/functions/myFunc',
          );
          await queue.enqueue({'data': 'test'});

          expect(capturedUrl, contains('us-west1'));
          expect(capturedUrl, contains('myFunc'));

          final task = capturedTaskBody!['task'] as Map<String, dynamic>;
          final httpRequest = task['httpRequest'] as Map<String, dynamic>;
          expect(
            httpRequest['url'],
            equals('https://us-west1-$projectId.cloudfunctions.net/myFunc'),
          );
        } finally {
          await app.close();
        }
      });

      test('uses project and location from full resource name', () async {
        Map<String, dynamic>? capturedTaskBody;
        String? capturedUrl;

        final authClient = await createTestAuthClient(
          email: mockClientEmail,
          apiHandler: (request) {
            capturedUrl = request.url.toString();
            capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
            return Response(
              jsonEncode({'name': 'task/123'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          },
        );

        final app = FirebaseApp.initializeApp(
          name: 'full-test-${DateTime.now().microsecondsSinceEpoch}',
          options: AppOptions(projectId: projectId, httpClient: authClient),
        );

        try {
          final functions = Functions.internal(app);
          final queue = functions.taskQueue(
            'projects/custom-project/locations/europe-west1/functions/euroFunc',
          );
          await queue.enqueue({'data': 'test'});

          expect(capturedUrl, contains('custom-project'));
          expect(capturedUrl, contains('europe-west1'));
          expect(capturedUrl, contains('euroFunc'));

          final task = capturedTaskBody!['task'] as Map<String, dynamic>;
          final httpRequest = task['httpRequest'] as Map<String, dynamic>;
          expect(
            httpRequest['url'],
            equals(
              'https://europe-west1-custom-project.cloudfunctions.net/euroFunc',
            ),
          );
        } finally {
          await app.close();
        }
      });
    });

    group('extension support', () {
      test('prefixes queue name with extension ID', () async {
        String? capturedUrl;

        final authClient = await createTestAuthClient(
          email: mockClientEmail,
          idToken: 'mock-id-token',
          apiHandler: (request) {
            capturedUrl = request.url.toString();
            return Response(
              jsonEncode({'name': 'task/123'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          },
        );

        final app = FirebaseApp.initializeApp(
          name: 'ext-test-${DateTime.now().microsecondsSinceEpoch}',
          options: AppOptions(projectId: projectId, httpClient: authClient),
        );

        try {
          final functions = Functions.internal(app);
          final queue = functions.taskQueue(
            'helloWorld',
            extensionId: 'my-extension',
          );
          await queue.enqueue({'data': 'test'});

          expect(capturedUrl, contains('ext-my-extension-helloWorld'));
        } finally {
          await app.close();
        }
      });

      test('prefixes function URL with extension ID', () async {
        Map<String, dynamic>? capturedTaskBody;

        final authClient = await createTestAuthClient(
          email: mockClientEmail,
          apiHandler: (request) {
            capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
            return Response(
              jsonEncode({'name': 'task/123'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          },
        );

        final app = FirebaseApp.initializeApp(
          name: 'ext-url-test-${DateTime.now().microsecondsSinceEpoch}',
          options: AppOptions(projectId: projectId, httpClient: authClient),
        );

        try {
          final functions = Functions.internal(app);
          final queue = functions.taskQueue(
            'helloWorld',
            extensionId: 'image-resize',
          );
          await queue.enqueue({'data': 'test'});

          final task = capturedTaskBody!['task'] as Map<String, dynamic>;
          final httpRequest = task['httpRequest'] as Map<String, dynamic>;

          expect(
            httpRequest['url'],
            equals(
              'https://us-central1-$projectId.cloudfunctions.net/ext-image-resize-helloWorld',
            ),
          );
        } finally {
          await app.close();
        }
      });
    });
  });

  // ===========================================================================
  // Task Options Serialization Tests
  // ===========================================================================
  group('Task Options Serialization', () {
    test('converts scheduleTime to ISO string', () async {
      Map<String, dynamic>? capturedTaskBody;
      final scheduleTime = DateTime.now().add(const Duration(hours: 1));

      final authClient = await createTestAuthClient(
        email: mockClientEmail,
        apiHandler: (request) {
          capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
          return Response(
            jsonEncode({'name': 'task/123'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final app = FirebaseApp.initializeApp(
        name: 'schedule-test-${DateTime.now().microsecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: authClient),
      );

      try {
        final functions = Functions.internal(app);
        final queue = functions.taskQueue('helloWorld');
        final options = TaskOptions(schedule: AbsoluteDelivery(scheduleTime));
        await queue.enqueue({'data': 'test'}, options);

        final task = capturedTaskBody!['task'] as Map<String, dynamic>;
        expect(
          task['scheduleTime'],
          equals(scheduleTime.toUtc().toIso8601String()),
        );
      } finally {
        await app.close();
      }
    });

    test('sets scheduleTime based on scheduleDelaySeconds', () async {
      Map<String, dynamic>? capturedTaskBody;
      const delaySeconds = 1800;

      final authClient = await createTestAuthClient(
        email: mockClientEmail,
        apiHandler: (request) {
          capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
          return Response(
            jsonEncode({'name': 'task/123'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final app = FirebaseApp.initializeApp(
        name: 'delay-test-${DateTime.now().microsecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: authClient),
      );

      try {
        final now = DateTime.now().toUtc();
        final functions = Functions.internal(app);
        final queue = functions.taskQueue('helloWorld');
        final options = TaskOptions(schedule: DelayDelivery(delaySeconds));
        await queue.enqueue({'data': 'test'}, options);

        final task = capturedTaskBody!['task'] as Map<String, dynamic>;
        final scheduleTimeStr = task['scheduleTime'] as String;
        final scheduleTime = DateTime.parse(scheduleTimeStr);

        // Should be approximately now + delaySeconds (allow 5 second tolerance)
        final expectedTime = now.add(const Duration(seconds: delaySeconds));
        expect(
          scheduleTime.difference(expectedTime).inSeconds.abs(),
          lessThan(5),
        );
      } finally {
        await app.close();
      }
    });

    test('converts dispatchDeadline to duration with s suffix', () async {
      Map<String, dynamic>? capturedTaskBody;
      const dispatchDeadlineSeconds = 300;

      final authClient = await createTestAuthClient(
        email: mockClientEmail,
        apiHandler: (request) {
          capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
          return Response(
            jsonEncode({'name': 'task/123'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final app = FirebaseApp.initializeApp(
        name: 'deadline-test-${DateTime.now().microsecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: authClient),
      );

      try {
        final functions = Functions.internal(app);
        final queue = functions.taskQueue('helloWorld');
        final options = TaskOptions(
          dispatchDeadlineSeconds: dispatchDeadlineSeconds,
        );
        await queue.enqueue({'data': 'test'}, options);

        final task = capturedTaskBody!['task'] as Map<String, dynamic>;
        expect(task['dispatchDeadline'], equals('${dispatchDeadlineSeconds}s'));
      } finally {
        await app.close();
      }
    });

    test('encodes data in base64 payload', () async {
      Map<String, dynamic>? capturedTaskBody;
      final testData = {'privateKey': '~/.ssh/id_rsa.pub', 'count': 42};

      final authClient = await createTestAuthClient(
        email: mockClientEmail,
        apiHandler: (request) {
          capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
          return Response(
            jsonEncode({'name': 'task/123'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final app = FirebaseApp.initializeApp(
        name: 'encode-test-${DateTime.now().microsecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: authClient),
      );

      try {
        final functions = Functions.internal(app);
        final queue = functions.taskQueue('helloWorld');
        await queue.enqueue(testData);

        final task = capturedTaskBody!['task'] as Map<String, dynamic>;
        final httpRequest = task['httpRequest'] as Map<String, dynamic>;
        final bodyBase64 = httpRequest['body'] as String;

        final decodedBytes = base64Decode(bodyBase64);
        final decodedJson = jsonDecode(utf8.decode(decodedBytes));
        expect((decodedJson as Map<String, dynamic>)['data'], equals(testData));
      } finally {
        await app.close();
      }
    });

    test('sets task name when ID is provided', () async {
      Map<String, dynamic>? capturedTaskBody;
      const taskId = 'my-custom-task-id';

      final authClient = await createTestAuthClient(
        email: mockClientEmail,
        apiHandler: (request) {
          capturedTaskBody = jsonDecode(request.body) as Map<String, dynamic>;
          return Response(
            jsonEncode({'name': 'task/123'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final app = FirebaseApp.initializeApp(
        name: 'id-test-${DateTime.now().microsecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: authClient),
      );

      try {
        final functions = Functions.internal(app);
        final queue = functions.taskQueue('helloWorld');
        final options = TaskOptions(id: taskId);
        await queue.enqueue({'data': 'test'}, options);

        final task = capturedTaskBody!['task'] as Map<String, dynamic>;
        expect(task['name'], contains(taskId));
        expect(task['name'], contains('helloWorld'));
      } finally {
        await app.close();
      }
    });
  });

  // ===========================================================================
  // Error Handling Tests
  // ===========================================================================
  group('Error Handling', () {
    test('throws task-already-exists on 409 conflict', () async {
      final authClient = await createTestAuthClient(
        email: mockClientEmail,
        apiHandler: (request) {
          return Response(
            jsonEncode({
              'error': {
                'code': 409,
                'message': 'Task already exists',
                'status': 'ALREADY_EXISTS',
              },
            }),
            409,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final app = FirebaseApp.initializeApp(
        name: 'conflict-test-${DateTime.now().microsecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: authClient),
      );

      try {
        final functions = Functions.internal(app);
        final queue = functions.taskQueue('helloWorld');

        expect(
          () =>
              queue.enqueue({'data': 'test'}, TaskOptions(id: 'duplicate-id')),
          throwsA(
            isA<FirebaseFunctionsAdminException>().having(
              (e) => e.errorCode,
              'errorCode',
              FunctionsClientErrorCode.taskAlreadyExists,
            ),
          ),
        );
      } finally {
        await app.close();
      }
    });

    test('throws not-found on 404 error for enqueue', () async {
      final authClient = await createTestAuthClient(
        email: mockClientEmail,
        apiHandler: (request) {
          return Response(
            jsonEncode({
              'error': {
                'code': 404,
                'message': 'Queue not found',
                'status': 'NOT_FOUND',
              },
            }),
            404,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final app = FirebaseApp.initializeApp(
        name: 'notfound-test-${DateTime.now().microsecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: authClient),
      );

      try {
        final functions = Functions.internal(app);
        final queue = functions.taskQueue('nonExistentQueue');

        expect(
          () => queue.enqueue({'data': 'test'}),
          throwsA(isA<FirebaseFunctionsAdminException>()),
        );
      } finally {
        await app.close();
      }
    });

    test('silently succeeds on 404 for delete (task not found)', () async {
      final authClient = await createTestAuthClient(
        email: mockClientEmail,
        apiHandler: (request) {
          if (request.method == 'DELETE') {
            return Response(
              jsonEncode({
                'error': {
                  'code': 404,
                  'message': 'Task not found',
                  'status': 'NOT_FOUND',
                },
              }),
              404,
              headers: {'content-type': 'application/json'},
            );
          }
          return Response('{}', 200);
        },
      );

      final app = FirebaseApp.initializeApp(
        name: 'delete-notfound-test-${DateTime.now().microsecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: authClient),
      );

      try {
        final functions = Functions.internal(app);
        final queue = functions.taskQueue('helloWorld');

        // Should NOT throw - 404 on delete is expected for non-existent tasks
        await queue.delete('non-existent-task');
      } finally {
        await app.close();
      }
    });
  });
}
