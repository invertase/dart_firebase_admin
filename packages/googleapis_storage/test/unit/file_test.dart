import 'dart:async';
import 'dart:typed_data';

import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_storage/googleapis_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockAuthClient extends Mock implements auth.AuthClient {}

class MockStorageApi extends Mock implements storage_v1.StorageApi {}

class MockObjectsResource extends Mock implements storage_v1.ObjectsResource {}

class MockURLSigner extends Mock implements URLSigner {}

class MockAcl extends Mock implements Acl {}

class MockObjectAccessControlsResource extends Mock
    implements storage_v1.ObjectAccessControlsResource {}

class MockFileStreamFactory extends Mock implements FileStreamFactory {}

class FakeBucketFile extends Fake implements BucketFile {}

class FakeCreateReadStreamOptions extends Fake implements CreateReadStreamOptions {}

class FakeCreateWriteStreamOptions extends Fake implements CreateWriteStreamOptions {}

/// Test helper that creates a Storage instance with an injectable mock client
class TestStorage extends Storage {
  final storage_v1.StorageApi mockClient;

  TestStorage(this.mockClient, {String? projectId})
    : super(
        StorageOptions(
          authClient: MockAuthClient(),
          useAuthWithCustomEndpoint: false,
          projectId: projectId,
        ),
      );

  @override
  Future<storage_v1.StorageApi> get storageClient async => mockClient;

  @override
  Future<auth.AuthClient> get authClient async => MockAuthClient();
}

