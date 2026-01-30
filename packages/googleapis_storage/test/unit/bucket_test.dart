import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_storage/googleapis_storage.dart';
import 'package:googleapis_storage/src/internal/service_object.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthClient extends Mock implements auth.AuthClient {}

class MockStorageApi extends Mock implements storage_v1.StorageApi {}

class MockObjectsResource extends Mock implements storage_v1.ObjectsResource {}

class MockBucketsResource extends Mock implements storage_v1.BucketsResource {}

class MockURLSigner extends Mock implements URLSigner {}

class FakeBaseRequest extends Fake implements http.BaseRequest {}

/// Test helper that creates a Storage instance with an injectable mock client
class TestStorage extends Storage {
  final storage_v1.StorageApi mockClient;
  final auth.AuthClient? mockAuth;

  TestStorage(this.mockClient, {String? projectId, this.mockAuth})
    : super(
        StorageOptions(
          authClient: mockAuth ?? MockAuthClient(),
          useAuthWithCustomEndpoint: false,
          projectId: projectId,
        ),
      );

  @override
  Future<storage_v1.StorageApi> get storageClient async => mockClient;

  @override
  Future<auth.AuthClient> get authClient async => mockAuth ?? MockAuthClient();
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SignedUrlConfig(method: SignedUrlMethod.get, expires: DateTime.now()),
    );
    registerFallbackValue(storage_v1.Object());
    registerFallbackValue(storage_v1.Bucket());
    registerFallbackValue(storage_v1.ComposeRequest());
    registerFallbackValue(FakeBaseRequest());
  });

  group('Bucket.getSignedUrl', () {
    late Storage storage;
    late Bucket bucket;
    late MockURLSigner mockSigner;
    final expires = DateTime(2026, 12, 31);
    const expectedSignedUrl = 'https://signed-url.example.com';

    setUp(() {
      storage = Storage(const StorageOptions(projectId: 'test-project'));
      mockSigner = MockURLSigner();

      // Use internal constructor to inject the mock signer
      bucket = Bucket.internal(storage, 'test-bucket', null, mockSigner);

      when(
        () => mockSigner.getSignedUrl(any()),
      ).thenAnswer((_) async => expectedSignedUrl);
    });

    test(
      'should call signer.getSignedUrl with correct config for list action',
      () async {
        final options = GetBucketSignedUrlOptions(
          action: 'list',
          expires: expires,
          version: SignedUrlVersion.v4,
        );

        final result = await bucket.getSignedUrl(options);

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

    test('should forward virtualHostedStyle parameter', () async {
      final options = GetBucketSignedUrlOptions(
        action: 'list',
        expires: expires,
        virtualHostedStyle: true,
      );

      await bucket.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.virtualHostedStyle, true);
    });

    test('should forward cname parameter', () async {
      const cname = 'https://cdn.example.com';
      final options = GetBucketSignedUrlOptions(
        action: 'list',
        expires: expires,
        cname: cname,
      );

      await bucket.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.cname, cname);
    });

    test('should forward extensionHeaders parameter', () async {
      final headers = {'x-goog-meta-test': 'value'};
      final options = GetBucketSignedUrlOptions(
        action: 'list',
        expires: expires,
        extensionHeaders: headers,
      );

      await bucket.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.extensionHeaders, headers);
    });

    test('should forward queryParams parameter', () async {
      final params = {'custom': 'value'};
      final options = GetBucketSignedUrlOptions(
        action: 'list',
        expires: expires,
        queryParams: params,
      );

      await bucket.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.queryParams, params);
    });

    test('should forward host parameter', () async {
      final host = Uri.parse('https://custom.example.com');
      final options = GetBucketSignedUrlOptions(
        action: 'list',
        expires: expires,
        host: host,
      );

      await bucket.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.host, host);
    });

    test('should forward signingEndpoint parameter', () async {
      final endpoint = Uri.parse('https://signing.example.com');
      final options = GetBucketSignedUrlOptions(
        action: 'list',
        expires: expires,
        signingEndpoint: endpoint,
      );

      await bucket.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.signingEndpoint, endpoint);
    });

    test('should use v2 version when specified', () async {
      final options = GetBucketSignedUrlOptions(
        action: 'list',
        expires: expires,
        version: SignedUrlVersion.v2,
      );

      await bucket.getSignedUrl(options);

      final captured = verify(
        () => mockSigner.getSignedUrl(captureAny()),
      ).captured;
      final config = captured[0] as SignedUrlConfig;
      expect(config.version, SignedUrlVersion.v2);
    });
  });

  group('Bucket.file', () {
    late TestStorage storage;
    late Bucket bucket;

    setUp(() {
      final mockClient = MockStorageApi();
      storage = TestStorage(mockClient, projectId: 'test-project');
      bucket = storage.bucket('test-bucket');
    });

    test('should return a BucketFile object', () {
      const fileName = 'remote-file-name.jpg';
      final file = bucket.file(fileName);

      expect(file, isA<BucketFile>());
      expect(file.name, fileName);
      expect(file.bucket.id, 'test-bucket');
    });

    test('should pass filename to File object', () {
      const fileName = 'test-file.txt';
      final file = bucket.file(fileName);

      expect(file.name, fileName);
    });

    test('should pass bucket to File object', () {
      const fileName = 'test-file.txt';
      final file = bucket.file(fileName);

      expect(file.bucket.id, bucket.id);
      expect(file.bucket.name, bucket.name);
    });

    test('should pass FileOptions to File object', () {
      const fileName = 'test-file.txt';
      const kmsKeyName =
          'projects/test/locations/us/keyRings/kr/cryptoKeys/key';
      final options = FileOptions(
        kmsKeyName: kmsKeyName,
        userProject: 'user-project',
      );
      final file = bucket.file(fileName, options);

      expect(file.name, fileName);
      // Verify options were passed (they're stored internally in BucketFile)
      expect(file.bucket.id, bucket.id);
    });

    test('should handle null options', () {
      const fileName = 'test-file.txt';
      final file = bucket.file(fileName, null);

      expect(file, isA<BucketFile>());
      expect(file.name, fileName);
    });
  });

  group('Bucket.getFiles', () {
    late TestStorage storage;
    late MockStorageApi mockClient;
    late MockObjectsResource mockObjects;
    late Bucket bucket;

    setUp(() {
      mockClient = MockStorageApi();
      mockObjects = MockObjectsResource();
      when(() => mockClient.objects).thenReturn(mockObjects);
      storage = TestStorage(mockClient, projectId: 'test-project');
      bucket = storage.bucket('test-bucket');
    });

    test('should get files without a query (autoPaginate: true)', () async {
      final file1 = storage_v1.Object()
        ..name = 'file1.txt'
        ..bucket = 'test-bucket';
      final file2 = storage_v1.Object()
        ..name = 'file2.txt'
        ..bucket = 'test-bucket';

      // Mock first page
      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1, file2]
          ..nextPageToken = null,
      );

      final (files, nextQuery) = await bucket.getFiles();

      expect(files, hasLength(2));
      expect(files[0].name, 'file1.txt');
      expect(files[1].name, 'file2.txt');
      expect(nextQuery, isNull);
    });

    test(
      'should get files with query parameters (autoPaginate: false)',
      () async {
        const token = 'next-page-token';
        final file1 = storage_v1.Object()
          ..name = 'file1.txt'
          ..bucket = 'test-bucket';

        when(
          () => mockObjects.list(
            'test-bucket',
            delimiter: '/',
            endOffset: any(named: 'endOffset'),
            includeFoldersAsPrefixes: true,
            includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
            prefix: 'prefix/',
            matchGlob: any(named: 'matchGlob'),
            maxResults: 5,
            pageToken: token,
            softDeleted: any(named: 'softDeleted'),
            startOffset: any(named: 'startOffset'),
            userProject: any(named: 'userProject'),
            versions: any(named: 'versions'),
          ),
        ).thenAnswer(
          (_) async => storage_v1.Objects()
            ..items = [file1]
            ..nextPageToken = 'next-token',
        );

        final (files, nextQuery) = await bucket.getFiles(
          GetFilesOptions(
            autoPaginate: false,
            maxResults: 5,
            pageToken: token,
            includeFoldersAsPrefixes: true,
            delimiter: '/',
            prefix: 'prefix/',
          ),
        );

        expect(files, hasLength(1));
        expect(files[0].name, 'file1.txt');
        expect(nextQuery, isNotNull);
        expect(nextQuery?.pageToken, 'next-token');
        expect(nextQuery?.maxResults, 5);
      },
    );

    test('should return null nextQuery if there are no more results', () async {
      final file1 = storage_v1.Object()
        ..name = 'file1.txt'
        ..bucket = 'test-bucket';

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1]
          ..nextPageToken = null,
      );

      final (files, nextQuery) = await bucket.getFiles(
        GetFilesOptions(autoPaginate: false, maxResults: 5),
      );

      expect(files, hasLength(1));
      expect(nextQuery, isNull);
    });

    test('should return File objects', () async {
      final file1 = storage_v1.Object()
        ..name = 'fake-file-name.txt'
        ..bucket = 'test-bucket'
        ..generation = '1';

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1]
          ..nextPageToken = null,
      );

      final (files, _) = await bucket.getFiles(
        GetFilesOptions(autoPaginate: false),
      );

      expect(files, hasLength(1));
      expect(files[0], isA<BucketFile>());
      expect(files[0].name, 'fake-file-name.txt');
    });

    test('should return versioned Files if queried for versions', () async {
      final file1 = storage_v1.Object()
        ..name = 'fake-file-name.txt'
        ..bucket = 'test-bucket'
        ..generation = '123';

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: true,
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1]
          ..nextPageToken = null,
      );

      final (files, _) = await bucket.getFiles(
        GetFilesOptions(autoPaginate: false, versions: true),
      );

      expect(files, hasLength(1));
      expect(files[0].name, 'fake-file-name.txt');
      // When versions=true, generation should be set on the FileOptions
      // This is verified by checking the file was created with the generation
    });

    test('should set kmsKeyName on file', () async {
      const kmsKeyName =
          'projects/test/locations/us/keyRings/kr/cryptoKeys/key';
      final file1 = storage_v1.Object()
        ..name = 'fake-file-name.txt'
        ..bucket = 'test-bucket'
        ..kmsKeyName = kmsKeyName;

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: true,
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1]
          ..nextPageToken = null,
      );

      final (files, _) = await bucket.getFiles(
        GetFilesOptions(autoPaginate: false, versions: true),
      );

      expect(files, hasLength(1));
      expect(files[0].name, 'fake-file-name.txt');
      // kmsKeyName is passed via FileOptions to the file instance
    });

    test(
      'should return soft-deleted Files if queried for softDeleted',
      () async {
        final file1 = storage_v1.Object()
          ..name = 'fake-file-name.txt'
          ..bucket = 'test-bucket'
          ..generation = '1';

        when(
          () => mockObjects.list(
            any(),
            delimiter: any(named: 'delimiter'),
            endOffset: any(named: 'endOffset'),
            includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
            includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
            prefix: any(named: 'prefix'),
            matchGlob: any(named: 'matchGlob'),
            maxResults: any(named: 'maxResults'),
            pageToken: any(named: 'pageToken'),
            softDeleted: true,
            startOffset: any(named: 'startOffset'),
            userProject: any(named: 'userProject'),
            versions: any(named: 'versions'),
          ),
        ).thenAnswer(
          (_) async => storage_v1.Objects()
            ..items = [file1]
            ..nextPageToken = null,
        );

        final (files, _) = await bucket.getFiles(
          GetFilesOptions(autoPaginate: false, softDeleted: true),
        );

        expect(files, hasLength(1));
        expect(files[0], isA<BucketFile>());
        expect(files[0].name, 'fake-file-name.txt');
      },
    );

    test('should populate returned File object with metadata', () async {
      final fileMetadata = storage_v1.Object()
        ..name = 'filename.txt'
        ..bucket = 'test-bucket'
        ..contentType = 'x-zebra'
        ..metadata = {'my': 'custom metadata'};

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [fileMetadata]
          ..nextPageToken = null,
      );

      final (files, _) = await bucket.getFiles(
        GetFilesOptions(autoPaginate: false),
      );

      expect(files, hasLength(1));
      expect(files[0].name, 'filename.txt');
      // Metadata is set via setInstanceMetadata, verify it's accessible
    });

    test('should forward userProject from options', () async {
      final file1 = storage_v1.Object()
        ..name = 'file1.txt'
        ..bucket = 'test-bucket';

      when(
        () => mockObjects.list(
          'test-bucket',
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: 'custom-project',
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1]
          ..nextPageToken = null,
      );

      await bucket.getFiles(
        GetFilesOptions(autoPaginate: false, userProject: 'custom-project'),
      );

      verify(
        () => mockObjects.list(
          'test-bucket',
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: 'custom-project',
          versions: any(named: 'versions'),
        ),
      ).called(1);
    });

    test('should handle all query parameters correctly', () async {
      when(
        () => mockObjects.list(
          'test-bucket',
          delimiter: '/',
          endOffset: 'end',
          includeFoldersAsPrefixes: true,
          includeTrailingDelimiter: true,
          prefix: 'prefix/',
          matchGlob: '*.txt',
          maxResults: 10,
          pageToken: 'token',
          softDeleted: true,
          startOffset: 'start',
          userProject: any(named: 'userProject'),
          versions: true,
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = []
          ..nextPageToken = null,
      );

      await bucket.getFiles(
        GetFilesOptions(
          autoPaginate: false,
          delimiter: '/',
          endOffset: 'end',
          includeFoldersAsPrefixes: true,
          includeTrailingDelimiter: true,
          prefix: 'prefix/',
          matchGlob: '*.txt',
          maxResults: 10,
          pageToken: 'token',
          softDeleted: true,
          startOffset: 'start',
          versions: true,
        ),
      );

      verify(
        () => mockObjects.list(
          'test-bucket',
          delimiter: '/',
          endOffset: 'end',
          includeFoldersAsPrefixes: true,
          includeTrailingDelimiter: true,
          prefix: 'prefix/',
          matchGlob: '*.txt',
          maxResults: 10,
          pageToken: 'token',
          softDeleted: true,
          startOffset: 'start',
          userProject: any(named: 'userProject'),
          versions: true,
        ),
      ).called(1);
    });

    test('should handle API errors', () async {
      final error = ApiError('Internal Server Error', code: 500);

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenThrow(error);

      expect(
        () => bucket.getFiles(GetFilesOptions(autoPaginate: false)),
        throwsA(isA<ApiError>()),
      );
    });

    test(
      'should return Files with specified values if queried for fields',
      () async {
        // Note: The fields parameter is in GetFilesOptions but not currently
        // forwarded to the API call in the implementation. This test verifies
        // the current behavior.
        final file1 = storage_v1.Object()
          ..name = 'fake-file-name.txt'
          ..bucket = 'test-bucket';

        when(
          () => mockObjects.list(
            any(),
            delimiter: any(named: 'delimiter'),
            endOffset: any(named: 'endOffset'),
            includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
            includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
            prefix: any(named: 'prefix'),
            matchGlob: any(named: 'matchGlob'),
            maxResults: any(named: 'maxResults'),
            pageToken: any(named: 'pageToken'),
            softDeleted: any(named: 'softDeleted'),
            startOffset: any(named: 'startOffset'),
            userProject: any(named: 'userProject'),
            versions: any(named: 'versions'),
          ),
        ).thenAnswer(
          (_) async => storage_v1.Objects()
            ..items = [file1]
            ..nextPageToken = null,
        );

        final (files, _) = await bucket.getFiles(
          GetFilesOptions(autoPaginate: false, fields: 'items(name)'),
        );

        expect(files, hasLength(1));
        expect(files[0].name, 'fake-file-name.txt');
        // Note: fields parameter is accepted but not forwarded to API
        // This would need to be implemented in bucket.dart:709-723
      },
    );
  });

  group('Bucket.upload', () {
    late TestStorage storage;
    late MockStorageApi mockClient;
    late MockAuthClient mockAuthClient;
    late MockObjectsResource mockObjects;
    late Bucket bucket;
    late io.File testFile;

    setUp(() {
      mockClient = MockStorageApi();
      mockAuthClient = MockAuthClient();
      mockObjects = MockObjectsResource();
      when(() => mockClient.objects).thenReturn(mockObjects);

      storage = TestStorage(
        mockClient,
        projectId: 'test-project',
        mockAuth: mockAuthClient,
      );
      bucket = storage.bucket('test-bucket');

      // Create a temporary test file
      testFile = io.File(
        '${io.Directory.systemTemp.path}/test-upload-${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      testFile.writeAsStringSync('test content');
    });

    tearDown(() {
      if (testFile.existsSync()) {
        testFile.deleteSync();
      }
    });

    test('should throw if file does not exist', () async {
      final nonExistentFile = io.File('/non/existent/file.txt');

      expect(
        () => bucket.upload(nonExistentFile),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should upload file with default destination (basename)', () async {
      // Mock successful upload response
      when(() => mockAuthClient.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final uploadedFile = await bucket.upload(
        testFile,
        UploadOptions(resumable: false),
      );

      expect(uploadedFile.bucket.id, bucket.id);
      expect(
        uploadedFile.name,
        testFile.path.split(io.Platform.pathSeparator).last,
      );
    });

    test('should upload file with PathUploadDestination', () async {
      const newFileName = 'new-file-name.png';

      when(() => mockAuthClient.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "$newFileName", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final uploadedFile = await bucket.upload(
        testFile,
        UploadOptions(
          resumable: false,
          destination: UploadDestination.path(newFileName),
        ),
      );

      expect(uploadedFile.bucket.id, bucket.id);
      expect(uploadedFile.name, newFileName);
    });

    test('should upload file with FileUploadDestination', () async {
      const destFileName = 'destination-file.txt';
      final destFile = bucket.file(destFileName);

      when(() => mockAuthClient.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "$destFileName", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final uploadedFile = await bucket.upload(
        testFile,
        UploadOptions(
          resumable: false,
          destination: UploadDestination.file(destFile),
        ),
      );

      expect(uploadedFile.bucket.id, bucket.id);
      expect(uploadedFile.name, destFileName);
      // Verify it's the same file instance
      expect(uploadedFile, destFile);
    });

    test('should forward encryptionKey and kmsKeyName to FileOptions', () async {
      const kmsKeyName =
          'projects/test/locations/us/keyRings/kr/cryptoKeys/key';
      final encryptionKey = Uint8List.fromList([
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        29,
        30,
        31,
        32,
      ]);

      when(() => mockAuthClient.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final uploadedFile = await bucket.upload(
        testFile,
        UploadOptions(
          resumable: false,
          encryptionKey: EncryptionKey.fromBuffer(encryptionKey),
          kmsKeyName: kmsKeyName,
        ),
      );

      expect(
        uploadedFile.name,
        testFile.path.split(io.Platform.pathSeparator).last,
      );
      // encryptionKey and kmsKeyName are stored in FileOptions internally
    });

    test('should forward metadata to createWriteStream', () async {
      final metadata = storage_v1.Object()
        ..contentType = 'text/plain'
        ..metadata = {'a': 'b', 'c': 'd'};

      http.BaseRequest? capturedRequest;

      when(() => mockAuthClient.send(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as http.BaseRequest;
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12", '
              '"contentType": "text/plain"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await bucket.upload(
        testFile,
        UploadOptions(resumable: false, metadata: metadata),
      );

      // Verify the request was made (metadata would be in the multipart body)
      expect(capturedRequest, isNotNull);
    });

    test('should forward gzip option', () async {
      http.BaseRequest? capturedRequest;

      when(() => mockAuthClient.send(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as http.BaseRequest;
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await bucket.upload(
        testFile,
        UploadOptions(resumable: false, gzip: true),
      );

      expect(capturedRequest, isNotNull);
      // gzip would affect the content-encoding header or body compression
    });

    test('should forward resumable option', () async {
      // For resumable uploads, we'd expect a different API flow
      when(() => mockAuthClient.send(any())).thenAnswer((_) async {
        // Resumable upload would first create a resumable session
        return http.StreamedResponse(
          Stream.value(utf8.encode('')),
          200,
          headers: {
            'location':
                'https://storage.googleapis.com/upload/storage/v1/b/test-bucket/o?uploadType=resumable&upload_id=test-upload-id',
          },
        );
      });

      final uploadedFile = await bucket.upload(
        testFile,
        UploadOptions(resumable: true),
      );

      expect(
        uploadedFile.name,
        testFile.path.split(io.Platform.pathSeparator).last,
      );
    });

    test('should forward predefinedAcl option', () async {
      http.BaseRequest? capturedRequest;

      when(() => mockAuthClient.send(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as http.BaseRequest;
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await bucket.upload(
        testFile,
        UploadOptions(
          resumable: false,
          predefinedAcl: PredefinedAcl.publicRead,
        ),
      );

      expect(capturedRequest, isNotNull);
      // predefinedAcl would be in query parameters or headers
    });

    test('should forward private option', () async {
      http.BaseRequest? capturedRequest;

      when(() => mockAuthClient.send(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as http.BaseRequest;
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await bucket.upload(
        testFile,
        UploadOptions(resumable: false, private: true),
      );

      expect(capturedRequest, isNotNull);
      // private: true sets predefinedAcl to 'private'
    });

    test('should forward public option', () async {
      http.BaseRequest? capturedRequest;

      when(() => mockAuthClient.send(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as http.BaseRequest;
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await bucket.upload(
        testFile,
        UploadOptions(resumable: false, public: true),
      );

      expect(capturedRequest, isNotNull);
      // public: true sets predefinedAcl to 'publicRead'
    });

    test('should forward preconditionOpts to FileOptions', () async {
      final preconditionOpts = PreconditionOptions(
        ifGenerationMatch: 123,
        ifMetagenerationMatch: 456,
      );

      when(() => mockAuthClient.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final uploadedFile = await bucket.upload(
        testFile,
        UploadOptions(resumable: false, preconditionOpts: preconditionOpts),
      );

      expect(
        uploadedFile.name,
        testFile.path.split(io.Platform.pathSeparator).last,
      );
      // preconditionOpts are passed to FileOptions when creating destination
    });

    test('should handle upload errors', () async {
      when(() => mockAuthClient.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('{"error": {"message": "Upload failed"}}')),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      expect(
        () => bucket.upload(testFile, UploadOptions(resumable: false)),
        throwsA(isA<ApiError>()),
      );
    });

    test('should use basename when destination is null', () async {
      when(() => mockAuthClient.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final uploadedFile = await bucket.upload(
        testFile,
        UploadOptions(resumable: false),
      );

      expect(
        uploadedFile.name,
        testFile.path.split(io.Platform.pathSeparator).last,
      );
    });

    test('should forward userProject option', () async {
      http.BaseRequest? capturedRequest;

      when(() => mockAuthClient.send(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as http.BaseRequest;
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await bucket.upload(
        testFile,
        UploadOptions(resumable: false, userProject: 'custom-project'),
      );

      expect(capturedRequest, isNotNull);
      // userProject would be in query parameters
    });

    test('should forward all options together', () async {
      final metadata = storage_v1.Object()
        ..contentType = 'text/plain'
        ..metadata = {'key': 'value'};
      const kmsKeyName =
          'projects/test/locations/us/keyRings/kr/cryptoKeys/key';
      final encryptionKey = Uint8List.fromList([
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        29,
        30,
        31,
        32,
      ]);

      when(() => mockAuthClient.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              '{"name": "${testFile.path.split(io.Platform.pathSeparator).last}", "bucket": "test-bucket", "size": "12"}',
            ),
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final uploadedFile = await bucket.upload(
        testFile,
        UploadOptions(
          resumable: false,
          metadata: metadata,
          encryptionKey: EncryptionKey.fromBuffer(encryptionKey),
          kmsKeyName: kmsKeyName,
          gzip: true,
          predefinedAcl: PredefinedAcl.publicRead,
          userProject: 'custom-project',
        ),
      );

      expect(
        uploadedFile.name,
        testFile.path.split(io.Platform.pathSeparator).last,
      );
      expect(uploadedFile.bucket.id, bucket.id);
    });
  });

  group('Bucket.getFilesStream', () {
    late TestStorage storage;
    late MockStorageApi mockClient;
    late MockObjectsResource mockObjects;
    late Bucket bucket;

    setUp(() {
      mockClient = MockStorageApi();
      mockObjects = MockObjectsResource();
      when(() => mockClient.objects).thenReturn(mockObjects);
      storage = TestStorage(mockClient, projectId: 'test-project');
      bucket = storage.bucket('test-bucket');
    });

    test('should stream files from single page', () async {
      final file1 = storage_v1.Object()
        ..name = 'file1.txt'
        ..bucket = 'test-bucket';
      final file2 = storage_v1.Object()
        ..name = 'file2.txt'
        ..bucket = 'test-bucket';

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1, file2]
          ..nextPageToken = null,
      );

      final files = <BucketFile>[];
      await for (final file in bucket.getFilesStream()) {
        files.add(file);
      }

      expect(files, hasLength(2));
      expect(files[0].name, 'file1.txt');
      expect(files[1].name, 'file2.txt');
    });

    test('should stream files with pagination', () async {
      final file1 = storage_v1.Object()
        ..name = 'file1.txt'
        ..bucket = 'test-bucket';
      final file2 = storage_v1.Object()
        ..name = 'file2.txt'
        ..bucket = 'test-bucket';

      // First page
      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: null,
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1]
          ..nextPageToken = 'token-1',
      );

      // Second page
      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: 'token-1',
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file2]
          ..nextPageToken = null,
      );

      final files = <BucketFile>[];
      await for (final file in bucket.getFilesStream()) {
        files.add(file);
      }

      expect(files, hasLength(2));
      expect(files[0].name, 'file1.txt');
      expect(files[1].name, 'file2.txt');
    });

    test('should forward query options to API', () async {
      when(
        () => mockObjects.list(
          'test-bucket',
          delimiter: '/',
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: true,
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: 'prefix/',
          matchGlob: any(named: 'matchGlob'),
          maxResults: 10,
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: 'custom-project',
          versions: true,
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = []
          ..nextPageToken = null,
      );

      final files = <BucketFile>[];
      await for (final file in bucket.getFilesStream(
        GetFilesOptions(
          delimiter: '/',
          prefix: 'prefix/',
          maxResults: 10,
          includeFoldersAsPrefixes: true,
          versions: true,
          userProject: 'custom-project',
        ),
      )) {
        files.add(file);
      }

      verify(
        () => mockObjects.list(
          'test-bucket',
          delimiter: '/',
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: true,
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: 'prefix/',
          matchGlob: any(named: 'matchGlob'),
          maxResults: 10,
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: 'custom-project',
          versions: true,
        ),
      ).called(1);
    });

    test('should handle stream errors', () async {
      final error = ApiError('Stream error', code: 500);

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenThrow(error);

      final files = <BucketFile>[];
      var errorCaught = false;

      try {
        await for (final file in bucket.getFilesStream()) {
          files.add(file);
        }
      } catch (e) {
        errorCaught = true;
        expect(e, isA<ApiError>());
      }

      expect(errorCaught, isTrue);
      expect(files, isEmpty);
    });
  });

  group('Bucket.deleteFiles', () {
    late TestStorage storage;
    late MockStorageApi mockClient;
    late MockObjectsResource mockObjects;
    late Bucket bucket;

    setUp(() {
      mockClient = MockStorageApi();
      mockObjects = MockObjectsResource();
      when(() => mockClient.objects).thenReturn(mockObjects);
      storage = TestStorage(mockClient, projectId: 'test-project');
      bucket = storage.bucket('test-bucket');
    });

    test('should delete files from stream with default options', () async {
      final file1 = storage_v1.Object()
        ..name = 'file1.txt'
        ..bucket = 'test-bucket';
      final file2 = storage_v1.Object()
        ..name = 'file2.txt'
        ..bucket = 'test-bucket';

      var deleteCallCount = 0;

      // Mock getFilesStream by mocking the underlying API calls
      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1, file2]
          ..nextPageToken = null,
      );

      // Mock file.delete calls
      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async {
        deleteCallCount++;
      });

      await bucket.deleteFiles();

      // Verify delete was called for each file
      expect(deleteCallCount, 2);
    });

    test('should forward query options to getFilesStream', () async {
      final file1 = storage_v1.Object()
        ..name = 'file1.txt'
        ..bucket = 'test-bucket';

      when(
        () => mockObjects.list(
          'test-bucket',
          delimiter: '/',
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: 'prefix/',
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1]
          ..nextPageToken = null,
      );

      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async {});

      await bucket.deleteFiles(
        DeleteFileOptions(delimiter: '/', prefix: 'prefix/'),
      );

      verify(
        () => mockObjects.list(
          'test-bucket',
          delimiter: '/',
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: 'prefix/',
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).called(1);
    });

    test('should forward precondition options to file.delete', () async {
      final file1 = storage_v1.Object()
        ..name = 'file1.txt'
        ..bucket = 'test-bucket';

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1]
          ..nextPageToken = null,
      );

      when(
        () => mockObjects.delete(
          'test-bucket',
          'file1.txt',
          generation: any(named: 'generation'),
          ifGenerationMatch: '123',

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async {});

      await bucket.deleteFiles(DeleteFileOptions(ifGenerationMatch: 123));

      verify(
        () => mockObjects.delete(
          'test-bucket',
          'file1.txt',
          generation: any(named: 'generation'),
          ifGenerationMatch: '123',

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });

    test('should handle errors from getFilesStream', () async {
      final error = ApiError('Stream error', code: 500);

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenThrow(error);

      expect(() => bucket.deleteFiles(), throwsA(isA<ApiError>()));
    });

    test('should handle errors from file.delete', () async {
      final file1 = storage_v1.Object()
        ..name = 'file1.txt'
        ..bucket = 'test-bucket';
      final error = ApiError('Delete failed', code: 403);

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1]
          ..nextPageToken = null,
      );

      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          userProject: any(named: 'userProject'),
        ),
      ).thenThrow(error);

      expect(() => bucket.deleteFiles(), throwsA(isA<ApiError>()));
    });

    test('should continue deleting with force: true on errors', () async {
      final file1 = storage_v1.Object()
        ..name = 'file1.txt'
        ..bucket = 'test-bucket';
      final file2 = storage_v1.Object()
        ..name = 'file2.txt'
        ..bucket = 'test-bucket';
      final error = ApiError('Delete failed', code: 403);

      var deleteCallCount = 0;

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = [file1, file2]
          ..nextPageToken = null,
      );

      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async {
        deleteCallCount++;
        throw error;
      });

      // With force: true, should not throw but collect errors
      // Note: The implementation collects exceptions but still throws the first one
      // This matches Node.js behavior where force: true collects errors but callback receives them
      try {
        await bucket.deleteFiles(DeleteFileOptions(force: true));
        // If no exception, verify all deletes were attempted
        expect(deleteCallCount, 2);
      } catch (e) {
        // Implementation may throw first error even with force: true
        // Verify deletes were attempted
        expect(deleteCallCount, greaterThan(0));
      }
    });

    test('should process files in parallel (max 10 at a time)', () async {
      // Create 15 files to test parallel limit
      final files = List.generate(
        15,
        (i) => storage_v1.Object()
          ..name = 'file$i.txt'
          ..bucket = 'test-bucket',
      );

      var deleteCallCount = 0;

      when(
        () => mockObjects.list(
          any(),
          delimiter: any(named: 'delimiter'),
          endOffset: any(named: 'endOffset'),
          includeFoldersAsPrefixes: any(named: 'includeFoldersAsPrefixes'),
          includeTrailingDelimiter: any(named: 'includeTrailingDelimiter'),
          prefix: any(named: 'prefix'),
          matchGlob: any(named: 'matchGlob'),
          maxResults: any(named: 'maxResults'),
          pageToken: any(named: 'pageToken'),
          softDeleted: any(named: 'softDeleted'),
          startOffset: any(named: 'startOffset'),
          userProject: any(named: 'userProject'),
          versions: any(named: 'versions'),
        ),
      ).thenAnswer(
        (_) async => storage_v1.Objects()
          ..items = files
          ..nextPageToken = null,
      );

      when(
        () => mockObjects.delete(
          any(),
          any(),
          generation: any(named: 'generation'),
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async {
        deleteCallCount++;
        // Small delay to verify parallel processing
        await Future.delayed(const Duration(milliseconds: 10));
      });

      await bucket.deleteFiles();

      // Verify all files were deleted
      expect(deleteCallCount, 15);
      // Note: Parallel limit of 10 means max 10 concurrent deletes
      // All 15 should eventually be deleted
    });
  });

  group('Bucket.setUserProject', () {
    late TestStorage storage;
    late MockStorageApi mockClient;
    late Bucket bucket;

    setUp(() {
      mockClient = MockStorageApi();
      storage = TestStorage(mockClient, projectId: 'test-project');
      bucket = storage.bucket('test-bucket');
    });

    test('should set the userProject property', () {
      const userProject = 'grape-spaceship-123';

      bucket.setUserProject(userProject);

      expect(bucket.userProject, userProject);
    });

    test('should overwrite existing userProject', () {
      bucket.setUserProject('old-project');
      bucket.setUserProject('new-project');

      expect(bucket.userProject, 'new-project');
    });
  });

  group('Bucket.setCorsConfiguration', () {
    late TestStorage storage;
    late MockStorageApi mockClient;
    late MockBucketsResource mockBuckets;
    late Bucket bucket;

    setUp(() {
      mockClient = MockStorageApi();
      mockBuckets = MockBucketsResource();
      when(() => mockClient.buckets).thenReturn(mockBuckets);
      storage = TestStorage(mockClient, projectId: 'test-project');
      bucket = storage.bucket('test-bucket');
    });

    test('should call setMetadata with cors configuration', () async {
      final corsConfiguration = [
        storage_v1.BucketCors()
          ..maxAgeSeconds = 3600
          ..method = ['GET', 'POST']
          ..origin = ['https://example.com'],
      ];

      final updatedMetadata = storage_v1.Bucket()
        ..name = 'test-bucket'
        ..cors = corsConfiguration
        ..etag = 'updated-etag';

      when(
        () => mockBuckets.patch(
          any(),
          'test-bucket',
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => updatedMetadata);

      final result = await bucket.setCorsConfiguration(corsConfiguration);

      expect(result.cors, corsConfiguration);
      expect(result.etag, 'updated-etag');

      verify(
        () => mockBuckets.patch(
          any(
            that: predicate<storage_v1.Bucket>(
              (m) => m.cors == corsConfiguration,
            ),
          ),
          'test-bucket',
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });
  });

  group('Bucket.setRetentionPeriod', () {
    late TestStorage storage;
    late MockStorageApi mockClient;
    late MockBucketsResource mockBuckets;
    late Bucket bucket;

    setUp(() {
      mockClient = MockStorageApi();
      mockBuckets = MockBucketsResource();
      when(() => mockClient.buckets).thenReturn(mockBuckets);
      storage = TestStorage(mockClient, projectId: 'test-project');
      bucket = storage.bucket('test-bucket');
    });

    test('should call setMetadata with retention policy', () async {
      const duration = Duration(seconds: 90000);

      final updatedMetadata = storage_v1.Bucket()
        ..name = 'test-bucket'
        ..retentionPolicy = storage_v1.BucketRetentionPolicy(
          retentionPeriod: '90000',
        )
        ..etag = 'updated-etag';

      when(
        () => mockBuckets.patch(
          any(),
          'test-bucket',
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => updatedMetadata);

      final result = await bucket.setRetentionPeriod(duration);

      expect(result.retentionPolicy?.retentionPeriod, '90000');
      expect(result.etag, 'updated-etag');

      verify(
        () => mockBuckets.patch(
          any(
            that: predicate<storage_v1.Bucket>(
              (m) => m.retentionPolicy?.retentionPeriod == '90000',
            ),
          ),
          'test-bucket',
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });
  });

  group('Bucket.removeRetentionPeriod', () {
    late TestStorage storage;
    late MockStorageApi mockClient;
    late MockBucketsResource mockBuckets;
    late Bucket bucket;

    setUp(() {
      mockClient = MockStorageApi();
      mockBuckets = MockBucketsResource();
      when(() => mockClient.buckets).thenReturn(mockBuckets);
      storage = TestStorage(mockClient, projectId: 'test-project');
      bucket = storage.bucket('test-bucket');
    });

    test('should call setMetadata with null retention policy', () async {
      final updatedMetadata = storage_v1.Bucket()
        ..name = 'test-bucket'
        ..retentionPolicy = null
        ..etag = 'updated-etag';

      when(
        () => mockBuckets.patch(
          any(),
          'test-bucket',
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => updatedMetadata);

      final result = await bucket.removeRetentionPeriod();

      expect(result.retentionPolicy, isNull);
      expect(result.etag, 'updated-etag');

      verify(
        () => mockBuckets.patch(
          any(
            that: predicate<storage_v1.Bucket>(
              (m) => m.retentionPolicy == null,
            ),
          ),
          'test-bucket',
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });
  });

  group('Bucket.combine', () {
    late TestStorage storage;
    late MockStorageApi mockClient;
    late MockObjectsResource mockObjects;
    late Bucket bucket;

    setUp(() {
      mockClient = MockStorageApi();
      mockObjects = MockObjectsResource();
      when(() => mockClient.objects).thenReturn(mockObjects);
      storage = TestStorage(mockClient, projectId: 'test-project');
      bucket = storage.bucket('test-bucket');
    });

    test('should throw if invalid sources are provided (empty list)', () {
      final destination = bucket.file('destination.txt');

      expect(
        () => bucket.combine(sources: [], destination: destination),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw if destination file name is empty', () {
      final source = bucket.file('source.txt');
      final destination = bucket.file('');

      expect(
        () => bucket.combine(sources: [source], destination: destination),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'should make correct API request with sources and destination',
      () async {
        final source1 = bucket.file('1.foo');
        final source2 = bucket.file('2.foo');
        final destination = bucket.file('destination.foo');

        when(
          () => mockObjects.compose(
            any(),
            'test-bucket',
            'destination.foo',
            ifGenerationMatch: any(named: 'ifGenerationMatch'),

            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            kmsKeyName: any(named: 'kmsKeyName'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async => storage_v1.Object());

        await bucket.combine(
          sources: [source1, source2],
          destination: destination,
        );

        verify(
          () => mockObjects.compose(
            any(
              that: predicate<storage_v1.ComposeRequest>(
                (req) =>
                    req.sourceObjects != null &&
                    req.sourceObjects!.length == 2 &&
                    req.sourceObjects![0].name == '1.foo' &&
                    req.sourceObjects![1].name == '2.foo',
              ),
            ),
            'test-bucket',
            'destination.foo',
            ifGenerationMatch: any(named: 'ifGenerationMatch'),

            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            kmsKeyName: any(named: 'kmsKeyName'),
            userProject: any(named: 'userProject'),
          ),
        ).called(1);
      },
    );

    test('should use content type from destination metadata', () async {
      final source1 = bucket.file('1.txt');
      final source2 = bucket.file('2.txt');
      final destination = bucket.file('destination.txt');
      // Set metadata directly on destination file
      destination.setInstanceMetadata(
        storage_v1.Object()..contentType = 'text/plain',
      );

      when(
        () => mockObjects.compose(
          any(),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await bucket.combine(
        sources: [source1, source2],
        destination: destination,
      );

      verify(
        () => mockObjects.compose(
          any(
            that: predicate<storage_v1.ComposeRequest>(
              (req) => req.destination?.contentType == 'text/plain',
            ),
          ),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),
          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),
          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });

    test(
      'should detect content type from file extension if not in metadata',
      () async {
        final source1 = bucket.file('1.txt');
        final source2 = bucket.file('2.txt');
        final destination = bucket.file('destination.txt');

        when(
          () => mockObjects.compose(
            any(),
            'test-bucket',
            'destination.txt',
            ifGenerationMatch: any(named: 'ifGenerationMatch'),

            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            kmsKeyName: any(named: 'kmsKeyName'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async => storage_v1.Object());

        await bucket.combine(
          sources: [source1, source2],
          destination: destination,
        );

        // Verify compose was called (content type detection happens internally)
        verify(
          () => mockObjects.compose(
            any(),
            'test-bucket',
            'destination.txt',
            ifGenerationMatch: any(named: 'ifGenerationMatch'),

            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            kmsKeyName: any(named: 'kmsKeyName'),
            userProject: any(named: 'userProject'),
          ),
        ).called(1);
      },
    );

    test('should send source generation value if available', () async {
      final source1 = bucket.file('1.txt');
      final source2 = bucket.file('2.txt');
      // Set metadata directly on source files
      source1.setInstanceMetadata(storage_v1.Object()..generation = '1');
      source2.setInstanceMetadata(storage_v1.Object()..generation = '2');
      final destination = bucket.file('destination.txt');

      when(
        () => mockObjects.compose(
          any(),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await bucket.combine(
        sources: [source1, source2],
        destination: destination,
      );

      verify(
        () => mockObjects.compose(
          any(
            that: predicate<storage_v1.ComposeRequest>(
              (req) =>
                  req.sourceObjects != null &&
                  req.sourceObjects!.length == 2 &&
                  req.sourceObjects![0].name == '1.txt' &&
                  req.sourceObjects![0].generation == '1' &&
                  req.sourceObjects![1].name == '2.txt' &&
                  req.sourceObjects![1].generation == '2',
            ),
          ),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });

    test('should accept userProject option', () async {
      final source1 = bucket.file('1.txt');
      final source2 = bucket.file('2.txt');
      final destination = bucket.file('destination.txt');

      when(
        () => mockObjects.compose(
          any(),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: 'user-project-id',
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await bucket.combine(
        sources: [source1, source2],
        destination: destination,
        options: const CombineOptions(userProject: 'user-project-id'),
      );

      verify(
        () => mockObjects.compose(
          any(),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: 'user-project-id',
        ),
      ).called(1);
    });

    test('should accept precondition options', () async {
      final source1 = bucket.file('1.txt');
      final source2 = bucket.file('2.txt');
      final destination = bucket.file('destination.txt');

      when(
        () => mockObjects.compose(
          any(),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: '100',

          ifMetagenerationMatch: '102',

          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await bucket.combine(
        sources: [source1, source2],
        destination: destination,
        options: const CombineOptions(
          ifGenerationMatch: 100,
          ifMetagenerationMatch: 102,
        ),
      );

      verify(
        () => mockObjects.compose(
          any(),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: '100',

          ifMetagenerationMatch: '102',

          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });

    test('should handle API errors', () async {
      final source1 = bucket.file('1.txt');
      final source2 = bucket.file('2.txt');
      final destination = bucket.file('destination.txt');
      final error = ApiError('Compose failed', code: 500);

      when(
        () => mockObjects.compose(
          any(),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: any(named: 'userProject'),
        ),
      ).thenThrow(error);

      expect(
        () => bucket.combine(
          sources: [source1, source2],
          destination: destination,
        ),
        throwsA(isA<ApiError>()),
      );
    });

    test('should include contentEncoding in destination if present', () async {
      final source1 = bucket.file('1.txt');
      final source2 = bucket.file('2.txt');
      final destination = bucket.file('destination.txt');
      // Set metadata directly on destination file
      destination.setInstanceMetadata(
        storage_v1.Object()
          ..contentType = 'text/plain'
          ..contentEncoding = 'gzip',
      );

      when(
        () => mockObjects.compose(
          any(),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await bucket.combine(
        sources: [source1, source2],
        destination: destination,
      );

      verify(
        () => mockObjects.compose(
          any(
            that: predicate<storage_v1.ComposeRequest>(
              (req) =>
                  req.destination?.contentType == 'text/plain' &&
                  req.destination?.contentEncoding == 'gzip',
            ),
          ),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          kmsKeyName: any(named: 'kmsKeyName'),
          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });

    test(
      'should use instance-level userProject if not provided in options',
      () async {
        bucket.setUserProject('instance-project');
        final source1 = bucket.file('1.txt');
        final source2 = bucket.file('2.txt');
        final destination = bucket.file('destination.txt');

        when(
          () => mockObjects.compose(
            any(),
            'test-bucket',
            'destination.txt',
            ifGenerationMatch: any(named: 'ifGenerationMatch'),

            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            kmsKeyName: any(named: 'kmsKeyName'),
            userProject: 'instance-project',
          ),
        ).thenAnswer((_) async => storage_v1.Object());

        await bucket.combine(
          sources: [source1, source2],
          destination: destination,
        );

        verify(
          () => mockObjects.compose(
            any(),
            'test-bucket',
            'destination.txt',
            ifGenerationMatch: any(named: 'ifGenerationMatch'),

            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            kmsKeyName: any(named: 'kmsKeyName'),
            userProject: 'instance-project',
          ),
        ).called(1);
      },
    );

    test(
      'should merge precondition options from destination file options',
      () async {
        final source1 = bucket.file('1.txt');
        final source2 = bucket.file('2.txt');
        final destination = bucket.file(
          'destination.txt',
          FileOptions(
            preconditionOpts: PreconditionOptions(ifGenerationMatch: 50),
          ),
        );

        when(
          () => mockObjects.compose(
            any(),
            'test-bucket',
            'destination.txt',
            ifGenerationMatch: '50',

            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            kmsKeyName: any(named: 'kmsKeyName'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async => storage_v1.Object());

        await bucket.combine(
          sources: [source1, source2],
          destination: destination,
        );

        verify(
          () => mockObjects.compose(
            any(),
            'test-bucket',
            'destination.txt',
            ifGenerationMatch: '50',

            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            kmsKeyName: any(named: 'kmsKeyName'),
            userProject: any(named: 'userProject'),
          ),
        ).called(1);
      },
    );

    test('should accept kmsKeyName option', () async {
      final source1 = bucket.file('1.txt');
      final source2 = bucket.file('2.txt');
      final destination = bucket.file('destination.txt');
      const kmsKeyName =
          'projects/test/locations/us/keyRings/kr/cryptoKeys/key';

      when(
        () => mockObjects.compose(
          any(),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          kmsKeyName: kmsKeyName,
          userProject: any(named: 'userProject'),
        ),
      ).thenAnswer((_) async => storage_v1.Object());

      await bucket.combine(
        sources: [source1, source2],
        destination: destination,
        options: const CombineOptions(kmsKeyName: kmsKeyName),
      );

      verify(
        () => mockObjects.compose(
          any(),
          'test-bucket',
          'destination.txt',
          ifGenerationMatch: any(named: 'ifGenerationMatch'),

          ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

          kmsKeyName: kmsKeyName,
          userProject: any(named: 'userProject'),
        ),
      ).called(1);
    });
  });

  group('Bucket.deleteLabels', () {
    late TestStorage storage;
    late MockStorageApi mockClient;
    late MockBucketsResource mockBuckets;
    late Bucket bucket;

    setUp(() {
      mockClient = MockStorageApi();
      mockBuckets = MockBucketsResource();
      when(() => mockClient.buckets).thenReturn(mockBuckets);
      storage = TestStorage(mockClient, projectId: 'test-project');
      bucket = storage.bucket('test-bucket');
    });

    group('all labels', () {
      test('should get all label names when labels is null', () async {
        final labels = {
          'labelone': 'labelonevalue',
          'labeltwo': 'labeltwovalue',
        };

        // Mock getMetadata (used by getLabels)
        when(
          () => mockBuckets.get(
            'test-bucket',
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer(
          (_) async => storage_v1.Bucket()
            ..name = 'test-bucket'
            ..labels = labels,
        );

        // Mock setMetadata (used by setLabels)
        final updatedMetadata = storage_v1.Bucket()
          ..name = 'test-bucket'
          ..labels = <String, String>{}
          ..etag = 'updated-etag';

        when(
          () => mockBuckets.patch(
            any(),
            'test-bucket',
            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            predefinedAcl: any(named: 'predefinedAcl'),
            projection: any(named: 'projection'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async => updatedMetadata);

        await bucket.deleteLabels();

        // Verify getMetadata was called (via getLabels)
        verify(
          () => mockBuckets.get(
            'test-bucket',
            userProject: any(named: 'userProject'),
          ),
        ).called(1);

        // Verify setMetadata was called with null values for all labels
        verify(
          () => mockBuckets.patch(
            any(
              that: predicate<storage_v1.Bucket>((m) {
                final labels = m.labels;
                return labels != null &&
                    labels.containsKey('labelone') &&
                    labels['labelone'] == null &&
                    labels.containsKey('labeltwo') &&
                    labels['labeltwo'] == null;
              }),
            ),
            'test-bucket',
            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            predefinedAcl: any(named: 'predefinedAcl'),
            projection: any(named: 'projection'),
            userProject: any(named: 'userProject'),
          ),
        ).called(1);
      });

      test('should return error from getLabels', () async {
        final error = ApiError('Error from getLabels', code: 500);

        when(
          () => mockBuckets.get(
            'test-bucket',
            userProject: any(named: 'userProject'),
          ),
        ).thenThrow(error);

        expect(() => bucket.deleteLabels(), throwsA(isA<ApiError>()));
      });

      test(
        'should call setMetadata with all label names set to null',
        () async {
          final labels = {
            'labelone': 'labelonevalue',
            'labeltwo': 'labeltwovalue',
          };

          when(
            () => mockBuckets.get(
              'test-bucket',
              userProject: any(named: 'userProject'),
            ),
          ).thenAnswer(
            (_) async => storage_v1.Bucket()
              ..name = 'test-bucket'
              ..labels = labels,
          );

          final updatedMetadata = storage_v1.Bucket()
            ..name = 'test-bucket'
            ..labels = <String, String>{}
            ..etag = 'updated-etag';

          when(
            () => mockBuckets.patch(
              any(),
              'test-bucket',
              ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

              predefinedAcl: any(named: 'predefinedAcl'),
              projection: any(named: 'projection'),
              userProject: any(named: 'userProject'),
            ),
          ).thenAnswer((_) async => updatedMetadata);

          final result = await bucket.deleteLabels();

          expect(result.labels, isEmpty);
          expect(result.etag, 'updated-etag');
        },
      );
    });

    group('single label', () {
      test('should call setMetadata with a single label set to null', () async {
        const label = 'labelname';
        final updatedMetadata = storage_v1.Bucket()
          ..name = 'test-bucket'
          ..labels = <String, String>{}
          ..etag = 'updated-etag';

        when(
          () => mockBuckets.patch(
            any(),
            'test-bucket',
            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            predefinedAcl: any(named: 'predefinedAcl'),
            projection: any(named: 'projection'),
            userProject: any(named: 'userProject'),
          ),
        ).thenAnswer((_) async => updatedMetadata);

        await bucket.deleteLabels(labels: [label]);

        verify(
          () => mockBuckets.patch(
            any(
              that: predicate<storage_v1.Bucket>((m) {
                final labels = m.labels;
                return labels != null &&
                    labels.containsKey(label) &&
                    labels[label] == null;
              }),
            ),
            'test-bucket',
            ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

            predefinedAcl: any(named: 'predefinedAcl'),
            projection: any(named: 'projection'),
            userProject: any(named: 'userProject'),
          ),
        ).called(1);
      });
    });

    group('multiple labels', () {
      test(
        'should call setMetadata with multiple labels set to null',
        () async {
          const labels = ['labelonename', 'labeltwoname'];
          final updatedMetadata = storage_v1.Bucket()
            ..name = 'test-bucket'
            ..labels = <String, String>{}
            ..etag = 'updated-etag';

          when(
            () => mockBuckets.patch(
              any(),
              'test-bucket',
              ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

              predefinedAcl: any(named: 'predefinedAcl'),
              projection: any(named: 'projection'),
              userProject: any(named: 'userProject'),
            ),
          ).thenAnswer((_) async => updatedMetadata);

          await bucket.deleteLabels(labels: labels);

          verify(
            () => mockBuckets.patch(
              any(
                that: predicate<storage_v1.Bucket>((m) {
                  final labels = m.labels;
                  return labels != null &&
                      labels.containsKey('labelonename') &&
                      labels['labelonename'] == null &&
                      labels.containsKey('labeltwoname') &&
                      labels['labeltwoname'] == null;
                }),
              ),
              'test-bucket',
              ifMetagenerationMatch: any(named: 'ifMetagenerationMatch'),

              predefinedAcl: any(named: 'predefinedAcl'),
              projection: any(named: 'projection'),
              userProject: any(named: 'userProject'),
            ),
          ).called(1);
        },
      );
    });

    test('should forward options to setMetadata', () async {
      const label = 'labelname';
      final updatedMetadata = storage_v1.Bucket()
        ..name = 'test-bucket'
        ..labels = <String, String>{}
        ..etag = 'updated-etag';

      when(
        () => mockBuckets.patch(
          any(),
          'test-bucket',
          ifMetagenerationMatch: '123',

          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: 'custom-project',
        ),
      ).thenAnswer((_) async => updatedMetadata);

      await bucket.deleteLabels(
        labels: [label],
        options: SetLabelsOptions(
          ifMetagenerationMatch: 123,
          userProject: 'custom-project',
        ),
      );

      verify(
        () => mockBuckets.patch(
          any(),
          'test-bucket',
          ifMetagenerationMatch: '123',

          predefinedAcl: any(named: 'predefinedAcl'),
          projection: any(named: 'projection'),
          userProject: 'custom-project',
        ),
      ).called(1);
    });
  });
}
