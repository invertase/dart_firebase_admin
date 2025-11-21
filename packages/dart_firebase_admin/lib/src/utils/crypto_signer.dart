import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:googleapis/iamcredentials/v1.dart' as iam_credentials_v1;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:pem/pem.dart';
import 'package:pointycastle/export.dart' as pointy;

import '../app.dart';

Future<R> _v1<R>(
  FirebaseApp app,
  Future<R> Function(iam_credentials_v1.IAMCredentialsApi client) fn,
) async {
  try {
    return await fn(
      iam_credentials_v1.IAMCredentialsApi(await app.client),
    );
  } on iam_credentials_v1.ApiRequestError catch (e) {
    throw CryptoSignerException(
      CryptoSignerErrorCode.serverError,
      e.message ?? 'Unknown error',
    );
  }
}

@internal
abstract class CryptoSigner {
  static CryptoSigner fromApp(FirebaseApp app) {
    final credential = app.options.credential;
    final serviceAccountCredentials = credential?.serviceAccountCredentials;
    if (serviceAccountCredentials != null) {
      return _ServiceAccountSigner(serviceAccountCredentials);
    }

    return _IAMSigner(app);
  }

  /// The name of the signing algorithm.
  String get algorithm;

  /// Cryptographically signs a buffer of data.
  Future<Uint8List> sign(Uint8List buffer);

  /// Returns the ID of the service account used to sign tokens.
  Future<String> getAccountId();
}

class _IAMSigner implements CryptoSigner {
  _IAMSigner(this.app)
      : _serviceAccountId = app.options.credential?.serviceAccountId;

  @override
  String get algorithm => 'RS256';

  final FirebaseApp app;
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

    final response = await _v1(app, (client) {
      return client.projects.serviceAccounts.signBlob(
        iam_credentials_v1.SignBlobRequest(
          payload: base64Encode(buffer),
        ),
        'projects/-/serviceAccounts/$serviceAccount',
      );
    });

    // Response from IAM is base64 encoded. Decode it into a buffer and return.
    return base64Decode(response.signedBlob!);
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
    final signer = pointy.Signer('SHA-256/RSA');
    final privateParams = pointy.PrivateKeyParameter<pointy.RSAPrivateKey>(
      parseRSAPrivateKey(credential.privateKey),
    );

    signer.init(true, privateParams); // `true` for signing mode

    final signature = signer.generateSignature(buffer) as pointy.RSASignature;

    return signature.bytes;

    // print(credential.privateKey);
    // final key = utf8.encode(credential.privateKey);
    // final hmac = Hmac(sha256, key);
    // final digest = hmac.convert(buffer);

    // return Uint8List.fromList(digest.bytes);
  }

  /// Parses a PEM private key into an `RSAPrivateKey`
  pointy.RSAPrivateKey parseRSAPrivateKey(String pemStr) {
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

    // final keyBytes = PemCodec(PemLabel.privateKey).decode(pemStr);
    // // final base64Key = pem
    // //     .replaceAll("-----BEGIN PRIVATE KEY-----", "")
    // //     .replaceAll("-----END PRIVATE KEY-----", "")
    // //     .replaceAll("\n", "")
    // //     .replaceAll("\r", "");

    // // final keyBytes = base64Decode(base64Key);
    // final asn1Parser = ASN1Parser(Uint8List.fromList(keyBytes));
    // final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    // final keySeq = topLevelSeq.elements![2] as ASN1Sequence;

    // final modulus = (keySeq.elements![0] as ASN1Integer).integer;
    // final privateExponent = (keySeq.elements![3] as ASN1Integer).integer;

    // return RSAPrivateKey(modulus!, privateExponent!, null, null);
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
