import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/functions.dart';

/// Functions example prerequisites:
/// 1) Run `npm run build` in `example_functions_ts` to generate `index.js`.
/// 2) From the example directory root (with `firebase.json` and `.firebaserc`),
///    start emulators with `firebase emulators:start`.
/// 3) Run `dart_firebase_admin/packages/dart_firebase_admin/example/run_with_emulator.sh`.
Future<void> functionsExample(FirebaseApp admin) async {
  print('\n### Functions Example ###\n');

  final functions = admin.functions();

  // Accessing the app property
  print('> Functions app name: ${functions.app.name}\n');

  // Get a task queue reference
  // The function name should match an existing Cloud Function or queue name
  final taskQueue = functions.taskQueue('helloWorld');

  // Example 1: Enqueue a simple task
  try {
    print('> Enqueuing a simple task...\n');
    await taskQueue.enqueue({
      'userId': 'user-123',
      'action': 'sendWelcomeEmail',
      'timestamp': DateTime.now().toIso8601String(),
    });
    print('Task enqueued successfully!\n');
  } on FirebaseFunctionsAdminException catch (e) {
    print('> Functions error: ${e.code} - ${e.message}\n');
  } catch (e) {
    print('> Error enqueuing task: $e\n');
  }

  // Example 2: Enqueue with delay (1 hour from now)
  try {
    print('> Enqueuing a delayed task...\n');
    await taskQueue.enqueue(
      {'action': 'cleanupTempFiles'},
      TaskOptions(schedule: DelayDelivery(3600)), // 1 hour delay
    );
    print('Delayed task enqueued successfully!\n');
  } on FirebaseFunctionsAdminException catch (e) {
    print('> Functions error: ${e.code} - ${e.message}\n');
  }

  // Example 3: Enqueue at specific time
  try {
    print('> Enqueuing a scheduled task...\n');
    final scheduledTime = DateTime.now().add(const Duration(minutes: 30));
    await taskQueue.enqueue({
      'action': 'sendReport',
    }, TaskOptions(schedule: AbsoluteDelivery(scheduledTime)));
    print('Scheduled task enqueued for: $scheduledTime\n');
  } on FirebaseFunctionsAdminException catch (e) {
    print('> Functions error: ${e.code} - ${e.message}\n');
  }

  // Example 4: Enqueue with custom task ID (for deduplication)
  try {
    print('> Enqueuing a task with custom ID...\n');
    await taskQueue.enqueue({
      'orderId': 'order-456',
      'action': 'processPayment',
    }, TaskOptions(id: 'payment-order-456'));
    print('Task with custom ID enqueued!\n');
  } on FirebaseFunctionsAdminException catch (e) {
    if (e.errorCode == FunctionsClientErrorCode.taskAlreadyExists) {
      print('> Task with this ID already exists (deduplication)\n');
    } else {
      print('> Functions error: ${e.code} - ${e.message}\n');
    }
  }

  // Example 5: Enqueue with experimental URI override
  try {
    print('> Enqueuing a task with a custom handler URI...\n');
    await taskQueue.enqueue(
      {'action': 'customHandler'},
      TaskOptions(
        experimental: TaskOptionsExperimental(
          uri: 'https://custom.example.com/task-handler',
        ),
      ),
    );
    print('Task with experimental URI enqueued!\n');
  } on FirebaseFunctionsAdminException catch (e) {
    print('> Functions error: ${e.code} - ${e.message}\n');
  }

  // Example 6: Delete a task
  try {
    print('> Deleting task...\n');
    await taskQueue.delete('payment-order-456');
    print('Task deleted successfully!\n');
  } on FirebaseFunctionsAdminException catch (e) {
    print('> Functions error: ${e.code} - ${e.message}\n');
  }
}
