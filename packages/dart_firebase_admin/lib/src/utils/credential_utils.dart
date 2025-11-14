import 'dart:io';

import '../../dart_firebase_admin.dart';

/// Returns the Google Cloud project ID associated with a Firebase app, if it's explicitly
/// specified in either the Firebase app options, credentials or the local environment.
/// Otherwise returns null.
///
/// This matches the Node.js `getExplicitProjectId` function behavior.
String? getExplicitProjectId(FirebaseAdminApp app) {
  final options = app.options;
  
  // Priority 1: Explicitly provided in options
  if (options.projectId != null && options.projectId!.isNotEmpty) {
    return options.projectId;
  }

  final credential = app.options.credential;
  
  // Priority 2: From ServiceAccountCredential
  if (credential case ServiceAccountCredential sa) {
    return sa.projectId;
  }

  // Priority 3: From environment variables
  final env = Platform.environment;
  final projectId = env['GOOGLE_CLOUD_PROJECT'] ?? env['GCLOUD_PROJECT'];
  if (projectId != null && projectId.isNotEmpty) {
    return projectId;
  }

  return null;
}

/// Determines the Google Cloud project ID associated with a Firebase app. This method
/// first checks if a project ID is explicitly specified in either the Firebase app options,
/// credentials or the local environment in that order. If no explicit project ID is
/// configured, but the SDK has been initialized with ApplicationDefaultCredential, this
/// method attempts to discover the project ID from the local metadata service.
///
/// This matches the Node.js `findProjectId` function behavior.
Future<String?> findProjectId(FirebaseAdminApp app) async {
  final projectId = getExplicitProjectId(app);
  if (projectId != null) {
    return projectId;
  }

  final credential = app.options.credential;
  if (credential case ApplicationDefaultCredential adc) {
    return await adc.getProjectId();
  }

  return null;
}

/// Returns the service account email associated with a Firebase app, if it's explicitly
/// specified in either the Firebase app options or credentials.
/// Otherwise returns null.
///
/// This matches the Node.js `getExplicitServiceAccountEmail` function behavior.
String? getExplicitServiceAccountEmail(FirebaseAdminApp app) {
  final options = app.options;
  
  // Priority 1: Explicitly provided in options
  if (options.serviceAccountId != null && options.serviceAccountId!.isNotEmpty) {
    return options.serviceAccountId;
  }

  final credential = app.options.credential;
  
  // Priority 2: From ServiceAccountCredential
  if (credential case ServiceAccountCredential sa) {
    return sa.clientEmail;
  }

  return null;
}

/// Determines the service account email associated with a Firebase app. This method first
/// checks if a service account email is explicitly specified in either the Firebase app options,
/// credentials or the local environment in that order. If no explicit service account email is
/// configured, but the SDK has been initialized with ApplicationDefaultCredential, this
/// method attempts to discover the service account email from the local metadata service.
///
/// This matches the Node.js `findServiceAccountEmail` function behavior.
Future<String?> findServiceAccountEmail(FirebaseAdminApp app) async {
  final accountId = getExplicitServiceAccountEmail(app);
  if (accountId != null) {
    return accountId;
  }

  final credential = app.options.credential;
  if (credential case ApplicationDefaultCredential adc) {
    return await adc.getServiceAccountEmail();
  }

  return null;
}

