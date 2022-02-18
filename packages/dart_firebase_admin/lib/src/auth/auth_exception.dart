part of dart_firebase_admin;

class FirebaseAuthAdminException extends FirebaseAdminException {
  FirebaseAuthAdminException._(String code, [String? message])
      : super('auth', code, message);

  factory FirebaseAuthAdminException.fromServerError(
      firebase_auth_v1.DetailedApiRequestError error) {
    final code = _authServerToClientCode(error.message) ?? 'UNKNOWN';
    return FirebaseAuthAdminException._(code, _authClientCodeMessage(code));
  }
}

String? _authClientCodeMessage(String clientCode) {
  switch (clientCode) {
    case 'BILLING_NOT_ENABLED':
      return 'Feature requires billing to be enabled.';

    case 'CLAIMS_TOO_LARGE':
      return 'Developer claims maximum payload size exceeded.';

    case 'CONFIGURATION_EXISTS':
      return 'A configuration already exists with the provided identifier.';

    case 'CONFIGURATION_NOT_FOUND':
      return 'There is no configuration corresponding to the provided identifier.';

    case 'ID_TOKEN_EXPIRED':
      return 'The provided Firebase ID token is expired.';

    case 'INVALID_ARGUMENT':
      return 'Invalid argument provided.';

    case 'INVALID_CONFIG':
      return 'The provided configuration is invalid.';

    case 'EMAIL_ALREADY_EXISTS':
      return 'The email address is already in use by another account.';

    case 'EMAIL_NOT_FOUND':
      return 'There is no user record corresponding to the provided email.';

    case 'FORBIDDEN_CLAIM':
      return 'The specified developer claim is reserved and cannot be specified.';

    case 'INVALID_ID_TOKEN':
      return 'The provided ID token is not a valid Firebase ID token.';

    case 'ID_TOKEN_REVOKED':
      return 'The Firebase ID token has been revoked.';

    case 'INTERNAL_ERROR':
      return 'An internal error has occurred.';

    case 'INVALID_CLAIMS':
      return 'The provided custom claim attributes are invalid.';

    case 'INVALID_CONTINUE_URI':
      return 'The continue URL must be a valid URL string.';

    case 'INVALID_CREATION_TIME':
      return 'The creation time must be a valid UTC date string.';

    case 'INVALID_CREDENTIAL':
      return 'Invalid credential object provided.';

    case 'INVALID_DISABLED_FIELD':
      return 'The disabled field must be a boolean.';

    case 'INVALID_DISPLAY_NAME':
      return 'The displayName field must be a valid string.';

    case 'INVALID_DYNAMIC_LINK_DOMAIN':
      return 'The provided dynamic link domain is not configured or authorized for the current project.';

    case 'INVALID_EMAIL_VERIFIED':
      return 'The emailVerified field must be a boolean.';

    case 'INVALID_EMAIL':
      return 'The email address is improperly formatted.';

    case 'INVALID_ENROLLED_FACTORS':
      return 'The enrolled factors must be a valid array of MultiFactorInfo objects.';

    case 'INVALID_ENROLLMENT_TIME':
      return 'The second factor enrollment time must be a valid UTC date string.';

    case 'INVALID_HASH_ALGORITHM':
      return 'The hash algorithm must match one of the strings in the list of supported algorithms.';

    case 'INVALID_HASH_BLOCK_SIZE':
      return 'The hash block size must be a valid number.';

    case 'INVALID_HASH_DERIVED_KEY_LENGTH':
      return 'The hash derived key length must be a valid number.';

    case 'INVALID_HASH_KEY':
      return 'The hash key must a valid byte buffer.';

    case 'INVALID_HASH_MEMORY_COST':
      return 'The hash memory cost must be a valid number.';

    case 'INVALID_HASH_PARALLELIZATION':
      return 'The hash parallelization must be a valid number.';

    case 'INVALID_HASH_ROUNDS':
      return 'The hash rounds must be a valid number.';

    case 'INVALID_HASH_SALT_SEPARATOR':
      return 'The hashing algorithm salt separator field must be a valid byte buffer.';

    case 'INVALID_LAST_SIGN_IN_TIME':
      return 'The last sign-in time must be a valid UTC date string.';

    case 'INVALID_NAME':
      return 'The resource name provided is invalid.';

    case 'INVALID_OAUTH_CLIENT_ID':
      return 'The provided OAuth client ID is invalid.';

    case 'INVALID_PAGE_TOKEN':
      return 'The page token must be a valid non-empty string.';

    case 'INVALID_PASSWORD':
      return 'The password must be a string with at least 6 characters.';

    case 'INVALID_PASSWORD_HASH':
      return 'The password hash must be a valid byte buffer.';

    case 'INVALID_PASSWORD_SALT':
      return 'The password salt must be a valid byte buffer.';

    case 'INVALID_PHONE_NUMBER':
      return 'The phone number must be a non-empty E.164 standard compliant identifier string.';

    case 'INVALID_PHOTO_URL':
      return 'The photoURL field must be a valid URL.';

    case 'INVALID_PROJECT_ID':
      return 'Invalid parent project. Either parent project doesn\'t exist or didn\'t enable multi-tenancy.';

    case 'INVALID_PROVIDER_DATA':
      return 'The providerData must be a valid array of UserInfo objects.';

    case 'INVALID_PROVIDER_ID':
      return 'The providerId must be a valid supported provider identifier string.';

    case 'INVALID_PROVIDER_UID':
      return 'The providerUid must be a valid provider uid string.';

    case 'INVALID_OAUTH_RESPONSETYPE':
      return 'Only exactly one OAuth responseType should be set to true.';

    case 'INVALID_SESSION_COOKIE_DURATION':
      return 'The session cookie duration must be a valid number in milliseconds between 5 minutes and 2 weeks.';

    case 'INVALID_TENANT_ID':
      return 'The tenant ID must be a valid non-empty string.';

    case 'INVALID_TENANT_TYPE':
      return 'Tenant type must be either "full_service" or "lightweight".';

    case 'INVALID_TESTING_PHONE_NUMBER':
      return 'Invalid testing phone number or invalid test code provided.';

    case 'INVALID_UID':
      return 'The uid must be a non-empty string with at most 128 characters.';

    case 'INVALID_USER_IMPORT':
      return 'The user record to import is invalid.';

    case 'INVALID_TOKENS_VALID_AFTER_TIME':
      return 'The tokensValidAfterTime must be a valid UTC number in seconds.';

    case 'MISMATCHING_TENANT_ID':
      return 'User tenant ID does not match with the current TenantAwareAuth tenant ID.';

    case 'MISSING_ANDROID_PACKAGE_NAME':
      return 'An Android Package Name must be provided if the Android App is required to be installed.';

    case 'MISSING_CONFIG':
      return 'The provided configuration is missing required attributes.';

    case 'MISSING_CONTINUE_URI':
      return 'A valid continue URL must be provided in the request.';

    case 'MISSING_DISPLAY_NAME':
      return 'The resource being created or edited is missing a valid display name.';

    case 'MISSING_EMAIL':
      return 'The email is required for the specified action. For example, a multi-factor user requires a verified email.';

    case 'MISSING_IOS_BUNDLE_ID':
      return 'The request is missing an iOS Bundle ID.';

    case 'MISSING_ISSUER':
      return 'The OAuth/OIDC configuration issuer must not be empty.';

    case 'MISSING_HASH_ALGORITHM':
      return 'Importing users with password hashes requires that the hashing algorithm and its parameters be provided.';

    case 'MISSING_OAUTH_CLIENT_ID':
      return 'The OAuth/OIDC configuration client ID must not be empty.';

    case 'MISSING_OAUTH_CLIENT_SECRET':
      return 'The OAuth configuration client secret is required to enable OIDC code flow.';

    case 'MISSING_PROVIDER_ID':
      return 'A valid provider ID must be provided in the request.';

    case 'MISSING_SAML_RELYING_PARTY_CONFIG':
      return 'The SAML configuration provided is missing a relying party configuration.';

    case 'MAXIMUM_TEST_PHONE_NUMBER_EXCEEDED':
      return 'The maximum allowed number of test phone number / code pairs has been exceeded.';

    case 'MAXIMUM_USER_COUNT_EXCEEDED':
      return 'The maximum allowed number of users to import has been exceeded.';

    case 'MISSING_UID':
      return 'A uid identifier is required for the current operation.';

    case 'OPERATION_NOT_ALLOWED':
      return 'The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.';

    case 'PHONE_NUMBER_ALREADY_EXISTS':
      return 'The user with the provided phone number already exists.';

    case 'PROJECT_NOT_FOUND':
      return 'No Firebase project was found for the provided credential.';

    case 'INSUFFICIENT_PERMISSION':
      return 'Credential implementation provided to initializeApp() via the "credential" property  has insufficient permission to access the requested resource. See https://firebase.google.com/docs/admin/setup for details on how to authenticate this SDK with appropriate permissions.';

    case 'QUOTA_EXCEEDED':
      return 'The project quota for the specified operation has been exceeded.';

    case 'SECOND_FACTOR_LIMIT_EXCEEDED':
      return 'The maximum number of allowed second factors on a user has been exceeded.';

    case 'SECOND_FACTOR_UID_ALREADY_EXISTS':
      return 'The specified second factor "uid" already exists.';

    case 'SESSION_COOKIE_EXPIRED':
      return 'The Firebase session cookie is expired.';

    case 'SESSION_COOKIE_REVOKED':
      return 'The Firebase session cookie has been revoked.';

    case 'TENANT_NOT_FOUND':
      return 'There is no tenant corresponding to the provided identifier.';

    case 'UID_ALREADY_EXISTS':
      return 'The user with the provided uid already exists.';

    case 'UNAUTHORIZED_DOMAIN':
      return 'The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.';

    case 'UNSUPPORTED_FIRST_FACTOR':
      return 'A multi-factor user requires a supported first factor.';

    case 'UNSUPPORTED_SECOND_FACTOR':
      return 'The request specified an unsupported type of second factor.';

    case 'UNSUPPORTED_TENANT_OPERATION':
      return 'This operation is not supported in a multi-tenant context.';

    case 'UNVERIFIED_EMAIL':
      return 'A verified email is required for the specified action. For example, a multi-factor user requires a verified email.';

    case 'USER_NOT_FOUND':
      return 'There is no user record corresponding to the provided identifier.';

    case 'NOT_FOUND':
      return 'The requested resource was not found.';

    case 'USER_DISABLED':
      return 'The user record is disabled.';

    case 'USER_NOT_DISABLED':
      return 'The user must be disabled in order to bulk delete it (or you must pass force=true).';
  }
}