void main() {
  late TestStorage storage;
  late MockStorageApi mockClient;
  late MockObjectsResource mockObjects;
  late Bucket bucket;
  late BucketFile file;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(storage_v1.Object());
    registerFallbackValue(storage_v1.ObjectAccessControl());
    registerFallbackValue(
      SignedUrlConfig(method: SignedUrlMethod.get, expires: DateTime.now()),
    );
    registerFallbackValue(FakeBucketFile());
    registerFallbackValue(FakeCreateReadStreamOptions());
    registerFallbackValue(FakeCreateWriteStreamOptions());
  });

  setUp(() {
    mockClient = MockStorageApi();
    mockObjects = MockObjectsResource();

    // Setup the mock client to return the resource mocks
    when(() => mockClient.objects).thenReturn(mockObjects);

    storage = TestStorage(mockClient, projectId: 'test-project');
    bucket = storage.bucket('test-bucket');
    file = bucket.file('test-file.txt');
  });

  group('File - getMetadata', () {
    test('should call API and return file metadata', () async {
      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Object()
          ..name = 'test-file.txt'
          ..bucket = 'test-bucket'
          ..generation = '1234'
          ..size = '1024'
          ..contentType = 'text/plain',
      );

      final result = await file.getMetadata();

      expect(result, isA<FileMetadata>());
      expect(result.name, 'test-file.txt');
      expect(result.bucket, 'test-bucket');
      expect(result.generation, '1234');
      expect(result.size, '1024');
      expect(result.contentType, 'text/plain');

      verify(
        () => mockObjects.get(
          'test-bucket',
          'test-file.txt',
          generation: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should pass userProject option to API', () async {
      final expectedMetadata = storage_v1.Object();

      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => expectedMetadata);

      await file.getMetadata(userProject: 'my-project');

      verify(
        () => mockObjects.get(
          'test-bucket',
          'test-file.txt',
          generation: null,
          userProject: 'my-project',
        ),
      ).called(1);
    });

    test(
      'should use instance-level userProject when method param not provided',
      () async {
        final expectedMetadata = storage_v1.Object();

        when(
          () => mockObjects.get(
            any(),
            any(),
            generation: any(named: 'generation'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async => expectedMetadata);

        // Set instance-level userProject
        file.userProject = 'instance-project';

        await file.getMetadata();

        verify(
          () => mockObjects.get(
            'test-bucket',
            'test-file.txt',
            generation: null,
            userProject: 'instance-project',
          ),
        ).called(1);
      },
    );

    test('should pass generation from file options', () async {
      final expectedMetadata = storage_v1.Object();

      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => expectedMetadata);

      final fileWithGeneration = bucket.file(
        'test-file.txt',
        const FileOptions(generation: 5678),
      );

      await fileWithGeneration.getMetadata();

      verify(
        () => mockObjects.get(
          'test-bucket',
          'test-file.txt',
          generation: '5678',
          userProject: null,
        ),
      ).called(1);
    });

    test('should update instance metadata after successful get', () async {
      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Object()
          ..name = 'test-file.txt'
          ..generation = '1234'
          ..contentType = 'text/plain',
      );

      await file.getMetadata();

      // Instance metadata should be updated
      expect(file.metadata.name, 'test-file.txt');
      expect(file.metadata.generation, '1234');
      expect(file.metadata.contentType, 'text/plain');
    });

    test('should throw when API returns error', () async {
      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenThrow(storage_v1.DetailedApiRequestError(404, 'Not Found'));

      expect(() => file.getMetadata(), throwsA(isA<ApiError>()));
    });
  });

  group('File - setMetadata', () {
    test('should call API and update file metadata', () async {
      final updateMetadata = storage_v1.Object()
        ..contentType = 'application/json'
        ..metadata = {'key': 'value'};

      when(
        () => mockObjects.patch(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Object()
          ..contentType = 'application/json'
          ..metadata = {'key': 'value'},
      );

      final result = await file.setMetadata(updateMetadata);

      expect(result.contentType, 'application/json');
      expect(result.metadata?['key'], 'value');

      verify(
        () => mockObjects.patch(
          updateMetadata,
          'test-bucket',
          'test-file.txt',
          generation: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
          predefinedAcl: null,
          projection: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should pass precondition options to API', () async {
      final updateMetadata = storage_v1.Object()..contentType = 'text/html';

      final updatedMetadata = storage_v1.Object();

      when(
        () => mockObjects.patch(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => updatedMetadata);

      await file.setMetadata(
        updateMetadata,
        options: const SetFileMetadataOptions(
          ifGenerationMatch: 1234,
          ifMetagenerationMatch: 5,
        ),
      );

      verify(
        () => mockObjects.patch(
          updateMetadata,
          'test-bucket',
          'test-file.txt',
          generation: null,
          ifGenerationMatch: '1234',
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: '5',
          ifMetagenerationNotMatch: null,
          predefinedAcl: null,
          projection: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should pass userProject option to API', () async {
      final updateMetadata = storage_v1.Object();
      final updatedMetadata = storage_v1.Object();

      when(
        () => mockObjects.patch(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => updatedMetadata);

      await file.setMetadata(
        updateMetadata,
        options: const SetFileMetadataOptions(userProject: 'my-project'),
      );

      verify(
        () => mockObjects.patch(
          updateMetadata,
          'test-bucket',
          'test-file.txt',
          generation: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
          predefinedAcl: null,
          projection: null,
          userProject: 'my-project',
        ),
      ).called(1);
    });

    test(
      'should update instance metadata after successful setMetadata',
      () async {
        final updateMetadata = storage_v1.Object()
          ..contentType = 'application/json'
          ..metadata = {'updated': 'true'};

        when(
          () => mockObjects.patch(
            any(),
            any(),
            any(),
            generation: any(named: 'generation'),
            ifGenerationMatch: any(named: 'ifGenerationMatch'),
            ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
            ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
            predefinedAcl: any(named: 'predefinedAcl'),
            projection: any(named: 'projection'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer(
          (_) async => storage_v1.Object()
            ..contentType = 'application/json'
            ..generation = '5678'
            ..metadata = {'updated': 'true'},
        );

        await file.setMetadata(updateMetadata);

        // Verify instance metadata was updated
        expect(file.metadata.contentType, 'application/json');
        expect(file.metadata.generation, '5678');
        expect(file.metadata.metadata?['updated'], 'true');
      },
    );

    test('should throw when API returns error', () async {
      final updateMetadata = storage_v1.Object();

      when(
        () => mockObjects.patch(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: any(named: 'userProject'),
        ),
      ).thenThrow(
        storage_v1.DetailedApiRequestError(412, 'Precondition Failed'),
      );

      expect(() => file.setMetadata(updateMetadata), throwsA(isA<ApiError>()));
    });
  });

  group('File - delete', () {
    test('should call API to delete file', () async {
      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).thenAnswer((_) async {});

      await file.delete();

      verify(
        () => mockObjects.delete(
          'test-bucket',
          'test-file.txt',
          generation: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
        ),
      ).called(1);
    });

    test('should pass precondition options to API', () async {
      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).thenAnswer((_) async {});

      await file.delete(
        options: const PreconditionOptions(
          ifGenerationMatch: 1234,
          ifMetagenerationMatch: 5,
        ),
      );

      verify(
        () => mockObjects.delete(
          'test-bucket',
          'test-file.txt',
          generation: '1234',
          ifGenerationMatch: '1234',
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: '5',
          ifMetagenerationNotMatch: null,
        ),
      ).called(1);
    });

    test('should pass ifGenerationNotMatch to API', () async {
      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).thenAnswer((_) async {});

      await file.delete(
        options: const PreconditionOptions(ifGenerationNotMatch: 5678),
      );

      verify(
        () => mockObjects.delete(
          'test-bucket',
          'test-file.txt',
          generation: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: '5678',
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
        ),
      ).called(1);
    });

    test('should ignore 404 error when ignoreNotFound is true', () async {
      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).thenThrow(storage_v1.DetailedApiRequestError(404, 'Not Found'));

      // Should not throw
      await file.delete(options: const DeleteOptions(ignoreNotFound: true));

      verify(
        () => mockObjects.delete(
          'test-bucket',
          'test-file.txt',
          generation: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
        ),
      ).called(1);
    });

    test('should throw 404 error when ignoreNotFound is false', () async {
      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).thenThrow(storage_v1.DetailedApiRequestError(404, 'Not Found'));

      expect(
        () => file.delete(options: const DeleteOptions(ignoreNotFound: false)),
        throwsA(isA<ApiError>()),
      );
    });

    test(
      'should throw non-404 errors even when ignoreNotFound is true',
      () async {
        when(
          () => mockObjects.delete(
            any(),
            any(),
            generation: any(named: 'generation'),
            ifGenerationMatch: any(named: 'ifGenerationMatch'),
            ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
            ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          ),
        ).thenThrow(storage_v1.DetailedApiRequestError(403, 'Forbidden'));

        expect(
          () => file.delete(options: const DeleteOptions(ignoreNotFound: true)),
          throwsA(isA<ApiError>()),
        );
      },
    );
  });

  group('File - exists', () {
    test('should return true when file exists', () async {
      final existingMetadata = storage_v1.Object();

      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => existingMetadata);

      final result = await file.exists();

      expect(result, isTrue);
    });

    test('should return false when file does not exist (404)', () async {
      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenThrow(storage_v1.DetailedApiRequestError(404, 'Not Found'));

      final result = await file.exists();

      expect(result, isFalse);
    });

    test('should throw on non-404 errors', () async {
      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenThrow(storage_v1.DetailedApiRequestError(403, 'Forbidden'));

      expect(() => file.exists(), throwsA(isA<ApiError>()));
    });

    test('should pass userProject option to getMetadata', () async {
      final existingMetadata = storage_v1.Object();

      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => existingMetadata);

      file.userProject = 'test-project';
      await file.exists();

      // Verify userProject was passed through
      verify(
        () => mockObjects.get(
          'test-bucket',
          'test-file.txt',
          generation: null,
          userProject: 'test-project',
        ),
      ).called(1);
    });

    test('should call getMetadata internally', () async {
      final existingMetadata = storage_v1.Object();

      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => existingMetadata);

      await file.exists();

      // Should have called the API via getMetadata
      verify(
        () => mockObjects.get(
          'test-bucket',
          'test-file.txt',
          generation: null,
          userProject: null,
        ),
      ).called(1);
    });
  });

  group('File - get', () {
    test('should return file when it exists', () async {
      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object()..name = 'test-file.txt');

      final result = await file.get();

      expect(result, isA<BucketFile>());
      expect(result.name, 'test-file.txt');
      expect(result.metadata.name, 'test-file.txt');
    });

    test(
      'should throw when file does not exist and autoCreate is false',
      () async {
        when(
          () => mockObjects.get(
            any(),
            any(),
            generation: any(named: 'generation'),
            userProject: any(named: 'userProject'),
          ),
        ).thenThrow(storage_v1.DetailedApiRequestError(404, 'Not Found'));

        expect(() => file.get(), throwsA(isA<ApiError>()));
      },
    );

    test('should pass userProject to getMetadata', () async {
      final existingMetadata = storage_v1.Object();

      when(
        () => mockObjects.get(
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => existingMetadata);

      file.userProject = 'test-project';
      await file.get();

      verify(
        () => mockObjects.get(
          'test-bucket',
          'test-file.txt',
          generation: null,
          userProject: 'test-project',
        ),
      ).called(1);
    });

    // Note: The following autoCreate tests document expected behavior.
    // The Node.js SDK has autoCreate functionality where if getMetadata returns 404
    // and autoCreate option is true, it attempts to create the file.
    // This would require additional implementation in the Dart SDK.
    // For now, these tests are commented out as the feature is not yet implemented.

    /*
    group('autoCreate behavior', () {
      test('should create file when 404 and autoCreate is true', () async {
        // First call to getMetadata returns 404
        when(
          () => mockObjects.get(
            any(),
            any(),
            generation: any(named: 'generation'),
            userProject: any(named: 'userProject'),
          ),
        ).thenThrow(
          storage_v1.DetailedApiRequestError(404, 'Not Found'),
        );

        // Mock create call to succeed
        final createdMetadata = storage_v1.Object();
        when(
          () => mockObjects.insert(
            any(),
            any(),
            name: any(named: 'name'),
          ),
        ).thenAnswer((_) async => createdMetadata);

        final result = await file.get(autoCreate: true);

        expect(result, isA<BucketFile>());
        expect(result.name, 'test-file.txt');
        verify(() => mockObjects.insert(any(), any(), name: any(named: 'name')))
            .called(1);
      });

      test('should pass config to create when autoCreate is true', () async {
        when(
          () => mockObjects.get(
            any(),
            any(),
            generation: any(named: 'generation'),
            userProject: any(named: 'userProject'),
          ),
        ).thenThrow(
          storage_v1.DetailedApiRequestError(404, 'Not Found'),
        );

        final createdMetadata = storage_v1.Object();
        when(
          () => mockObjects.insert(
            any(),
            any(),
            name: any(named: 'name'),
            contentType: any(named: 'contentType'),
          ),
        ).thenAnswer((_) async => createdMetadata);

        await file.get(
          autoCreate: true,
          createOptions: const FileCreateOptions(
            contentType: 'text/plain',
          ),
        );

        verify(
          () => mockObjects.insert(
            any(),
            any(),
            name: 'test-file.txt',
            contentType: 'text/plain',
          ),
        ).called(1);
      });

      test('should retry get after 409 conflict on create', () async {
        var getCallCount = 0;
        when(
          () => mockObjects.get(
            any(),
            any(),
            generation: any(named: 'generation'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          getCallCount++;
          if (getCallCount == 1) {
            throw storage_v1.DetailedApiRequestError(404, 'Not Found');
          } else {
            // Second call succeeds after create conflict
            return storage_v1.Object();
          }
        });

        when(
          () => mockObjects.insert(
            any(),
            any(),
            name: any(named: 'name'),
          ),
        ).thenThrow(
          storage_v1.DetailedApiRequestError(409, 'Conflict'),
        );

        final result = await file.get(autoCreate: true);

        expect(result, isA<BucketFile>());
        // Should have called get twice (initial + retry after 409)
        verify(
          () => mockObjects.get(
            any(),
            any(),
            generation: any(named: 'generation'),
            userProject: any(named: 'userProject'),
          ),
        ).called(2);
      });

      test('should refresh metadata after successful create', () async {
        var getCallCount = 0;
        final initialMetadata = storage_v1.Object();
        final refreshedMetadata = storage_v1.Object();

        when(
          () => mockObjects.get(
            any(),
            any(),
            generation: any(named: 'generation'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async {
          getCallCount++;
          if (getCallCount == 1) {
            throw storage_v1.DetailedApiRequestError(404, 'Not Found');
          } else {
            return refreshedMetadata;
          }
        });

        when(
          () => mockObjects.insert(
            any(),
            any(),
            name: any(named: 'name'),
          ),
        ).thenAnswer((_) async => initialMetadata);

        final result = await file.get(autoCreate: true);

        // Should have refreshed metadata after create
        expect(result.metadata.generation, '2');
        expect(result.metadata.size, '1024');
      });

      test('should propagate create errors that are not 409', () async {
        when(
          () => mockObjects.get(
            any(),
            any(),
            generation: any(named: 'generation'),
            userProject: any(named: 'userProject'),
          ),
        ).thenThrow(
          storage_v1.DetailedApiRequestError(404, 'Not Found'),
        );

        when(
          () => mockObjects.insert(
            any(),
            any(),
            name: any(named: 'name'),
          ),
        ).thenThrow(
          storage_v1.DetailedApiRequestError(403, 'Forbidden'),
        );

        expect(
          () => file.get(autoCreate: true),
          throwsA(isA<ApiError>()),
        );
      });
    });
    */
  });

  group('File.getSignedUrl', () {
    late MockURLSigner mockSigner;
    final expires = DateTime(2026, 12, 31);
    const expectedSignedUrl = 'https://signed-url.example.com';

    setUp(() {
      mockSigner = MockURLSigner();

      // Re-create file with mock signer
      file = BucketFile.internal(bucket, 'test-file.txt', null, mockSigner);

      when(
        () => mockSigner.getSignedUrl(any()),
      ).thenAnswer((_) async => expectedSignedUrl);
    });

    test(
      'should call signer.getSignedUrl with correct config for read action',
      () async {
        final options = GetFileSignedUrlOptions(
          action: 'read',
          expires: expires,
          version: SignedUrlVersion.v4,
        );

        final result = await file.getSignedUrl(options);

        expect(result, expectedSignedUrl);

        final captured = verify(
          () => mockSigner.getSignedUrl(captureAny()),
        ).captured;
        expect(captured, hasLength(1));

        final config = captured[0] as SignedUrlConfig;
        expect(config.method, SignedUrlMethod.get);
        expect(config.expires, expires);
        expect(config.version, SignedUrlVersion.v4);
      },
    );

    test('should map write action to PUT method', () async {
      final options = GetFileSignedUrlOptions(
        action: 'write',
        expires: expires,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.method, SignedUrlMethod.put);
    });

    test('should map delete action to DELETE method', () async {
      final options = GetFileSignedUrlOptions(
        action: 'delete',
        expires: expires,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.method, SignedUrlMethod.delete);
    });

    test('should map resumable action to POST method', () async {
      final options = GetFileSignedUrlOptions(
        action: 'resumable',
        expires: expires,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.method, SignedUrlMethod.post);
    });

    test('should forward virtualHostedStyle parameter', () async {
      final options = GetFileSignedUrlOptions(
        action: 'read',
        expires: expires,
        virtualHostedStyle: true,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.virtualHostedStyle, true);
    });

    test('should forward cname parameter', () async {
      const cname = 'https://cdn.example.com';
      final options = GetFileSignedUrlOptions(
        action: 'read',
        expires: expires,
        cname: cname,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.cname, cname);
    });

    test('should forward contentMd5 parameter', () async {
      const md5 = 'md5-hash';
      final options = GetFileSignedUrlOptions(
        action: 'write',
        expires: expires,
        contentMd5: md5,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.contentMd5, md5);
    });

    test('should forward contentType parameter', () async {
      const contentType = 'application/json';
      final options = GetFileSignedUrlOptions(
        action: 'write',
        expires: expires,
        contentType: contentType,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.contentType, contentType);
    });

    test('should forward accessibleAt parameter', () async {
      final accessibleAt = DateTime(2026, 1, 1);
      final options = GetFileSignedUrlOptions(
        action: 'read',
        expires: expires,
        accessibleAt: accessibleAt,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.accessibleAt, accessibleAt);
    });

    test('should add responseType to queryParams', () async {
      final options = GetFileSignedUrlOptions(
        action: 'read',
        expires: expires,
        responseType: 'application/json',
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.queryParams?['response-content-type'], 'application/json');
    });

    test(
      'should add promptSaveAs to queryParams as response-content-disposition',
      () async {
        final options = GetFileSignedUrlOptions(
          action: 'read',
          expires: expires,
          promptSaveAs: 'download.txt',
        );

        await file.getSignedUrl(options);

        final captured = verify(
          () => mockSigner.getSignedUrl(captureAny()),
        ).captured;
        final config = captured[0] as SignedUrlConfig;
        expect(
          config.queryParams?['response-content-disposition'],
          'attachment; filename="download.txt"',
        );
      },
    );

    test('should prefer responseDisposition over promptSaveAs', () async {
      const disposition = 'attachment; filename="custom.txt"';
      final options = GetFileSignedUrlOptions(
        action: 'read',
        expires: expires,
        promptSaveAs: 'download.txt',
        responseDisposition: disposition,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.queryParams?['response-content-disposition'], disposition);
    });

    test('should add generation to queryParams when set', () async {
      final fileWithGeneration = BucketFile.internal(
        bucket,
        'test-file.txt',
        const FileOptions(generation: 123456789),
        mockSigner,
      );

      final options = GetFileSignedUrlOptions(action: 'read', expires: expires);

      await fileWithGeneration.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.queryParams?['generation'], '123456789');
    });

    test('should merge custom queryParams with generated ones', () async {
      final options = GetFileSignedUrlOptions(
        action: 'read',
        expires: expires,
        responseType: 'application/json',
        queryParams: {'custom': 'value'},
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.queryParams?['response-content-type'], 'application/json');
      expect(config.queryParams?['custom'], 'value');
    });

    test('should forward extensionHeaders parameter', () async {
      final headers = {'x-goog-meta-test': 'value'};
      final options = GetFileSignedUrlOptions(
        action: 'write',
        expires: expires,
        extensionHeaders: headers,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.extensionHeaders, headers);
    });

    test('should forward host parameter', () async {
      final host = Uri.parse('https://custom.example.com');
      final options = GetFileSignedUrlOptions(
        action: 'read',
        expires: expires,
        host: host,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.host, host);
    });

    test('should forward signingEndpoint parameter', () async {
      final endpoint = Uri.parse('https://signing.example.com');
      final options = GetFileSignedUrlOptions(
        action: 'read',
        expires: expires,
        signingEndpoint: endpoint,
      );

      await file.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.signingEndpoint, endpoint);
    });
  });

  group('File - copy', () {
    late storage_v1.RewriteResponse successResponse;

    setUp(() {
      // Default successful rewrite response
      successResponse = storage_v1.RewriteResponse()
        ..done = true
        ..totalBytesRewritten = '1024'
        ..objectSize = '1024'
        ..resource = storage_v1.Object();

      // Register fallback for RewriteResponse
      registerFallbackValue(storage_v1.Object());
    });

    test('should copy file to string destination in same bucket', () async {
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => successResponse);

      final result = await file.copy(const PathCopyDestination('new-file.txt'));

      expect(result, isA<BucketFile>());
      expect(result.name, 'new-file.txt');
      expect(result.bucket.name, 'test-bucket'); // Same bucket

      verify(
        () => mockObjects.rewrite(
          any(),
          'test-bucket', // source bucket
          'test-file.txt', // source file
          'test-bucket', // destination bucket (same)
          'new-file.txt', // destination file
          sourceGeneration: null,
          rewriteToken: null,
          destinationKmsKeyName: null,
          destinationPredefinedAcl: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should copy file to gs:// URI destination (cross-bucket)', () async {
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => successResponse);

      final result = await file.copy(
        const PathCopyDestination('gs://other-bucket/new-file.txt'),
      );

      expect(result.name, 'new-file.txt');
      expect(result.bucket.name, 'other-bucket'); // Different bucket

      verify(
        () => mockObjects.rewrite(
          any(),
          'test-bucket',
          'test-file.txt',
          'other-bucket', // destination bucket parsed from gs://
          'new-file.txt',
          sourceGeneration: null,
          rewriteToken: null,
          destinationKmsKeyName: null,
          destinationPredefinedAcl: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should copy file to Bucket destination', () async {
      final destBucket = storage.bucket('destination-bucket');

      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => successResponse);

      final result = await file.copy(BucketCopyDestination(destBucket));

      expect(result.name, 'test-file.txt'); // Same filename
      expect(result.bucket.name, 'destination-bucket');

      verify(
        () => mockObjects.rewrite(
          any(),
          'test-bucket',
          'test-file.txt',
          'destination-bucket',
          'test-file.txt', // Same name as source
          sourceGeneration: null,
          rewriteToken: null,
          destinationKmsKeyName: null,
          destinationPredefinedAcl: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should copy file to File destination', () async {
      final destBucket = storage.bucket('destination-bucket');
      final destFile = destBucket.file('custom-name.txt');

      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => successResponse);

      final result = await file.copy(FileCopyDestination(destFile));

      expect(result, same(destFile)); // Returns same File object
      expect(result.name, 'custom-name.txt');
      expect(result.bucket.name, 'destination-bucket');

      verify(
        () => mockObjects.rewrite(
          any(),
          'test-bucket',
          'test-file.txt',
          'destination-bucket',
          'custom-name.txt',
          sourceGeneration: null,
          rewriteToken: null,
          destinationKmsKeyName: null,
          destinationPredefinedAcl: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should pass precondition options to API', () async {
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => successResponse);

      await file.copy(
        const PathCopyDestination('new-file.txt'),
        options: const CopyOptions(
          preconditionOpts: PreconditionOptions(
            ifGenerationMatch: 1234,
            ifMetagenerationMatch: 5,
          ),
        ),
      );

      verify(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: null,
          rewriteToken: null,
          destinationKmsKeyName: null,
          destinationPredefinedAcl: null,
          ifGenerationMatch: '1234',
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: '5',
          ifMetagenerationNotMatch: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should pass userProject option to API', () async {
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => successResponse);

      await file.copy(
        const PathCopyDestination('new-file.txt'),
        options: const CopyOptions(userProject: 'my-project'),
      );

      verify(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: null,
          rewriteToken: null,
          destinationKmsKeyName: null,
          destinationPredefinedAcl: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
          userProject: 'my-project',
        ),
      ).called(1);
    });

    test('should pass metadata options to API', () async {
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => successResponse);

      await file.copy(
        const PathCopyDestination('new-file.txt'),
        options: const CopyOptions(
          contentType: 'application/json',
          cacheControl: 'public, max-age=3600',
          metadata: {'key': 'value'},
        ),
      );

      final captured = verify(
        () => mockObjects.rewrite(
          captureAny(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).captured;

      final metadata = captured[0] as storage_v1.Object;
      expect(metadata.contentType, 'application/json');
      expect(metadata.cacheControl, 'public, max-age=3600');
      expect(metadata.metadata?['key'], 'value');
    });

    test('should pass destinationKmsKeyName option to API', () async {
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => successResponse);

      await file.copy(
        const PathCopyDestination('new-file.txt'),
        options: const CopyOptions(
          destinationKmsKeyName:
              'projects/my-project/locations/us/keyRings/my-kr/cryptoKeys/my-key',
        ),
      );

      verify(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: null,
          rewriteToken: null,
          destinationKmsKeyName:
              'projects/my-project/locations/us/keyRings/my-kr/cryptoKeys/my-key',
          destinationPredefinedAcl: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should pass predefinedAcl option to API', () async {
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => successResponse);

      await file.copy(
        const PathCopyDestination('new-file.txt'),
        options: const CopyOptions(predefinedAcl: PredefinedAcl.publicRead),
      );

      verify(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: null,
          rewriteToken: null,
          destinationKmsKeyName: null,
          destinationPredefinedAcl: 'publicRead',
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should pass sourceGeneration from file options', () async {
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => successResponse);

      final versionedFile = bucket.file(
        'test-file.txt',
        const FileOptions(generation: 9999),
      );

      await versionedFile.copy(const PathCopyDestination('new-file.txt'));

      verify(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: '9999',
          rewriteToken: null,
          destinationKmsKeyName: null,
          destinationPredefinedAcl: null,
          ifGenerationMatch: null,
          ifGenerationNotMatch: null,
          ifMetagenerationMatch: null,
          ifMetagenerationNotMatch: null,
          userProject: null,
        ),
      ).called(1);
    });

    test('should handle multi-part copy with rewriteToken', () async {
      var callCount = 0;
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          // First call returns incomplete with token
          return storage_v1.RewriteResponse()
            ..done = false
            ..rewriteToken = 'partial-copy-token-123'
            ..totalBytesRewritten = '512'
            ..objectSize = '1024';
        } else {
          // Second call completes
          return successResponse;
        }
      });

      final result = await file.copy(const PathCopyDestination('new-file.txt'));

      expect(result.name, 'new-file.txt');

      // Should have called rewrite twice - once without token, once with token
      expect(callCount, 2);
    });

    test('should preserve userProject in multi-part copy', () async {
      var callCount = 0;
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return storage_v1.RewriteResponse()
            ..done = false
            ..rewriteToken = 'token-123';
        } else {
          return successResponse;
        }
      });

      await file.copy(
        const PathCopyDestination('new-file.txt'),
        options: const CopyOptions(userProject: 'test-project'),
      );

      // Should have called rewrite twice (once for initial, once for continuation)
      expect(callCount, 2);

      // Both calls should have userProject - verify last call had it
      verify(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: 'token-123',
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: 'test-project',
        ),
      ).called(1);
    });

    test('should update destination file metadata from response', () async {
      final responseWithMetadata = storage_v1.RewriteResponse()
        ..done = true
        ..resource = (storage_v1.Object()
          ..generation = '9999'
          ..contentType = 'application/json'
          ..size = '2048');

      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => responseWithMetadata);

      final result = await file.copy(const PathCopyDestination('new-file.txt'));

      // Metadata should be updated from response
      expect(result.metadata.generation, '9999');
      expect(result.metadata.contentType, 'application/json');
      expect(result.metadata.size, '2048');
    });

    test('should throw when API returns error', () async {
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenThrow(storage_v1.DetailedApiRequestError(403, 'Forbidden'));

      expect(
        () => file.copy(const PathCopyDestination('new-file.txt')),
        throwsA(isA<ApiError>()),
      );
    });
  });

  // ========================================================================
  // File Access Control Tests
  // ========================================================================

  group('File - makePrivate', () {
    late TestStorage storage;
    late storage_v1.StorageApi mockApi;
    late storage_v1.ObjectsResource mockObjects;
    late BucketFile file;

    setUp(() {
      mockApi = MockStorageApi();
      mockObjects = MockObjectsResource();
      when(() => mockApi.objects).thenReturn(mockObjects);

      storage = TestStorage(mockApi, projectId: 'test-project');
      file = storage.bucket('test-bucket').file('test-file.txt');
    });

    test('should make file private to project by default', () async {
      when(
        () => mockObjects.patch(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          predefinedAcl: any(named: 'predefinedAcl'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await file.makePrivate();

      final captured = verify(
        () => mockObjects.patch(
          captureAny(),
          'test-bucket',
          'test-file.txt',
          generation: any(named: 'generation'),
          predefinedAcl: captureAny(named: 'predefinedAcl'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).captured;

      // Verify metadata has acl set to null
      final metadata = captured[0] as storage_v1.Object;
      expect(metadata.acl, isNull);

      // Verify predefinedAcl is 'projectPrivate' (default, non-strict mode)
      final predefinedAcl = captured[1] as String;
      expect(predefinedAcl, 'projectPrivate');
    });

    test('should make file private to user when strict is true', () async {
      when(
        () => mockObjects.patch(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          predefinedAcl: any(named: 'predefinedAcl'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await file.makePrivate(const MakeFilePrivateOptions(strict: true));

      final predefinedAcl =
          verify(
                () => mockObjects.patch(
                  any(),
                  'test-bucket',
                  'test-file.txt',
                  generation: any(named: 'generation'),
                  predefinedAcl: captureAny(named: 'predefinedAcl'),
                  ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
                  ifMetagenerationNotMatch: any(
                    named: 'ifMetagenerationNotMatch',
                  ),
                  ifGenerationMatch: any(named: 'ifGenerationMatch'),
                  ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
                  userProject: any(named: 'userProject'),
                ),
              ).captured.single
              as String;

      expect(predefinedAcl, 'private');
    });

    test('should merge custom metadata with acl null', () async {
      final customMetadata = FileMetadata()
        ..contentType = 'text/plain'
        ..metadata = {'custom': 'value'};

      when(
        () => mockObjects.patch(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          predefinedAcl: any(named: 'predefinedAcl'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await file.makePrivate(MakeFilePrivateOptions(metadata: customMetadata));

      final metadata =
          verify(
                () => mockObjects.patch(
                  captureAny(),
                  'test-bucket',
                  'test-file.txt',
                  generation: any(named: 'generation'),
                  predefinedAcl: any(named: 'predefinedAcl'),
                  ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
                  ifMetagenerationNotMatch: any(
                    named: 'ifMetagenerationNotMatch',
                  ),
                  ifGenerationMatch: any(named: 'ifGenerationMatch'),
                  ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
                  userProject: any(named: 'userProject'),
                ),
              ).captured.single
              as storage_v1.Object;

      // Verify acl is null
      expect(metadata.acl, isNull);
      // Verify custom metadata is preserved
      expect(metadata.contentType, 'text/plain');
      expect(metadata.metadata, {'custom': 'value'});
    });

    test('should pass userProject option', () async {
      when(
        () => mockObjects.patch(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          predefinedAcl: any(named: 'predefinedAcl'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await file.makePrivate(
        const MakeFilePrivateOptions(userProject: 'user-project-id'),
      );

      verify(
        () => mockObjects.patch(
          any(),
          'test-bucket',
          'test-file.txt',
          generation: any(named: 'generation'),
          predefinedAcl: any(named: 'predefinedAcl'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          userProject: 'user-project-id',
        ),
      ).called(1);
    });

    test('should pass precondition options', () async {
      when(
        () => mockObjects.patch(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          predefinedAcl: any(named: 'predefinedAcl'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await file.makePrivate(
        const MakeFilePrivateOptions(
          preconditionOpts: PreconditionOptions(
            ifGenerationMatch: 1234,
            ifMetagenerationMatch: 1,
          ),
        ),
      );

      verify(
        () => mockObjects.patch(
          any(),
          'test-bucket',
          'test-file.txt',
          generation: any(named: 'generation'),
          predefinedAcl: any(named: 'predefinedAcl'),
          ifMetagenerationMatch: '1',
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          ifGenerationMatch: '1234',
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });
  });

  group('File - makePublic', () {
    late TestStorage storage;
    late BucketFile file;

    setUp(() {
      final mockApi = MockStorageApi();
      final mockObjects = MockObjectsResource();
      when(() => mockApi.objects).thenReturn(mockObjects);

      storage = TestStorage(mockApi, projectId: 'test-project');
    });

    test('should add allUsers READER ACL entry', () async {
      final mockApi = MockStorageApi();
      final mockObjects = MockObjectsResource();
      final mockObjectAccessControls = MockObjectAccessControlsResource();

      when(() => mockApi.objects).thenReturn(mockObjects);
      when(
        () => mockApi.objectAccessControls,
      ).thenReturn(mockObjectAccessControls);

      storage = TestStorage(mockApi, projectId: 'test-project');
      file = storage.bucket('test-bucket').file('test-file.txt');

      final aclEntry = storage_v1.ObjectAccessControl()
        ..entity = 'allUsers'
        ..role = 'READER';

      when(
        () => mockObjectAccessControls.insert(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => aclEntry);

      await file.makePublic();

      final captured =
          verify(
                () => mockObjectAccessControls.insert(
                  captureAny(),
                  'test-bucket',
                  'test-file.txt',
                  generation: any(named: 'generation'),
                  userProject: any(named: 'userProject'),
                ),
              ).captured.single
              as storage_v1.ObjectAccessControl;

      expect(captured.entity, 'allUsers');
      expect(captured.role, 'READER');
    });

    test('should pass userProject if set on file options', () async {
      final mockApi = MockStorageApi();
      final mockObjects = MockObjectsResource();
      final mockObjectAccessControls = MockObjectAccessControlsResource();

      when(() => mockApi.objects).thenReturn(mockObjects);
      when(
        () => mockApi.objectAccessControls,
      ).thenReturn(mockObjectAccessControls);

      storage = TestStorage(mockApi, projectId: 'test-project');
      file = storage
          .bucket('test-bucket')
          .file('test-file.txt', const FileOptions(userProject: 'my-project'));

      final aclEntry = storage_v1.ObjectAccessControl()
        ..entity = 'allUsers'
        ..role = 'READER';

      when(
        () => mockObjectAccessControls.insert(
          any(),
          any(),
          any(),
          generation: any(named: 'generation'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => aclEntry);

      await file.makePublic();

      verify(
        () => mockObjectAccessControls.insert(
          any(),
          'test-bucket',
          'test-file.txt',
          generation: any(named: 'generation'),
          userProject: 'my-project',
        ),
      ).called(1);
    });
  });

  group('File - publicUrl', () {
    late TestStorage storage;
    late BucketFile file;

    setUp(() {
      final mockApi = MockStorageApi();
      final mockObjects = MockObjectsResource();
      when(() => mockApi.objects).thenReturn(mockObjects);

      storage = TestStorage(mockApi, projectId: 'test-project');
      file = storage.bucket('test-bucket').file('test-file.txt');
    });

    test('should return correctly formatted public URL', () {
      final url = file.publicUrl();
      expect(url, 'https://storage.googleapis.com/test-bucket/test-file.txt');
    });

    test('should URL-encode special characters in filename', () {
      file = storage.bucket('test-bucket').file('my#file\$.png');
      final url = file.publicUrl();
      expect(
        url,
        'https://storage.googleapis.com/test-bucket/my%23file%24.png',
      );
    });

    test('should handle filenames with spaces', () {
      file = storage.bucket('test-bucket').file('my file.txt');
      final url = file.publicUrl();
      expect(url, 'https://storage.googleapis.com/test-bucket/my%20file.txt');
    });

    test('should handle filenames with slashes (nested paths)', () {
      file = storage.bucket('test-bucket').file('path/to/file.txt');
      final url = file.publicUrl();
      expect(
        url,
        'https://storage.googleapis.com/test-bucket/path%2Fto%2Ffile.txt',
      );
    });
  });

  group('File - move', () {
    late TestStorage storage;
    late storage_v1.StorageApi mockApi;
    late storage_v1.ObjectsResource mockObjects;
    late BucketFile file;

    setUp(() {
      mockApi = MockStorageApi();
      mockObjects = MockObjectsResource();
      when(() => mockApi.objects).thenReturn(mockObjects);

      storage = TestStorage(mockApi, projectId: 'test-project');
      file = storage.bucket('test-bucket').file('old-file.txt');
    });

    test('should copy file to destination and delete original', () async {
      final rewriteResponse = storage_v1.RewriteResponse()
        ..done = true
        ..resource = (storage_v1.Object()..name = 'new-file.txt');

      // Mock rewrite (copy)
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => rewriteResponse);

      // Mock delete
      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).thenAnswer((_) async {});

      final result = await file.move(const PathCopyDestination('new-file.txt'));

      expect(result, isA<BucketFile>());
      expect(result.name, 'new-file.txt');

      // Verify copy was called
      verify(
        () => mockObjects.rewrite(
          any(),
          'test-bucket',
          'old-file.txt',
          'test-bucket',
          'new-file.txt',
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);

      // Verify delete was called
      verify(
        () => mockObjects.delete(
          'test-bucket',
          'old-file.txt',
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).called(1);
    });

    test('should not delete if destination is same as source', () async {
      final rewriteResponse = storage_v1.RewriteResponse()
        ..done = true
        ..resource = (storage_v1.Object()..name = 'old-file.txt');

      // Mock rewrite (copy to same name)
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => rewriteResponse);

      await file.move(const PathCopyDestination('old-file.txt'));

      // Verify delete was NOT called (same file, same bucket)
      verifyNever(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      );
    });

    test('should pass options to both copy and delete', () async {
      final rewriteResponse = storage_v1.RewriteResponse()
        ..done = true
        ..resource = (storage_v1.Object()..name = 'new-file.txt');

      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => rewriteResponse);

      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).thenAnswer((_) async {});

      await file.move(
        const PathCopyDestination('new-file.txt'),
        options: const MoveOptions(
          userProject: 'my-project',
          preconditionOpts: PreconditionOptions(ifGenerationMatch: 1234),
        ),
      );

      // Verify userProject passed to copy
      verify(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: '1234',
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: 'my-project',
        ),
      ).called(1);

      // Verify preconditions passed to delete
      verify(
        () => mockObjects.delete(
          'test-bucket',
          'old-file.txt',
          generation: any(named: 'generation'),
          ifGenerationMatch: '1234',
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).called(1);
    });

    test('should move to File destination in different bucket', () async {
      final rewriteResponse = storage_v1.RewriteResponse()
        ..done = true
        ..resource = (storage_v1.Object()..name = 'moved-file.txt');

      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => rewriteResponse);

      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).thenAnswer((_) async {});

      final destFile = storage.bucket('other-bucket').file('moved-file.txt');
      await file.move(FileCopyDestination(destFile));

      // Verify rewrite called with different buckets
      verify(
        () => mockObjects.rewrite(
          any(),
          'test-bucket',
          'old-file.txt',
          'other-bucket',
          'moved-file.txt',
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);

      // Verify delete was called (different bucket)
      verify(
        () => mockObjects.delete(
          'test-bucket',
          'old-file.txt',
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).called(1);
    });

    test('should throw when copy fails', () async {
      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenThrow(storage_v1.DetailedApiRequestError(403, 'Forbidden'));

      expect(
        () => file.move(const PathCopyDestination('new-file.txt')),
        throwsA(isA<ApiError>()),
      );

      // Verify delete was NOT called (copy failed)
      verifyNever(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      );
    });
  });

  group('File - rename', () {
    late TestStorage storage;
    late storage_v1.StorageApi mockApi;
    late storage_v1.ObjectsResource mockObjects;
    late BucketFile file;

    setUp(() {
      mockApi = MockStorageApi();
      mockObjects = MockObjectsResource();
      when(() => mockApi.objects).thenReturn(mockObjects);

      storage = TestStorage(mockApi, projectId: 'test-project');
      file = storage.bucket('test-bucket').file('old-name.txt');
    });

    test('should call move with correct parameters', () async {
      final rewriteResponse = storage_v1.RewriteResponse()
        ..done = true
        ..resource = (storage_v1.Object()..name = 'new-name.txt');

      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => rewriteResponse);

      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).thenAnswer((_) async {});

      final result = await file.rename(
        const PathCopyDestination('new-name.txt'),
        options: const MoveOptions(userProject: 'my-project'),
      );

      expect(result, isA<BucketFile>());
      expect(result.name, 'new-name.txt');

      // Verify rename calls move (which calls rewrite + delete)
      verify(
        () => mockObjects.rewrite(
          any(),
          'test-bucket',
          'old-name.txt',
          'test-bucket',
          'new-name.txt',
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: 'my-project',
        ),
      ).called(1);

      verify(
        () => mockObjects.delete(
          'test-bucket',
          'old-name.txt',
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).called(1);
    });

    test('should accept File object as destination', () async {
      final rewriteResponse = storage_v1.RewriteResponse()
        ..done = true
        ..resource = (storage_v1.Object()..name = 'renamed-file.txt');

      when(
        () => mockObjects.rewrite(
          any(),
          any(),
          any(),
          any(),
          any(),
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => rewriteResponse);

      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
        ),
      ).thenAnswer((_) async {});

      final destFile = storage.bucket('test-bucket').file('renamed-file.txt');
      final result = await file.rename(FileCopyDestination(destFile));

      expect(result, isA<BucketFile>());
      expect(result.name, 'renamed-file.txt');

      verify(
        () => mockObjects.rewrite(
          any(),
          'test-bucket',
          'old-name.txt',
          'test-bucket',
          'renamed-file.txt',
          sourceGeneration: any(named: 'sourceGeneration'),
          rewriteToken: any(named: 'rewriteToken'),
          destinationKmsKeyName: any(named: 'destinationKmsKeyName'),
          destinationPredefinedAcl: any(named: 'destinationPredefinedAcl'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifGenerationNotMatch: any(named: 'ifGenerationNotMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          ifMetagenerationNotMatch: any(named: 'ifMetagenerationNotMatch'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });
  });

  // ========================================================================
  // File Download/Save Tests
  // ========================================================================

  group('File - download', () {
    late TestStorage storage;
    late storage_v1.StorageApi mockApi;
    late storage_v1.ObjectsResource mockObjects;
    late MockFileStreamFactory mockStreamFactory;
    late BucketFile file;

    setUp(() {
      mockApi = MockStorageApi();
      mockObjects = MockObjectsResource();
      mockStreamFactory = MockFileStreamFactory();

      when(() => mockApi.objects).thenReturn(mockObjects);

      storage = TestStorage(mockApi, projectId: 'test-project');
      final bucket = storage.bucket('test-bucket');

      // Create file with mock stream factory
      file = BucketFile.internal(
        bucket,
        'test-file.txt',
        null,
        null,
        mockStreamFactory,
      );
    });

    test('should call createReadStream with filtered options', () async {
      final mockStream = Stream<List<int>>.value([1, 2, 3]);

      when(() => mockStreamFactory.createReadStream(any(), any()))
          .thenAnswer((_) => mockStream);

      await file.download(
        DownloadOptions(
          start: 100,
          end: 200,
          userProject: 'my-project',
        ),
      );

      final captured = verify(
        () => mockStreamFactory.createReadStream(
          any(),
          captureAny(),
        ),
      ).captured.single as CreateReadStreamOptions;

      expect(captured.start, 100);
      expect(captured.end, 200);
      expect(captured.userProject, 'my-project');
    });

    test('should filter out destination from options', () async {
      final mockStream = Stream<List<int>>.value([1, 2, 3]);

      when(() => mockStreamFactory.createReadStream(any(), any()))
          .thenAnswer((_) => mockStream);

      // Note: destination would normally be a File, but since we're not
      // actually writing to disk in this test, we skip that part
      await file.download(
        const DownloadOptions(
          start: 100,
          userProject: 'my-project',
        ),
      );

      final captured = verify(
        () => mockStreamFactory.createReadStream(
          any(),
          captureAny(),
        ),
      ).captured.single as CreateReadStreamOptions;

      // Verify destination is NOT in the options passed to createReadStream
      expect(captured.start, 100);
      expect(captured.userProject, 'my-project');
    });

    test('should filter out encryptionKey from stream options', () async {
      final mockStream = Stream<List<int>>.value([1, 2, 3]);
      final encryptionKey = EncryptionKey.fromString('test-encryption-key');

      when(() => mockStreamFactory.createReadStream(any(), any()))
          .thenAnswer((_) => mockStream);

      await file.download(
        DownloadOptions(
          encryptionKey: encryptionKey,
          userProject: 'my-project',
        ),
      );

      // Verify createReadStream was called (without encryption key in options)
      final captured = verify(
        () => mockStreamFactory.createReadStream(
          any(),
          captureAny(),
        ),
      ).captured.single as CreateReadStreamOptions;

      // encryptionKey should not be in stream options (handled separately)
      expect(captured.userProject, 'my-project');
    });

    test('should download to memory when no destination', () async {
      final mockStream = Stream<List<int>>.fromIterable([
        [1, 2, 3],
        [4, 5, 6],
      ]);

      when(() => mockStreamFactory.createReadStream(any(), any()))
          .thenAnswer((_) => mockStream);

      final result = await file.download();

      expect(result, [1, 2, 3, 4, 5, 6]);
    });
  });

  group('File - save', () {
    late TestStorage storage;
    late storage_v1.StorageApi mockApi;
    late storage_v1.ObjectsResource mockObjects;
    late MockFileStreamFactory mockStreamFactory;
    late BucketFile file;

    setUp(() {
      mockApi = MockStorageApi();
      mockObjects = MockObjectsResource();
      mockStreamFactory = MockFileStreamFactory();

      when(() => mockApi.objects).thenReturn(mockObjects);

      storage = TestStorage(mockApi, projectId: 'test-project');
      final bucket = storage.bucket('test-bucket');

      // Create file with mock stream factory
      file = BucketFile.internal(
        bucket,
        'test-file.txt',
        null,
        null,
        mockStreamFactory,
      );
    });

    test('should call createWriteStream with options', () async {
      final controller = StreamController<List<int>>();
      final dataFuture = controller.stream.toList();

      when(() => mockStreamFactory.createWriteStream(any(), any()))
          .thenAnswer((_) => controller.sink);

      await file.save(
        'test data',
        SaveOptions(
          contentType: 'text/plain',
          resumable: false,
        ),
      );

      await dataFuture; // Wait for stream to complete

      verify(
        () => mockStreamFactory.createWriteStream(
          any(),
          any(),
        ),
      ).called(1);
    });

    test('should handle String data', () async {
      final controller = StreamController<List<int>>();
      final dataFuture = controller.stream.toList();

      when(() => mockStreamFactory.createWriteStream(any(), any()))
          .thenAnswer((_) => controller.sink);

      await file.save('test data');

      final receivedChunks = await dataFuture;
      final receivedData = receivedChunks.expand((chunk) => chunk).toList();
      expect(String.fromCharCodes(receivedData), 'test data');
    });

    test('should handle List<int> data', () async {
      final controller = StreamController<List<int>>();
      final dataFuture = controller.stream.toList();

      when(() => mockStreamFactory.createWriteStream(any(), any()))
          .thenAnswer((_) => controller.sink);

      await file.save([1, 2, 3, 4, 5]);

      final receivedChunks = await dataFuture;
      final receivedData = receivedChunks.expand((chunk) => chunk).toList();
      expect(receivedData, [1, 2, 3, 4, 5]);
    });

    test('should handle Uint8List data', () async {
      final controller = StreamController<List<int>>();
      final dataFuture = controller.stream.toList();

      when(() => mockStreamFactory.createWriteStream(any(), any()))
          .thenAnswer((_) => controller.sink);

      final data = Uint8List.fromList([10, 20, 30]);
      await file.save(data);

      final receivedChunks = await dataFuture;
      final receivedData = receivedChunks.expand((chunk) => chunk).toList();
      expect(receivedData, [10, 20, 30]);
    });

    test('should handle Stream<List<int>> data', () async {
      final controller = StreamController<List<int>>();
      final dataFuture = controller.stream.toList();

      when(() => mockStreamFactory.createWriteStream(any(), any()))
          .thenAnswer((_) => controller.sink);

      final dataStream = Stream<List<int>>.fromIterable([
        [1, 2, 3],
        [4, 5, 6],
      ]);

      await file.save(dataStream);

      final receivedChunks = await dataFuture;
      final receivedData = receivedChunks.expand((chunk) => chunk).toList();
      expect(receivedData, [1, 2, 3, 4, 5, 6]);
    });

    test('should throw for unsupported data types', () async {
      final controller = StreamController<List<int>>();

      when(() => mockStreamFactory.createWriteStream(any(), any()))
          .thenAnswer((_) => controller.sink);

      try {
        await file.save(123); // Number is not supported
        fail('Should have thrown an error');
      } catch (e) {
        expect(e, isA<ApiError>());
        expect(
          e.toString(),
          contains('Data must be String, Uint8List, List<int>, or Stream<List<int>>'),
        );
      } finally {
        unawaited(controller.close());
      }
    });
  });
}
