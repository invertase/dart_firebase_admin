import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth_utils/src/extensions/auth_client_extensions.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mocks
class MockAuthClient extends Mock implements AuthClient {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeUri());
  });

  group('AuthClientX extension', () {
    late MockAuthClient mockAuthClient;

    setUp(() {
      mockAuthClient = MockAuthClient();
      // Reset singleton before each test
      ProjectIdProvider.instance = null;
    });

    tearDown(() {
      // Clean up singleton after each test
      ProjectIdProvider.instance = null;
    });

    group('getProjectId', () {
      test('delegates to ProjectIdProvider singleton', () async {
        final mockAuthClient2 = MockAuthClient();

        final projectId1 = await mockAuthClient.getProjectId(
          environment: {'GOOGLE_CLOUD_PROJECT': 'shared-project'},
        );

        // Second client should get the same cached value (singleton behavior)
        final projectId2 = await mockAuthClient2.getProjectId(
          environment: {'GOOGLE_CLOUD_PROJECT': 'different-project'},
        );

        expect(projectId1, 'shared-project');
        expect(projectId2, 'shared-project');
      });

      test('works with default Platform.environment', () async {
        // This test uses actual Platform.environment
        // It should either find a project ID or throw an exception
        try {
          final projectId = await mockAuthClient.getProjectId();
          // If successful, project ID should be a non-empty string
          expect(projectId, isNotEmpty);
        } catch (e) {
          // If no project ID found, should throw specific exception
          expect(e.toString(), contains('Failed to determine project ID'));
        }
      });
    });

    group('cachedProjectId', () {
      test('returns null when no project ID has been fetched', () {
        expect(mockAuthClient.cachedProjectId, isNull);
      });

      test('returns cached project ID after getProjectId call', () async {
        await mockAuthClient.getProjectId(
          environment: {'GOOGLE_CLOUD_PROJECT': 'test-project'},
        );

        expect(mockAuthClient.cachedProjectId, 'test-project');
      });

      test('returns null after cache is cleared', () async {
        await mockAuthClient.getProjectId(
          environment: {'GOOGLE_CLOUD_PROJECT': 'test-project'},
        );

        expect(mockAuthClient.cachedProjectId, 'test-project');

        ProjectIdProvider.instance?.clearCache();

        expect(mockAuthClient.cachedProjectId, isNull);
      });

      test('shares cached value across multiple clients', () async {
        final mockAuthClient2 = MockAuthClient();

        await mockAuthClient.getProjectId(
          environment: {'GOOGLE_CLOUD_PROJECT': 'shared-project'},
        );

        // Second client should see the same cached value
        expect(mockAuthClient2.cachedProjectId, 'shared-project');
      });
    });

    group('getServiceAccountEmail', () {
      test('delegates to ProjectIdProvider', () async {
        when(
          () => mockAuthClient.get(
            Uri.parse(
              'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
            ),
            headers: {'Metadata-Flavor': 'Google'},
          ),
        ).thenAnswer(
          (_) async =>
              http.Response('test-sa@project.iam.gserviceaccount.com', 200),
        );

        final email = await mockAuthClient.getServiceAccountEmail();

        expect(email, 'test-sa@project.iam.gserviceaccount.com');
        verify(
          () => mockAuthClient.get(
            Uri.parse(
              'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
            ),
            headers: {'Metadata-Flavor': 'Google'},
          ),
        ).called(1);
      });
    });

    group('integration tests', () {
      setUp(() {
        // Reset singleton for integration tests
        ProjectIdProvider.instance = null;
      });

      test('getProjectId and cachedProjectId work together', () async {
        final testClient = MockAuthClient();

        // First call getProjectId to initialize the singleton
        await testClient.getProjectId(
          environment: {'GOOGLE_CLOUD_PROJECT': 'integration-project'},
        );

        // Now cachedProjectId should return the cached value
        expect(testClient.cachedProjectId, 'integration-project');
      });

      test('multiple clients share ProjectIdProvider singleton', () async {
        final client1 = MockAuthClient();
        final client2 = MockAuthClient();

        await client1.getProjectId(
          environment: {'GOOGLE_CLOUD_PROJECT': 'shared-project'},
        );

        expect(client1.cachedProjectId, 'shared-project');
        expect(client2.cachedProjectId, 'shared-project');

        final projectId = await client2.getProjectId(
          environment: {'GOOGLE_CLOUD_PROJECT': 'different-project'},
        );

        // Should still return cached value from first call
        expect(projectId, 'shared-project');
      });

      test('getServiceAccountEmail is independent of project ID', () async {
        final testClient = MockAuthClient();

        when(
          () => testClient.get(
            Uri.parse(
              'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
            ),
            headers: {'Metadata-Flavor': 'Google'},
          ),
        ).thenAnswer(
          (_) async => http.Response('sa@project.iam.gserviceaccount.com', 200),
        );

        // Get project ID first to initialize singleton with correct environment
        await testClient.getProjectId(
          environment: {'GOOGLE_CLOUD_PROJECT': 'test-project'},
        );
        expect(testClient.cachedProjectId, 'test-project');

        // Service account email should work independently
        final email = await testClient.getServiceAccountEmail();
        expect(email, 'sa@project.iam.gserviceaccount.com');

        // Can call multiple times
        final email2 = await testClient.getServiceAccountEmail();
        expect(email2, 'sa@project.iam.gserviceaccount.com');
      });
    });
  });
}
