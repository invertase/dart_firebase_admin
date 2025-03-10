import 'dart:convert';

import 'package:meta/meta.dart';

import '../utils/crypto_signer.dart';
import 'ap_check_api_internal.dart';
import 'app_check_api.dart';

// Audience to use for Firebase App Check Custom tokens
const firebaseAppCheckAudience =
    'https://firebaseappcheck.googleapis.com/google.firebase.appcheck.v1.TokenExchangeService';

const oneMinuteInSeconds = 60;

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

      var header = {
        'alg': signer.algorithm,
        'typ': 'JWT',
      };
      final iat = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      var body = {
        'iss': account,
        'sub': account,
        'app_id': appId,
        'aud': firebaseAppCheckAudience,
        'exp': iat + (oneMinuteInSeconds * 5),
        'iat': iat,
      };

      final token = '${_encodeSegment(header)}.${_encodeSegment(body)}';

      final signature = await signer.sign(utf8.encode(token));

      // print('HEre -----');
      final res = '$token.${_encodeSegmentBuffer(signature)}';
      // print(res);
      return res;
    } on CryptoSignerException catch (err) {
      throw _appCheckErrorFromCryptoSignerError(err);
    }
  }

  String _encodeSegment(Map<String, Object?> segment) {
    return _encodeSegmentBuffer(utf8.encode(jsonEncode(segment)));
  }

  String _encodeSegmentBuffer(List<int> buffer) {
    final base64 = _toWebSafeBase64(buffer);

    return base64.replaceAll(RegExp(r'=+$'), '');
  }

  String _toWebSafeBase64(List<int> data) {
    return base64Encode(data).replaceAll('/', '_').replaceAll('+', '-');
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
