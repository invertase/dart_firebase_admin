// Copyright 2026 Firebase
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

part of 'app_check.dart';

final appCheckErrorCodeMapping = <String, AppCheckErrorCode>{
  'ABORTED': AppCheckErrorCode.aborted,
  'INVALID_ARGUMENT': AppCheckErrorCode.invalidArgument,
  'INVALID_CREDENTIAL': AppCheckErrorCode.invalidCredential,
  'INTERNAL': AppCheckErrorCode.internalError,
  'PERMISSION_DENIED': AppCheckErrorCode.permissionDenied,
  'UNAUTHENTICATED': AppCheckErrorCode.unauthenticated,
  'NOT_FOUND': AppCheckErrorCode.notFound,
  'UNKNOWN': AppCheckErrorCode.unknownError,
};

enum AppCheckErrorCode {
  aborted('aborted'),
  invalidArgument('invalid-argument'),
  invalidCredential('invalid-credential'),
  internalError('internal-error'),
  permissionDenied('permission-denied'),
  unauthenticated('unauthenticated'),
  notFound('not-found'),
  appCheckTokenExpired('app-check-token-expired'),
  unknownError('unknown-error');

  const AppCheckErrorCode(this.code);

  final String code;
}

/// Firebase App Check error code structure. This extends PrefixedFirebaseError.
///
/// [code] - The error code.
/// [message] - The error message.
class FirebaseAppCheckException extends FirebaseAdminException {
  FirebaseAppCheckException(AppCheckErrorCode code, [String? message])
    : super(FirebaseServiceType.appCheck.name, code.code, message);

  factory FirebaseAppCheckException.fromJwtException(JwtException error) {
    if (error.code == JwtErrorCode.tokenExpired) {
      const errorMessage =
          'The provided App Check token has expired. Get a fresh App Check token'
          ' from your client app and try again.';
      return FirebaseAppCheckException(
        AppCheckErrorCode.appCheckTokenExpired,
        errorMessage,
      );
    } else if (error.code == JwtErrorCode.invalidSignature) {
      const errorMessage =
          'The provided App Check token has invalid signature.';
      return FirebaseAppCheckException(
        AppCheckErrorCode.invalidArgument,
        errorMessage,
      );
    } else if (error.code == JwtErrorCode.noMatchingKid) {
      const errorMessage =
          'The provided App Check token has "kid" claim which does not '
          'correspond to a known public key. Most likely the provided App Check token '
          'is expired, so get a fresh token from your client app and try again.';
      return FirebaseAppCheckException(
        AppCheckErrorCode.invalidArgument,
        errorMessage,
      );
    }
    return FirebaseAppCheckException(
      AppCheckErrorCode.invalidArgument,
      error.message,
    );
  }
}
