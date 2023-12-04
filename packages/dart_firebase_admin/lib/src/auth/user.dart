part of '../auth.dart';

/// 'REDACTED', encoded as a base64 string.
final _b64Redacted = base64Encode('REDACTED'.codeUnits);

enum MultiFactorId {
  phone._('phone'),
  totp._('totp');

  const MultiFactorId._(this._value);

  final String _value;
}

class UserRecord {
  @internal
  UserRecord({
    required this.uid,
    required this.email,
    required this.emailVerified,
    required this.displayName,
    required this.photoUrl,
    required this.phoneNumber,
    required this.disabled,
    required this.metadata,
    required this.providerData,
    required this.passwordHash,
    required this.passwordSalt,
    required this.customClaims,
    required this.tenantId,
    required this.tokensValidAfterTime,
    required this.multiFactor,
  });

  @internal
  factory UserRecord.fromResponse(
    auth1.GoogleCloudIdentitytoolkitV1UserInfo response,
  ) {
    final localId = response.localId;
    // The Firebase user id is required.
    if (localId == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.internalError,
        'INTERNAL ASSERT FAILED: Invalid user response',
      );
    }
    // If disabled is not provided, the account is enabled by default.
    final disabled = response.disabled ?? false;
    final metadata = UserMetadata.fromResponse(response);

    final providerData = <UserInfo>[];
    final providerUserInfo = response.providerUserInfo;
    if (providerUserInfo != null) {
      for (final entry in providerUserInfo) {
        providerData.add(UserInfo.fromResponse(entry));
      }
    }

    // If the password hash is redacted (probably due to missing permissions)
    // then clear it out, similar to how the salt is returned. (Otherwise, it
    // *looks* like a b64-encoded hash is present, which is confusing.)
    final passwordHash =
        response.passwordHash == _b64Redacted ? null : response.passwordHash;

    final customAttributes = response.customAttributes;
    final customClaims = customAttributes != null
        ? UnmodifiableMapView(
            jsonDecode(customAttributes) as Map<String, Object?>,
          )
        : null;

    DateTime? tokensValidAfterTime;
    final validSince = response.validSince;
    if (validSince != null) {
      // Convert validSince first to UTC milliseconds and then to UTC date string.
      tokensValidAfterTime = DateTime.fromMillisecondsSinceEpoch(
        // TODO double check that 1000
        int.parse(validSince) * 1000,
        isUtc: true,
      );
    }

    MultiFactorSettings? multiFactor =
        MultiFactorSettings.fromResponse(response);
    if (multiFactor.enrolledFactors.isEmpty) {
      multiFactor = null;
    }

