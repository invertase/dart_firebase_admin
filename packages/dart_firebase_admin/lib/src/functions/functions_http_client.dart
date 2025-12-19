part of 'functions.dart';

/// HTTP client for Cloud Functions Task Queue operations.
///
/// Handles HTTP client management, googleapis API client creation,
/// path builders, and emulator support.
class FunctionsHttpClient {
  FunctionsHttpClient(this.app);

  final FirebaseApp app;

  /// Gets the Cloud Tasks API host URL based on emulator configuration.
  ///
  /// When CLOUD_TASKS_EMULATOR_HOST is set, routes requests to
  /// the local Cloud Tasks emulator. Otherwise, uses production Cloud Tasks API.
  Uri get _cloudTasksApiHost {
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    final emulatorHost = env['CLOUD_TASKS_EMULATOR_HOST'];

    if (emulatorHost != null && emulatorHost.isNotEmpty) {
      return Uri.http(emulatorHost, '/');
    }

    return Uri.https('cloudtasks.googleapis.com', '/');
  }

  /// Lazy-initialized HTTP client that's cached for reuse.
  /// Uses EmulatorClient for emulator, authenticated client for production.
  late final Future<googleapis_auth.AuthClient> _client = _createClient();

  Future<googleapis_auth.AuthClient> get client => _client;

  /// Creates the appropriate HTTP client based on emulator configuration.
  Future<googleapis_auth.AuthClient> _createClient() async {
    // If app has custom httpClient (e.g., mock for testing), always use it
    if (app.options.httpClient != null) {
      return app.client;
    }

    // Check if Cloud Tasks emulator is enabled
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    final emulatorHost = env['CLOUD_TASKS_EMULATOR_HOST'];

    if (emulatorHost != null && emulatorHost.isNotEmpty) {
      // Emulator: Create unauthenticated client to avoid loading ADC credentials
      // which would cause emulator warnings. Wrap with EmulatorClient to add
      // "Authorization: Bearer owner" header that the emulator requires.
      return EmulatorClient(http.Client());
    }

    // Production: Use authenticated client from app
    return app.client;
  }

  /// Builds the parent resource path for Cloud Tasks operations.
  ///
  /// Format: `projects/{projectId}/locations/{locationId}/queues/{queueId}`
  String buildTasksParent({
    required String projectId,
    required String locationId,
    required String queueId,
  }) {
    return 'projects/$projectId/locations/$locationId/queues/$queueId';
  }

  /// Builds the full task resource name.
  ///
  /// Format: `projects/{projectId}/locations/{locationId}/queues/{queueId}/tasks/{taskId}`
  String buildTaskName({
    required String projectId,
    required String locationId,
    required String queueId,
    required String taskId,
  }) {
    return 'projects/$projectId/locations/$locationId/queues/$queueId/tasks/$taskId';
  }

  /// Builds the function URL.
  ///
  /// Format: `https://{locationId}-{projectId}.cloudfunctions.net/{functionName}`
  String buildFunctionUrl({
    required String projectId,
    required String locationId,
    required String functionName,
  }) {
    return 'https://$locationId-$projectId.cloudfunctions.net/$functionName';
  }

  Future<R> _run<R>(
    Future<R> Function(googleapis_auth.AuthClient client, String projectId) fn,
  ) async {
    final authClient = await client;
    final projectId = await authClient.getProjectId(
      projectIdOverride: app.options.projectId,
      environment: Zone.current[envSymbol] as Map<String, String>?,
    );
    return _functionsGuard(() => fn(authClient, projectId));
  }

  /// Executes a Cloud Tasks API operation with automatic projectId injection.
  Future<R> cloudTasks<R>(
    Future<R> Function(tasks2.CloudTasksApi api, String projectId) fn,
  ) => _run(
    (client, projectId) => fn(
      tasks2.CloudTasksApi(client, rootUrl: _cloudTasksApiHost.toString()),
      projectId,
    ),
  );
}

/// Guards a Functions operation and converts errors to FirebaseFunctionsAdminException.
Future<T> _functionsGuard<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on tasks2.DetailedApiRequestError catch (error) {
    // Convert googleapis error to Functions exception
    throw _createFirebaseError(
      statusCode: error.status ?? 500,
      body: switch (error.jsonResponse) {
        null => error.message ?? '',
        final json => jsonEncode(json),
      },
      isJson: error.jsonResponse != null,
    );
  }
}
