import 'package:googleapis_storage/googleapis_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockURLSigner extends Mock implements URLSigner {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SignedUrlConfig(method: SignedUrlMethod.get, expires: DateTime.now()),
    );
  });

  group('File.getSignedUrl', () {
    late Storage storage;
    late Bucket bucket;
    late BucketFile file;
    late MockURLSigner mockSigner;
    final expires = DateTime(2026, 12, 31);
    const expectedSignedUrl = 'https://signed-url.example.com';

    setUp(() {
      storage = Storage(const StorageOptions(projectId: 'test-project'));
      bucket = storage.bucket('test-bucket');
      mockSigner = MockURLSigner();

      // Use internal constructor to inject the mock signer
      file = BucketFile.internal(
        bucket,
        'test-file.txt',
        null,
        mockSigner,
      );

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
}
