import 'package:collection/collection.dart';
import 'package:firebaseapis/identitytoolkit/v1.dart' as auth1;
import 'package:meta/meta.dart';

import '../dart_firebase_admin.dart';
import '../app/core.dart';
import '../utils/validator.dart';
import 'auth_api_request.dart';
import 'auth_config.dart';
import 'identifier.dart';
import 'token_verifier.dart';
import 'user.dart';
import 'user_import_builder.dart';

abstract class BaseAuth {
  FirebaseAdminApp get app;
  @visibleForOverriding
  AbstractAuthRequestHandler get authRequestHandler;
  FirebaseTokenVerifier get _sessionCookieVerifier;

  // TODO createCustomToken
  // TODO verifyIdToken
  // TODO setCustomUserClaims
  // TODO revokeRefreshTokens
  // TODO createSessionCookie
  // TODO verifySessionCookie
  // TODO generatePasswordResetLink
  // TODO generateEmailVerificationLink
  // TODO generateVerifyAndChangeEmailLink
  // TODO generateSignInWithEmailLink
  // TODO listProviderConfigs
  // TODO getProviderConfig
  // TODO deleteProviderConfig
  // TODO updateProviderConfig
  // TODO createProviderConfig

  Future<DecodedIdToken> verifySessionCookie(
    String sessionCookie, {
    bool checkRevoked = false,
  }) async {
    final isEmulator = app.isUsingEmulator;
    throw UnimplementedError();
  }

  /// Imports the provided list of users into Firebase Auth.
  /// A maximum of 1000 users are allowed to be imported one at a time.
  /// When importing users with passwords,
  /// [UserImportOptions] are required to be
  /// specified.
  /// This operation is optimized for bulk imports and will ignore checks on `uid`,
  /// `email` and other identifier uniqueness which could result in duplications.
  ///
  /// - users - The list of user records to import to Firebase Auth.
  /// - options - The user import options, required when the users provided include
  ///   password credentials.
  ///
  /// Returns a Future that resolves when
  /// the operation completes with the result of the import. This includes the
  /// number of successful imports, the number of failed imports and their
  /// corresponding errors.
  Future<UserImportResult> importUsers(
    List<UserImportRecord> users, [
    UserImportOptions? options,
  ]) async {
    return authRequestHandler.uploadAccount(users, options);
  }

  /// Retrieves a list of users (single batch only) with a size of `maxResults`
  /// starting from the offset as specified by `pageToken`. This is used to
  /// retrieve all the users of a specified project in batches.
  ///
  /// See https://firebase.google.com/docs/auth/admin/manage-users#list_all_users
  /// for code samples and detailed documentation.
  ///
  /// - maxResults - The page size, 1000 if undefined. This is also
  ///   the maximum allowed limit.
  /// - pageToken - The next page token. If not specified, returns
  ///   users starting without any offset.
  ///
  /// Returns a promise that resolves with
  /// the current batch of downloaded users and the next page token.
  Future<ListUsersResult> listUsers({
    int? maxResults,
    String? pageToken,
  }) async {
    final response = await authRequestHandler.downloadAccount(
      maxResults: maxResults,
      pageToken: pageToken,
    );

    final users =
        response.users?.map(UserRecord.fromResponse).toList() ?? <UserRecord>[];

    return ListUsersResult._(
      users: users,
      pageToken: response.nextPageToken,
    );
  }

  /// Deletes an existing user.
  ///
  /// See https://firebase.google.com/docs/auth/admin/manage-users#delete_a_user
  /// for code samples and detailed documentation.
  ///
  /// Returns an empty promise fulfilled once the user has been
  /// deleted.
  Future<void> deleteUser(String uid) async {
    await authRequestHandler.deleteAccount(uid);
  }

