// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

part of 'storage.dart';

class FirebaseStorageAdminException extends FirebaseAdminException
    implements Exception {
  FirebaseStorageAdminException(this.errorCode, [String? message])
    : super(
        FirebaseServiceType.storage.name,
        errorCode.code,
        message ?? errorCode.message,
      );

  final StorageClientErrorCode errorCode;

  @override
  String toString() => 'FirebaseStorageAdminException: $code: $message';
}

enum StorageClientErrorCode {
  noDownloadToken(
    code: 'no-download-token',
    message:
        'No download token available. Please create one in the Firebase Console.',
  ),
  objectNotFound(
    code: 'object-not-found',
    message: 'No object exists at the desired reference.',
  ),
  internalError(
    code: 'internal-error',
    message: 'An internal error has occurred. Please retry the request.',
  );

  const StorageClientErrorCode({required this.code, required this.message});

  final String code;
  final String message;
}
