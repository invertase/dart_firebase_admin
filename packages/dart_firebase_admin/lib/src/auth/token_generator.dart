part of '../auth.dart';

const _oneHourInSeconds = 60 * 60;

// Audience to use for Firebase Auth Custom tokens
const _firebaseAudience =
    'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit';

// List of reserved claims which cannot be provided when creating a custom token
const _reservedClaims = [
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
  _FirebaseTokenGenerator(this._app, {required this.tenantId}) {
    final tenantId = this.tenantId;
    if (tenantId != null && tenantId.isEmpty) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        '`tenantId` argument must be a non-empty string.',
      );
    }
  }

  final FirebaseApp _app;
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
        if (_reservedClaims.contains(key)) {
          throw FirebaseAuthAdminException(
            AuthClientErrorCode.invalidArgument,
            'Developer claim "$key" is reserved and cannot be specified.',
          );
        }
      }
    }

    try {
      final account = await _app.serviceAccountEmail;

      final header = {'alg': 'RS256', 'typ': 'JWT'};
      final iat = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final body = {
        'aud': _firebaseAudience,
        'iat': iat,
        'exp': iat + _oneHourInSeconds,
        'iss': account,
        'sub': account,
        'uid': uid,
        'tenant_id': ?tenantId,
        if (claims.isNotEmpty) 'claims': claims,
      };

      final token = '${_encodeSegment(header)}.${_encodeSegment(body)}';
      final signature = await _app.sign(utf8.encode(token));

      return '$token.$signature';
    } on googleapis_auth.ServerRequestFailedException catch (err, stack) {
      Error.throwWithStackTrace(
        FirebaseAuthAdminException(
          AuthClientErrorCode.invalidCredential,
          err.message,
        ),
        stack,
      );
    }
  }

  String _encodeSegment(Object? segment) {
    final buffer = segment is Uint8List
        ? segment
        : utf8.encode(jsonEncode(segment));
    return base64Encode(buffer).replaceFirst(RegExp(r'=+$'), '');
  }
}
