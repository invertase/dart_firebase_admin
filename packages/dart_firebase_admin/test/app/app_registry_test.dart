import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

import '../mock_service_account.dart';

void main() {
  group('AppRegistry', () {
    late AppRegistry registry;

    setUp(() {
      // Reset the singleton by setting to null, then get fresh instance
      AppRegistry.instance = null;
      registry = AppRegistry.getDefault();
    });

    tearDown(() {
      // Clean up all apps
      for (final app in registry.apps.toList()) {
        registry.removeApp(app.name);
      }
      // Reset singleton for next test
      AppRegistry.instance = null;
    });

    group('singleton behavior', () {
      test('getDefault returns same instance', () {
        final instance1 = AppRegistry.getDefault();
        final instance2 = AppRegistry.getDefault();

        expect(identical(instance1, instance2), isTrue);
      });

      test('instance getter returns current singleton', () {
        final defaultInstance = AppRegistry.getDefault();
        expect(AppRegistry.instance, same(defaultInstance));
      });

      test('instance setter allows resetting singleton for testing', () {
        final firstInstance = AppRegistry.getDefault();

        // Reset to null
        AppRegistry.instance = null;
        expect(AppRegistry.instance, isNull);

        // Getting default creates new instance
        final secondInstance = AppRegistry.getDefault();
        expect(secondInstance, isNotNull);
        expect(identical(firstInstance, secondInstance), isFalse);
      });
    });

    group('fetchOptionsFromEnvironment', () {
      test('returns AppOptions with ADC when FIREBASE_CONFIG not set', () {
        runZoned(() {
          final options = registry.fetchOptionsFromEnvironment();

          expect(options.credential, isNotNull);
          expect(options.credential, isA<ApplicationDefaultCredential>());
          expect(options.projectId, isNull);
          expect(options.databaseURL, isNull);
          expect(options.storageBucket, isNull);
        }, zoneValues: {envSymbol: <String, String>{}});
      });

      test('returns AppOptions with ADC when FIREBASE_CONFIG is empty', () {
        runZoned(
          () {
            final options = registry.fetchOptionsFromEnvironment();

            expect(options.credential, isNotNull);
            expect(options.credential, isA<ApplicationDefaultCredential>());
          },
          zoneValues: {
            envSymbol: {'FIREBASE_CONFIG': ''},
          },
        );
      });

      test('parses FIREBASE_CONFIG as JSON when starts with {', () {
        const configJson =
            '{"projectId":"test-project",'
            '"databaseURL":"https://test.firebaseio.com",'
            '"storageBucket":"test-bucket.appspot.com",'
            '"serviceAccountId":"test@example.com"}';

        runZoned(
          () {
            final options = registry.fetchOptionsFromEnvironment();

            expect(options.projectId, 'test-project');
            expect(options.databaseURL, 'https://test.firebaseio.com');
            expect(options.storageBucket, 'test-bucket.appspot.com');
            expect(options.serviceAccountId, 'test@example.com');
            expect(options.credential, isA<ApplicationDefaultCredential>());
          },
          zoneValues: {
            envSymbol: {'FIREBASE_CONFIG': configJson},
          },
        );
      });

      test('parses FIREBASE_CONFIG with partial fields', () {
        const configJson = '{"projectId":"partial-project"}';

        runZoned(
          () {
            final options = registry.fetchOptionsFromEnvironment();

            expect(options.projectId, 'partial-project');
            expect(options.databaseURL, isNull);
            expect(options.storageBucket, isNull);
          },
          zoneValues: {
            envSymbol: {'FIREBASE_CONFIG': configJson},
          },
        );
      });

      test('reads FIREBASE_CONFIG as file path when not JSON', () {
        // Create temporary config file
        final tempDir = Directory.systemTemp.createTempSync('firebase_test_');
        final configFile = File('${tempDir.path}/firebase-config.json');

        try {
          configFile.writeAsStringSync(
            jsonEncode({
              'projectId': 'file-project',
              'databaseURL': 'https://file-project.firebaseio.com',
              'storageBucket': 'file-bucket.appspot.com',
            }),
          );

          runZoned(
            () {
              final options = registry.fetchOptionsFromEnvironment();

              expect(options.projectId, 'file-project');
              expect(
                options.databaseURL,
                'https://file-project.firebaseio.com',
              );
              expect(options.storageBucket, 'file-bucket.appspot.com');
              expect(options.credential, isA<ApplicationDefaultCredential>());
            },
            zoneValues: {
              envSymbol: {'FIREBASE_CONFIG': configFile.path},
            },
          );
        } finally {
          // Cleanup
          tempDir.deleteSync(recursive: true);
        }
      });

      test(
        'throws FirebaseAppException when FIREBASE_CONFIG has invalid JSON',
        () {
          runZoned(
            () {
              expect(
                () => registry.fetchOptionsFromEnvironment(),
                throwsA(
                  isA<FirebaseAppException>()
                      .having((e) => e.code, 'code', 'app/invalid-argument')
                      .having(
                        (e) => e.message,
                        'message',
                        contains('Failed to parse FIREBASE_CONFIG'),
                      ),
                ),
              );
            },
            zoneValues: {
              envSymbol: {'FIREBASE_CONFIG': '{invalid json}'},
            },
          );
        },
      );

      test('throws FirebaseAppException when file path does not exist', () {
        runZoned(
          () {
            expect(
              () => registry.fetchOptionsFromEnvironment(),
              throwsA(
                isA<FirebaseAppException>()
                    .having((e) => e.code, 'code', 'app/invalid-argument')
                    .having(
                      (e) => e.message,
                      'message',
                      contains('Failed to parse FIREBASE_CONFIG'),
                    ),
              ),
            );
          },
          zoneValues: {
            envSymbol: {'FIREBASE_CONFIG': '/nonexistent/path/config.json'},
          },
        );
      });

      test('throws FirebaseAppException when JSON is not an object', () {
        const configJson = '[1,2,3]'; // Array instead of object

        runZoned(
          () {
            expect(
              () => registry.fetchOptionsFromEnvironment(),
              throwsA(isA<FirebaseAppException>()),
            );
          },
          zoneValues: {
            envSymbol: {'FIREBASE_CONFIG': configJson},
          },
        );
      });
    });

    group('initializeApp - edge cases not covered by firebase_app_test', () {
      test(
        'throws when app exists from env and trying to init with explicit options',
        () {
          runZoned(() {
            // First: initialize from env
            registry.initializeApp(name: 'test-app');

            // Second: try to initialize with explicit options
            expect(
              () => registry.initializeApp(
                options: const AppOptions(projectId: mockProjectId),
                name: 'test-app',
              ),
              throwsA(
                isA<FirebaseAppException>().having(
                  (e) => e.code,
                  'code',
                  'app/invalid-app-options',
                ),
              ),
            );
          }, zoneValues: {envSymbol: <String, String>{}});
        },
      );

      test(
        'throws when app exists with explicit options and trying to init from env',
        () {
          runZoned(() {
            // First: initialize with explicit options
            registry.initializeApp(
              options: const AppOptions(projectId: mockProjectId),
              name: 'test-app',
            );

            // Second: try to initialize from env
            expect(
              () => registry.initializeApp(name: 'test-app'),
              throwsA(
                isA<FirebaseAppException>().having(
                  (e) => e.code,
                  'code',
                  'app/invalid-app-options',
                ),
              ),
            );
          }, zoneValues: {envSymbol: <String, String>{}});
        },
      );

      test('returns same app when both initialized from env', () {
        runZoned(() {
          final app1 = registry.initializeApp(name: 'env-app');
          final app2 = registry.initializeApp(name: 'env-app');

          expect(identical(app1, app2), isTrue);
        }, zoneValues: {envSymbol: <String, String>{}});
      });

      test('uses AppOptions equality for duplicate detection', () {
        const options1 = AppOptions(
          projectId: 'project1',
          databaseURL: 'https://db1.firebaseio.com',
        );
        const options2 = AppOptions(
          projectId: 'project1',
          databaseURL: 'https://db1.firebaseio.com',
        );
        const options3 = AppOptions(
          projectId: 'project2', // Different
          databaseURL: 'https://db1.firebaseio.com',
        );

        // Same options should return same app
        final app1 = registry.initializeApp(options: options1, name: 'test');
        final app2 = registry.initializeApp(options: options2, name: 'test');
        expect(identical(app1, app2), isTrue);

        // Different options should throw
        expect(
          () => registry.initializeApp(options: options3, name: 'test'),
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.code,
              'code',
              'app/duplicate-app',
            ),
          ),
        );
      });
    });

    group('removeApp', () {
      test('removes app from registry by name', () {
        registry.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
          name: 'test-app',
        );

        expect(registry.apps, hasLength(1));

        registry.removeApp('test-app');

        expect(registry.apps, isEmpty);
      });

      test('does nothing when removing nonexistent app', () {
        registry.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
          name: 'existing-app',
        );

        expect(registry.apps, hasLength(1));

        // Remove nonexistent app - should not throw
        registry.removeApp('nonexistent-app');

        // Existing app should still be there
        expect(registry.apps, hasLength(1));
      });

      test('allows re-initializing app after removal', () {
        const options = AppOptions(projectId: mockProjectId);

        final app1 = registry.initializeApp(options: options, name: 'test-app');
        registry.removeApp('test-app');

        // Should be able to create app with same name again
        final app2 = registry.initializeApp(options: options, name: 'test-app');

        expect(app1, isNot(same(app2)));
        expect(app2.name, 'test-app');
      });
    });

    group('app name validation edge cases', () {
      test('throws for empty string app name in initializeApp', () {
        expect(
          () => registry.initializeApp(
            options: const AppOptions(projectId: mockProjectId),
            name: '',
          ),
          throwsA(
            isA<FirebaseAppException>()
                .having((e) => e.code, 'code', 'app/invalid-app-name')
                .having(
                  (e) => e.message,
                  'message',
                  contains('non-empty string'),
                ),
          ),
        );
      });

      test('throws for empty string app name in getApp', () {
        expect(
          () => registry.getApp(''),
          throwsA(
            isA<FirebaseAppException>()
                .having((e) => e.code, 'code', 'app/invalid-app-name')
                .having(
                  (e) => e.message,
                  'message',
                  contains('non-empty string'),
                ),
          ),
        );
      });

      test('accepts app names with special characters', () {
        const specialNames = [
          'app-with-dashes',
          'app_with_underscores',
          'app.with.dots',
          'app123',
          'app-1_2.3',
        ];

        for (final name in specialNames) {
          final app = registry.initializeApp(
            options: const AppOptions(projectId: mockProjectId),
            name: name,
          );

          expect(app.name, name);
          registry.removeApp(name);
        }
      });
    });

    group('getApp error messages', () {
      test('provides helpful message for missing default app', () {
        expect(
          () => registry.getApp(),
          throwsA(
            isA<FirebaseAppException>()
                .having((e) => e.code, 'code', 'app/no-app')
                .having(
                  (e) => e.message,
                  'message',
                  allOf(
                    contains('default Firebase app does not exist'),
                    contains('initializeApp()'),
                  ),
                ),
          ),
        );
      });

      test('provides helpful message for missing named app', () {
        expect(
          () => registry.getApp('my-app'),
          throwsA(
            isA<FirebaseAppException>()
                .having((e) => e.code, 'code', 'app/no-app')
                .having(
                  (e) => e.message,
                  'message',
                  allOf(
                    contains('my-app'),
                    contains('does not exist'),
                    contains('initializeApp()'),
                  ),
                ),
          ),
        );
      });
    });

    group('apps property', () {
      test('returns unmodifiable list', () {
        registry.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
          name: 'test-app',
        );

        final apps = registry.apps;

        // Attempting to modify should throw
        expect(apps.clear, throwsUnsupportedError);
        expect(() => apps.add(apps.first), throwsUnsupportedError);
      });

      test('returns new list instance on each call', () {
        registry.initializeApp(
          options: const AppOptions(projectId: mockProjectId),
          name: 'test-app',
        );

        final apps1 = registry.apps;
        final apps2 = registry.apps;

        // Should be equal but not identical
        expect(apps1, equals(apps2));
        expect(identical(apps1, apps2), isFalse);
      });
    });
  });
}
