// Copyright 2024 Google LLC
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

import 'package:dart_firebase_admin/app_check.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

Future<void> appCheckExample(FirebaseApp admin) async {
  print('\n### App Check Example ###\n');

  final appCheck = admin.appCheck();

  // Example 1: Create an App Check token for a client app
  try {
    print('> Creating App Check token...\n');
    final token = await appCheck.createToken('<app-id>');
    print('Token created successfully!');
    print('  - Token: ${token.token}');
    print('  - TTL: ${token.ttlMillis}ms');
    print('');
  } on FirebaseAppCheckException catch (e) {
    print('> App Check error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error creating token: $e');
  }

  // Example 2: Create a token with a custom TTL (e.g. 1 hour)
  try {
    print('> Creating App Check token with custom TTL...\n');
    final token = await appCheck.createToken(
      '<app-id>',
      AppCheckTokenOptions(ttlMillis: const Duration(hours: 1)),
    );
    print('Token with custom TTL created!');
    print('  - TTL: ${token.ttlMillis}ms');
    print('');
  } on FirebaseAppCheckException catch (e) {
    print('> App Check error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error creating token with TTL: $e');
  }

  // Example 3: Verify an App Check token from a client request
  try {
    print('> Verifying App Check token...\n');
    final response = await appCheck.verifyToken('<app-check-token>');
    print('Token verified successfully!');
    print('  - App ID: ${response.appId}');
    print('  - Already consumed: ${response.alreadyConsumed}');
    print('');
  } on FirebaseAppCheckException catch (e) {
    if (e.code == AppCheckErrorCode.appCheckTokenExpired.code) {
      print('> Token has expired');
    } else {
      print('> App Check error: ${e.code} - ${e.message}');
    }
  } catch (e) {
    print('> Error verifying token: $e');
  }

  // Example 4: Verify with replay protection (consume the token)
  try {
    print('> Verifying App Check token with replay protection...\n');
    final response = await appCheck.verifyToken(
      '<app-check-token>',
      VerifyAppCheckTokenOptions()..consume = true,
    );
    if (response.alreadyConsumed ?? false) {
      print('> Token was already consumed — possible replay attack!');
    } else {
      print('Token consumed and verified!');
      print('  - App ID: ${response.appId}');
    }
    print('');
  } on FirebaseAppCheckException catch (e) {
    print('> App Check error: ${e.code} - ${e.message}');
  } catch (e) {
    print('> Error verifying token with replay protection: $e');
  }
}
