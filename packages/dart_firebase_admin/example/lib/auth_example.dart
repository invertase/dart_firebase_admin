import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

Future<void> authExample(FirebaseApp admin) async {
  print('\n### Auth Example ###\n');

  final auth = admin.auth();

  UserRecord? user;
  try {
    print('> Check if user with email exists: test@example.com\n');
    user = await auth.getUserByEmail('test@example.com');
    print('> User found by email\n');
  } on FirebaseAuthAdminException catch (e) {
    if (e.errorCode == AuthClientErrorCode.userNotFound) {
      print('> User not found, creating new user\n');
      user = await auth.createUser(
        CreateRequest(email: 'test@example.com', password: 'Test@12345'),
      );
    } else {
      print('> Auth error: ${e.errorCode} - ${e.message}');
    }
  } catch (e, stackTrace) {
    print('> Unexpected error: $e');
    print('Stack trace: $stackTrace');
  }

  if (user != null) {
    print('Fetched user email: ${user.email}');
  }
}

Future<void> projectConfigExample(FirebaseApp admin) async {
  print('\n### Project Config Example ###\n');

  final projectConfigManager = admin.auth().projectConfigManager;

  try {
    // Get current project configuration
    print('> Fetching current project configuration...\n');
    final config = await projectConfigManager.getProjectConfig();

    // Display current configuration
    print('Current project configuration:');
    if (config.emailPrivacyConfig != null) {
      print(
        '  - Email Privacy: ${config.emailPrivacyConfig!.enableImprovedEmailPrivacy}',
      );
    }
    if (config.passwordPolicyConfig != null) {
      print(
        '  - Password Policy: ${config.passwordPolicyConfig!.enforcementState}',
      );
    }
    if (config.smsRegionConfig != null) {
      print('  - SMS Region Config: enabled');
    }
    if (config.mobileLinksConfig != null) {
      print('  - Mobile Links: ${config.mobileLinksConfig!.domain?.value}');
    }
    print('');

    // Example: Update email privacy configuration
    print('> Updating email privacy configuration...\n');
    final updatedConfig = await projectConfigManager.updateProjectConfig(
      UpdateProjectConfigRequest(
        emailPrivacyConfig: EmailPrivacyConfig(
          enableImprovedEmailPrivacy: true,
        ),
      ),
    );

    print('Configuration updated successfully!');
    if (updatedConfig.emailPrivacyConfig != null) {
      print(
        '  - Improved Email Privacy: ${updatedConfig.emailPrivacyConfig!.enableImprovedEmailPrivacy}',
      );
    }
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error managing project config: $e');
  }
}

