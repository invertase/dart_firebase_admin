import 'package:dart_firebase_admin/security_rules.dart';
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';
import '../mock.dart';

void main() {
  late SecurityRules securityRules;
  final createdRulesets = <String>[];

  setUpAll(registerFallbacks);

  setUp(() async {
    final sdk = createApp();
    securityRules = SecurityRules(sdk);
    createdRulesets.clear();
  });

  tearDown(() async {
    // Clean up any rulesets created during tests
    for (final rulesetName in createdRulesets) {
      try {
        await securityRules.deleteRuleset(rulesetName);
      } catch (_) {
        // Ignore errors during cleanup
      }
    }
  });

  const simpleFirestoreContent =
      'service cloud.firestore { match /databases/{database}/documents { match /{document=**} { allow read, write: if false; } } }';

  const simpleStorageContent =
      'service firebase.storage { match /b/{bucket}/o { match /{allPaths=**} { allow read, write: if request.auth != null; } } }';

  group('SecurityRules', () {
    test(
      'ruleset e2e',
      () async {
        final ruleset = await securityRules.createRuleset(
          RulesFile(name: 'firestore.rules', content: simpleFirestoreContent),
        );
        createdRulesets.add(ruleset.name);

        final ruleset2 = await securityRules.getRuleset(ruleset.name);
        expect(ruleset2.name, ruleset.name);
        expect(ruleset2.createTime, isNotEmpty);
        expect(ruleset2.source.single.name, 'firestore.rules');
        expect(ruleset2.source.single.content, simpleFirestoreContent);

        await securityRules.deleteRuleset(ruleset.name);

        expect(
          securityRules.getRuleset(ruleset.name),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/not-found',
            ),
          ),
        );
      },
      skip: hasGoogleEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
    );

    test(
      'listRulesetMetadata',
      () async {
        final ruleset = await securityRules.createRuleset(
          RulesFile(name: 'firestore.rules', content: simpleFirestoreContent),
        );
        createdRulesets.add(ruleset.name);

        final ruleset2 = await securityRules.createRuleset(
          RulesFile(
            name: 'firestore.rules',
            content: '/* hello */ $simpleFirestoreContent',
          ),
        );
        createdRulesets.add(ruleset2.name);

        final metadata = await securityRules.listRulesetMetadata(pageSize: 1);

        expect(metadata.rulesets.length, 1);
        expect(metadata.nextPageToken, isNotNull);
        expect(metadata.rulesets.single.name, ruleset2.name);

        final metadata2 = await securityRules.listRulesetMetadata(
          pageSize: 1,
          nextPageToken: metadata.nextPageToken,
        );

        expect(metadata2.rulesets.length, 1);
        expect(metadata2.rulesets.single.name, isNot(ruleset2.name));
        expect(metadata2.rulesets.single.name, ruleset.name);
      },
      skip: hasGoogleEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
    );

    test(
      'firestore release flow',
      () async {
        final ruleset = await securityRules.createRuleset(
          RulesFile(name: 'firestore.rules', content: simpleFirestoreContent),
        );
        createdRulesets.add(ruleset.name);

        final before = await securityRules.getFirestoreRuleset();

        expect(before.name, isNot(ruleset.name));

        await securityRules.releaseFirestoreRuleset(ruleset.name);

        final after = await securityRules.getFirestoreRuleset();
        expect(after.name, ruleset.name);
      },
      skip: hasGoogleEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
    );

    test(
      'storage release flow',
      () async {
        const bucket = 'dart-firebase-admin.appspot.com';

        // Create and release a new ruleset from source
        final newRuleset = await securityRules.releaseStorageRulesetFromSource(
          simpleStorageContent,
          bucket,
        );
        createdRulesets.add(newRuleset.name);

        expect(newRuleset.name, isNotEmpty);
        expect(newRuleset.source.length, 1);
        expect(newRuleset.source.single.name, 'storage.rules');
        expect(newRuleset.source.single.content, simpleStorageContent);

        // Verify it was applied by getting the current ruleset
        final after = await securityRules.getStorageRuleset(bucket);
        expect(after.name, newRuleset.name);
        expect(after.source.length, 1);
        expect(after.source.single.content, simpleStorageContent);
      },
      skip: 'Requires Storage bucket to be configured in Firebase project',
    );

    group('Error Handling', () {
      test(
        'getRuleset rejects with not-found for non-existing ruleset',
        () async {
          const nonExistingName = '00000000-1111-2222-3333-444444444444';
          await expectLater(
            securityRules.getRuleset(nonExistingName),
            throwsA(
              isA<FirebaseSecurityRulesException>().having(
                (e) => e.code,
                'code',
                'security-rules/not-found',
              ),
            ),
          );
        },
        skip: hasGoogleEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
      );

      test(
        'getRuleset rejects with invalid-argument for invalid name',
        () async {
          await expectLater(
            securityRules.getRuleset('invalid uuid'),
            throwsA(
              isA<FirebaseSecurityRulesException>().having(
                (e) => e.code,
                'code',
                'security-rules/invalid-argument',
              ),
            ),
          );
        },
        skip: hasGoogleEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
      );

      test(
        'createRuleset rejects with invalid-argument for invalid syntax',
        () async {
          final invalidRulesFile = RulesFile(
            name: 'firestore.rules',
            content: 'invalid syntax',
          );

          await expectLater(
            securityRules.createRuleset(invalidRulesFile),
            throwsA(
              isA<FirebaseSecurityRulesException>().having(
                (e) => e.code,
                'code',
                'security-rules/invalid-argument',
              ),
            ),
          );
        },
        skip: hasGoogleEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
      );

      test(
        'deleteRuleset rejects with not-found for non-existing ruleset',
        () async {
          const nonExistingName = '00000000-1111-2222-3333-444444444444';
          await expectLater(
            securityRules.deleteRuleset(nonExistingName),
            throwsA(
              isA<FirebaseSecurityRulesException>().having(
                (e) => e.code,
                'code',
                'security-rules/not-found',
              ),
            ),
          );
        },
        skip: hasGoogleEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
      );

      test(
        'deleteRuleset rejects with invalid-argument for invalid name',
        () async {
          await expectLater(
            securityRules.deleteRuleset('invalid uuid'),
            throwsA(
              isA<FirebaseSecurityRulesException>().having(
                (e) => e.code,
                'code',
                'security-rules/invalid-argument',
              ),
            ),
          );
        },
        skip: hasGoogleEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
      );
    });
  });
}
