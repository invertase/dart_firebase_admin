import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;

import '../app.dart';

extension AuthExtension on googleapis_auth.AuthClient {
  Future<String> get getServiceAccountEmail async =>
      serviceAccountCredentials?.email ??
      googleapis_auth.IAMSigner(this).getServiceAccountEmail();

  /// Signs the given data using the IAM Credentials API or local credentials.
  ///
  /// Returns a base64-encoded signature string. In emulator mode, returns an
  /// empty string to produce unsigned tokens.
  Future<String> signBlob(List<int> data, {String? endpoint}) async =>
      Environment.isAuthEmulatorEnabled() ? '' : sign(data, endpoint: endpoint);
}