    return UserRecord(
      uid: localId,
      email: response.email,
      emailVerified: response.emailVerified ?? false,
      displayName: response.displayName,
      photoUrl: response.photoUrl,
      phoneNumber: response.phoneNumber,
      disabled: disabled,
      metadata: metadata,
      providerData: UnmodifiableListView(providerData),
      passwordHash: passwordHash,
      passwordSalt: response.salt,
      customClaims: customClaims,
      tenantId: response.tenantId,
      tokensValidAfterTime: tokensValidAfterTime,
      multiFactor: multiFactor,
    );
  }

  /// The user's `uid`.
  final String uid;

  /// The user's primary email, if set.
  final String? email;

  /// Whether or not the user's primary email is verified.
  final bool emailVerified;

  /// The user's display name.
  final String? displayName;

  /// The user's photo URL.
  final String? photoUrl;

  /// The user's primary phone number, if set.
  final String? phoneNumber;

  /// Whether or not the user is disabled: `true` for disabled; `false` for
  /// enabled.
  final bool disabled;

  /// Additional metadata about the user.
  final UserMetadata metadata;

  /// An array of providers (for example, Google, Facebook) linked to the user.
  final List<UserInfo> providerData;

  /// The user's hashed password (base64-encoded), only if Firebase Auth hashing
  /// algorithm (SCRYPT) is used. If a different hashing algorithm had been used
  /// when uploading this user, as is typical when migrating from another Auth
  /// system, this will be an empty string. If no password is set, this is
  /// null. This is only available when the user is obtained from
  /// [_BaseAuth.listUsers].
  final String? passwordHash;

  /// The user's password salt (base64-encoded), only if Firebase Auth hashing
  /// algorithm (SCRYPT) is used. If a different hashing algorithm had been used to
  /// upload this user, typical when migrating from another Auth system, this will
  /// be an empty string. If no password is set, this is null. This is only
  /// available when the user is obtained from [_BaseAuth.listUsers].
  final String? passwordSalt;

  /// The user's custom claims object if available, typically used to define
  /// user roles and propagated to an authenticated user's ID token.
  /// This is set via [_BaseAuth.setCustomUserClaims].
  final Map<String, Object?>? customClaims;

  /// The ID of the tenant the user belongs to, if available.
  final String? tenantId;

  /// The date the user's tokens are valid after, formatted as a UTC string.
  /// This is updated every time the user's refresh token are revoked either
  /// from the [_BaseAuth.revokeRefreshTokens].
  /// API or from the Firebase Auth backend on big account changes (password
  /// resets, password or email updates, etc).
  final DateTime? tokensValidAfterTime;

  /// The multi-factor related properties for the current user, if available.
  final MultiFactorSettings? multiFactor;

  /// Returns a JSON-serializable representation of this object.
  ///
  /// A JSON-serializable representation of this object.
  Map<String, Object?> _toJson() {
    final providerDataJson = <Object?>[];
    final json = <String, Object?>{
      'uid': uid,
      'email': email,
      'emailVerified': emailVerified,
      'displayName': displayName,
      'photoURL': photoUrl,
      'phoneNumber': phoneNumber,
      'disabled': disabled,
      // Convert metadata to json.
      'metadata': metadata._toJson(),
      'passwordHash': passwordHash,
      'passwordSalt': passwordSalt,
      'customClaims': customClaims,
      'tokensValidAfterTime': tokensValidAfterTime,
      'tenantId': tenantId,
      'providerData': providerDataJson,
    };

    final multiFactor = this.multiFactor;
    if (multiFactor != null) json['multiFactor'] = multiFactor._toJson();

    json['providerData'] = [];
    for (final entry in providerData) {
      // Convert each provider data to json.
      providerDataJson.add(entry._toJson());
    }
    return json;
  }
}

class UserInfo {
  UserInfo({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.providerId,
    required this.phoneNumber,
  });

  UserInfo.fromResponse(
    auth1.GoogleCloudIdentitytoolkitV1ProviderUserInfo response,
  )   : uid = response.rawId,
        displayName = response.displayName,
        email = response.email,
        photoUrl = response.photoUrl,
        providerId = response.providerId,
        phoneNumber = response.phoneNumber {
    if (response.rawId == null || response.providerId == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.internalError,
      );
    }
  }

  final String? uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? providerId;
  final String? phoneNumber;

  Map<String, Object?> _toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoUrl,
      'providerId': providerId,
      'phoneNumber': phoneNumber,
    };
  }
}

class MultiFactorSettings {
  MultiFactorSettings({required this.enrolledFactors});

  factory MultiFactorSettings.fromResponse(
    auth1.GoogleCloudIdentitytoolkitV1UserInfo response,
  ) {
    final parsedEnrolledFactors = <MultiFactorInfo>[
      ...?response.mfaInfo
          ?.map(MultiFactorInfo.initMultiFactorInfo)
          .whereNotNull(),
    ];

    return MultiFactorSettings(
      enrolledFactors: UnmodifiableListView(parsedEnrolledFactors),
    );
  }

  final List<MultiFactorInfo> enrolledFactors;

  Map<String, Object?> _toJson() {
    return {
      'enrolledFactors': enrolledFactors.map((info) => info._toJson()).toList(),
    };
  }
}

/// Interface representing the common properties of a user-enrolled second factor.
abstract class MultiFactorInfo {
  MultiFactorInfo({
    required this.uid,
    required this.displayName,
    required this.enrollmentTime,
  });

