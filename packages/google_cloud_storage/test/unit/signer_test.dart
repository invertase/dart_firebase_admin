import 'package:google_cloud_storage/google_cloud_storage.dart';
import 'package:test/test.dart';

void main() {
  group('URLSigner', () {
    const bucketName = 'test-bucket';
    const fileName = 'test-file.txt';

    late Storage storage;
    late Bucket bucket;
    late BucketFile file;
    late URLSigner signer;

    setUp(() {
      storage = Storage(const StorageOptions(projectId: 'test-project'));
      bucket = storage.bucket(bucketName);
      file = bucket.file(fileName);
      signer = URLSigner.internal(bucket, file);
    });

    group('constructor', () {
      test('should set bucket', () {
        expect(signer.bucket, equals(bucket));
      });

      test('should set file', () {
        expect(signer.file, equals(file));
      });

      test('should work with null file for bucket-only URLs', () {
        final bucketOnlySigner = URLSigner.internal(bucket, null);
        expect(bucketOnlySigner.bucket, equals(bucket));
        expect(bucketOnlySigner.file, isNull);
      });
    });

    group('getSignedUrl validation', () {
      test('should throw when expiration is before accessibleAt', () {
        final accessibleAt = DateTime.now().add(const Duration(hours: 2));
        final invalidExpires = DateTime.now().add(const Duration(hours: 1));

        final config = SignedUrlConfig(
          method: SignedUrlMethod.get,
          expires: invalidExpires,
          accessibleAt: accessibleAt,
        );

        expect(
          () => signer.getSignedUrl(config),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Expiration must be >= accessibleAt'),
            ),
          ),
        );
      });

      test('should accept valid expiration after accessibleAt', () {
        final accessibleAt = DateTime.now();
        final validExpires = accessibleAt.add(const Duration(hours: 1));

        // Should not throw when creating a valid config
        final config = SignedUrlConfig(
          method: SignedUrlMethod.get,
          expires: validExpires,
          accessibleAt: accessibleAt,
        );

        expect(config.expires, validExpires);
        expect(config.accessibleAt, accessibleAt);
      });
    });

    group('SignedUrlMethod', () {
      test('should have correct string values', () {
        expect(SignedUrlMethod.get.value, 'GET');
        expect(SignedUrlMethod.put.value, 'PUT');
        expect(SignedUrlMethod.delete.value, 'DELETE');
        expect(SignedUrlMethod.post.value, 'POST');
      });

      test('should have all required methods', () {
        expect(SignedUrlMethod.values, hasLength(4));
        expect(SignedUrlMethod.values, contains(SignedUrlMethod.get));
        expect(SignedUrlMethod.values, contains(SignedUrlMethod.put));
        expect(SignedUrlMethod.values, contains(SignedUrlMethod.delete));
        expect(SignedUrlMethod.values, contains(SignedUrlMethod.post));
      });
    });

    group('SignedUrlVersion', () {
      test('should have v2 and v4 versions', () {
        expect(SignedUrlVersion.values, hasLength(2));
        expect(SignedUrlVersion.values, contains(SignedUrlVersion.v2));
        expect(SignedUrlVersion.values, contains(SignedUrlVersion.v4));
      });
    });

    group('SignedUrlConfig', () {
      late DateTime expires;

      setUp(() {
        expires = DateTime.now().add(const Duration(hours: 1));
      });

      test('should create with required parameters', () {
        final config = SignedUrlConfig(
          method: SignedUrlMethod.get,
          expires: expires,
        );

        expect(config.method, SignedUrlMethod.get);
        expect(config.expires, expires);
        expect(config.version, isNull); // defaults to null (will use v2)
        expect(config.accessibleAt, isNull);
        expect(config.virtualHostedStyle, isNull);
      });

      test('should accept all optional parameters', () {
        final accessibleAt = DateTime.now();
        final host = Uri.parse('https://custom.example.com');
        final signingEndpoint = Uri.parse('https://signing.example.com');

        final config = SignedUrlConfig(
          method: SignedUrlMethod.put,
          expires: expires,
          accessibleAt: accessibleAt,
          virtualHostedStyle: true,
          version: SignedUrlVersion.v4,
          cname: 'cdn.example.com',
          contentMd5: 'test-md5',
          contentType: 'image/png',
          extensionHeaders: {'x-goog-meta-foo': 'bar'},
          queryParams: {'response-content-type': 'text/plain'},
          host: host,
          signingEndpoint: signingEndpoint,
        );

        expect(config.method, SignedUrlMethod.put);
        expect(config.expires, expires);
        expect(config.accessibleAt, accessibleAt);
        expect(config.virtualHostedStyle, true);
        expect(config.version, SignedUrlVersion.v4);
        expect(config.cname, 'cdn.example.com');
        expect(config.contentMd5, 'test-md5');
        expect(config.contentType, 'image/png');
        expect(config.extensionHeaders, {'x-goog-meta-foo': 'bar'});
        expect(config.queryParams, {'response-content-type': 'text/plain'});
        expect(config.host, host);
        expect(config.signingEndpoint, signingEndpoint);
      });

      test('should handle different HTTP methods', () {
        for (final method in SignedUrlMethod.values) {
          final config = SignedUrlConfig(method: method, expires: expires);

          expect(config.method, method);
        }
      });

      test('should handle both version options', () {
        final v2Config = SignedUrlConfig(
          method: SignedUrlMethod.get,
          expires: expires,
          version: SignedUrlVersion.v2,
        );

        final v4Config = SignedUrlConfig(
          method: SignedUrlMethod.get,
          expires: expires,
          version: SignedUrlVersion.v4,
        );

        expect(v2Config.version, SignedUrlVersion.v2);
        expect(v4Config.version, SignedUrlVersion.v4);
      });

      test('should accept custom headers', () {
        final config = SignedUrlConfig(
          method: SignedUrlMethod.put,
          expires: expires,
          extensionHeaders: {
            'x-goog-meta-custom': 'value',
            'x-goog-acl': 'public-read',
          },
        );

        expect(config.extensionHeaders, isNotNull);
        expect(config.extensionHeaders!['x-goog-meta-custom'], 'value');
        expect(config.extensionHeaders!['x-goog-acl'], 'public-read');
      });

      test('should accept custom query parameters', () {
        final config = SignedUrlConfig(
          method: SignedUrlMethod.get,
          expires: expires,
          queryParams: {
            'response-content-disposition': 'attachment',
            'response-cache-control': 'no-cache',
          },
        );

        expect(config.queryParams, isNotNull);
        expect(
          config.queryParams!['response-content-disposition'],
          'attachment',
        );
        expect(config.queryParams!['response-cache-control'], 'no-cache');
      });
    });
  });
}
