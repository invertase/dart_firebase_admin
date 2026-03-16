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

part of 'firestore.dart';

/// Validates that 'value' is a host.
@internal
void validateHost(String value, {required String argName}) {
  final urlString = 'http://$value/';
  Uri parsed;
  try {
    parsed = Uri.parse(urlString);
  } catch (e) {
    throw ArgumentError.value(value, argName, 'Must be a valid host');
  }

  if (parsed.query.isNotEmpty ||
      parsed.path != '/' ||
      parsed.userName.isNotEmpty) {
    throw ArgumentError.value(value, argName, 'Must be a valid host');
  }
}

extension on Uri {
  String get userName => userInfo.split(':').first;
}
