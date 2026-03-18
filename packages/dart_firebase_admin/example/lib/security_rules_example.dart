// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/security_rules.dart';

Future<void> securityRulesExample(FirebaseApp admin) async {
  print('\n### Security Rules Example ###\n');

  final securityRules = admin.securityRules();

  // Example 1: Get the currently applied Firestore ruleset
  try {
    print('> Fetching current Firestore ruleset...\n');
    final ruleset = await securityRules.getFirestoreRuleset();
    print('Current Firestore ruleset:');
    print('  - Name: ${ruleset.name}');
    print('  - Created: ${ruleset.createTime}');
    print('');
  } on FirebaseSecurityRulesException catch (e) {
    print('> Security Rules error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error fetching Firestore ruleset: $e');
  }

  // Example 2: Deploy new Firestore rules from source
  try {
    print('> Deploying new Firestore rules...\n');
    const source = """
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
""";
    final ruleset = await securityRules.releaseFirestoreRulesetFromSource(
      source,
    );
    print('Firestore rules deployed successfully!');
    print('  - Ruleset name: ${ruleset.name}');
    print('');
  } on FirebaseSecurityRulesException catch (e) {
    print('> Security Rules error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error deploying Firestore rules: $e');
  }

  // Example 3: Get the currently applied Storage ruleset
  try {
    print('> Fetching current Storage ruleset...\n');
    final ruleset = await securityRules.getStorageRuleset();
    print('Current Storage ruleset:');
    print('  - Name: ${ruleset.name}');
    print('  - Created: ${ruleset.createTime}');
    print('');
  } on FirebaseSecurityRulesException catch (e) {
    print('> Security Rules error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error fetching Storage ruleset: $e');
  }

  // Example 4: Deploy new Storage rules from source
  try {
    print('> Deploying new Storage rules...\n');
    const source = """
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
""";
    final ruleset = await securityRules.releaseStorageRulesetFromSource(source);
    print('Storage rules deployed successfully!');
    print('  - Ruleset name: ${ruleset.name}');
    print('');
  } on FirebaseSecurityRulesException catch (e) {
    print('> Security Rules error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error deploying Storage rules: $e');
  }

  // Example 5: Create a ruleset and delete it
  try {
    print('> Creating a standalone ruleset...\n');
    const source = """
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
""";
    final rulesFile = RulesFile(name: 'firestore.rules', content: source);
    final ruleset = await securityRules.createRuleset(rulesFile);
    print('Ruleset created: ${ruleset.name}');

    await securityRules.deleteRuleset(ruleset.name);
    print('Ruleset deleted successfully!\n');
  } on FirebaseSecurityRulesException catch (e) {
    print('> Security Rules error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error creating/deleting ruleset: $e');
  }

  // Example 6: List existing rulesets
  try {
    print('> Listing rulesets...\n');
    final result = await securityRules.listRulesetMetadata(pageSize: 10);
    print('Found ${result.rulesets.length} ruleset(s):');
    for (final meta in result.rulesets) {
      print('  - ${meta.name} (created: ${meta.createTime})');
    }
    if (result.nextPageToken != null) {
      print('  (more rulesets available — use nextPageToken to paginate)');
    }
    print('');
  } on FirebaseSecurityRulesException catch (e) {
    print('> Security Rules error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error listing rulesets: $e');
  }
}
