part of '../auth.dart';

class FirebaseAuthAdminException extends FirebaseAdminException
    implements Exception {
  FirebaseAuthAdminException(
    this.errorCode, [
    String? message,
  ]) : super('auth', errorCode.code, message ?? errorCode.message);

  factory FirebaseAuthAdminException.fromServerError({
    required String serverErrorCode,
    Object? rawServerResponse,
  }) {
    // serverErrorCode could contain additional details:
    // ERROR_CODE : Detailed message which can also contain colons
    final colonSeparator = serverErrorCode.indexOf(':');
    String? customMessage;
    if (colonSeparator != -1) {
      customMessage = serverErrorCode.substring(colonSeparator + 1).trim();
      serverErrorCode = serverErrorCode.substring(0, colonSeparator).trim();
    }
    // If not found, default to internal error.
    final error = authServerToClientCode[serverErrorCode] ??
        AuthClientErrorCode.internalError;
    // Server detailed message should have highest priority.
    customMessage = customMessage ?? error.message;

    if (error == AuthClientErrorCode.internalError &&
        rawServerResponse != null) {
      try {
        customMessage +=
            ' Raw server response: "${jsonEncode(rawServerResponse)}"';
      } catch (e) {
        // Ignore JSON parsing error.
      }
    }

    return FirebaseAuthAdminException(error, customMessage);
  }

  final AuthClientErrorCode errorCode;

  @override
  String toString() => 'firebaseAuthAdminException: $code: $message';
}

