part of '../auth.dart';

class FirebaseAuthAdminException extends FirebaseAdminException
    implements Exception {
  FirebaseAuthAdminException(
    this.errorCode, [
    String? message,
  ]) : super('auth', errorCode.name, message ?? errorCode.message);

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

extension AuthClientErrorCodeExtension on AuthClientErrorCode {
  String? get message => _authClientCodeMessage(this);
}

enum AuthClientErrorCode {
  unknown,
  billingNotEnabled,
  claimsTooLarge,
  configurationExists,
  configurationNotFound,
  idTokenExpired,
  invalidArgument,
  invalidConfig,
  emailAlreadyExists,
  emailNotFound,
  forbiddenClaim,
  invalidIdToken,
  idTokenRevoked,
  internalError,
  invalidClaims,
  invalidContinueUri,
  invalidCreationTime,
  invalidCredential,
  invalidDisabledField,
  invalidDisplayName,
  invalidDynamicLinkDomain,
  invalidEmailVerified,
  invalidEmail,
  invalidEnrolledFactors,
  invalidEnrollmentTime,
  invalidHashAlgorithm,
  invalidHashBlockSize,
  invalidHashDerivedKeyLength,
  invalidHashKey,
  invalidHashMemoryCost,
  invalidHashParallelization,
  invalidHashRounds,
  invalidHashSaltSeparator,
  invalidLastSignInTime,
  invalidName,
  invalidOauthClientId,
  invalidPageToken,
  invalidPassword,
  invalidPasswordHash,
  invalidPasswordSalt,
  invalidPhoneNumber,
  invalidPhotoUrl,
  invalidProjectId,
  invalidProviderData,
  invalidProviderId,
  invalidProviderUid,
  invalidOauthResponseType,
  invalidSessionCookieDuration,
  invalidTenantId,
  invalidTenantType,
  invalidTestingPhoneNumber,
  invalidUid,
  invalidUserImport,
  invalidTokensValidAfterTime,
  mismatchingTenantId,
  missingAndroidPackageName,
  missingConfig,
  missingContinueUri,
  missingDisplayName,
  missingEmail,
  missingIosBundleId,
  missingIssuer,
  missingHashAlgorithm,
  missingOauthClientId,
  missingOauthClientSecret,
  missingProviderId,
  missingSamlRelyingPartyConfig,
  maximumTestPhoneNumberExceeded,
  maximumUserCountExceeded,
  missingUid,
  operationNotAllowed,
  phoneNumberAlreadyExists,
  projectNotFound,
  insufficientPermission,
  quotaExceeded,
  secondFactorLimitExceeded,
  secondFactorUidAlreadyExists,
  sessionCookieExpired,
  sessionCookieRevoked,
  tenantNotFound,
  uidAlreadyExists,
  unauthorizedDomain,
  unsupportedFirstFactor,
  unsupportedSecondFactor,
  unsupportedTenantOperation,
  unverifiedEmail,
  userNotFound,
  notFound,
  userDisabled,
  userNotDisabled;
}

String? _authClientCodeMessage(AuthClientErrorCode code) {
  switch (code) {
    case AuthClientErrorCode.billingNotEnabled:
      return 'Feature requires billing to be enabled.';

    case AuthClientErrorCode.claimsTooLarge:
      return 'Developer claims maximum payload size exceeded.';

    case AuthClientErrorCode.configurationExists:
      return 'A configuration already exists with the provided identifier.';

    case AuthClientErrorCode.configurationNotFound:
      return 'There is no configuration corresponding to the provided identifier.';

    case AuthClientErrorCode.idTokenExpired:
      return 'The provided Firebase ID token is expired.';

    case AuthClientErrorCode.invalidArgument:
      return 'Invalid argument provided.';

    case AuthClientErrorCode.invalidConfig:
      return 'The provided configuration is invalid.';

    case AuthClientErrorCode.emailAlreadyExists:
      return 'The email address is already in use by another account.';

    case AuthClientErrorCode.emailNotFound:
      return 'There is no user record corresponding to the provided email.';

    case AuthClientErrorCode.forbiddenClaim:
      return 'The specified developer claim is reserved and cannot be specified.';

    case AuthClientErrorCode.invalidIdToken:
      return 'The provided ID token is not a valid Firebase ID token.';

    case AuthClientErrorCode.idTokenRevoked:
      return 'The Firebase ID token has been revoked.';

    case AuthClientErrorCode.internalError:
      return 'An internal error has occurred.';

    case AuthClientErrorCode.invalidClaims:
      return 'The provided custom claim attributes are invalid.';

    case AuthClientErrorCode.invalidContinueUri:
      return 'The continue URL must be a valid URL string.';

    case AuthClientErrorCode.invalidCreationTime:
      return 'The creation time must be a valid UTC date string.';

    case AuthClientErrorCode.invalidCredential:
      return 'Invalid credential object provided.';

    case AuthClientErrorCode.invalidDisabledField:
      return 'The disabled field must be a boolean.';

    case AuthClientErrorCode.invalidDisplayName:
      return 'The displayName field must be a valid string.';

    case AuthClientErrorCode.invalidDynamicLinkDomain:
      return 'The provided dynamic link domain is not configured or authorized for the current project.';

    case AuthClientErrorCode.invalidEmailVerified:
      return 'The emailVerified field must be a boolean.';

    case AuthClientErrorCode.invalidEmail:
      return 'The email address is improperly formatted.';

    case AuthClientErrorCode.invalidEnrolledFactors:
      return 'The enrolled factors must be a valid array of MultiFactorInfo objects.';

    case AuthClientErrorCode.invalidEnrollmentTime:
      return 'The second factor enrollment time must be a valid UTC date string.';

    case AuthClientErrorCode.invalidHashAlgorithm:
      return 'The hash algorithm must match one of the strings in the list of supported algorithms.';

    case AuthClientErrorCode.invalidHashBlockSize:
      return 'The hash block size must be a valid number.';

    case AuthClientErrorCode.invalidHashDerivedKeyLength:
      return 'The hash derived key length must be a valid number.';

    case AuthClientErrorCode.invalidHashKey:
      return 'The hash key must a valid byte buffer.';

    case AuthClientErrorCode.invalidHashMemoryCost:
      return 'The hash memory cost must be a valid number.';

    case AuthClientErrorCode.invalidHashParallelization:
      return 'The hash parallelization must be a valid number.';

    case AuthClientErrorCode.invalidHashRounds:
      return 'The hash rounds must be a valid number.';

    case AuthClientErrorCode.invalidHashSaltSeparator:
      return 'The hashing algorithm salt separator field must be a valid byte buffer.';

    case AuthClientErrorCode.invalidLastSignInTime:
      return 'The last sign-in time must be a valid UTC date string.';

    case AuthClientErrorCode.invalidName:
      return 'The resource name provided is invalid.';

    case AuthClientErrorCode.invalidOauthClientId:
      return 'The provided OAuth client ID is invalid.';

    case AuthClientErrorCode.invalidPageToken:
      return 'The page token must be a valid non-empty string.';

    case AuthClientErrorCode.invalidPassword:
      return 'The password must be a string with at least 6 characters.';

    case AuthClientErrorCode.invalidPasswordHash:
      return 'The password hash must be a valid byte buffer.';

    case AuthClientErrorCode.invalidPasswordSalt:
      return 'The password salt must be a valid byte buffer.';

    case AuthClientErrorCode.invalidPhoneNumber:
      return 'The phone number must be a non-empty E.164 standard compliant identifier string.';

    case AuthClientErrorCode.invalidPhotoUrl:
      return 'The photoURL field must be a valid URL.';

    case AuthClientErrorCode.invalidProjectId:
      return "Invalid parent project. Either parent project doesn't exist or didn't enable multi-tenancy.";

    case AuthClientErrorCode.invalidProviderData:
      return 'The providerData must be a valid array of UserInfo objects.';

    case AuthClientErrorCode.invalidProviderId:
      return 'The providerId must be a valid supported provider identifier string.';

    case AuthClientErrorCode.invalidProviderUid:
      return 'The providerUid must be a valid provider uid string.';

    case AuthClientErrorCode.invalidOauthResponseType:
      return 'Only exactly one OAuth responseType should be set to true.';

    case AuthClientErrorCode.invalidSessionCookieDuration:
      return 'The session cookie duration must be a valid number in milliseconds between 5 minutes and 2 weeks.';

    case AuthClientErrorCode.invalidTenantId:
      return 'The tenant ID must be a valid non-empty string.';

    case AuthClientErrorCode.invalidTenantType:
      return 'Tenant type must be either "full_service" or "lightweight".';

    case AuthClientErrorCode.invalidTestingPhoneNumber:
      return 'Invalid testing phone number or invalid test code provided.';

    case AuthClientErrorCode.invalidUid:
      return 'The uid must be a non-empty string with at most 128 characters.';

    case AuthClientErrorCode.invalidUserImport:
      return 'The user record to import is invalid.';

    case AuthClientErrorCode.invalidTokensValidAfterTime:
      return 'The tokensValidAfterTime must be a valid UTC number in seconds.';

    case AuthClientErrorCode.mismatchingTenantId:
      return 'User tenant ID does not match with the current TenantAwareAuth tenant ID.';

    case AuthClientErrorCode.missingAndroidPackageName:
      return 'An Android Package Name must be provided if the Android App is required to be installed.';

    case AuthClientErrorCode.missingConfig:
      return 'The provided configuration is missing required attributes.';

    case AuthClientErrorCode.missingContinueUri:
      return 'A valid continue URL must be provided in the request.';

    case AuthClientErrorCode.missingDisplayName:
      return 'The resource being created or edited is missing a valid display name.';

    case AuthClientErrorCode.missingEmail:
      return 'The email is required for the specified action. For example, a multi-factor user requires a verified email.';

    case AuthClientErrorCode.missingIosBundleId:
      return 'The request is missing an iOS Bundle ID.';

    case AuthClientErrorCode.missingIssuer:
      return 'The OAuth/OIDC configuration issuer must not be empty.';

    case AuthClientErrorCode.missingHashAlgorithm:
      return 'Importing users with password hashes requires that the hashing algorithm and its parameters be provided.';

    case AuthClientErrorCode.missingOauthClientId:
      return 'The OAuth/OIDC configuration client ID must not be empty.';

    case AuthClientErrorCode.missingOauthClientSecret:
      return 'The OAuth configuration client secret is required to enable OIDC code flow.';

    case AuthClientErrorCode.missingProviderId:
      return 'A valid provider ID must be provided in the request.';

    case AuthClientErrorCode.missingSamlRelyingPartyConfig:
      return 'The SAML configuration provided is missing a relying party configuration.';

    case AuthClientErrorCode.maximumTestPhoneNumberExceeded:
      return 'The maximum allowed number of test phone number / code pairs has been exceeded.';

    case AuthClientErrorCode.maximumUserCountExceeded:
      return 'The maximum allowed number of users to import has been exceeded.';

    case AuthClientErrorCode.missingUid:
      return 'A uid identifier is required for the current operation.';

    case AuthClientErrorCode.operationNotAllowed:
      return 'The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.';

    case AuthClientErrorCode.phoneNumberAlreadyExists:
      return 'The user with the provided phone number already exists.';

    case AuthClientErrorCode.projectNotFound:
      return 'No Firebase project was found for the provided credential.';

    case AuthClientErrorCode.insufficientPermission:
      return 'Credential implementation provided to initializeApp() via the "credential" property  has insufficient permission to access the requested resource. See https://firebase.google.com/docs/admin/setup for details on how to authenticate this SDK with appropriate permissions.';

    case AuthClientErrorCode.quotaExceeded:
      return 'The project quota for the specified operation has been exceeded.';

    case AuthClientErrorCode.secondFactorLimitExceeded:
      return 'The maximum number of allowed second factors on a user has been exceeded.';

    case AuthClientErrorCode.secondFactorUidAlreadyExists:
      return 'The specified second factor "uid" already exists.';

    case AuthClientErrorCode.sessionCookieExpired:
      return 'The Firebase session cookie is expired.';

    case AuthClientErrorCode.sessionCookieRevoked:
      return 'The Firebase session cookie has been revoked.';

    case AuthClientErrorCode.tenantNotFound:
      return 'There is no tenant corresponding to the provided identifier.';

    case AuthClientErrorCode.uidAlreadyExists:
      return 'The user with the provided uid already exists.';

    case AuthClientErrorCode.unauthorizedDomain:
      return 'The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.';

    case AuthClientErrorCode.unsupportedFirstFactor:
      return 'A multi-factor user requires a supported first factor.';

    case AuthClientErrorCode.unsupportedSecondFactor:
      return 'The request specified an unsupported type of second factor.';

    case AuthClientErrorCode.unsupportedTenantOperation:
      return 'This operation is not supported in a multi-tenant context.';

    case AuthClientErrorCode.unverifiedEmail:
      return 'A verified email is required for the specified action. For example, a multi-factor user requires a verified email.';

    case AuthClientErrorCode.userNotFound:
      return 'There is no user record corresponding to the provided identifier.';

    case AuthClientErrorCode.notFound:
      return 'The requested resource was not found.';

    case AuthClientErrorCode.userDisabled:
      return 'The user record is disabled.';

    case AuthClientErrorCode.userNotDisabled:
      return 'The user must be disabled in order to bulk delete it (or you must pass force=true).';

    case AuthClientErrorCode.unknown:
      return null;
  }
}

AuthClientErrorCode? _authServerToClientCode(String? serverCode) {
  switch (serverCode) {
    case 'BILLING_NOT_ENABLED':
      return AuthClientErrorCode.billingNotEnabled;

    /// Claims payload is too large.
    case 'CLAIMS_TOO_LARGE':
      return AuthClientErrorCode.claimsTooLarge;

    /// Configuration being added already exists.
    case 'CONFIGURATION_EXISTS':
      return AuthClientErrorCode.configurationExists;

    /// Configuration not found.
    case 'CONFIGURATION_NOT_FOUND':
      return AuthClientErrorCode.configurationNotFound;

    /// Provided credential has insufficient permissions.
    case 'INSUFFICIENT_PERMISSION':
      return AuthClientErrorCode.insufficientPermission;

    /// Provided configuration has invalid fields.
    case 'INVALID_CONFIG':
      return AuthClientErrorCode.invalidConfig;

    /// Provided configuration identifier is invalid.
    case 'INVALID_CONFIG_ID':
      return AuthClientErrorCode.invalidProviderId;

    /// ActionCodeSettings missing continue URL.
    case 'INVALID_CONTINUE_URI':
      return AuthClientErrorCode.invalidContinueUri;

    /// Dynamic link domain in provided ActionCodeSettings is not authorized.
    case 'INVALID_DYNAMIC_LINK_DOMAIN':
      return AuthClientErrorCode.invalidDynamicLinkDomain;

    /// uploadAccount provides an email that already exists.
    case 'DUPLICATE_EMAIL':
      return AuthClientErrorCode.emailAlreadyExists;

    /// uploadAccount provides a localId that already exists.
    case 'DUPLICATE_LOCAL_ID':
      return AuthClientErrorCode.uidAlreadyExists;

    /// Request specified a multi-factor enrollment ID that already exists.
    case 'DUPLICATE_MFA_ENROLLMENT_ID':
      return AuthClientErrorCode.secondFactorUidAlreadyExists;

    /// setAccountInfo email already exists.
    case 'EMAIL_EXISTS':
      return AuthClientErrorCode.emailAlreadyExists;

    /// accounts:sendOobCode for password reset when user is not found.
    case 'EMAIL_NOT_FOUND':
      return AuthClientErrorCode.emailNotFound;

    /// Reserved claim name.
    case 'FORBIDDEN_CLAIM':
      return AuthClientErrorCode.forbiddenClaim;

    /// Invalid claims provided.
    case 'INVALID_CLAIMS':
      return AuthClientErrorCode.invalidClaims;

    /// Invalid session cookie duration.
    case 'INVALID_DURATION':
      return AuthClientErrorCode.invalidSessionCookieDuration;

    /// Invalid email provided.
    case 'INVALID_EMAIL':
      return AuthClientErrorCode.invalidEmail;

    /// Invalid tenant display name. This can be thrown on CreateTenant and UpdateTenant.
    case 'INVALID_DISPLAY_NAME':
      return AuthClientErrorCode.invalidDisplayName;

    /// Invalid ID token provided.
    case 'INVALID_ID_TOKEN':
      return AuthClientErrorCode.invalidIdToken;

    /// Invalid tenant/parent resource name.
    case 'INVALID_NAME':
      return AuthClientErrorCode.invalidName;

    /// OIDC configuration has an invalid OAuth client ID.
    case 'INVALID_OAUTH_CLIENT_ID':
      return AuthClientErrorCode.invalidOauthClientId;

    /// Invalid page token.
    case 'INVALID_PAGE_SELECTION':
      return AuthClientErrorCode.invalidPageToken;

    /// Invalid phone number.
    case 'INVALID_PHONE_NUMBER':
      return AuthClientErrorCode.invalidPhoneNumber;

    /// Invalid agent project. Either agent project doesn't exist or didn't enable multi-tenancy.
    case 'INVALID_PROJECT_ID':
      return AuthClientErrorCode.invalidProjectId;

    /// Invalid provider ID.
    case 'INVALID_PROVIDER_ID':
      return AuthClientErrorCode.invalidProviderId;

    /// Invalid service account.
    case 'INVALID_SERVICE_ACCOUNT':
      return AuthClientErrorCode.unknown;

    /// Invalid testing phone number.
    case 'INVALID_TESTING_PHONE_NUMBER':
      return AuthClientErrorCode.invalidTestingPhoneNumber;

    /// Invalid tenant type.
    case 'INVALID_TENANT_TYPE':
      return AuthClientErrorCode.invalidTenantType;

    /// Missing Android package name.
    case 'MISSING_ANDROID_PACKAGE_NAME':
      return AuthClientErrorCode.missingAndroidPackageName;

    /// Missing configuration.
    case 'MISSING_CONFIG':
      return AuthClientErrorCode.missingConfig;

    /// Missing configuration identifier.
    case 'MISSING_CONFIG_ID':
      return AuthClientErrorCode.missingProviderId;

    /// Missing tenant display name: This can be thrown on CreateTenant and UpdateTenant.
    case 'MISSING_DISPLAY_NAME':
      return AuthClientErrorCode.missingDisplayName;

    /// Email is required for the specified action. For example a multi-factor user requires
    /// a verified email.
    case 'MISSING_EMAIL':
      return AuthClientErrorCode.missingEmail;

    /// Missing iOS bundle ID.
    case 'MISSING_IOS_BUNDLE_ID':
      return AuthClientErrorCode.missingIosBundleId;

    /// Missing OIDC issuer.
    case 'MISSING_ISSUER':
      return AuthClientErrorCode.missingIssuer;

    /// No localId provided (deleteAccount missing localId).
    case 'MISSING_LOCAL_ID':
      return AuthClientErrorCode.missingUid;

    /// OIDC configuration is missing an OAuth client ID.
    case 'MISSING_OAUTH_CLIENT_ID':
      return AuthClientErrorCode.missingOauthClientId;

    /// Missing provider ID.
    case 'MISSING_PROVIDER_ID':
      return AuthClientErrorCode.missingProviderId;

    /// Missing SAML RP config.
    case 'MISSING_SAML_RELYING_PARTY_CONFIG':
      return AuthClientErrorCode.missingSamlRelyingPartyConfig;

    /// Empty user list in uploadAccount.
    case 'MISSING_USER_ACCOUNT':
      return AuthClientErrorCode.missingUid;

    /// Password auth disabled in console.
    case 'OPERATION_NOT_ALLOWED':
      return AuthClientErrorCode.operationNotAllowed;

    /// Provided credential has insufficient permissions.
    case 'PERMISSION_DENIED':
      return AuthClientErrorCode.insufficientPermission;

    /// Phone number already exists.
    case 'PHONE_NUMBER_EXISTS':
      return AuthClientErrorCode.phoneNumberAlreadyExists;

    /// Project not found.
    case 'PROJECT_NOT_FOUND':
      return AuthClientErrorCode.projectNotFound;

    /// In multi-tenancy context: project creation quota exceeded.
    case 'QUOTA_EXCEEDED':
      return AuthClientErrorCode.quotaExceeded;

    /// Currently only 5 second factors can be set on the same user.
    case 'SECOND_FACTOR_LIMIT_EXCEEDED':
      return AuthClientErrorCode.secondFactorLimitExceeded;

    /// Tenant not found.
    case 'TENANT_NOT_FOUND':
      return AuthClientErrorCode.tenantNotFound;

    /// Tenant ID mismatch.
    case 'TENANT_ID_MISMATCH':
      return AuthClientErrorCode.mismatchingTenantId;

    /// Token expired error.
    case 'TOKEN_EXPIRED':
      return AuthClientErrorCode.idTokenExpired;

    /// Continue URL provided in ActionCodeSettings has a domain that is not whitelisted.
    case 'UNAUTHORIZED_DOMAIN':
      return AuthClientErrorCode.unauthorizedDomain;

    /// A multi-factor user requires a supported first factor.
    case 'UNSUPPORTED_FIRST_FACTOR':
      return AuthClientErrorCode.unsupportedFirstFactor;

    /// The request specified an unsupported type of second factor.
    case 'UNSUPPORTED_SECOND_FACTOR':
      return AuthClientErrorCode.unsupportedSecondFactor;

    /// Operation is not supported in a multi-tenant context.
    case 'UNSUPPORTED_TENANT_OPERATION':
      return AuthClientErrorCode.unsupportedTenantOperation;

    /// A verified email is required for the specified action. For example a multi-factor user
    /// requires a verified email.
    case 'UNVERIFIED_EMAIL':
      return AuthClientErrorCode.unverifiedEmail;

    /// User on which action is to be performed is not found.
    case 'USER_NOT_FOUND':
      return AuthClientErrorCode.userNotFound;

    /// User record is disabled.
    case 'USER_DISABLED':
      return AuthClientErrorCode.userDisabled;

    /// Password provided is too weak.
    case 'WEAK_PASSWORD':
      return AuthClientErrorCode.invalidPassword;
  }

  return null;
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
