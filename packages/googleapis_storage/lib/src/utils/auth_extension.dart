import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;

extension AuthExtension on googleapis_auth.AuthClient {
  Future<String> get getServiceAccountEmail async =>
      serviceAccountCredentials?.email ??
      googleapis_auth.IAMSigner(this).getServiceAccountEmail();
}
