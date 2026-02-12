import 'dart:io';

import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:meta/meta.dart';

sealed class Credential {
  factory Credential.fromApplicationDefaultCredentials({
    String? serviceAccountId,
  }) {
    return ApplicationDefaultCredential._(serviceAccountId: serviceAccountId);
  }

  factory Credential.fromServiceAccount(File serviceAccountFile) {
    try {
      final json = serviceAccountFile.readAsStringSync();
      final credentials = googleapis_auth.ServiceAccountCredentials.fromJson(
        json,
      );
      return ServiceAccountCredential._(credentials);
    } catch (e) {
      throw ArgumentError('Failed to parse service account JSON: $e');
    }
  }

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
      throw ArgumentError('Failed to create service account credentials: $e');
    }
  }

  Credential._();

  @internal
  googleapis_auth.ServiceAccountCredentials? get serviceAccountCredentials;

  @internal
  String? get serviceAccountId;
}

@internal
final class ServiceAccountCredential extends Credential {
  ServiceAccountCredential._(this._serviceAccountCredentials) : super._() {
    if (_serviceAccountCredentials.projectId == null) {
      throw ArgumentError(
        'Service account JSON must contain a "project_id" property',
      );
    }
  }

  final googleapis_auth.ServiceAccountCredentials _serviceAccountCredentials;

  String get projectId => _serviceAccountCredentials.projectId!;

  String get clientEmail => _serviceAccountCredentials.email;

  String get privateKey => _serviceAccountCredentials.privateKey;

  @override
  googleapis_auth.ServiceAccountCredentials? get serviceAccountCredentials =>
      _serviceAccountCredentials;

  @override
  String? get serviceAccountId => _serviceAccountCredentials.email;
}

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
