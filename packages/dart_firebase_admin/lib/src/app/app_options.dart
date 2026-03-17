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

/// Configuration options for initializing a Firebase app.
///
/// Only [credential] is required. All other fields are optional and will be
/// auto-discovered or use defaults when not provided.
class AppOptions extends Equatable {
  const AppOptions({
    this.credential,
    this.projectId,
    this.databaseURL,
    this.storageBucket,
    this.serviceAccountId,
    this.httpClient,
    this.databaseAuthVariableOverride,
  });

  /// A credential used to authenticate the Admin SDK.
  ///
  /// Use one of:
  /// - [Credential.fromServiceAccount] - For service account JSON files
  /// - [Credential.fromServiceAccountParams] - For individual service account parameters
  /// - [Credential.fromApplicationDefaultCredentials] - For Application Default Credentials (ADC)
  final Credential? credential;

  /// The Firebase project ID.
  ///
  /// If not provided, will be auto-discovered from:
  /// 1. The credential (service account JSON contains project_id)
  /// 2. GOOGLE_CLOUD_PROJECT environment variable
  /// 3. GCLOUD_PROJECT environment variable
  /// 4. GCE metadata server (when running on Google Cloud)
  final String? projectId;

  /// The Realtime Database URL.
  ///
  /// Format: https://project-id.firebaseio.com
  ///
  /// Required only if using Realtime Database and the URL cannot be inferred
  /// from the project ID.
  final String? databaseURL;

  /// The Cloud Storage bucket name.
  ///
  /// Format: project-id.appspot.com (without gs:// prefix)
  ///
  /// Required only if using Cloud Storage and the bucket name differs from
  /// the default project bucket.
  final String? storageBucket;

  /// The service account email to use for operations requiring it.
  ///
  /// Format: firebase-adminsdk@project-id.iam.gserviceaccount.com
  ///
  /// If not provided, will be auto-discovered from the credential.
  final String? serviceAccountId;

  /// Custom HTTP client to use for REST API calls.
  ///
  /// This client is used by all services that make REST calls (Auth, Messaging,
  /// App Check, Security Rules, etc.).
  ///
  /// Firestore uses gRPC and does not use this HTTP client.
  ///
  /// If not provided, a default client will be created automatically.
  ///
  /// Useful for:
  /// - Testing: Inject mock HTTP clients
  /// - Proxies: Configure proxy settings
  /// - Custom timeouts: Set per-request timeouts
  /// - Connection pooling: Control connection behavior
  /// - Request/response logging
  ///
  /// Example:
  /// ```dart
  /// import 'package:googleapis_auth/auth_io.dart' as auth;
  ///
  /// final customClient = await auth.clientViaApplicationDefaultCredentials();
  /// final app = FirebaseAdminApp.initializeApp(
  ///   AppOptions(
  ///     credential: credential,
  ///     httpClient: customClient,
  ///   ),
  /// );
  /// ```
  final googleapis_auth.AuthClient? httpClient;

  /// The object to use as the auth variable in Realtime Database Rules.
  ///
  /// This allows you to downscope the Admin SDK from its default full read
  /// and write privileges.
  ///
  /// - Pass a Map to act as a specific user: `{'uid': 'user123', 'role': 'admin'}`
  /// - Pass `null` to act as an unauthenticated client
  /// - Omit this field to use default admin privileges
  ///
  /// See: https://firebase.google.com/docs/database/admin/start#authenticate-with-limited-privileges
  ///
  /// Example:
  /// ```dart
  /// // Act as a specific user
  /// final app = FirebaseAdminApp.initializeApp(
  ///   AppOptions(
  ///     credential: credential,
  ///     databaseAuthVariableOverride: {
  ///       'uid': 'user123',
  ///       'email': 'user@example.com',
  ///       'customClaims': {'role': 'admin'},
  ///     },
  ///   ),
  /// );
  ///
  /// // Act as unauthenticated
  /// final unauthApp = FirebaseAdminApp.initializeApp(
  ///   AppOptions(
  ///     credential: credential,
  ///     databaseAuthVariableOverride: null,
  ///   ),
  /// );
  /// ```
  final Map<String, dynamic>? databaseAuthVariableOverride;

  @override
  List<Object?> get props => [
    // Exclude credential and httpClient from comparison
    // (they're instances that can't be meaningfully compared)
    projectId,
    databaseURL,
    storageBucket,
    serviceAccountId,
    databaseAuthVariableOverride,
  ];
}