  /// Deletes the users specified by the given uids.
  ///
  /// Deleting a non-existing user won't generate an error (i.e. this method
  /// is idempotent.) Non-existing users are considered to be successfully
  /// deleted, and are therefore counted in the
  /// `DeleteUsersResult.successCount` value.
  ///
  /// Only a maximum of 1000 identifiers may be supplied. If more than 1000
  /// identifiers are supplied, this method throws a FirebaseAuthError.
  ///
  /// This API is currently rate limited at the server to 1 QPS. If you exceed
  /// this, you may get a quota exceeded error. Therefore, if you want to
  /// delete more than 1000 users, you may need to add a delay to ensure you
  /// don't go over this limit.
  ///
  /// Returns a Futrue that resolves to the total number of successful/failed
  /// deletions, as well as the array of errors that corresponds to the
  /// failed deletions.
  Future<DeleteUsersResult> deleteUsers(List<String> uids) async {
    uids.forEach(assertIsUid);

    final response = await authRequestHandler.deleteAccounts(uids, force: true);
    final errors = response.errors ??
        <auth1.GoogleCloudIdentitytoolkitV1BatchDeleteErrorInfo>[];

    return DeleteUsersResult._(
      successCount: uids.length - errors.length,
      failureCount: errors.length,
      errors: errors.map((batchDeleteErrorInfo) {
        final index = batchDeleteErrorInfo.index;
        if (index == null) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.internalError,
            'Corrupt BatchDeleteAccountsResponse detected',
          );
        }

        FirebaseAuthAdminException errMsgToError(String? msg) {
          // We unconditionally set force=true, so the 'NOT_DISABLED' error
          // should not be possible.
          final code = msg != null && msg.startsWith('NOT_DISABLED')
              ? AuthClientErrorCode.userNotDisabled
              : AuthClientErrorCode.internalError;

          return FirebaseAuthAdminException(code, batchDeleteErrorInfo.message);
        }

        return FirebaseArrayIndexError(
          index: index,
          error: errMsgToError(batchDeleteErrorInfo.message),
        );
      }).toList(),
    );
  }

  /// Gets the user data for the user corresponding to a given `uid`.
  ///
  /// See https://firebase.google.com/docs/auth/admin/manage-users#retrieve_user_data
  /// for code samples and detailed documentation.
  ///
  /// Returns a Future fulfilled with the use data corresponding to the provided `uid`.
  Future<UserRecord> getUser(String uid) async {
    final response = await authRequestHandler.getAccountInfoByUid(uid);
    // Returns the user record populated with server response.
    return UserRecord.fromResponse(response);
  }

  /// Gets the user data for the user corresponding to a given phone number. The
  /// phone number has to conform to the E.164 specification.
  ///
  /// See https://firebase.google.com/docs/auth/admin/manage-users#retrieve_user_data
  /// for code samples and detailed documentation.
  ///
  /// Takes the phone number corresponding to the user whose
  /// data to fetch.
  ///
  /// Returns a Future fulfilled with the user
  /// data corresponding to the provided phone number.
  Future<UserRecord> getUserByPhoneNumber(String phoneNumber) async {
    final response =
        await authRequestHandler.getAccountInfoByPhoneNumber(phoneNumber);
    // Returns the user record populated with server response.
    return UserRecord.fromResponse(response);
  }

  /// Gets the user data for the user corresponding to a given email.
  ///
  /// See https://firebase.google.com/docs/auth/admin/manage-users#retrieve_user_data
  /// for code samples and detailed documentation.
  ///
  /// Receives the email corresponding to the user whose data to fetch.
  ///
  /// Returns a promise fulfilled with the user
  /// data corresponding to the provided email.
  Future<UserRecord> getUserByEmail(String email) async {
    final response = await authRequestHandler.getAccountInfoByEmail(email);
    // Returns the user record populated with server response.
    return UserRecord.fromResponse(response);
  }

  /// Gets the user data for the user corresponding to a given provider id.
  ///
  /// See https://firebase.google.com/docs/auth/admin/manage-users#retrieve_user_data
  /// for code samples and detailed documentation.
  ///
  /// - `providerId`: The provider ID, for example, "google.com" for the
  ///   Google provider.
  /// - `uid`: The user identifier for the given provider.
  ///
  /// Returns a Future fulfilled with the user data corresponding to the
  /// given provider id.
  Future<UserRecord> getUserByProviderUid({
    required String providerId,
    required String uid,
  }) async {
    // Although we don't really advertise it, we want to also handle
    // non-federated idps with this call. So if we detect one of them, we'll
    // reroute this request appropriately.
    if (providerId == 'phone') {
      return getUserByPhoneNumber(uid);
    } else if (providerId == 'email') {
      return getUserByEmail(uid);
    }

    final response = await authRequestHandler.getAccountInfoByFederatedUid(
      providerId: providerId,
      rawId: uid,
    );

    // Returns the user record populated with server response.
    return UserRecord.fromResponse(response);
  }

  /// Gets the user data corresponding to the specified identifiers.
  ///
  /// There are no ordering guarantees; in particular, the nth entry in the result list is not
  /// guaranteed to correspond to the nth entry in the input parameters list.
  ///
  /// Only a maximum of 100 identifiers may be supplied. If more than 100 identifiers are supplied,
  /// this method throws a FirebaseAuthError.
  ///
  /// Takes a list of [UserIdentifier] used to indicate which user records should be returned.
  /// Must not have more than 100 entries.
  ///
  /// Returns a Future that resolves to the corresponding user records.
  /// Throws [FirebaseAdminException] if any of the identifiers are invalid or if more than 100
  ///  identifiers are specified.
  Future<GetUsersResult> getUsers(List<UserIdentifier> identifiers) async {
    final response =
        await authRequestHandler.getAccountInfoByIdentifiers(identifiers);

    final userRecords = response.users?.map(UserRecord.fromResponse).toList() ??
        const <UserRecord>[];

    // Checks if the specified identifier is within the list of UserRecords.
    bool isUserFound(UserIdentifier id) {
      return userRecords.any((userRecord) {
        switch (id) {
          case UidIdentifier():
            return id.uid == userRecord.uid;
          case EmailIdentifier():
            return id.email == userRecord.email;
          case PhoneIdentifier():
            return id.phoneNumber == userRecord.phoneNumber;
          case ProviderIdentifier():
            final matchingUserInfo = userRecord.providerData
                .firstWhereOrNull((userInfo) => userInfo.phoneNumber != null);
            return matchingUserInfo != null &&
                id.providerUid == matchingUserInfo.uid;
        }
      });
    }

    final notFound = identifiers.where((id) => !isUserFound(id)).toList();

    return GetUsersResult._(users: userRecords, notFound: notFound);
  }

  /// Creates a new user.
  ///
  /// See https://firebase.google.com/docs/auth/admin/manage-users#create_a_user
  /// for code samples and detailed documentation.
  ///
  /// Returns A Future fulfilled with the user
  /// data corresponding to the newly created user.
  Future<UserRecord> createUser(CreateRequest properties) async {
    return authRequestHandler
        .createNewAccount(properties)
        // Return the corresponding user record.
        .then(getUser)
        .onError<FirebaseAuthAdminException>((error, _) {
      if (error.errorCode == AuthClientErrorCode.userNotFound) {
        // Something must have happened after creating the user and then retrieving it.
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.internalError,
          'Unable to create the user record provided.',
        );
      }
      throw error;
    });
  }

  /// Updates an existing user.
  ///
  /// See https://firebase.google.com/docs/auth/admin/manage-users#update_a_user
  /// for code samples and detailed documentation.
  ///
  /// - uid - The `uid` corresponding to the user to update.
  /// - properties - The properties to update on the provided user.
  ///
  /// Returns a [Future] fulfilled with the updated user data.
  Future<UserRecord> updateuser(String uid, UpdateRequest properties) async {
    // Although we don't really advertise it, we want to also handle linking of
    // non-federated idps with this call. So if we detect one of them, we'll
    // adjust the properties parameter appropriately. This *does* imply that a
    // conflict could arise, e.g. if the user provides a phoneNumber property,
    // but also provides a providerToLink with a 'phone' provider id. In that
    // case, we'll throw an error.
    var request = properties;
    final providerToLink = properties.providerToLink;
    switch (providerToLink) {
      case UserProvider(providerId: 'email'):
        if (properties.email != null) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidArgument,
            "Both UpdateRequest.email and UpdateRequest.providerToLink.providerId='email' were set. To "
            'link to the email/password provider, only specify the UpdateRequest.email field.',
          );
        }
        request = properties.copyWith(email: providerToLink.uid);
      case UserProvider(providerId: 'phone'):
        if (properties.phoneNumber != null) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidArgument,
            "Both UpdateRequest.phoneNumber and UpdateRequest.providerToLink.providerId='phone' were set. To "
            'link to a phone provider, only specify the UpdateRequest.phoneNumber field.',
          );
        }
        request = properties.copyWith(phoneNumber: providerToLink.uid);
    }
    final providersToUnlink = properties.providersToUnlink;
    if (providersToUnlink != null && providersToUnlink.contains('phone')) {
      // If we've been told to unlink the phone provider both via setting
      // phoneNumber to null *and* by setting providersToUnlink to include
      // 'phone', then we'll reject that. Though it might also be reasonable
      // to relax this restriction and just unlink it.
      if (properties.phoneNumber == null) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidArgument,
          "Both UpdateRequest.phoneNumber and UpdateRequest.providersToUnlink=['phone'] were set. To "
          'unlink the phone provider, only specify the UpdateRequest.providersToUnlink field.',
        );
      }
    }

    final existingUid =
        await authRequestHandler.updateExistingAccount(uid, request);
    return getUser(existingUid);
  }
}

