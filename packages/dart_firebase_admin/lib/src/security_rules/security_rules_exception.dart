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
