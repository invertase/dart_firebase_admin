import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis/cloudtasks/v2.dart' as tasks2;
import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:meta/meta.dart';

import '../app.dart';
import '../utils/validator.dart';

part 'functions_api.dart';
part 'functions_exception.dart';
part 'functions_http_client.dart';
part 'functions_request_handler.dart';
part 'task_queue.dart';

const _defaultLocation = 'us-central1';

/// Default service account email used when running with the Cloud Tasks emulator.
const _emulatedServiceAccountDefault = 'emulated-service-acct@email.com';

/// An interface for interacting with Cloud Functions Task Queues.
///
/// This service allows you to enqueue tasks for Cloud Functions and manage
/// those tasks before they execute.
class Functions implements FirebaseService {
  /// Creates or returns the cached Functions instance for the given app.
  factory Functions(FirebaseApp app) {
    return app.getOrInitService(
      FirebaseServiceType.functions.name,
      Functions._,
    );
  }

  /// An interface for interacting with Cloud Functions Task Queues.
  Functions._(this.app) : _requestHandler = FunctionsRequestHandler(app);

  @internal
  factory Functions.internal(
    FirebaseApp app, {
    FunctionsRequestHandler? requestHandler,
  }) {
    return app.getOrInitService(
      FirebaseServiceType.functions.name,
      (app) => Functions._internal(app, requestHandler: requestHandler),
    );
  }

  Functions._internal(this.app, {FunctionsRequestHandler? requestHandler})
    : _requestHandler = requestHandler ?? FunctionsRequestHandler(app);

  /// The app associated with this Functions instance.
  @override
  final FirebaseApp app;

  final FunctionsRequestHandler _requestHandler;

  /// Creates a reference to a task queue for the given function.
  ///
  /// The [functionName] can be:
  /// 1. A fully qualified function resource name:
  ///    `projects/{project}/locations/{location}/functions/{functionName}`
  /// 2. A partial resource name with location and function name:
  ///    `locations/{location}/functions/{functionName}`
  /// 3. Just the function name (uses default location `us-central1`):
  ///    `{functionName}`
  ///
  /// The optional [extensionId] is used for Firebase Extension functions.
  ///
  /// Example:
  /// ```dart
  /// final functions = FirebaseApp.instance.functions;
  /// final queue = functions.taskQueue('myFunction');
  /// await queue.enqueue({'data': 'value'});
  /// ```
  TaskQueue taskQueue(String functionName, {String? extensionId}) {
    return TaskQueue._(
      functionName: functionName,
      requestHandler: _requestHandler,
      extensionId: extensionId,
    );
  }

  @override
  Future<void> delete() async {
    // Close HTTP client if we created it (emulator mode)
    // In production mode, we use app.client which is closed by the app
    if (Environment.isCloudTasksEmulatorEnabled()) {
      try {
        final client = await _requestHandler.httpClient.client;
        client.close();
      } catch (_) {
        // Ignore errors if client wasn't initialized
      }
    }
  }
}
