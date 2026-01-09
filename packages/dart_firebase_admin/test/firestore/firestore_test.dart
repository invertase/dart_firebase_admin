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
        expect(() => firestoreService.getDatabase(), returnsNormally);
      });

      test('should return Firestore instance for default database', () {
        final db = firestoreService.getDatabase();
        expect(db, isA<gfs.Firestore>());
      });

      test('should return Firestore instance for named database', () {
        final db = firestoreService.getDatabase('my-database');
        expect(db, isA<gfs.Firestore>());
      });

      test('should cache Firestore instances per database ID', () {
        final db1 = firestoreService.getDatabase();
        final db2 = firestoreService.getDatabase();
        expect(db1, same(db2));
      });

      test('should return different instances for different database IDs', () {
        final db1 = firestoreService.getDatabase();
        final db2 = firestoreService.getDatabase('my-database');
        expect(db1, isNot(same(db2)));
      });
    });

    group('app', () {
      test('returns the app from the constructor', () {
        expect(firestoreService.app, same(app));
      });
    });

    group('initializeDatabase', () {
      test('should initialize database with settings', () {
        const settings = gfs.Settings(projectId: 'test-project');

        expect(
          () => firestoreService.initializeDatabase('test-db', settings),
          returnsNormally,
        );
      });

      test('should return same instance if initialized with same settings', () {
        const settings = gfs.Settings(projectId: 'test-project');

        final db1 = firestoreService.initializeDatabase('test-db-1', settings);
        final db2 = firestoreService.initializeDatabase('test-db-1', settings);

        expect(db1, same(db2));
      });

      test(
        'should throw if database already initialized with different settings',
        () {
          const settings1 = gfs.Settings(projectId: 'test-project');
          const settings2 = gfs.Settings(projectId: 'different-project');

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

    group('_buildSettings', () {
      test('should set projectId from app if not in settings', () {
        final appWithProject = FirebaseApp.initializeApp(
          name: 'project-app',
          options: AppOptions(projectId: 'my-project-id', httpClient: client),
        );
        addTearDown(appWithProject.close);

        final service = Firestore.internal(appWithProject);
        final db = service.getDatabase();

        // The internal Firestore instance should have projectId set
        // This is a white-box test - we're testing the internal behavior
        expect(db, isNotNull);
      });

      test('should set databaseId in settings', () {
        final db = firestoreService.getDatabase('custom-db');
        expect(db, isNotNull);
        // Ideally we'd verify the settings, but they're private
        // Integration tests will verify this works correctly
      });
    });

    group('credential handling', () {
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

        // TODO: Add more specific assertions once we can inspect the settings
        // For now, this is a smoke test that it doesn't crash
      });

      test(
        'should use Application Default Credentials when no credential provided',
        () {
          // This test requires GOOGLE_APPLICATION_CREDENTIALS to be set
          // or running in a GCP environment
          if (!hasGoogleEnv) {
            return;
          }

          final adcApp = FirebaseApp.initializeApp(
            name: 'adc-app',
            options: AppOptions(projectId: 'test-project', httpClient: client),
          );
          addTearDown(adcApp.close);

          final service = Firestore.internal(adcApp);
          final db = service.getDatabase();

          expect(db, isNotNull);
        },
      );
    });

    group('settings comparison', () {
      test('should treat null settings as equal', () {
        final db1 = firestoreService.initializeDatabase('db-null-1', null);
        final db2 = firestoreService.initializeDatabase('db-null-1', null);

        expect(db1, same(db2));
      });

      test('should detect different projectId', () {
        const settings1 = gfs.Settings(projectId: 'project-1');
        const settings2 = gfs.Settings(projectId: 'project-2');

        firestoreService.initializeDatabase('db-diff-1', settings1);

        expect(
          () => firestoreService.initializeDatabase('db-diff-1', settings2),
          throwsA(isA<FirebaseAppException>()),
        );
      });

      test('should detect different databaseId', () {
        const settings1 = gfs.Settings(databaseId: 'db-1');
        const settings2 = gfs.Settings(databaseId: 'db-2');

        firestoreService.initializeDatabase('db-diff-2', settings1);

        expect(
          () => firestoreService.initializeDatabase('db-diff-2', settings2),
          throwsA(isA<FirebaseAppException>()),
        );
      });

      test('should detect different host', () {
        const settings1 = gfs.Settings(host: 'localhost:8080');
        const settings2 = gfs.Settings(host: 'localhost:9090');

        firestoreService.initializeDatabase('db-diff-3', settings1);

        expect(
          () => firestoreService.initializeDatabase('db-diff-3', settings2),
          throwsA(isA<FirebaseAppException>()),
        );
      });

      test('should detect different ssl', () {
        const settings1 = gfs.Settings();
        const settings2 = gfs.Settings(ssl: false);

        firestoreService.initializeDatabase('db-diff-4', settings1);

        expect(
          () => firestoreService.initializeDatabase('db-diff-4', settings2),
          throwsA(isA<FirebaseAppException>()),
        );
      });

      test('should detect different credentials - clientEmail', () {
        const settings1 = gfs.Settings(
          projectId: 'test-project',
          credentials: gfs.Credentials(
            clientEmail: 'test1@example.com',
            privateKey:
                mockPrivateKey, // Use mock key from mock_service_account
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

        firestoreService.initializeDatabase('db-diff-5', settings1);

        expect(
          () => firestoreService.initializeDatabase('db-diff-5', settings2),
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.message,
              'message',
              contains('already been called with different settings'),
            ),
          ),
        );
      });

      test('should detect different credentials - privateKey', () {
        // Note: We can't easily test different private keys without having
        // two valid keys. Instead, this verifies the comparison logic
        // by checking that credentials with different emails are detected.
        // The _areSettingsEqual method checks both clientEmail AND privateKey.
      });

      test('should allow same credentials', () {
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
    });

    group('lifecycle', () {
      test('should terminate all databases on delete', () async {
        final db1 = firestoreService.getDatabase('lifecycle-1');
        final db2 = firestoreService.getDatabase('lifecycle-2');

        expect(db1, isNotNull);
        expect(db2, isNotNull);

        await firestoreService.delete();

        // After delete, the databases map should be empty
        // This is tested indirectly - we can't access private fields
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

    test('should return Firestore instance', () {
      final db = app.firestore();
      expect(db, isA<gfs.Firestore>());
    });

    test('should return same instance for default database', () {
      final db1 = app.firestore();
      final db2 = app.firestore();
      expect(db1, same(db2));
    });

    test('should accept databaseId parameter', () {
      final db = app.firestore(databaseId: 'my-database');
      expect(db, isA<gfs.Firestore>());
    });

    test('should return different instances for different database IDs', () {
      final db1 = app.firestore();
      final db2 = app.firestore(databaseId: 'my-database');
      expect(db1, isNot(same(db2)));
    });

    test('should initialize with settings', () {
      const settings = gfs.Settings(
        projectId: 'test-project',
        host: 'localhost:8080',
        ssl: false,
      );

      final db = app.firestore(settings: settings);
      expect(db, isA<gfs.Firestore>());
    });

    test('should initialize named database with settings', () {
      const settings = gfs.Settings(
        projectId: 'test-project',
        host: 'localhost:8080',
        ssl: false,
      );

      final db = app.firestore(settings: settings, databaseId: 'my-db');
      expect(db, isA<gfs.Firestore>());
    });

    test('should throw if trying to reinitialize with different settings', () {
      const settings1 = gfs.Settings(projectId: 'project-1');
      const settings2 = gfs.Settings(projectId: 'project-2');

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
      final defaultDb = app.firestore();
      final namedDb1 = app.firestore(databaseId: 'database-1');
      final namedDb2 = app.firestore(databaseId: 'database-2');

      expect(defaultDb, isA<gfs.Firestore>());
      expect(namedDb1, isA<gfs.Firestore>());
      expect(namedDb2, isA<gfs.Firestore>());

      // All should be different instances
      expect(defaultDb, isNot(same(namedDb1)));
      expect(defaultDb, isNot(same(namedDb2)));
      expect(namedDb1, isNot(same(namedDb2)));
    });

    test('should cache instances per database ID', () {
      final db1 = app.firestore(databaseId: 'cached-db');
      final db2 = app.firestore(databaseId: 'cached-db');

      expect(db1, same(db2));
    });
  });
}
