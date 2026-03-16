// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

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
