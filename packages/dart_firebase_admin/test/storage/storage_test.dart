import 'dart:async';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:dart_firebase_admin/src/storage/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_storage/googleapis_storage.dart' as gcs;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../helpers.dart';

class MockAuthClient extends Mock implements auth.AuthClient {}

void main() {
  group('Storage', () {
    late FirebaseApp app;
    late FirebaseApp appWithBucket;
    late MockAuthClient mockClient;

    setUp(() {
      mockClient = MockAuthClient();

      // Create app without storage bucket
      app = FirebaseApp.initializeApp(
        name: 'test-app-${DateTime.now().millisecondsSinceEpoch}',
        options: AppOptions(projectId: projectId, httpClient: mockClient),
      );

      // Create app with storage bucket configured
      appWithBucket = FirebaseApp.initializeApp(
        name: 'test-app-bucket-${DateTime.now().millisecondsSinceEpoch}',
        options: AppOptions(
          projectId: projectId,
          storageBucket: 'bucketName.appspot.com',
          httpClient: mockClient,
        ),
      );
    });

    tearDown(() async {
      await app.close();
      await appWithBucket.close();
    });

    group('Constructor', () {
      test('should not throw given a valid app', () {
        expect(() => Storage.internal(app), returnsNormally);
      });

      test('should create storage instance successfully', () {
        final storage = Storage.internal(app);
        expect(storage, isA<Storage>());
      });

      test('should be singleton per app', () {
        final storage1 = Storage.internal(app);
        final storage2 = Storage.internal(app);
        expect(storage1, same(storage2));
      });
    });

    group('app', () {
      test('returns the app from the constructor', () {
        final storage = Storage.internal(app);
        // We expect referential equality here
        expect(storage.app, same(app));
      });

      test('is read-only', () {
        final storage = Storage.internal(app);
        // In Dart, final properties are inherently read-only
        expect(storage.app, isA<FirebaseApp>());
      });
    });

    group('bucket()', () {
      test('should return a bucket object when called with no arguments', () {
        final storage = Storage.internal(appWithBucket);
        final bucket = storage.bucket(null);
        expect(bucket, isA<gcs.Bucket>());
        expect(bucket.name, 'bucketName.appspot.com');
      });

      test('should return a bucket object when called with valid name', () {
        final storage = Storage.internal(app);
        final bucket = storage.bucket('foo');
        expect(bucket, isA<gcs.Bucket>());
        expect(bucket.name, 'foo');
      });

      test(
        'should throw when no bucket name provided and no default configured',
        () {
          final storage = Storage.internal(app);

          expect(
            () => storage.bucket(null),
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
                    contains('Bucket name not specified or invalid'),
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    contains(
                      'Specify a valid bucket name via the storageBucket option',
                    ),
                  )
                  .having(
                    (e) => e.message,
                    'message',
                    contains('calling the bucket() method'),
                  ),
            ),
          );
        },
      );

      test('should throw when empty string is provided', () {
        final storage = Storage.internal(app);

        expect(
          () => storage.bucket(''),
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
                  contains('Bucket name not specified or invalid'),
                ),
          ),
        );
      });

      test('should create multiple buckets with different names', () {
        final storage = Storage.internal(app);
        final bucket1 = storage.bucket('bucket-1');
        final bucket2 = storage.bucket('bucket-2');

        expect(bucket1.name, 'bucket-1');
        expect(bucket2.name, 'bucket-2');
      });

      test('should prioritize explicit name over default bucket', () {
        final storage = Storage.internal(appWithBucket);
        final bucket = storage.bucket('custom-bucket');

        expect(bucket.name, 'custom-bucket');
        expect(bucket.name, isNot('bucketName.appspot.com'));
      });
    });

    group('Emulator mode', () {
      const validEmulatorHost = 'localhost:9199';
      const invalidEmulatorHost = 'https://localhost:9199';

      test(
        'sets up correctly when FIREBASE_STORAGE_EMULATOR_HOST is set',
        () async {
          final testEnv = <String, String>{
            Environment.firebaseStorageEmulatorHost: validEmulatorHost,
          };

          await runZoned(zoneValues: {envSymbol: testEnv}, () async {
            final testApp = FirebaseApp.initializeApp(
              name: 'emulator-test-${DateTime.now().millisecondsSinceEpoch}',
              options: AppOptions(projectId: projectId, httpClient: mockClient),
            );
            addTearDown(() async {
              await testApp.close();
            });

            // Should create storage without errors
            final storage = Storage.internal(testApp);
            expect(storage, isA<Storage>());

            // Verify that storage works in emulator mode
            expect(() => storage.bucket('test-bucket'), returnsNormally);
          });
        },
      );

      test('throws if FIREBASE_STORAGE_EMULATOR_HOST has a protocol', () async {
        final testEnv = <String, String>{
          Environment.firebaseStorageEmulatorHost: invalidEmulatorHost,
        };

        await runZoned(zoneValues: {envSymbol: testEnv}, () async {
          final testApp = FirebaseApp.initializeApp(
            name:
                'emulator-protocol-test-${DateTime.now().millisecondsSinceEpoch}',
            options: AppOptions(projectId: projectId, httpClient: mockClient),
          );
          addTearDown(() async {
            await testApp.close();
          });

          expect(
            () => Storage.internal(testApp),
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
                    contains(
                      'FIREBASE_STORAGE_EMULATOR_HOST should not contain a protocol',
                    ),
                  ),
            ),
          );
        });
      });

      test('throws if protocol is http://', () async {
        final testEnv = <String, String>{
          Environment.firebaseStorageEmulatorHost: 'http://localhost:9199',
        };

        await runZoned(zoneValues: {envSymbol: testEnv}, () async {
          final testApp = FirebaseApp.initializeApp(
            name: 'emulator-http-test-${DateTime.now().millisecondsSinceEpoch}',
            options: AppOptions(projectId: projectId, httpClient: mockClient),
          );
          addTearDown(() async {
            await testApp.close();
          });

          expect(
            () => Storage.internal(testApp),
            throwsA(
              isA<FirebaseAppException>().having(
                (e) => e.message,
                'message',
                contains(
                  'FIREBASE_STORAGE_EMULATOR_HOST should not contain a protocol',
                ),
              ),
            ),
          );
        });
      });

      test('works correctly without emulator configuration', () async {
        // Empty environment - no emulator
        final testEnv = <String, String>{};

        await runZoned(zoneValues: {envSymbol: testEnv}, () async {
          final testApp = FirebaseApp.initializeApp(
            name: 'no-emulator-test-${DateTime.now().millisecondsSinceEpoch}',
            options: AppOptions(projectId: projectId, httpClient: mockClient),
          );
          addTearDown(() async {
            await testApp.close();
          });

          final storage = Storage.internal(testApp);
          expect(storage, isA<Storage>());
          expect(() => storage.bucket('test-bucket'), returnsNormally);
        });
      });
    });

    group('FirebaseApp.storage()', () {
      late FirebaseApp testApp;

      setUp(() {
        testApp = FirebaseApp.initializeApp(
          name: 'storage-api-test-${DateTime.now().millisecondsSinceEpoch}',
          options: AppOptions(
            projectId: projectId,
            storageBucket: 'test-bucket.appspot.com',
            httpClient: mockClient,
          ),
        );
      });

      tearDown(() async {
        await testApp.close();
      });

      test('should return Storage instance and cache it', () {
        final storage1 = testApp.storage();
        final storage2 = testApp.storage();

        expect(storage1, isA<Storage>());
        expect(storage1, same(storage2)); // Cached
      });

      test('should provide access to bucket() method', () {
        final storage = testApp.storage();
        final bucket = storage.bucket(null); // Use default bucket

        expect(bucket, isA<gcs.Bucket>());
        expect(bucket.name, 'test-bucket.appspot.com');
      });
    });

    group('lifecycle', () {
      test('should handle delete() gracefully', () async {
        final testApp = FirebaseApp.initializeApp(
          name: 'delete-test-${DateTime.now().millisecondsSinceEpoch}',
          options: AppOptions(projectId: projectId, httpClient: mockClient),
        );

        final storage = Storage.internal(testApp);
        expect(storage, isNotNull);

        // Delete should not throw
        await storage.delete();

        // Clean up the app
        await testApp.close();
      });

      test('should throw when accessing storage after app.close()', () async {
        final testApp = FirebaseApp.initializeApp(
          name: 'close-test-${DateTime.now().millisecondsSinceEpoch}',
          options: AppOptions(projectId: projectId, httpClient: mockClient),
        );

        // Get storage instance before closing
        final storage = testApp.storage();
        expect(storage, isNotNull);

        // Close the app
        await testApp.close();

        // Trying to get storage after close should throw
        expect(
          testApp.storage,
          throwsA(
            isA<FirebaseAppException>().having(
              (e) => e.errorCode,
              'errorCode',
              equals(AppErrorCode.appDeleted),
            ),
          ),
        );
      });
    });

    group('Integration with underlying Storage library', () {
      test('should pass through to googleapis_storage correctly', () {
        final storage = Storage.internal(appWithBucket);
        final bucket = storage.bucket('integration-test-bucket');

        expect(bucket, isA<gcs.Bucket>());
        expect(bucket.name, 'integration-test-bucket');

        // The bucket should be a valid googleapis_storage.Bucket instance
        expect(bucket.storage, isNotNull);
      });

      test('should handle bucket operations without errors', () {
        final storage = Storage.internal(app);

        // Create multiple buckets
        final bucket1 = storage.bucket('test-bucket-1');
        final bucket2 = storage.bucket('test-bucket-2');
        final bucket3 = storage.bucket('test-bucket-3');

        expect(bucket1.name, 'test-bucket-1');
        expect(bucket2.name, 'test-bucket-2');
        expect(bucket3.name, 'test-bucket-3');
      });
    });
  });
}
