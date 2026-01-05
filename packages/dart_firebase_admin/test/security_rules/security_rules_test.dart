import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/src/security_rules/security_rules.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mock.dart';
import '../mock_service_account.dart';

// Mock classes
class MockSecurityRulesRequestHandler extends Mock
    implements SecurityRulesRequestHandler {}

void main() {
  late SecurityRules securityRules;
  late FirebaseApp app;
  late MockSecurityRulesRequestHandler mockRequestHandler;

  // Test data
  final firestoreRulesetResponse = RulesetResponse.forTest(
    name: 'projects/test-project/rulesets/foo',
    createTime: '2019-03-08T23:45:23.288047Z',
    source: RulesetSource(
      files: [
        RulesFile(
          name: 'firestore.rules',
          content: r'service cloud.firestore{\n}\n',
        ),
      ],
    ),
  );

  final firestoreRelease = Release.forTest(
    name: 'projects/test-project/releases/firestore.release',
    rulesetName: 'projects/test-project/rulesets/foo',
    createTime: '2019-03-08T23:45:23.288047Z',
  );

  final expectedError = FirebaseSecurityRulesException(
    FirebaseSecurityRulesErrorCode.internalError,
    'message',
  );

  setUpAll(() {
    registerFallbacks();
    registerFallbackValue(RulesetContent(source: RulesetSource(files: [])));
  });

  setUp(() {
    app = FirebaseApp.initializeApp(
      name: 'security-rules-test',
      options: AppOptions(
        credential: Credential.fromServiceAccountParams(
          clientId: 'test-client-id',
          privateKey: mockPrivateKey,
          email: mockClientEmail,
          projectId: mockProjectId,
        ),
        storageBucket: 'bucketName.appspot.com',
      ),
    );
    mockRequestHandler = MockSecurityRulesRequestHandler();
    securityRules = SecurityRules.internal(
      app,
      requestHandler: mockRequestHandler,
    );
  });

  tearDown(() {
    FirebaseApp.apps.forEach(FirebaseApp.deleteApp);
  });

  group('SecurityRules', () {
    group('Constructor', () {
      test('should not throw given a valid app', () {
        expect(() => SecurityRules(app), returnsNormally);
      });

      test('should return the same instance for the same app', () {
        final instance1 = SecurityRules(app);
        final instance2 = SecurityRules(app);

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('app property', () {
      test('returns the app from the constructor', () {
        expect(securityRules.app, equals(app));
        expect(securityRules.app.name, equals('security-rules-test'));
      });
    });

    group('getRuleset()', () {
      test('should propagate API errors', () async {
        when(
          () => mockRequestHandler.getRuleset(any()),
        ).thenThrow(expectedError);

        await expectLater(
          securityRules.getRuleset('foo'),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/internal-error',
            ),
          ),
        );
      });

      test('should resolve with Ruleset on success', () async {
        when(
          () => mockRequestHandler.getRuleset('foo'),
        ).thenAnswer((_) async => firestoreRulesetResponse);

        final ruleset = await securityRules.getRuleset('foo');

        expect(ruleset.name, equals('foo'));
        expect(ruleset.createTime, equals('2019-03-08T23:45:23.288047Z'));
        expect(ruleset.source.length, equals(1));

        final file = ruleset.source[0];
        expect(file.name, equals('firestore.rules'));
        expect(file.content, equals(r'service cloud.firestore{\n}\n'));

        verify(() => mockRequestHandler.getRuleset('foo')).called(1);
      });
    });

    group('getFirestoreRuleset()', () {
      test('should propagate API errors', () async {
        when(
          () => mockRequestHandler.getRelease(any()),
        ).thenThrow(expectedError);

        await expectLater(
          securityRules.getFirestoreRuleset(),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/internal-error',
            ),
          ),
        );
      });

      test('should resolve with Ruleset on success', () async {
        when(
          () => mockRequestHandler.getRelease('cloud.firestore'),
        ).thenAnswer((_) async => firestoreRelease);
        when(
          () => mockRequestHandler.getRuleset('foo'),
        ).thenAnswer((_) async => firestoreRulesetResponse);

        final ruleset = await securityRules.getFirestoreRuleset();

        expect(ruleset.name, equals('foo'));
        expect(ruleset.createTime, equals('2019-03-08T23:45:23.288047Z'));
        expect(ruleset.source.length, equals(1));

        final file = ruleset.source[0];
        expect(file.name, equals('firestore.rules'));

        verify(
          () => mockRequestHandler.getRelease('cloud.firestore'),
        ).called(1);
        verify(() => mockRequestHandler.getRuleset('foo')).called(1);
      });
    });

    group('getStorageRuleset()', () {
      test('should reject when called with empty string', () async {
        await expectLater(
          securityRules.getStorageRuleset(''),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/invalid-argument',
            ),
          ),
        );
      });

      test('should propagate API errors', () async {
        when(
          () => mockRequestHandler.getRelease(any()),
        ).thenThrow(expectedError);

        await expectLater(
          securityRules.getStorageRuleset(),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/internal-error',
            ),
          ),
        );
      });

      test(
        'should resolve with Ruleset for the default bucket on success',
        () async {
          when(
            () => mockRequestHandler.getRelease(
              'firebase.storage/bucketName.appspot.com',
            ),
          ).thenAnswer((_) async => firestoreRelease);
          when(
            () => mockRequestHandler.getRuleset('foo'),
          ).thenAnswer((_) async => firestoreRulesetResponse);

          final ruleset = await securityRules.getStorageRuleset();

          expect(ruleset.name, equals('foo'));
          expect(ruleset.createTime, equals('2019-03-08T23:45:23.288047Z'));

          verify(
            () => mockRequestHandler.getRelease(
              'firebase.storage/bucketName.appspot.com',
            ),
          ).called(1);
          verify(() => mockRequestHandler.getRuleset('foo')).called(1);
        },
      );

      test(
        'should resolve with Ruleset for the specified bucket on success',
        () async {
          when(
            () => mockRequestHandler.getRelease(
              'firebase.storage/other.appspot.com',
            ),
          ).thenAnswer((_) async => firestoreRelease);
          when(
            () => mockRequestHandler.getRuleset('foo'),
          ).thenAnswer((_) async => firestoreRulesetResponse);

          final ruleset = await securityRules.getStorageRuleset(
            'other.appspot.com',
          );

          expect(ruleset.name, equals('foo'));
          expect(ruleset.createTime, equals('2019-03-08T23:45:23.288047Z'));

          verify(
            () => mockRequestHandler.getRelease(
              'firebase.storage/other.appspot.com',
            ),
          ).called(1);
          verify(() => mockRequestHandler.getRuleset('foo')).called(1);
        },
      );
    });

    group('releaseFirestoreRuleset()', () {
      test('should propagate API errors', () async {
        when(
          () => mockRequestHandler.updateOrCreateRelease(any(), any()),
        ).thenThrow(expectedError);

        await expectLater(
          securityRules.releaseFirestoreRuleset('foo'),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/internal-error',
            ),
          ),
        );
      });

      test('should resolve on success', () async {
        when(
          () => mockRequestHandler.updateOrCreateRelease(
            'cloud.firestore',
            'foo',
          ),
        ).thenAnswer((_) async => firestoreRelease);

        await securityRules.releaseFirestoreRuleset('foo');

        verify(
          () => mockRequestHandler.updateOrCreateRelease(
            'cloud.firestore',
            'foo',
          ),
        ).called(1);
      });
    });

    group('releaseFirestoreRulesetFromSource()', () {
      test('should propagate API errors', () async {
        when(
          () => mockRequestHandler.createRuleset(any()),
        ).thenThrow(expectedError);

        await expectLater(
          securityRules.releaseFirestoreRulesetFromSource('foo'),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/internal-error',
            ),
          ),
        );
      });

      test('should resolve on success', () async {
        when(
          () => mockRequestHandler.createRuleset(any()),
        ).thenAnswer((_) async => firestoreRulesetResponse);
        when(
          () => mockRequestHandler.updateOrCreateRelease(
            'cloud.firestore',
            'foo',
          ),
        ).thenAnswer((_) async => firestoreRelease);

        final ruleset = await securityRules.releaseFirestoreRulesetFromSource(
          'test source {}',
        );

        expect(ruleset.name, equals('foo'));
        expect(ruleset.createTime, equals('2019-03-08T23:45:23.288047Z'));

        verify(() => mockRequestHandler.createRuleset(any())).called(1);
        verify(
          () => mockRequestHandler.updateOrCreateRelease(
            'cloud.firestore',
            'foo',
          ),
        ).called(1);
      });
    });

    group('releaseStorageRuleset()', () {
      test('should reject when called with empty bucket', () async {
        await expectLater(
          securityRules.releaseStorageRuleset('foo', ''),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/invalid-argument',
            ),
          ),
        );
      });

      test('should propagate API errors', () async {
        when(
          () => mockRequestHandler.updateOrCreateRelease(any(), any()),
        ).thenThrow(expectedError);

        await expectLater(
          securityRules.releaseStorageRuleset('foo'),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/internal-error',
            ),
          ),
        );
      });

      test('should resolve for default bucket on success', () async {
        when(
          () => mockRequestHandler.updateOrCreateRelease(
            'firebase.storage/bucketName.appspot.com',
            'foo',
          ),
        ).thenAnswer((_) async => firestoreRelease);

        await securityRules.releaseStorageRuleset('foo');

        verify(
          () => mockRequestHandler.updateOrCreateRelease(
            'firebase.storage/bucketName.appspot.com',
            'foo',
          ),
        ).called(1);
      });

      test('should resolve for custom bucket on success', () async {
        when(
          () => mockRequestHandler.updateOrCreateRelease(
            'firebase.storage/other.appspot.com',
            'foo',
          ),
        ).thenAnswer((_) async => firestoreRelease);

        await securityRules.releaseStorageRuleset('foo', 'other.appspot.com');

        verify(
          () => mockRequestHandler.updateOrCreateRelease(
            'firebase.storage/other.appspot.com',
            'foo',
          ),
        ).called(1);
      });
    });

    group('releaseStorageRulesetFromSource()', () {
      test('should reject when called with empty bucket', () async {
        await expectLater(
          securityRules.releaseStorageRulesetFromSource('test source {}', ''),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/invalid-argument',
            ),
          ),
        );
      });

      test('should propagate API errors', () async {
        when(
          () => mockRequestHandler.createRuleset(any()),
        ).thenThrow(expectedError);

        await expectLater(
          securityRules.releaseStorageRulesetFromSource('foo'),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/internal-error',
            ),
          ),
        );
      });

      test('should resolve for default bucket on success', () async {
        when(
          () => mockRequestHandler.createRuleset(any()),
        ).thenAnswer((_) async => firestoreRulesetResponse);
        when(
          () => mockRequestHandler.updateOrCreateRelease(
            'firebase.storage/bucketName.appspot.com',
            'foo',
          ),
        ).thenAnswer((_) async => firestoreRelease);

        final ruleset = await securityRules.releaseStorageRulesetFromSource(
          'test source {}',
        );

        expect(ruleset.name, equals('foo'));
        expect(ruleset.createTime, equals('2019-03-08T23:45:23.288047Z'));

        verify(() => mockRequestHandler.createRuleset(any())).called(1);
        verify(
          () => mockRequestHandler.updateOrCreateRelease(
            'firebase.storage/bucketName.appspot.com',
            'foo',
          ),
        ).called(1);
      });

      test('should resolve for custom bucket on success', () async {
        when(
          () => mockRequestHandler.createRuleset(any()),
        ).thenAnswer((_) async => firestoreRulesetResponse);
        when(
          () => mockRequestHandler.updateOrCreateRelease(
            'firebase.storage/other.appspot.com',
            'foo',
          ),
        ).thenAnswer((_) async => firestoreRelease);

        final ruleset = await securityRules.releaseStorageRulesetFromSource(
          'test source {}',
          'other.appspot.com',
        );

        expect(ruleset.name, equals('foo'));
        expect(ruleset.createTime, equals('2019-03-08T23:45:23.288047Z'));

        verify(() => mockRequestHandler.createRuleset(any())).called(1);
        verify(
          () => mockRequestHandler.updateOrCreateRelease(
            'firebase.storage/other.appspot.com',
            'foo',
          ),
        ).called(1);
      });
    });

    group('createRuleset()', () {
      test('should propagate API errors', () async {
        when(
          () => mockRequestHandler.createRuleset(any()),
        ).thenThrow(expectedError);

        final rulesFile = RulesFile(
          name: 'test.rules',
          content: 'test source {}',
        );

        await expectLater(
          securityRules.createRuleset(rulesFile),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/internal-error',
            ),
          ),
        );
      });

      test('should resolve with Ruleset on success', () async {
        when(
          () => mockRequestHandler.createRuleset(any()),
        ).thenAnswer((_) async => firestoreRulesetResponse);

        final rulesFile = RulesFile(
          name: 'test.rules',
          content: 'test source {}',
        );
        final ruleset = await securityRules.createRuleset(rulesFile);

        expect(ruleset.name, equals('foo'));
        expect(ruleset.createTime, equals('2019-03-08T23:45:23.288047Z'));
        expect(ruleset.source.length, equals(1));

        verify(() => mockRequestHandler.createRuleset(any())).called(1);
      });
    });

    group('deleteRuleset()', () {
      test('should propagate API errors', () async {
        when(
          () => mockRequestHandler.deleteRuleset(any()),
        ).thenAnswer((_) => Future.error(expectedError));

        await expectLater(
          securityRules.deleteRuleset('foo'),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/internal-error',
            ),
          ),
        );
      });

      test('should resolve on success', () async {
        when(
          () => mockRequestHandler.deleteRuleset('foo'),
        ).thenAnswer((_) async => Future.value());

        await securityRules.deleteRuleset('foo');

        verify(() => mockRequestHandler.deleteRuleset('foo')).called(1);
      });
    });

    group('listRulesetMetadata()', () {
      final listRulesetsResponse = ListRulesetsResponse.forTest(
        rulesets: [
          RulesetResponse.forTest(
            name: 'projects/test-project/rulesets/rs1',
            createTime: '2019-03-08T23:45:23.288047Z',
            source: RulesetSource(files: []),
          ),
          RulesetResponse.forTest(
            name: 'projects/test-project/rulesets/rs2',
            createTime: '2019-03-08T23:45:23.288047Z',
            source: RulesetSource(files: []),
          ),
        ],
        nextPageToken: 'next',
      );

      test('should propagate API errors', () async {
        when(() => mockRequestHandler.listRulesets()).thenThrow(expectedError);

        await expectLater(
          securityRules.listRulesetMetadata(),
          throwsA(
            isA<FirebaseSecurityRulesException>().having(
              (e) => e.code,
              'code',
              'security-rules/internal-error',
            ),
          ),
        );
      });

      test('should resolve with RulesetMetadataList on success', () async {
        when(
          () => mockRequestHandler.listRulesets(),
        ).thenAnswer((_) async => listRulesetsResponse);

        final result = await securityRules.listRulesetMetadata();

        expect(result.rulesets.length, equals(2));
        expect(result.rulesets[0].name, equals('rs1'));
        expect(
          result.rulesets[0].createTime,
          equals('2019-03-08T23:45:23.288047Z'),
        );
        expect(result.rulesets[1].name, equals('rs2'));
        expect(
          result.rulesets[1].createTime,
          equals('2019-03-08T23:45:23.288047Z'),
        );
        expect(result.nextPageToken, equals('next'));

        verify(() => mockRequestHandler.listRulesets()).called(1);
      });

      test('should resolve when called with page size', () async {
        when(
          () => mockRequestHandler.listRulesets(pageSize: 10),
        ).thenAnswer((_) async => listRulesetsResponse);

        final result = await securityRules.listRulesetMetadata(pageSize: 10);

        expect(result.rulesets.length, equals(2));
        expect(result.nextPageToken, equals('next'));

        verify(() => mockRequestHandler.listRulesets(pageSize: 10)).called(1);
      });

      test('should resolve when called with page token', () async {
        when(
          () =>
              mockRequestHandler.listRulesets(pageSize: 10, pageToken: 'next'),
        ).thenAnswer((_) async => listRulesetsResponse);

        final result = await securityRules.listRulesetMetadata(
          pageSize: 10,
          nextPageToken: 'next',
        );

        expect(result.rulesets.length, equals(2));
        expect(result.nextPageToken, equals('next'));

        verify(
          () =>
              mockRequestHandler.listRulesets(pageSize: 10, pageToken: 'next'),
        ).called(1);
      });

      test('should resolve when the response contains no page token', () async {
        final responseWithoutToken = ListRulesetsResponse.forTest(
          rulesets: listRulesetsResponse.rulesets,
        );

        when(
          () =>
              mockRequestHandler.listRulesets(pageSize: 10, pageToken: 'next'),
        ).thenAnswer((_) async => responseWithoutToken);

        final result = await securityRules.listRulesetMetadata(
          pageSize: 10,
          nextPageToken: 'next',
        );

        expect(result.rulesets.length, equals(2));
        expect(result.nextPageToken, isNull);

        verify(
          () =>
              mockRequestHandler.listRulesets(pageSize: 10, pageToken: 'next'),
        ).called(1);
      });
    });

    group('RulesFile', () {
      test('creates RulesFile with required name and content', () {
        final rulesFile = RulesFile(
          name: 'test.rules',
          content: 'test source {}',
        );

        expect(rulesFile.name, equals('test.rules'));
        expect(rulesFile.content, equals('test source {}'));
      });

      test('works with empty content', () {
        final rulesFile = RulesFile(name: 'test.rules', content: '');

        expect(rulesFile.name, equals('test.rules'));
        expect(rulesFile.content, equals(''));
      });
    });
  });
}
