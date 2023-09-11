import 'package:firebaseapis/identitytoolkit/v1.dart' as v1;

import '../dart_firebase_admin.dart';

const _sentinel = _Sentinel();

class _Sentinel {
  const _Sentinel();
}

/// An object used to differentiate "no value" from "a null value".
///
/// This is typically used to enable `update(displayName: null)`.
class Box<T> {
  Box(this.value);

  static Box<T?>? unwrap<T>(Object? value) {
    if (value == _sentinel) return null;
    return Box(value as T?);
  }

  final T value;
}

/// Interface representing the properties to set on a new user record to be
/// created.
class CreateRequest extends _BaseUpdateRequest {
  CreateRequest({
    super.disabled,
    super.displayName,
    super.email,
    super.emailVerified,
    super.password,
    super.phoneNumber,
    super.photoURL,
    this.multiFactor,
    this.uid,
  }) : assert(
          multiFactor is! MultiFactorUpdateSettings,
          'MultiFactorUpdateSettings is not supported for create requests.',
        );

  /// The user's `uid`.
  final String? uid;

  /// The user's multi-factor related properties.
  final MultiFactorCreateSettings? multiFactor;
}

/// Interface representing the properties to update on the provided user.
class UpdateRequest extends _BaseUpdateRequest {
  /// Interface representing the properties to update on the provided user.
  UpdateRequest({
    super.disabled,
    String? super.displayName,
    super.email,
    super.emailVerified,
    super.password,
    String? super.phoneNumber,
    String? super.photoURL,
    this.multiFactor,
    this.providerToLink,
    this.providersToUnlink,
  });

  UpdateRequest._({
    super.disabled,
    super.displayName,
    super.email,
    super.emailVerified,
    super.password,
    super.phoneNumber,
    super.photoURL,
    this.multiFactor,
    this.providerToLink,
    this.providersToUnlink,
  });

  /// The user's updated multi-factor related properties.
  final MultiFactorUpdateSettings? multiFactor;

  /// Links this user to the specified provider.
  ///
  /// Linking a provider to an existing user account does not invalidate the
  /// refresh token of that account. In other words, the existing account
  /// would continue to be able to access resources, despite not having used
  /// the newly linked provider to log in. If you wish to force the user to
  /// authenticate with this new provider, you need to (a) revoke their
  /// refresh token (see
  /// https://firebase.google.com/docs/auth/admin/manage-sessions#revoke_refresh_tokens),
  /// and (b) ensure no other authentication methods are present on this
  /// account.
  final UserProvider? providerToLink;

  /// Unlinks this user from the specified providers.
  final List<String>? providersToUnlink;

  UpdateRequest Function({String? email, String? phoneNumber}) get copyWith {
    // ignore: avoid_types_on_closure_parameters, false positive
    return ({Object? email = _sentinel, Object? phoneNumber = _sentinel}) {
      return UpdateRequest._(
        disabled: disabled,
        displayName: displayName,
        email: email == _sentinel ? this.email : email as String?,
        emailVerified: emailVerified,
        password: password,
        phoneNumber: phoneNumber == _sentinel
            ? this.phoneNumber
            : phoneNumber as String?,
        photoURL: photoURL,
        multiFactor: multiFactor,
        providerToLink: providerToLink,
        providersToUnlink: providersToUnlink,
      );
    };
  }
}

class _BaseUpdateRequest {
  /// A base request to update a user.
  /// This supports differentiating between unset properties and clearing
  /// properties by setting them to `null`.
  ///
  /// As in `UpdateRequest()` vs `UpdateRequest(displayName: null)`.
  ///
  /// Use [UpdateRequest] directly instead, as this constructor has some
  /// untyped parameters.
  _BaseUpdateRequest({
    required this.disabled,
    Object? displayName = _sentinel,
    required this.email,
    required this.emailVerified,
    required this.password,
    Object? phoneNumber = _sentinel,
    Object? photoURL = _sentinel,
  })  : displayName = Box.unwrap(displayName),
        phoneNumber = Box.unwrap(phoneNumber),
        photoURL = Box.unwrap(photoURL);

  /// Whether or not the user is disabled: `true` for disabled;
  /// `false` for enabled.
  final bool? disabled;

  /// The user's display name.
  final Box<String?>? displayName;

  /// The user's primary email.
  final String? email;

  /// Whether or not the user's primary email is verified.
  final bool? emailVerified;

  /// The user's unhashed password.
  final String? password;

  /// The user's primary phone number.
  final Box<String?>? phoneNumber;

  /// The user's photo URL.
  final Box<String?>? photoURL;
}

/// Represents a user identity provider that can be associated with a Firebase user.
class UserProvider {
  UserProvider({
    this.uid,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
    this.providerId,
  });

  /// The user identifier for the linked provider.
  final String? uid;

  /// The display name for the linked provider.
  final String? displayName;

