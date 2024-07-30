part of '../auth.dart';

enum HashAlgorithmType {
  scrypt('SCRYPT'),
  standardScrypt('STANDARD_SCRYPT'),
  hmacSha512('HMAC_SHA512'),
  hmacSha256('HMAC_SHA256'),
  hmacSha1('HMAC_SHA1'),
  hmacMd5('HMAC_MD5'),
  md5('MD5'),
  pbkdfSha1('PBKDF_SHA1'),
  bcrypt('BCRYPT'),
  pbkdf2Sha256('PBKDF2_SHA256'),
  sha512('SHA512'),
  sha256('SHA256'),
  sha1('SHA1');

  const HashAlgorithmType(this.value);

  final String value;
}

class UserImportHashOptions {
  UserImportHashOptions({
    required this.algorithm,
    required this.key,
    required this.saltSeparator,
    required this.rounds,
    required this.memoryCost,
    required this.parallelization,
    required this.blockSize,
    required this.derivedKeyLength,
  });

  /// The password hashing algorithm identifier. The following algorithm
  /// identifiers are supported:
  /// `SCRYPT`, `STANDARD_SCRYPT`, `HMAC_SHA512`, `HMAC_SHA256`, `HMAC_SHA1`,
  /// `HMAC_MD5`, `MD5`, `PBKDF_SHA1`, `BCRYPT`, `PBKDF2_SHA256`, `SHA512`,
  /// `SHA256` and `SHA1`.
  final HashAlgorithmType algorithm;

  /// The signing key used in the hash algorithm in buffer bytes.
  /// Required by hashing algorithms `SCRYPT`, `HMAC_SHA512`, `HMAC_SHA256`,
  /// `HAMC_SHA1` and `HMAC_MD5`.
  final Uint8List? key;

  /// The salt separator in buffer bytes which is appended to salt when
  /// verifying a password. This is only used by the `SCRYPT` algorithm.
  final Uint8List? saltSeparator;

  /// The number of rounds for hashing calculation.
  /// Required for `SCRYPT`, `MD5`, `SHA512`, `SHA256`, `SHA1`, `PBKDF_SHA1` and
  /// `PBKDF2_SHA256`.
  final int? rounds;

  /// The memory cost required for `SCRYPT` algorithm, or the CPU/memory cost.
  /// Required for `STANDARD_SCRYPT` algorithm.
  final int? memoryCost;

  /// The parallelization of the hashing algorithm. Required for the
  /// `STANDARD_SCRYPT` algorithm.
  final int? parallelization;

  /// The block size (normally 8) of the hashing algorithm. Required for the
  /// `STANDARD_SCRYPT` algorithm.
  final int? blockSize;

  /// The derived key length of the hashing algorithm. Required for the
  /// `STANDARD_SCRYPT` algorithm.
  final int? derivedKeyLength;
}

/// Interface representing the user import options needed for
/// [_BaseAuth.importUsers] method. This is used to
/// provide the password hashing algorithm information.
class UserImportOptions {
  UserImportOptions({required this.hash});

  /// The password hashing information.
  final UserImportHashOptions hash;
}

class UploadAccountOptions {
  UploadAccountOptions._({
    this.hashAlgorithm,
    this.signerKey,
    this.rounds,
    this.memoryCost,
    this.saltSeparator,
    this.parallelization,
    this.blockSize,
    this.dkLen,
  });

  final HashAlgorithmType? hashAlgorithm;
  final String? signerKey;
  final int? rounds;
  final int? memoryCost;
  final String? saltSeparator;
  final int? parallelization;
  final int? blockSize;
  final int? dkLen;
}

/// User provider data to include when importing a user.
class UserProviderRequest {
  UserProviderRequest({
    required this.uid,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
    required this.providerId,
  });

  /// The user identifier for the linked provider.
  final String uid;

  /// The display name for the linked provider.
  final String? displayName;

  /// The email for the linked provider.
  final String? email;

  /// The phone number for the linked provider.
  final String? phoneNumber;

  /// The photo URL for the linked provider.
  final String? photoURL;

  /// The linked provider ID (for example, "google.com" for the Google provider).
  final String providerId;
}

