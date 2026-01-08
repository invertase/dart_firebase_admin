import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:meta/meta.dart';

import '../../dart_firebase_admin.dart';

// Extension to provide CryptoSigner factory from FirebaseApp
extension CryptoSignerFromApp on FirebaseApp {
  @internal
  CryptoSigner createCryptoSigner() {
    final credential = options.credential;
    final serviceAccountCredentials = credential?.serviceAccountCredentials;
    if (serviceAccountCredentials != null) {
      return ServiceAccountSigner(serviceAccountCredentials);
    }

    return IAMSigner.lazy(
      client,
      serviceAccountEmail: options.serviceAccountId,
    );
  }
}