/// Auth server to client enum error codes.
@internal
const authServerToClientCode = {
  // Feature being configured or used requires a billing account.
  'BILLING_NOT_ENABLED': AuthClientErrorCode.billingNotEnabled,
  // Claims payload is too large.
  'CLAIMS_TOO_LARGE': AuthClientErrorCode.claimsTooLarge,
  // Configuration being added already exists.
  'CONFIGURATION_EXISTS': AuthClientErrorCode.configurationExists,
  // Configuration not found.
  'CONFIGURATION_NOT_FOUND': AuthClientErrorCode.configurationNotFound,
  // Provided credential has insufficient permissions.
  'INSUFFICIENT_PERMISSION': AuthClientErrorCode.insufficientPermission,
  // Provided configuration has invalid fields.
  'INVALID_CONFIG': AuthClientErrorCode.invalidConfig,
  // Provided configuration identifier is invalid.
  'INVALID_CONFIG_ID': AuthClientErrorCode.invalidProviderId,
  // ActionCodeSettings missing continue URL.
  'INVALID_CONTINUE_URI': AuthClientErrorCode.invalidContinueUri,
  // Dynamic link domain in provided ActionCodeSettings is not authorized.
  'INVALID_DYNAMIC_LINK_DOMAIN': AuthClientErrorCode.invalidDynamicLinkDomain,
  // uploadAccount provides an email that already exists.
  'DUPLICATE_EMAIL': AuthClientErrorCode.emailAlreadyExists,
  // uploadAccount provides a localId that already exists.
  'DUPLICATE_LOCAL_ID': AuthClientErrorCode.uidAlreadyExists,
  // Request specified a multi-factor enrollment ID that already exists.
  'DUPLICATE_MFA_ENROLLMENT_ID':
      AuthClientErrorCode.secondFactorUidAlreadyExists,
  // setAccountInfo email already exists.
  'EMAIL_EXISTS': AuthClientErrorCode.emailAlreadyExists,
  // /'accounts':sndOobCode for password reset when user is not AuthClientErrorCode.found.
  'EMAIL_NOT_FOUND': AuthClientErrorCode.emailNotFound,
  // Reserved claim name.
  'FORBIDDEN_CLAIM': AuthClientErrorCode.forbiddenClaim,
  // Invalid claims provided.
  'INVALID_CLAIMS': AuthClientErrorCode.invalidClaims,
  // Invalid session cookie duration.
  'INVALID_DURATION': AuthClientErrorCode.invalidSessionCookieDuration,
  // Invalid email provided.
  'INVALID_EMAIL': AuthClientErrorCode.invalidEmail,
  // Invalid new email provided.
  'INVALID_NEW_EMAIL': AuthClientErrorCode.invalidNewEmail,
  // Invalid tenant display name. This can be thrown on CreateTenant and UpdateTenant.
  'INVALID_DISPLAY_NAME': AuthClientErrorCode.invalidDisplayName,
  // Invalid ID token provided.
  'INVALID_ID_TOKEN': AuthClientErrorCode.invalidIdToken,
  // Invalid tenant/parent resource name.
  'INVALID_NAME': AuthClientErrorCode.invalidName,
  // OIDC configuration has an invalid OAuth client ID.
  'INVALID_OAUTH_CLIENT_ID': AuthClientErrorCode.invalidOauthClientId,
  // Invalid page token.
  'INVALID_PAGE_SELECTION': AuthClientErrorCode.invalidPageToken,
  // Invalid phone number.
  'INVALID_PHONE_NUMBER': AuthClientErrorCode.invalidPhoneNumber,
  // Invalid agent project. Either agent project doesn't exist or didn't enable multi-tenancy.
  'INVALID_PROJECT_ID': AuthClientErrorCode.invalidProjectId,
  // Invalid provider ID.
  'INVALID_PROVIDER_ID': AuthClientErrorCode.invalidProviderId,
  // Invalid testing phone number.
  'INVALID_TESTING_PHONE_NUMBER': AuthClientErrorCode.invalidTestingPhoneNumber,
  // Invalid tenant type.
  'INVALID_TENANT_TYPE': AuthClientErrorCode.invalidTenantType,
  // Missing Android package name.
  'MISSING_ANDROID_PACKAGE_NAME': AuthClientErrorCode.missingAndroidPackageName,
  // Missing configuration.
  'MISSING_CONFIG': AuthClientErrorCode.missingConfig,
  // Missing configuration identifier.
  'MISSING_CONFIG_ID': AuthClientErrorCode.missingProviderId,
  // Missing tenant display 'name': his can be thrown on CreateTenant and AuthClientErrorCode.updateTenant.
  'MISSING_DISPLAY_NAME': AuthClientErrorCode.missingDisplayName,
  // Email is required for the specified action. For example a multi-factor user requires
  // a verified email.
  'MISSING_EMAIL': AuthClientErrorCode.missingEmail,
  // Missing iOS bundle ID.
  'MISSING_IOS_BUNDLE_ID': AuthClientErrorCode.missingIosBundleId,
  // Missing OIDC issuer.
  'MISSING_ISSUER': AuthClientErrorCode.missingIssuer,
  // No localId provided (deleteAccount missing localId).
  'MISSING_LOCAL_ID': AuthClientErrorCode.missingUid,
  // OIDC configuration is missing an OAuth client ID.
  'MISSING_OAUTH_CLIENT_ID': AuthClientErrorCode.missingOauthClientId,
  // Missing provider ID.
  'MISSING_PROVIDER_ID': AuthClientErrorCode.missingProviderId,
  // Missing SAML RP config.
  'MISSING_SAML_RELYING_PARTY_CONFIG':
      AuthClientErrorCode.missingSamlRelyingPartyConfig,
  // Empty user list in uploadAccount.
  'MISSING_USER_ACCOUNT': AuthClientErrorCode.missingUid,
  // Password auth disabled in console.
  'OPERATION_NOT_ALLOWED': AuthClientErrorCode.operationNotAllowed,
  // Provided credential has insufficient permissions.
  'PERMISSION_DENIED': AuthClientErrorCode.insufficientPermission,
  // Phone number already exists.
  'PHONE_NUMBER_EXISTS': AuthClientErrorCode.phoneNumberAlreadyExists,
  // Project not found.
  'PROJECT_NOT_FOUND': AuthClientErrorCode.projectNotFound,
  // In multi-tenancy 'context': reject creation quota AuthClientErrorCode.exceed.
  'QUOTA_EXCEEDED': AuthClientErrorCode.quotaExceeded,
  // Currently only 5 second factors can be set on the same user.
  'SECOND_FACTOR_LIMIT_EXCEEDED': AuthClientErrorCode.secondFactorLimitExceeded,
  // Tenant not found.
  'TENANT_NOT_FOUND': AuthClientErrorCode.tenantNotFound,
  // Tenant ID mismatch.
  'TENANT_ID_MISMATCH': AuthClientErrorCode.mismatchingTenantId,
  // Token expired error.
  'TOKEN_EXPIRED': AuthClientErrorCode.idTokenExpired,
  // Continue URL provided in ActionCodeSettings has a domain that is not whitelisted.
  'UNAUTHORIZED_DOMAIN': AuthClientErrorCode.unauthorizedDomain,
  // A multi-factor user requires a supported first factor.
  'UNSUPPORTED_FIRST_FACTOR': AuthClientErrorCode.unsupportedFirstFactor,
  // The request specified an unsupported type of second factor.
  'UNSUPPORTED_SECOND_FACTOR': AuthClientErrorCode.unsupportedSecondFactor,
  // Operation is not supported in a multi-tenant context.
  'UNSUPPORTED_TENANT_OPERATION':
      AuthClientErrorCode.unsupportedTenantOperation,
  // A verified email is required for the specified action. For example a multi-factor user
  // requires a verified email.
  'UNVERIFIED_EMAIL': AuthClientErrorCode.unverifiedEmail,
  // User on which action is to be performed is not found.
  'USER_NOT_FOUND': AuthClientErrorCode.userNotFound,
  // User record is disabled.
  'USER_DISABLED': AuthClientErrorCode.userDisabled,
  // Password provided is too weak.
  'WEAK_PASSWORD': AuthClientErrorCode.invalidPassword,
  // Unrecognized reCAPTCHA action.
  'INVALID_RECAPTCHA_ACTION': AuthClientErrorCode.invalidRecaptchaAction,
  // Unrecognized reCAPTCHA enforcement state.
  'INVALID_RECAPTCHA_ENFORCEMENT_STATE':
      AuthClientErrorCode.invalidRecaptchaEnforcementState,
  // reCAPTCHA is not enabled for account defender.
  'RECAPTCHA_NOT_ENABLED': AuthClientErrorCode.recaptchaNotEnabled,
};

