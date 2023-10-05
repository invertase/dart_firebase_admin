part of '../auth.dart';

class FirebaseAuthAdminException extends FirebaseAdminException
    implements Exception {
  FirebaseAuthAdminException(
    this.errorCode, [
    String? message,
  ]) : super('auth', errorCode.name, errorCode.message ?? message);

  factory FirebaseAuthAdminException.fromServerError(
    auth1.DetailedApiRequestError error,
  ) {
    final code =
        _authServerToClientCode(error.message) ?? AuthClientErrorCode.unknown;
    return FirebaseAuthAdminException(code);
  }

  final AuthClientErrorCode errorCode;

  @override
  String toString() => 'FirebaseAuthAdminException: $code: $message';
}

/// An enum representing possible error codes.
enum AuthClientErrorCode {
  billingNotEnabled(
    'BILLING_NOT_ENABLED',
    'Feature requires billing to be enabled.',
  ),
  claimsTooLarge(
    'CLAIMS_TOO_LARGE',
    'Developer claims maximum payload size exceeded.',
  ),
  configurationExists(
    'CONFIGURATION_EXISTS',
    'A configuration already exists with the provided identifier.',
  ),
  configurationNotFound(
    'CONFIGURATION_NOT_FOUND',
    'There is no configuration corresponding to the provided identifier.',
  ),
  idTokenExpired(
    'ID_TOKEN_EXPIRED',
    'The provided Firebase ID token is expired.',
  ),
  invalidArgument('INVALID_ARGUMENT', 'Invalid argument provided.'),
  invalidConfig('INVALID_CONFIG', 'The provided configuration is invalid.'),
  emailAlreadyExists(
    'EMAIL_ALREADY_EXISTS',
    'The email address is already in use by another account.',
  ),
  emailNotFound(
    'EMAIL_NOT_FOUND',
    'There is no user record corresponding to the provided email.',
  ),
  forbiddenClaim(
    'FORBIDDEN_CLAIM',
    'The specified developer claim is reserved and cannot be specified.',
  ),
  invalidIdToken(
    'INVALID_ID_TOKEN',
    'The provided ID token is not a valid Firebase ID token.',
  ),
  idTokenRevoked('ID_TOKEN_REVOKED', 'The Firebase ID token has been revoked.'),
  internalError('INTERNAL_ERROR', 'An internal error has occurred.'),
  invalidClaims(
    'INVALID_CLAIMS',
    'The provided custom claim attributes are invalid.',
  ),
  invalidContinueUri(
    'INVALID_CONTINUE_URI',
    'The continue URL must be a valid URL string.',
  ),
  invalidCreationTime(
    'INVALID_CREATION_TIME',
    'The creation time must be a valid UTC date string.',
  ),
  invalidCredential(
    'INVALID_CREDENTIAL',
    'Invalid credential object provided.',
  ),
  invalidDisabledField(
    'INVALID_DISABLED_FIELD',
    'The disabled field must be a boolean.',
  ),
  invalidDisplayName(
    'INVALID_DISPLAY_NAME',
    'The displayName field must be a valid string.',
  ),
  invalidDynamicLinkDomain(
    'INVALID_DYNAMIC_LINK_DOMAIN',
    'The provided dynamic link domain is not configured or authorized for the current project.',
  ),
  invalidEmailVerified(
    'INVALID_EMAIL_VERIFIED',
    'The emailVerified field must be a boolean.',
  ),
  invalidEmail('INVALID_EMAIL', 'The email address is improperly formatted.'),
  invalidEnrolledFactors(
    'INVALID_ENROLLED_FACTORS',
    'The enrolled factors must be a valid array of MultiFactorInfo objects.',
  ),
  invalidEnrollmentTime(
    'INVALID_ENROLLMENT_TIME',
    'The second factor enrollment time must be a valid UTC date string.',
  ),
  invalidHashAlgorithm(
    'INVALID_HASH_ALGORITHM',
    'The hash algorithm must match one of the strings in the list of supported algorithms.',
  ),
  invalidHashBlockSize(
    'INVALID_HASH_BLOCK_SIZE',
    'The hash block size must be a valid number.',
  ),
  invalidHashDerivedKeyLength(
    'INVALID_HASH_DERIVED_KEY_LENGTH',
    'The hash derived key length must be a valid number.',
  ),
  invalidHashKey('INVALID_HASH_KEY', 'The hash key must a valid byte buffer.'),
  invalidHashMemoryCost(
    'INVALID_HASH_MEMORY_COST',
    'The hash memory cost must be a valid number.',
  ),
  invalidHashParallelization(
    'INVALID_HASH_PARALLELIZATION',
    'The hash parallelization must be a valid number.',
  ),
  invalidHashRounds(
    'INVALID_HASH_ROUNDS',
    'The hash rounds must be a valid number.',
  ),
  invalidHashSaltSeparator(
    'INVALID_HASH_SALT_SEPARATOR',
    'The hashing algorithm salt separator field must be a valid byte buffer.',
  ),
  invalidLastSignInTime(
    'INVALID_LAST_SIGN_IN_TIME',
    'The last sign-in time must be a valid UTC date string.',
  ),
  invalidName('INVALID_NAME', 'The resource name provided is invalid.'),
  invalidOauthClientId(
    'INVALID_OAUTH_CLIENT_ID',
    'The provided OAuth client ID is invalid.',
  ),
  invalidPageToken(
    'INVALID_PAGE_TOKEN',
    'The page token must be a valid non-empty string.',
  ),
  invalidPassword(
    'INVALID_PASSWORD',
    'The password must be a string with at least 6 characters.',
  ),
  invalidPasswordHash(
    'INVALID_PASSWORD_HASH',
    'The password hash must be a valid byte buffer.',
  ),
  invalidPasswordSalt(
    'INVALID_PASSWORD_SALT',
    'The password salt must be a valid byte buffer.',
  ),
  invalidPhoneNumber(
    'INVALID_PHONE_NUMBER',
    'The phone number must be a non-empty E.164 standard compliant identifier string.',
  ),
  invalidPhotoUrl(
    'INVALID_PHOTO_URL',
    'The photoURL field must be a valid URL.',
  ),
  invalidProjectId(
    'INVALID_PROJECT_ID',
    "Invalid parent project. Either parent project doesn't exist or didn't enable multi-tenancy.",
  ),
  invalidProviderData(
    'INVALID_PROVIDER_DATA',
    'The providerData must be a valid array of UserInfo objects.',
  ),
  invalidProviderId(
    'INVALID_PROVIDER_ID',
    'The providerId must be a valid supported provider identifier string.',
  ),
  invalidProviderUid(
    'INVALID_PROVIDER_UID',
    'The providerUid must be a valid provider uid string.',
  ),
  invalidOauthResponsetype(
    'INVALID_OAUTH_RESPONSETYPE',
    'Only exactly one OAuth responseType should be set to true.',
  ),
  invalidSessionCookieDuration(
    'INVALID_SESSION_COOKIE_DURATION',
    'The session cookie duration must be a valid number in milliseconds between 5 minutes and 2 weeks.',
  ),
  invalidTenantId(
    'INVALID_TENANT_ID',
    'The tenant ID must be a valid non-empty string.',
  ),
  invalidTenantType(
    'INVALID_TENANT_TYPE',
    'Tenant type must be either "full_service" or "lightweight".',
  ),
  invalidTestingPhoneNumber(
    'INVALID_TESTING_PHONE_NUMBER',
    'Invalid testing phone number or invalid test code provided.',
  ),
  invalidUid(
    'INVALID_UID',
    'The uid must be a non-empty string with at most 128 characters.',
  ),
  invalidUserImport(
    'INVALID_USER_IMPORT',
    'The user record to import is invalid.',
  ),
  invalidTokensValidAfterTime(
    'INVALID_TOKENS_VALID_AFTER_TIME',
    'The tokensValidAfterTime must be a valid UTC number in seconds.',
  ),
  mismatchingTenantId(
    'MISMATCHING_TENANT_ID',
    'User tenant ID does not match with the current TenantAwareAuth tenant ID.',
  ),
  missingAndroidPackageName(
    'MISSING_ANDROID_PACKAGE_NAME',
    'An Android Package Name must be provided if the Android App is required to be installed.',
  ),
  missingConfig(
    'MISSING_CONFIG',
    'The provided configuration is missing required attributes.',
  ),
  missingContinueUri(
    'MISSING_CONTINUE_URI',
    'A valid continue URL must be provided in the request.',
  ),
  missingDisplayName(
    'MISSING_DISPLAY_NAME',
    'The resource being created or edited is missing a valid display name.',
  ),
  missingEmail(
    'MISSING_EMAIL',
    'The email is required for the specified action. For example, a multi-factor user requires a verified email.',
  ),
  missingIosBundleId(
    'MISSING_IOS_BUNDLE_ID',
    'The request is missing an iOS Bundle ID.',
  ),
  missingIssuer(
    'MISSING_ISSUER',
    'The OAuth/OIDC configuration issuer must not be empty.',
  ),
  missingHashAlgorithm(
    'MISSING_HASH_ALGORITHM',
    'Importing users with password hashes requires that the hashing algorithm and its parameters be provided.',
  ),
  missingOauthClientId(
    'MISSING_OAUTH_CLIENT_ID',
    'The OAuth/OIDC configuration client ID must not be empty.',
  ),
  missingOauthClientSecret(
    'MISSING_OAUTH_CLIENT_SECRET',
    'The OAuth configuration client secret is required to enable OIDC code flow.',
  ),
  missingProviderId(
    'MISSING_PROVIDER_ID',
    'A valid provider ID must be provided in the request.',
  ),
  missingSamlRelyingPartyConfig(
    'MISSING_SAML_RELYING_PARTY_CONFIG',
    'The SAML configuration provided is missing a relying party configuration.',
  ),
  maximumTestPhoneNumberExceeded(
    'MAXIMUM_TEST_PHONE_NUMBER_EXCEEDED',
    'The maximum allowed number of test phone number / code pairs has been exceeded.',
  ),
  maximumUserCountExceeded(
    'MAXIMUM_USER_COUNT_EXCEEDED',
    'The maximum allowed number of users to import has been exceeded.',
  ),
  missingUid(
    'MISSING_UID',
    'A uid identifier is required for the current operation.',
  ),
  operationNotAllowed(
    'OPERATION_NOT_ALLOWED',
    'The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.',
  ),
  phoneNumberAlreadyExists(
    'PHONE_NUMBER_ALREADY_EXISTS',
    'The user with the provided phone number already exists.',
  ),
  projectNotFound(
    'PROJECT_NOT_FOUND',
    'No Firebase project was found for the provided credential.',
  ),
  insufficientPermission(
    'INSUFFICIENT_PERMISSION',
    'Credential implementation provided to initializeApp() via the "credential" property  has insufficient permission to access the requested resource. See https://firebase.google.com/docs/admin/setup for details on how to authenticate this SDK with appropriate permissions.',
  ),
  quotaExceeded(
    'QUOTA_EXCEEDED',
    'The project quota for the specified operation has been exceeded.',
  ),
  secondFactorLimitExceeded(
    'SECOND_FACTOR_LIMIT_EXCEEDED',
    'The maximum number of allowed second factors on a user has been exceeded.',
  ),
  secondFactorUidAlreadyExists(
    'SECOND_FACTOR_UID_ALREADY_EXISTS',
    'The specified second factor "uid" already exists.',
  ),
  sessionCookieExpired(
    'SESSION_COOKIE_EXPIRED',
    'The Firebase session cookie is expired.',
  ),
  sessionCookieRevoked(
    'SESSION_COOKIE_REVOKED',
    'The Firebase session cookie has been revoked.',
  ),
  tenantNotFound(
    'TENANT_NOT_FOUND',
    'There is no tenant corresponding to the provided identifier.',
  ),
  uidAlreadyExists(
    'UID_ALREADY_EXISTS',
    'The user with the provided uid already exists.',
  ),
  unauthorizedDomain(
    'UNAUTHORIZED_DOMAIN',
    'The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.',
  ),
  unsupportedFirstFactor(
    'UNSUPPORTED_FIRST_FACTOR',
    'A multi-factor user requires a supported first factor.',
  ),
  unsupportedSecondFactor(
    'UNSUPPORTED_SECOND_FACTOR',
    'The request specified an unsupported type of second factor.',
  ),
  unsupportedTenantOperation(
    'UNSUPPORTED_TENANT_OPERATION',
    'This operation is not supported in a multi-tenant context.',
  ),
  unverifiedEmail(
    'UNVERIFIED_EMAIL',
    'A verified email is required for the specified action. For example, a multi-factor user requires a verified email.',
  ),
  userNotFound(
    'USER_NOT_FOUND',
    'There is no user record corresponding to the provided identifier.',
  ),
  notFound('NOT_FOUND', 'The requested resource was not found.'),
  userDisabled('USER_DISABLED', 'The user record is disabled.'),
  userNotDisabled(
    'USER_NOT_DISABLED',
    'The user must be disabled in order to bulk delete it (or you must pass force=true).',
  ),
  unknown('UNKNOWN', null);

  const AuthClientErrorCode(this.code, this.message);

  /// The error code.
  final String code;

  /// The error message, or null if [unknown].
  final String? message;
}

AuthClientErrorCode? _authServerToClientCode(String? serverCode) {
  return AuthClientErrorCode.values.firstWhereOrNull(
    (code) => code.code == serverCode,
  );
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
      FirebaseAuthAdminException.fromServerError(exception),
      stackTrace,
    );
  }

  Error.throwWithStackTrace(exception, stackTrace);
}
