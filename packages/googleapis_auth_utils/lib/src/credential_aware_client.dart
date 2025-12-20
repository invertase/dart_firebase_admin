import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'credential.dart';

/// Associates [GoogleCredential]s with [AuthClient] instances.
///
/// This allows extension methods to access the original credentials used to
/// create an auth client, enabling features like local signing when service
/// account credentials with private keys are available.
///
/// The association is maintained via [Expando], which doesn't prevent garbage
/// collection of the auth client.
@internal
final authClientCredentials = Expando<GoogleCredential>(
  'AuthClient credentials',
);

/// Creates an authenticated HTTP client from a [GoogleCredential].
///
/// This function:
/// 1. Creates an AuthClient using googleapis_auth
/// 2. Associates it with the credential via [authClientCredentials] Expando
///
/// The returned client will automatically refresh access tokens as needed.
/// Extension methods like `sign()` can access the credential through the Expando.
///
/// Example:
/// ```dart
/// final credential = GoogleCredential.fromServiceAccount(
///   File('service-account.json'),
/// );
/// final client = await createAuthClient(credential, [
///   'https://www.googleapis.com/auth/cloud-platform',
/// ]);
///
/// // Use client for API calls
/// final response = await client.get(Uri.parse('https://...'));
///
/// // Sign data (extension method uses the associated credential)
/// final signature = await client.sign('data to sign');
///
/// // Don't forget to close when done
/// client.close();
/// ```
Future<AuthClient> createAuthClient(
  GoogleCredential? credential,
  List<String> scopes, {
  http.Client? baseClient,
}) async {
  // If no credential provided, use ADC
  final _credential =
      credential ?? GoogleCredential.fromApplicationDefaultCredentials();

  AuthClient client;

  if (_credential is GoogleServiceAccountCredential) {
    // Use service account credentials
    client = await clientViaServiceAccount(
      _credential.serviceAccountCredentials,
      scopes,
      baseClient: baseClient,
    );
  } else if (_credential is GoogleApplicationDefaultCredential) {
    // For ADC, check if we have service account credentials
    final serviceAccountCreds = _credential.serviceAccountCredentials;
    if (serviceAccountCreds != null) {
      client = await clientViaServiceAccount(
        serviceAccountCreds,
        scopes,
        baseClient: baseClient,
      );
    } else {
      // Fall back to regular ADC (will use metadata service on GCE/Cloud Run)
      client = await clientViaApplicationDefaultCredentials(
        scopes: scopes,
        baseClient: baseClient,
      );
    }
  } else {
    throw UnsupportedError(
      'Unknown credential type: ${_credential.runtimeType}',
    );
  }

  // Associate the credential with the auth client
  authClientCredentials[client] = _credential;

  return client;
}
