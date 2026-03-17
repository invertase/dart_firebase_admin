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

/// Exception thrown for Firebase app initialization and lifecycle errors.
class FirebaseAppException extends FirebaseAdminException {
  FirebaseAppException(this.errorCode, [String? message])
    : super('app', errorCode.code, message ?? errorCode.message);

  /// The error code object containing code and default message.
  final AppErrorCode errorCode;

  @override
  String toString() => 'FirebaseAppException($code): $message';
}

/// Firebase App error codes with their default messages.
enum AppErrorCode {
  /// Firebase app with the given name has already been deleted.
  appDeleted(
    code: 'app-deleted',
    message: 'The specified Firebase app has already been deleted.',
  ),

  /// Firebase app with the same name already exists.
  duplicateApp(
    code: 'duplicate-app',
    message: 'A Firebase app with the given name already exists.',
  ),

  /// Invalid argument provided to a Firebase App method.
  invalidArgument(
    code: 'invalid-argument',
    message: 'Invalid argument provided.',
  ),

  /// An internal error occurred within the Firebase SDK.
  internalError(
    code: 'internal-error',
    message: 'An internal error has occurred.',
  ),

  /// Invalid Firebase app name provided.
  invalidAppName(
    code: 'invalid-app-name',
    message: 'Invalid Firebase app name provided.',
  ),

  /// Invalid app options provided to initializeApp().
  invalidAppOptions(
    code: 'invalid-app-options',
    message: 'Invalid app options provided to initializeApp().',
  ),

  /// Invalid credential configuration.
  invalidCredential(
    code: 'invalid-credential',
    message: 'The credential configuration is invalid.',
  ),

  /// Network error occurred during the operation.
  networkError(code: 'network-error', message: 'A network error has occurred.'),

  /// Network timeout occurred during the operation.
  networkTimeout(
    code: 'network-timeout',
    message: 'The network request timed out.',
  ),

  /// No Firebase app exists with the given name.
  noApp(code: 'no-app', message: 'No Firebase app exists with the given name.'),

  /// Operation failed because a precondition was not met.
  failedPrecondition(
    code: 'failed-precondition',
    message: 'The operation failed because a precondition was not met.',
  ),

  /// Unable to parse the server response.
  unableToParseResponse(
    code: 'unable-to-parse-response',
    message: 'Unable to parse the response from the server.',
  );

  const AppErrorCode({required this.code, required this.message});

  /// The error code string identifier.
  final String code;

  /// The default error message for this error code.
  final String message;
}
