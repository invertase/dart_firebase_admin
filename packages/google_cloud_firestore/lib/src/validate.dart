// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

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
