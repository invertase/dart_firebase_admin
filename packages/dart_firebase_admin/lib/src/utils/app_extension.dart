import 'package:googleapis_auth/auth_io.dart';

import '../app.dart';

extension AppExtension on FirebaseApp {
  Future<String> get serviceAccountEmail async =>
      options.credential?.serviceAccountCredentials?.email ??
      (await client).getServiceAccountEmail();

  /// Signs the given data using the IAM Credentials API or local credentials.
  ///
  /// Returns a base64-encoded signature string. In emulator mode, returns an
  /// empty string to produce unsigned tokens.
  Future<String> sign(List<int> data, {String? endpoint}) async =>
      Environment.isAuthEmulatorEnabled()
      ? ''
      : (await client).sign(
          data,
          serviceAccountCredentials:
              options.credential?.serviceAccountCredentials,
          endpoint: endpoint,
        );
}