  /// The email for the linked provider.
  final String? email;

  /// The phone number for the linked provider.
  final String? phoneNumber;

  /// The photo URL for the linked provider.
  final String? photoURL;

  /// The linked provider ID (for example, "google.com" for the Google provider).
  final String? providerId;

  v1.GoogleCloudIdentitytoolkitV1ProviderUserInfo toProviderUserInfo() {
    return v1.GoogleCloudIdentitytoolkitV1ProviderUserInfo(
      displayName: displayName,
      email: email,
      phoneNumber: phoneNumber,
      photoUrl: photoURL,
      providerId: providerId,
      rawId: uid,
      federatedId: null,
      screenName: null,
    );
  }
}

/// The multi-factor related user settings for update operations.
class MultiFactorUpdateSettings {
  MultiFactorUpdateSettings({this.enrolledFactors});

  /// The updated list of enrolled second factors. The provided list overwrites the user's
  /// existing list of second factors.
  /// When null is passed, all of the user's existing second factors are removed.
  final List<UpdateMultiFactorInfoRequest>? enrolledFactors;

  v1.GoogleCloudIdentitytoolkitV1MfaInfo toMfaInfo() {
    final enrolledFactors = this.enrolledFactors;
    if (enrolledFactors == null || enrolledFactors.isEmpty) {
      // Remove all second factors.
      return v1.GoogleCloudIdentitytoolkitV1MfaInfo();
    }

    return v1.GoogleCloudIdentitytoolkitV1MfaInfo(
      enrollments: enrolledFactors.map((e) => e.toMfaEnrollment()).toList(),
    );
  }
}

/// The multi-factor related user settings for create operations.
class MultiFactorCreateSettings {
  MultiFactorCreateSettings({
    required this.enrolledFactors,
  });

  /// The created user's list of enrolled second factors.
  final List<CreateMultiFactorInfoRequest> enrolledFactors;
}

/// Interface representing a phone specific user-enrolled second factor for a
/// `CreateRequest`.
class CreatePhoneMultiFactorInfoRequest extends CreateMultiFactorInfoRequest {
  CreatePhoneMultiFactorInfoRequest({
    required super.displayName,
    required this.phoneNumber,
  });

  /// The phone number associated with a phone second factor.
  final String phoneNumber;

  @override
  v1.GoogleCloudIdentitytoolkitV1MfaFactor
      toGoogleCloudIdentitytoolkitV1MfaFactor() {
    return v1.GoogleCloudIdentitytoolkitV1MfaFactor(
      displayName: displayName,
      // TODO param is optional, but phoneNumber is required.
      phoneInfo: phoneNumber,
    );
  }
}

/// Interface representing base properties of a user-enrolled second factor for a
/// `CreateRequest`.
sealed class CreateMultiFactorInfoRequest {
  CreateMultiFactorInfoRequest({
    required this.displayName,
  });

  /// The optional display name for an enrolled second factor.
  final String? displayName;

  v1.GoogleCloudIdentitytoolkitV1MfaFactor
      toGoogleCloudIdentitytoolkitV1MfaFactor();
}

/// Interface representing a phone specific user-enrolled second factor
/// for an `UpdateRequest`.
class UpdatePhoneMultiFactorInfoRequest extends UpdateMultiFactorInfoRequest {
  UpdatePhoneMultiFactorInfoRequest({
    required this.phoneNumber,
    super.uid,
    super.displayName,
    super.enrollmentTime,
  });

  /// The phone number associated with a phone second factor.
  final String phoneNumber;
}

/// Interface representing common properties of a user-enrolled second factor
/// for an `UpdateRequest`.
sealed class UpdateMultiFactorInfoRequest {
  UpdateMultiFactorInfoRequest({
    this.uid,
    this.displayName,
    this.enrollmentTime,
  }) {
    final enrollmentTime = this.enrollmentTime;
    if (enrollmentTime != null && !enrollmentTime.isUtc) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidEnrollmentTime,
        'The second factor "enrollmentTime" for "$uid" must be a valid '
        'UTC date.',
      );
    }
  }

  /// The ID of the enrolled second factor. This ID is unique to the user. When not provided,
  /// a new one is provisioned by the Auth server.
  final String? uid;

  /// The optional display name for an enrolled second factor.
  final String? displayName;

  /// The optional date the second factor was enrolled.
  final DateTime? enrollmentTime;

  v1.GoogleCloudIdentitytoolkitV1MfaEnrollment toMfaEnrollment() {
    final that = this;
    return switch (that) {
      UpdatePhoneMultiFactorInfoRequest() =>
        v1.GoogleCloudIdentitytoolkitV1MfaEnrollment(
          mfaEnrollmentId: uid,
          displayName: displayName,
          // Required for all phone second factors.
          phoneInfo: that.phoneNumber,
          enrolledAt: enrollmentTime?.toUtc().toIso8601String(),
        ),
    };
  }
}
