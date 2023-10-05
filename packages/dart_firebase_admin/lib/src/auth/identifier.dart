part of '../auth.dart';

/// Identifies a user to be looked up.
///
/// See also:
/// - [ProviderIdentifier]
/// - [PhoneIdentifier]
/// - [EmailIdentifier]
/// - [UidIdentifier]
sealed class UserIdentifier {}

/// Used for looking up an account by federated provider.
///
/// See [_BaseAuth.getUsers].
class ProviderIdentifier extends UserIdentifier {
  ProviderIdentifier({required this.providerId, required this.providerUid}) {
    if (providerId.isEmpty) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidProviderId);
    }
    if (providerUid.isEmpty) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidProviderUid);
    }
  }

  final String providerId;
  final String providerUid;
}

/// Used for looking up an account by phone number.
///
/// See [_BaseAuth.getUsers].
class PhoneIdentifier extends UserIdentifier {
  PhoneIdentifier({required this.phoneNumber}) {
    assertIsPhoneNumber(phoneNumber);
  }

  final String phoneNumber;
}

/// Used for looking up an account by email.
///
/// See [_BaseAuth.getUsers].
class EmailIdentifier extends UserIdentifier {
  EmailIdentifier({required this.email}) {
    assertIsEmail(email);
  }

  final String email;
}

/// Used for looking up an account by uid.
///
/// See [_BaseAuth.getUsers].
class UidIdentifier extends UserIdentifier {
  UidIdentifier({required this.uid}) {
    assertIsUid(uid);
  }

  final String uid;
}
