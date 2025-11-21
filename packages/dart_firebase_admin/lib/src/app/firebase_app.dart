part of '../app.dart';

/// Base class for all Firebase services.
///
/// All Firebase services (Auth, Messaging, Firestore, etc.) implement this
/// interface to enable proper lifecycle management.
///
/// Services are automatically registered with the [FirebaseApp] when first
/// accessed via factory constructors. When the app is closed via
/// [FirebaseApp.close], all registered services have their [delete] method
/// called to clean up resources.
///
/// Example implementation:
/// ```dart
/// class MyService implements FirebaseService {
///   factory MyService(FirebaseApp app) {
///     return app.getOrInitService(
///       'my-service',
///       (app) => MyService._(app),
///     ) as MyService;
///   }
///
///   MyService._(this.app);
///
///   @override
///   final FirebaseApp app;
///
///   @override
///   Future<void> delete() async {
///     // Cleanup logic here
///   }
/// }
/// ```
abstract class FirebaseService {
  FirebaseService(this.app);

  /// The Firebase app this service is associated with.
  final FirebaseApp app;

  /// Cleans up resources used by this service.
  ///
  /// This method is called automatically when [FirebaseApp.close] is called
  /// on the parent app. Services should override this to release any held
  /// resources such as:
  /// - Network connections
  /// - File handles
  /// - Cached data
  /// - Subscriptions or listeners
  Future<void> delete();
}

/// Represents a Firebase app instance.
///
/// Each app is associated with a Firebase project and has its own
/// configuration options and services.
class FirebaseApp {
  FirebaseApp({
    required this.options,
    required this.name,
    required this.wasInitializedFromEnv,
  });

  /// Initializes a Firebase app.
  ///
  /// Creates a new app instance or returns an existing one if already
  /// initialized with the same configuration.
  ///
  /// If [options] is not provided, the app will be auto-initialized from
  /// the FIREBASE_CONFIG environment variable.
  ///
  /// [name] defaults to an internal string if not specified.
  static FirebaseApp initializeApp({
    AppOptions? options,
    String? name,
  }) {
    return _defaultAppRegistry.initializeApp(
      options: options,
      name: name,
    );
  }

  /// Returns the default Firebase app instance.
  ///
  /// This is a convenience getter equivalent to `getApp()`.
  ///
  /// Throws `FirebaseAppException` if the default app has not been initialized.
  static FirebaseApp get instance => getApp();

  /// Gets an existing Firebase app by name.
  ///
  /// Returns the app with the given [name], or the default app if [name]
  /// is not provided.
  ///
  /// Throws `FirebaseAppException` if no app exists with the given name.
  static FirebaseApp getApp([String? name]) {
    return _defaultAppRegistry.getApp(name);
  }

  /// Returns a list of all initialized Firebase apps.
  static List<FirebaseApp> get apps {
    return _defaultAppRegistry.apps;
  }

  /// Deletes the specified Firebase app and cleans up its resources.
  ///
  /// Throws `FirebaseAppException` if the app does not exist.
  static Future<void> deleteApp(FirebaseApp app) {
    return _defaultAppRegistry.deleteApp(app);
  }

  /// The name of this app.
  ///
  /// The default app's name is `[DEFAULT]`.
  final String name;

  /// The configuration options for this app.
  final AppOptions options;

  /// Whether this app was initialized from environment variables.
  ///
  /// When true, indicates the app was created via `initializeApp()` without
  /// explicit options, loading config from environment instead.
  final bool wasInitializedFromEnv;

  /// Whether this app has been deleted.
  bool _isDeleted = false;

  /// Returns true if this app has been deleted.
  bool get isDeleted => _isDeleted;

  @override
  String toString() =>
      'FirebaseApp(name: $name, projectId: $projectId, wasInitializedFromEnv: $wasInitializedFromEnv, isDeleted: $_isDeleted)';

  /// Map of service name to service instance for caching.
  final Map<String, FirebaseService> _services = {};

  /// The HTTP client for this app.
  ///
  /// Uses the client from options if provided, otherwise creates a default one.
  late final Future<http.Client> _httpClient = options.httpClient != null
      ? Future.value(options.httpClient)
      : _createDefaultClient();

  Future<http.Client> _createDefaultClient() async {
    // Use proper OAuth scope constants
    final scopes = [
      auth3.IdentityToolkitApi.cloudPlatformScope,
      auth3.IdentityToolkitApi.firebaseScope,
    ];

    final serviceAccountCredentials =
        options.credential?.serviceAccountCredentials;

    // Create authenticated client using googleapis_auth
    if (serviceAccountCredentials != null) {
      return auth.clientViaServiceAccount(
        serviceAccountCredentials,
        scopes,
      );
    }

    return auth.clientViaApplicationDefaultCredentials(scopes: scopes);
  }

  /// Returns the HTTP client for this app.
  @internal
  Future<http.Client> get client => _httpClient;

  /// Returns the explicitly configured project ID, if available.
  ///
  /// This is a simple synchronous getter that returns the project ID from
  /// [AppOptions.projectId] if it was explicitly set. Returns null if not set.
  ///
  /// Services that need project ID should use their own discovery mechanism
  /// via `ProjectIdProvider.discoverProjectId()` which handles async metadata
  /// service lookup when explicit projectId is not available.
  String? get projectId => options.projectId;

  /// Gets or initializes a service for this app.
  ///
  /// Services are cached per app instance. The first call with a given [name]
  /// will invoke [init] to create the service. Subsequent calls return the
  /// cached instance.
  @internal
  FirebaseService getOrInitService(
    String name,
    FirebaseService Function(FirebaseApp) init,
  ) {
    _checkDestroyed();
    if (!_services.containsKey(name)) {
      _services[name] = init(this);
    }
    return _services[name]!;
  }

  /// Closes this app and cleans up all associated resources.
  ///
  /// This method:
  /// 1. Removes the app from the global registry
  /// 2. Calls [FirebaseService.delete] on all registered services
  /// 3. Closes the HTTP client (if it was created by the SDK)
  /// 4. Marks the app as deleted
  ///
  /// After calling this method, the app instance can no longer be used.
  /// Any subsequent calls to the app or its services will throw a
  /// `FirebaseAppException` with code 'app-deleted'.
  ///
  /// Note: If you provided a custom [AppOptions.httpClient], it will NOT
  /// be closed automatically. You are responsible for closing it.
  ///
  /// Example:
  /// ```dart
  /// final app = FirebaseApp.initializeApp(options: options);
  /// // Use app...
  /// await app.close();
  /// // App can no longer be used
  /// ```
  Future<void> close() async {
    _checkDestroyed();

    // Remove from registry
    _defaultAppRegistry.removeApp(name);

    // Delete all services
    await Future.wait(
      _services.values.map((service) {
        return service.delete();
      }),
    );

    _services.clear();

    // Only close client if we created it (not user-provided)
    if (options.httpClient == null) {
      (await _httpClient).close();
    }

    _isDeleted = true;
  }

  /// Checks if this app has been deleted and throws if so.
  void _checkDestroyed() {
    if (_isDeleted) {
      throw FirebaseAppException(
        AppErrorCode.appDeleted,
        'Firebase app "$name" has already been deleted.',
      );
    }
  }
}
