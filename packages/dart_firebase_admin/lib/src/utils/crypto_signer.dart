import 'dart:convert';
import 'dart:typed_data';

import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:pointycastle/pointycastle.dart';

import '../../dart_firebase_admin.dart';

/// Creates a new CryptoSigner instance for the given app. If the app has been initialized with a
/// service account credential, creates a ServiceAccountSigner.
@internal
CryptoSigner cryptoSignerFromApp(FirebaseAdminApp app) {
  final credential = app.credential;
  final serviceAccountCredentials = credential.serviceAccountCredentials;
  if (serviceAccountCredentials != null) {
    return _ServiceAccountSigner(serviceAccountCredentials);
  }

  return _IAMSigner(app);
}

@internal
abstract class CryptoSigner {
  /// The name of the signing algorithm.
  String get algorithm;

  /// Cryptographically signs a buffer of data.
  Future<Uint8List> sign(Uint8List buffer);

  /// Returns the ID of the service account used to sign tokens.
  Future<String> getAccountId();
}

class _IAMSigner implements CryptoSigner {
  _IAMSigner(this.app) : _serviceAccountId = app.credential.serviceAccountId;

  @override
  String get algorithm => 'RS256';

  final FirebaseAdminApp app;
  String? _serviceAccountId;

  @override
  Future<String> getAccountId() async {
    if (_serviceAccountId case final serviceAccountId?
        when serviceAccountId.isNotEmpty) {
      return serviceAccountId;
    }
    final response = await http.get(
      Uri.parse(
        'http://metadata/computeMetadata/v1/instance/service-accounts/default/email',
      ),
      headers: {
        'Metadata-Flavor': 'Google',
      },
    );

    if (response.statusCode != 200) {
      throw CryptoSignerException(
        CryptoSignerErrorCode.invalidCredential,
        'Failed to determine service account. Make sure to initialize '
        'the SDK with a service account credential. Alternatively specify a service '
        'account with iam.serviceAccounts.signBlob permission. Original error: ${response.body}',
      );
    }

    return _serviceAccountId = response.body;
  }

  @override
  Future<Uint8List> sign(Uint8List buffer) async {
    final serviceAccount = await getAccountId();

    final response = await http.post(
      Uri.parse(
        'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$serviceAccount:signBlob',
      ),
      body: {'payload': base64Encode(buffer)},
    );

    if (response.statusCode != 200) {
      throw CryptoSignerException(
        CryptoSignerErrorCode.serverError,
        response.body,
      );
    }

    // Response from IAM is base64 encoded. Decode it into a buffer and return.
    return base64Decode(response.body);
  }
}

/// A CryptoSigner implementation that uses an explicitly specified service account private key to
/// sign data. Performs all operations locally, and does not make any RPC calls.
class _ServiceAccountSigner implements CryptoSigner {
  _ServiceAccountSigner(this.credential);

  final auth.ServiceAccountCredentials credential;

  @override
  String get algorithm => 'RS256';

  @override
  Future<String> getAccountId() async => credential.email;

  @override
  Future<Uint8List> sign(Uint8List buffer) async {
    final rsaPrivateKey = _parsePrivateKeyFromPem();
    final signer = Signer('SHA-256/RSA')
      ..init(true, PrivateKeyParameter<RSAPrivateKey>(rsaPrivateKey));
    final signature = signer.generateSignature(buffer) as RSASignature;
    return signature.bytes;
  }

  RSAPrivateKey _parsePrivateKeyFromPem() {
    final privateKeyString = credential.privateKey
        .replaceAll('-----BEGIN PRIVATE KEY-----', '')
        .replaceAll('-----END PRIVATE KEY-----', '')
        .replaceAll('\n', '');
    final privateKeyDER = base64Decode(privateKeyString);

    final asn1Parser = ASN1Parser(Uint8List.fromList(privateKeyDER));
    final topLevelSequence = asn1Parser.nextObject() as ASN1Sequence;
    final privateKeyOctet = topLevelSequence.elements![2] as ASN1OctetString;

    final privateKeyParser = ASN1Parser(privateKeyOctet.valueBytes);
    final privatekeySequence = privateKeyParser.nextObject() as ASN1Sequence;

    final modulus = (privatekeySequence.elements![1] as ASN1Integer).integer!;
    final exponent = (privatekeySequence.elements![3] as ASN1Integer).integer!;
    final p = (privatekeySequence.elements![4] as ASN1Integer).integer;
    final q = (privatekeySequence.elements![5] as ASN1Integer).integer;

    return RSAPrivateKey(modulus, exponent, p, q);
  }
}

@internal
class CryptoSignerException implements Exception {
  CryptoSignerException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'CryptoSignerException($code, $message)';
}

/// Crypto Signer error codes and their default messages.
@internal
class CryptoSignerErrorCode {
  static const invalidArgument = 'invalid-argument';
  static const internalError = 'internal-error';
  static const invalidCredential = 'invalid-credential';
  static const serverError = 'server-error';
}
