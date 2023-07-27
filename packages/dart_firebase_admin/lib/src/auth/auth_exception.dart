part of dart_firebase_admin;

class FirebaseAuthAdminException extends FirebaseAdminException {
  FirebaseAuthAdminException._(String code, [String? message])
      : super('auth', code, message);

  factory FirebaseAuthAdminException.fromServerError(
      firebase_auth_v1.DetailedApiRequestError error) {
    final code =
        _authServerToClientCode(error.message) ?? AuthClientErrorCode.UNKNOWN;
    return FirebaseAuthAdminException._(code.name, code.message);
  }

  factory FirebaseAuthAdminException.fromAuthClientErrorCode(
      AuthClientErrorCode code) {
    return FirebaseAuthAdminException._(code.name, code.message);
  }

  @override
  String toString() {
    return '$runtimeType: $code: $message';
  }
}

extension AuthClientErrorCodeExtension on AuthClientErrorCode {
  String? get message => _authClientCodeMessage(this);
}

enum AuthClientErrorCode {
  UNKNOWN,
  BILLING_NOT_ENABLED,
  CLAIMS_TOO_LARGE,
  CONFIGURATION_EXISTS,
  CONFIGURATION_NOT_FOUND,
  ID_TOKEN_EXPIRED,
  INVALID_ARGUMENT,
  INVALID_CONFIG,
  EMAIL_ALREADY_EXISTS,
  EMAIL_NOT_FOUND,
  FORBIDDEN_CLAIM,
  INVALID_ID_TOKEN,
  ID_TOKEN_REVOKED,
  INTERNAL_ERROR,
  INVALID_CLAIMS,
  INVALID_CONTINUE_URI,
  INVALID_CREATION_TIME,
  INVALID_CREDENTIAL,
  INVALID_DISABLED_FIELD,
  INVALID_DISPLAY_NAME,
  INVALID_DYNAMIC_LINK_DOMAIN,
  INVALID_EMAIL_VERIFIED,
  INVALID_EMAIL,
  INVALID_ENROLLED_FACTORS,
  INVALID_ENROLLMENT_TIME,
  INVALID_HASH_ALGORITHM,
  INVALID_HASH_BLOCK_SIZE,
  INVALID_HASH_DERIVED_KEY_LENGTH,
  INVALID_HASH_KEY,
  INVALID_HASH_MEMORY_COST,
  INVALID_HASH_PARALLELIZATION,
  INVALID_HASH_ROUNDS,
  INVALID_HASH_SALT_SEPARATOR,
  INVALID_LAST_SIGN_IN_TIME,
  INVALID_NAME,
  INVALID_OAUTH_CLIENT_ID,
  INVALID_PAGE_TOKEN,
  INVALID_PASSWORD,
  INVALID_PASSWORD_HASH,
  INVALID_PASSWORD_SALT,
  INVALID_PHONE_NUMBER,
  INVALID_PHOTO_URL,
  INVALID_PROJECT_ID,
  INVALID_PROVIDER_DATA,
  INVALID_PROVIDER_ID,
  INVALID_PROVIDER_UID,
  INVALID_OAUTH_RESPONSETYPE,
  INVALID_SESSION_COOKIE_DURATION,
  INVALID_TENANT_ID,
  INVALID_TENANT_TYPE,
  INVALID_TESTING_PHONE_NUMBER,
  INVALID_UID,
  INVALID_USER_IMPORT,
  INVALID_TOKENS_VALID_AFTER_TIME,
  MISMATCHING_TENANT_ID,
  MISSING_ANDROID_PACKAGE_NAME,
  MISSING_CONFIG,
  MISSING_CONTINUE_URI,
  MISSING_DISPLAY_NAME,
  MISSING_EMAIL,
  MISSING_IOS_BUNDLE_ID,
  MISSING_ISSUER,
  MISSING_HASH_ALGORITHM,
  MISSING_OAUTH_CLIENT_ID,
  MISSING_OAUTH_CLIENT_SECRET,
  MISSING_PROVIDER_ID,
  MISSING_SAML_RELYING_PARTY_CONFIG,
  MAXIMUM_TEST_PHONE_NUMBER_EXCEEDED,
  MAXIMUM_USER_COUNT_EXCEEDED,
  MISSING_UID,
  OPERATION_NOT_ALLOWED,
  PHONE_NUMBER_ALREADY_EXISTS,
  PROJECT_NOT_FOUND,
  INSUFFICIENT_PERMISSION,
  QUOTA_EXCEEDED,
  SECOND_FACTOR_LIMIT_EXCEEDED,
  SECOND_FACTOR_UID_ALREADY_EXISTS,
  SESSION_COOKIE_EXPIRED,
  SESSION_COOKIE_REVOKED,
  TENANT_NOT_FOUND,
  UID_ALREADY_EXISTS,
  UNAUTHORIZED_DOMAIN,
  UNSUPPORTED_FIRST_FACTOR,
  UNSUPPORTED_SECOND_FACTOR,
  UNSUPPORTED_TENANT_OPERATION,
  UNVERIFIED_EMAIL,
  USER_NOT_FOUND,
  NOT_FOUND,
  USER_DISABLED,
  USER_NOT_DISABLED,
}

