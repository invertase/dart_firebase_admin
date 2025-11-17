import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_dart_storage/googleapis_dart_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockStorageApi extends Mock implements storage_v1.StorageApi {}

class MockBucketAccessControlsResource extends Mock
    implements storage_v1.BucketAccessControlsResource {}

class MockObjectAccessControlsResource extends Mock
    implements storage_v1.ObjectAccessControlsResource {}

class MockDefaultObjectAccessControlsResource extends Mock
    implements storage_v1.DefaultObjectAccessControlsResource {}

// No need for mock list response classes - use the real types from googleapis

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

/// Helper to create ACL instances for testing
/// Use the public API to access ACLs
Acl _createBucketAcl(Storage storage, String bucket) {
  return storage.bucket(bucket).acl;
}

Acl _createBucketDefaultObjectAcl(Storage storage, String bucket) {
  return storage.bucket(bucket).aclDefault;
}

Acl _createObjectAcl(Storage storage, String bucket, String object) {
  return storage.bucket(bucket).file(object).acl;
}

void main() {
  late TestStorage storage;
  late MockStorageApi mockClient;
  late MockBucketAccessControlsResource mockBucketAccessControls;
  late MockObjectAccessControlsResource mockObjectAccessControls;
  late MockDefaultObjectAccessControlsResource mockDefaultObjectAccessControls;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(storage_v1.BucketAccessControl());
    registerFallbackValue(storage_v1.ObjectAccessControl());
  });

  setUp(() {
    mockClient = MockStorageApi();
    mockBucketAccessControls = MockBucketAccessControlsResource();
    mockObjectAccessControls = MockObjectAccessControlsResource();
    mockDefaultObjectAccessControls = MockDefaultObjectAccessControlsResource();

    // Setup the mock client to return the resource mocks
    when(() => mockClient.bucketAccessControls)
        .thenReturn(mockBucketAccessControls);
    when(() => mockClient.objectAccessControls)
        .thenReturn(mockObjectAccessControls);
    when(() => mockClient.defaultObjectAccessControls)
        .thenReturn(mockDefaultObjectAccessControls);

    storage = TestStorage(mockClient);
  });

  group('AclEntry', () {
    test('should create with required fields', () {
      const entry = AclEntry(
        entity: 'user-test@example.com',
        role: 'OWNER',
      );

      expect(entry.entity, 'user-test@example.com');
      expect(entry.role, 'OWNER');
      expect(entry.projectTeam, isNull);
    });

    test('should create with projectTeam', () {
      const projectTeam = ProjectTeam(
        projectNumber: '123',
        team: ProjectTeamRole.editors,
      );
      const entry = AclEntry(
        entity: 'user-test@example.com',
        role: 'READER',
        projectTeam: projectTeam,
      );

      expect(entry.entity, 'user-test@example.com');
      expect(entry.role, 'READER');
      expect(entry.projectTeam, projectTeam);
      expect(entry.projectTeam?.projectNumber, '123');
      expect(entry.projectTeam?.team, ProjectTeamRole.editors);
    });
  });

  group('Acl - Bucket ACL', () {
    late Acl bucketAcl;

    setUp(() {
      bucketAcl = _createBucketAcl(storage, 'test-bucket');
    });

    group('add', () {
      test('should call bucketAccessControls.insert with correct parameters',
          () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER';

        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await bucketAcl.add(
          entity: 'user-test@example.com',
          role: 'OWNER',
        );

        verify(() => mockBucketAccessControls.insert(
              any(
                  that: predicate<storage_v1.BucketAccessControl>((acl) =>
                      acl.entity == 'user-test@example.com' &&
                      acl.role == 'OWNER')),
              'test-bucket',
              userProject: null,
            )).called(1);

        expect(result.entity, 'user-test@example.com');
        expect(result.role, 'OWNER');
      });

      test('should uppercase role', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'READER';

        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await bucketAcl.add(
          entity: 'user-test@example.com',
          role: 'reader', // lowercase
        );

        verify(() => mockBucketAccessControls.insert(
              any(
                  that: predicate<storage_v1.BucketAccessControl>(
                      (acl) => acl.role == 'READER')), // should be uppercased
              'test-bucket',
              userProject: null,
            )).called(1);
      });

      test('should pass userProject parameter', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'READER';

        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await bucketAcl.add(
          entity: 'user-test@example.com',
          role: 'READER',
          userProject: 'my-project',
        );

        verify(() => mockBucketAccessControls.insert(
              any(),
              'test-bucket',
              userProject: 'my-project',
            )).called(1);
      });

      test('should throw ApiError on failure', () async {
        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenThrow(Exception('API Error'));

        expect(
          () => bucketAcl.add(
            entity: 'user-test@example.com',
            role: 'OWNER',
          ),
          throwsA(isA<ApiError>()),
        );
      });
    });

    group('delete', () {
      test('should call bucketAccessControls.delete with correct parameters',
          () async {
        when(() => mockBucketAccessControls.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await bucketAcl.delete(entity: 'user-test@example.com');

        verify(() => mockBucketAccessControls.delete(
              'test-bucket',
              'user-test@example.com',
              userProject: null,
            )).called(1);
      });

      test('should pass userProject parameter', () async {
        when(() => mockBucketAccessControls.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await bucketAcl.delete(
          entity: 'user-test@example.com',
          userProject: 'my-project',
        );

        verify(() => mockBucketAccessControls.delete(
              'test-bucket',
              'user-test@example.com',
              userProject: 'my-project',
            )).called(1);
      });
    });

    group('get', () {
      test('should call bucketAccessControls.get with correct parameters',
          () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER';

        when(() => mockBucketAccessControls.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await bucketAcl.get(entity: 'user-test@example.com');

        verify(() => mockBucketAccessControls.get(
              'test-bucket',
              'user-test@example.com',
              userProject: null,
            )).called(1);

        expect(result.entity, 'user-test@example.com');
        expect(result.role, 'OWNER');
      });

      test('should pass userProject parameter', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER';

        when(() => mockBucketAccessControls.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await bucketAcl.get(
          entity: 'user-test@example.com',
          userProject: 'my-project',
        );

        verify(() => mockBucketAccessControls.get(
              'test-bucket',
              'user-test@example.com',
              userProject: 'my-project',
            )).called(1);
      });

      test('should throw ApiError on failure', () async {
        when(() => mockBucketAccessControls.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenThrow(Exception('API Error'));

        expect(
          () => bucketAcl.get(entity: 'user-test@example.com'),
          throwsA(isA<ApiError>()),
        );
      });
    });

    group('getAll', () {
      test('should call bucketAccessControls.list and return all entries',
          () async {
        final mockResponse = storage_v1.BucketAccessControls()
          ..items = [
            storage_v1.BucketAccessControl()
              ..entity = 'user-1@example.com'
              ..role = 'OWNER',
            storage_v1.BucketAccessControl()
              ..entity = 'user-2@example.com'
              ..role = 'READER',
          ];

        when(() => mockBucketAccessControls.list(
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await bucketAcl.getAll();

        verify(() => mockBucketAccessControls.list(
              'test-bucket',
              userProject: null,
            )).called(1);

        expect(result.length, 2);
        expect(result[0].entity, 'user-1@example.com');
        expect(result[0].role, 'OWNER');
        expect(result[1].entity, 'user-2@example.com');
        expect(result[1].role, 'READER');
      });

      test('should handle empty list', () async {
        final mockResponse = storage_v1.BucketAccessControls()..items = [];

        when(() => mockBucketAccessControls.list(
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await bucketAcl.getAll();

        expect(result, isEmpty);
      });

      test('should pass userProject parameter', () async {
        final mockResponse = storage_v1.BucketAccessControls()..items = [];

        when(() => mockBucketAccessControls.list(
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await bucketAcl.getAll(userProject: 'my-project');

        verify(() => mockBucketAccessControls.list(
              'test-bucket',
              userProject: 'my-project',
            )).called(1);
      });

      test('should throw ApiError on failure', () async {
        when(() => mockBucketAccessControls.list(
              any(),
              userProject: any(named: 'userProject'),
            )).thenThrow(Exception('API Error'));

        expect(
          () => bucketAcl.getAll(),
          throwsA(isA<ApiError>()),
        );
      });
    });

    group('update', () {
      test('should call bucketAccessControls.update with correct parameters',
          () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'WRITER';

        when(() => mockBucketAccessControls.update(
              any(),
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await bucketAcl.update(
          entity: 'user-test@example.com',
          role: 'WRITER',
        );

        verify(() => mockBucketAccessControls.update(
              any(
                  that: predicate<storage_v1.BucketAccessControl>(
                      (acl) => acl.role == 'WRITER')),
              'test-bucket',
              'user-test@example.com',
              userProject: null,
            )).called(1);

        expect(result.entity, 'user-test@example.com');
        expect(result.role, 'WRITER');
      });

      test('should uppercase role', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'READER';

        when(() => mockBucketAccessControls.update(
              any(),
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await bucketAcl.update(
          entity: 'user-test@example.com',
          role: 'reader', // lowercase
        );

        verify(() => mockBucketAccessControls.update(
              any(
                  that: predicate<storage_v1.BucketAccessControl>(
                      (acl) => acl.role == 'READER')), // should be uppercased
              'test-bucket',
              'user-test@example.com',
              userProject: null,
            )).called(1);
      });

      test('should pass userProject parameter', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'READER';

        when(() => mockBucketAccessControls.update(
              any(),
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await bucketAcl.update(
          entity: 'user-test@example.com',
          role: 'READER',
          userProject: 'my-project',
        );

        verify(() => mockBucketAccessControls.update(
              any(),
              'test-bucket',
              'user-test@example.com',
              userProject: 'my-project',
            )).called(1);
      });
    });
  });

  group('Acl - Bucket Default Object ACL', () {
    late Acl defaultObjectAcl;

    setUp(() {
      defaultObjectAcl = _createBucketDefaultObjectAcl(storage, 'test-bucket');
    });

    group('add', () {
      test('should call defaultObjectAccessControls.insert', () async {
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER';

        when(() => mockDefaultObjectAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await defaultObjectAcl.add(
          entity: 'user-test@example.com',
          role: 'OWNER',
        );

        verify(() => mockDefaultObjectAccessControls.insert(
              any(
                  that: predicate<storage_v1.ObjectAccessControl>((acl) =>
                      acl.entity == 'user-test@example.com' &&
                      acl.role == 'OWNER')),
              'test-bucket',
              userProject: null,
            )).called(1);

        expect(result.entity, 'user-test@example.com');
        expect(result.role, 'OWNER');
      });
    });

    group('delete', () {
      test('should call defaultObjectAccessControls.delete', () async {
        when(() => mockDefaultObjectAccessControls.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await defaultObjectAcl.delete(entity: 'user-test@example.com');

        verify(() => mockDefaultObjectAccessControls.delete(
              'test-bucket',
              'user-test@example.com',
              userProject: null,
            )).called(1);
      });
    });

    group('get', () {
      test('should call defaultObjectAccessControls.get', () async {
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER';

        when(() => mockDefaultObjectAccessControls.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result =
            await defaultObjectAcl.get(entity: 'user-test@example.com');

        verify(() => mockDefaultObjectAccessControls.get(
              'test-bucket',
              'user-test@example.com',
              userProject: null,
            )).called(1);

        expect(result.entity, 'user-test@example.com');
        expect(result.role, 'OWNER');
      });

      test('should convert projectTeam from API response', () async {
        final mockProjectTeam = storage_v1.ObjectAccessControlProjectTeam()
          ..projectNumber = '123456789'
          ..team = 'editors';
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER'
          ..projectTeam = mockProjectTeam;

        when(() => mockDefaultObjectAccessControls.get(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result =
            await defaultObjectAcl.get(entity: 'user-test@example.com');

        expect(result.projectTeam, isNotNull);
        expect(result.projectTeam?.projectNumber, '123456789');
        expect(result.projectTeam?.team, ProjectTeamRole.editors);
      });
    });

    group('getAll', () {
      test('should call defaultObjectAccessControls.list', () async {
        final mockResponse = storage_v1.ObjectAccessControls()
          ..items = [
            storage_v1.ObjectAccessControl()
              ..entity = 'user-1@example.com'
              ..role = 'OWNER',
          ];

        when(() => mockDefaultObjectAccessControls.list(
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await defaultObjectAcl.getAll();

        verify(() => mockDefaultObjectAccessControls.list(
              'test-bucket',
              userProject: null,
            )).called(1);

        expect(result.length, 1);
        expect(result[0].entity, 'user-1@example.com');
      });
    });

    group('update', () {
      test('should call defaultObjectAccessControls.update', () async {
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'WRITER';

        when(() => mockDefaultObjectAccessControls.update(
              any(),
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await defaultObjectAcl.update(
          entity: 'user-test@example.com',
          role: 'WRITER',
        );

        verify(() => mockDefaultObjectAccessControls.update(
              any(),
              'test-bucket',
              'user-test@example.com',
              userProject: null,
            )).called(1);

        expect(result.role, 'WRITER');
      });
    });
  });

  group('Acl - Object ACL', () {
    late Acl objectAcl;

    setUp(() {
      objectAcl = _createObjectAcl(storage, 'test-bucket', 'test-object');
    });

    group('add', () {
      test('should call objectAccessControls.insert with correct parameters',
          () async {
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER';

        when(() => mockObjectAccessControls.insert(
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await objectAcl.add(
          entity: 'user-test@example.com',
          role: 'OWNER',
        );

        verify(() => mockObjectAccessControls.insert(
              any(
                  that: predicate<storage_v1.ObjectAccessControl>((acl) =>
                      acl.entity == 'user-test@example.com' &&
                      acl.role == 'OWNER')),
              'test-bucket',
              'test-object',
              generation: null,
              userProject: null,
            )).called(1);

        expect(result.entity, 'user-test@example.com');
        expect(result.role, 'OWNER');
      });

      test('should pass generation parameter', () async {
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'READER';

        when(() => mockObjectAccessControls.insert(
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await objectAcl.add(
          entity: 'user-test@example.com',
          role: 'READER',
          generation: 123,
        );

        verify(() => mockObjectAccessControls.insert(
              any(),
              'test-bucket',
              'test-object',
              generation: '123',
              userProject: null,
            )).called(1);
      });

      test('should pass userProject parameter', () async {
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'READER';

        when(() => mockObjectAccessControls.insert(
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await objectAcl.add(
          entity: 'user-test@example.com',
          role: 'READER',
          userProject: 'my-project',
        );

        verify(() => mockObjectAccessControls.insert(
              any(),
              'test-bucket',
              'test-object',
              generation: null,
              userProject: 'my-project',
            )).called(1);
      });
    });

    group('delete', () {
      test('should call objectAccessControls.delete', () async {
        when(() => mockObjectAccessControls.delete(
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await objectAcl.delete(entity: 'user-test@example.com');

        verify(() => mockObjectAccessControls.delete(
              'test-bucket',
              'test-object',
              'user-test@example.com',
              generation: null,
              userProject: null,
            )).called(1);
      });

      test('should pass generation parameter', () async {
        when(() => mockObjectAccessControls.delete(
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await objectAcl.delete(
          entity: 'user-test@example.com',
          generation: 123,
        );

        verify(() => mockObjectAccessControls.delete(
              'test-bucket',
              'test-object',
              'user-test@example.com',
              generation: '123',
              userProject: null,
            )).called(1);
      });
    });

    group('get', () {
      test('should call objectAccessControls.get', () async {
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER';

        when(() => mockObjectAccessControls.get(
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await objectAcl.get(entity: 'user-test@example.com');

        verify(() => mockObjectAccessControls.get(
              'test-bucket',
              'test-object',
              'user-test@example.com',
              generation: null,
              userProject: null,
            )).called(1);

        expect(result.entity, 'user-test@example.com');
        expect(result.role, 'OWNER');
      });

      test('should pass generation parameter', () async {
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER';

        when(() => mockObjectAccessControls.get(
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await objectAcl.get(
          entity: 'user-test@example.com',
          generation: 123,
        );

        verify(() => mockObjectAccessControls.get(
              'test-bucket',
              'test-object',
              'user-test@example.com',
              generation: '123',
              userProject: null,
            )).called(1);
      });

      test('should convert projectTeam from API response', () async {
        final mockProjectTeam = storage_v1.ObjectAccessControlProjectTeam()
          ..projectNumber = '123456789'
          ..team = 'editors';
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER'
          ..projectTeam = mockProjectTeam;

        when(() => mockObjectAccessControls.get(
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await objectAcl.get(entity: 'user-test@example.com');

        expect(result.projectTeam, isNotNull);
        expect(result.projectTeam?.projectNumber, '123456789');
        expect(result.projectTeam?.team, ProjectTeamRole.editors);
      });

      test('should handle projectTeam with owners team', () async {
        final mockProjectTeam = storage_v1.ObjectAccessControlProjectTeam()
          ..projectNumber = '987654321'
          ..team = 'owners';
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER'
          ..projectTeam = mockProjectTeam;

        when(() => mockObjectAccessControls.get(
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await objectAcl.get(entity: 'user-test@example.com');

        expect(result.projectTeam?.team, ProjectTeamRole.owners);
        expect(result.projectTeam?.projectNumber, '987654321');
      });

      test('should handle projectTeam with viewers team', () async {
        final mockProjectTeam = storage_v1.ObjectAccessControlProjectTeam()
          ..team = 'viewers';
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'OWNER'
          ..projectTeam = mockProjectTeam;

        when(() => mockObjectAccessControls.get(
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await objectAcl.get(entity: 'user-test@example.com');

        expect(result.projectTeam?.team, ProjectTeamRole.viewers);
        expect(result.projectTeam?.projectNumber, isNull);
      });
    });

    group('getAll', () {
      test('should call objectAccessControls.list', () async {
        final mockResponse = storage_v1.ObjectAccessControls()
          ..items = [
            storage_v1.ObjectAccessControl()
              ..entity = 'user-1@example.com'
              ..role = 'OWNER',
          ];

        when(() => mockObjectAccessControls.list(
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await objectAcl.getAll();

        verify(() => mockObjectAccessControls.list(
              'test-bucket',
              'test-object',
              generation: null,
              userProject: null,
            )).called(1);

        expect(result.length, 1);
        expect(result[0].entity, 'user-1@example.com');
      });

      test('should pass generation parameter', () async {
        final mockResponse = storage_v1.ObjectAccessControls()..items = [];

        when(() => mockObjectAccessControls.list(
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await objectAcl.getAll(generation: 123);

        verify(() => mockObjectAccessControls.list(
              'test-bucket',
              'test-object',
              generation: '123',
              userProject: null,
            )).called(1);
      });

      test('should convert projectTeam in list responses', () async {
        final mockProjectTeam = storage_v1.ObjectAccessControlProjectTeam()
          ..projectNumber = '123456789'
          ..team = 'editors';
        final mockResponse = storage_v1.ObjectAccessControls()
          ..items = [
            storage_v1.ObjectAccessControl()
              ..entity = 'user-1@example.com'
              ..role = 'OWNER'
              ..projectTeam = mockProjectTeam,
            storage_v1.ObjectAccessControl()
              ..entity = 'user-2@example.com'
              ..role = 'READER',
          ];

        when(() => mockObjectAccessControls.list(
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await objectAcl.getAll();

        expect(result.length, 2);
        expect(result[0].entity, 'user-1@example.com');
        expect(result[0].projectTeam, isNotNull);
        expect(result[0].projectTeam?.projectNumber, '123456789');
        expect(result[0].projectTeam?.team, ProjectTeamRole.editors);
        expect(result[1].entity, 'user-2@example.com');
        expect(result[1].projectTeam, isNull);
      });
    });

    group('update', () {
      test('should call objectAccessControls.update', () async {
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'WRITER';

        when(() => mockObjectAccessControls.update(
              any(),
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        final result = await objectAcl.update(
          entity: 'user-test@example.com',
          role: 'WRITER',
        );

        verify(() => mockObjectAccessControls.update(
              any(),
              'test-bucket',
              'test-object',
              'user-test@example.com',
              generation: null,
              userProject: null,
            )).called(1);

        expect(result.role, 'WRITER');
      });

      test('should pass generation parameter', () async {
        final mockResponse = storage_v1.ObjectAccessControl()
          ..entity = 'user-test@example.com'
          ..role = 'READER';

        when(() => mockObjectAccessControls.update(
              any(),
              any(),
              any(),
              any(),
              generation: any(named: 'generation'),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await objectAcl.update(
          entity: 'user-test@example.com',
          role: 'READER',
          generation: 123,
        );

        verify(() => mockObjectAccessControls.update(
              any(),
              'test-bucket',
              'test-object',
              'user-test@example.com',
              generation: '123',
              userProject: null,
            )).called(1);
      });
    });
  });

  group('AclRoleAccessor', () {
    late Acl bucketAcl;
    late AclRoleAccessor owners;
    late AclRoleAccessor readers;
    late AclRoleAccessor writers;
    late AclRoleAccessor fullControl;

    setUp(() {
      bucketAcl = _createBucketAcl(storage, 'test-bucket');
      owners = bucketAcl.owners;
      readers = bucketAcl.readers;
      writers = bucketAcl.writers;
      fullControl = bucketAcl.fullControl;
    });

    test('should create role accessors', () {
      expect(owners, isA<AclRoleAccessor>());
      expect(readers, isA<AclRoleAccessor>());
      expect(writers, isA<AclRoleAccessor>());
      expect(fullControl, isA<AclRoleAccessor>());
    });

    group('allUsers', () {
      test('owners should add allUsers with OWNER role', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'allUsers'
          ..role = 'OWNER';

        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await owners.addAllUsers();

        verify(() => mockBucketAccessControls.insert(
              any(
                  that: predicate<storage_v1.BucketAccessControl>((acl) =>
                      acl.entity == 'allUsers' && acl.role == 'OWNER')),
              'test-bucket',
              userProject: null,
            )).called(1);
      });

      test('readers should add allUsers with READER role', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'allUsers'
          ..role = 'READER';

        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await readers.addAllUsers();

        verify(() => mockBucketAccessControls.insert(
              any(
                  that: predicate<storage_v1.BucketAccessControl>((acl) =>
                      acl.entity == 'allUsers' && acl.role == 'READER')),
              'test-bucket',
              userProject: null,
            )).called(1);
      });

      test('should delete allUsers', () async {
        when(() => mockBucketAccessControls.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await owners.deleteAllUsers();

        verify(() => mockBucketAccessControls.delete(
              'test-bucket',
              'allUsers',
              userProject: null,
            )).called(1);
      });
    });

    group('allAuthenticatedUsers', () {
      test('should add allAuthenticatedUsers', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'allAuthenticatedUsers'
          ..role = 'OWNER';

        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await owners.addAllAuthenticatedUsers();

        verify(() => mockBucketAccessControls.insert(
              any(
                  that: predicate<storage_v1.BucketAccessControl>((acl) =>
                      acl.entity == 'allAuthenticatedUsers' &&
                      acl.role == 'OWNER')),
              'test-bucket',
              userProject: null,
            )).called(1);
      });

      test('should delete allAuthenticatedUsers', () async {
        when(() => mockBucketAccessControls.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await owners.deleteAllAuthenticatedUsers();

        verify(() => mockBucketAccessControls.delete(
              'test-bucket',
              'allAuthenticatedUsers',
              userProject: null,
            )).called(1);
      });
    });

    group('domain', () {
      test('should add domain with "domain-" prefix', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'domain-example.com'
          ..role = 'OWNER';

        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await owners.addDomain('example.com');

        verify(() => mockBucketAccessControls.insert(
              any(
                  that: predicate<storage_v1.BucketAccessControl>((acl) =>
                      acl.entity == 'domain-example.com' &&
                      acl.role == 'OWNER')),
              'test-bucket',
              userProject: null,
            )).called(1);
      });

      test('should delete domain with "domain-" prefix', () async {
        when(() => mockBucketAccessControls.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await owners.deleteDomain('example.com');

        verify(() => mockBucketAccessControls.delete(
              'test-bucket',
              'domain-example.com',
              userProject: null,
            )).called(1);
      });
    });

    group('group', () {
      test('should add group with "group-" prefix', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'group-group@example.com'
          ..role = 'OWNER';

        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await owners.addGroup('group@example.com');

        verify(() => mockBucketAccessControls.insert(
              any(
                  that: predicate<storage_v1.BucketAccessControl>((acl) =>
                      acl.entity == 'group-group@example.com' &&
                      acl.role == 'OWNER')),
              'test-bucket',
              userProject: null,
            )).called(1);
      });

      test('should delete group with "group-" prefix', () async {
        when(() => mockBucketAccessControls.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await owners.deleteGroup('group@example.com');

        verify(() => mockBucketAccessControls.delete(
              'test-bucket',
              'group-group@example.com',
              userProject: null,
            )).called(1);
      });
    });

    group('project', () {
      test('should add project with "project-" prefix', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'project-project-id'
          ..role = 'OWNER';

        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await owners.addProject('project-id');

        verify(() => mockBucketAccessControls.insert(
              any(
                  that: predicate<storage_v1.BucketAccessControl>((acl) =>
                      acl.entity == 'project-project-id' &&
                      acl.role == 'OWNER')),
              'test-bucket',
              userProject: null,
            )).called(1);
      });

      test('should delete project with "project-" prefix', () async {
        when(() => mockBucketAccessControls.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await owners.deleteProject('project-id');

        verify(() => mockBucketAccessControls.delete(
              'test-bucket',
              'project-project-id',
              userProject: null,
            )).called(1);
      });
    });

    group('user', () {
      test('should add user with "user-" prefix', () async {
        final mockResponse = storage_v1.BucketAccessControl()
          ..entity = 'user-user@example.com'
          ..role = 'OWNER';

        when(() => mockBucketAccessControls.insert(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => mockResponse);

        await owners.addUser('user@example.com');

        verify(() => mockBucketAccessControls.insert(
              any(
                  that: predicate<storage_v1.BucketAccessControl>((acl) =>
                      acl.entity == 'user-user@example.com' &&
                      acl.role == 'OWNER')),
              'test-bucket',
              userProject: null,
            )).called(1);
      });

      test('should delete user with "user-" prefix', () async {
        when(() => mockBucketAccessControls.delete(
              any(),
              any(),
              userProject: any(named: 'userProject'),
            )).thenAnswer((_) async => '');

        await owners.deleteUser('user@example.com');

        verify(() => mockBucketAccessControls.delete(
              'test-bucket',
              'user-user@example.com',
              userProject: null,
            )).called(1);
      });
    });
  });
}
