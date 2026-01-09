import 'dart:async';

import 'package:googleapis_firestore/googleapis_firestore.dart'
    as googleapis_firestore;
import 'package:meta/meta.dart';

import '../app.dart';

/// Default database ID used by Firestore
const String kDefaultDatabaseId = '(default)';

/// Firestore service for Firebase Admin SDK.
///
/// Supports multiple named databases similar to Node.js SDK.
class Firestore implements FirebaseService {
  /// Internal constructor
  Firestore._(this.app);

  /// Factory constructor that ensures singleton per app.
  @internal
  factory Firestore.internal(FirebaseApp app) {
    return app.getOrInitService(
      FirebaseServiceType.firestore.name,
      Firestore._,
    );
  }

  @override
  final FirebaseApp app;

  // Maps database IDs to Firestore delegate instances
  final Map<String, googleapis_firestore.Firestore> _databases = {};

  // Maps database IDs to their settings
  final Map<String, googleapis_firestore.Settings?> _settings = {};

  /// Gets the settings used to initialize a specific database.
  /// Returns null if the database hasn't been initialized yet.
  ///
  /// This is exposed for testing purposes to verify credential extraction.
  @visibleForTesting
  googleapis_firestore.Settings? getSettingsForDatabase(String databaseId) {
    return _settings[databaseId];
  }

  /// Gets the actual settings that would be built for a database.
  /// This calls _buildSettings without initializing the database.
  ///
  /// This is exposed for testing purposes to verify settings construction.
  @visibleForTesting
  googleapis_firestore.Settings buildSettingsForTesting(
    String databaseId,
    googleapis_firestore.Settings? userSettings,
  ) {
    return _buildSettings(databaseId, userSettings);
  }

  /// Gets or creates a Firestore instance for the specified database.
  @internal
  googleapis_firestore.Firestore getDatabase([
    String databaseId = kDefaultDatabaseId,
  ]) {
    var database = _databases[databaseId];
    if (database == null) {
      database = _initFirestore(databaseId, null);
      _databases[databaseId] = database;
      _settings[databaseId] = null;
    }
    return database;
  }

  /// Initializes a Firestore instance with specific settings.
  /// Throws if the database was already initialized with different settings.
  @internal
  googleapis_firestore.Firestore initializeDatabase(
    String databaseId,
    googleapis_firestore.Settings? settings,
  ) {
    final existingInstance = _databases[databaseId];
    if (existingInstance != null) {
      final initialSettings = _settings[databaseId];
      if (_areSettingsEqual(settings, initialSettings)) {
        return existingInstance;
      }
      throw FirebaseAppException(
        AppErrorCode.failedPrecondition,
        'app.firestore() has already been called with different settings for database "$databaseId". '
        'To avoid this error, call app.firestore() with the same settings '
        'as when it was originally called, or call app.firestore() to return the '
        'already initialized instance.',
      );
    }

    final newInstance = _initFirestore(databaseId, settings);
    _databases[databaseId] = newInstance;
    // Store user-provided settings (not built settings) for comparison
    // This allows us to detect if the user tries to reinitialize with
    // different settings
    _settings[databaseId] = settings;
    return newInstance;
  }

  /// Creates Firestore settings from the Firebase app configuration
  googleapis_firestore.Settings _buildSettings(
    String databaseId,
    googleapis_firestore.Settings? userSettings,
  ) {
    final projectId = app.projectId;
    final appCredential = app.options.credential;

    // Start with user settings or empty settings
    var settings = userSettings ?? const googleapis_firestore.Settings();

    // Extract credentials from app (if not provided by user)
    if (settings.credentials == null && settings.keyFilename == null) {
      if (appCredential is ServiceAccountCredential) {
        // Extract service account credentials
        settings = settings.copyWith(
          credentials: googleapis_firestore.Credentials(
            clientEmail: appCredential.clientEmail,
            privateKey: appCredential.privateKey,
          ),
        );
      } else if (appCredential is ApplicationDefaultCredential) {
        // Let googleapis_firestore discover ADC automatically
      } else if (appCredential != null) {
        // Unsupported credential type
        throw FirebaseAppException(
          AppErrorCode.invalidCredential,
          'Firestore requires ServiceAccountCredential or '
          'ApplicationDefaultCredential. Got: ${appCredential.runtimeType}',
        );
      }
    }

    // Set database ID
    settings = settings.copyWith(databaseId: databaseId);

    // Set project ID if available and not already set
    if (projectId != null && settings.projectId == null) {
      settings = settings.copyWith(projectId: projectId);
    }

    return settings;
  }

  googleapis_firestore.Firestore _initFirestore(
    String databaseId,
    googleapis_firestore.Settings? settings,
  ) {
    final firestoreSettings = _buildSettings(databaseId, settings);
    return googleapis_firestore.Firestore(settings: firestoreSettings);
  }

  bool _areSettingsEqual(
    googleapis_firestore.Settings? a,
    googleapis_firestore.Settings? b,
  ) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    // Compare basic fields
    if (a.projectId != b.projectId ||
        a.databaseId != b.databaseId ||
        a.host != b.host ||
        a.ssl != b.ssl ||
        a.keyFilename != b.keyFilename) {
      return false;
    }

    // Compare credentials
    final credsA = a.credentials;
    final credsB = b.credentials;

    if (credsA == null && credsB == null) return true;
    if (credsA == null || credsB == null) return false;

    // Compare credential fields
    return credsA.clientEmail == credsB.clientEmail &&
        credsA.privateKey == credsB.privateKey;
  }

  @override
  Future<void> delete() async {
    // Terminate all Firestore instances
    await Future.wait(_databases.values.map((db) => db.terminate()));
    _databases.clear();
    _settings.clear();
  }
}
