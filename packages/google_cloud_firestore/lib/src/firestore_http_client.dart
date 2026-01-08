part of 'firestore.dart';

/// HTTP client wrapper for Firestore API operations.
///
/// Provides authenticated API access with automatic project ID discovery.
class FirestoreHttpClient {
  FirestoreHttpClient({required this.credential, required Settings settings})
    : _settings = settings;

  final GoogleCredential credential;
  final Settings _settings;

  String? _cachedProjectId;

  String? get cachedProjectId => _cachedProjectId;

  /// Gets the Firestore API host URL based on emulator configuration.
  Uri get _firestoreApiHost {
    final emulatorHost = Environment.getFirestoreEmulatorHost();

    if (emulatorHost != null) {
      return Uri.http(emulatorHost, '/');
    }

    return Uri.https(_settings.host ?? 'firestore.googleapis.com', '/');
  }

  /// Checks if the Firestore emulator is enabled via environment variable.
  bool get _isUsingEmulator => Environment.isFirestoreEmulatorEnabled();

  /// Lazy-initialized HTTP client that's cached for reuse.
  late final Future<AuthClient> _client = _createClient();

  /// Creates the appropriate HTTP client based on emulator configuration.
  Future<AuthClient> _createClient() async {
    if (_isUsingEmulator) {
      // Emulator: Create unauthenticated client
      return EmulatorClient(Client());
    }

    // Production: Create authenticated client
    return createAuthClient(credential, [
      firestore_v1.FirestoreApi.cloudPlatformScope,
    ]);
  }

  Future<R> _run<R>(
    Future<R> Function(AuthClient client, String projectId) fn,
  ) async {
    final client = await _client;

    // Get project ID from settings or discover it
    final projectId = _settings.projectId ?? await client.getProjectId();

    _cachedProjectId = projectId;

    return _firestoreGuard(() => fn(client, projectId));
  }

  /// Executes a Firestore v1 API operation with automatic projectId injection.
  Future<R> v1<R>(
    Future<R> Function(firestore_v1.FirestoreApi api, String projectId) fn,
  ) => _run(
    (client, projectId) => fn(
      firestore_v1.FirestoreApi(client, rootUrl: _firestoreApiHost.toString()),
      projectId,
    ),
  );
}
