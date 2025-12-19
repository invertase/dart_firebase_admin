part of 'functions.dart';

/// Parsed resource name components.
class _ParsedResource {
  _ParsedResource({this.projectId, this.locationId, required this.resourceId});

  String? projectId;
  String? locationId;
  final String resourceId;
}

/// Request handler for Cloud Functions Task Queue operations.
///
/// Handles complex business logic, request/response transformations,
/// and validation. Delegates API calls to [FunctionsHttpClient].
class FunctionsRequestHandler {
  FunctionsRequestHandler(FirebaseApp app, {FunctionsHttpClient? httpClient})
    : _httpClient = httpClient ?? FunctionsHttpClient(app);

  final FunctionsHttpClient _httpClient;

  /// Enqueues a task to the specified function's queue.
  Future<void> enqueue(
    Object data,
    String functionName,
    String? extensionId,
    TaskOptions? options,
  ) async {
    validateNonEmptyString(functionName, 'functionName');

    // Parse the function name to extract project, location, and function ID
    final resources = _parseResourceName(functionName, 'functions');

    return _httpClient.cloudTasks((api, projectId) async {
      // Fill in missing resource components
      resources.projectId ??= projectId;
      resources.locationId ??= _defaultLocation;

      validateNonEmptyString(resources.resourceId, 'resourceId');

      // Apply extension ID prefix if provided
      var queueId = resources.resourceId;
      if (extensionId != null && extensionId.isNotEmpty) {
        queueId = 'ext-$extensionId-$queueId';
      }

      // Build the task
      final task = _buildTask(data, resources, queueId, options);

      final parent = _httpClient.buildTasksParent(
        projectId: resources.projectId!,
        locationId: resources.locationId!,
        queueId: queueId,
      );

      try {
        await api.projects.locations.queues.tasks.create(
          tasks2.CreateTaskRequest(task: task),
          parent,
        );
      } on tasks2.DetailedApiRequestError catch (error) {
        // Handle 409 Conflict (task already exists)
        if (error.status == 409) {
          throw FirebaseFunctionsAdminException(
            FunctionsClientErrorCode.taskAlreadyExists,
            'A task with ID ${options?.id} already exists',
          );
        }
        rethrow; // Will be caught by _functionsGuard
      }
    });
  }

  /// Deletes a task from the specified function's queue.
  Future<void> delete(
    String id,
    String functionName,
    String? extensionId,
  ) async {
    validateNonEmptyString(functionName, 'functionName');
    validateNonEmptyString(id, 'id');

    if (!isValidTaskId(id)) {
      throw FirebaseFunctionsAdminException(
        FunctionsClientErrorCode.invalidArgument,
        'id can contain only letters ([A-Za-z]), numbers ([0-9]), '
        'hyphens (-), or underscores (_). The maximum length is 500 characters.',
      );
    }

    // Parse the function name
    final resources = _parseResourceName(functionName, 'functions');

    return _httpClient.cloudTasks((api, projectId) async {
      // Fill in missing resource components
      resources.projectId ??= projectId;
      resources.locationId ??= _defaultLocation;

      validateNonEmptyString(resources.resourceId, 'resourceId');

      // Apply extension ID prefix if provided
      var queueId = resources.resourceId;
      if (extensionId != null && extensionId.isNotEmpty) {
        queueId = 'ext-$extensionId-$queueId';
      }

      // Build the full task name
      final taskName = _httpClient.buildTaskName(
        projectId: resources.projectId!,
        locationId: resources.locationId!,
        queueId: queueId,
        taskId: id,
      );

      try {
        await api.projects.locations.queues.tasks.delete(taskName);
      } on tasks2.DetailedApiRequestError catch (error) {
        // If the task doesn't exist (404), ignore the error
        if (error.status == 404) {
          return;
        }
        rethrow; // Will be caught by _functionsGuard
      }
    });
  }

  /// Parses a resource name into its components.
  ///
  /// Supports:
  /// - Full: `projects/{project}/locations/{location}/functions/{functionName}`
  /// - Partial: `locations/{location}/functions/{functionName}`
  /// - Simple: `{functionName}`
  _ParsedResource _parseResourceName(
    String resourceName,
    String resourceIdKey,
  ) {
    // Simple case: no slashes means it's just the resource ID
    if (!resourceName.contains('/')) {
      return _ParsedResource(resourceId: resourceName);
    }

    // Parse full or partial resource name
    final regex = RegExp(
      '^(projects/([^/]+)/)?locations/([^/]+)/$resourceIdKey/([^/]+)\$',
    );
    final match = regex.firstMatch(resourceName);

    if (match == null) {
      throw FirebaseFunctionsAdminException(
        FunctionsClientErrorCode.invalidArgument,
        'Invalid resource name format.',
      );
    }

    return _ParsedResource(
      projectId: match.group(2), // Optional project ID
      locationId: match.group(3), // Required location
      resourceId: match.group(4)!, // Required resource ID
    );
  }

  /// Builds a Cloud Tasks Task from the given data and options.
  tasks2.Task _buildTask(
    Object data,
    _ParsedResource resources,
    String queueId,
    TaskOptions? options,
  ) {
    // Base64 encode the data payload
    final bodyBytes = utf8.encode(jsonEncode({'data': data}));
    final bodyBase64 = base64Encode(bodyBytes);

    // Build HTTP request
    final httpRequest = tasks2.HttpRequest(
      body: bodyBase64,
      headers: {'Content-Type': 'application/json', ...?options?.headers},
    );

    // Build the task
    final task = tasks2.Task(httpRequest: httpRequest);

    // Set schedule time using pattern matching on DeliverySchedule
    switch (options?.schedule) {
      case AbsoluteDelivery(:final scheduleTime):
        task.scheduleTime = scheduleTime.toUtc().toIso8601String();
      case DelayDelivery(:final scheduleDelaySeconds):
        final scheduledTime = DateTime.now().toUtc().add(
          Duration(seconds: scheduleDelaySeconds),
        );
        task.scheduleTime = scheduledTime.toIso8601String();
      case null:
        // No scheduling specified - task will be enqueued immediately
        break;
    }

    // Set dispatch deadline
    if (options?.dispatchDeadlineSeconds != null) {
      task.dispatchDeadline = '${options!.dispatchDeadlineSeconds}s';
    }

    // Set task ID (for deduplication)
    if (options?.id != null) {
      task.name = _httpClient.buildTaskName(
        projectId: resources.projectId!,
        locationId: resources.locationId!,
        queueId: queueId,
        taskId: options!.id!,
      );
    }

    // Set custom URI if provided (experimental feature)
    if (options?.experimental?.uri != null) {
      httpRequest.url = options!.experimental!.uri;
    } else {
      // Use default function URL
      httpRequest.url = _httpClient.buildFunctionUrl(
        projectId: resources.projectId!,
        locationId: resources.locationId!,
        functionName: queueId,
      );
    }

    // Set OIDC token for authentication
    // TODO: Check for ComputeEngine credentials and use ID token instead
    // For now, always use OIDC token with service account
    httpRequest.oidcToken = tasks2.OidcToken(
      serviceAccountEmail: '', // Will be filled by service account discovery
    );

    return task;
  }
}
