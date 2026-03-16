// Copyright 2025 Google LLC
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
