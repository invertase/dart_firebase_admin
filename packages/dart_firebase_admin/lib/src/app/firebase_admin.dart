part of '../app.dart';

class FirebaseAdminApp {
  FirebaseAdminApp._({
    required this.name,
    Client? client,
    String? projectId,
    Credential? credential,
    String? serviceAccountId,
    String? storageBucket,
  })  : _clientOverride = client,
        options = _createAppOptions(
          credential:
              credential ?? Credential.fromApplicationDefaultCredentials(),
          projectId: projectId,
          serviceAccountId: serviceAccountId,
          storageBucket: storageBucket,
        );

  final String name;

  final AppOptions options;

  /// The ID of the Google Cloud project associated with the App.
  String? get projectId => options.projectId;

  Uri? _authApiHost;
  Uri? _firestoreApiHost;
  Uri? _tasksEmulatorHost;

  /// Creates AppOptions with automatic credential and serviceAccountId resolution.
  static AppOptions _createAppOptions({
    required Credential credential,
    String? projectId,
    String? serviceAccountId,
    String? storageBucket,
  }) {
    // Priority 1: Explicitly provided projectId
    var resolvedProjectId = projectId;

    // Priority 2: From service account credential (if we have one)
    if (resolvedProjectId == null) {
      if (credential case final ServiceAccountCredential sa) {
        resolvedProjectId = sa.projectId;
      }
    }

    // Priority 3: From environment variables (GOOGLE_CLOUD_PROJECT or GCLOUD_PROJECT)
    if (resolvedProjectId == null) {
      final env = Zone.current[envSymbol] as Map<String, String>? ??
          Platform.environment;
      resolvedProjectId = env['GOOGLE_CLOUD_PROJECT'] ?? env['GCLOUD_PROJECT'];
    }

    // Throw if projectId still cannot be determined
    if (resolvedProjectId == null || resolvedProjectId.isEmpty) {
      throw FirebaseAppException(
        AppErrorCode.invalidCredential,
        'Failed to determine project ID. Initialize the SDK with service account '
        'credentials or set project ID as an app option. Alternatively, set the '
        'GOOGLE_CLOUD_PROJECT or GCLOUD_PROJECT environment variable.',
      );
    }

    // Extract serviceAccountId from credential if not provided
    var resolvedServiceAccountId = serviceAccountId;
    if (resolvedServiceAccountId == null) {
      if (credential case final ServiceAccountCredential sa) {
        resolvedServiceAccountId = sa.clientEmail;
      } else {
        resolvedServiceAccountId = credential.serviceAccountId;
      }
    }

    return AppOptions._(
      credential: credential,
      projectId: resolvedProjectId,
      serviceAccountId: resolvedServiceAccountId,
      storageBucket: storageBucket,
    );
  }

  @internal
  bool get isUsingEmulator {
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    return env.containsKey('FIREBASE_AUTH_EMULATOR_HOST') ||
        env.containsKey('FIRESTORE_EMULATOR_HOST') ||
        env.containsKey('CLOUD_TASKS_EMULATOR_HOST');
  }

  Uri? _getEnvironmentVariableHost(String name) {
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;

    final value = env[name];

    if (value == null || value.isEmpty) {
      return null;
    }

    return Uri.http(value, '/');
  }

  @internal
  Uri get authApiHost {
    return _authApiHost ??=
        _getEnvironmentVariableHost('FIREBASE_AUTH_EMULATOR_HOST') ??
            Uri.https('identitytoolkit.googleapis.com', '/');
  }

  @internal
  Uri get firestoreApiHost {
    return _firestoreApiHost ??=
        _getEnvironmentVariableHost('FIRESTORE_EMULATOR_HOST') ??
            Uri.https('firestore.googleapis.com', '/');
  }

  @internal
  Uri get tasksEmulatorHost {
    return _tasksEmulatorHost ??=
        _getEnvironmentVariableHost('CLOUD_TASKS_EMULATOR_HOST') ??
            Uri.https('cloudfunctions.googleapis.com', '/');
  }

  @internal
  late final client = _getClient(
    [
      auth3.IdentityToolkitApi.cloudPlatformScope,
      auth3.IdentityToolkitApi.firebaseScope,
    ],
  );

  final Client? _clientOverride;

  Future<Client> _getClient(List<String> scopes) async {
    if (_clientOverride != null) {
      return _clientOverride;
    }

    if (isUsingEmulator) {
      return _EmulatorClient(Client());
    }

    final serviceAccountCredentials =
        options.credential.serviceAccountCredentials;
    final client = serviceAccountCredentials == null
        ? await auth.clientViaApplicationDefaultCredentials(scopes: scopes)
        : await auth.clientViaServiceAccount(serviceAccountCredentials, scopes);

    return client;
  }

  /// Stops the app and releases any resources associated with it.
  Future<void> close() async {
    final client = await this.client;
    client.close();
  }

  /// Deletes the Firebase app instance and removes it from the registry.
  ///
  /// This method makes the app unusable and frees resources of all associated
  /// services. It also removes the app from the FirebaseAdmin app registry.
  ///
  /// This is called by [FirebaseAdmin.deleteApp].
  @internal
  Future<void> delete() async {
    // Close and release resources
    await close();

    // Remove from registry
    FirebaseAdmin._apps.remove(name);
  }
}

final class AppOptions {
  const AppOptions._({
    required this.credential,
    required this.projectId,
    this.serviceAccountId,
    this.storageBucket,
  });

  /// A [Credential] object used to authenticate the Admin SDK.
  final Credential credential;
  // final Object? databaseAuthVariableOverride; // TODO:
  // final String? databaseURL; // TODO: Implement once database support
  // final Object? httpAgent; // TODO: Do we need this? Looks like a nodejs thing.

  /// The ID of the Google Cloud project associated with the App.
  final String projectId;

  /// The ID of the service account to be used for signing custom tokens. This can be found in the `client_email` field of a service account JSON file.
  final String? serviceAccountId;

  /// The name of the Google Cloud Storage bucket used for storing application data. Use only the bucket name without any prefixes or additions (do *not* prefix the name with "gs://").
  final String? storageBucket;
}
