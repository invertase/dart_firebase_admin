part of '../auth.dart';

class AuthHttpClient {
  AuthHttpClient(this.app);

  final FirebaseApp app;

  /// Gets the Auth API host URL based on emulator configuration.
  ///
  /// When [Environment.firebaseAuthEmulatorHost] is set, routes requests to
  /// the local Auth emulator. Otherwise, uses production Auth API.
  Uri get _authApiHost {
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    final emulatorHost = env[Environment.firebaseAuthEmulatorHost];

    if (emulatorHost != null) {
      return Uri.http(emulatorHost, 'identitytoolkit.googleapis.com/');
    }

    return Uri.https('identitytoolkit.googleapis.com', '/');
  }

  /// Lazy-initialized HTTP client that's cached for reuse.
  /// Uses unauthenticated client for emulator, authenticated for production.
  late final Future<googleapis_auth.AuthClient> _client = _createClient();

  Future<googleapis_auth.AuthClient> get client => _client;

  /// Creates the appropriate HTTP client based on emulator configuration.
  Future<googleapis_auth.AuthClient> _createClient() async {
    // If app has custom httpClient (e.g., mock for testing), always use it
    if (app.options.httpClient != null) {
      return app.client;
    }

    if (Environment.isAuthEmulatorEnabled()) {
      // Emulator: Create unauthenticated client to avoid loading ADC credentials
      // which would cause emulator warnings. Wrap with EmulatorClient to add
      // "Authorization: Bearer owner" header that the emulator requires.
      return EmulatorClient(http.Client());
    }
    // Production: Use authenticated client from app
    return app.client;
  }

  // TODO handle tenants

  /// Builds the parent resource path for project-level operations.
  String buildParent(String projectId) {
    return 'projects/$projectId';
  }

  /// Builds the parent path for OAuth IDP config operations.
  String buildOAuthIdpParent(String projectId, String parentId) {
    return 'projects/$projectId/oauthIdpConfigs/$parentId';
  }

  /// Builds the parent path for SAML config operations.
  String buildSamlParent(String projectId, String parentId) {
    return 'projects/$projectId/inboundSamlConfigs/$parentId';
  }

  Future<auth1.GoogleCloudIdentitytoolkitV1GetOobCodeResponse> getOobCode(
    auth1.GoogleCloudIdentitytoolkitV1GetOobCodeRequest request,
  ) {
    return v1((client, projectId) async {
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
  listInboundSamlConfigs({required int pageSize, String? pageToken}) {
    return v2((client, projectId) async {
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
        buildParent(projectId),
        pageSize: pageSize,
        pageToken: pageToken,
      );
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2ListOAuthIdpConfigsResponse>
  listOAuthIdpConfigs({required int pageSize, String? pageToken}) {
    return v2((client, projectId) async {
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
        buildParent(projectId),
        pageSize: pageSize,
        pageToken: pageToken,
      );
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig>
  createOAuthIdpConfig(
    auth2.GoogleCloudIdentitytoolkitAdminV2OAuthIdpConfig request,
  ) {
    return v2((client, projectId) async {
      final response = await client.projects.oauthIdpConfigs.create(
        request,
        buildParent(projectId),
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
    return v2((client, projectId) async {
      final response = await client.projects.inboundSamlConfigs.create(
        request,
        buildParent(projectId),
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
    return v2((client, projectId) async {
      await client.projects.oauthIdpConfigs.delete(
        buildOAuthIdpParent(projectId, providerId),
      );
    });
  }

  Future<void> deleteInboundSamlConfig(String providerId) {
    return v2((client, projectId) async {
      await client.projects.inboundSamlConfigs.delete(
        buildSamlParent(projectId, providerId),
      );
    });
  }

  Future<auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig>
  updateInboundSamlConfig(
    auth2.GoogleCloudIdentitytoolkitAdminV2InboundSamlConfig request,
    String providerId, {
    required String? updateMask,
  }) {
    return v2((client, projectId) async {
      final response = await client.projects.inboundSamlConfigs.patch(
        request,
        buildSamlParent(projectId, providerId),
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
    return v2((client, projectId) async {
      final response = await client.projects.oauthIdpConfigs.patch(
        request,
        buildOAuthIdpParent(projectId, providerId),
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
    return v1((client, projectId) async {
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
    return v2((client, projectId) async {
      final response = await client.projects.oauthIdpConfigs.get(
        buildOAuthIdpParent(projectId, providerId),
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
    return v2((client, projectId) async {
      final response = await client.projects.inboundSamlConfigs.get(
        buildSamlParent(projectId, providerId),
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

  Future<R> _run<R>(Future<R> Function(googleapis_auth.AuthClient client) fn) {
    return _authGuard(() async {
      // Use the cached client (created once based on emulator configuration)
      final client = await _client;
      return fn(client);
    });
  }

  Future<R> v1<R>(
    Future<R> Function(auth1.IdentityToolkitApi client, String projectId) fn,
  ) async {
    // TODO(demolaf): this can move into _run instead
    final client = await this.client;
    final projectId = await client.getProjectId(
      projectIdOverride: app.options.projectId,
      environment: Zone.current[envSymbol] as Map<String, String>?,
    );
    return _run(
      (client) => fn(
        auth1.IdentityToolkitApi(client, rootUrl: _authApiHost.toString()),
        projectId,
      ),
    );
  }

  Future<R> v2<R>(
    Future<R> Function(auth2.IdentityToolkitApi client, String projectId) fn,
  ) async {
    final client = await this.client;
    final projectId = await client.getProjectId(
      projectIdOverride: app.options.projectId,
      environment: Zone.current[envSymbol] as Map<String, String>?,
    );
    return _run(
      (client) => fn(
        auth2.IdentityToolkitApi(client, rootUrl: _authApiHost.toString()),
        projectId,
      ),
    );
  }

  Future<R> v3<R>(
    Future<R> Function(auth3.IdentityToolkitApi client, String projectId) fn,
  ) async {
    final client = await this.client;
    final projectId = await client.getProjectId(
      projectIdOverride: app.options.projectId,
      environment: Zone.current[envSymbol] as Map<String, String>?,
    );
    return _run(
      (client) => fn(
        auth3.IdentityToolkitApi(client, rootUrl: _authApiHost.toString()),
        projectId,
      ),
    );
  }
}
