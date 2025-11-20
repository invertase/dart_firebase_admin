import 'package:dart_firebase_admin/security_rules.dart';
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';
import '../mock.dart';

void main() {
  late SecurityRules securityRules;

  setUpAll(registerFallbacks);

  setUp(() async {
    final sdk = createApp();
    securityRules = SecurityRules(sdk);
  });

  const simpleFirestoreContent =
      'service cloud.firestore { match /databases/{database}/documents { match /{document=**} { allow read, write: if false; } } }';

  group('SecurityRules', () {
    test('ruleset e2e', () async {
      final ruleset = await securityRules.createRuleset(
        RulesFile(
          name: 'firestore.rules',
          content: simpleFirestoreContent,
        ),
      );

      final ruleset2 = await securityRules.getRuleset(ruleset.name);
      expect(ruleset2.name, ruleset.name);
      expect(ruleset2.createTime, isNotEmpty);
      expect(ruleset2.source.single.name, 'firestore.rules');
      expect(ruleset2.source.single.content, simpleFirestoreContent);

      await securityRules.deleteRuleset(ruleset.name);

      expect(
        securityRules.getRuleset(ruleset.name),
        throwsA(
          isA<FirebaseSecurityRulesException>()
              .having((e) => e.code, 'code', 'security-rules/not-found'),
        ),
      );
    });

    test('listRulesetMetadata', () async {
      final ruleset = await securityRules.createRuleset(
        RulesFile(
          name: 'firestore.rules',
          content: simpleFirestoreContent,
        ),
      );
      final ruleset2 = await securityRules.createRuleset(
        RulesFile(
          name: 'firestore.rules',
          content: '/* hello */ $simpleFirestoreContent',
        ),
      );

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
    });

    test('firestore release flow', () async {
      final ruleset = await securityRules.createRuleset(
        RulesFile(
          name: 'firestore.rules',
          content: simpleFirestoreContent,
        ),
      );

      final before = await securityRules.getFirestoreRuleset();

      expect(before.name, isNot(ruleset.name));

      await securityRules.releaseFirestoreRuleset(ruleset.name);

      final after = await securityRules.getFirestoreRuleset();
      expect(after.name, ruleset.name);
    });
  });
}
