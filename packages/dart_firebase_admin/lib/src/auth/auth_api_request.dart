import 'package:firebaseapis/identitytoolkit/v1.dart' as auth1;
import 'package:firebaseapis/identitytoolkit/v2.dart' as auth2;
import 'package:firebaseapis/identitytoolkit/v3.dart' as auth3;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

import '../../dart_firebase_admin.dart';
import '../utils/validator.dart';
import 'auth_config.dart';
import 'base_auth.dart';
import 'identifier.dart';
import 'user_import_builder.dart';

/// Maximum allowed number of users to batch get at one time.
const maxGetAccountsBatchSize = 100;

/// Maximum allowed number of users to batch download at one time.
const maxDownloadAccountPageSize = 1000;

/// Maximum allowed number of users to batch delete at one time.
const maxDeleteAccountsBatchSize = 1000;

/// Maximum allowed number of users to batch upload at one time.
const maxUploadAccountBatchSize = 1000;

abstract class AbstractAuthRequestHandler {
  AbstractAuthRequestHandler(this.app) : _httpClient = _AuthHttpClient(app);

  final FirebaseAdminApp app;
  final _AuthHttpClient _httpClient;

  /// Imports the list of users provided to Firebase Auth. This is useful when
  /// migrating from an external authentication system without having to use the Firebase CLI SDK.
  /// At most, 1000 users are allowed to be imported one at a time.
  /// When importing a list of password users, UserImportOptions are required to be specified.
  ///
  /// - users - The list of user records to import to Firebase Auth.
  /// - options - The user import options, required when the users provided
  ///     include password credentials.
  ///
  /// Returns a Future that resolves when the operation completes
  /// with the result of the import. This includes the number of successful imports, the number
  /// of failed uploads and their corresponding errors.
  Future<UserImportResult> uploadAccount(
    List<UserImportRecord> users,
    UserImportOptions? options,
  ) async {
    // This will throw if any error is detected in the hash options.
    // For errors in the list of users, this will not throw and will report the errors and the
    // corresponding user index in the user import generated response below.
    // No need to validate raw request or raw response as this is done in UserImportBuilder.
    final userImportBuilder = UserImportBuilder(
      users: users,
      options: options,
      userRequestValidator: (userRequest) {
        // Pass true to validate the uploadAccount specific fields.
        // TODO validateCreateEditRequest
      },
    );

    final request = userImportBuilder.buildRequest();
    final requestUsers = request.users;
    // Fail quickly if more users than allowed are to be imported.
    if (requestUsers != null &&
        requestUsers.length > maxUploadAccountBatchSize) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.maximumUserCountExceeded,
        'A maximum of $maxUploadAccountBatchSize users can be imported at once.',
      );
    }
    // If no remaining user in request after client side processing, there is no need
    // to send the request to the server.
    if (requestUsers == null || requestUsers.isEmpty) {
      return userImportBuilder.buildResponse([]);
    }

    return _httpClient.v1((client) async {
      final response = await client.projects.accounts_1.batchCreate(
        request,
        app.projectId,
      );
      // No error object is returned if no error encountered.
      // Rewrite response as UserImportResult and re-insert client previously detected errors.
      return userImportBuilder.buildResponse(response.error ?? const []);
    });
  }

  /// Exports the users (single batch only) with a size of maxResults and starting from
  /// the offset as specified by pageToken.
  ///
  /// maxResults - The page size, 1000 if undefined. This is also the maximum
  /// allowed limit.
  ///
  /// pageToken - The next page token. If not specified, returns users starting
  /// without any offset. Users are returned in the order they were created from oldest to
  /// newest, relative to the page token offset.
  ///
  /// Returns a Future that resolves with the current batch of downloaded
  /// users and the next page token if available. For the last page, an empty list of users
  /// and no page token are returned.
  Future<auth1.GoogleCloudIdentitytoolkitV1DownloadAccountResponse>
      downloadAccount({
    required int? maxResults,
    required String? pageToken,
  }) {
    maxResults ??= maxDownloadAccountPageSize;
    if (pageToken != null && pageToken.isEmpty) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidPageToken);
    }
    if (maxResults <= 0 || maxResults > maxDownloadAccountPageSize) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        'Required "maxResults" must be a positive integer that does not exceed '
        '$maxDownloadAccountPageSize.',
      );
    }

    return _httpClient.v1((client) async {
      // TODO handle tenants
      return client.projects.accounts_1.batchGet(
        app.projectId,
        maxResults: maxResults,
        nextPageToken: pageToken,
      );
    });
  }

  /// Deletes an account identified by a uid.
  Future<auth1.GoogleCloudIdentitytoolkitV1DeleteAccountResponse> deleteAccount(
    String uid,
  ) async {
    assertIsUid(uid);

    // TODO handle tenants
    return _httpClient.v1((client) async {
      return client.projects.accounts_1.delete(
        auth1.GoogleCloudIdentitytoolkitV1DeleteAccountRequest(localId: uid),
        app.projectId,
      );
    });
  }

  Future<auth1.GoogleCloudIdentitytoolkitV1BatchDeleteAccountsResponse>
      deleteAccounts(
    List<String> uids, {
    required bool force,
  }) async {
    if (uids.isEmpty) {
      return auth1.GoogleCloudIdentitytoolkitV1BatchDeleteAccountsResponse();
    } else if (uids.length > maxDeleteAccountsBatchSize) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.maximumUserCountExceeded,
        '`uids` parameter must have <= $maxDeleteAccountsBatchSize entries.',
      );
    }

    return _httpClient.v1((client) async {
      // TODO handle tenants
      return client.projects.accounts_1.batchDelete(
        auth1.GoogleCloudIdentitytoolkitV1BatchDeleteAccountsRequest(
          localIds: uids,
          force: force,
        ),
        app.projectId,
      );
    });
  }

  /// Create a new user with the properties supplied.
  ///
  /// A [Future] that resolves when the operation completes
  /// with the user id that was created.
  Future<String> createNewAccount(CreateRequest properties) async {
    return _httpClient.v1((client) async {
      var mfaInfo = properties.multiFactor?.enrolledFactors
          .map((info) => info.toGoogleCloudIdentitytoolkitV1MfaFactor())
          .toList();
      if (mfaInfo != null && mfaInfo.isEmpty) mfaInfo = null;

      // TODO support tenants
      final response = await client.projects.accounts(
        auth1.GoogleCloudIdentitytoolkitV1SignUpRequest(
          captchaChallenge: null,
          captchaResponse: null,
          disabled: properties.disabled,
          displayName: properties.displayName?.value,
          email: properties.email,
          emailVerified: properties.emailVerified,
          idToken: null,
          instanceId: null,
          localId: properties.uid,
          mfaInfo: mfaInfo,
          password: properties.password,
          phoneNumber: properties.phoneNumber?.value,
          photoUrl: properties.photoURL?.value,
          targetProjectId: null,
          tenantId: null,
        ),
        app.projectId,
      );

      final localId = response.localId;
      if (localId == null) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.internalError,
          'INTERNAL ASSERT FAILED: Unable to create new user',
        );
      }

      return localId;
    });
  }

  Future<auth1.GoogleCloudIdentitytoolkitV1GetAccountInfoResponse>
      _accountsLookup(
    auth1.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest request,
  ) async {
    // TODO handle tenants
    return _httpClient.v1((client) async {
      final response = await client.accounts.lookup(request);
      final users = response.users;
      if (users == null || users.isEmpty) {
        throw FirebaseAuthAdminException(AuthClientErrorCode.userNotFound);
      }
      return response;
    });
  }

  /// Looks up a user by uid.
  ///
  /// Returns a Future that resolves with the user information.
  Future<auth1.GoogleCloudIdentitytoolkitV1UserInfo> getAccountInfoByUid(
    String uid,
  ) async {
    final response = await _accountsLookup(
      auth1.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest(localId: [uid]),
    );

    return response.users!.single;
  }

  /// Looks up a user by email.
  Future<auth1.GoogleCloudIdentitytoolkitV1UserInfo> getAccountInfoByEmail(
    String email,
  ) async {
    assertIsEmail(email);

    final response = await _accountsLookup(
      auth1.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest(email: [email]),
    );

    return response.users!.single;
  }

  /// Looks up a user by phone number.
  Future<auth1.GoogleCloudIdentitytoolkitV1UserInfo>
      getAccountInfoByPhoneNumber(
    String phoneNumber,
  ) async {
    assertIsPhoneNumber(phoneNumber);

    final response = await _accountsLookup(
      auth1.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest(
        phoneNumber: [phoneNumber],
      ),
    );

    return response.users!.single;
  }

  Future<auth1.GoogleCloudIdentitytoolkitV1UserInfo>
      getAccountInfoByFederatedUid({
    required String providerId,
    required String rawId,
  }) async {
    if (providerId.isEmpty || rawId.isEmpty) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidProviderId);
    }

    final response = await _accountsLookup(
      auth1.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest(
        federatedUserId: [
          auth1.GoogleCloudIdentitytoolkitV1FederatedUserIdentifier(
            providerId: providerId,
            rawId: rawId,
          ),
        ],
      ),
    );

    return response.users!.single;
  }

  /// Looks up multiple users by their identifiers (uid, email, etc).
  Future<auth1.GoogleCloudIdentitytoolkitV1GetAccountInfoResponse>
      getAccountInfoByIdentifiers(
    List<UserIdentifier> identifiers,
  ) async {
    if (identifiers.isEmpty) {
      return auth1.GoogleCloudIdentitytoolkitV1GetAccountInfoResponse(
        users: [],
      );
    } else if (identifiers.length > maxGetAccountsBatchSize) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.maximumUserCountExceeded,
        '`identifiers` parameter must have <= $maxGetAccountsBatchSize entries.',
      );
    }

    final request = auth1.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest();

    for (final id in identifiers) {
      switch (id) {
        case UidIdentifier():
          final localIds = request.localId ?? <String>[];
          localIds.add(id.uid);
        case EmailIdentifier():
          final emails = request.email ?? <String>[];
          emails.add(id.email);
        case PhoneIdentifier():
          final phoneNumbers = request.phoneNumber ?? <String>[];
          phoneNumbers.add(id.phoneNumber);
        case ProviderIdentifier():
          final providerIds = request.federatedUserId ?? <String>[];
          providerIds.add(id.providerId);
      }
    }

    // TODO handle tenants
    return _httpClient.v1((client) => client.accounts.lookup(request));
  }

  /// Edits an existing user.
  ///
  /// - uid - The user to edit.
  /// - properties - The properties to set on the user.
  ///
  /// Returns a [Future] that resolves when the operation completes
  /// with the user id that was edited.
  Future<String> updateExistingAccount(
    String uid,
    UpdateRequest properties,
  ) async {
    assertIsUid(uid);

    final providerToLink = properties.providerToLink;
    if (providerToLink != null) {
      if (providerToLink.providerId?.isNotEmpty ?? false) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidArgument,
          'providerToLink.providerId of properties argument must be a non-empty string.',
        );
      }
      if (providerToLink.uid?.isNotEmpty ?? false) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidArgument,
          'providerToLink.uid of properties argument must be a non-empty string.',
        );
      }
    }
    final providersToUnlink = properties.providersToUnlink;
    if (providersToUnlink != null) {
      for (final provider in providersToUnlink) {
        if (provider.isEmpty) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidArgument,
            'providersToUnlink of properties argument must be a non-empty string.',
          );
        }
      }
    }

    // For deleting some attributes, these values must be passed as Box(null).
    final isPhotoDeleted =
        properties.photoURL != null && properties.photoURL?.value == null;
    final isDisplayNameDeleted =
        properties.displayName != null && properties.displayName?.value == null;
    final isPhoneNumberDeleted =
        properties.phoneNumber != null && properties.phoneNumber?.value == null;

    // They will be removed from the backend request and an additional parameter
    // deleteAttribute: ['PHOTO_URL', 'DISPLAY_NAME']
    // with an array of the parameter names to delete will be passed.
    final deleteAttribute = [
      if (isPhotoDeleted) 'PHOTO_URL',
      if (isDisplayNameDeleted) 'DISPLAY_NAME',
    ];

    // Phone will be removed from the backend request and an additional parameter
    // deleteProvider: ['phone'] with an array of providerIds (phone in this case),
    // will be passed.
    List<String>? deleteProvider;
    if (isPhoneNumberDeleted) deleteProvider = ['phone'];

    final linkProviderUserInfo =
        properties.providerToLink?.toProviderUserInfo();

    final providerToUnlink = properties.providersToUnlink;
    if (providerToUnlink != null) {
      deleteProvider ??= [];
      deleteProvider.addAll(providerToUnlink);
    }

    final mfa = properties.multiFactor?.toMfaInfo();

    return _httpClient.v1((client) async {
      final response = await client.accounts.update(
        auth1.GoogleCloudIdentitytoolkitV1SetAccountInfoRequest(
          captchaChallenge: null,
          captchaResponse: null,
          createdAt: null,
          customAttributes: null,
          delegatedProjectNumber: null,
          deleteAttribute: deleteAttribute.isEmpty ? null : deleteAttribute,
          deleteProvider: deleteProvider,
          disableUser: properties.disabled,
          // Will be null if deleted or set to null. "deleteAttribute" will take over
          displayName: properties.displayName?.value,
          email: properties.email,
          emailVerified: properties.emailVerified,
          idToken: null,
          instanceId: null,
          lastLoginAt: null,
          linkProviderUserInfo: linkProviderUserInfo,
          localId: null,
          mfa: mfa,
          oobCode: null,
          password: properties.password,
          // Will be null if deleted or set to null. "deleteProvider" will take over
          phoneNumber: properties.phoneNumber?.value,
          // Will be null if deleted or set to null. "deleteAttribute" will take over
          photoUrl: properties.photoURL?.value,
          provider: null,
          returnSecureToken: null,
          targetProjectId: null,
          tenantId: null,
          upgradeToFederatedLogin: null,
          validSince: null,
        ),
      );

      final localId = response.localId;
      if (localId == null) {
        throw FirebaseAuthAdminException(AuthClientErrorCode.userNotFound);
      }

      return localId;
    });
  }
}