/// Interface representing a user to import to Firebase Auth via the
/// [_BaseAuth.importUsers] method.
class UserImportRecord {
  UserImportRecord({
    required this.uid,
    this.email,
    this.emailVerified,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.disabled,
    this.metadata,
    this.providerData,
    this.customClaims,
    this.passwordHash,
    this.passwordSalt,
    this.tenantId,
    this.multiFactor,
  });

  /// The user's `uid`.
  final String uid;

  /// The user's primary email, if set.
  final String? email;

  /// Whether or not the user's primary email is verified.
  final bool? emailVerified;

  /// The user's display name.
  final String? displayName;

  /// The user's primary phone number, if set.
  final String? phoneNumber;

  /// The user's photo URL.
  final String? photoURL;

  /// Whether or not the user is disabled: `true` for disabled; `false` for
  /// enabled.
  final bool? disabled;

  /// Additional metadata about the user.
  final UserMetadataRequest? metadata;

  /// An array of providers (for example, Google, Facebook) linked to the user.
  final List<UserProviderRequest>? providerData;

  /// The user's custom claims object if available, typically used to define
  /// user roles and propagated to an authenticated user's ID token.
  final Map<String, Object?>? customClaims;

  /// The buffer of bytes representing the user's hashed password.
  /// When a user is to be imported with a password hash,
  /// [UserImportOptions] are required to be
  /// specified to identify the hashing algorithm used to generate this hash.
  final Uint8List? passwordHash;

  /// The buffer of bytes representing the user's password salt.
  final Uint8List? passwordSalt;

  /// The identifier of the tenant where user is to be imported to.
  /// When not provided in an `admin.auth.Auth` context, the user is uploaded to
  /// the default parent project.
  /// When not provided in an `admin.auth.TenantAwareAuth` context, the user is uploaded
  /// to the tenant corresponding to that `TenantAwareAuth` instance's tenant ID.
  final String? tenantId;

  /// The user's multi-factor related properties.
  final MultiFactorUpdateSettings? multiFactor;
}

/// Callback function to validate an UploadAccountUser object.
typedef _ValidatorFunction = void Function(
  v1.GoogleCloudIdentitytoolkitV1UserInfo data,
);

/// User metadata to include when importing a user.
class UserMetadataRequest {
  UserMetadataRequest({
    required this.lastSignInTime,
    required this.creationTime,
  });

  /// The date the user last signed in, formatted as a UTC string.
  final DateTime? lastSignInTime;

  /// The date the user was created, formatted as a UTC string.
  final DateTime? creationTime;
}

class _UserImportBuilder {
  _UserImportBuilder({
    required this.users,
    required this.options,
    required this.userRequestValidator,
  }) {
    _validatedUsers = _populateUsers(users, userRequestValidator);
    _validatedOptions = _populateOptions(
      options,
      requiresHashOptions: _requiresHashOptions,
    );
  }

  final List<UserImportRecord> users;
  final UserImportOptions? options;
  final _ValidatorFunction? userRequestValidator;

  var _requiresHashOptions = false;
  var _validatedUsers = <v1.GoogleCloudIdentitytoolkitV1UserInfo>[];
  UploadAccountOptions? _validatedOptions;
  final _indexMap = <int, int>{};
  final _userImportResultErrors = <FirebaseArrayIndexError>[];

  v1.GoogleCloudIdentitytoolkitV1UploadAccountRequest buildRequest() {
    return v1.GoogleCloudIdentitytoolkitV1UploadAccountRequest(
      hashAlgorithm: _validatedOptions?.hashAlgorithm?.value,
      signerKey: _validatedOptions?.signerKey,
      rounds: _validatedOptions?.rounds,
      memoryCost: _validatedOptions?.memoryCost,
      saltSeparator: _validatedOptions?.saltSeparator,
      parallelization: _validatedOptions?.parallelization,
      blockSize: _validatedOptions?.blockSize,
      dkLen: _validatedOptions?.dkLen,
      users: _validatedUsers.toList(),
    );
  }

