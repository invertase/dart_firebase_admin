import 'package:dart_firebase_admin/functions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'util/helpers.dart';

class MockRequestHandler extends Mock implements FunctionsRequestHandler {}

void main() {
  late MockRequestHandler mockHandler;
  late Functions functions;

  setUp(() {
    mockHandler = MockRequestHandler();
    functions = createFunctionsWithMockHandler(mockHandler);
  });

  group('Functions', () {
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
        final queue = functions.taskQueue('helloWorld', 'my-extension');

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
        final options = TaskOptions(schedule: const DelayDelivery(60));

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

        final queue = functions.taskQueue('helloWorld', 'my-extension');

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

        final queue = functions.taskQueue('helloWorld', 'my-extension');

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

        // Should not throw
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
}
