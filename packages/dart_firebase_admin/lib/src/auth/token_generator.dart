part of '../auth.dart';

const _oneHourInSeconds = 60 * 60;

// Audience to use for Firebase Auth Custom tokens
const _firebaseAudience =
    'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit';

// List of blacklisted claims which cannot be provided when creating a custom token
const _blacklistedClaims = [
  'acr',
  'amr',
  'at_hash',
  'aud',
  'auth_time',
  'azp',
  'cnf',
  'c_hash',
  'exp',
  'iat',
  'iss',
  'jti',
  'nbf',
  'nonce',
];

class _FirebaseTokenGenerator {
  _FirebaseTokenGenerator(
    this._signer, {
    required this.tenantId,
  }) {
    final tenantId = this.tenantId;
    if (tenantId != null && tenantId.isEmpty) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        '`tenantId` argument must be a non-empty string.',
      );
    }
  }

  final CryptoSigner _signer;
  final String? tenantId;

  /// Creates a new Firebase Auth Custom token.
  Future<String> createCustomToken(
    String uid, {
    Map<String, Object?>? developerClaims,
  }) async {
    String? errorMessage;
    if (uid.isEmpty) {
      errorMessage = '`uid` argument must be a non-empty string uid.';
    } else if (uid.length > 128) {
      errorMessage = '`uid` argument must not be longer than 128 characters.';
    }

    if (errorMessage != null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        errorMessage,
      );
    }

    final claims = <String, Object?>{...?developerClaims};
    if (developerClaims != null) {
      for (final key in developerClaims.keys) {
        if (_blacklistedClaims.contains(key)) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidArgument,
            'Developer claim "$key" is reserved and cannot be specified.',
          );
        }
      }
    }

    try {
      final account = await _signer.getAccountId();

      final header = {
        'alg': _signer.algorithm,
        'typ': 'JWT',
      };
      final iat = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final body = {
        'aud': _firebaseAudience,
        'iat': iat,
        'exp': iat + _oneHourInSeconds,
        'iss': account,
        'sub': account,
        'uid': uid,
        if (tenantId case final tenantId?) 'tenant_id': tenantId,
        if (claims.isNotEmpty) 'claims': claims,
      };

      final token = '${_encodeSegment(header)}.${_encodeSegment(body)}';
      final signPromise = await _signer.sign(utf8.encode(token));

      return '$token.${_encodeSegment(signPromise)}';
    } on CryptoSignerException catch (err, stack) {
      Error.throwWithStackTrace(_handleCryptoSignerError(err), stack);
    }
  }

  String _encodeSegment(Object? segment) {
    final buffer =
        segment is Uint8List ? segment : utf8.encode(jsonEncode(segment));
    return base64Encode(buffer).replaceFirst(RegExp(r'=+$'), '');
  }
}

/// Creates a new FirebaseAuthError by extracting the error code, message and other relevant
/// details from a CryptoSignerError.
Object _handleCryptoSignerError(CryptoSignerException err) {
  return FirebaseAuthAdminException(
    _mapToAuthClientErrorCode(err.code),
    err.message,
  );
}

AuthClientErrorCode _mapToAuthClientErrorCode(String code) {
  switch (code) {
    case CryptoSignerErrorCode.invalidCredential:
      return AuthClientErrorCode.invalidCredential;
    case CryptoSignerErrorCode.invalidArgument:
      return AuthClientErrorCode.invalidArgument;
    default:
      return AuthClientErrorCode.internalError;
  }
}

/// A CryptoSigner implementation that is used when communicating with the Auth emulator.
/// It produces unsigned tokens.
class _EmulatedSigner implements CryptoSigner {
  @override
  String get algorithm => 'none';

  @override
  Future<Uint8List> sign(Uint8List buffer) async => utf8.encode('');

  @override
  Future<String> getAccountId() async => 'firebase-auth-emulator@example.com';
}