/// Tenant management example.
///
/// Steps to enable Identity Platform:
///
/// 1. Go to Google Cloud Console (not Firebase Console):
///    - Visit: https://console.cloud.google.com/
///    - Select your project
///
/// 2. Enable Identity Platform API:
///    - In the search bar, search for "Identity Platform"
///    - Click on "Identity Platform"
///    - Click "Enable API" if not already enabled
///
/// 3. Upgrade to Identity Platform:
///    - Once in Identity Platform, look for an "Upgrade" or "Get Started" button
///    - Follow the prompts to upgrade from Firebase Auth to Identity Platform
///
/// 4. Enable Multi-tenancy:
///    - After upgrading, go to Settings
///    - Look for "Multi-tenancy" option
///    - Enable it
Future<void> tenantExample(FirebaseApp admin) async {
  print('\n### Tenant Example ###\n');

  final tenantManager = admin.auth().tenantManager;

  String? createdTenantId;

  try {
    print('> Creating a new tenant...\n');
    final newTenant = await tenantManager.createTenant(
      UpdateTenantRequest(
        displayName: 'example-tenant',
        emailSignInConfig: EmailSignInProviderConfig(
          enabled: true,
          passwordRequired: true,
        ),
      ),
    );
    createdTenantId = newTenant.tenantId;

    print('Tenant created successfully!');
    print('  - Tenant ID: ${newTenant.tenantId}');
    print('  - Display Name: ${newTenant.displayName}');
    print('');

    // Get the tenant
    print('> Fetching tenant details...\n');
    final tenant = await tenantManager.getTenant(createdTenantId);
    print('Tenant details:');
    print('  - ID: ${tenant.tenantId}');
    print('  - Display Name: ${tenant.displayName}');
    print('');

    // Update the tenant
    print('> Updating tenant...\n');
    final updatedTenant = await tenantManager.updateTenant(
      createdTenantId,
      UpdateTenantRequest(displayName: 'updated-tenant'),
    );
    print('Tenant updated successfully!');
    print('  - New Display Name: ${updatedTenant.displayName}');
    print('');

    // List tenants
    print('> Listing all tenants...\n');
    final listResult = await tenantManager.listTenants();
    print('Found ${listResult.tenants.length} tenant(s)');
    for (final t in listResult.tenants) {
      print('  - ${t.tenantId}: ${t.displayName}');
    }
    print('');

    // Delete the tenant
    print('> Deleting tenant...\n');
    await tenantManager.deleteTenant(createdTenantId);
    print('Tenant deleted successfully!');
  } on FirebaseAuthAdminException catch (e) {
    if (e.code == 'auth/invalid-project-id') {
      print('> Multi-tenancy is not enabled for this project.');
      print(
        '  Enable it in Firebase Console under Identity Platform settings.',
      );
    } else {
      print('> Auth error: ${e.code} - ${e.message}');
    }

    // Clean up if tenant was created
    if (createdTenantId != null) {
      try {
        await tenantManager.deleteTenant(createdTenantId);
      } catch (_) {
        // Ignore cleanup errors
      }
    }
  } catch (e) {
    print('> Error managing tenants: $e');

    // Clean up if tenant was created
    if (createdTenantId != null) {
      try {
        await tenantManager.deleteTenant(createdTenantId);
      } catch (_) {
        // Ignore cleanup errors
      }
    }
  }
}

