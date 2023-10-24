part of '../auth.dart';

/// Maximum allowed number of provider configurations to batch download at one time.
const _maxListProviderConfigurationPageSize = 100;

/// Maximum allowed number of users to batch get at one time.
const _maxGetAccountsBatchSize = 100;

/// Maximum allowed number of users to batch download at one time.
const _maxDownloadAccountPageSize = 1000;

/// Maximum allowed number of users to batch delete at one time.
const _maxDeleteAccountsBatchSize = 1000;

/// Maximum allowed number of users to batch upload at one time.
const _maxUploadAccountBatchSize = 1000;

/// Minimum allowed session cookie duration in seconds (5 minutes).
const _minSessionCookieDurationSecs = 5 * 60;

/// Maximum allowed session cookie duration in seconds (2 weeks).
const _maxSessionCookieDurationSecs = 14 * 24 * 60 * 60;

/// List of supported email action request types.
const _emailActionRequestTypes = {
  'PASSWORD_RESET',
  'VERIFY_EMAIL',
  'EMAIL_SIGNIN',
  'VERIFY_AND_CHANGE_EMAIL',
};

abstract class _AbstractAuthRequestHandler {
  _AbstractAuthRequestHandler(this.app) : _httpClient = _AuthHttpClient(app);

  final FirebaseAdminApp app;
  final _AuthHttpClient _httpClient;

  /// Generates the out of band email action link for the email specified using the action code settings provided.
  /// Returns a promise that resolves with the generated link.
  Future<String> getEmailActionLink(
    String requestType,
    String email,
    ActionCodeSettings? actionCodeSettings, [
    String? newEmail,
  ]) async {
    final request = auth1.GoogleCloudIdentitytoolkitV1GetOobCodeRequest(
      requestType: requestType,
      email: email,
      returnOobLink: true,
      newEmail: newEmail,
    );

    // ActionCodeSettings required for email link sign-in to determine the url where the sign-in will
    // be completed.

    if (actionCodeSettings == null && requestType == 'EMAIL_SIGNIN') {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        "`actionCodeSettings` is required when `requestType` === 'EMAIL_SIGNIN'",
      );
    }

    if (actionCodeSettings != null || requestType == 'EMAIL_SIGNIN') {
      final builder = _ActionCodeSettingsBuilder(actionCodeSettings!);
      builder.buildRequest(request);
    }