String? _authClientCodeMessage(AuthClientErrorCode code) {
  switch (code) {
    case AuthClientErrorCode.BILLING_NOT_ENABLED:
      return 'Feature requires billing to be enabled.';

    case AuthClientErrorCode.CLAIMS_TOO_LARGE:
      return 'Developer claims maximum payload size exceeded.';

    case AuthClientErrorCode.CONFIGURATION_EXISTS:
      return 'A configuration already exists with the provided identifier.';

    case AuthClientErrorCode.CONFIGURATION_NOT_FOUND:
      return 'There is no configuration corresponding to the provided identifier.';

    case AuthClientErrorCode.ID_TOKEN_EXPIRED:
      return 'The provided Firebase ID token is expired.';

    case AuthClientErrorCode.INVALID_ARGUMENT:
      return 'Invalid argument provided.';

    case AuthClientErrorCode.INVALID_CONFIG:
      return 'The provided configuration is invalid.';

    case AuthClientErrorCode.EMAIL_ALREADY_EXISTS:
      return 'The email address is already in use by another account.';

    case AuthClientErrorCode.EMAIL_NOT_FOUND:
      return 'There is no user record corresponding to the provided email.';

    case AuthClientErrorCode.FORBIDDEN_CLAIM:
      return 'The specified developer claim is reserved and cannot be specified.';

    case AuthClientErrorCode.INVALID_ID_TOKEN:
      return 'The provided ID token is not a valid Firebase ID token.';

    case AuthClientErrorCode.ID_TOKEN_REVOKED:
      return 'The Firebase ID token has been revoked.';

    case AuthClientErrorCode.INTERNAL_ERROR:
      return 'An internal error has occurred.';

    case AuthClientErrorCode.INVALID_CLAIMS:
      return 'The provided custom claim attributes are invalid.';

    case AuthClientErrorCode.INVALID_CONTINUE_URI:
      return 'The continue URL must be a valid URL string.';

    case AuthClientErrorCode.INVALID_CREATION_TIME:
      return 'The creation time must be a valid UTC date string.';

    case AuthClientErrorCode.INVALID_CREDENTIAL:
      return 'Invalid credential object provided.';

    case AuthClientErrorCode.INVALID_DISABLED_FIELD:
      return 'The disabled field must be a boolean.';

    case AuthClientErrorCode.INVALID_DISPLAY_NAME:
      return 'The displayName field must be a valid string.';

    case AuthClientErrorCode.INVALID_DYNAMIC_LINK_DOMAIN:
      return 'The provided dynamic link domain is not configured or authorized for the current project.';

    case AuthClientErrorCode.INVALID_EMAIL_VERIFIED:
      return 'The emailVerified field must be a boolean.';

    case AuthClientErrorCode.INVALID_EMAIL:
      return 'The email address is improperly formatted.';

    case AuthClientErrorCode.INVALID_ENROLLED_FACTORS:
      return 'The enrolled factors must be a valid array of MultiFactorInfo objects.';

    case AuthClientErrorCode.INVALID_ENROLLMENT_TIME:
      return 'The second factor enrollment time must be a valid UTC date string.';

    case AuthClientErrorCode.INVALID_HASH_ALGORITHM:
      return 'The hash algorithm must match one of the strings in the list of supported algorithms.';

    case AuthClientErrorCode.INVALID_HASH_BLOCK_SIZE:
      return 'The hash block size must be a valid number.';

    case AuthClientErrorCode.INVALID_HASH_DERIVED_KEY_LENGTH:
      return 'The hash derived key length must be a valid number.';

    case AuthClientErrorCode.INVALID_HASH_KEY:
      return 'The hash key must a valid byte buffer.';

    case AuthClientErrorCode.INVALID_HASH_MEMORY_COST:
      return 'The hash memory cost must be a valid number.';

    case AuthClientErrorCode.INVALID_HASH_PARALLELIZATION:
      return 'The hash parallelization must be a valid number.';

    case AuthClientErrorCode.INVALID_HASH_ROUNDS:
      return 'The hash rounds must be a valid number.';

    case AuthClientErrorCode.INVALID_HASH_SALT_SEPARATOR:
      return 'The hashing algorithm salt separator field must be a valid byte buffer.';

    case AuthClientErrorCode.INVALID_LAST_SIGN_IN_TIME:
      return 'The last sign-in time must be a valid UTC date string.';

    case AuthClientErrorCode.INVALID_NAME:
      return 'The resource name provided is invalid.';

    case AuthClientErrorCode.INVALID_OAUTH_CLIENT_ID:
      return 'The provided OAuth client ID is invalid.';

    case AuthClientErrorCode.INVALID_PAGE_TOKEN:
      return 'The page token must be a valid non-empty string.';

    case AuthClientErrorCode.INVALID_PASSWORD:
      return 'The password must be a string with at least 6 characters.';

    case AuthClientErrorCode.INVALID_PASSWORD_HASH:
      return 'The password hash must be a valid byte buffer.';

    case AuthClientErrorCode.INVALID_PASSWORD_SALT:
      return 'The password salt must be a valid byte buffer.';

    case AuthClientErrorCode.INVALID_PHONE_NUMBER:
      return 'The phone number must be a non-empty E.164 standard compliant identifier string.';

    case AuthClientErrorCode.INVALID_PHOTO_URL:
      return 'The photoURL field must be a valid URL.';

    case AuthClientErrorCode.INVALID_PROJECT_ID:
      return 'Invalid parent project. Either parent project doesn\'t exist or didn\'t enable multi-tenancy.';

    case AuthClientErrorCode.INVALID_PROVIDER_DATA:
      return 'The providerData must be a valid array of UserInfo objects.';

    case AuthClientErrorCode.INVALID_PROVIDER_ID:
      return 'The providerId must be a valid supported provider identifier string.';

    case AuthClientErrorCode.INVALID_PROVIDER_UID:
      return 'The providerUid must be a valid provider uid string.';

    case AuthClientErrorCode.INVALID_OAUTH_RESPONSETYPE:
      return 'Only exactly one OAuth responseType should be set to true.';

    case AuthClientErrorCode.INVALID_SESSION_COOKIE_DURATION:
      return 'The session cookie duration must be a valid number in milliseconds between 5 minutes and 2 weeks.';

    case AuthClientErrorCode.INVALID_TENANT_ID:
      return 'The tenant ID must be a valid non-empty string.';

    case AuthClientErrorCode.INVALID_TENANT_TYPE:
      return 'Tenant type must be either "full_service" or "lightweight".';

    case AuthClientErrorCode.INVALID_TESTING_PHONE_NUMBER:
      return 'Invalid testing phone number or invalid test code provided.';

    case AuthClientErrorCode.INVALID_UID:
      return 'The uid must be a non-empty string with at most 128 characters.';

    case AuthClientErrorCode.INVALID_USER_IMPORT:
      return 'The user record to import is invalid.';

    case AuthClientErrorCode.INVALID_TOKENS_VALID_AFTER_TIME:
      return 'The tokensValidAfterTime must be a valid UTC number in seconds.';

    case AuthClientErrorCode.MISMATCHING_TENANT_ID:
      return 'User tenant ID does not match with the current TenantAwareAuth tenant ID.';

    case AuthClientErrorCode.MISSING_ANDROID_PACKAGE_NAME:
      return 'An Android Package Name must be provided if the Android App is required to be installed.';

    case AuthClientErrorCode.MISSING_CONFIG:
      return 'The provided configuration is missing required attributes.';

    case AuthClientErrorCode.MISSING_CONTINUE_URI:
      return 'A valid continue URL must be provided in the request.';

    case AuthClientErrorCode.MISSING_DISPLAY_NAME:
      return 'The resource being created or edited is missing a valid display name.';

    case AuthClientErrorCode.MISSING_EMAIL:
      return 'The email is required for the specified action. For example, a multi-factor user requires a verified email.';

    case AuthClientErrorCode.MISSING_IOS_BUNDLE_ID:
      return 'The request is missing an iOS Bundle ID.';

    case AuthClientErrorCode.MISSING_ISSUER:
      return 'The OAuth/OIDC configuration issuer must not be empty.';

    case AuthClientErrorCode.MISSING_HASH_ALGORITHM:
      return 'Importing users with password hashes requires that the hashing algorithm and its parameters be provided.';

    case AuthClientErrorCode.MISSING_OAUTH_CLIENT_ID:
      return 'The OAuth/OIDC configuration client ID must not be empty.';

    case AuthClientErrorCode.MISSING_OAUTH_CLIENT_SECRET:
      return 'The OAuth configuration client secret is required to enable OIDC code flow.';

    case AuthClientErrorCode.MISSING_PROVIDER_ID:
      return 'A valid provider ID must be provided in the request.';

    case AuthClientErrorCode.MISSING_SAML_RELYING_PARTY_CONFIG:
      return 'The SAML configuration provided is missing a relying party configuration.';

    case AuthClientErrorCode.MAXIMUM_TEST_PHONE_NUMBER_EXCEEDED:
      return 'The maximum allowed number of test phone number / code pairs has been exceeded.';

    case AuthClientErrorCode.MAXIMUM_USER_COUNT_EXCEEDED:
      return 'The maximum allowed number of users to import has been exceeded.';

    case AuthClientErrorCode.MISSING_UID:
      return 'A uid identifier is required for the current operation.';

    case AuthClientErrorCode.OPERATION_NOT_ALLOWED:
      return 'The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.';

    case AuthClientErrorCode.PHONE_NUMBER_ALREADY_EXISTS:
      return 'The user with the provided phone number already exists.';

    case AuthClientErrorCode.PROJECT_NOT_FOUND:
      return 'No Firebase project was found for the provided credential.';

    case AuthClientErrorCode.INSUFFICIENT_PERMISSION:
      return 'Credential implementation provided to initializeApp() via the "credential" property  has insufficient permission to access the requested resource. See https://firebase.google.com/docs/admin/setup for details on how to authenticate this SDK with appropriate permissions.';

    case AuthClientErrorCode.QUOTA_EXCEEDED:
      return 'The project quota for the specified operation has been exceeded.';

    case AuthClientErrorCode.SECOND_FACTOR_LIMIT_EXCEEDED:
      return 'The maximum number of allowed second factors on a user has been exceeded.';

    case AuthClientErrorCode.SECOND_FACTOR_UID_ALREADY_EXISTS:
      return 'The specified second factor "uid" already exists.';

    case AuthClientErrorCode.SESSION_COOKIE_EXPIRED:
      return 'The Firebase session cookie is expired.';

    case AuthClientErrorCode.SESSION_COOKIE_REVOKED:
      return 'The Firebase session cookie has been revoked.';

    case AuthClientErrorCode.TENANT_NOT_FOUND:
      return 'There is no tenant corresponding to the provided identifier.';

    case AuthClientErrorCode.UID_ALREADY_EXISTS:
      return 'The user with the provided uid already exists.';

    case AuthClientErrorCode.UNAUTHORIZED_DOMAIN:
      return 'The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.';

    case AuthClientErrorCode.UNSUPPORTED_FIRST_FACTOR:
      return 'A multi-factor user requires a supported first factor.';

    case AuthClientErrorCode.UNSUPPORTED_SECOND_FACTOR:
      return 'The request specified an unsupported type of second factor.';

    case AuthClientErrorCode.UNSUPPORTED_TENANT_OPERATION:
      return 'This operation is not supported in a multi-tenant context.';

    case AuthClientErrorCode.UNVERIFIED_EMAIL:
      return 'A verified email is required for the specified action. For example, a multi-factor user requires a verified email.';

    case AuthClientErrorCode.USER_NOT_FOUND:
      return 'There is no user record corresponding to the provided identifier.';

    case AuthClientErrorCode.NOT_FOUND:
      return 'The requested resource was not found.';

    case AuthClientErrorCode.USER_DISABLED:
      return 'The user record is disabled.';

    case AuthClientErrorCode.USER_NOT_DISABLED:
      return 'The user must be disabled in order to bulk delete it (or you must pass force=true).';

    case AuthClientErrorCode.UNKNOWN:
    default:
      return null;
  }
}

