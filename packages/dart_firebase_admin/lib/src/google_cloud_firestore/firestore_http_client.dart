part of 'firestore.dart';

class FirestoreHttpClient {
  FirestoreHttpClient(this.app, [ProjectIdProvider? projectIdProvider])
      : _projectIdProvider = projectIdProvider ?? ProjectIdProvider(app);

  final FirebaseApp app;
  final ProjectIdProvider _projectIdProvider;

  /// Gets the Firestore API host URL based on emulator configuration.
  ///
  /// When [Environment.firestoreEmulatorHost] is set, routes requests to
  /// the local Firestore emulator. Otherwise, uses production Firestore API.
  Uri get _firestoreApiHost {
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    final emulatorHost = env[Environment.firestoreEmulatorHost];

    if (emulatorHost != null) {
      return Uri.http(emulatorHost, '/');
    }

    return Uri.https('firestore.googleapis.com', '/');
  }

  /// Checks if the Firestore emulator is enabled via environment variable.
  bool get _isUsingEmulator => Environment.isFirestoreEmulatorEnabled();

  /// Lazy-initialized HTTP client that's cached for reuse.
  /// Uses unauthenticated client for emulator, authenticated for production.
  late final Future<Client> _client = _createClient();

  /// Creates the appropriate HTTP client based on emulator configuration.
  Future<Client> _createClient() async {
    // If app has custom httpClient (e.g., mock for testing), always use it
    if (app.options.httpClient != null) {
      return app.client;
    }

    if (_isUsingEmulator) {
      // Emulator: Create unauthenticated client to avoid loading ADC credentials
      // which would cause emulator warnings. Wrap with EmulatorClient to add
      // "Authorization: Bearer owner" header that the emulator requires.
      return EmulatorClient(Client());
    }
    // Production: Use authenticated client from app
    return app.client;
  }

  Future<R> _run<R>(
    Future<R> Function(Client client) fn,
  ) async {
    // Use the cached client (created once based on emulator configuration)
    final client = await _client;
    return _firestoreGuard(() => fn(client));
  }

  /// Executes a Firestore v1 API operation with automatic projectId injection.
  ///
  /// Discovers and caches the projectId on first call, then provides it to
  /// all subsequent operations. This matches the Auth service pattern.
  Future<R> v1<R>(
    Future<R> Function(firestore1.FirestoreApi client, String projectId) fn,
  ) async {
    final projectId = await _projectIdProvider.discoverProjectId();
    return _run(
      (client) => fn(
        firestore1.FirestoreApi(
          client,
          rootUrl: _firestoreApiHost.toString(),
        ),
        projectId,
      ),
    );
  }
}
