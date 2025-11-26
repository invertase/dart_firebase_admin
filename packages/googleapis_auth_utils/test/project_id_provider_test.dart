import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth_utils/src/extensions/auth_client_extensions.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mocks
class MockFileSystem extends Mock implements FileSystem {}

class MockProcessRunner extends Mock implements ProcessRunner {}

class MockMetadataClient extends Mock implements MetadataClient {}

class MockAuthClient extends Mock implements AuthClient {}

void main() {
  group('ProjectIdProvider', () {
    late MockFileSystem mockFileSystem;
    late MockProcessRunner mockProcessRunner;
    late MockMetadataClient mockMetadataClient;
    late MockAuthClient mockAuthClient;
    late Map<String, String> mockEnvironment;
    late ProjectIdProvider provider;

    setUp(() {
      mockFileSystem = MockFileSystem();
      mockProcessRunner = MockProcessRunner();
      mockMetadataClient = MockMetadataClient();
      mockAuthClient = MockAuthClient();
      mockEnvironment = {};

      provider = ProjectIdProvider(
        fileSystem: mockFileSystem,
        processRunner: mockProcessRunner,
        metadataClient: mockMetadataClient,
        environment: mockEnvironment,
      );

      // Reset singleton for each test
      ProjectIdProvider.instance = null;
    });

    tearDown(() {
      // Clean up singleton
      ProjectIdProvider.instance = null;
    });

    group('getProjectId', () {
      test('returns cached project ID on subsequent calls', () async {
        mockEnvironment['GOOGLE_CLOUD_PROJECT'] = 'test-project';

        final projectId1 = await provider.getProjectId();
        final projectId2 = await provider.getProjectId();

        expect(projectId1, 'test-project');
        expect(projectId2, 'test-project');
        expect(provider.cachedProjectId, 'test-project');
      });

      test('uses projectIdOverride when provided', () async {
        final projectId = await provider.getProjectId(
          projectIdOverride: 'override-project',
        );

        expect(projectId, 'override-project');
        expect(provider.cachedProjectId, 'override-project');
      });

      test('ignores empty projectIdOverride', () async {
        mockEnvironment['GOOGLE_CLOUD_PROJECT'] = 'env-project';

        final projectId = await provider.getProjectId(projectIdOverride: '');

        expect(projectId, 'env-project');
      });

      test('uses GOOGLE_CLOUD_PROJECT environment variable', () async {
        mockEnvironment['GOOGLE_CLOUD_PROJECT'] = 'gcp-project';

        final projectId = await provider.getProjectId();

        expect(projectId, 'gcp-project');
        expect(provider.cachedProjectId, 'gcp-project');
      });

      test('uses GCLOUD_PROJECT environment variable as fallback', () async {
        mockEnvironment['GCLOUD_PROJECT'] = 'gcloud-project';

        final projectId = await provider.getProjectId();

        expect(projectId, 'gcloud-project');
        expect(provider.cachedProjectId, 'gcloud-project');
      });

      test(
        'prefers GOOGLE_CLOUD_PROJECT over GCLOUD_PROJECT when both are set',
        () async {
          mockEnvironment['GOOGLE_CLOUD_PROJECT'] = 'gcp-project';
          mockEnvironment['GCLOUD_PROJECT'] = 'gcloud-project';

          final projectId = await provider.getProjectId();

          expect(projectId, 'gcp-project');
        },
      );

      test('ignores empty environment variables', () async {
        mockEnvironment['GOOGLE_CLOUD_PROJECT'] = '';
        mockEnvironment['GCLOUD_PROJECT'] = '';
        mockEnvironment['GOOGLE_APPLICATION_CREDENTIALS'] =
            '/path/to/creds.json';

        when(
          () => mockFileSystem.exists('/path/to/creds.json'),
        ).thenReturn(true);
        when(
          () => mockFileSystem.readAsString('/path/to/creds.json'),
        ).thenAnswer((_) async => jsonEncode({'project_id': 'creds-project'}));

        final projectId = await provider.getProjectId();

        expect(projectId, 'creds-project');
      });

      test(
        'reads project ID from GOOGLE_APPLICATION_CREDENTIALS file',
        () async {
          mockEnvironment['GOOGLE_APPLICATION_CREDENTIALS'] =
              '/path/to/creds.json';

          when(
            () => mockFileSystem.exists('/path/to/creds.json'),
          ).thenReturn(true);
          when(
            () => mockFileSystem.readAsString('/path/to/creds.json'),
          ).thenAnswer((_) async => jsonEncode({'project_id': 'file-project'}));

          final projectId = await provider.getProjectId();

          expect(projectId, 'file-project');
          expect(provider.cachedProjectId, 'file-project');
          verify(() => mockFileSystem.exists('/path/to/creds.json')).called(1);
          verify(
            () => mockFileSystem.readAsString('/path/to/creds.json'),
          ).called(1);
        },
      );

      test('skips credentials file if it does not exist', () async {
        mockEnvironment['GOOGLE_APPLICATION_CREDENTIALS'] =
            '/path/to/missing.json';

        when(
          () => mockFileSystem.exists('/path/to/missing.json'),
        ).thenReturn(false);
        when(() => mockProcessRunner.run('gcloud', any())).thenAnswer(
          (_) async => ProcessResult(
            0,
            0,
            jsonEncode({
              'configuration': {
                'properties': {
                  'core': {'project': 'gcloud-project'},
                },
              },
            }),
            '',
          ),
        );

        final projectId = await provider.getProjectId();

        expect(projectId, 'gcloud-project');
        verify(() => mockFileSystem.exists('/path/to/missing.json')).called(1);
        verifyNever(() => mockFileSystem.readAsString('/path/to/missing.json'));
      });

      test('skips credentials file if project_id is missing', () async {
        mockEnvironment['GOOGLE_APPLICATION_CREDENTIALS'] =
            '/path/to/creds.json';

        when(
          () => mockFileSystem.exists('/path/to/creds.json'),
        ).thenReturn(true);
        when(
          () => mockFileSystem.readAsString('/path/to/creds.json'),
        ).thenAnswer((_) async => jsonEncode({'type': 'service_account'}));
        when(() => mockProcessRunner.run('gcloud', any())).thenAnswer(
          (_) async => ProcessResult(
            0,
            0,
            jsonEncode({
              'configuration': {
                'properties': {
                  'core': {'project': 'gcloud-project'},
                },
              },
            }),
            '',
          ),
        );

        final projectId = await provider.getProjectId();

        expect(projectId, 'gcloud-project');
      });

      test('skips credentials file if project_id is empty', () async {
        mockEnvironment['GOOGLE_APPLICATION_CREDENTIALS'] =
            '/path/to/creds.json';

        when(
          () => mockFileSystem.exists('/path/to/creds.json'),
        ).thenReturn(true);
        when(
          () => mockFileSystem.readAsString('/path/to/creds.json'),
        ).thenAnswer((_) async => jsonEncode({'project_id': ''}));
        when(() => mockProcessRunner.run('gcloud', any())).thenAnswer(
          (_) async => ProcessResult(
            0,
            0,
            jsonEncode({
              'configuration': {
                'properties': {
                  'core': {'project': 'gcloud-project'},
                },
              },
            }),
            '',
          ),
        );

        final projectId = await provider.getProjectId();

        expect(projectId, 'gcloud-project');
      });

      test('handles JSON parsing errors in credentials file', () async {
        mockEnvironment['GOOGLE_APPLICATION_CREDENTIALS'] = '/path/to/bad.json';

        when(() => mockFileSystem.exists('/path/to/bad.json')).thenReturn(true);
        when(
          () => mockFileSystem.readAsString('/path/to/bad.json'),
        ).thenAnswer((_) async => 'not valid json');
        when(() => mockProcessRunner.run('gcloud', any())).thenAnswer(
          (_) async => ProcessResult(
            0,
            0,
            jsonEncode({
              'configuration': {
                'properties': {
                  'core': {'project': 'gcloud-project'},
                },
              },
            }),
            '',
          ),
        );

        final projectId = await provider.getProjectId();

        expect(projectId, 'gcloud-project');
      });

      test('reads project ID from gcloud config', () async {
        when(
          () => mockProcessRunner.run('gcloud', [
            'config',
            'config-helper',
            '--format',
            'json',
          ]),
        ).thenAnswer(
          (_) async => ProcessResult(
            0,
            0,
            jsonEncode({
              'configuration': {
                'properties': {
                  'core': {'project': 'gcloud-project'},
                },
              },
            }),
            '',
          ),
        );

        final projectId = await provider.getProjectId();

        expect(projectId, 'gcloud-project');
        expect(provider.cachedProjectId, 'gcloud-project');
        verify(
          () => mockProcessRunner.run('gcloud', [
            'config',
            'config-helper',
            '--format',
            'json',
          ]),
        ).called(1);
      });

      test('skips gcloud config if command fails', () async {
        when(
          () => mockProcessRunner.run('gcloud', any()),
        ).thenAnswer((_) async => ProcessResult(0, 1, '', 'Command not found'));
        when(() => mockMetadataClient.getProjectId()).thenAnswer(
          (_) async => const MetadataResponse(200, 'metadata-project'),
        );

        final projectId = await provider.getProjectId();

        expect(projectId, 'metadata-project');
      });

      test('handles malformed gcloud config response', () async {
        when(
          () => mockProcessRunner.run('gcloud', any()),
        ).thenAnswer((_) async => ProcessResult(0, 0, 'not json', ''));
        when(() => mockMetadataClient.getProjectId()).thenAnswer(
          (_) async => const MetadataResponse(200, 'metadata-project'),
        );

        final projectId = await provider.getProjectId();

        expect(projectId, 'metadata-project');
      });

      test('handles gcloud config with missing nested properties', () async {
        when(() => mockProcessRunner.run('gcloud', any())).thenAnswer(
          (_) async => ProcessResult(0, 0, jsonEncode({'other': 'data'}), ''),
        );
        when(() => mockMetadataClient.getProjectId()).thenAnswer(
          (_) async => const MetadataResponse(200, 'metadata-project'),
        );

        final projectId = await provider.getProjectId();

        expect(projectId, 'metadata-project');
      });

      test('handles gcloud exception', () async {
        when(
          () => mockProcessRunner.run('gcloud', any()),
        ).thenThrow(Exception('gcloud not found'));
        when(() => mockMetadataClient.getProjectId()).thenAnswer(
          (_) async => const MetadataResponse(200, 'metadata-project'),
        );

        final projectId = await provider.getProjectId();

        expect(projectId, 'metadata-project');
      });

      test('reads project ID from metadata service', () async {
        when(() => mockMetadataClient.getProjectId()).thenAnswer(
          (_) async => const MetadataResponse(200, 'metadata-project'),
        );

        final projectId = await provider.getProjectId();

        expect(projectId, 'metadata-project');
        expect(provider.cachedProjectId, 'metadata-project');
        verify(() => mockMetadataClient.getProjectId()).called(1);
      });

      test('skips metadata service if response is not 200', () async {
        when(
          () => mockMetadataClient.getProjectId(),
        ).thenAnswer((_) async => const MetadataResponse(404, 'Not Found'));

        expect(
          () => provider.getProjectId(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to determine project ID'),
            ),
          ),
        );
      });

      test('skips metadata service if response body is empty', () async {
        when(
          () => mockMetadataClient.getProjectId(),
        ).thenAnswer((_) async => const MetadataResponse(200, ''));

        expect(
          () => provider.getProjectId(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to determine project ID'),
            ),
          ),
        );
      });

      test('handles metadata service exception', () async {
        when(
          () => mockMetadataClient.getProjectId(),
        ).thenThrow(Exception('Network error'));

        expect(
          () => provider.getProjectId(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to determine project ID'),
            ),
          ),
        );
      });

      test('throws when no project ID can be determined', () async {
        expect(
          () => provider.getProjectId(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              allOf([
                contains('Failed to determine project ID'),
                contains('Initialize the SDK with service account credentials'),
                contains('set project ID as an app option'),
                contains('GOOGLE_CLOUD_PROJECT environment variable'),
              ]),
            ),
          ),
        );
      });

      test(
        'follows priority order: override > env > file > gcloud > metadata',
        () async {
          // Set up all sources
          mockEnvironment['GOOGLE_CLOUD_PROJECT'] = 'env-project';
          mockEnvironment['GOOGLE_APPLICATION_CREDENTIALS'] =
              '/path/to/creds.json';

          when(
            () => mockFileSystem.exists('/path/to/creds.json'),
          ).thenReturn(true);
          when(
            () => mockFileSystem.readAsString('/path/to/creds.json'),
          ).thenAnswer((_) async => jsonEncode({'project_id': 'file-project'}));
          when(() => mockProcessRunner.run('gcloud', any())).thenAnswer(
            (_) async => ProcessResult(
              0,
              0,
              jsonEncode({
                'configuration': {
                  'properties': {
                    'core': {'project': 'gcloud-project'},
                  },
                },
              }),
              '',
            ),
          );
          when(() => mockMetadataClient.getProjectId()).thenAnswer(
            (_) async => const MetadataResponse(200, 'metadata-project'),
          );

          // Override should win
          final projectId = await provider.getProjectId(
            projectIdOverride: 'override-project',
          );
          expect(projectId, 'override-project');

          // Reset cache and try without override - env should win
          provider.clearCache();
          final projectId2 = await provider.getProjectId();
          expect(projectId2, 'env-project');
          verifyNever(() => mockFileSystem.exists(any()));
          verifyNever(() => mockProcessRunner.run(any(), any()));
          verifyNever(() => mockMetadataClient.getProjectId());
        },
      );
    });

    group('clearCache', () {
      test('clears cached project ID', () async {
        mockEnvironment['GOOGLE_CLOUD_PROJECT'] = 'test-project';

        await provider.getProjectId();
        expect(provider.cachedProjectId, 'test-project');

        provider.clearCache();
        expect(provider.cachedProjectId, isNull);
      });

      test('allows fetching project ID again after clearing cache', () async {
        mockEnvironment['GOOGLE_CLOUD_PROJECT'] = 'project-1';

        final projectId1 = await provider.getProjectId();
        expect(projectId1, 'project-1');

        provider.clearCache();
        mockEnvironment['GOOGLE_CLOUD_PROJECT'] = 'project-2';

        final projectId2 = await provider.getProjectId();
        expect(projectId2, 'project-2');
      });
    });

    group('getServiceAccountEmail', () {
      test('returns email from metadata service', () async {
        when(() => mockMetadataClient.getServiceAccountEmail()).thenAnswer(
          (_) async => const MetadataResponse(
            200,
            'test-sa@project.iam.gserviceaccount.com',
          ),
        );

        final email = await provider.getServiceAccountEmail();

        expect(email, 'test-sa@project.iam.gserviceaccount.com');
        verify(() => mockMetadataClient.getServiceAccountEmail()).called(1);
      });

      test(
        'returns null when metadata service returns non-200 status',
        () async {
          when(
            () => mockMetadataClient.getServiceAccountEmail(),
          ).thenAnswer((_) async => const MetadataResponse(404, 'Not Found'));

          final email = await provider.getServiceAccountEmail();

          expect(email, isNull);
        },
      );

      test('returns null when response body is empty', () async {
        when(
          () => mockMetadataClient.getServiceAccountEmail(),
        ).thenAnswer((_) async => const MetadataResponse(200, ''));

        final email = await provider.getServiceAccountEmail();

        expect(email, isNull);
      });

      test('returns null when metadata service throws exception', () async {
        when(
          () => mockMetadataClient.getServiceAccountEmail(),
        ).thenThrow(Exception('Network error'));

        final email = await provider.getServiceAccountEmail();

        expect(email, isNull);
      });

      test('can be called multiple times independently', () async {
        when(() => mockMetadataClient.getServiceAccountEmail()).thenAnswer(
          (_) async =>
              const MetadataResponse(200, 'sa@project.iam.gserviceaccount.com'),
        );

        final email1 = await provider.getServiceAccountEmail();
        final email2 = await provider.getServiceAccountEmail();

        expect(email1, 'sa@project.iam.gserviceaccount.com');
        expect(email2, 'sa@project.iam.gserviceaccount.com');
        verify(() => mockMetadataClient.getServiceAccountEmail()).called(2);
      });

      test('is independent of project ID lookup', () async {
        when(() => mockMetadataClient.getServiceAccountEmail()).thenAnswer(
          (_) async =>
              const MetadataResponse(200, 'sa@project.iam.gserviceaccount.com'),
        );

        // Get service account email without getting project ID first
        final email = await provider.getServiceAccountEmail();
        expect(email, 'sa@project.iam.gserviceaccount.com');
        expect(provider.cachedProjectId, isNull);

        // Get project ID
        mockEnvironment['GOOGLE_CLOUD_PROJECT'] = 'test-project';
        await provider.getProjectId();
        expect(provider.cachedProjectId, 'test-project');

        // Service account email should still work
        final email2 = await provider.getServiceAccountEmail();
        expect(email2, 'sa@project.iam.gserviceaccount.com');
      });
    });

    group('getDefault', () {
      test('returns singleton instance', () {
        final provider1 = ProjectIdProvider.getDefault(mockAuthClient);
        final provider2 = ProjectIdProvider.getDefault(mockAuthClient);

        expect(identical(provider1, provider2), isTrue);
        expect(ProjectIdProvider.instance, isNotNull);
      });

      test('uses Platform.environment by default', () {
        final provider = ProjectIdProvider.getDefault(mockAuthClient);

        expect(provider, isNotNull);
      });

      test('accepts custom environment map', () {
        final customEnv = {'CUSTOM_VAR': 'value'};
        final provider = ProjectIdProvider.getDefault(
          mockAuthClient,
          environment: customEnv,
        );

        expect(provider, isNotNull);
      });
    });

    group('MetadataClient', () {
      test('getProjectId makes correct request to metadata service', () async {
        final mockClient = MockAuthClient();
        final metadataClient = MetadataClient(mockClient);

        when(
          () => mockClient.get(
            Uri.parse(
              'http://metadata.google.internal/computeMetadata/v1/project/project-id',
            ),
            headers: {'Metadata-Flavor': 'Google'},
          ),
        ).thenAnswer((_) async => http.Response('test-project', 200));

        final response = await metadataClient.getProjectId();

        expect(response.statusCode, 200);
        expect(response.body, 'test-project');
        verify(
          () => mockClient.get(
            Uri.parse(
              'http://metadata.google.internal/computeMetadata/v1/project/project-id',
            ),
            headers: {'Metadata-Flavor': 'Google'},
          ),
        ).called(1);
      });

      test(
        'getServiceAccountEmail makes correct request to metadata service',
        () async {
          final mockClient = MockAuthClient();
          final metadataClient = MetadataClient(mockClient);

          when(
            () => mockClient.get(
              Uri.parse(
                'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
              ),
              headers: {'Metadata-Flavor': 'Google'},
            ),
          ).thenAnswer(
            (_) async =>
                http.Response('test-sa@project.iam.gserviceaccount.com', 200),
          );

          final response = await metadataClient.getServiceAccountEmail();

          expect(response.statusCode, 200);
          expect(response.body, 'test-sa@project.iam.gserviceaccount.com');
          verify(
            () => mockClient.get(
              Uri.parse(
                'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
              ),
              headers: {'Metadata-Flavor': 'Google'},
            ),
          ).called(1);
        },
      );

      test('getServiceAccountEmail returns correct response on error', () async {
        final mockClient = MockAuthClient();
        final metadataClient = MetadataClient(mockClient);

        when(
          () => mockClient.get(
            Uri.parse(
              'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
            ),
            headers: {'Metadata-Flavor': 'Google'},
          ),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        final response = await metadataClient.getServiceAccountEmail();

        expect(response.statusCode, 404);
        expect(response.body, 'Not Found');
      });
    });
  });
}