/// Auth client error codes and their default messages.
enum AuthClientErrorCode {
  authBlockingTokenExpired(
    code: 'auth-blocking-token-expired',
    message: 'The provided Firebase Auth Blocking token is expired.',
  ),
  billingNotEnabled(
    code: 'billing-not-enabled',
    message: 'Feature requires billing to be enabled.',
  ),
  claimsTooLarge(
    code: 'claims-too-large',
    message: 'Developer claims maximum payload size exceeded.',
  ),
  configurationExists(
    code: 'configuration-exists',
    message: 'A configuration already exists with the provided identifier.',
  ),
  configurationNotFound(
    code: 'configuration-not-found',
    message:
        'There is no configuration corresponding to the provided identifier.',
  ),
  idTokenExpired(
    code: 'id-token-expired',
    message: 'The provided Firebase ID token is expired.',
  ),
  invalidArgument(
    code: 'argument-error',
    message: 'Invalid argument provided.',
  ),
  invalidConfig(
    code: 'invalid-config',
    message: 'The provided configuration is invalid.',
  ),
  emailAlreadyExists(
    code: 'email-already-exists',
    message: 'The email address is already in use by another account.',
  ),
  emailNotFound(
    code: 'email-not-found',
    message: 'There is no user record corresponding to the provided email.',
  ),
  forbiddenClaim(
    code: 'reserved-claim',
    message:
        'The specified developer claim is reserved and cannot be specified.',
  ),
  invalidIdToken(
    code: 'invalid-id-token',
    message: 'The provided ID token is not a valid Firebase ID token.',
  ),
  idTokenRevoked(
    code: 'id-token-revoked',
    message: 'The Firebase ID token has been revoked.',
  ),
  internalError(
    code: 'internal-error',
    message: 'An internal error has occurred.',
  ),
  invalidClaims(
    code: 'invalid-claims',
    message: 'The provided custom claim attributes are invalid.',
  ),
  invalidContinueUri(
    code: 'invalid-continue-uri',
    message: 'The continue URL must be a valid URL string.',
  ),
  invalidCreationTime(
    code: 'invalid-creation-time',
    message: 'The creation time must be a valid UTC date string.',
  ),
  invalidCredential(
    code: 'invalid-credential',
    message: 'Invalid credential object provided.',
  ),
  invalidDisabledField(
    code: 'invalid-disabled-field',
    message: 'The disabled field must be a boolean.',
  ),
  invalidDisplayName(
    code: 'invalid-display-name',
    message: 'The displayName field must be a valid string.',
  ),
  invalidDynamicLinkDomain(
    code: 'invalid-dynamic-link-domain',
    message: 'The provided dynamic link domain is not configured or authorized '
        'for the current project.',
  ),
  invalidEmailVerified(
    code: 'invalid-email-verified',
    message: 'The emailVerified field must be a boolean.',
  ),
  invalidEmail(
    code: 'invalid-email',
    message: 'The email address is improperly formatted.',
  ),
  invalidNewEmail(
    code: 'invalid-new-email',
    message: 'The new email address is improperly formatted.',
  ),
  invalidEnrolledFactors(
    code: 'invalid-enrolled-factors',
    message:
        'The enrolled factors must be a valid array of MultiFactorInfo objects.',
  ),
  invalidEnrollmentTime(
    code: 'invalid-enrollment-time',
    message:
        'The second factor enrollment time must be a valid UTC date string.',
  ),
  invalidHashAlgorithm(
    code: 'invalid-hash-algorithm',
    message: 'The hash algorithm must match one of the strings in the list of '
        'supported algorithms.',
  ),
  invalidHashBlockSize(
    code: 'invalid-hash-block-size',
    message: 'The hash block size must be a valid number.',
  ),
  invalidHashDerivedKeyLength(
    code: 'invalid-hash-derived-key-length',
    message: 'The hash derived key length must be a valid number.',
  ),
  invalidHashKey(
    code: 'invalid-hash-key',
    message: 'The hash key must a valid byte buffer.',
  ),
  invalidHashMemoryCost(
    code: 'invalid-hash-memory-cost',
    message: 'The hash memory cost must be a valid number.',
  ),
  invalidHashParallelization(
    code: 'invalid-hash-parallelization',
    message: 'The hash parallelization must be a valid number.',
  ),
  invalidHashRounds(
    code: 'invalid-hash-rounds',
    message: 'The hash rounds must be a valid number.',
  ),
  invalidHashSaltSeparator(
    code: 'invalid-hash-salt-separator',
    message:
        'The hashing algorithm salt separator field must be a valid byte buffer.',
  ),
  invalidLastSignInTime(
    code: 'invalid-last-sign-in-time',
    message: 'The last sign-in time must be a valid UTC date string.',
  ),
  invalidName(
    code: 'invalid-name',
    message: 'The resource name provided is invalid.',
  ),
  invalidOauthClientId(
    code: 'invalid-oauth-client-id',
    message: 'The provided OAuth client ID is invalid.',
  ),
  invalidPageToken(
    code: 'invalid-page-token',
    message: 'The page token must be a valid non-empty string.',
  ),
  invalidPassword(
    code: 'invalid-password',
    message: 'The password must be a string with at least 6 characters.',
  ),
  invalidPasswordHash(
    code: 'invalid-password-hash',
    message: 'The password hash must be a valid byte buffer.',
  ),
  invalidPasswordSalt(
    code: 'invalid-password-salt',
    message: 'The password salt must be a valid byte buffer.',
  ),
  invalidPhoneNumber(
    code: 'invalid-phone-number',
    message:
        'The phone number must be a non-empty E.164 standard compliant identifier '
        'string.',
  ),
  invalidPhotoUrl(
    code: 'invalid-photo-url',
    message: 'The photoURL field must be a valid URL.',
  ),
  invalidProjectId(
    code: 'invalid-project-id',
    message: 'Invalid parent project. '
        "Either parent project doesn't exist or didn't enable multi-tenancy.",
  ),
  invalidProviderData(
    code: 'invalid-provider-data',
    message: 'The providerData must be a valid array of UserInfo objects.',
  ),
  invalidProviderId(
    code: 'invalid-provider-id',
    message:
        'The providerId must be a valid supported provider identifier string.',
  ),
  invalidProviderUid(
    code: 'invalid-provider-uid',
    message: 'The providerUid must be a valid provider uid string.',
  ),
  invalidOauthResponseType(
    code: 'invalid-oauth-responsetype',
    message: 'Only exactly one OAuth responseType should be set to true.',
  ),
  invalidSessionCookieDuration(
    code: 'invalid-session-cookie-duration',
    message:
        'The session cookie duration must be a valid number in milliseconds '
        'between 5 minutes and 2 weeks.',
  ),
  invalidTenantId(
    code: 'invalid-tenant-id',
    message: 'The tenant ID must be a valid non-empty string.',
  ),
  invalidTenantType(
    code: 'invalid-tenant-type',
    message: 'Tenant type must be either "full_service" or "lightweight".',
  ),
  invalidTestingPhoneNumber(
    code: 'invalid-testing-phone-number',
    message: 'Invalid testing phone number or invalid test code provided.',
  ),
  invalidUid(
    code: 'invalid-uid',
    message: 'The uid must be a non-empty string with at most 128 characters.',
  ),
  invalidUserImport(
    code: 'invalid-user-import',
    message: 'The user record to import is invalid.',
  ),
  invalidTokensValidAfterTime(
    code: 'invalid-tokens-valid-after-time',
    message: 'The tokensValidAfterTime must be a valid UTC number in seconds.',
  ),
  mismatchingTenantId(
    code: 'mismatching-tenant-id',
    message:
        'User tenant ID does not match with the current TenantAwareAuth tenant ID.',
  ),
  missingAndroidPackageName(
    code: 'missing-android-pkg-name',
    message: 'An Android Package Name must be provided if the Android App is '
        'required to be installed.',
  ),
  missingConfig(
    code: 'missing-config',
    message: 'The provided configuration is missing required attributes.',
  ),
  missingContinueUri(
    code: 'missing-continue-uri',
    message: 'A valid continue URL must be provided in the request.',
  ),
  missingDisplayName(
    code: 'missing-display-name',
    message:
        'The resource being created or edited is missing a valid display name.',
  ),
  missingEmail(
    code: 'missing-email',
    message:
        'The email is required for the specified action. For example, a multi-factor user '
        'requires a verified email.',
  ),
  missingIosBundleId(
    code: 'missing-ios-bundle-id',
    message: 'The request is missing an iOS Bundle ID.',
  ),
  missingIssuer(
    code: 'missing-issuer',
    message: 'The OAuth/OIDC configuration issuer must not be empty.',
  ),
  missingHashAlgorithm(
    code: 'missing-hash-algorithm',
    message: 'Importing users with password hashes requires that the hashing '
        'algorithm and its parameters be provided.',
  ),
  missingOauthClientId(
    code: 'missing-oauth-client-id',
    message: 'The OAuth/OIDC configuration client ID must not be empty.',
  ),
  missingOauthClientSecret(
    code: 'missing-oauth-client-secret',
    message:
        'The OAuth configuration client secret is required to enable OIDC code flow.',
  ),
  missingProviderId(
    code: 'missing-provider-id',
    message: 'A valid provider ID must be provided in the request.',
  ),
  missingSamlRelyingPartyConfig(
    code: 'missing-saml-relying-party-config',
    message:
        'The SAML configuration provided is missing a relying party configuration.',
  ),
  maximumTestPhoneNumberExceeded(
    code: 'test-phone-number-limit-exceeded',
    message:
        'The maximum allowed number of test phone number / code pairs has been exceeded.',
  ),
  maximumUserCountExceeded(
    code: 'maximum-user-count-exceeded',
    message: 'The maximum allowed number of users to import has been exceeded.',
  ),
  missingUid(
    code: 'missing-uid',
    message: 'A uid identifier is required for the current operation.',
  ),
  operationNotAllowed(
    code: 'operation-not-allowed',
    message:
        'The given sign-in provider is disabled for this Firebase project. '
        'Enable it in the Firebase console, under the sign-in method tab of the '
        'Auth section.',
  ),
  phoneNumberAlreadyExists(
    code: 'phone-number-already-exists',
    message: 'The user with the provided phone number already exists.',
  ),
  projectNotFound(
    code: 'project-not-found',
    message: 'No Firebase project was found for the provided credential.',
  ),
  insufficientPermission(
    code: 'insufficient-permission',
    message:
        'Credential implementation provided to initializeApp() via the "credential" property '
        'has insufficient permission to access the requested resource. See '
        'https://firebase.google.com/docs/admin/setup for details on how to authenticate this SDK '
        'with appropriate permissions.',
  ),
  quotaExceeded(
    code: 'quota-exceeded',
    message: 'The project quota for the specified operation has been exceeded.',
  ),
  secondFactorLimitExceeded(
    code: 'second-factor-limit-exceeded',
    message:
        'The maximum number of allowed second factors on a user has been exceeded.',
  ),
  secondFactorUidAlreadyExists(
    code: 'second-factor-uid-already-exists',
    message: 'The specified second factor "uid" already exists.',
  ),
  sessionCookieExpired(
    code: 'session-cookie-expired',
    message: 'The Firebase session cookie is expired.',
  ),
  sessionCookieRevoked(
    code: 'session-cookie-revoked',
    message: 'The Firebase session cookie has been revoked.',
  ),
  tenantNotFound(
    code: 'tenant-not-found',
    message: 'There is no tenant corresponding to the provided identifier.',
  ),
  uidAlreadyExists(
    code: 'uid-already-exists',
    message: 'The user with the provided uid already exists.',
  ),
  unauthorizedDomain(
    code: 'unauthorized-continue-uri',
    message:
        'The domain of the continue URL is not whitelisted. Whitelist the domain in the '
        'Firebase console.',
  ),
  unsupportedFirstFactor(
    code: 'unsupported-first-factor',
    message: 'A multi-factor user requires a supported first factor.',
  ),
  unsupportedSecondFactor(
    code: 'unsupported-second-factor',
    message: 'The request specified an unsupported type of second factor.',
  ),
  unsupportedTenantOperation(
    code: 'unsupported-tenant-operation',
    message: 'This operation is not supported in a multi-tenant context.',
  ),
  unverifiedEmail(
    code: 'unverified-email',
    message:
        'A verified email is required for the specified action. For example, a multi-factor user '
        'requires a verified email.',
  ),
  userNotFound(
    code: 'user-not-found',
    message:
        'There is no user record corresponding to the provided identifier.',
  ),
  notFound(
    code: 'not-found',
    message: 'The requested resource was not found.',
  ),
  userDisabled(
    code: 'user-disabled',
    message: 'The user record is disabled.',
  ),
  userNotDisabled(
    code: 'user-not-disabled',
    message:
        'The user must be disabled in order to bulk delete it (or you must pass force=true).',
  ),
  invalidRecaptchaAction(
    code: 'invalid-recaptcha-action',
    message: 'reCAPTCHA action must be "BLOCK".',
  ),
  invalidRecaptchaEnforcementState(
    code: 'invalid-recaptcha-enforcement-state',
    message:
        'reCAPTCHA enforcement state must be either "OFF", "AUDIT" or "ENFORCE".',
  ),
  recaptchaNotEnabled(
    code: 'recaptcha-not-enabled',
    message: 'reCAPTCHA enterprise is not enabled.',
  );

  const AuthClientErrorCode({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}

/// A generic guard wrapper for API calls to handle exceptions.
R _authGuard<R>(R Function() cb) {
  try {
    final value = cb();

    if (value is Future) {
      return value.catchError(_handleException) as R;
    }

    return value;
  } catch (error, stackTrace) {
    _handleException(error, stackTrace);
  }
}

/// Converts a Exception to a FirebaseAdminException.
Never _handleException(Object exception, StackTrace stackTrace) {
  if (exception is auth1.DetailedApiRequestError) {
    Error.throwWithStackTrace(
      FirebaseAuthAdminException.fromServerError(
        serverErrorCode: exception.message ?? '',
        rawServerResponse: exception.jsonResponse,
      ),
      stackTrace,
    );
  }

  Error.throwWithStackTrace(exception, stackTrace);
}
