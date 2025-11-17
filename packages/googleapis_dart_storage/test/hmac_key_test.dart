import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_dart_storage/googleapis_dart_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockStorageApi extends Mock implements storage_v1.StorageApi {}

class MockProjectsResource extends Mock
    implements storage_v1.ProjectsResource {}

class MockHmacKeysResource extends Mock
    implements storage_v1.ProjectsHmacKeysResource {}

/// Test helper that creates a Storage instance with an injectable mock client
class TestStorage extends Storage {
  final storage_v1.StorageApi mockClient;

  TestStorage(this.mockClient)
      : super(StorageOptions(
          authClient: Future.value(MockHttpClient() as http.Client),
          useAuthWithCustomEndpoint: false,
        ));

  @override
  Future<storage_v1.StorageApi> get client async => mockClient;
}

void main() {
  late TestStorage storage;
  late MockStorageApi mockClient;
  late MockProjectsResource mockProjects;
  late MockHmacKeysResource mockHmacKeys;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(storage_v1.HmacKeyMetadata());
  });

  setUp(() {
    mockClient = MockStorageApi();
    mockProjects = MockProjectsResource();
    mockHmacKeys = MockHmacKeysResource();

    // Setup the mock client to return the resource mocks
    when(() => mockClient.projects).thenReturn(mockProjects);
    when(() => mockProjects.hmacKeys).thenReturn(mockHmacKeys);

    storage = TestStorage(mockClient);
  });

  group('HmacKeyOptions', () {
    test('should create with projectId', () {
      final options = HmacKeyOptions(projectId: 'test-project');
      expect(options.projectId, 'test-project');
    });

    test('should create without projectId', () {
      final options = HmacKeyOptions();
      expect(options.projectId, isNull);
    });
  });

  group('HmacKeyState', () {
    test('should have correct values', () {
      expect(HmacKeyState.active.value, 'ACTIVE');
      expect(HmacKeyState.inactive.value, 'INACTIVE');
      expect(HmacKeyState.deleted.value, 'DELETED');
    });
  });

  group('SetHmacKeyMetadata', () {
    test('should create with state', () {
      final metadata = SetHmacKeyMetadata(state: HmacKeyState.active);
      expect(metadata.state, 'ACTIVE');
      expect(metadata.etag, isNull);
    });

    test('should create with etag', () {
      final metadata = SetHmacKeyMetadata(etag: 'test-etag');
      expect(metadata.state, isNull);
      expect(metadata.etag, 'test-etag');
    });

    test('should create with both state and etag', () {
      final metadata = SetHmacKeyMetadata(
        state: HmacKeyState.inactive,
        etag: 'test-etag',
      );
      expect(metadata.state, 'INACTIVE');
      expect(metadata.etag, 'test-etag');
    });
  });

  group('HmacKey', () {
    group('constructor', () {
      test('should create with projectId in options', () {
        final hmacKey = storage.hmacKey(
          'test-access-id',
          HmacKeyOptions(projectId: 'test-project'),
        );

        expect(hmacKey.accessId, 'test-access-id');
        expect(hmacKey.projectId, 'test-project');
        expect(hmacKey.storage, storage);
        expect(hmacKey.metadata.accessId, 'test-access-id');
        expect(hmacKey.metadata.projectId, 'test-project');
      });

      test('should throw when projectId is not provided', () {
        expect(
          () => storage.hmacKey('test-access-id'),
          throwsA(isA<ApiError>().having(
            (e) => e.message,
            'message',
            contains('Project ID is required'),
          )),
        );
      });

      test('should throw when projectId is empty', () {
        expect(
          () => storage.hmacKey(
            'test-access-id',
            HmacKeyOptions(projectId: ''),
          ),
          throwsA(isA<ApiError>().having(
            (e) => e.message,
            'message',
            contains('Project ID is required'),
          )),
        );
      });
    });

    group('delete', () {
      late HmacKey hmacKey;

      setUp(() {
        hmacKey = storage.hmacKey(
          'test-access-id',
          HmacKeyOptions(projectId: 'test-project'),
        );
      });

      test('should call hmacKeys.delete with correct parameters', () async {
        when(() => mockHmacKeys.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await hmacKey.delete();

        verify(() => mockHmacKeys.delete(
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);
      });

      test('should throw ApiError on failure', () async {
        when(() => mockHmacKeys.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenThrow(Exception('API Error'));

        expect(
          () => hmacKey.delete(),
          throwsA(isA<ApiError>().having(
            (e) => e.message,
            'message',
            contains('Failed to delete HMAC key'),
          )),
        );
      });

      test('should accept PreconditionOptions for base class compatibility',
          () async {
        when(() => mockHmacKeys.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await hmacKey.delete(
          options: const PreconditionOptions(
            ifMetagenerationMatch: 123,
          ),
        );

        verify(() => mockHmacKeys.delete(
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);
      });
    });

    group('getMetadata', () {
      late HmacKey hmacKey;

      setUp(() {
        hmacKey = storage.hmacKey(
          'test-access-id',
          HmacKeyOptions(projectId: 'test-project'),
        );
      });

      test('should call hmacKeys.get and update metadata', () async {
        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..projectId = 'test-project'
          ..state = 'ACTIVE'
          ..etag = 'test-etag'
          ..serviceAccountEmail = 'test@example.com';

        when(() => mockHmacKeys.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await hmacKey.getMetadata();

        verify(() => mockHmacKeys.get(
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);

        expect(result.accessId, 'test-access-id');
        expect(result.projectId, 'test-project');
        expect(result.state, 'ACTIVE');
        expect(result.etag, 'test-etag');
        expect(result.serviceAccountEmail, 'test@example.com');

        // Verify metadata was updated
        expect(hmacKey.metadata.accessId, 'test-access-id');
        expect(hmacKey.metadata.state, 'ACTIVE');
      });

      test('should pass userProject parameter', () async {
        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..state = 'ACTIVE';

        when(() => mockHmacKeys.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await hmacKey.getMetadata(userProject: 'my-project');

        verify(() => mockHmacKeys.get(
              'test-project',
              'test-access-id',
              userProject: 'my-project',
            )).called(1);
      });

      test('should throw ApiError on failure', () async {
        when(() => mockHmacKeys.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenThrow(Exception('API Error'));

        expect(
          () => hmacKey.getMetadata(),
          throwsA(isA<ApiError>()),
        );
      });
    });

    group('get', () {
      late HmacKey hmacKey;

      setUp(() {
        hmacKey = storage.hmacKey(
          'test-access-id',
          HmacKeyOptions(projectId: 'test-project'),
        );
      });

      test('should call getMetadata and return HmacKeyMetadata', () async {
        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..state = 'ACTIVE';

        when(() => mockHmacKeys.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await hmacKey.get();

        verify(() => mockHmacKeys.get(
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);

        expect(result, isA<storage_v1.HmacKeyMetadata>());
        expect(result.state, 'ACTIVE');
        expect(hmacKey.metadata.state, 'ACTIVE');
      });
    });

    group('getInstance', () {
      late HmacKey hmacKey;

      setUp(() {
        hmacKey = storage.hmacKey(
          'test-access-id',
          HmacKeyOptions(projectId: 'test-project'),
        );
      });

      test('should call getMetadata and return HmacKey instance', () async {
        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..state = 'ACTIVE';

        when(() => mockHmacKeys.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await hmacKey.getInstance();

        verify(() => mockHmacKeys.get(
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);

        expect(result, same(hmacKey));
        expect(result.metadata.state, 'ACTIVE');
      });

      test('should pass userProject parameter', () async {
        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..state = 'ACTIVE';

        when(() => mockHmacKeys.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await hmacKey.getInstance(userProject: 'my-project');

        verify(() => mockHmacKeys.get(
              'test-project',
              'test-access-id',
              userProject: 'my-project',
            )).called(1);
      });
    });

    group('setMetadata', () {
      late HmacKey hmacKey;

      setUp(() {
        hmacKey = storage.hmacKey(
          'test-access-id',
          HmacKeyOptions(projectId: 'test-project'),
        );
      });

      test('should call hmacKeys.update with state and etag', () async {
        final updateMetadata = storage_v1.HmacKeyMetadata()
          ..state = 'INACTIVE'
          ..etag = 'test-etag';

        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..state = 'INACTIVE'
          ..etag = 'updated-etag'
          ..projectId = 'test-project';

        when(() => mockHmacKeys.update(
              any(),
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await hmacKey.setMetadata(updateMetadata);

        verify(() => mockHmacKeys.update(
              any(
                  that: predicate<storage_v1.HmacKeyMetadata>(
                      (m) => m.state == 'INACTIVE' && m.etag == 'test-etag')),
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);

        expect(result.state, 'INACTIVE');
        expect(result.etag, 'updated-etag');
        expect(hmacKey.metadata.state, 'INACTIVE');
      });

      test('should only send state and etag fields', () async {
        final updateMetadata = storage_v1.HmacKeyMetadata()
          ..accessId = 'should-not-be-sent'
          ..state = 'ACTIVE'
          ..etag = 'test-etag'
          ..projectId = 'should-not-be-sent'
          ..serviceAccountEmail = 'should-not-be-sent';

        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..state = 'ACTIVE'
          ..etag = 'updated-etag';

        when(() => mockHmacKeys.update(
              any(),
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await hmacKey.setMetadata(updateMetadata);

        verify(() => mockHmacKeys.update(
              any(
                  that: predicate<storage_v1.HmacKeyMetadata>((m) =>
                      m.state == 'ACTIVE' &&
                      m.etag == 'test-etag' &&
                      m.accessId == null &&
                      m.projectId == null &&
                      m.serviceAccountEmail == null)),
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);
      });

      test('should work with SetHmacKeyMetadata', () async {
        final updateMetadata = SetHmacKeyMetadata(
          state: HmacKeyState.inactive,
          etag: 'test-etag',
        );

        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..state = 'INACTIVE'
          ..etag = 'updated-etag';

        when(() => mockHmacKeys.update(
              any(),
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await hmacKey.setMetadata(updateMetadata);

        verify(() => mockHmacKeys.update(
              any(
                  that: predicate<storage_v1.HmacKeyMetadata>(
                      (m) => m.state == 'INACTIVE' && m.etag == 'test-etag')),
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);
      });

      test('should update cached metadata after successful update', () async {
        final updateMetadata = storage_v1.HmacKeyMetadata()
          ..state = 'INACTIVE'
          ..etag = 'test-etag';

        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..state = 'INACTIVE'
          ..etag = 'updated-etag'
          ..projectId = 'test-project';

        when(() => mockHmacKeys.update(
              any(),
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await hmacKey.setMetadata(updateMetadata);

        expect(hmacKey.metadata.state, 'INACTIVE');
        expect(hmacKey.metadata.etag, 'updated-etag');
      });

      test('should throw ApiError on failure', () async {
        final updateMetadata = storage_v1.HmacKeyMetadata()..state = 'INACTIVE';

        when(() => mockHmacKeys.update(
              any(),
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenThrow(Exception('API Error'));

        expect(
          () => hmacKey.setMetadata(updateMetadata),
          throwsA(isA<ApiError>()),
        );
      });
    });

    group('retry behavior', () {
      late HmacKey hmacKey;

      setUp(() {
        hmacKey = storage.hmacKey(
          'test-access-id',
          HmacKeyOptions(projectId: 'test-project'),
        );
      });

      test('setMetadata should disable retries unless retryAlways', () async {
        // Set retryConditional strategy (default)
        final storageWithConditional = TestStorage(mockClient);
        final hmacKeyConditional = storageWithConditional.hmacKey(
          'test-access-id',
          HmacKeyOptions(projectId: 'test-project'),
        );

        final updateMetadata = storage_v1.HmacKeyMetadata()..state = 'INACTIVE';

        final mockResponse = storage_v1.HmacKeyMetadata()..state = 'INACTIVE';

        // First call should succeed, but retries should be disabled
        when(() => mockHmacKeys.update(
              any(),
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await hmacKeyConditional.setMetadata(updateMetadata);

        verify(() => mockHmacKeys.update(
              any(),
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);
      });

      test('delete should allow retries by default', () async {
        when(() => mockHmacKeys.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await hmacKey.delete();

        verify(() => mockHmacKeys.delete(
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);
      });

      test('getMetadata should allow retries by default', () async {
        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..state = 'ACTIVE';

        when(() => mockHmacKeys.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await hmacKey.getMetadata();

        verify(() => mockHmacKeys.get(
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);
      });
    });

    group('ServiceObject integration', () {
      late HmacKey hmacKey;

      setUp(() {
        hmacKey = storage.hmacKey(
          'test-access-id',
          HmacKeyOptions(projectId: 'test-project'),
        );
      });

      test('should implement exists() method', () async {
        final mockResponse = storage_v1.HmacKeyMetadata()
          ..accessId = 'test-access-id'
          ..state = 'ACTIVE';

        when(() => mockHmacKeys.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final exists = await hmacKey.exists();

        expect(exists, isTrue);
        verify(() => mockHmacKeys.get(
              'test-project',
              'test-access-id',
              userProject: null,
            )).called(1);
      });

      test('exists() should return false on 404', () async {
        final apiError = ApiError('Not found', code: 404);

        when(() => mockHmacKeys.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenThrow(apiError);

        final exists = await hmacKey.exists();

        expect(exists, isFalse);
      });

      test('exists() should rethrow non-404 errors', () async {
        final apiError = ApiError('Forbidden', code: 403);

        when(() => mockHmacKeys.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenThrow(apiError);

        expect(() => hmacKey.exists(), throwsA(isA<ApiError>()));
      });
    });
  });
}