String? _authServerToClientCode(String? serverCode) {
  switch (serverCode) {
    case 'BILLING_NOT_ENABLED':
      return 'BILLING_NOT_ENABLED';

    /// Claims payload is too large.
    case 'CLAIMS_TOO_LARGE':
      return 'CLAIMS_TOO_LARGE';

    /// Configuration being added already exists.
    case 'CONFIGURATION_EXISTS':
      return 'CONFIGURATION_EXISTS';

    /// Configuration not found.
    case 'CONFIGURATION_NOT_FOUND':
      return 'CONFIGURATION_NOT_FOUND';

    /// Provided credential has insufficient permissions.
    case 'INSUFFICIENT_PERMISSION':
      return 'INSUFFICIENT_PERMISSION';

    /// Provided configuration has invalid fields.
    case 'INVALID_CONFIG':
      return 'INVALID_CONFIG';

    /// Provided configuration identifier is invalid.
    case 'INVALID_CONFIG_ID':
      return 'INVALID_PROVIDER_ID';

    /// ActionCodeSettings missing continue URL.
    case 'INVALID_CONTINUE_URI':
      return 'INVALID_CONTINUE_URI';

    /// Dynamic link domain in provided ActionCodeSettings is not authorized.
    case 'INVALID_DYNAMIC_LINK_DOMAIN':
      return 'INVALID_DYNAMIC_LINK_DOMAIN';

    /// uploadAccount provides an email that already exists.
    case 'DUPLICATE_EMAIL':
      return 'EMAIL_ALREADY_EXISTS';

    /// uploadAccount provides a localId that already exists.
    case 'DUPLICATE_LOCAL_ID':
      return 'UID_ALREADY_EXISTS';

    /// Request specified a multi-factor enrollment ID that already exists.
    case 'DUPLICATE_MFA_ENROLLMENT_ID':
      return 'SECOND_FACTOR_UID_ALREADY_EXISTS';

    /// setAccountInfo email already exists.
    case 'EMAIL_EXISTS':
      return 'EMAIL_ALREADY_EXISTS';

    /// accounts:sendOobCode for password reset when user is not found.
    case 'EMAIL_NOT_FOUND':
      return 'EMAIL_NOT_FOUND';

    /// Reserved claim name.
    case 'FORBIDDEN_CLAIM':
      return 'FORBIDDEN_CLAIM';

    /// Invalid claims provided.
    case 'INVALID_CLAIMS':
      return 'INVALID_CLAIMS';

    /// Invalid session cookie duration.
    case 'INVALID_DURATION':
      return 'INVALID_SESSION_COOKIE_DURATION';

    /// Invalid email provided.
    case 'INVALID_EMAIL':
      return 'INVALID_EMAIL';

    /// Invalid tenant display name. This can be thrown on CreateTenant and UpdateTenant.
    case 'INVALID_DISPLAY_NAME':
      return 'INVALID_DISPLAY_NAME';

    /// Invalid ID token provided.
    case 'INVALID_ID_TOKEN':
      return 'INVALID_ID_TOKEN';

    /// Invalid tenant/parent resource name.
    case 'INVALID_NAME':
      return 'INVALID_NAME';

    /// OIDC configuration has an invalid OAuth client ID.
    case 'INVALID_OAUTH_CLIENT_ID':
      return 'INVALID_OAUTH_CLIENT_ID';

    /// Invalid page token.
    case 'INVALID_PAGE_SELECTION':
      return 'INVALID_PAGE_TOKEN';

    /// Invalid phone number.
    case 'INVALID_PHONE_NUMBER':
      return 'INVALID_PHONE_NUMBER';

    /// Invalid agent project. Either agent project doesn't exist or didn't enable multi-tenancy.
    case 'INVALID_PROJECT_ID':
      return 'INVALID_PROJECT_ID';

    /// Invalid provider ID.
    case 'INVALID_PROVIDER_ID':
      return 'INVALID_PROVIDER_ID';

    /// Invalid service account.
    case 'INVALID_SERVICE_ACCOUNT':
      return 'INVALID_SERVICE_ACCOUNT';

    /// Invalid testing phone number.
    case 'INVALID_TESTING_PHONE_NUMBER':
      return 'INVALID_TESTING_PHONE_NUMBER';

    /// Invalid tenant type.
    case 'INVALID_TENANT_TYPE':
      return 'INVALID_TENANT_TYPE';

    /// Missing Android package name.
    case 'MISSING_ANDROID_PACKAGE_NAME':
      return 'MISSING_ANDROID_PACKAGE_NAME';

    /// Missing configuration.
    case 'MISSING_CONFIG':
      return 'MISSING_CONFIG';

    /// Missing configuration identifier.
    case 'MISSING_CONFIG_ID':
      return 'MISSING_PROVIDER_ID';

    /// Missing tenant display name: This can be thrown on CreateTenant and UpdateTenant.
    case 'MISSING_DISPLAY_NAME':
      return 'MISSING_DISPLAY_NAME';

    /// Email is required for the specified action. For example a multi-factor user requires
    /// a verified email.
    case 'MISSING_EMAIL':
      return 'MISSING_EMAIL';

    /// Missing iOS bundle ID.
    case 'MISSING_IOS_BUNDLE_ID':
      return 'MISSING_IOS_BUNDLE_ID';

    /// Missing OIDC issuer.
    case 'MISSING_ISSUER':
      return 'MISSING_ISSUER';

    /// No localId provided (deleteAccount missing localId).
    case 'MISSING_LOCAL_ID':
      return 'MISSING_UID';

    /// OIDC configuration is missing an OAuth client ID.
    case 'MISSING_OAUTH_CLIENT_ID':
      return 'MISSING_OAUTH_CLIENT_ID';

    /// Missing provider ID.
    case 'MISSING_PROVIDER_ID':
      return 'MISSING_PROVIDER_ID';

    /// Missing SAML RP config.
    case 'MISSING_SAML_RELYING_PARTY_CONFIG':
      return 'MISSING_SAML_RELYING_PARTY_CONFIG';

    /// Empty user list in uploadAccount.
    case 'MISSING_USER_ACCOUNT':
      return 'MISSING_UID';

    /// Password auth disabled in console.
    case 'OPERATION_NOT_ALLOWED':
      return 'OPERATION_NOT_ALLOWED';

    /// Provided credential has insufficient permissions.
    case 'PERMISSION_DENIED':
      return 'INSUFFICIENT_PERMISSION';

    /// Phone number already exists.
    case 'PHONE_NUMBER_EXISTS':
      return 'PHONE_NUMBER_ALREADY_EXISTS';

    /// Project not found.
    case 'PROJECT_NOT_FOUND':
      return 'PROJECT_NOT_FOUND';

    /// In multi-tenancy context: project creation quota exceeded.
    case 'QUOTA_EXCEEDED':
      return 'QUOTA_EXCEEDED';

    /// Currently only 5 second factors can be set on the same user.
    case 'SECOND_FACTOR_LIMIT_EXCEEDED':
      return 'SECOND_FACTOR_LIMIT_EXCEEDED';

    /// Tenant not found.
    case 'TENANT_NOT_FOUND':
      return 'TENANT_NOT_FOUND';

    /// Tenant ID mismatch.
    case 'TENANT_ID_MISMATCH':
      return 'MISMATCHING_TENANT_ID';

    /// Token expired error.
    case 'TOKEN_EXPIRED':
      return 'ID_TOKEN_EXPIRED';

    /// Continue URL provided in ActionCodeSettings has a domain that is not whitelisted.
    case 'UNAUTHORIZED_DOMAIN':
      return 'UNAUTHORIZED_DOMAIN';

    /// A multi-factor user requires a supported first factor.
    case 'UNSUPPORTED_FIRST_FACTOR':
      return 'UNSUPPORTED_FIRST_FACTOR';

    /// The request specified an unsupported type of second factor.
    case 'UNSUPPORTED_SECOND_FACTOR':
      return 'UNSUPPORTED_SECOND_FACTOR';

    /// Operation is not supported in a multi-tenant context.
    case 'UNSUPPORTED_TENANT_OPERATION':
      return 'UNSUPPORTED_TENANT_OPERATION';

    /// A verified email is required for the specified action. For example a multi-factor user
    /// requires a verified email.
    case 'UNVERIFIED_EMAIL':
      return 'UNVERIFIED_EMAIL';

    /// User on which action is to be performed is not found.
    case 'USER_NOT_FOUND':
      return 'USER_NOT_FOUND';

    /// User record is disabled.
    case 'USER_DISABLED':
      return 'USER_DISABLED';

    /// Password provided is too weak.
    case 'WEAK_PASSWORD':
      return 'INVALID_PASSWORD';
  }
}