Future<void> userManagementExample(FirebaseApp admin) async {
  print('\n### User Management Example ###\n');

  final auth = admin.auth();

  // Create a temporary user to use throughout this example
  late UserRecord tempUser;
  try {
    print('> Creating temporary user for example...\n');
    tempUser = await auth.createUser(
      CreateRequest(
        email: 'temp-example-${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'TempPass@12345',
        displayName: 'Temp Example User',
      ),
    );
    print('Temporary user created: ${tempUser.uid}\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Failed to create temporary user: ${e.code} - ${e.message}');
    return;
  } catch (e) {
    print('> Failed to create temporary user: $e');
    return;
  }

  // getUser
  try {
    print('> Fetching user by UID...\n');
    final user = await auth.getUser(tempUser.uid);
    print('User: ${user.uid} — ${user.email}');
  } on FirebaseAuthAdminException catch (e) {
    if (e.errorCode == AuthClientErrorCode.userNotFound) {
      print('> User not found');
    } else {
      print('> Auth error: ${e.code} - ${e.message}');
    }
  } catch (e) {
    print('> Error: $e');
  }

  // getUserByPhoneNumber
  try {
    print('> Fetching user by phone number...\n');
    final user = await auth.getUserByPhoneNumber('+15551234567');
    print('User by phone: ${user.uid}');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // getUserByProviderUid
  try {
    print('> Fetching user by provider UID...\n');
    final user = await auth.getUserByProviderUid(
      providerId: 'google.com',
      uid: 'google-uid-123',
    );
    print('User by provider: ${user.uid}');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // getUsers (batch lookup)
  try {
    print('> Batch fetching users...\n');
    final result = await auth.getUsers([
      UidIdentifier(uid: tempUser.uid),
      EmailIdentifier(email: tempUser.email!),
    ]);
    print('Found ${result.users.length} user(s)');
    print('Not found: ${result.notFound.length}');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // updateUser
  try {
    print('> Updating user...\n');
    final updated = await auth.updateUser(
      tempUser.uid,
      UpdateRequest(displayName: 'Updated Name', disabled: false),
    );
    print('Updated user: ${updated.displayName}');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // listUsers
  try {
    print('> Listing users (first page)...\n');
    final result = await auth.listUsers(maxResults: 10);
    print('Listed ${result.users.length} user(s)');
    if (result.pageToken != null) {
      print('Next page token: ${result.pageToken}');
    }
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // importUsers
  try {
    print('> Importing users...\n');
    final importResult = await auth.importUsers([
      UserImportRecord(uid: 'import-uid-1', email: 'import1@example.com'),
      UserImportRecord(uid: 'import-uid-2', email: 'import2@example.com'),
    ]);
    print(
      'Import complete: ${importResult.successCount} succeeded, '
      '${importResult.failureCount} failed',
    );
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // deleteUser — clean up the temporary user created at the start
  try {
    print('> Deleting temporary user...\n');
    await auth.deleteUser(tempUser.uid);
    print('Temporary user deleted');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // deleteUsers
  try {
    print('> Deleting multiple users (demo with non-existent UIDs)...\n');
    final result = await auth.deleteUsers(['uid-a', 'uid-b', 'uid-c']);
    print(
      'Deleted: ${result.successCount} succeeded, '
      '${result.failureCount} failed',
    );
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }
}

Future<void> emailLinksExample(FirebaseApp admin) async {
  print('\n### Email Action Links Example ###\n');

  final auth = admin.auth();
  const email = 'user@example.com';
  final actionCodeSettings = ActionCodeSettings(
    url: 'https://example.com/finishSignUp?cartId=1234',
    handleCodeInApp: true,
    iOS: ActionCodeSettingsIos('com.example.ios'),
    android: ActionCodeSettingsAndroid(
      packageName: 'com.example.android',
      installApp: true,
      minimumVersion: '12',
    ),
  );

  // generatePasswordResetLink
  try {
    print('> Generating password reset link...\n');
    final link = await auth.generatePasswordResetLink(
      email,
      actionCodeSettings: actionCodeSettings,
    );
    print('Password reset link: $link\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // generateEmailVerificationLink
  try {
    print('> Generating email verification link...\n');
    final link = await auth.generateEmailVerificationLink(
      email,
      actionCodeSettings: actionCodeSettings,
    );
    print('Email verification link: $link\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // generateVerifyAndChangeEmailLink
  try {
    print('> Generating verify-and-change-email link...\n');
    final link = await auth.generateVerifyAndChangeEmailLink(
      email,
      'newemail@example.com',
      actionCodeSettings: actionCodeSettings,
    );
    print('Verify-and-change-email link: $link\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // generateSignInWithEmailLink
  try {
    print('> Generating sign-in-with-email link...\n');
    final link = await auth.generateSignInWithEmailLink(
      email,
      actionCodeSettings,
    );
    print('Sign-in-with-email link: $link\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }
}

Future<void> tokenExample(FirebaseApp admin) async {
  print('\n### Custom Tokens & ID Token Verification Example ###\n');

  final auth = admin.auth();
  const uid = 'some-uid';

  // setCustomUserClaims
  try {
    print('> Setting custom user claims...\n');
    await auth.setCustomUserClaims(
      uid,
      customUserClaims: {'admin': true, 'accessLevel': 5},
    );
    print('Custom claims set\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // createCustomToken
  try {
    print('> Creating custom token...\n');
    final customToken = await auth.createCustomToken(uid);
    print(
      'Custom token (first 40 chars): ${customToken.substring(0, 40)}...\n',
    );
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // verifyIdToken
  try {
    print('> Verifying ID token...\n');
    final decoded = await auth.verifyIdToken('<id-token-from-client>');
    print('Decoded token:');
    print('  - uid: ${decoded.uid}');
    print('  - email: ${decoded.email}');
    print('  - iss: ${decoded.iss}');
    print('');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // revokeRefreshTokens + verifyIdToken with checkRevoked
  try {
    print('> Revoking refresh tokens for user...\n');
    await auth.revokeRefreshTokens(uid);
    print('Refresh tokens revoked\n');

    print('> Verifying ID token with revocation check...\n');
    final decoded = await auth.verifyIdToken(
      '<id-token-from-client>',
      checkRevoked: true,
    );
    print('Token is still valid: uid=${decoded.uid}\n');
  } on FirebaseAuthAdminException catch (e) {
    if (e.errorCode == AuthClientErrorCode.idTokenRevoked) {
      print('> Token has been revoked — require re-authentication');
    } else {
      print('> Auth error: ${e.code} - ${e.message}');
    }
  } catch (e) {
    print('> Error: $e');
  }
}

Future<void> sessionCookieExample(FirebaseApp admin) async {
  print('\n### Session Cookie Example ###\n');

  final auth = admin.auth();

  // createSessionCookie
  try {
    print('> Creating session cookie...\n');
    final sessionCookie = await auth.createSessionCookie(
      '<id-token-from-client>',
      SessionCookieOptions(expiresIn: const Duration(days: 5).inMilliseconds),
    );
    print(
      'Session cookie created (first 40 chars): '
      '${sessionCookie.substring(0, 40)}...\n',
    );

    // verifySessionCookie
    print('> Verifying session cookie...\n');
    final decoded = await auth.verifySessionCookie(sessionCookie);
    print('Session cookie valid: uid=${decoded.uid}\n');
  } on FirebaseAuthAdminException catch (e) {
    if (e.errorCode == AuthClientErrorCode.sessionCookieRevoked) {
      print('> Session cookie has been revoked');
    } else {
      print('> Auth error: ${e.code} - ${e.message}');
    }
  } catch (e) {
    print('> Error: $e');
  }
}

Future<void> providerConfigExample(FirebaseApp admin) async {
  print('\n### Provider Config Example ###\n');

  final auth = admin.auth();
  const oidcProviderId = 'oidc.my-provider';
  const samlProviderId = 'saml.my-provider';

  // createProviderConfig (OIDC)
  try {
    print('> Creating OIDC provider config...\n');
    final config = await auth.createProviderConfig(
      OIDCAuthProviderConfig(
        providerId: oidcProviderId,
        clientId: 'my-client-id',
        issuer: 'https://accounts.google.com',
        displayName: 'My OIDC Provider',
        enabled: true,
      ),
    );
    print('OIDC provider created: ${config.providerId}\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // createProviderConfig (SAML)
  try {
    print('> Creating SAML provider config...\n');
    final config = await auth.createProviderConfig(
      SAMLAuthProviderConfig(
        providerId: samlProviderId,
        idpEntityId: 'https://idp.example.com',
        ssoURL: 'https://idp.example.com/sso',
        x509Certificates: [
          '-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----',
        ],
        rpEntityId: 'my-rp-entity-id',
        displayName: 'My SAML Provider',
        enabled: true,
      ),
    );
    print('SAML provider created: ${config.providerId}\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // getProviderConfig
  try {
    print('> Fetching OIDC provider config...\n');
    final config = await auth.getProviderConfig(oidcProviderId);
    print('Provider: ${config.providerId} — enabled: ${config.enabled}\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // updateProviderConfig
  try {
    print('> Updating OIDC provider config...\n');
    final updated = await auth.updateProviderConfig(
      oidcProviderId,
      OIDCUpdateAuthProviderRequest(displayName: 'Updated OIDC Provider'),
    );
    print('Updated provider: ${updated.displayName}\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // listProviderConfigs
  try {
    print('> Listing OIDC provider configs...\n');
    final result = await auth.listProviderConfigs(
      AuthProviderConfigFilter.oidc(maxResults: 10),
    );
    print('Found ${result.providerConfigs.length} OIDC provider(s)');
    if (result.pageToken != null) {
      print('Next page token: ${result.pageToken}');
    }
    print('');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }

  // deleteProviderConfig
  try {
    print('> Deleting OIDC provider config...\n');
    await auth.deleteProviderConfig(oidcProviderId);
    print('OIDC provider deleted\n');

    print('> Deleting SAML provider config...\n');
    await auth.deleteProviderConfig(samlProviderId);
    print('SAML provider deleted\n');
  } on FirebaseAuthAdminException catch (e) {
    print('> Auth error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error: $e');
  }
}
