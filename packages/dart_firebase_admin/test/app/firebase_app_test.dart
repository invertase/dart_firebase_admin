import 'dart:async';

import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/messaging.dart';
import 'package:dart_firebase_admin/security_rules.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:dart_firebase_admin/src/app_check/app_check.dart';
import 'package:dart_firebase_admin/src/auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mock.dart';
import '../mock_service_account.dart';

void main() {
  group('FirebaseApp', () {
    group('initializeApp', () {
      tearDown(() {
        // Clean up all apps after each test
        FirebaseApp.apps.forEach(FirebaseApp.deleteApp);
      });

      test('creates a default app without options', () {
        final app = FirebaseApp.initializeApp();

        expect(app.name, '[DEFAULT]');
        expect(app.wasInitializedFromEnv, isTrue);
        expect(app.isDeleted, isFalse);
      });

      test('creates default app with options', () {
        const options = AppOptions(projectId: mockProjectId);
        final app = FirebaseApp.initializeApp(options: options);

        expect(app.name, '[DEFAULT]');
        expect(app.options.projectId, mockProjectId);
        expect(app.wasInitializedFromEnv, isFalse);
        expect(app.isDeleted, isFalse);
      });

      test('creates named app with options', () {
        const options = AppOptions(projectId: mockProjectId);
        final app = FirebaseApp.initializeApp(
          options: options,
          name: 'custom-app',
        );

        expect(app.name, 'custom-app');
        expect(app.options.projectId, mockProjectId);
        expect(app.wasInitializedFromEnv, isFalse);
      });

      test('returns same instance for duplicate initialization', () {
        const options = AppOptions(projectId: mockProjectId);
        final app1 = FirebaseApp.initializeApp(options: options);
        final app2 = FirebaseApp.initializeApp(options: options);

        expect(identical(app1, app2), isTrue);
      });

      test('allows multiple named apps', () {
        const options1 = AppOptions(projectId: 'project1');
        const options2 = AppOptions(projectId: 'project2');

        final app1 = FirebaseApp.initializeApp(options: options1, name: 'app1');
        final app2 = FirebaseApp.initializeApp(options: options2, name: 'app2');

        expect(app1.name, 'app1');
        expect(app2.name, 'app2');
        expect(app1.options.projectId, 'project1');
        expect(app2.options.projectId, 'project2');
      });
    });

    group('instance', () {
      tearDown(() {
        FirebaseApp.apps.forEach(FirebaseApp.deleteApp);
      });

      test('returns default app', () {
        final app = FirebaseApp.initializeApp();
        final instance = FirebaseApp.initializeApp();

        expect(identical(app, instance), isTrue);
      });

      test('throws if default app not initialized', () {
        expect(
          () => FirebaseApp.instance,
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.code,
              'code',
              AppErrorCode.noApp.code,
            ),
          ),
        );
      });
    });

    group('getApp', () {
      tearDown(() {
        FirebaseApp.apps.forEach(FirebaseApp.deleteApp);
      });

      test('returns default app when no name provided', () {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
        );
        final retrieved = FirebaseApp.getApp();

        expect(identical(app, retrieved), isTrue);
      });

      test('returns named app', () {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
          name: 'test-app',
        );
        final retrieved = FirebaseApp.getApp('test-app');

        expect(identical(app, retrieved), isTrue);
      });

      test('throws if app does not exist', () {
        expect(
          () => FirebaseApp.getApp('nonexistent'),
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.code,
              'code',
              AppErrorCode.noApp.code,
            ),
          ),
        );
      });
    });

    group('apps', () {
      tearDown(() {
        FirebaseApp.apps.forEach(FirebaseApp.deleteApp);
      });

      test('returns empty list when no apps initialized', () {
        expect(FirebaseApp.apps, isEmpty);
      });

      test('returns all initialized apps', () {
        final app1 = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: 'project1'),
          name: 'app1',
        );
        final app2 = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: 'project2'),
          name: 'app2',
        );

        final apps = FirebaseApp.apps;
        expect(apps.length, 2);
        expect(apps.contains(app1), isTrue);
        expect(apps.contains(app2), isTrue);
      });
    });

    group('deleteApp', () {
      test('removes app from registry', () async {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
        );

        await FirebaseApp.deleteApp(app);

        expect(FirebaseApp.apps, isEmpty);
      });

      test('marks app as deleted', () async {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
        );

        await FirebaseApp.deleteApp(app);

        expect(app.isDeleted, isTrue);
      });

      test('throws if app does not exist in registry', () async {
        final app = FirebaseApp(
          name: 'fake-app',
          options: const AppOptions(projectId: mockProjectId),
          wasInitializedFromEnv: false,
        );

        expect(
          () => FirebaseApp.deleteApp(app),
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.code,
              'code',
              AppErrorCode.noApp.code,
            ),
          ),
        );
      });
    });

    group('properties', () {
      tearDown(() async {
        FirebaseApp.apps.forEach(FirebaseApp.deleteApp);
      });

      test('projectId returns null when not configured', () {
        final appWithoutProject = FirebaseApp.initializeApp(
          options: const AppOptions(),
          name: 'test-app',
        );

        expect(appWithoutProject.projectId, isNull);

        FirebaseApp.deleteApp(appWithoutProject);
      });

      test('isDeleted returns false for active app', () {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
          name: 'test-app',
        );

        expect(app.isDeleted, isFalse);
      });
    });

    group('client', () {
      test('returns custom client when provided', () async {
        final mockClient = ClientMock();
        final app = FirebaseApp.initializeApp(
          options: AppOptions(projectId: mockProjectId, httpClient: mockClient),
        );

        final client = await app.client;
        expect(identical(client, mockClient), isTrue);

        await FirebaseApp.deleteApp(app);
      });

      // TODO(demolaf): this test would need to be an e2e test.
      // test('creates authenticated client when service account provided',
      //     () async {
      //   final credential = Credential.fromServiceAccountParams(
      //     privateKey: mockPrivateKey,
      //     email: mockClientEmail,
      //     projectId: mockProjectId,
      //   );
      //   final app = FirebaseApp.initializeApp(
      //     options: AppOptions(
      //       projectId: mockProjectId,
      //       credential: credential,
      //     ),
      //   );
      //
      //   final client = await app.client;
      //   expect(client, isA<http.Client>());
      //
      //   await FirebaseApp.deleteApp(app);
      // });

      test('reuses same client on subsequent calls', () async {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
        );
        final client1 = await app.client;
        final client2 = await app.client;

        expect(identical(client1, client2), isTrue);

        await FirebaseApp.deleteApp(app);
      });
    });

    group('service accessors', () {
      late FirebaseApp app;

      setUp(() {
        app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
        );
      });

      tearDown(() async {
        if (!app.isDeleted) {
          await FirebaseApp.deleteApp(app);
        }
      });

      test('appCheck returns AppCheck instance', () {
        final appCheck = app.appCheck;
        expect(appCheck, isA<AppCheck>());
        expect(identical(appCheck.app, app), isTrue);
      });

      test('appCheck returns cached instance', () {
        final appCheck1 = app.appCheck;
        final appCheck2 = app.appCheck;
        expect(identical(appCheck1, appCheck2), isTrue);
        expect(identical(appCheck2, AppCheck(app)), isTrue);
      });

      test('auth returns Auth instance', () {
        final auth = app.auth;
        expect(auth, isA<Auth>());
        expect(identical(auth.app, app), isTrue);
      });

      test('auth returns cached instance', () {
        final auth1 = app.auth;
        final auth2 = app.auth;
        expect(identical(auth1, auth2), isTrue);
        expect(identical(auth2, Auth(app)), isTrue);
      });

      test('firestore returns Firestore instance', () {
        final firestore = app.firestore();
        expect(firestore, isA<Firestore>());
        expect(identical(firestore.app, app), isTrue);
      });

      test('firestore returns cached instance', () {
        final firestore1 = app.firestore();
        final firestore2 = app.firestore();
        expect(identical(firestore1, firestore2), isTrue);
        expect(identical(firestore2, Firestore(app)), isTrue);
      });

      test('firestore returns cached instance even if different '
          'settings specified', () {
        final firestore1 = app.firestore(
          settings: Settings(databaseId: 'test-db1'),
        );
        final firestore2 = app.firestore(
          settings: Settings(databaseId: 'test-db2'),
        );
        expect(identical(firestore1, firestore2), isTrue);
      });

      test('messaging returns Messaging instance', () {
        final messaging = app.messaging;
        expect(messaging, isA<Messaging>());
        expect(identical(messaging.app, app), isTrue);
      });

      test('messaging returns cached instance', () {
        final messaging1 = app.messaging;
        final messaging2 = app.messaging;
        expect(identical(messaging1, messaging2), isTrue);
        expect(identical(messaging1, Messaging(app)), isTrue);
      });

      test('securityRules returns SecurityRules instance', () {
        final securityRules = app.securityRules;
        expect(securityRules, isA<SecurityRules>());
        expect(identical(securityRules.app, app), isTrue);
      });

      test('securityRules returns cached instance', () {
        final securityRules1 = app.securityRules;
        final securityRules2 = app.securityRules;
        expect(identical(securityRules1, securityRules2), isTrue);
      });

      test('throws when accessing services after deletion', () async {
        await app.close();

        expect(
          () => app.auth,
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.code,
              'code',
              AppErrorCode.appDeleted.code,
            ),
          ),
        );
        expect(
          () => app.firestore(),
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.code,
              'code',
              AppErrorCode.appDeleted.code,
            ),
          ),
        );
      });
    });

    group('close', () {
      test('marks app as deleted', () async {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
        );

        await app.close();

        expect(app.isDeleted, isTrue);
      });

      test('removes app from registry', () async {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
        );

        await app.close();

        expect(FirebaseApp.apps, isEmpty);
      });

      test('cleans up services', () async {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
        );

        // Initialize a service
        app.auth;

        await app.close();

        expect(app.isDeleted, isTrue);
      });

      test('closes HTTP client when created by SDK', () async {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
        );

        await app.client;

        await app.close();

        expect(app.isDeleted, isTrue);
      });

      test('does not close custom HTTP client', () async {
        final mockClient = ClientMock();
        final app = FirebaseApp.initializeApp(
          options: AppOptions(projectId: mockProjectId, httpClient: mockClient),
        );

        // Trigger client access
        await app.client;

        await app.close();

        // Verify close was not NOT called on custom client
        verifyNever(mockClient.close);
      });

      test('throws when called twice', () async {
        final app = FirebaseApp.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
        );

        await app.close();

        expect(
          app.close,
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.code,
              'code',
              AppErrorCode.appDeleted.code,
            ),
          ),
        );
      });

      test(
        'calls delete() on auth service and closes HTTP client when emulator is enabled',
        () async {
          const firebaseAuthEmulatorHost = '127.0.0.1:9099';
          final testEnv = <String, String>{
            Environment.firebaseAuthEmulatorHost: firebaseAuthEmulatorHost,
          };

          await runZoned(zoneValues: {envSymbol: testEnv}, () async {
            // Create mocks
            final mockHttpClient = AuthHttpClientMock();
            final mockClient = ClientMock();

            final app = FirebaseApp.initializeApp(
              options: const AppOptions(projectId: mockProjectId),
            );

            // Setup the mock: httpClient returns our mock client
            when(
              () => mockHttpClient.client,
            ).thenAnswer((_) async => mockClient);

            // Create a real request handler with mocked http client
            final requestHandler = AuthRequestHandler(
              app,
              httpClient: mockHttpClient,
            );

            // Initialize auth service with our request handler
            Auth(app, requestHandler: requestHandler);

            // Verify emulator is enabled
            expect(Environment.isAuthEmulatorEnabled(), isTrue);

            // Close the app - this should call delete() on auth service
            // which should close the HTTP client
            await app.close();

            // Verify app is marked as deleted
            expect(app.isDeleted, isTrue);

            // Verify client.close() was called
            verify(mockClient.close).called(1);
          });
        },
      );

      test(
        'closes firestore service and HTTP client when emulator is enabled',
        () async {
          const firestoreEmulatorHost = 'localhost:8080';
          final testEnv = <String, String>{
            Environment.firestoreEmulatorHost: firestoreEmulatorHost,
          };

          await runZoned(zoneValues: {envSymbol: testEnv}, () async {
            final app = FirebaseApp.initializeApp(
              options: const AppOptions(projectId: mockProjectId),
            );

            // Initialize firestore service
            app.firestore();

            // Verify emulator is enabled
            expect(Environment.isFirestoreEmulatorEnabled(), isTrue);

            // Close the app - this should call delete() on firestore service
            await app.close();

            // Verify app is marked as deleted
            expect(app.isDeleted, isTrue);

            // Verify accessing service after close throws
            expect(
              app.firestore,
              throwsA(
                isA<FirebaseAppException>().having(
                  (e) => e.code,
                  'code',
                  AppErrorCode.appDeleted.code,
                ),
              ),
            );
          });
        },
      );
    });
  });
}
