part of 'functions.dart';

/// A reference to a Cloud Functions task queue.
///
/// Use this to enqueue tasks for a specific Cloud Function or delete
/// pending tasks.
class TaskQueue {
  TaskQueue._({
    required String functionName,
    required FunctionsRequestHandler requestHandler,
    String? extensionId,
  }) : _functionName = functionName,
       _requestHandler = requestHandler,
       _extensionId = extensionId {
    validateNonEmptyString(_functionName, 'functionName');
    if (_extensionId != null) {
      validateString(_extensionId, 'extensionId');
    }
  }

  final String _functionName;
  final FunctionsRequestHandler _requestHandler;
  final String? _extensionId;

  /// Enqueues a task with the given [data] payload.
  ///
  /// The [data] will be JSON-encoded and sent to the function.
  ///
  /// Optional [options] can specify:
  /// - Schedule time (absolute or delay)
  /// - Dispatch deadline
  /// - Task ID (for deduplication)
  /// - Custom headers
  /// - Custom URI
  ///
  /// Example:
  /// ```dart
  /// await queue.enqueue(
  ///   {'userId': '123', 'action': 'sendEmail'},
  ///   TaskOptions(
  ///     scheduleDelaySeconds: 3600, // Send in 1 hour
  ///     id: 'unique-task-id',
  ///   ),
  /// );
  /// ```
  ///
  /// Throws [FirebaseFunctionsAdminException] if the request fails.
  Future<void> enqueue(Map<String, dynamic> data, [TaskOptions? options]) {
    return _requestHandler.enqueue(data, _functionName, _extensionId, options);
  }

  /// Deletes a task from the queue by its [id].
  ///
  /// A task can only be deleted if it hasn't been executed yet.
  /// If the task doesn't exist, this method completes successfully without error.
  ///
  /// Example:
  /// ```dart
  /// await queue.delete('unique-task-id');
  /// ```
  ///
  /// Throws [FirebaseFunctionsAdminException] if the request fails.
  Future<void> delete(String id) {
    return _requestHandler.delete(id, _functionName, _extensionId);
  }
}
