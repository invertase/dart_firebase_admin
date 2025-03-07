import 'dart:convert';

import 'package:meta/meta.dart';

import '../utils/crypto_signer.dart';
import 'ap_check_api_internal.dart';
import 'app_check_api.dart';

// Audience to use for Firebase App Check Custom tokens
const FIREBASE_APP_CHECK_AUDIENCE =
    'https://firebaseappcheck.googleapis.com/google.firebase.appcheck.v1.TokenExchangeService';

const ONE_MINUTE_IN_SECONDS = 60;

/// Class for generating Firebase App Check tokens.
@internal
class AppCheckTokenGenerator {
  AppCheckTokenGenerator(this.signer);

  final CryptoSigner signer;

  /// Creates a new custom token that can be exchanged to an App Check token.
  ///
  /// [appId] - The Application ID to use for the generated token.
  ///
  /// @returns A Promise fulfilled with a custom token signed with a service account key
  /// that can be exchanged to an App Check token.
  Future<String> createCustomToken(
    String appId, [
    AppCheckTokenOptions? options,
  ]) async {
    try {
      final account = await signer.getAccountId();

      final header = {
        'alg': signer.algorithm,
        'typ': 'JWT',
      };
      final iat = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      final body = {
        'iss': account,
        'sub': account,
        'app_id': appId,
        'aud': FIREBASE_APP_CHECK_AUDIENCE,
        'exp': iat + (ONE_MINUTE_IN_SECONDS * 5),
        'iat': iat,
      };
      final token = '${_encodeSegment(header)}.${_encodeSegment(body)}';

      final signature = await signer.sign(utf8.encode(token));

      return '$token.${_encodeSegmentBuffer(signature)}';
    } on CryptoSignerException catch (err) {
      throw _appCheckErrorFromCryptoSignerError(err);
    }
  }

  String _encodeSegment(Map<String, Object?> segment) {
    return _encodeSegmentBuffer(utf8.encode(jsonEncode(segment)));
  }

  String _encodeSegmentBuffer(List<int> buffer) {
    final base64 = base64Encode(buffer);

    return base64.replaceAll(RegExp(r'=+$'), '');
  }
}

/// Creates a new `FirebaseAppCheckError` by extracting the error code, message and other relevant
/// details from a `CryptoSignerError`.
///
/// [err] - The Error to convert into a [FirebaseAppCheckException] error
/// Returns a Firebase App Check error that can be returned to the user.
FirebaseAppCheckException _appCheckErrorFromCryptoSignerError(
  CryptoSignerException err,
) {
  // TODO handle CryptoSignerException.cause

  return FirebaseAppCheckException(
    AppCheckErrorCode.from(err.code),
    err.message,
  );
}
