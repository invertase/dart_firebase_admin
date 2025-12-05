import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:googleapis/iamcredentials/v1.dart' as iam_credentials_v1;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:pem/pem.dart';
import 'package:pointycastle/export.dart' as pointy;

import 'credential_aware_client.dart';

/// Signs data using either local private key or IAM API.
///
/// This is adapted from dart_firebase_admin's CryptoSigner to work with
/// AuthClient instead of FirebaseApp.
abstract class CryptoSigner {
  /// Creates a CryptoSigner from an AuthClient.
  ///
  /// If [authClient] was created via [createAuthClient] with service account
  /// credentials, uses local signing. Otherwise, uses IAM API signing.
  ///
  /// [serviceAccountEmail] is only used for IAM API signing when the auth
  /// client doesn't have service account credentials.
  /// [endpoint] is an optional custom IAM Credentials API endpoint for universe
  /// domain support. Defaults to `https://iamcredentials.googleapis.com/`.
  static CryptoSigner fromAuthClient(
    auth.AuthClient authClient, {
    String? serviceAccountEmail,
    String? endpoint,
  }) {
    // Check if credentials are associated with this auth client via Expando
    final credential = authClientCredentials[authClient];
    final serviceAccountCreds = credential?.serviceAccountCredentials;

    if (serviceAccountCreds != null) {
      return ServiceAccountSigner(serviceAccountCreds);
    }

    // Fall back to IAM API signing
    return IAMSigner(
      authClient,
      serviceAccountEmail: serviceAccountEmail,
      endpoint: endpoint,
    );
  }

  /// The name of the signing algorithm.
  String get algorithm;

  /// Cryptographically signs a buffer of data.
  Future<Uint8List> sign(Uint8List buffer);

  /// Returns the ID of the service account used to sign tokens.
  Future<String> getAccountId();
}

/// IAM API-based signer.
class IAMSigner implements CryptoSigner {
  /// Creates an IAMSigner with an AuthClient.
  IAMSigner(
    auth.AuthClient authClient, {
    String? serviceAccountEmail,
    String? endpoint,
  }) : _authClientFuture = Future.value(authClient),
       _serviceAccountEmail = serviceAccountEmail,
       _endpoint = endpoint;

  /// Creates an IAMSigner with a Future<AuthClient> (for lazy initialization).
  IAMSigner.lazy(
    Future<auth.AuthClient> authClient, {
    String? serviceAccountEmail,
    String? endpoint,
  }) : _authClientFuture = authClient,
       _serviceAccountEmail = serviceAccountEmail,
       _endpoint = endpoint;

  @override
  String get algorithm => 'RS256';

  final Future<auth.AuthClient> _authClientFuture;
  auth.AuthClient? _authClient;
  String? _serviceAccountEmail;
  final String? _endpoint;

  /// Gets the resolved AuthClient, caching it after first resolution.
  Future<auth.AuthClient> get _client async {
    return _authClient ??= await _authClientFuture;
  }

  @override
  Future<String> getAccountId() async {
    if (_serviceAccountEmail != null && _serviceAccountEmail!.isNotEmpty) {
      return _serviceAccountEmail!;
    }

    // Try to get from metadata server
    try {
      final response = await http.get(
        Uri.parse(
          'http://metadata/computeMetadata/v1/instance/service-accounts/default/email',
        ),
        headers: {'Metadata-Flavor': 'Google'},
      );

      if (response.statusCode == 200) {
        return _serviceAccountEmail = response.body;
      }
    } catch (_) {
      // Fall through to error
    }

    throw CryptoSignerException(
      CryptoSignerErrorCode.invalidCredential,
      'Failed to determine service account. Make sure to provide '
      'serviceAccountEmail parameter or run on GCE/Cloud Run with a default service account.',
    );
  }

  @override
  Future<Uint8List> sign(Uint8List buffer) async {
    final serviceAccount = await getAccountId();
    final client = await _client;

    try {
      final api = _endpoint != null
          ? iam_credentials_v1.IAMCredentialsApi(
              client,
              rootUrl: _endpoint.endsWith('/') ? _endpoint : '$_endpoint/',
            )
          : iam_credentials_v1.IAMCredentialsApi(client);

      final response = await api.projects.serviceAccounts.signBlob(
        iam_credentials_v1.SignBlobRequest(payload: base64Encode(buffer)),
        'projects/-/serviceAccounts/$serviceAccount',
      );

      if (response.signedBlob == null) {
        throw CryptoSignerException(
          CryptoSignerErrorCode.serverError,
          'IAM API response missing signedBlob field',
        );
      }

      // Response from IAM is base64 encoded. Decode it into a buffer and return.
      return base64Decode(response.signedBlob!);
    } on iam_credentials_v1.ApiRequestError catch (e) {
      throw CryptoSignerException(
        CryptoSignerErrorCode.serverError,
        'IAM signBlob failed: ${e.message ?? 'Unknown error'}',
      );
    }
  }
}

/// A CryptoSigner implementation that uses an explicitly specified service account private key to
/// sign data. Performs all operations locally, and does not make any RPC calls.
class ServiceAccountSigner implements CryptoSigner {
  ServiceAccountSigner(this.credential);

  final auth.ServiceAccountCredentials credential;

  @override
  String get algorithm => 'RS256';

  @override
  Future<String> getAccountId() async => credential.email;

  @override
  Future<Uint8List> sign(Uint8List buffer) async {
    final signer = pointy.Signer('SHA-256/RSA');
    final privateParams = pointy.PrivateKeyParameter<pointy.RSAPrivateKey>(
      parseRSAPrivateKey(credential.privateKey),
    );

    signer.init(true, privateParams); // `true` for signing mode

    final signature = signer.generateSignature(buffer) as pointy.RSASignature;

    return signature.bytes;
  }

  /// Parses a PEM private key into an `RSAPrivateKey`
  ///
  /// Supports PKCS#8 format (BEGIN PRIVATE KEY).
  pointy.RSAPrivateKey parseRSAPrivateKey(String pemStr) {
    // Decode PKCS#8 format (BEGIN PRIVATE KEY)
    final pem = PemCodec(PemLabel.privateKey).decode(pemStr);

    var asn1Parser = ASN1Parser(Uint8List.fromList(pem));
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    final privateKey = topLevelSeq.elements[2];

    asn1Parser = ASN1Parser(privateKey.contentBytes());
    final pkSeq = asn1Parser.nextObject() as ASN1Sequence;

    final modulus = pkSeq.elements[1] as ASN1Integer;
    final privateExponent = pkSeq.elements[3] as ASN1Integer;
    final p = pkSeq.elements[4] as ASN1Integer;
    final q = pkSeq.elements[5] as ASN1Integer;

    return pointy.RSAPrivateKey(
      modulus.valueAsBigInteger,
      privateExponent.valueAsBigInteger,
      p.valueAsBigInteger,
      q.valueAsBigInteger,
    );
  }
}

class CryptoSignerException implements Exception {
  CryptoSignerException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'CryptoSignerException($code, $message)';
}

/// Crypto Signer error codes and their default messages.
class CryptoSignerErrorCode {
  static const invalidArgument = 'invalid-argument';
  static const internalError = 'internal-error';
  static const invalidCredential = 'invalid-credential';
  static const serverError = 'server-error';
}
