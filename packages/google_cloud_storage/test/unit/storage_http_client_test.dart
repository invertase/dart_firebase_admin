import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:google_cloud_storage/google_cloud_storage.dart';
import 'package:google_cloud_storage/src/internal/storage_http_client.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockClient extends Mock implements http.Client {}

class MockAuthClient extends Mock implements auth.AuthClient {}

class MockStorageApi extends Mock implements storage_v1.StorageApi {}

class FakeBaseRequest extends Fake implements http.BaseRequest {}

/// Test helper that creates a Storage instance with StorageHttpClient
/// wrapped in a MockAuthClient, allowing us to track which underlying client is used
class TestStorage extends Storage {
  final storage_v1.StorageApi mockClient;
  final http.Client mockWithAutoDecompress;
  final http.Client mockWithoutAutoDecompress;

  TestStorage(
    this.mockClient,
    this.mockWithAutoDecompress,
    this.mockWithoutAutoDecompress, {
    String? projectId,
    String? universeDomain,
    String? apiEndpoint,
  }) : super(
         StorageOptions(
           authClient: _createTrackingAuthClient(
             mockWithAutoDecompress,
             mockWithoutAutoDecompress,
             universeDomain: universeDomain,
             apiEndpoint: apiEndpoint,
           ),
           useAuthWithCustomEndpoint: true,
           projectId: projectId,
           universeDomain: universeDomain,
           apiEndpoint: apiEndpoint,
         ),
       );

  static Future<auth.AuthClient> _createTrackingAuthClient(
    http.Client withAutoDecompress,
    http.Client withoutAutoDecompress, {
    String? universeDomain,
    String? apiEndpoint,
  }) async {
    // Determine storage endpoint
    String? endpoint = apiEndpoint;
    if (endpoint == null && universeDomain != null) {
      endpoint = 'https://storage.$universeDomain';
    }

    final storageHttpClient = StorageHttpClient.forTesting(
      withAutoDecompress: withAutoDecompress,
      withoutAutoDecompress: withoutAutoDecompress,
      storageEndpoint: endpoint,
    );

    // Create a MockAuthClient and set it up to delegate to StorageHttpClient
    final mockAuthClient = MockAuthClient();
    when(() => mockAuthClient.send(any())).thenAnswer((invocation) {
      final request = invocation.positionalArguments[0] as http.BaseRequest;
      return storageHttpClient.send(request);
    });
    when(() => mockAuthClient.close()).thenAnswer((_) {
      storageHttpClient.close();
    });

    return mockAuthClient;
  }