    if (requestType == 'VERIFY_AND_CHANGE_EMAIL' && newEmail == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        "`newEmail` is required when `requestType` === 'VERIFY_AND_CHANGE_EMAIL'",
      );
    }

    final response = await _httpClient.getOobCode(request);
    return response.oobLink!;
  }

  /// Lists the OIDC configurations (single batch only) with a size of maxResults and starting from
  /// the offset as specified by pageToken.
  Future<auth2.GoogleCloudIdentitytoolkitAdminV2ListOAuthIdpConfigsResponse>
      listOAuthIdpConfigs({int? maxResults, String? pageToken}) async {
    final response = await _httpClient.listOAuthIdpConfigs(
      pageSize: maxResults ?? _maxListProviderConfigurationPageSize,
      pageToken: pageToken,
    );
    if (response.oauthIdpConfigs == null) {
      response.oauthIdpConfigs = [];
      response.nextPageToken = null;
    }
    return response;
  }

  /// Lists the SAML configurations (single batch only) with a size of maxResults and starting from
  /// the offset as specified by pageToken.
  Future<auth2.GoogleCloudIdentitytoolkitAdminV2ListInboundSamlConfigsResponse>
      listInboundSamlConfigs({int? maxResults, String? pageToken}) async {
    final response = await _httpClient.listInboundSamlConfigs(
      pageSize: maxResults ?? _maxListProviderConfigurationPageSize,
      pageToken: pageToken,
    );
    if (response.inboundSamlConfigs == null) {
      response.inboundSamlConfigs = [];
      response.nextPageToken = null;
    }
    return response;
  }

  /// Creates a new OIDC provider configuration with the properties provided.
  Future<auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig>
      createOAuthIdpConfig(
    OIDCAuthProviderConfig options,
  ) async {
    final request = _OIDCConfig.buildServerRequest(options) ??
        auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig();

    final response = await _httpClient.createOAuthIdpConfig(request);

    final name = response.name;
    if (name == null ||
        _OIDCConfig.getProviderIdFromResourceName(name) == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.internalError,
        'INTERNAL ASSERT FAILED: Unable to create OIDC configuration',
      );
    }

    return response;
  }

  /// Creates a new SAML provider configuration with the properties provided.
  Future<auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig>
      createInboundSamlConfig(
    SAMLAuthProviderConfig options,
  ) async {
    final request = _SAMLConfig.buildServerRequest(options) ??
        auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig();

    final response = await _httpClient.createInboundSamlConfig(request);

    final name = response.name;
    if (name == null ||
        _SAMLConfig.getProviderIdFromResourceName(name) == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.internalError,
        'INTERNAL ASSERT FAILED: Unable to create SAML configuration',
      );
    }

    return response;
  }

  /// Sets additional developer claims on an existing user identified by provided UID.
  Future<String> setCustomUserClaims(
    String uid,
    Map<String, Object?>? customUserClaims,
  ) async {
    if (!isUid(uid)) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidUid);
    }

    final claims = customUserClaims ?? <String, Object?>{};

    final request = auth1.GoogleCloudIdentitytoolkitV1SetAccountInfoRequest(
      localId: uid,
      customAttributes: jsonEncode(claims),
    );

    final response = await _httpClient.setAccountInfo(request);
    return response.localId!;
  }

  /// Revokes all refresh tokens for the specified user identified by the uid provided.
  /// In addition to revoking all refresh tokens for a user, all ID tokens issued
  /// before revocation will also be revoked on the Auth backend. Any request with an
  /// ID token generated before revocation will be rejected with a token expired error.
  /// Note that due to the fact that the timestamp is stored in seconds, any tokens minted in
  /// the same second as the revocation will still be valid. If there is a chance that a token
  /// was minted in the last second, delay for 1 second before revoking.
  Future<String> revokeRefreshTokens(String uid) async {
    // Validate user UID.
    if (!isUid(uid)) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidUid);
    }

    final request = auth1.GoogleCloudIdentitytoolkitV1SetAccountInfoRequest(
      localId: uid,
      // validSince is in UTC seconds.
      validSince:
          (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString(),
    );

    final response = await _httpClient.setAccountInfo(request);
    return response.localId!;
  }

  /// Updates an existing OIDC provider configuration with the properties provided.
  Future<auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig>
      updateOAuthIdpConfig(
    String providerId,
    OIDCUpdateAuthProviderRequest options,
  ) async {
    if (!_OIDCConfig.isProviderId(providerId)) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidProviderId);
    }

    final request = _OIDCConfig.buildServerRequest(
      options,
      ignoreMissingFields: true,
    );
    final updateMask = generateUpdateMask(request);

    final response = await _httpClient.updateOAuthIdpConfig(
      request ?? auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig(),
      providerId,
      updateMask: updateMask.join(','),
    );

    final name = response.name;
    if (name == null ||
        _OIDCConfig.getProviderIdFromResourceName(name) == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.internalError,
        'INTERNAL ASSERT FAILED: Unable to update OIDC configuration',
      );
    }

    return response;
  }

  /// Updates an existing SAML provider configuration with the properties provided.
  Future<auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig>
      updateInboundSamlConfig(
    String providerId,
    SAMLUpdateAuthProviderRequest options,
  ) async {
    if (!_SAMLConfig.isProviderId(providerId)) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidProviderId);
    }

    final request = _SAMLConfig.buildServerRequest(
      options,
      ignoreMissingFields: true,
    );
    final updateMask = generateUpdateMask(request);
    final response = await _httpClient.updateInboundSamlConfig(
      request ?? auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig(),
      providerId,
      updateMask: updateMask.join(','),
    );

    final name = response.name;
    if (name == null ||
        _SAMLConfig.getProviderIdFromResourceName(name) == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.internalError,
        'INTERNAL ASSERT FAILED: Unable to update SAML provider configuration',
      );
    }
    return response;
  }

  /// Looks up an OIDC provider configuration by provider ID.
  Future<auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig>
      getOAuthIdpConfig(String providerId) {
    if (!_OIDCConfig.isProviderId(providerId)) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidProviderId,
      );
    }

    return _httpClient.getOauthIdpConfig(providerId);
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig>
      getInboundSamlConfig(String providerId) {
    if (!_SAMLConfig.isProviderId(providerId)) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidProviderId);
    }

    return _httpClient.getInboundSamlConfig(providerId);
  }

  /// Deletes an OIDC configuration identified by a providerId.
  Future<void> deleteOAuthIdpConfig(String providerId) {
    if (!_OIDCConfig.isProviderId(providerId)) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidProviderId,
      );
    }

    return _httpClient.deleteOauthIdpConfig(providerId);
  }

  /// Deletes a SAML configuration identified by a providerId.
  Future<void> deleteInboundSamlConfig(String providerId) {
    if (!_SAMLConfig.isProviderId(providerId)) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidProviderId,
      );
    }

    return _httpClient.deleteInboundSamlConfig(providerId);
  }

  /// Creates a new Firebase session cookie with the specified duration that can be used for
  /// session management (set as a server side session cookie with custom cookie policy).
  /// The session cookie JWT will have the same payload claims as the provided ID token.
  Future<String> createSessionCookie(String idToken, {required int expiresIn}) {
    // Convert to seconds.
    final validDuration = expiresIn / 1000;
    final request =
        auth1.GoogleCloudIdentitytoolkitV1CreateSessionCookieRequest(
      idToken: idToken,
      validDuration: validDuration.toString(),
    );

    return _httpClient.v1((client) async {
      // TODO handle tenant ID

      // Validate the ID token is a non-empty string.
      if (idToken.isEmpty) {
        throw FirebaseAuthAdminException(AuthClientErrorCode.invalidIdToken);
      }

      // Validate the custom session cookie duration.
      if (validDuration < _minSessionCookieDurationSecs ||
          validDuration > _maxSessionCookieDurationSecs) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidSessionCookieDuration,
        );
      }

      final response = await client.projects.createSessionCookie(
        request,
        app.projectId,
      );

      final sessionCookie = response.sessionCookie;
      if (sessionCookie == null || sessionCookie.isEmpty) {
        throw FirebaseAuthAdminException(AuthClientErrorCode.internalError);
      }

      return response.sessionCookie!;
    });
  }

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
    final userImportBuilder = _UserImportBuilder(
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
        requestUsers.length > _maxUploadAccountBatchSize) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.maximumUserCountExceeded,
        'A maximum of $_maxUploadAccountBatchSize users can be imported at once.',
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
    maxResults ??= _maxDownloadAccountPageSize;
    if (pageToken != null && pageToken.isEmpty) {
      throw FirebaseAuthAdminException(AuthClientErrorCode.invalidPageToken);
    }
    if (maxResults <= 0 || maxResults > _maxDownloadAccountPageSize) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        'Required "maxResults" must be a positive integer that does not exceed '
        '$_maxDownloadAccountPageSize.',
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
    } else if (uids.length > _maxDeleteAccountsBatchSize) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.maximumUserCountExceeded,
        '`uids` parameter must have <= $_maxDeleteAccountsBatchSize entries.',
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
          disabled: properties.disabled,
          displayName: properties.displayName?.value,
          email: properties.email,
          emailVerified: properties.emailVerified,
          localId: properties.uid,
          mfaInfo: mfaInfo,
          password: properties.password,
          phoneNumber: properties.phoneNumber?.value,
          photoUrl: properties.photoURL?.value,
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
    } else if (identifiers.length > _maxGetAccountsBatchSize) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.maximumUserCountExceeded,
        '`identifiers` parameter must have <= $_maxGetAccountsBatchSize entries.',
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
        properties.providerToLink?._toProviderUserInfo();

    final providerToUnlink = properties.providersToUnlink;
    if (providerToUnlink != null) {
      deleteProvider ??= [];
      deleteProvider.addAll(providerToUnlink);
    }

    final mfa = properties.multiFactor?.toMfaInfo();

    final request = auth1.GoogleCloudIdentitytoolkitV1SetAccountInfoRequest(
      deleteAttribute: deleteAttribute.isEmpty ? null : deleteAttribute,
      deleteProvider: deleteProvider,
      disableUser: properties.disabled,
      // Will be null if deleted or set to null. "deleteAttribute" will take over
      displayName: properties.displayName?.value,
      email: properties.email,
      emailVerified: properties.emailVerified,
      linkProviderUserInfo: linkProviderUserInfo,
      mfa: mfa,
      password: properties.password,
      // Will be null if deleted or set to null. "deleteProvider" will take over
      phoneNumber: properties.phoneNumber?.value,
      // Will be null if deleted or set to null. "deleteAttribute" will take over
      photoUrl: properties.photoURL?.value,
    );

    final response = await _httpClient.setAccountInfo(request);
    return response.localId!;
  }
}

