// Copyright 2025 Google LLC
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

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/src/auth.dart';
import 'package:googleapis/fcm/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

void registerFallbacks() {
  registerFallbackValue(_SendMessageRequestFake());
  registerFallbackValue(Uri());
  registerFallbackValue(Request('post', Uri()));
}

class FirebaseAdminMock extends Mock implements FirebaseApp {}

class MockAuthClient extends Mock implements AuthClient {}

class AuthRequestHandlerMock extends Mock implements AuthRequestHandler {}

class AuthHttpClientMock extends Mock implements AuthHttpClient {}

class MockFirebaseTokenVerifier extends Mock implements FirebaseTokenVerifier {}

class _SendMessageRequestFake extends Fake implements SendMessageRequest {}
