// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of '../app.dart';

@internal
const envSymbol = #_envSymbol;

/// Base class for Firebase Admin SDK credentials.
///
/// Create credentials using one of the factory methods:
/// - [Credential.fromServiceAccount] - For service account JSON files
/// - [Credential.fromServiceAccountParams] - For individual service account parameters
/// - [Credential.fromApplicationDefaultCredentials] - For Application Default Credentials (ADC)
///
/// The credential is used to authenticate all API calls made by the Admin SDK.
sealed class Credential {
  /// Creates a credential using Application Default Credentials (ADC).
  ///
  /// ADC attempts to find credentials in the following order:
  /// 1. [Environment.googleApplicationCredentials] environment variable (path to service account JSON)
  /// 2. Compute Engine default service account (when running on GCE)
  /// 3. Other ADC sources
  ///
  /// [serviceAccountId] can optionally be provided to override the service
  /// account email if needed for specific operations.
  factory Credential.fromApplicationDefaultCredentials({
    String? serviceAccountId,
  }) {
    return ApplicationDefaultCredential._(serviceAccountId: serviceAccountId);
  }

  /// Creates a credential from a service account JSON file.
  ///
  /// The service account file must contain:
  /// - `project_id`: The Google Cloud project ID
  /// - `private_key`: The service account private key
  /// - `client_email`: The service account email
  ///
  /// You can download service account JSON files from the Firebase Console
  /// under Project Settings > Service Accounts.
  ///
  /// Example:
  /// ```dart
  /// final credential = Credential.fromServiceAccount(
  ///   File('path/to/service-account.json'),
  /// );
  /// ```
  factory Credential.fromServiceAccount(File serviceAccountFile) {
    try {
      final json = serviceAccountFile.readAsStringSync();
      final credentials = googleapis_auth.ServiceAccountCredentials.fromJson(
        json,
      );
      return ServiceAccountCredential._(credentials);
    } catch (e) {
      throw FirebaseAppException(
        AppErrorCode.invalidCredential,
        'Failed to parse service account JSON: $e',
      );
    }
  }

  /// Creates a credential from individual service account parameters.
  ///
  /// Parameters:
  /// - [clientId]: The OAuth2 client ID (optional)
  /// - [privateKey]: The private key in PEM format
  /// - [email]: The service account email address
  /// - [projectId]: The Google Cloud project ID
  ///
  /// Example:
  /// ```dart
  /// final credential = Credential.fromServiceAccountParams(
  ///   clientId: 'client-id',
  ///   privateKey: '-----BEGIN PRIVATE KEY-----\n...',
  ///   email: 'client@example.iam.gserviceaccount.com',
  ///   projectId: 'my-project',
  /// );
  /// ```
  factory Credential.fromServiceAccountParams({
    String? clientId,
    required String privateKey,
    required String email,
    required String projectId,
  }) {
    try {
      final json = {
        'type': 'service_account',
        'project_id': projectId,
        'private_key': privateKey,
        'client_email': email,
        'client_id': clientId ?? '',
      };
      final credentials = googleapis_auth.ServiceAccountCredentials.fromJson(
        json,
      );
      return ServiceAccountCredential._(credentials);
    } catch (e) {
      throw FirebaseAppException(
        AppErrorCode.invalidCredential,
        'Failed to create service account credentials: $e',
      );
    }
  }

  /// Private constructor for sealed class.
  Credential._();

  /// Returns the underlying [googleapis_auth.ServiceAccountCredentials] if this is a
  /// [ServiceAccountCredential], null otherwise.
  @internal
  googleapis_auth.ServiceAccountCredentials? get serviceAccountCredentials;

  /// Returns the service account ID (email) if available.
  @internal
  String? get serviceAccountId;
}

/// Service account credentials for Firebase Admin SDK.
///
/// Holds [googleapis_auth.ServiceAccountCredentials] and ensures
/// the [projectId] field is present, which is required for Firebase Admin SDK operations.
@internal
final class ServiceAccountCredential extends Credential {
  ServiceAccountCredential._(this._serviceAccountCredentials) : super._() {
    // Firebase requires projectId
    if (_serviceAccountCredentials.projectId == null) {
      throw FirebaseAppException(
        AppErrorCode.invalidCredential,
        'Service account JSON must contain a "project_id" property',
      );
    }
  }

  final googleapis_auth.ServiceAccountCredentials _serviceAccountCredentials;

  /// The Google Cloud project ID associated with this service account.
  ///
  /// This is extracted from the `project_id` field in the service account JSON.
  String get projectId => _serviceAccountCredentials.projectId!;

  /// The service account email address.
  ///
  /// This is the `client_email` field from the service account JSON.
  /// Format: `firebase-adminsdk-xxxxx@project-id.iam.gserviceaccount.com`
  String get clientEmail => _serviceAccountCredentials.email;

  /// The service account private key in PEM format.
  ///
  /// This is used to sign authentication tokens for API calls.
  String get privateKey => _serviceAccountCredentials.privateKey;

  @override
  googleapis_auth.ServiceAccountCredentials? get serviceAccountCredentials =>
      _serviceAccountCredentials;

  @override
  String? get serviceAccountId => _serviceAccountCredentials.email;
}

/// Application Default Credentials for Firebase Admin SDK.
///
/// Uses Google Application Default Credentials (ADC) to automatically discover
/// credentials from the environment. ADC checks the following sources in order:
///
/// 1. [Environment.googleApplicationCredentials] environment variable pointing to a
///    service account JSON file
/// 2. **Compute Engine** default service account (when running on GCE, Cloud Run, etc.)
/// 3. Other ADC sources (gcloud CLI credentials, etc.)
///
/// This credential type is recommended for production environments as it allows
/// the same code to work across different deployment environments without
/// hardcoding credential paths.
///
/// The project ID is discovered from [google_cloud.computeProjectId].
@internal
final class ApplicationDefaultCredential extends Credential {
  ApplicationDefaultCredential._({String? serviceAccountId})
    : _serviceAccountId = serviceAccountId,
      super._();

  final String? _serviceAccountId;

  @override
  googleapis_auth.ServiceAccountCredentials? get serviceAccountCredentials =>
      null;

  @override
  String? get serviceAccountId => _serviceAccountId;
}
