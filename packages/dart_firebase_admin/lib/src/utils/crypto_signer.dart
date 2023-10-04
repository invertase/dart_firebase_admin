import 'dart:typed_data';

abstract class CryptoSigner {
  /// The name of the signing algorithm.
  String get algorithm;

  /// Cryptographically signs a buffer of data.
  Future<Uint8List> sign(Uint8List buffer);

  /// Returns the ID of the service account used to sign tokens.
  Future<String> getAccountId();
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