class _AuthRequestHandler extends _AbstractAuthRequestHandler {
  _AuthRequestHandler(super.app);

  // TODO getProjectConfig
  // TODO updateProjectConfig
  // TODO getTenant
  // TODO listTenants
  // TODO deleteTenant
  // TODO updateTenant
}

class _AuthHttpClient {
  _AuthHttpClient(this.app);

  // TODO handle tenants
  // TODO needs to send "owner" as bearer token when using the emulator
  final FirebaseAdminApp app;

  String _buildParent() => 'projects/${app.projectId}';

  String _buildOAuthIpdParent(String parentId) => 'projects/${app.projectId}/'
      'oauthIdpConfigs/$parentId';

  String _buildSamlParent(String parentId) => 'projects/${app.projectId}/'
      'inboundSamlConfigs/$parentId';

  Future<auth1.GoogleCloudIdentitytoolkitV1GetOobCodeResponse> getOobCode(
    auth1.GoogleCloudIdentitytoolkitV1GetOobCodeRequest request,
  ) {
    return v1((client) async {
      final email = request.email;
      if (email == null || !isEmail(email)) {
        throw FirebaseAuthAdminException(AuthClientErrorCode.invalidEmail);
      }

      final newEmail = request.newEmail;
      if (newEmail != null && !isEmail(newEmail)) {
        throw FirebaseAuthAdminException(AuthClientErrorCode.invalidEmail);
      }

      if (!_emailActionRequestTypes.contains(request.requestType)) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidArgument,
          '"${request.requestType}" is not a supported email action request type.',
        );
      }

      final response = await client.accounts.sendOobCode(request);

      if (response.oobLink == null) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.internalError,
          'INTERNAL ASSERT FAILED: Unable to generate email action link',
        );
      }

      return response;
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2ListInboundSamlConfigsResponse>
      listInboundSamlConfigs({
    required int pageSize,
    String? pageToken,
  }) {
    return v2((client) {
      if (pageToken != null && pageToken.isEmpty) {
        throw FirebaseAuthAdminException(AuthClientErrorCode.invalidPageToken);
      }

      if (pageSize <= 0 || pageSize > _maxListProviderConfigurationPageSize) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidArgument,
          'Required "maxResults" must be a positive integer that does not exceed '
          '$_maxListProviderConfigurationPageSize.',
        );
      }

      return client.projects.inboundSamlConfigs.list(
        _buildParent(),
        pageSize: pageSize,
        pageToken: pageToken,
      );
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2ListOAuthIdpConfigsResponse>
      listOAuthIdpConfigs({
    required int pageSize,
    String? pageToken,
  }) {
    return v2((client) {
      if (pageToken != null && pageToken.isEmpty) {
        throw FirebaseAuthAdminException(AuthClientErrorCode.invalidPageToken);
      }

      if (pageSize <= 0 || pageSize > _maxListProviderConfigurationPageSize) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidArgument,
          'Required "maxResults" must be a positive integer that does not exceed '
          '$_maxListProviderConfigurationPageSize.',
        );
      }

      return client.projects.oauthIdpConfigs.list(
        _buildParent(),
        pageSize: pageSize,
        pageToken: pageToken,
      );
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig>
      createOAuthIdpConfig(
    auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig request,
  ) {
    return v2((client) async {
      final response = await client.projects.oauthIdpConfigs.create(
        request,
        _buildParent(),
      );

      final name = response.name;
      if (name == null || name.isEmpty) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.internalError,
          'INTERNAL ASSERT FAILED: Unable to create OIDC configuration',
        );
      }

      return response;
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig>
      createInboundSamlConfig(
    auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig request,
  ) {
    return v2((client) async {
      final response = await client.projects.inboundSamlConfigs.create(
        request,
        _buildParent(),
      );

      final name = response.name;
      if (name == null || name.isEmpty) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.internalError,
          'INTERNAL ASSERT FAILED: Unable to create SAML configuration',
        );
      }

      return response;
    });
  }

  Future<void> deleteOauthIdpConfig(String providerId) {
    return v2((client) async {
      await client.projects.oauthIdpConfigs.delete(
        _buildOAuthIpdParent(providerId),
      );
    });
  }

  Future<void> deleteInboundSamlConfig(String providerId) {
    return v2((client) async {
      await client.projects.inboundSamlConfigs.delete(
        _buildSamlParent(providerId),
      );
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig>
      updateInboundSamlConfig(
    auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig request,
    String providerId, {
    required String? updateMask,
  }) {
    return v2((client) async {
      final response = await client.projects.inboundSamlConfigs.patch(
        request,
        _buildSamlParent(providerId),
        updateMask: updateMask,
      );

      if (response.name == null || response.name!.isEmpty) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.internalError,
          'INTERNAL ASSERT FAILED: Unable to update SAML configuration',
        );
      }

      return response;
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig>
      updateOAuthIdpConfig(
    auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig request,
    String providerId, {
    required String? updateMask,
  }) {
    return v2((client) async {
      final response = await client.projects.oauthIdpConfigs.patch(
        request,
        _buildOAuthIpdParent(providerId),
        updateMask: updateMask,
      );

      if (response.name == null || response.name!.isEmpty) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.internalError,
          'INTERNAL ASSERT FAILED: Unable to update OIDC configuration',
        );
      }

      return response;
    });
  }

  Future<auth1.GoogleCloudIdentitytoolkitV1SetAccountInfoResponse>
      setAccountInfo(
    auth1.GoogleCloudIdentitytoolkitV1SetAccountInfoRequest request,
  ) {
    return v1((client) async {
      // TODO should this use account/project/update or account/update?
      // Or maybe both?
      // ^ Depending on it, use tenantId... Or do we? The request seems to reject tenantID args
      final response = await client.accounts.update(request);

      final localId = response.localId;
      if (localId == null) {
        throw FirebaseAuthAdminException(AuthClientErrorCode.userNotFound);
      }
      return response;
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig>
      getOauthIdpConfig(String providerId) {
    return v2((client) async {
      final response = await client.projects.oauthIdpConfigs.get(
        _buildOAuthIpdParent(providerId),
      );

      final name = response.name;
      if (name == null || name.isEmpty) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.internalError,
          'INTERNAL ASSERT FAILED: Unable to get OIDC configuration',
        );
      }

      return response;
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig>
      getInboundSamlConfig(String providerId) {
    return v2((client) async {
      final response = await client.projects.inboundSamlConfigs.get(
        _buildSamlParent(providerId),
      );

      final name = response.name;
      if (name == null || name.isEmpty) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.internalError,
          'INTERNAL ASSERT FAILED: Unable to get SAML configuration',
        );
      }

      return response;
    });
  }

  Future<R> _run<R>(
    Future<R> Function(AutoRefreshingAuthClient client) fn,
  ) {
    return _authGuard(() => app.credential.client.then(fn));
  }

  Future<R> v1<R>(
    Future<R> Function(auth1.IdentityToolkitApi client) fn,
  ) {
    return _run(
      (client) => fn(
        auth1.IdentityToolkitApi(
          client,
          rootUrl: app.authApiHost.toString(),
        ),
      ),
    );
  }

  Future<R> v2<R>(
    Future<R> Function(auth2.IdentityToolkitApi client) fn,
  ) async {
    return _run(
      (client) => fn(
        auth2.IdentityToolkitApi(
          client,
          rootUrl: app.authApiHost.toString(),
        ),
      ),
    );
  }

  Future<R> v3<R>(
    Future<R> Function(auth3.IdentityToolkitApi client) fn,
  ) async {
    return _run(
      (client) => fn(
        auth3.IdentityToolkitApi(
          client,
          rootUrl: app.authApiHost.toString(),
        ),
      ),
    );
  }
}
