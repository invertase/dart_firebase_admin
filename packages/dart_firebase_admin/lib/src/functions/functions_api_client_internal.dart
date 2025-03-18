// import 'package:googleapis/cloudfunctions/v2.dart' as functions2;
import 'dart:convert';

import 'package:googleapis/cloudtasks/v2.dart' as tasks2;
import 'package:googleapis/fcm/v1.dart';
import 'package:meta/meta.dart';

import '../app.dart';
import '../utils/index.dart' as utils;
import 'functions_api.dart';

// Default canonical location ID of the task queue.
const _defaultLocation = 'us-central1';

@internal
class FunctionsApiClient {
  FunctionsApiClient(this.app);

  final FirebaseAdminApp app;

  Future<R> _v2<R>(
    Future<R> Function(tasks2.CloudTasksApi client) fn,
  ) async {
    return fn(tasks2.CloudTasksApi(await app.client));
  }

  /// Deletes a task from a queue.
  Future<void> delete(
    String id,
    String functionName, [
    String? extensionId,
  ]) async {
    return _v2((client) async {
      utils.ParsedResource resources;
      try {
        resources = utils.ParsedResource.parse(functionName, 'functions');
      } catch (err) {
        throw FirebaseFunctionsException(
          FunctionsErrorCode.invalidArgument,
          'Function name must be a single string or a qualified resource name',
        );
      }
      resources.projectId ??= app.projectId;
      resources.locationId ??= _defaultLocation;
      if (extensionId != null) {
        resources.resourceId = 'ext-$extensionId-${resources.resourceId}';
      }
      final path =
          'projects/${resources.projectId}/locations/${resources.locationId}/queues/${resources.resourceId}/tasks';

      await client.projects.locations.queues.tasks.delete(path);
    });
  }

  /// Creates a task and adds it to a queue.
  Future<void> enqueue(
    Object? data,
    String functionName,
    String? extensionId, [
    TaskOptions? opts,
  ]) async {
    return _v2((client) async {
      try {
        utils.ParsedResource resources;
        try {
          resources = utils.ParsedResource.parse(functionName, 'functions');
        } catch (err) {
          throw FirebaseFunctionsException(
            FunctionsErrorCode.invalidArgument,
            'Function name must be a single string or a qualified resource name',
          );
        }

        resources.projectId ??= app.projectId;
        resources.locationId ??= _defaultLocation;
        if (extensionId != null) {
          resources.resourceId = 'ext-$extensionId-${resources.resourceId}';
        }

        final path =
            'projects/${resources.projectId}/locations/${resources.locationId}/queues/${resources.resourceId}/tasks';

        await client.projects.locations.queues.tasks.create(
          tasks2.CreateTaskRequest(
            task: _validateTaskOptions(data, resources, opts),
          ),
          path,
        );
      } on DetailedApiRequestError catch (e) {
        if (e.status == 409) {
          throw FirebaseFunctionsException(
            FunctionsErrorCode.taskAlreadyExists,
            'A task with ID ${opts?.id} already exists',
          );
        }

        rethrow;
      }
    });
  }

  tasks2.Task _validateTaskOptions(
    Object? data,
    utils.ParsedResource resources,
    TaskOptions? options,
  ) {
    final task = tasks2.Task(
      httpRequest: tasks2.HttpRequest(
        url: '',
        oidcToken: tasks2.OidcToken(serviceAccountEmail: ''),
        body: base64.encode(utf8.encode(json.encode(data))),
        headers: {
          'Content-Type': 'application/json',
          ...?options?.headers,
        },
      ),
    );

    if (options == null) return task;

    switch (options.schedule) {
      case final DelayDelivery delay:
        if (delay.scheduleDelaySeconds case final scheduleDelaySeconds?) {
          if (scheduleDelaySeconds < 0) {
            throw FirebaseFunctionsException(
              FunctionsErrorCode.invalidArgument,
              'scheduleDelaySeconds must be a non-negative duration in seconds.',
            );
          }

          final date = DateTime.now();
          date.add(Duration(seconds: delay.scheduleDelaySeconds!));
          task.scheduleTime = date.toIso8601String();
        }
      case final AbsoluteDelivery absolute:
        if (absolute.scheduleTime case final scheduleTime?) {
          task.scheduleTime = scheduleTime.toIso8601String();
        }
    }

    if (options.dispatchDeadlineSeconds case final dispatchDeadlineSeconds?) {
      if (dispatchDeadlineSeconds < 15 || dispatchDeadlineSeconds > 1800) {
        throw FirebaseFunctionsException(
          FunctionsErrorCode.invalidArgument,
          'dispatchDeadlineSeconds must be a non-negative duration in seconds and must be in the range of 15s to 30 mins.',
        );
      }
      task.dispatchDeadline = '${options.dispatchDeadlineSeconds}s';
    }

    if (options.id case final id?) {
      task.name =
          'projects/${resources.projectId}/locations/${resources.locationId}/queues/${resources.resourceId}/tasks/$id';
    }

    if (options.uri case final uri?) {
      if (Uri.tryParse(uri) == null) {
        throw FirebaseFunctionsException(
          FunctionsErrorCode.invalidArgument,
          'uri must be a valid URL string.',
        );
      }
      task.httpRequest!.url = uri;
    }

    return task;
  }
}

final functionsErrorCodeMapping = <String, FunctionsErrorCode>{
  'ABORTED': FunctionsErrorCode.aborted,
  'INVALID_ARGUMENT': FunctionsErrorCode.invalidArgument,
  'INVALID_CREDENTIAL': FunctionsErrorCode.invalidCredential,
  'INTERNAL': FunctionsErrorCode.internalError,
  'FAILED_PRECONDITION': FunctionsErrorCode.failedPrecondition,
  'PERMISSION_DENIED': FunctionsErrorCode.permissionDenied,
  'UNAUTHENTICATED': FunctionsErrorCode.unauthenticated,
  'NOT_FOUND': FunctionsErrorCode.notFound,
  'UNKNOWN': FunctionsErrorCode.unknownError,
};

enum FunctionsErrorCode {
  aborted('aborted'),
  invalidArgument('invalid-argument'),
  invalidCredential('invalid-credential'),
  internalError('internal-error'),
  failedPrecondition('failed-precondition'),
  permissionDenied('permission-denied'),
  unauthenticated('unauthenticated'),
  notFound('not-found'),
  unknownError('unknown-error'),
  taskAlreadyExists('task-already-exists');

  const FunctionsErrorCode(this.code);
  final String code;
}

/// Firebase Functions error code structure. This extends PrefixedFirebaseError.
///
/// [code] - The error code.
/// [message] - The error message.
class FirebaseFunctionsException extends FirebaseAdminException {
  FirebaseFunctionsException(FunctionsErrorCode code, String message)
      : super('app-check', code.code, message);
}
