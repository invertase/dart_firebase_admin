// Copyright 2024 Google LLC
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

part of 'security_rules.dart';

enum FirebaseSecurityRulesErrorCode {
  alreadyExists('already-exists'),
  authenticationError('authentication-error'),
  internalError('internal-error'),
  invalidArgument('invalid-argument'),
  invalidServerResponse('invalid-server-response'),
  notFound('not-found'),
  resourceExhausted('resource-exhausted'),
  serviceUnavailable('service-unavailable'),
  unknownError('unknown-error');

  const FirebaseSecurityRulesErrorCode(this.value);
  final String value;
}

class FirebaseSecurityRulesException extends FirebaseAdminException {
  FirebaseSecurityRulesException(
    FirebaseSecurityRulesErrorCode code,
    String? message,
  ) : super(FirebaseServiceType.securityRules.name, code.value, message);
}

const _errorMapping = {
  'ALREADY_EXISTS': FirebaseSecurityRulesErrorCode.alreadyExists,
  'INVALID_ARGUMENT': FirebaseSecurityRulesErrorCode.invalidArgument,
  'NOT_FOUND': FirebaseSecurityRulesErrorCode.notFound,
  'RESOURCE_EXHAUSTED': FirebaseSecurityRulesErrorCode.resourceExhausted,
  'UNAUTHENTICATED': FirebaseSecurityRulesErrorCode.authenticationError,
  'UNKNOWN': FirebaseSecurityRulesErrorCode.unknownError,
};