AuthClientErrorCode? _authServerToClientCode(String? serverCode) {
  switch (serverCode) {
    case 'BILLING_NOT_ENABLED':
      return AuthClientErrorCode.BILLING_NOT_ENABLED;

    /// Claims payload is too large.
    case 'CLAIMS_TOO_LARGE':
      return AuthClientErrorCode.CLAIMS_TOO_LARGE;

    /// Configuration being added already exists.
    case 'CONFIGURATION_EXISTS':
      return AuthClientErrorCode.CONFIGURATION_EXISTS;

    /// Configuration not found.
    case 'CONFIGURATION_NOT_FOUND':
      return AuthClientErrorCode.CONFIGURATION_NOT_FOUND;

    /// Provided credential has insufficient permissions.
    case 'INSUFFICIENT_PERMISSION':
      return AuthClientErrorCode.INSUFFICIENT_PERMISSION;

    /// Provided configuration has invalid fields.
    case 'INVALID_CONFIG':
      return AuthClientErrorCode.INVALID_CONFIG;

    /// Provided configuration identifier is invalid.
    case 'INVALID_CONFIG_ID':
      return AuthClientErrorCode.INVALID_PROVIDER_ID;

    /// ActionCodeSettings missing continue URL.
    case 'INVALID_CONTINUE_URI':
      return AuthClientErrorCode.INVALID_CONTINUE_URI;

    /// Dynamic link domain in provided ActionCodeSettings is not authorized.
    case 'INVALID_DYNAMIC_LINK_DOMAIN':
      return AuthClientErrorCode.INVALID_DYNAMIC_LINK_DOMAIN;

    /// uploadAccount provides an email that already exists.
    case 'DUPLICATE_EMAIL':
      return AuthClientErrorCode.EMAIL_ALREADY_EXISTS;

    /// uploadAccount provides a localId that already exists.
    case 'DUPLICATE_LOCAL_ID':
      return AuthClientErrorCode.UID_ALREADY_EXISTS;

    /// Request specified a multi-factor enrollment ID that already exists.
    case 'DUPLICATE_MFA_ENROLLMENT_ID':
      return AuthClientErrorCode.SECOND_FACTOR_UID_ALREADY_EXISTS;

    /// setAccountInfo email already exists.
    case 'EMAIL_EXISTS':
      return AuthClientErrorCode.EMAIL_ALREADY_EXISTS;

    /// accounts:sendOobCode for password reset when user is not found.
    case 'EMAIL_NOT_FOUND':
      return AuthClientErrorCode.EMAIL_NOT_FOUND;

    /// Reserved claim name.
    case 'FORBIDDEN_CLAIM':
      return AuthClientErrorCode.FORBIDDEN_CLAIM;

    /// Invalid claims provided.
    case 'INVALID_CLAIMS':
      return AuthClientErrorCode.INVALID_CLAIMS;

    /// Invalid session cookie duration.
    case 'INVALID_DURATION':
      return AuthClientErrorCode.INVALID_SESSION_COOKIE_DURATION;

    /// Invalid email provided.
    case 'INVALID_EMAIL':
      return AuthClientErrorCode.INVALID_EMAIL;

    /// Invalid tenant display name. This can be thrown on CreateTenant and UpdateTenant.
    case 'INVALID_DISPLAY_NAME':
      return AuthClientErrorCode.INVALID_DISPLAY_NAME;

    /// Invalid ID token provided.
    case 'INVALID_ID_TOKEN':
      return AuthClientErrorCode.INVALID_ID_TOKEN;

    /// Invalid tenant/parent resource name.
    case 'INVALID_NAME':
      return AuthClientErrorCode.INVALID_NAME;

    /// OIDC configuration has an invalid OAuth client ID.
    case 'INVALID_OAUTH_CLIENT_ID':
      return AuthClientErrorCode.INVALID_OAUTH_CLIENT_ID;

    /// Invalid page token.
    case 'INVALID_PAGE_SELECTION':
      return AuthClientErrorCode.INVALID_PAGE_TOKEN;

    /// Invalid phone number.
    case 'INVALID_PHONE_NUMBER':
      return AuthClientErrorCode.INVALID_PHONE_NUMBER;

    /// Invalid agent project. Either agent project doesn't exist or didn't enable multi-tenancy.
    case 'INVALID_PROJECT_ID':
      return AuthClientErrorCode.INVALID_PROJECT_ID;

    /// Invalid provider ID.
    case 'INVALID_PROVIDER_ID':
      return AuthClientErrorCode.INVALID_PROVIDER_ID;

    /// Invalid service account.
    case 'INVALID_SERVICE_ACCOUNT':
      return AuthClientErrorCode.UNKNOWN;

    /// Invalid testing phone number.
    case 'INVALID_TESTING_PHONE_NUMBER':
      return AuthClientErrorCode.INVALID_TESTING_PHONE_NUMBER;

    /// Invalid tenant type.
    case 'INVALID_TENANT_TYPE':
      return AuthClientErrorCode.INVALID_TENANT_TYPE;

    /// Missing Android package name.
    case 'MISSING_ANDROID_PACKAGE_NAME':
      return AuthClientErrorCode.MISSING_ANDROID_PACKAGE_NAME;

    /// Missing configuration.
    case 'MISSING_CONFIG':
      return AuthClientErrorCode.MISSING_CONFIG;

    /// Missing configuration identifier.
    case 'MISSING_CONFIG_ID':
      return AuthClientErrorCode.MISSING_PROVIDER_ID;

    /// Missing tenant display name: This can be thrown on CreateTenant and UpdateTenant.
    case 'MISSING_DISPLAY_NAME':
      return AuthClientErrorCode.MISSING_DISPLAY_NAME;

    /// Email is required for the specified action. For example a multi-factor user requires
    /// a verified email.
    case 'MISSING_EMAIL':
      return AuthClientErrorCode.MISSING_EMAIL;

    /// Missing iOS bundle ID.
    case 'MISSING_IOS_BUNDLE_ID':
      return AuthClientErrorCode.MISSING_IOS_BUNDLE_ID;

    /// Missing OIDC issuer.
    case 'MISSING_ISSUER':
      return AuthClientErrorCode.MISSING_ISSUER;

    /// No localId provided (deleteAccount missing localId).
    case 'MISSING_LOCAL_ID':
      return AuthClientErrorCode.MISSING_UID;

    /// OIDC configuration is missing an OAuth client ID.
    case 'MISSING_OAUTH_CLIENT_ID':
      return AuthClientErrorCode.MISSING_OAUTH_CLIENT_ID;

    /// Missing provider ID.
    case 'MISSING_PROVIDER_ID':
      return AuthClientErrorCode.MISSING_PROVIDER_ID;

    /// Missing SAML RP config.
    case 'MISSING_SAML_RELYING_PARTY_CONFIG':
      return AuthClientErrorCode.MISSING_SAML_RELYING_PARTY_CONFIG;

    /// Empty user list in uploadAccount.
    case 'MISSING_USER_ACCOUNT':
      return AuthClientErrorCode.MISSING_UID;

    /// Password auth disabled in console.
    case 'OPERATION_NOT_ALLOWED':
      return AuthClientErrorCode.OPERATION_NOT_ALLOWED;

    /// Provided credential has insufficient permissions.
    case 'PERMISSION_DENIED':
      return AuthClientErrorCode.INSUFFICIENT_PERMISSION;

    /// Phone number already exists.
    case 'PHONE_NUMBER_EXISTS':
      return AuthClientErrorCode.PHONE_NUMBER_ALREADY_EXISTS;

    /// Project not found.
    case 'PROJECT_NOT_FOUND':
      return AuthClientErrorCode.PROJECT_NOT_FOUND;

    /// In multi-tenancy context: project creation quota exceeded.
    case 'QUOTA_EXCEEDED':
      return AuthClientErrorCode.QUOTA_EXCEEDED;

    /// Currently only 5 second factors can be set on the same user.
    case 'SECOND_FACTOR_LIMIT_EXCEEDED':
      return AuthClientErrorCode.SECOND_FACTOR_LIMIT_EXCEEDED;

    /// Tenant not found.
    case 'TENANT_NOT_FOUND':
      return AuthClientErrorCode.TENANT_NOT_FOUND;

    /// Tenant ID mismatch.
    case 'TENANT_ID_MISMATCH':
      return AuthClientErrorCode.MISMATCHING_TENANT_ID;

    /// Token expired error.
    case 'TOKEN_EXPIRED':
      return AuthClientErrorCode.ID_TOKEN_EXPIRED;

    /// Continue URL provided in ActionCodeSettings has a domain that is not whitelisted.
    case 'UNAUTHORIZED_DOMAIN':
      return AuthClientErrorCode.UNAUTHORIZED_DOMAIN;

    /// A multi-factor user requires a supported first factor.
    case 'UNSUPPORTED_FIRST_FACTOR':
      return AuthClientErrorCode.UNSUPPORTED_FIRST_FACTOR;

    /// The request specified an unsupported type of second factor.
    case 'UNSUPPORTED_SECOND_FACTOR':
      return AuthClientErrorCode.UNSUPPORTED_SECOND_FACTOR;

    /// Operation is not supported in a multi-tenant context.
    case 'UNSUPPORTED_TENANT_OPERATION':
      return AuthClientErrorCode.UNSUPPORTED_TENANT_OPERATION;

    /// A verified email is required for the specified action. For example a multi-factor user
    /// requires a verified email.
    case 'UNVERIFIED_EMAIL':
      return AuthClientErrorCode.UNVERIFIED_EMAIL;

    /// User on which action is to be performed is not found.
    case 'USER_NOT_FOUND':
      return AuthClientErrorCode.USER_NOT_FOUND;

    /// User record is disabled.
    case 'USER_DISABLED':
      return AuthClientErrorCode.USER_DISABLED;

    /// Password provided is too weak.
    case 'WEAK_PASSWORD':
      return AuthClientErrorCode.INVALID_PASSWORD;
  }

  return null;
}