  UserImportResult buildResponse(
    List<v1.GoogleCloudIdentitytoolkitV1ErrorInfo> failedUploads,
  ) {
    // Initialize user import result.
    final importResult = UserImportResult(
      successCount: _validatedUsers.length - failedUploads.length,
      failureCount: _userImportResultErrors.length + failedUploads.length,
      errors: [
        ..._userImportResultErrors,
        for (final failedUpload in failedUploads)
          FirebaseArrayIndexError(
            // Map backend request index to original developer provided array index.
            index: _indexMap[failedUpload.index]!,
            error: FirebaseAuthAdminException(
              AuthClientErrorCode.invalidUserImport,
              failedUpload.message,
            ),
          ),
      ],
    );
    // Sort errors by index.
    importResult.errors.sort((a, b) => a.index - b.index);
    // Return sorted result
    return importResult;
  }

  UploadAccountOptions _populateOptions(
    UserImportOptions? options, {
    required bool requiresHashOptions,
  }) {
    if (!requiresHashOptions) return UploadAccountOptions._();

    if (options == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        '"UserImportOptions" are required when importing users with passwords.',
      );
    }

    switch (options.hash.algorithm) {
      case HashAlgorithmType.hmacSha512:
      case HashAlgorithmType.hmacSha256:
      case HashAlgorithmType.hmacSha1:
      case HashAlgorithmType.hmacMd5:
        final key = options.hash.key;
        if (key == null) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidHashKey,
            'A non-empty "hash.key" byte buffer must be provided for hash '
            'algorithm ${options.hash.algorithm}.',
          );
        }

        return UploadAccountOptions._(
          hashAlgorithm: options.hash.algorithm,
          signerKey: base64Encode(key),
        );

      case HashAlgorithmType.md5:
      case HashAlgorithmType.sha1:
      case HashAlgorithmType.sha256:
      case HashAlgorithmType.sha512:
        // MD5 is [0,8192] but SHA1, SHA256, and SHA512 are [1,8192]
        final rounds = options.hash.rounds;
        final minRounds =
            options.hash.algorithm == HashAlgorithmType.md5 ? 0 : 1;
        if (rounds == null || rounds < minRounds || rounds > 8192) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidHashRounds,
            'A "hash.rounds" value between $minRounds and 8192 must be provided '
            'for hash algorithm ${options.hash.algorithm}.',
          );
        }

        return UploadAccountOptions._(
          hashAlgorithm: options.hash.algorithm,
          rounds: rounds,
        );

      case HashAlgorithmType.pbkdfSha1:
      case HashAlgorithmType.pbkdf2Sha256:
        final rounds = options.hash.rounds;
        if (rounds == null || rounds < 0 || rounds > 120000) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidHashRounds,
            'A "hash.rounds" value between 0 and 120000 must be provided '
            'for hash algorithm ${options.hash.algorithm}.',
          );
        }

        return UploadAccountOptions._(
          hashAlgorithm: options.hash.algorithm,
          rounds: rounds,
        );

      case HashAlgorithmType.scrypt:
        final key = options.hash.key;
        if (key == null) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidHashKey,
            'A "hash.key" byte buffer must be provided for '
            'hash algorithm ${options.hash.algorithm}.',
          );
        }
        final rounds = options.hash.rounds;
        if (rounds == null || rounds <= 0 || rounds > 8) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidHashRounds,
            'A valid "hash.rounds" number between 1 and 8 must be provided for '
            'hash algorithm ${options.hash.algorithm}.',
          );
        }
        final memoryCost = options.hash.memoryCost;
        if (memoryCost == null || memoryCost <= 0 || memoryCost > 14) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidHashMemoryCost,
            'A valid "hash.memoryCost" number between 1 and 14 must be provided '
            'for hash algorithm ${options.hash.algorithm}.',
          );
        }
        final saltSeparator = options.hash.saltSeparator;

        return UploadAccountOptions._(
          hashAlgorithm: options.hash.algorithm,
          signerKey: base64Encode(key),
          rounds: rounds,
          memoryCost: memoryCost,
          saltSeparator: base64Encode(saltSeparator ?? Uint8List(0)),
        );

      case HashAlgorithmType.bcrypt:
        return UploadAccountOptions._(
          hashAlgorithm: options.hash.algorithm,
        );

      case HashAlgorithmType.standardScrypt:
        final cpuMemCost = options.hash.memoryCost;
        if (cpuMemCost == null) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidHashMemoryCost,
            'A valid "hash.memoryCost" number must be provided for '
            'hash algorithm ${options.hash.algorithm}.',
          );
        }
        final parallelization = options.hash.parallelization;
        if (parallelization == null) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidHashParallelization,
            'A valid "hash.parallelization" number must be provided for '
            'hash algorithm ${options.hash.algorithm}.',
          );
        }
        final blockSize = options.hash.blockSize;
        if (blockSize == null) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidHashBlockSize,
            'A valid "hash.blockSize" number must be provided for '
            'hash algorithm ${options.hash.algorithm}.',
          );
        }
        final dkLen = options.hash.derivedKeyLength;
        if (dkLen == null) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidHashDerivedKeyLength,
            'A valid "hash.derivedKeyLength" number must be provided for '
            'hash algorithm ${options.hash.algorithm}.',
          );
        }

        return UploadAccountOptions._(
          hashAlgorithm: options.hash.algorithm,
          memoryCost: cpuMemCost,
          parallelization: parallelization,
          blockSize: blockSize,
          dkLen: dkLen,
        );
    }
  }

  /// Validates and returns the users list of the uploadAccount request.
  /// Whenever a user with an error is detected, the error is cached and will later be
  /// merged into the user import result. This allows the processing of valid users without
  /// failing early on the first error detected.
  ///
  /// - [users] The UserImportRecords to convert to UploadAccountUser objects.
  /// - [userValidator] The user validator function.
  List<v1.GoogleCloudIdentitytoolkitV1UserInfo> _populateUsers(
    List<UserImportRecord> users,
    _ValidatorFunction? userValidator,
  ) {
    final populatedUsers = <v1.GoogleCloudIdentitytoolkitV1UserInfo>[];
    users.forEachIndexed((index, user) {
      try {
        final result = _populateUploadAccountUser(user, userValidator);
        if (result.passwordHash != null) {
          _requiresHashOptions = true;
        }

        // Only users that pass client screening will be passed to backend for processing.
        populatedUsers.add(result);
        // Map user's index (the one to be sent to backend) to original developer provided array.
        _indexMap[populatedUsers.length - 1] = index;
      } on FirebaseAdminException catch (err) {
        _userImportResultErrors.add(
          FirebaseArrayIndexError(index: index, error: err),
        );
      }
    });

    return populatedUsers;
  }
}

