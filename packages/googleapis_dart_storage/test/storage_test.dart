import 'dart:async';

import 'package:googleapis_dart_storage/googleapis_dart_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('StorageOptions', () {
    test('should create with default values', () {
      const options = StorageOptions();
      expect(options.apiEndpoint, isNull);
      expect(options.crc32cGenerator, isNull);
      expect(options.retryOptions, isNull);
      expect(options.authClient, isNull);
      expect(options.useAuthWithCustomEndpoint, isNull);
      expect(options.universeDomain, isNull);
    });

    test('should create with all parameters', () {
      final retryOptions = const RetryOptions(maxRetries: 5);
      final mockClient = MockHttpClient();
      final authClient = Future.value(mockClient as http.Client);

      final options = StorageOptions(
        apiEndpoint: 'https://custom.example.com',
        retryOptions: retryOptions,
        authClient: authClient,
        useAuthWithCustomEndpoint: true,
        universeDomain: 'example.com',
      );

      expect(options.apiEndpoint, 'https://custom.example.com');
      expect(options.retryOptions, retryOptions);
      expect(options.authClient, authClient);
      expect(options.useAuthWithCustomEndpoint, true);
      expect(options.universeDomain, 'example.com');
    });

    group('copyWith', () {
      test('should return new instance with updated values', () {
        final originalRetryOptions = const RetryOptions(maxRetries: 3);
        final originalOptions = StorageOptions(
          apiEndpoint: 'https://original.example.com',
          retryOptions: originalRetryOptions,
          universeDomain: 'original.com',
        );

        final newRetryOptions = const RetryOptions(maxRetries: 10);
        final copied = originalOptions.copyWith(
          apiEndpoint: 'https://new.example.com',
          retryOptions: newRetryOptions,
          universeDomain: 'new.com',
        );

        expect(copied.apiEndpoint, 'https://new.example.com');
        expect(copied.retryOptions, newRetryOptions);
        expect(copied.universeDomain, 'new.com');
        expect(originalOptions.apiEndpoint, 'https://original.example.com');
        expect(originalOptions.retryOptions, originalRetryOptions);
      });

      test('should preserve original values when not specified', () {
        final originalRetryOptions = const RetryOptions(maxRetries: 3);
        final originalOptions = StorageOptions(
          apiEndpoint: 'https://original.example.com',
          retryOptions: originalRetryOptions,
        );

        final copied = originalOptions.copyWith(
          universeDomain: 'new.com',
        );

        expect(copied.apiEndpoint, 'https://original.example.com');
        expect(copied.retryOptions, originalRetryOptions);
        expect(copied.universeDomain, 'new.com');
      });

      test('should preserve original values when null is passed', () {
        final originalRetryOptions = const RetryOptions();
        final originalOptions = StorageOptions(
          apiEndpoint: 'https://original.example.com',
          retryOptions: originalRetryOptions,
        );

        // copyWith uses ?? operator, so passing null preserves original values
        final copied = originalOptions.copyWith(
          apiEndpoint: null,
          retryOptions: null,
        );

        expect(copied.apiEndpoint, 'https://original.example.com');
        expect(copied.retryOptions, originalRetryOptions);
      });
    });
  });

  group('Storage', () {
    group('constructor', () {
      test('should create with default StorageOptions', () {
        final storage = Storage(const StorageOptions());
        expect(storage.options, isA<StorageOptions>());
        expect(storage.retryOptions, isA<RetryOptions>());
      });

      test('should create with custom StorageOptions', () {
        final retryOptions = const RetryOptions(maxRetries: 5);
        final options = StorageOptions(retryOptions: retryOptions);
        final storage = Storage(options);

        expect(storage.options, options);
        expect(storage.retryOptions.maxRetries, 5);
      });
    });

    group('endpoint calculation', () {
      test('should use default googleapis.com endpoint', () {
        final storage = Storage(const StorageOptions());
        expect(storage, isA<Storage>());
        expect(storage.config.apiEndpoint, 'https://storage.googleapis.com');
      });

      test('should use custom universe domain', () {
        final storage = Storage(
          const StorageOptions(universeDomain: 'example.com'),
        );
        expect(storage.config.apiEndpoint, 'https://storage.example.com');
      });

      test('should use explicit apiEndpoint', () {
        final storage = Storage(
          const StorageOptions(apiEndpoint: 'https://custom.example.com'),
        );
        expect(storage.config.apiEndpoint, 'https://custom.example.com');
      });

      test('should handle apiEndpoint without protocol', () {
        final storage = Storage(
          const StorageOptions(apiEndpoint: 'custom.example.com'),
        );
        // Should add https:// prefix
        expect(storage.config.apiEndpoint, 'https://custom.example.com');
      });

      test('should handle apiEndpoint with trailing slashes', () {
        final storage = Storage(
          const StorageOptions(apiEndpoint: 'https://custom.example.com///'),
        );
        // Should remove trailing slashes
        expect(storage.config.apiEndpoint, 'https://custom.example.com');
      });

      test('should use STORAGE_EMULATOR_HOST from environment', () async {
        const emulatorHost = 'localhost:8080';
        final testEnv = <String, String>{
          'STORAGE_EMULATOR_HOST': emulatorHost,
        };

        await runZoned(
          () {
            final storage = Storage(const StorageOptions());
            expect(storage.config.apiEndpoint, 'https://$emulatorHost');
            expect(storage.config.customEndpoint, true);
          },
          zoneValues: {envSymbol: testEnv},
        );
      });

      test('should prioritize explicit apiEndpoint over STORAGE_EMULATOR_HOST',
          () async {
        const emulatorHost = 'localhost:8080';
        const explicitEndpoint = 'https://override.example.com';
        final testEnv = <String, String>{
          'STORAGE_EMULATOR_HOST': emulatorHost,
        };

        await runZoned(
          () {
            final storage = Storage(
              const StorageOptions(apiEndpoint: explicitEndpoint),
            );
            // Explicit apiEndpoint should take precedence
            expect(storage.config.apiEndpoint, explicitEndpoint);
            expect(storage.config.customEndpoint, true);
          },
          zoneValues: {envSymbol: testEnv},
        );
      });

      test('should sanitize STORAGE_EMULATOR_HOST without protocol', () async {
        const emulatorHost = 'localhost:8080';
        final testEnv = <String, String>{
          'STORAGE_EMULATOR_HOST': emulatorHost,
        };

        await runZoned(
          () {
            final storage = Storage(const StorageOptions());
            // Should add https:// prefix
            expect(storage.config.apiEndpoint, 'https://$emulatorHost');
          },
          zoneValues: {envSymbol: testEnv},
        );
      });

      test('should sanitize STORAGE_EMULATOR_HOST with trailing slashes',
          () async {
        const emulatorHost = 'localhost:8080///';
        final testEnv = <String, String>{
          'STORAGE_EMULATOR_HOST': emulatorHost,
        };

        await runZoned(
          () {
            final storage = Storage(const StorageOptions());
            // Should remove trailing slashes
            expect(storage.config.apiEndpoint, 'https://localhost:8080');
          },
          zoneValues: {envSymbol: testEnv},
        );
      });
    });

    group('retryOptions', () {
      test('should return default RetryOptions when not specified', () {
        final storage = Storage(const StorageOptions());
        final retryOptions = storage.retryOptions;

        expect(retryOptions, isA<RetryOptions>());
        expect(retryOptions.autoRetry, true);
        expect(retryOptions.maxRetries, 3);
      });

      test('should return custom RetryOptions when specified', () {
        final customRetryOptions = const RetryOptions(
          autoRetry: false,
          maxRetries: 10,
        );
        final storage = Storage(
          StorageOptions(retryOptions: customRetryOptions),
        );

        expect(storage.retryOptions, customRetryOptions);
        expect(storage.retryOptions.autoRetry, false);
        expect(storage.retryOptions.maxRetries, 10);
      });
    });

    group('.bucket()', () {
      test('should create a new Bucket instance', () {
        final storage = Storage(const StorageOptions());
        final bucket = storage.bucket('test-bucket');
        expect(bucket, isA<Bucket>());
      });

      test('should create Bucket with correct name', () {
        final storage = Storage(const StorageOptions());
        final bucket = storage.bucket('my-bucket-name');
        expect(bucket.id, 'my-bucket-name');
        expect(bucket.metadata.inner.name, 'my-bucket-name');
      });

      test('should create Bucket with BucketOptions', () {
        final storage = Storage(const StorageOptions());
        final bucketOptions = const BucketOptions(
          userProject: 'my-project',
          kmsKeyName: 'my-key',
        );
        final bucket = storage.bucket('test-bucket', bucketOptions);

        expect(bucket, isA<Bucket>());
        expect(bucket.options.userProject, 'my-project');
        expect(bucket.options.kmsKeyName, 'my-key');
      });

      test('should create Bucket with default BucketOptions when not provided',
          () {
        final storage = Storage(const StorageOptions());
        final bucket = storage.bucket('test-bucket');

        expect(bucket.options, isA<BucketOptions>());
        expect(bucket.options.userProject, isNull);
      });

      // TODO: Align the error message once we have a proper exception class.
      test('should throw Exception when bucket name is empty', () {
        final storage = Storage(const StorageOptions());

        expect(
          () => storage.bucket(''),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Bucket name is required'),
          )),
        );
      });

      test('should create multiple buckets with different names', () {
        final storage = Storage(const StorageOptions());
        final bucket1 = storage.bucket('bucket-1');
        final bucket2 = storage.bucket('bucket-2');

        expect(bucket1.id, 'bucket-1');
        expect(bucket2.id, 'bucket-2');
        expect(bucket1, isNot(same(bucket2)));
      });

      test('should create bucket that references the storage instance', () {
        final storage = Storage(const StorageOptions());
        final bucket = storage.bucket('test-bucket');

        expect(bucket.storage, same(storage));
      });
    });
  });
}
