import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mocks
class MockAuthClient extends Mock implements AuthClient {}

class FakeUri extends Fake implements Uri {}

class FakeBaseRequest extends Fake implements http.BaseRequest {}

// Mock HTTP client for intercepting OAuth token requests
class MockOAuthHttpClient extends Mock implements http.Client {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Mock OAuth token request
    if (request.url.toString().contains('oauth2.googleapis.com/token')) {
      return http.StreamedResponse(
        Stream.value(
          utf8.encode(
            jsonEncode({
              'access_token': 'mock_access_token',
              'expires_in': 3600,
              'token_type': 'Bearer',
            }),
          ),
        ),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    // Return 404 for any other request
    return http.StreamedResponse(Stream.value([]), 404);
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue(<String, String>{});
    registerFallbackValue(FakeBaseRequest());
  });

  group('sign()', () {
    const testData = 'abc123';
    const signedBlob = 'erutangis'; // "signature" reversed
    final signedBlobBase64 = base64Encode(utf8.encode(signedBlob));

    group('with ServiceAccountCredentials (local signing)', () {
      test('should sign using the private key', () async {
        // Load service account credentials from fixture
        final file = File('test/fixtures/service_account.json');
        final credential = GoogleCredential.fromServiceAccount(file);

        // Create a mock HTTP client to intercept OAuth token requests
        final mockHttp = MockOAuthHttpClient();

        // Create auth client with associated credential
        final client = await createAuthClient(credential, [
          'https://www.googleapis.com/auth/cloud-platform',
        ], baseClient: mockHttp);

        // Sign data
        final signature = await client.sign(testData);

        // Verify signature is base64-encoded and not empty
        expect(signature, isNotEmpty);
        final decodedSignature = base64Decode(signature);
        expect(decodedSignature.length, greaterThan(0));
      });

      test('should not use custom endpoint for local signing', () async {
        final file = File('test/fixtures/service_account.json');
        final credential = GoogleCredential.fromServiceAccount(file);

        // Create a mock HTTP client to intercept OAuth token requests
        final mockHttp = MockOAuthHttpClient();

        // Create auth client with associated credential
        final client = await createAuthClient(credential, [
          'https://www.googleapis.com/auth/cloud-platform',
        ], baseClient: mockHttp);

        // Sign with custom endpoint - should ignore it and use local signing
        final signature = await client.sign(
          testData,
          endpoint: 'https://custom.endpoint.com',
        );

        expect(signature, isNotEmpty);
      });
    });

    group('with ImpersonatedAuthClient', () {
      test('should use IAM signBlob endpoint with target principal', () async {
        final mockSourceClient = MockAuthClient();

        // Mock credentials
        when(() => mockSourceClient.credentials).thenReturn(
          AccessCredentials(
            AccessToken('Bearer', 'test-token', DateTime.now().toUtc()),
            null,
            ['https://www.googleapis.com/auth/cloud-platform'],
          ),
        );

        // Setup impersonated client
        const targetPrincipal = 'target@project.iam.gserviceaccount.com';
        final impersonated = ImpersonatedAuthClient(
          ImpersonatedOptions(
            sourceClient: mockSourceClient,
            targetPrincipal: targetPrincipal,
          ),
        );

        // Mock the HTTP POST request to IAM API
        final signBlobUrl = Uri.parse(
          'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$targetPrincipal:signBlob',
        );

        when(
          () => mockSourceClient.post(
            signBlobUrl,
            headers: {'Content-Type': 'application/json'},
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'keyId': 'key123', 'signedBlob': signedBlob}),
            200,
          ),
        );

        // Sign data
        final signature = await impersonated.sign(testData);

        expect(signature.signedBlob, signedBlob);
        expect(signature.keyId, 'key123');

        // Verify the request was made with correct payload
        verify(
          () => mockSourceClient.post(
            signBlobUrl,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'payload': base64Encode(utf8.encode(testData))}),
          ),
        ).called(1);
      });

      test(
        'should use sign() extension method on ImpersonatedAuthClient',
        () async {
          final mockSourceClient = MockAuthClient();

          when(() => mockSourceClient.credentials).thenReturn(
            AccessCredentials(
              AccessToken('Bearer', 'test-token', DateTime.now().toUtc()),
              null,
              ['https://www.googleapis.com/auth/cloud-platform'],
            ),
          );

          const targetPrincipal = 'target@project.iam.gserviceaccount.com';
          final impersonated = ImpersonatedAuthClient(
            ImpersonatedOptions(
              sourceClient: mockSourceClient,
              targetPrincipal: targetPrincipal,
            ),
          );

          final signBlobUrl = Uri.parse(
            'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$targetPrincipal:signBlob',
          );

          when(
            () => mockSourceClient.post(
              signBlobUrl,
              headers: {'Content-Type': 'application/json'},
              body: any(named: 'body'),
            ),
          ).thenAnswer(
            (_) async => http.Response(
              jsonEncode({'keyId': 'key123', 'signedBlob': signedBlob}),
              200,
            ),
          );

          // Cast to AuthClient to use the extension method
          final AuthClient client = impersonated;
          final signature = await client.sign(testData);

          // The extension method should detect it's an ImpersonatedAuthClient
          // and return just the signedBlob string
          expect(signature, signedBlob);
        },
      );

