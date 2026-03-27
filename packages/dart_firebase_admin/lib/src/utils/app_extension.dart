// Copyright 2026 Firebase
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
