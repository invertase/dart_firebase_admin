import 'dart:async';

import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:google_cloud_storage/google_cloud_storage.dart';
import 'package:google_cloud_storage/src/environment.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthClient extends Mock implements auth.AuthClient {}

class MockStorageApi extends Mock implements storage_v1.StorageApi {}

class MockBucketsResource extends Mock implements storage_v1.BucketsResource {}

class MockProjectsResource extends Mock
    implements storage_v1.ProjectsResource {}

class MockHmacKeysResource extends Mock
    implements storage_v1.ProjectsHmacKeysResource {}

class MockServiceAccountResource extends Mock
    implements storage_v1.ProjectsServiceAccountResource {}

/// Test helper that creates a Storage instance with an injectable mock client
class TestStorage extends Storage {
  final storage_v1.StorageApi mockClient;

  TestStorage(this.mockClient, {String? projectId})
    : super(
        _TestStorageOptions(
          projectId: projectId ?? 'test-project',
          authClient: MockAuthClient(),
          useAuthWithCustomEndpoint: false,
        ),
      );

  @override
  Future<storage_v1.StorageApi> get storageClient async => mockClient;

  @override
  Future<auth.AuthClient> get authClient async => MockAuthClient();
}

// Helper class to create StorageOptions with projectId for testing
// Since StorageOptions doesn't expose projectId in its constructor,
// we need to use a workaround by creating a custom class that preserves
// projectId when copyWith is called (which Storage does internally)
class _TestStorageOptions extends StorageOptions {
  _TestStorageOptions({
    required String projectId,
    super.authClient,
    super.useAuthWithCustomEndpoint,
    super.apiEndpoint,
    super.crc32cGenerator,
    super.retryOptions,
    super.universeDomain,
  }) : _projectId = projectId,
       super();

  final String _projectId;

  // Override projectId getter to return our test projectId
  @override
  String? get projectId => _projectId;

  // Override copyWith to preserve projectId when Storage calls it
  @override
  StorageOptions copyWith({
    String? apiEndpoint,
    Crc32Generator? crc32cGenerator,
    RetryOptions? retryOptions,
    Credential? credential,
    FutureOr<auth.AuthClient>? authClient,
    bool? useAuthWithCustomEndpoint,
    String? universeDomain,
    String? projectId,
  }) {
    return _TestStorageOptions(
      projectId: projectId ?? _projectId,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      crc32cGenerator: crc32cGenerator ?? this.crc32cGenerator,
      retryOptions: retryOptions ?? this.retryOptions,
      authClient: authClient ?? super.authClient,
      useAuthWithCustomEndpoint:
          useAuthWithCustomEndpoint ?? super.useAuthWithCustomEndpoint,
      universeDomain: universeDomain ?? super.universeDomain,
    );
  }
}

