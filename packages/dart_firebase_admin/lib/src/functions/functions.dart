import '../../dart_firebase_admin.dart';
import 'functions_api.dart';
import 'functions_api_client_internal.dart';

class Functions {
  Functions(this.app);

  final FirebaseAdminApp app;
  late final _client = FunctionsApiClient(app);

  /// Creates a reference to a [TaskQueue] for a given function name.
  /// The function name can be either:
  ///
  /// 1) A fully qualified function resource name:
  ///     `projects/{project}/locations/{location}/functions/{functionName}`
  ///
  /// 2) A partial resource name with location and function name, in which case
  ///     the runtime project ID is used:
  ///     `locations/{location}/functions/{functionName}`
  ///
  /// 3) A partial function name, in which case the runtime project ID and the default location,
  ///     `us-central1`, is used:
  ///     `{functionName}`
  ///
  /// [functionName] - The name of the function.
  /// [extensionId] - Optional Firebase extension ID.
  /// Returns a future that fulfills with a [TaskQueue].
  TaskQueue taskQueue(String functionName, [String? extensionId]) =>
      TaskQueue._(functionName, _client, extensionId);
}

class TaskQueue {
  TaskQueue._(this._functionName, this._client, [this._extensionId]);

  final String _functionName;
  final FunctionsApiClient _client;
  final String? _extensionId;

  /// Creates a task and adds it to the queue. Tasks cannot be updated after creation.
  /// This action requires `cloudtasks.tasks.create` IAM permission on the service account.
  ///
  /// [data] - The data payload of the task.
  /// [opts] - Optional options when enqueuing a new task.
  /// Returns a future that resolves when the task has successfully been added to the queue.
  Future<void> enqueue(Map<String, Object?> data, [TaskOptions? opts]) {
    return _client.enqueue(
      data,
      _functionName,
      _extensionId,
      opts,
    );
  }

  /// Deletes an enqueued task if it has not yet completed.
  ///
  /// [id] - the ID of the task, relative to this queue.
  /// Returns a future that resolves when the task has been deleted.
  Future<void> delete(String id) {
    return _client.delete(id, _functionName, _extensionId);
  }
}
