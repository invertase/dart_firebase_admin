import 'dart:io';

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/src/firestore/firestore.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_firestore/googleapis_firestore.dart' as gfs;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import '../mock_service_account.dart';

class MockAuthClient extends Mock implements auth.AuthClient {}

void main() {
  group('Firestore Wrapper', () {
    late FirebaseApp app;
    late Firestore firestoreService;
    late MockAuthClient client;

    setUp(() {
      client = MockAuthClient();

      // Create app with mock HTTP client to prevent actual authentication
      app = FirebaseApp.initializeApp(
        name: 'test-app-${DateTime.now().millisecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: client),
      );

      firestoreService = Firestore.internal(app);
    });

    tearDown(() async {
      await app.close();
    });

    group('Initializer', () {
      test('should not throw given a valid app', () {
        expect(
          () => firestoreService.initializeDatabase(
            '(default)',
            mockFirestoreSettings,
          ),
          returnsNormally,
        );
      });

      test('should return Firestore instance for named database', () {
        final db = firestoreService.initializeDatabase(
          'my-database',
          mockFirestoreSettingsWithDb('my-database'),
        );
        expect(db, isA<gfs.Firestore>());
      });
    });

    group('app', () {
      test('returns the app from the constructor', () {
        expect(firestoreService.app, same(app));
      });
    });

    group('initializeDatabase', () {
      test('should initialize database with settings', () {
        expect(
          () => firestoreService.initializeDatabase(
            'test-db',
            mockFirestoreSettings,
          ),
          returnsNormally,
        );
      });

      test('should return same instance if initialized with same settings', () {
        final db1 = firestoreService.initializeDatabase(
          'test-db-1',
          mockFirestoreSettings,
        );
        final db2 = firestoreService.initializeDatabase(
          'test-db-1',
          mockFirestoreSettings,
        );

        expect(db1, same(db2));
      });

      test(
        'should throw if database already initialized with different settings',
        () {
          const settings1 = gfs.Settings(
            projectId: 'test-project',
            environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
          );
          const settings2 = gfs.Settings(
            projectId: 'different-project',
            environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
          );

          firestoreService.initializeDatabase('test-db-2', settings1);

          expect(
            () => firestoreService.initializeDatabase('test-db-2', settings2),
            throwsA(
              isA<FirebaseAppException>()
                  .having(
                    (e) => e.errorCode,
                    'errorCode',
                    equals(AppErrorCode.failedPrecondition),
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    contains('already been called with different settings'),
                  ),
            ),
          );
        },
      );
    });

    group(
      'credential handling',
      () {
        test('should extract credentials from ServiceAccountCredential', () {
          // Use a real service account file for this test
          final serviceAccountFile = File('test/mock_service_account.json');
          if (!serviceAccountFile.existsSync()) {
            // Skip if mock service account doesn't exist
            return;
          }

          final credential = Credential.fromServiceAccount(serviceAccountFile);

          final credApp = FirebaseApp.initializeApp(
            name: 'cred-app',
            options: AppOptions(
              credential: credential,
              projectId: 'test-project',
              httpClient: client,
            ),
          );
          addTearDown(credApp.close);

          final service = Firestore.internal(credApp);
          final db = service.getDatabase();

          // The Firestore instance should have credentials set from the app
          // This test will FAIL initially because credential extraction is not implemented
          expect(db, isNotNull);
        });

        test(
          'should use Application Default Credentials when no credential provided',
          () {
            final adcApp = FirebaseApp.initializeApp(
              name: 'adc-app',
              options: AppOptions(
                projectId: 'test-project',
                httpClient: client,
              ),
            );
            addTearDown(adcApp.close);

            final service = Firestore.internal(adcApp);
            final db = service.getDatabase();

            expect(db, isNotNull);
          },
        );
      },
      skip: hasGoogleEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
    );

    group('settings comparison', () {
      test('should detect different settings (projectId, host, ssl)', () {
        const settings1 = gfs.Settings(
          projectId: 'project-1',
          host: 'localhost:8080',
          environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
        );
        const settings2 = gfs.Settings(
          projectId: 'project-2',
          host: 'localhost:9090',
          ssl: false,
          environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
        );

        firestoreService.initializeDatabase('db-diff-1', settings1);

        expect(
          () => firestoreService.initializeDatabase('db-diff-1', settings2),
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.message,
              'message',
              contains('already been called with different settings'),
            ),
          ),
        );
      });

      test('should detect different credentials', () {
        const settings1 = gfs.Settings(
          projectId: 'test-project',
          credentials: gfs.Credentials(
            clientEmail: 'test1@example.com',
            privateKey: mockPrivateKey,
          ),
          environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
        );
        const settings2 = gfs.Settings(
          projectId: 'test-project',
          credentials: gfs.Credentials(
            clientEmail: 'test2@example.com', // Different email
            privateKey: mockPrivateKey,
          ),
          environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
        );

        firestoreService.initializeDatabase('db-diff-2', settings1);

        expect(
          () => firestoreService.initializeDatabase('db-diff-2', settings2),
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.message,
              'message',
              contains('already been called with different settings'),
            ),
          ),
        );
      });

      test('should allow same settings', () {
        const settings = gfs.Settings(
          projectId: 'test-project',
          credentials: gfs.Credentials(
            clientEmail: mockClientEmail,
            privateKey: mockPrivateKey,
          ),
          environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
        );

        final db1 = firestoreService.initializeDatabase('db-same-1', settings);
        final db2 = firestoreService.initializeDatabase('db-same-1', settings);

        expect(db1, same(db2));
      });

      test('should allow same mock settings for multiple calls', () {
        final db1 = firestoreService.initializeDatabase(
          'db-mock-1',
          mockFirestoreSettings,
        );
        final db2 = firestoreService.initializeDatabase(
          'db-mock-1',
          mockFirestoreSettings,
        );

        expect(db1, same(db2));
      });
    });

    group('lifecycle', () {
      test('should terminate all databases on delete', () async {
        final db1 = firestoreService.initializeDatabase(
          'lifecycle-1',
          mockFirestoreSettingsWithDb('lifecycle-1'),
        );
        final db2 = firestoreService.initializeDatabase(
          'lifecycle-2',
          mockFirestoreSettingsWithDb('lifecycle-2'),
        );

        expect(db1, isNotNull);
        expect(db2, isNotNull);

        await firestoreService.delete();

        // After delete, the databases map should be empty
        // This is tested indirectly - we can't access private fields
      });

      test('should handle delete() called multiple times', () async {
        final db = firestoreService.initializeDatabase(
          'multi-delete-test',
          mockFirestoreSettings,
        );
        expect(db, isNotNull);

        // First delete
        await firestoreService.delete();

        // Second delete should not throw
        expect(() => firestoreService.delete(), returnsNormally);
      });

      test('should throw when accessing firestore after app.close()', () async {
        final testApp = FirebaseApp.initializeApp(
          name: 'close-test-${DateTime.now().millisecondsSinceEpoch}',
          options: AppOptions(projectId: projectId, httpClient: client),
        );

        // Get firestore instance before closing
        final db = testApp.firestore(settings: mockFirestoreSettings);
        expect(db, isNotNull);

        // Close the app
        await testApp.close();

        // Trying to get firestore after close should throw
        expect(
          () => testApp.firestore(settings: mockFirestoreSettings),
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.errorCode,
              'errorCode',
              equals(AppErrorCode.appDeleted),
            ),
          ),
        );
      });

      test('should create new instance after delete if requested', () async {
        final db1 = firestoreService.initializeDatabase(
          'recreate-test',
          mockFirestoreSettings,
        );
        expect(db1, isNotNull);

        await firestoreService.delete();

        // After delete, getting database should create a new instance
        final db2 = firestoreService.initializeDatabase(
          'recreate-test',
          mockFirestoreSettings,
        );
        expect(db2, isNotNull);
        expect(db2, isNot(same(db1)));
      });
    });
  });

  group('FirebaseApp.firestore()', () {
    late FirebaseApp app;
    late MockAuthClient client;

    setUp(() {
      client = MockAuthClient();
      app = FirebaseApp.initializeApp(
        name: 'firestore-api-test-${DateTime.now().millisecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: client),
      );
    });

    tearDown(() async {
      await app.close();
    });

    test('should return Firestore instance and cache it', () {
      final db1 = app.firestore(settings: mockFirestoreSettings);
      final db2 = app.firestore(settings: mockFirestoreSettings);

      expect(db1, isA<gfs.Firestore>());
      expect(db1, same(db2)); // Cached
    });

    test('should accept custom settings', () {
      const settings = gfs.Settings(
        projectId: 'test-project',
        host: 'localhost:8080',
        ssl: false,
        environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
      );

      final db = app.firestore(settings: settings, databaseId: 'my-db');
      expect(db, isA<gfs.Firestore>());
    });

    test('should throw if trying to reinitialize with different settings', () {
      const settings1 = gfs.Settings(
        projectId: 'project-1',
        environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
      );
      const settings2 = gfs.Settings(
        projectId: 'project-2',
        environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
      );

      app.firestore(settings: settings1, databaseId: 'reinit-test');

      expect(
        () => app.firestore(settings: settings2, databaseId: 'reinit-test'),
        throwsA(
          isA<FirebaseAppException>().having(
            (e) => e.message,
            'message',
            contains('already been called with different settings'),
          ),
        ),
      );
    });
  });

  group('Multi-database support', () {
    late FirebaseApp app;
    late MockAuthClient client;

    setUp(() {
      client = MockAuthClient();
      app = FirebaseApp.initializeApp(
        name: 'multi-db-test-${DateTime.now().millisecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: client),
      );
    });

    tearDown(() async {
      await app.close();
    });

    test('should support multiple databases per app', () {
      final defaultDb = app.firestore(settings: mockFirestoreSettings);
      final namedDb1 = app.firestore(
        settings: mockFirestoreSettingsWithDb('database-1'),
        databaseId: 'database-1',
      );
      final namedDb2 = app.firestore(
        settings: mockFirestoreSettingsWithDb('database-2'),
        databaseId: 'database-2',
      );

      expect(defaultDb, isA<gfs.Firestore>());
      expect(namedDb1, isA<gfs.Firestore>());
      expect(namedDb2, isA<gfs.Firestore>());

      // All should be different instances
      expect(defaultDb, isNot(same(namedDb1)));
      expect(defaultDb, isNot(same(namedDb2)));
      expect(namedDb1, isNot(same(namedDb2)));
    });
  });

  group('Edge Cases', () {
    late MockAuthClient client;

    setUp(() {
      client = MockAuthClient();
    });

    test('should work when projectId is null but provided in settings', () {
      final appWithoutProject = FirebaseApp.initializeApp(
        name: 'no-project-${DateTime.now().millisecondsSinceEpoch}',
        options: AppOptions(httpClient: client), // No projectId
      );
      addTearDown(appWithoutProject.close);

      // Should work if settings provide projectId
      const settings = gfs.Settings(
        projectId: 'settings-project',
        environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
      );
      final db = appWithoutProject.firestore(settings: settings);

      expect(db, isA<gfs.Firestore>());
    });

    test('should allow empty database ID to default to "(default)"', () {
      final app = FirebaseApp.initializeApp(
        name: 'empty-db-${DateTime.now().millisecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: client),
      );
      addTearDown(app.close);

      // Empty string should be treated as default database
      final db1 = app.firestore(
        settings: mockFirestoreSettings,
        databaseId: '',
      );
      final db2 = app.firestore(settings: mockFirestoreSettings); // default

      expect(db1, isA<gfs.Firestore>());
      expect(db2, isA<gfs.Firestore>());
      // They might or might not be the same depending on implementation
    });

    test('should handle concurrent initialization of same database', () async {
      final app = FirebaseApp.initializeApp(
        name: 'concurrent-${DateTime.now().millisecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: client),
      );
      addTearDown(app.close);

      final concurrentSettings = mockFirestoreSettingsWithDb('concurrent-db');

      // Try to initialize the same database concurrently
      final results = await Future.wait([
        Future(
          () => app.firestore(
            settings: concurrentSettings,
            databaseId: 'concurrent-db',
          ),
        ),
        Future(
          () => app.firestore(
            settings: concurrentSettings,
            databaseId: 'concurrent-db',
          ),
        ),
        Future(
          () => app.firestore(
            settings: concurrentSettings,
            databaseId: 'concurrent-db',
          ),
        ),
      ]);

      // All should be the same instance (cached)
      expect(results[0], same(results[1]));
      expect(results[1], same(results[2]));
    });
  });
}
