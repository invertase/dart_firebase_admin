// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:meta/meta.dart';

import 'firestore_exception.dart';

/// Base class for Firestore credentials.
///
/// Create credentials using one of the factory methods:
/// - [Credential.fromServiceAccount] - For service account JSON files
/// - [Credential.fromServiceAccountParams] - For individual service account parameters
/// - [Credential.fromApplicationDefaultCredentials] - For Application Default Credentials (ADC)
sealed class Credential {
  /// Creates a credential using Application Default Credentials (ADC).
  factory Credential.fromApplicationDefaultCredentials({
    String? serviceAccountId,
  }) {
    return ApplicationDefaultCredential._(serviceAccountId: serviceAccountId);
  }

  /// Creates a credential from a service account JSON file.
  factory Credential.fromServiceAccount(File serviceAccountFile) {
    try {
      final json = serviceAccountFile.readAsStringSync();
      final credentials = googleapis_auth.ServiceAccountCredentials.fromJson(
        json,
      );
      return ServiceAccountCredential._(credentials);
    } catch (e) {
      throw FirestoreException(
        FirestoreClientErrorCode.invalidArgument,
        'Failed to parse service account JSON: $e',
      );
    }
  }

  /// Creates a credential from individual service account parameters.
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
      throw FirestoreException(
        FirestoreClientErrorCode.invalidArgument,
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

/// Service account credentials for Firestore.
@internal
final class ServiceAccountCredential extends Credential {
  ServiceAccountCredential._(this._serviceAccountCredentials) : super._() {
    if (_serviceAccountCredentials.projectId == null) {
      throw FirestoreException(
        FirestoreClientErrorCode.invalidArgument,
        'Service account JSON must contain a "project_id" property',
      );
    }
  }

  final googleapis_auth.ServiceAccountCredentials _serviceAccountCredentials;

  /// The Google Cloud project ID associated with this service account.
  String get projectId => _serviceAccountCredentials.projectId!;

  /// The service account email address.
  String get clientEmail => _serviceAccountCredentials.email;

  /// The service account private key in PEM format.
  String get privateKey => _serviceAccountCredentials.privateKey;

  @override
  googleapis_auth.ServiceAccountCredentials? get serviceAccountCredentials =>
      _serviceAccountCredentials;

  @override
  String? get serviceAccountId => _serviceAccountCredentials.email;
}

/// Application Default Credentials for Firestore.
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
