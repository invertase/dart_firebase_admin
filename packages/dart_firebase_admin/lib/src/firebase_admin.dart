part of 'app.dart';

/// Root Firebase Admin SDK instance that manages Firebase app instances.
class FirebaseAdmin {
  FirebaseAdmin._();

  static final FirebaseAdmin instance = FirebaseAdmin._();

  static const String _defaultAppName = '[DEFAULT]';

  static final Map<String, FirebaseAdminApp> _apps = {};

  /// Initializes a Firebase app instance.
  ///
  /// Creates a new instance if one doesn't exist, or returns an existing
  /// app instance if one exists with the same name and options.
  ///
  /// Throws [FirebaseAppException] if an app with the same name already
  /// exists with different options.
  ///
  /// [name] defaults to `[DEFAULT]` if not provided.
  static FirebaseAdminApp initializeApp({
    String? name,
    Client? client,
    String? projectId,
    Credential? credential,
    String? serviceAccountId,
    String? storageBucket,
  }) {
    final appName = name ?? _defaultAppName;
    _validateAppName(appName);

    // If app already exists, check if options match
    if (_apps.containsKey(appName)) {
      final existingApp = _apps[appName]!;
      if (!_optionsMatch(
        existingApp: existingApp.options,
        projectId: projectId,
        serviceAccountId: serviceAccountId,
        storageBucket: storageBucket,
        credential: credential,
      )) {
        throw FirebaseAppException(
          AppErrorCode.duplicateApp,
          'A Firebase app named "$appName" already exists with a different configuration.',
        );
      }
      return existingApp;
    }

    // Create new app
    final app = FirebaseAdminApp._(
      name: appName,
      client: client,
      projectId: projectId,
      credential: credential,
      serviceAccountId: serviceAccountId,
      storageBucket: storageBucket,
    );

    _apps[appName] = app;
    return app;
  }

  /// Returns an existing Firebase app instance.
  ///
  /// [name] defaults to `[DEFAULT]` if not provided.
  ///
  /// Throws [FirebaseAppException] if no app exists for the given name.
  FirebaseAdminApp app([String? name]) {
    final appName = name ?? _defaultAppName;
    _validateAppName(appName);

    if (!_apps.containsKey(appName)) {
      final errorMessage = appName == _defaultAppName
          ? 'The default Firebase app does not exist. '
          : 'Firebase app named "$appName" does not exist. ';
      throw FirebaseAppException(
        AppErrorCode.noApp,
        '${errorMessage}Make sure you call initializeApp() before using any of the Firebase services.',
      );
    }

    return _apps[appName]!;
  }

  /// Returns a list of all initialized Firebase app instances.
  static List<FirebaseAdminApp> getApps() => List.unmodifiable(_apps.values);

  /// Returns an existing Firebase app instance.
  ///
  /// [name] defaults to `[DEFAULT]` if not provided.
  ///
  /// Throws [FirebaseAppException] if no app exists for the given name.
  static FirebaseAdminApp getApp([String? name]) {
    final appName = name ?? _defaultAppName;
    _validateAppName(appName);

    if (!_apps.containsKey(appName)) {
      final errorMessage = appName == _defaultAppName
          ? 'The default Firebase app does not exist. '
          : 'Firebase app named "$appName" does not exist. ';
      throw FirebaseAppException(
        AppErrorCode.noApp,
        '${errorMessage}Make sure you call initializeApp() before using any of the Firebase services.',
      );
    }

    return _apps[appName]!;
  }

  /// Deletes a Firebase app instance and releases all associated resources.
  ///
  /// This method makes the app unusable and frees resources of all associated
  /// services. When running locally, this method should be called to ensure
  /// graceful termination of the process.
  ///
  /// Throws [FirebaseAppException] if the app argument is invalid or doesn't exist.
  static Future<void> deleteApp(FirebaseAdminApp app) async {
    // Validate app has required properties
    try {
      // Access name to ensure it's a valid app instance
      final appName = app.name;
      if (appName.isEmpty) {
        throw FirebaseAppException(
          AppErrorCode.invalidArgument,
          'Invalid app argument.',
        );
      }
    } catch (e) {
      throw FirebaseAppException(
        AppErrorCode.invalidArgument,
        'Invalid app argument.',
      );
    }

    // Make sure the given app already exists
    final existingApp = getApp(app.name);

    // Delegate delete operation to the App instance itself
    await existingApp.delete();
  }
}

/// Compares options to see if they match an existing app.
///
/// Note: We don't compare credentials or client as they can't be reliably
/// compared. If a credential is provided, we throw an error (matching Node.js behavior).
bool _optionsMatch({
  required AppOptions existingApp,
  String? projectId,
  String? serviceAccountId,
  String? storageBucket,
  Credential? credential,
}) {
  // If credential is explicitly provided, we can't reliably compare it
  // Node.js throws in this case, so we return false to trigger the throw
  if (credential != null) {
    return false;
  }

  // Compare projectId - must match if provided
  if (projectId != null && projectId != existingApp.projectId) {
    return false;
  }

  // Compare serviceAccountId - must match if provided
  if (serviceAccountId != null &&
      serviceAccountId != existingApp.serviceAccountId) {
    return false;
  }

  // Compare storageBucket - must match if provided
  if (storageBucket != null && storageBucket != existingApp.storageBucket) {
    return false;
  }

  // All provided options match
  return true;
}

void _validateAppName(String name) {
  if (name.isEmpty) {
    throw FirebaseAppException(
      AppErrorCode.invalidAppName,
      'App name cannot be empty.',
    );
  }
  // App name must not contain ':' character
  if (name.contains(':')) {
    throw FirebaseAppException(
      AppErrorCode.invalidAppName,
      'App name cannot contain the character ":".',
    );
  }
}
