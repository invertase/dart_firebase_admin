// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:googleapis_auth/auth_io.dart';

import '../app.dart';

extension AppExtension on FirebaseApp {
  Future<String> get serviceAccountEmail async =>
      options.credential?.serviceAccountId ??
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
          serviceAccountEmail: options.credential?.serviceAccountId,
          endpoint: endpoint,
        );
}
