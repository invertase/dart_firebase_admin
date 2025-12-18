import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/messaging.dart';

Future<void> main() async {
  final admin = FirebaseApp.initializeApp();
  await authExample(admin);
  await firestoreExample(admin);
  await projectConfigExample(admin);

  // Uncomment to run tenant example (requires Identity Platform upgrade)
  // await tenantExample(admin);

  // Uncomment to run messaging example (requires valid fcm token)
  // await messagingExample(admin);

  await admin.close();
}

Future<void> authExample(FirebaseApp admin) async {
  print('\n### Auth Example ###\n');

  final auth = Auth(admin);

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

Future<void> firestoreExample(FirebaseApp admin) async {
  print('\n### Firestore Example ###\n');

  final firestore = Firestore(admin);

  try {
    final collection = firestore.collection('users');
    await collection.doc('123').set({'name': 'John Doe', 'age': 27});
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      print('> Document data: ${doc.data()}');
    }
  } catch (e) {
    print('> Error setting document: $e');
  }
}

Future<void> projectConfigExample(FirebaseApp admin) async {
  print('\n### Project Config Example ###\n');

  final auth = Auth(admin);
  final projectConfigManager = auth.projectConfigManager;

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
// ignore: unreachable_from_main
Future<void> tenantExample(FirebaseApp admin) async {
  print('\n### Tenant Example ###\n');

  final auth = Auth(admin);
  final tenantManager = auth.tenantManager;

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

// ignore: unreachable_from_main
Future<void> messagingExample(FirebaseApp admin) async {
  print('\n### Messaging Example ###\n');

  final messaging = Messaging(admin);

  // Example 1: Send a message to a topic
  try {
    print('> Sending message to topic: fcm_test_topic\n');
    final messageId = await messaging.send(
      TopicMessage(
        topic: 'fcm_test_topic',
        notification: Notification(
          title: 'Hello World',
          body: 'Dart Firebase Admin SDK works!',
        ),
        data: {'timestamp': DateTime.now().toIso8601String()},
      ),
    );
    print('Message sent successfully!');
    print('  - Message ID: $messageId');
    print('');
  } on FirebaseMessagingAdminException catch (e) {
    print('> Messaging error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error sending message: $e');
  }

  // Example 2: Send multiple messages
  try {
    print('> Sending multiple messages...\n');
    final response = await messaging.sendEach([
      TopicMessage(
        topic: 'topic1',
        notification: Notification(title: 'Message 1'),
      ),
      TopicMessage(
        topic: 'topic2',
        notification: Notification(title: 'Message 2'),
      ),
    ]);

    print('Batch send completed!');
    print('  - Success: ${response.successCount}');
    print('  - Failures: ${response.failureCount}');
    for (var i = 0; i < response.responses.length; i++) {
      final resp = response.responses[i];
      if (resp.success) {
        print('  - Message $i: ${resp.messageId}');
      } else {
        print('  - Message $i failed: ${resp.error?.message}');
      }
    }
    print('');
  } on FirebaseMessagingAdminException catch (e) {
    print('> Messaging error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error sending batch: $e');
  }

  // Example 3: Send multicast message to multiple tokens
  try {
    print('> Sending multicast message...\n');
    // Note: Using fake tokens for demonstration
    final response = await messaging.sendEachForMulticast(
      MulticastMessage(
        tokens: ['fake-token-1', 'fake-token-2'],
        notification: Notification(
          title: 'Multicast Message',
          body: 'This goes to multiple devices',
        ),
      ),
      dryRun: true, // Use dry run to validate without actually sending
    );

    print('Multicast send completed!');
    print('  - Success: ${response.successCount}');
    print('  - Failures: ${response.failureCount}');
    print('');
  } on FirebaseMessagingAdminException catch (e) {
    print('> Messaging error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error sending multicast: $e');
  }

  // Example 4: Subscribe tokens to a topic
  try {
    print('> Subscribing tokens to topic: test-topic\n');
    // Note: Using fake token for demonstration
    final response = await messaging.subscribeToTopic([
      'fake-registration-token',
    ], 'test-topic');

    print('Subscription completed!');
    print('  - Success: ${response.successCount}');
    print('  - Failures: ${response.failureCount}');
    if (response.errors.isNotEmpty) {
      for (final error in response.errors) {
        print('  - Token ${error.index} error: ${error.error.message}');
      }
    }
    print('');
  } on FirebaseMessagingAdminException catch (e) {
    if (e.errorCode == MessagingClientErrorCode.invalidArgument) {
      print('> Invalid topic format or empty tokens list');
    } else {
      print('> Messaging error: ${e.code} - ${e.message}');
    }
  } catch (e) {
    print('> Error subscribing to topic: $e');
  }

  // Example 5: Send with platform-specific options
  try {
    print('> Sending message with platform-specific options...\n');
    final messageId = await messaging.send(
      TokenMessage(
        token: 'fake-device-token',
        notification: Notification(
          title: 'Platform-specific message',
          body: 'With Android and iOS options',
        ),
        android: AndroidConfig(
          priority: AndroidConfigPriority.high,
          notification: AndroidNotification(color: '#FF0000', sound: 'default'),
        ),
        apns: ApnsConfig(
          payload: ApnsPayload(
            aps: Aps(
              contentAvailable: true,
              sound: CriticalSound(critical: true, name: 'default'),
            ),
          ),
        ),
      ),
      dryRun: true, // Use dry run to validate
    );

    print('Platform-specific message validated!');
    print('  - Message ID: $messageId');
  } on FirebaseMessagingAdminException catch (e) {
    if (e.errorCode == MessagingClientErrorCode.invalidRegistrationToken) {
      print('> Invalid registration token format');
    } else {
      print('> Messaging error: ${e.code} - ${e.message}');
    }
  } catch (e) {
    print('> Error sending platform-specific message: $e');
  }
}