      test('should use custom endpoint when provided', () async {
        final mockSourceClient = MockAuthClient();

        when(() => mockSourceClient.credentials).thenReturn(
          AccessCredentials(
            AccessToken('Bearer', 'test-token', DateTime.now().toUtc()),
            null,
            ['https://www.googleapis.com/auth/cloud-platform'],
          ),
        );

        const targetPrincipal = 'target@project.iam.gserviceaccount.com';
        const customEndpoint = 'https://custom.iamcredentials.googleapis.com';
        final impersonated = ImpersonatedAuthClient(
          ImpersonatedOptions(
            sourceClient: mockSourceClient,
            targetPrincipal: targetPrincipal,
            endpoint: customEndpoint,
          ),
        );

        final signBlobUrl = Uri.parse(
          '$customEndpoint/v1/projects/-/serviceAccounts/$targetPrincipal:signBlob',
        );

        when(
          () => mockSourceClient.post(
            signBlobUrl,
            headers: {'Content-Type': 'application/json'},
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'keyId': 'key123', 'signedBlob': signedBlob}),
            200,
          ),
        );

        // Cast to AuthClient to use the extension method
        final AuthClient client = impersonated;
        final signature = await client.sign(testData);

        expect(signature, signedBlob);

        // Verify custom endpoint was used
        verify(
          () => mockSourceClient.post(
            signBlobUrl,
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).called(1);
      });
    });

    group('with other AuthClient (IAM API signing)', () {
      test(
        'should use IAM signBlob API when custom endpoint is provided',
        () async {
          final mockClient = MockAuthClient();
          const serviceAccountEmail = 'test@project.iam.gserviceaccount.com';
          const customEndpoint = 'https://iamcredentials.googleapis.com';

          // Mock getting service account email from metadata
          when(
            () => mockClient.get(
              Uri.parse(
                'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
              ),
              headers: {'Metadata-Flavor': 'Google'},
            ),
          ).thenAnswer((_) async => http.Response(serviceAccountEmail, 200));

          // Mock the IAM signBlob API call via send()
          when(() => mockClient.send(any())).thenAnswer((invocation) async {
            final request =
                invocation.positionalArguments[0] as http.BaseRequest;
            if (request.url.path.contains(':signBlob')) {
              return http.StreamedResponse(
                Stream.value(
                  utf8.encode(jsonEncode({'signedBlob': signedBlobBase64})),
                ),
                200,
                headers: {'content-type': 'application/json'},
              );
            }
            return http.StreamedResponse(Stream.value([]), 404);
          });

          // Sign data with custom endpoint
          final signature = await mockClient.sign(
            testData,
            endpoint: customEndpoint,
          );

          expect(signature, signedBlobBase64);

          // Verify IAM API was called via send()
          verify(() => mockClient.send(any())).called(greaterThan(0));
        },
      );

      test('should use custom endpoint for IAM API signing', () async {
        final mockClient = MockAuthClient();
        const serviceAccountEmail = 'test@project.iam.gserviceaccount.com';
        const customEndpoint = 'https://custom.iamcredentials.googleapis.com';

        when(
          () => mockClient.get(
            Uri.parse(
              'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
            ),
            headers: {'Metadata-Flavor': 'Google'},
          ),
        ).thenAnswer((_) async => http.Response(serviceAccountEmail, 200));

        // Mock the IAM signBlob API call via send()
        when(() => mockClient.send(any())).thenAnswer((invocation) async {
          final request = invocation.positionalArguments[0] as http.BaseRequest;
          if (request.url.toString().contains(customEndpoint) &&
              request.url.path.contains(':signBlob')) {
            return http.StreamedResponse(
              Stream.value(
                utf8.encode(jsonEncode({'signedBlob': signedBlobBase64})),
              ),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.StreamedResponse(Stream.value([]), 404);
        });

        final signature = await mockClient.sign(
          testData,
          endpoint: customEndpoint,
        );

        expect(signature, signedBlobBase64);

        // Verify custom endpoint was used
        final captured = verify(() => mockClient.send(captureAny())).captured;
        expect(captured.isNotEmpty, true);
        final capturedRequest = captured.first as http.BaseRequest;
        expect(capturedRequest.url.toString(), contains(customEndpoint));
      });

      test('should throw when service account email is not available', () async {
        final mockClient = MockAuthClient();

        // Mock the get request for service account email to return empty/null
        when(
          () => mockClient.get(
            Uri.parse(
              'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
            ),
            headers: {'Metadata-Flavor': 'Google'},
          ),
        ).thenAnswer((_) async => http.Response('', 404));

        // Mock send() to avoid null errors (though it shouldn't be reached)
        when(() => mockClient.send(any())).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'error': 'not found'}))),
            404,
          ),
        );

        // Sign with custom endpoint should fail
        await expectLater(
          mockClient.sign(testData, endpoint: 'https://custom.com'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('integration tests', () {
      test('signature format is base64-encoded', () async {
        final file = File('test/fixtures/service_account.json');
        final credential = GoogleCredential.fromServiceAccount(file);

        // Create a mock HTTP client to intercept OAuth token requests
        final mockHttp = MockOAuthHttpClient();

        // Create auth client with associated credential
        final client = await createAuthClient(credential, [
          'https://www.googleapis.com/auth/cloud-platform',
        ], baseClient: mockHttp);

        final signature = await client.sign(testData);

        // Should be valid base64
        expect(() => base64Decode(signature), returnsNormally);

        // Should not be empty
        final decoded = base64Decode(signature);
        expect(decoded.length, greaterThan(0));
      });

      test('same data produces same signature', () async {
        final file = File('test/fixtures/service_account.json');
        final credential = GoogleCredential.fromServiceAccount(file);

        // Create a mock HTTP client to intercept OAuth token requests
        final mockHttp = MockOAuthHttpClient();

        // Create auth client with associated credential
        final client = await createAuthClient(credential, [
          'https://www.googleapis.com/auth/cloud-platform',
        ], baseClient: mockHttp);

        final signature1 = await client.sign(testData);
        final signature2 = await client.sign(testData);

        // RSA signatures with PKCS#1 v1.5 padding are deterministic
        // (same input always produces same output with same key)
        expect(signature1, signature2);
      });
    });
  });
}