class _AuthHttpClient {
  _AuthHttpClient(this.app);

  // TODO needs to send "owner" as bearer token when using the emulator
  final FirebaseAdminApp app;

  auth.AuthClient? _client;

  Future<auth.AuthClient> _getClient() async {
    return _client ??= await app.credential.getAuthClient([
      auth3.IdentityToolkitApi.cloudPlatformScope,
      auth3.IdentityToolkitApi.firebaseScope,
    ]);
  }

  Future<R> v1<R>(
    Future<R> Function(auth1.IdentityToolkitApi client) fn,
  ) {
    return guard(
      () async => fn(
        auth1.IdentityToolkitApi(
          await _getClient(),
          rootUrl: app.authApiHost.toString(),
        ),
      ),
    );
  }

  Future<R> v2<R>(
    Future<R> Function(auth2.IdentityToolkitApi client) fn,
  ) async {
    return guard(
      () async => fn(
        auth2.IdentityToolkitApi(
          await _getClient(),
          rootUrl: app.authApiHost.toString(),
        ),
      ),
    );
  }

  Future<R> v3<R>(
    Future<R> Function(auth3.IdentityToolkitApi client) fn,
  ) async {
    return guard(
      () async => fn(
        auth3.IdentityToolkitApi(
          await _getClient(),
          rootUrl: app.authApiHost.toString(),
        ),
      ),
    );
  }
}