  MultiFactorInfo.fromResponse(
    auth1.GoogleCloudIdentitytoolkitV1MfaEnrollment response,
  )   : uid = response.mfaEnrollmentId.orThrow(
          () => throw FirebaseAuthAdminException(
            AuthClientErrorCode.internalError,
            'INTERNAL ASSERT FAILED: No uid found for MFA info.',
          ),
        ),
        displayName = response.displayName,
        enrollmentTime = response.enrolledAt
            .let(int.parse)
            .let(DateTime.fromMillisecondsSinceEpoch);

  /// Initializes the MultiFactorInfo associated subclass using the server side.
  /// If no MultiFactorInfo is associated with the response, null is returned.
  ///
  /// @param response - The server side response.
  /// @internal
  static MultiFactorInfo? initMultiFactorInfo(
    auth1.GoogleCloudIdentitytoolkitV1MfaEnrollment response,
  ) {
    // PhoneMultiFactorInfo, TotpMultiFactorInfo currently available.
    try {
      final phoneInfo = response.phoneInfo;
      // TODO Support TotpMultiFactorInfo

      if (phoneInfo != null) {
        return PhoneMultiFactorInfo.fromResponse(response);
      }
      // Ignore the other SDK unsupported MFA factors to prevent blocking developers using the current SDK.
    } catch (e) {
      // Ignore error.
    }

    return null;
  }

  /// The ID of the enrolled second factor. This ID is unique to the user.
  final String uid;

  /// The optional display name of the enrolled second factor.
  final String? displayName;

  /// The type identifier of the second factor.
  /// For SMS second factors, this is `phone`.
  /// For TOTP second factors, this is `totp`.
  MultiFactorId get factorId;

  /// The optional date the second factor was enrolled, formatted as a UTC string.
  final DateTime? enrollmentTime;

  /// Returns a JSON-serializable representation of this object.
  ///
  /// @returns A JSON-serializable representation of this object.
  Map<String, Object?> _toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'factorId': factorId._value,
      'enrollmentTime': enrollmentTime,
    };
  }
}

/// Interface representing a phone specific user-enrolled second factor.
class PhoneMultiFactorInfo extends MultiFactorInfo {
  /// Initializes the PhoneMultiFactorInfo object using the server side response.
  @internal
  PhoneMultiFactorInfo.fromResponse(super.response)
      : phoneNumber = response.phoneInfo,
        factorId = response.phoneInfo != null ? MultiFactorId.phone : throw 42,
        super.fromResponse();

  /// The phone number associated with a phone second factor.
  final String? phoneNumber;

  @override
  final MultiFactorId factorId;

  @override
  Map<String, Object?> _toJson() {
    return {
      ...super._toJson(),
      'phoneNumber': phoneNumber,
    };
  }
}

/// Metadata information about when a user was created and last signed in.
class UserMetadata {
  /// Metadata information about when a user was created and last signed in.
  @internal
  UserMetadata({
    required this.creationTime,
    required this.lastSignInTime,
    required this.lastRefreshTime,
  });

  @internal
  UserMetadata.fromResponse(
    auth1.GoogleCloudIdentitytoolkitV1UserInfo response,
  )   : creationTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(response.createdAt!),
        ),
        lastSignInTime = response.lastLoginAt.let((lastLoginAt) {
          return DateTime.fromMillisecondsSinceEpoch(int.parse(lastLoginAt));
        }),
        lastRefreshTime = response.lastRefreshAt.let(DateTime.parse);

  final DateTime creationTime;
  final DateTime? lastSignInTime;
  final DateTime? lastRefreshTime;

  Map<String, Object?> _toJson() {
    return {
      'creationTime': creationTime.microsecondsSinceEpoch.toString(),
      'lastSignInTime': lastSignInTime?.millisecondsSinceEpoch.toString(),
      'lastRefreshTime': lastRefreshTime?.toIso8601String(),
    };
  }
}

/// Export [UserMetadata._toJson] for testing purposes.
@internal
extension UserMetadataToJson on UserMetadata {
  Map<String, Object?> toJson() => _toJson();
}