  @override
  Future<storage_v1.StorageApi> get storageClient async => mockClient;
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBaseRequest());
  });

  group('Storage with StorageHttpClient routing', () {
    late MockStorageApi mockClient;
    late MockClient mockWithAutoDecompress;
    late MockClient mockWithoutAutoDecompress;
    late Storage storage;

    setUp(() {
      mockClient = MockStorageApi();
      mockWithAutoDecompress = MockClient();
      mockWithoutAutoDecompress = MockClient();
    });

    group('default storage.googleapis.com', () {
      setUp(() {
        storage = TestStorage(
          mockClient,
          mockWithAutoDecompress,
          mockWithoutAutoDecompress,
          projectId: 'test-project',
        );
      });

      test(
        'should route storage.googleapis.com to manual decompression client',
        () async {
          expect(storage.config.apiEndpoint, 'https://storage.googleapis.com');

          // Mock HTTP response - should use manual decompression client
          when(() => mockWithoutAutoDecompress.send(any())).thenAnswer((
            _,
          ) async {
            return http.StreamedResponse(Stream.value([]), 200);
          });

          // Directly call authClient.send() with a storage API request (no actual API call)
          final authClient = await storage.authClient;
          final request = http.Request(
            'GET',
            Uri.parse(
              'https://storage.googleapis.com/storage/v1/b/test-bucket/o/test-file',
            ),
          );
          await authClient.send(request);

          // Verify the correct client was used
          verify(() => mockWithoutAutoDecompress.send(any())).called(1);
          verifyNever(() => mockWithAutoDecompress.send(any()));
        },
      );
    });

    group('custom universeDomain', () {
      setUp(() {
        // Set up mocks BEFORE creating storage to ensure they're ready
        when(() => mockWithoutAutoDecompress.send(any())).thenAnswer((_) async {
          return http.StreamedResponse(Stream.value([]), 200);
        });
        when(() => mockWithAutoDecompress.send(any())).thenAnswer((_) async {
          return http.StreamedResponse(Stream.value([]), 200);
        });

        storage = TestStorage(
          mockClient,
          mockWithAutoDecompress,
          mockWithoutAutoDecompress,
          projectId: 'test-project',
          universeDomain: 'example.com',
        );
      });

      test(
        'should route custom universeDomain to manual decompression client',
        () async {
          expect(storage.config.apiEndpoint, 'https://storage.example.com');

          // Directly call authClient.send() with a storage API request
          final authClient = await storage.authClient;
          final request = http.Request(
            'GET',
            Uri.parse(
              'https://storage.example.com/storage/v1/b/test-bucket/o/test-file',
            ),
          );
          await authClient.send(request);

          // Should use mockWithoutAutoDecompress (manual decompression)
          verify(() => mockWithoutAutoDecompress.send(any())).called(1);
          verifyNever(() => mockWithAutoDecompress.send(any()));
        },
      );
    });

    group('custom apiEndpoint', () {
      setUp(() {
        // Set up mocks BEFORE creating storage to ensure they're ready
        when(() => mockWithoutAutoDecompress.send(any())).thenAnswer((_) async {
          return http.StreamedResponse(Stream.value([]), 200);
        });
        when(() => mockWithAutoDecompress.send(any())).thenAnswer((_) async {
          return http.StreamedResponse(Stream.value([]), 200);
        });

        storage = TestStorage(
          mockClient,
          mockWithAutoDecompress,
          mockWithoutAutoDecompress,
          projectId: 'test-project',
          apiEndpoint: 'https://custom-storage.example.com',
        );
      });

      test(
        'should route custom apiEndpoint to manual decompression client',
        () async {
          expect(
            storage.config.apiEndpoint,
            'https://custom-storage.example.com',
          );

          // Directly call authClient.send() with a storage API request
          final authClient = await storage.authClient;
          final request = http.Request(
            'GET',
            Uri.parse(
              'https://custom-storage.example.com/storage/v1/b/test-bucket/o/test-file',
            ),
          );
          await authClient.send(request);

          // Should use mockWithoutAutoDecompress (manual decompression)
          verify(() => mockWithoutAutoDecompress.send(any())).called(1);
          verifyNever(() => mockWithAutoDecompress.send(any()));
        },
      );
    });

    test(
      'should route non-storage requests to auto-decompression client',
      () async {
        // Set up mocks BEFORE creating storage
        when(() => mockWithAutoDecompress.send(any())).thenAnswer((_) async {
          return http.StreamedResponse(Stream.value([]), 200);
        });
        when(() => mockWithoutAutoDecompress.send(any())).thenAnswer((_) async {
          return http.StreamedResponse(Stream.value([]), 200);
        });

        storage = TestStorage(
          mockClient,
          mockWithAutoDecompress,
          mockWithoutAutoDecompress,
          projectId: 'test-project',
        );

        // Directly call authClient.send() with a non-storage request (e.g., OAuth)
        final authClient = await storage.authClient;
        final request = http.Request(
          'GET',
          Uri.parse('https://oauth2.googleapis.com/token'),
        );
        await authClient.send(request);

        // Should use mockWithAutoDecompress (auto decompression)
        verify(() => mockWithAutoDecompress.send(any())).called(1);
        verifyNever(() => mockWithoutAutoDecompress.send(any()));
      },
    );

    test('should handle case-insensitive hostname matching', () async {
      // Set up mocks BEFORE creating storage
      when(() => mockWithoutAutoDecompress.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(Stream.value([]), 200);
      });
      when(() => mockWithAutoDecompress.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(Stream.value([]), 200);
      });

      storage = TestStorage(
        mockClient,
        mockWithAutoDecompress,
        mockWithoutAutoDecompress,
        projectId: 'test-project',
        universeDomain: 'example.com',
      );

      // Test with uppercase hostname (should still route correctly)
      final authClient = await storage.authClient;
      final request = http.Request(
        'GET',
        Uri.parse(
          'https://STORAGE.EXAMPLE.COM/storage/v1/b/test-bucket/o/test-file',
        ),
      );
      await authClient.send(request);

      // This test will FAIL if case sensitivity is an issue
      verify(() => mockWithoutAutoDecompress.send(any())).called(1);
      verifyNever(() => mockWithAutoDecompress.send(any()));
    });

    test('should handle empty host after parsing', () {
      // Test that StorageHttpClient.create() handles empty/malformed endpoints gracefully
      final client = StorageHttpClient.create('');
      expect(client, isA<StorageHttpClient>());
      client.close();

      final client2 = StorageHttpClient.create('not-a-valid-url://');
      expect(client2, isA<StorageHttpClient>());
      client2.close();
    });
  });
}
