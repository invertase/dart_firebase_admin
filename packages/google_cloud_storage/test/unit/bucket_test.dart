import 'package:google_cloud_storage/google_cloud_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockURLSigner extends Mock implements URLSigner {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SignedUrlConfig(method: SignedUrlMethod.get, expires: DateTime.now()),
    );
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
}