/// Interface representing the object returned from a
/// [BaseAuth.listUsers] operation. Contains the list
/// of users for the current batch and the next page token if available.
class ListUsersResult {
  ListUsersResult._({required this.users, required this.pageToken});

  /// The list of {@link UserRecord} objects for the
  /// current downloaded batch.
  final List<UserRecord> users;

  /// The next page token if available. This is needed for the next batch download.
  final String? pageToken;
}

/// Represents the result of the {@link BaseAuth.getUsers} API.
class GetUsersResult {
  GetUsersResult._({required this.users, required this.notFound});

  /// Set of user records, corresponding to the set of users that were
  /// requested. Only users that were found are listed here. The result set is
  /// unordered.
  final List<UserRecord> users;

  /// Set of identifiers that were requested, but not found.
  final List<UserIdentifier> notFound;
}

/// Represents the result of the {@link BaseAuth.deleteUsers}.
/// API.
class DeleteUsersResult {
  DeleteUsersResult._({
    required this.failureCount,
    required this.successCount,
    required this.errors,
  });

  /// The number of user records that failed to be deleted (possibly zero).
  final int failureCount;

  /// The number of users that were deleted successfully (possibly zero).
  /// Users that did not exist prior to calling `deleteUsers()` are
  /// considered to be successfully deleted.
  final int successCount;

  /// A list of `FirebaseArrayIndexError` instances describing the errors that
  /// were encountered during the deletion. Length of this list is equal to
  /// the return value of {@link DeleteUsersResult.failureCount}.
  final List<FirebaseArrayIndexError> errors;
}

/// Interface representing the response from the
/// [BaseAuth.importUsers] method for batch
/// importing users to Firebase Auth.
class UserImportResult {
  @internal
  UserImportResult({
    required this.failureCount,
    required this.successCount,
    required this.errors,
  });

  /// The number of user records that failed to import to Firebase Auth.
  final int failureCount;

  /// The number of user records that successfully imported to Firebase Auth.
  final int successCount;

  /// An array of errors corresponding to the provided users to import. The
  /// length of this array is equal to [failureCount].
  final List<FirebaseArrayIndexError> errors;
}
