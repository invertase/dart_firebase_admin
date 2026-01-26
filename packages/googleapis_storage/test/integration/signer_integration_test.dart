import 'dart:io';
import 'dart:async';
import 'package:googleapis_storage/googleapis_storage.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final credPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
  final testEnv = <String, String?>{'GOOGLE_APPLICATION_CREDENTIALS': credPath};

  group(
    'URLSigner integration tests',
    () {
      late Storage storage;
      const bucketName = 'dart-firebase-admin.firebasestorage.app';
      const fileName = 'test-file.txt';

      setUp(() {
        final credentials = GoogleCredential.fromServiceAccount(
          File(credPath!),
        );

        runZoned(() {
          storage = Storage(StorageOptions(credentials: credentials));
        }, zoneValues: {envSymbol: testEnv});
      });

      tearDown(() async {
        final client = await storage.authClient;
        client.close();
      });

      group('v2 signing', () {
        test('should generate valid v2 signed URL for GET', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
            version: SignedUrlVersion.v2,
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
          expect(url, contains('GoogleAccessId='));
          expect(url, contains('Expires='));
          expect(url, contains('Signature='));
          expect(url, contains(bucketName));
          expect(url, contains(fileName));
        });

        test('should generate valid v2 signed URL for PUT', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(minutes: 30));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.put,
            expires: expires,
            version: SignedUrlVersion.v2,
            contentType: 'text/plain',
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
          expect(url, contains('GoogleAccessId='));
          expect(url, contains('Expires='));
          expect(url, contains('Signature='));
        });

        test('should include extension headers in v2 signature', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
            version: SignedUrlVersion.v2,
            extensionHeaders: {'x-goog-meta-test': 'value'},
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
          expect(url, contains('GoogleAccessId='));
        });

        test('should generate v2 URL with query parameters', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
            version: SignedUrlVersion.v2,
            queryParams: {'response-content-type': 'application/json'},
          );

          final url = await signer.getSignedUrl(config);

          expect(url, contains('response-content-type='));
        });
      });

      group('v4 signing', () {
        test('should generate valid v4 signed URL for GET', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
            version: SignedUrlVersion.v4,
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
          expect(url, contains('X-Goog-Algorithm=GOOG4-RSA-SHA256'));
          expect(url, contains('X-Goog-Credential='));
          expect(url, contains('X-Goog-Date='));
          expect(url, contains('X-Goog-Expires='));
          expect(url, contains('X-Goog-SignedHeaders='));
          expect(url, contains('X-Goog-Signature='));
          expect(url, contains(bucketName));
          expect(url, contains(fileName));
        });

        test('should generate valid v4 signed URL for PUT', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(minutes: 30));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.put,
            expires: expires,
            version: SignedUrlVersion.v4,
            contentType: 'image/png',
          );

          final url = await signer.getSignedUrl(config);

          expect(url, contains('X-Goog-Algorithm=GOOG4-RSA-SHA256'));
          expect(url, contains('X-Goog-Credential='));
        });

        test('should handle accessibleAt in v4', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          // Use a time in the past to avoid timing issues
          final accessibleAt = DateTime.now().subtract(
            const Duration(minutes: 5),
          );
          final expires = DateTime.now().add(const Duration(hours: 2));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
            version: SignedUrlVersion.v4,
            accessibleAt: accessibleAt,
          );

          final url = await signer.getSignedUrl(config);

          expect(url, contains('X-Goog-Date='));
          // Verify the date format is correct (YYYYMMDDTHHMMSSZ)
          final dateMatch = RegExp(
            r'X-Goog-Date=(\d{8}T\d{6}Z)',
          ).firstMatch(url);
          expect(dateMatch, isNotNull);
        });

        test('should calculate expires duration correctly in v4', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 3));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
            version: SignedUrlVersion.v4,
          );

          final url = await signer.getSignedUrl(config);

          // Extract and verify expires value
          final expiresMatch = RegExp(r'X-Goog-Expires=(\d+)').firstMatch(url);
          expect(expiresMatch, isNotNull);

          final expiresSeconds = int.parse(expiresMatch!.group(1)!);
          // Should be approximately 3 hours (10800 seconds)
          expect(expiresSeconds, greaterThan(10700));
          expect(expiresSeconds, lessThan(10900));
        });

        test('should include query parameters in v4 URL', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
            version: SignedUrlVersion.v4,
            queryParams: {
              'response-content-disposition':
                  'attachment; filename="download.txt"',
            },
          );

          final url = await signer.getSignedUrl(config);

          expect(url, contains('response-content-disposition='));
        });
      });

      group('URL styles', () {
        test('should generate path-style URL by default', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
          );

          final url = await signer.getSignedUrl(config);

          expect(url, contains('/$bucketName/$fileName'));
        });

        test(
          'should generate virtual-hosted-style URL when specified',
          () async {
            final bucket = storage.bucket(bucketName);
            final file = bucket.file(fileName);
            final signer = URLSigner.internal(bucket, file);

            final expires = DateTime.now().add(const Duration(hours: 1));
            final config = SignedUrlConfig(
              method: SignedUrlMethod.get,
              expires: expires,
              virtualHostedStyle: true,
            );

            final url = await signer.getSignedUrl(config);

            expect(url, contains('$bucketName.storage.googleapis.com'));
          },
        );

        test('should use custom cname when provided', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
            cname: 'https://cdn.example.com',
          );

          final url = await signer.getSignedUrl(config);

          expect(url, startsWith('https://cdn.example.com'));
        });

        test('should use custom host when provided', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
            host: Uri.parse('https://custom-storage.example.com'),
          );

          final url = await signer.getSignedUrl(config);

          expect(url, startsWith('https://custom-storage.example.com'));
        });
      });

      group('HTTP methods', () {
        test('should generate signed URL for GET', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
        });

        test('should generate signed URL for PUT', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.put,
            expires: expires,
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
        });

        test('should generate signed URL for DELETE', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.delete,
            expires: expires,
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
        });

        test('should generate signed URL for POST', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.post,
            expires: expires,
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
        });
      });

      group('bucket-only URLs', () {
        test('should generate signed URL for bucket without file', () async {
          final bucket = storage.bucket(bucketName);
          final signer = URLSigner.internal(bucket, null);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.get,
            expires: expires,
          );

          final url = await signer.getSignedUrl(config);

          expect(url, contains(bucketName));
          expect(url, isNot(contains(fileName)));
        });
      });

      group('content options', () {
        test('should handle contentMd5', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.put,
            expires: expires,
            contentMd5: 'rL0Y20zC+Fzt72VPzMSk2A==',
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
        });

        test('should handle contentType', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.put,
            expires: expires,
            contentType: 'application/pdf',
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
        });

        test('should handle both contentMd5 and contentType', () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final signer = URLSigner.internal(bucket, file);

          final expires = DateTime.now().add(const Duration(hours: 1));
          final config = SignedUrlConfig(
            method: SignedUrlMethod.put,
            expires: expires,
            contentMd5: 'rL0Y20zC+Fzt72VPzMSk2A==',
            contentType: 'image/jpeg',
          );

          final url = await signer.getSignedUrl(config);

          expect(url, isNotEmpty);
        });
      });
    },
    skip: !hasGoogleEnv
        ? 'GOOGLE_APPLICATION_CREDENTIALS environment variable not set'
        : null,
  );
}