void main() {
  group('StorageOptions', () {
    test('should create with default values', () {
      const options = StorageOptions();
      expect(options.apiEndpoint, isNull);
      expect(
        options.crc32cGenerator,
        isNull,
      ); // Default is applied in Storage constructor
      expect(options.retryOptions, isNull);
      expect(options.credential, isNull);
      expect(options.authClient, isNull);
      expect(options.useAuthWithCustomEndpoint, isNull);
      expect(options.universeDomain, isNull);
    });

    test('should create with all parameters', () {
      final retryOptions = const RetryOptions(maxRetries: 5);
      final mockClient = MockAuthClient();

      final options = StorageOptions(
        apiEndpoint: 'https://custom.example.com',
        retryOptions: retryOptions,
        authClient: mockClient,
        useAuthWithCustomEndpoint: true,
        universeDomain: 'example.com',
      );

      expect(options.apiEndpoint, 'https://custom.example.com');
      expect(options.retryOptions, retryOptions);
      expect(options.authClient, mockClient);
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

        final copied = originalOptions.copyWith(universeDomain: 'new.com');

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

      test('should update crc32cGenerator', () {
        final originalGenerator = defaultCrc32cValidatorGenerator;
        final originalOptions = StorageOptions(
          crc32cGenerator: originalGenerator,
        );

        final newGenerator = defaultCrc32cValidatorGenerator;
        final copied = originalOptions.copyWith(crc32cGenerator: newGenerator);

        expect(copied.crc32cGenerator, newGenerator);
        expect(originalOptions.crc32cGenerator, originalGenerator);
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

        // Storage constructor modifies options (adds apiEndpoint), so compare properties
        expect(storage.options.retryOptions, retryOptions);
        expect(storage.retryOptions.maxRetries, 5);
      });
    });

    group('endpoint calculation', () {
      test('should use default googleapis.com endpoint', () {
        runZoned(() {
          final storage = Storage(const StorageOptions());
          expect(storage, isA<Storage>());
          expect(storage.config.apiEndpoint, 'https://storage.googleapis.com');
        }, zoneValues: {envSymbol: <String, String>{}});
      });

      test('should use custom universe domain', () {
        runZoned(() {
          final storage = Storage(
            const StorageOptions(universeDomain: 'example.com'),
          );
          expect(storage.config.apiEndpoint, 'https://storage.example.com');
        }, zoneValues: {envSymbol: <String, String>{}});
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
          Environment.storageEmulatorHost: emulatorHost,
        };

        await runZoned(() {
          final storage = Storage(const StorageOptions());
          expect(storage.config.apiEndpoint, 'https://$emulatorHost');
          expect(storage.config.customEndpoint, true);
        }, zoneValues: {envSymbol: testEnv});
      });

      test(
        'should prioritize explicit apiEndpoint over STORAGE_EMULATOR_HOST',
        () async {
          const emulatorHost = 'localhost:8080';
          const explicitEndpoint = 'https://override.example.com';
          final testEnv = <String, String>{
            Environment.storageEmulatorHost: emulatorHost,
          };

          await runZoned(() {
            final storage = Storage(
              const StorageOptions(apiEndpoint: explicitEndpoint),
            );
            // Explicit apiEndpoint should take precedence
            expect(storage.config.apiEndpoint, explicitEndpoint);
            expect(storage.config.customEndpoint, true);
          }, zoneValues: {envSymbol: testEnv});
        },
      );

      test('should sanitize STORAGE_EMULATOR_HOST without protocol', () async {
        const emulatorHost = 'localhost:8080';
        final testEnv = <String, String>{
          Environment.storageEmulatorHost: emulatorHost,
        };

        await runZoned(() {
          final storage = Storage(const StorageOptions());
          // Should add https:// prefix
          expect(storage.config.apiEndpoint, 'https://$emulatorHost');
        }, zoneValues: {envSymbol: testEnv});
      });

      test(
        'should sanitize STORAGE_EMULATOR_HOST with trailing slashes',
        () async {
          const emulatorHost = 'localhost:8080///';
          final testEnv = <String, String>{
            Environment.storageEmulatorHost: emulatorHost,
          };

          await runZoned(() {
            final storage = Storage(const StorageOptions());
            // Should remove trailing slashes
            expect(storage.config.apiEndpoint, 'https://localhost:8080');
          }, zoneValues: {envSymbol: testEnv});
        },
      );
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
        expect(bucket.metadata.name, 'my-bucket-name');
      });

      test('should create Bucket with BucketOptions', () {
        final storage = Storage(const StorageOptions());
        final bucketOptions = const BucketOptions(
          userProject: 'my-project',
          kmsKeyName: 'my-key',
        );
        final bucket = storage.bucket('test-bucket', bucketOptions);

        expect(bucket, isA<Bucket>());
        // In Node.js, only userProject is exposed on the bucket instance
        expect(bucket.userProject, 'my-project');
        // kmsKeyName is not exposed on bucket (only used when creating files)
      });

      test(
        'should create Bucket with default BucketOptions when not provided',
        () {
          final storage = Storage(const StorageOptions());
          final bucket = storage.bucket('test-bucket');

          expect(bucket, isA<Bucket>());
          expect(bucket.userProject, isNull);
        },
      );

      test('should throw ArgumentError when bucket name is empty', () {
        final storage = Storage(const StorageOptions());

        expect(
          () => storage.bucket(''),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('bucket name is needed'),
            ),
          ),
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

    group('.channel()', () {
      test('should create a new Channel instance', () {
        final storage = Storage(const StorageOptions());
        final channel = storage.channel('channel-id', 'resource-id');
        expect(channel, isA<Channel>());
      });

      test('should create Channel with correct id and resourceId', () {
        final storage = Storage(const StorageOptions());
        final channel = storage.channel('my-channel-id', 'my-resource-id');
        expect(channel.metadata.id, 'my-channel-id');
        expect(channel.metadata.resourceId, 'my-resource-id');
      });

      test('should throw ArgumentError when channel id is empty', () {
        final storage = Storage(const StorageOptions());

        expect(
          () => storage.channel('', 'resource-id'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Channel ID is required'),
            ),
          ),
        );
      });

      test('should throw ArgumentError when resourceId is empty', () {
        final storage = Storage(const StorageOptions());

        expect(
          () => storage.channel('channel-id', ''),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Resource ID is required'),
            ),
          ),
        );
      });

      test('should create channel that references the storage instance', () {
        final storage = Storage(const StorageOptions());
        final channel = storage.channel('channel-id', 'resource-id');

        expect(channel.storage, same(storage));
      });
    });

    group('.hmacKey()', () {
      test('should create a new HmacKey instance', () {
        final storage = Storage(_TestStorageOptions(projectId: 'test-project'));
        final hmacKey = storage.hmacKey('access-id');
        expect(hmacKey, isA<HmacKey>());
      });

      test('should create HmacKey with correct accessId', () {
        final storage = Storage(_TestStorageOptions(projectId: 'test-project'));
        final hmacKey = storage.hmacKey('my-access-id');
        expect(hmacKey.id, 'my-access-id');
      });

      test('should create HmacKey with HmacKeyOptions', () {
        final storage = Storage(_TestStorageOptions(projectId: 'test-project'));
        final hmacKeyOptions = HmacKeyOptions(projectId: 'custom-project');
        final hmacKey = storage.hmacKey('access-id', hmacKeyOptions);

        expect(hmacKey, isA<HmacKey>());
        expect(hmacKey.metadata.projectId, 'custom-project');
      });

      test('should throw ArgumentError when accessId is empty', () {
        final storage = Storage(_TestStorageOptions(projectId: 'test-project'));

        expect(
          () => storage.hmacKey(''),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('access ID is needed'),
            ),
          ),
        );
      });

      test('should create hmacKey that references the storage instance', () {
        final storage = Storage(_TestStorageOptions(projectId: 'test-project'));
        final hmacKey = storage.hmacKey('access-id');

        expect(hmacKey.storage, same(storage));
      });

      test('should create HmacKey with null projectId when not provided', () {
        final storage = Storage(const StorageOptions());

        final hmacKey = storage.hmacKey('access-id');

        expect(hmacKey.metadata.accessId, 'access-id');
        expect(hmacKey.metadata.projectId, isNull); // No projectId provided
        expect(hmacKey.storage, same(storage));
      });
    });

    group('crc32cGenerator', () {
      test('should use default generator when not specified', () {
        final storage = Storage(const StorageOptions());
        expect(storage.crc32cGenerator, isNotNull);
        // crc32cGenerator stores the function, not the result
        expect(storage.crc32cGenerator, same(defaultCrc32cValidatorGenerator));
      });

      test('should use custom generator when specified', () {
        // Create a custom generator function
        Crc32cValidator customGenerator() => Crc32c();
        final storage = Storage(
          StorageOptions(crc32cGenerator: customGenerator),
        );
        // crc32cGenerator stores the function reference
        expect(storage.crc32cGenerator, same(customGenerator));
        expect(
          storage.crc32cGenerator,
          isNot(same(defaultCrc32cValidatorGenerator)),
        );
      });
    });

    group('.createBucket()', () {
      late TestStorage storage;
      late MockStorageApi mockClient;
      late MockBucketsResource mockBuckets;

      setUpAll(() {
        registerFallbackValue(storage_v1.Bucket());
      });

      setUp(() {
        mockClient = MockStorageApi();
        mockBuckets = MockBucketsResource();
        when(() => mockClient.buckets).thenReturn(mockBuckets);
        storage = TestStorage(mockClient, projectId: 'test-project');
      });

      test('should create bucket successfully', () async {
        final bucketMetadata = storage_v1.Bucket()
          ..name = 'test-bucket'
          ..location = 'US';
        final createdBucket = storage_v1.Bucket()
          ..name = 'test-bucket'
          ..location = 'US'
          ..id = 'test-bucket';

        when(
          () => mockBuckets.insert(
            any(),
            any(),
            predefinedAcl: any(named: 'predefinedAcl'),
            predefinedDefaultObjectAcl: any(
              named: 'predefinedDefaultObjectAcl',
            ),
            projection: any(named: 'projection'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async => createdBucket);

        final result = await storage.createBucket(bucketMetadata);

        expect(result, isA<Bucket>());
        expect(result.id, 'test-bucket');
        expect(result.metadata.name, 'test-bucket');
        verify(
          () => mockBuckets.insert(
            bucketMetadata,
            'test-project',
            predefinedAcl: null,
            predefinedDefaultObjectAcl: null,
            projection: null,
            userProject: null,
          ),
        ).called(1);
      });

      test('should throw ArgumentError when bucket name is null', () {
        final bucketMetadata = storage_v1.Bucket();

        expect(
          () => storage.createBucket(bucketMetadata),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Bucket name is required'),
            ),
          ),
        );
      });

      test('should wrap errors in ApiError', () async {
        final bucketMetadata = storage_v1.Bucket()..name = 'test-bucket';
        final error = Exception('API error');

        when(
          () => mockBuckets.insert(
            any(),
            any(),
            predefinedAcl: any(named: 'predefinedAcl'),
            predefinedDefaultObjectAcl: any(
              named: 'predefinedDefaultObjectAcl',
            ),
            projection: any(named: 'projection'),
            userProject: any(named: 'userProject'),
          ),
        ).thenThrow(error);

        expect(
          () => storage.createBucket(bucketMetadata),
          throwsA(
            isA<ApiError>().having(
              (e) => e.message,
              'message',
              contains('API error'),
            ),
          ),
        );
      });
    });

    group('.createHmacKey()', () {
      late TestStorage storage;
      late MockStorageApi mockClient;
      late MockProjectsResource mockProjects;
      late MockHmacKeysResource mockHmacKeys;

      setUpAll(() {
        registerFallbackValue(storage_v1.HmacKeyMetadata());
        registerFallbackValue(storage_v1.HmacKey());
      });

      setUp(() {
        mockClient = MockStorageApi();
        mockProjects = MockProjectsResource();
        mockHmacKeys = MockHmacKeysResource();
        when(() => mockClient.projects).thenReturn(mockProjects);
        when(() => mockProjects.hmacKeys).thenReturn(mockHmacKeys);
        storage = TestStorage(mockClient, projectId: 'test-project');
      });

      test('should create HMAC key successfully', () async {
        final metadata = storage_v1.HmacKeyMetadata()
          ..accessId = 'ACCESS_ID'
          ..projectId = 'test-project'
          ..serviceAccountEmail = 'test@example.com';
        final response = storage_v1.HmacKey()
          ..metadata = metadata
          ..secret = 'secret-key';

        when(
          () => mockHmacKeys.create(
            any(),
            any(),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async => response);

        final result = await storage.createHmacKey(
          'test@example.com',
          CreateHmacKeyOptions(projectId: 'test-project'),
        );

        expect(result, isA<HmacKey>());
        expect(result.id, 'ACCESS_ID');
        expect(result.metadata.projectId, 'test-project');
        verify(
          () => mockHmacKeys.create(
            'test-project',
            'test@example.com',
            userProject: null,
          ),
        ).called(1);
      });

      test('should throw ApiError when metadata is null', () async {
        final response = storage_v1.HmacKey()..metadata = null;

        when(
          () => mockHmacKeys.create(
            any(),
            any(),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async => response);

        expect(
          () => storage.createHmacKey(
            'test@example.com',
            CreateHmacKeyOptions(projectId: 'test-project'),
          ),
          throwsA(
            isA<ApiError>().having(
              (e) => e.message,
              'message',
              contains('Failed to create HMAC key'),
            ),
          ),
        );
      });

      test('should wrap errors in ApiError', () async {
        final error = Exception('API error');

        when(
          () => mockHmacKeys.create(
            any(),
            any(),
            userProject: any(named: 'userProject'),
          ),
        ).thenThrow(error);

        expect(
          () => storage.createHmacKey(
            'test@example.com',
            CreateHmacKeyOptions(projectId: 'test-project'),
          ),
          throwsA(
            isA<ApiError>().having(
              (e) => e.message,
              'message',
              contains('API error'),
            ),
          ),
        );
      });
    });

    group('.getServiceAccount()', () {
      late TestStorage storage;
      late MockStorageApi mockClient;
      late MockProjectsResource mockProjects;
      late MockServiceAccountResource mockServiceAccount;

      setUpAll(() {
        registerFallbackValue(storage_v1.ServiceAccount());
      });

      setUp(() {
        mockClient = MockStorageApi();
        mockProjects = MockProjectsResource();
        mockServiceAccount = MockServiceAccountResource();
        when(() => mockClient.projects).thenReturn(mockProjects);
        when(() => mockProjects.serviceAccount).thenReturn(mockServiceAccount);
        storage = TestStorage(mockClient, projectId: 'test-project');
      });

      test('should get service account successfully', () async {
        final serviceAccount = storage_v1.ServiceAccount()
          ..emailAddress = 'test@example.com';

        when(
          () => mockServiceAccount.get(
            any(),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async => serviceAccount);

        final result = await storage.getServiceAccount(
          GetServiceAccountOptions(projectId: 'test-project'),
        );

        expect(result, isA<storage_v1.ServiceAccount>());
        expect(result.emailAddress, 'test@example.com');
        verify(
          () => mockServiceAccount.get('test-project', userProject: null),
        ).called(1);
      });

      test('should wrap errors in ApiError', () async {
        final error = Exception('API error');

        when(
          () => mockServiceAccount.get(
            any(),
            userProject: any(named: 'userProject'),
          ),
        ).thenThrow(error);

        expect(
          () => storage.getServiceAccount(
            GetServiceAccountOptions(projectId: 'test-project'),
          ),
          throwsA(
            isA<ApiError>().having(
              (e) => e.message,
              'message',
              contains('API error'),
            ),
          ),
        );
      });
    });

    group('.getBuckets()', () {
      late TestStorage storage;
      late MockStorageApi mockClient;
      late MockBucketsResource mockBuckets;

      setUpAll(() {
        registerFallbackValue(storage_v1.Bucket());
      });

      setUp(() {
        mockClient = MockStorageApi();
        mockBuckets = MockBucketsResource();
        when(() => mockClient.buckets).thenReturn(mockBuckets);
        storage = TestStorage(mockClient, projectId: 'test-project');
      });

      test('should get buckets with autoPaginate=true', () async {
        final bucket1 = storage_v1.Bucket()
          ..id = 'bucket-1'
          ..name = 'bucket-1';
        final bucket2 = storage_v1.Bucket()
          ..id = 'bucket-2'
          ..name = 'bucket-2';

        // First page
        when(
          () => mockBuckets.list(
            any(),
            maxResults: any(named: 'maxResults'),
            pageToken: any(named: 'pageToken'),
            prefix: any(named: 'prefix'),
            projection: any(named: 'projection'),
            softDeleted: any(named: 'softDeleted'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.Buckets()
            ..items = [bucket1]
            ..nextPageToken = 'token-1';
        });

        // Second page
        when(
          () => mockBuckets.list(
            any(),
            maxResults: any(named: 'maxResults'),
            pageToken: 'token-1',
            prefix: any(named: 'prefix'),
            projection: any(named: 'projection'),
            softDeleted: any(named: 'softDeleted'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.Buckets()
            ..items = [bucket2]
            ..nextPageToken = null;
        });

        final (buckets, nextQuery) = await storage.getBuckets(
          const GetBucketsOptions(projectId: 'test-project'),
        );

        expect(buckets, hasLength(2));
        expect(buckets[0].id, 'bucket-1');
        expect(buckets[1].id, 'bucket-2');
        expect(nextQuery, isNull);
      });

      test('should get buckets with autoPaginate=false', () async {
        final bucket1 = storage_v1.Bucket()
          ..id = 'bucket-1'
          ..name = 'bucket-1';

        when(
          () => mockBuckets.list(
            any(),
            maxResults: any(named: 'maxResults'),
            pageToken: any(named: 'pageToken'),
            prefix: any(named: 'prefix'),
            projection: any(named: 'projection'),
            softDeleted: any(named: 'softDeleted'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.Buckets()
            ..items = [bucket1]
            ..nextPageToken = 'token-1';
        });

        final (buckets, nextQuery) = await storage.getBuckets(
          const GetBucketsOptions(
            projectId: 'test-project',
            autoPaginate: false,
          ),
        );

        expect(buckets, hasLength(1));
        expect(buckets[0].id, 'bucket-1');
        expect(nextQuery, isNotNull);
        expect(nextQuery?.pageToken, 'token-1');
      });

      test('should wrap errors in ApiError', () async {
        final error = Exception('API error');

        // Test with autoPaginate=false to avoid stream error handling
        when(
          () => mockBuckets.list(
            any(),
            maxResults: any(named: 'maxResults'),
            pageToken: any(named: 'pageToken'),
            prefix: any(named: 'prefix'),
            projection: any(named: 'projection'),
            softDeleted: any(named: 'softDeleted'),
            userProject: any(named: 'userProject'),
          ),
        ).thenThrow(error);

        expect(
          () => storage.getBuckets(
            const GetBucketsOptions(
              projectId: 'test-project',
              autoPaginate: false,
            ),
          ),
          throwsA(
            isA<ApiError>().having(
              (e) => e.message,
              'message',
              contains('API error'),
            ),
          ),
        );
      });
    });

    group('.getBucketsStream()', () {
      late TestStorage storage;
      late MockStorageApi mockClient;
      late MockBucketsResource mockBuckets;

      setUpAll(() {
        registerFallbackValue(storage_v1.Bucket());
      });

      setUp(() {
        mockClient = MockStorageApi();
        mockBuckets = MockBucketsResource();
        when(() => mockClient.buckets).thenReturn(mockBuckets);
        storage = TestStorage(mockClient, projectId: 'test-project');
      });

      test('should stream buckets from single page', () async {
        final bucket1 = storage_v1.Bucket()
          ..id = 'bucket-1'
          ..name = 'bucket-1';
        final bucket2 = storage_v1.Bucket()
          ..id = 'bucket-2'
          ..name = 'bucket-2';

        when(
          () => mockBuckets.list(
            any(),
            maxResults: any(named: 'maxResults'),
            pageToken: any(named: 'pageToken'),
            prefix: any(named: 'prefix'),
            projection: any(named: 'projection'),
            softDeleted: any(named: 'softDeleted'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.Buckets()
            ..items = [bucket1, bucket2]
            ..nextPageToken = null;
        });

        final buckets = <Bucket>[];
        await for (final bucket in storage.getBucketsStream(
          const GetBucketsOptions(projectId: 'test-project'),
        )) {
          buckets.add(bucket);
        }

        expect(buckets, hasLength(2));
        expect(buckets[0].id, 'bucket-1');
        expect(buckets[1].id, 'bucket-2');
      });

      test('should stream buckets with pagination', () async {
        final bucket1 = storage_v1.Bucket()
          ..id = 'bucket-1'
          ..name = 'bucket-1';
        final bucket2 = storage_v1.Bucket()
          ..id = 'bucket-2'
          ..name = 'bucket-2';

        // First page
        when(
          () => mockBuckets.list(
            any(),
            maxResults: any(named: 'maxResults'),
            pageToken: null,
            prefix: any(named: 'prefix'),
            projection: any(named: 'projection'),
            softDeleted: any(named: 'softDeleted'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.Buckets()
            ..items = [bucket1]
            ..nextPageToken = 'token-1';
        });

        // Second page
        when(
          () => mockBuckets.list(
            any(),
            maxResults: any(named: 'maxResults'),
            pageToken: 'token-1',
            prefix: any(named: 'prefix'),
            projection: any(named: 'projection'),
            softDeleted: any(named: 'softDeleted'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.Buckets()
            ..items = [bucket2]
            ..nextPageToken = null;
        });

        final buckets = <Bucket>[];
        await for (final bucket in storage.getBucketsStream(
          const GetBucketsOptions(projectId: 'test-project'),
        )) {
          buckets.add(bucket);
        }

        expect(buckets, hasLength(2));
        expect(buckets[0].id, 'bucket-1');
        expect(buckets[1].id, 'bucket-2');
      });
    });

    group('.getHmacKeys()', () {
      late TestStorage storage;
      late MockStorageApi mockClient;
      late MockProjectsResource mockProjects;
      late MockHmacKeysResource mockHmacKeys;

      setUpAll(() {
        registerFallbackValue(storage_v1.HmacKeyMetadata());
      });

      setUp(() {
        mockClient = MockStorageApi();
        mockProjects = MockProjectsResource();
        mockHmacKeys = MockHmacKeysResource();
        when(() => mockClient.projects).thenReturn(mockProjects);
        when(() => mockProjects.hmacKeys).thenReturn(mockHmacKeys);
        storage = TestStorage(mockClient, projectId: 'test-project');
      });

      test('should get HMAC keys with autoPaginate=true', () async {
        final key1 = storage_v1.HmacKeyMetadata()
          ..accessId = 'key-1'
          ..projectId = 'test-project';
        final key2 = storage_v1.HmacKeyMetadata()
          ..accessId = 'key-2'
          ..projectId = 'test-project';

        // First page
        when(
          () => mockHmacKeys.list(
            any(),
            serviceAccountEmail: any(named: 'serviceAccountEmail'),
            showDeletedKeys: any(named: 'showDeletedKeys'),
            maxResults: any(named: 'maxResults'),
            pageToken: any(named: 'pageToken'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.HmacKeysMetadata()
            ..items = [key1]
            ..nextPageToken = 'token-1';
        });

        // Second page
        when(
          () => mockHmacKeys.list(
            any(),
            serviceAccountEmail: any(named: 'serviceAccountEmail'),
            showDeletedKeys: any(named: 'showDeletedKeys'),
            maxResults: any(named: 'maxResults'),
            pageToken: 'token-1',
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.HmacKeysMetadata()
            ..items = [key2]
            ..nextPageToken = null;
        });

        final (keys, nextQuery) = await storage.getHmacKeys(
          const GetHmacKeysOptions(projectId: 'test-project'),
        );

        expect(keys, hasLength(2));
        expect(keys[0].id, 'key-1');
        expect(keys[1].id, 'key-2');
        expect(nextQuery, isNull);
      });

      test('should get HMAC keys with autoPaginate=false', () async {
        final key1 = storage_v1.HmacKeyMetadata()
          ..accessId = 'key-1'
          ..projectId = 'test-project';

        when(
          () => mockHmacKeys.list(
            any(),
            serviceAccountEmail: any(named: 'serviceAccountEmail'),
            showDeletedKeys: any(named: 'showDeletedKeys'),
            maxResults: any(named: 'maxResults'),
            pageToken: any(named: 'pageToken'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.HmacKeysMetadata()
            ..items = [key1]
            ..nextPageToken = 'token-1';
        });

        final (keys, nextQuery) = await storage.getHmacKeys(
          const GetHmacKeysOptions(
            projectId: 'test-project',
            autoPaginate: false,
          ),
        );

        expect(keys, hasLength(1));
        expect(keys[0].id, 'key-1');
        expect(nextQuery, isNotNull);
        expect(nextQuery?.pageToken, 'token-1');
      });

      test('should wrap errors in ApiError', () async {
        final error = Exception('API error');

        // Test with autoPaginate=false to avoid stream error handling
        when(
          () => mockHmacKeys.list(
            any(),
            serviceAccountEmail: any(named: 'serviceAccountEmail'),
            showDeletedKeys: any(named: 'showDeletedKeys'),
            maxResults: any(named: 'maxResults'),
            pageToken: any(named: 'pageToken'),
            userProject: any(named: 'userProject'),
          ),
        ).thenThrow(error);

        expect(
          () => storage.getHmacKeys(
            const GetHmacKeysOptions(
              projectId: 'test-project',
              autoPaginate: false,
            ),
          ),
          throwsA(
            isA<ApiError>().having(
              (e) => e.message,
              'message',
              contains('API error'),
            ),
          ),
        );
      });
    });

    group('.getHmacKeysStream()', () {
      late TestStorage storage;
      late MockStorageApi mockClient;
      late MockProjectsResource mockProjects;
      late MockHmacKeysResource mockHmacKeys;

      setUpAll(() {
        registerFallbackValue(storage_v1.HmacKeyMetadata());
      });

      setUp(() {
        mockClient = MockStorageApi();
        mockProjects = MockProjectsResource();
        mockHmacKeys = MockHmacKeysResource();
        when(() => mockClient.projects).thenReturn(mockProjects);
        when(() => mockProjects.hmacKeys).thenReturn(mockHmacKeys);
        storage = TestStorage(mockClient, projectId: 'test-project');
      });

      test('should stream HMAC keys from single page', () async {
        final key1 = storage_v1.HmacKeyMetadata()
          ..accessId = 'key-1'
          ..projectId = 'test-project';
        final key2 = storage_v1.HmacKeyMetadata()
          ..accessId = 'key-2'
          ..projectId = 'test-project';

        when(
          () => mockHmacKeys.list(
            any(),
            serviceAccountEmail: any(named: 'serviceAccountEmail'),
            showDeletedKeys: any(named: 'showDeletedKeys'),
            maxResults: any(named: 'maxResults'),
            pageToken: any(named: 'pageToken'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.HmacKeysMetadata()
            ..items = [key1, key2]
            ..nextPageToken = null;
        });

        final keys = <HmacKey>[];
        await for (final key in storage.getHmacKeysStream(
          const GetHmacKeysOptions(projectId: 'test-project'),
        )) {
          keys.add(key);
        }

        expect(keys, hasLength(2));
        expect(keys[0].id, 'key-1');
        expect(keys[1].id, 'key-2');
      });

      test('should stream HMAC keys with pagination', () async {
        final key1 = storage_v1.HmacKeyMetadata()
          ..accessId = 'key-1'
          ..projectId = 'test-project';
        final key2 = storage_v1.HmacKeyMetadata()
          ..accessId = 'key-2'
          ..projectId = 'test-project';

        // First page
        when(
          () => mockHmacKeys.list(
            any(),
            serviceAccountEmail: any(named: 'serviceAccountEmail'),
            showDeletedKeys: any(named: 'showDeletedKeys'),
            maxResults: any(named: 'maxResults'),
            pageToken: null,
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.HmacKeysMetadata()
            ..items = [key1]
            ..nextPageToken = 'token-1';
        });

        // Second page
        when(
          () => mockHmacKeys.list(
            any(),
            serviceAccountEmail: any(named: 'serviceAccountEmail'),
            showDeletedKeys: any(named: 'showDeletedKeys'),
            maxResults: any(named: 'maxResults'),
            pageToken: 'token-1',
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          return storage_v1.HmacKeysMetadata()
            ..items = [key2]
            ..nextPageToken = null;
        });

        final keys = <HmacKey>[];
        await for (final key in storage.getHmacKeysStream(
          const GetHmacKeysOptions(projectId: 'test-project'),
        )) {
          keys.add(key);
        }

        expect(keys, hasLength(2));
        expect(keys[0].id, 'key-1');
        expect(keys[1].id, 'key-2');
      });
    });
  });

  group('RetryOptions', () {
    test('should create with default values', () {
      const options = RetryOptions();
      expect(options.autoRetry, true);
      expect(options.maxRetries, 3);
      expect(options.totalTimeout, const Duration(seconds: 600));
      expect(options.maxRetryDelay, const Duration(seconds: 64));
      expect(options.retryDelayMultiplier, 2.0);
      expect(options.retryableErrorFn, isNull);
      expect(options.idempotencyStrategy, IdempotencyStrategy.retryConditional);
    });

    test('should create with custom values', () {
      bool customFn(dynamic error) => true;
      final options = RetryOptions(
        autoRetry: false,
        maxRetries: 10,
        totalTimeout: const Duration(seconds: 300),
        maxRetryDelay: const Duration(seconds: 32),
        retryDelayMultiplier: 1.5,
        retryableErrorFn: customFn,
        idempotencyStrategy: IdempotencyStrategy.retryAlways,
      );

      expect(options.autoRetry, false);
      expect(options.maxRetries, 10);
      expect(options.totalTimeout, const Duration(seconds: 300));
      expect(options.maxRetryDelay, const Duration(seconds: 32));
      expect(options.retryDelayMultiplier, 1.5);
      expect(options.retryableErrorFn, same(customFn));
      expect(options.idempotencyStrategy, IdempotencyStrategy.retryAlways);
    });

    group('copyWith', () {
      test('should return new instance with updated values', () {
        const originalOptions = RetryOptions(autoRetry: true, maxRetries: 3);

        final copied = originalOptions.copyWith(
          autoRetry: false,
          maxRetries: 10,
        );

        expect(copied.autoRetry, false);
        expect(copied.maxRetries, 10);
        expect(originalOptions.autoRetry, true);
        expect(originalOptions.maxRetries, 3);
      });

      test('should preserve original values when not specified', () {
        const originalOptions = RetryOptions(autoRetry: false, maxRetries: 5);

        final copied = originalOptions.copyWith(maxRetries: 10);

        expect(copied.autoRetry, false);
        expect(copied.maxRetries, 10);
        expect(originalOptions.maxRetries, 5);
      });
    });
  });

  group('GetServiceAccountOptions', () {
    test('should create with all parameters', () {
      const options = GetServiceAccountOptions(
        userProject: 'user-project',
        projectId: 'test-project',
      );

      expect(options.userProject, 'user-project');
      expect(options.projectId, 'test-project');
    });

    test('should create with default values', () {
      const options = GetServiceAccountOptions();

      expect(options.userProject, isNull);
      expect(options.projectId, isNull);
    });
  });

  group('PreconditionOptions', () {
    test('should create with all parameters', () {
      const options = PreconditionOptions(
        ifGenerationMatch: 1,
        ifGenerationNotMatch: 2,
        ifMetagenerationMatch: 3,
        ifMetagenerationNotMatch: 4,
      );

      expect(options.ifGenerationMatch, 1);
      expect(options.ifGenerationNotMatch, 2);
      expect(options.ifMetagenerationMatch, 3);
      expect(options.ifMetagenerationNotMatch, 4);
    });

    test('should create with default values', () {
      const options = PreconditionOptions();

      expect(options.ifGenerationMatch, isNull);
      expect(options.ifGenerationNotMatch, isNull);
      expect(options.ifMetagenerationMatch, isNull);
      expect(options.ifMetagenerationNotMatch, isNull);
    });
  });

  group('DeleteOptions', () {
    test('should create with all parameters', () {
      const options = DeleteOptions(
        ignoreNotFound: true,
        userProject: 'user-project',
        ifGenerationMatch: 1,
        ifGenerationNotMatch: 2,
        ifMetagenerationMatch: 3,
        ifMetagenerationNotMatch: 4,
      );

      expect(options.ignoreNotFound, true);
      expect(options.userProject, 'user-project');
      expect(options.ifGenerationMatch, 1);
      expect(options.ifGenerationNotMatch, 2);
      expect(options.ifMetagenerationMatch, 3);
      expect(options.ifMetagenerationNotMatch, 4);
    });

    test('should create with default values', () {
      const options = DeleteOptions();

      expect(options.ignoreNotFound, false);
      expect(options.userProject, isNull);
      expect(options.ifGenerationMatch, isNull);
      expect(options.ifGenerationNotMatch, isNull);
      expect(options.ifMetagenerationMatch, isNull);
      expect(options.ifMetagenerationNotMatch, isNull);
    });

    test('should inherit from PreconditionOptions', () {
      const options = DeleteOptions(
        ifGenerationMatch: 1,
        ifMetagenerationMatch: 2,
      );

      expect(options, isA<PreconditionOptions>());
      expect(options.ifGenerationMatch, 1);
      expect(options.ifMetagenerationMatch, 2);
    });
  });
}