/// Converts a UserImportRecord to a UploadAccountUser object. Throws an error when invalid
/// fields are provided.
///
/// - [UserImportRecord] user The UserImportRecord to convert to UploadAccountUser.
/// - [_ValidatorFunction] userValidator The user validator function.
v1.GoogleCloudIdentitytoolkitV1UserInfo _populateUploadAccountUser(
  UserImportRecord user,
  _ValidatorFunction? userValidator,
) {
  final mfaInfo = user.multiFactor?.enrolledFactors
      ?.map(
        (factor) => factor.toMfaEnrollment(),
      )
      .toList();

  final providerUserInfo = user.providerData
      ?.map(
        (providerData) => v1.GoogleCloudIdentitytoolkitV1ProviderUserInfo(
          rawId: providerData.uid,
          providerId: providerData.providerId,
          email: providerData.email,
          displayName: providerData.displayName,
          photoUrl: providerData.photoURL,
        ),
      )
      .toList();

  final result = v1.GoogleCloudIdentitytoolkitV1UserInfo(
    localId: user.uid,
    email: user.email,
    emailVerified: user.emailVerified,
    displayName: user.displayName,
    disabled: user.disabled,
    photoUrl: user.photoURL,
    phoneNumber: user.phoneNumber,
    providerUserInfo: providerUserInfo != null && providerUserInfo.isNotEmpty
        ? providerUserInfo
        : null,
    mfaInfo: mfaInfo != null && mfaInfo.isNotEmpty ? mfaInfo : null,
    tenantId: user.tenantId,
    customAttributes: user.customClaims.let(json.encode),
    passwordHash: user.passwordHash.let(base64Encode),
    salt: user.passwordSalt.let(base64Encode),
    createdAt: user.metadata?.creationTime?.toIso8601String(),
    lastLoginAt: user.metadata?.lastSignInTime?.toIso8601String(),
  );

  userValidator?.call(result);

  return result;
}
