// Copyright 2026 Google LLC
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

import 'dart:io';

/// The current Dart SDK version in semver format (e.g. "3.3.0").
String get dartVersion =>
    Platform.version.split(RegExp('[^0-9]')).take(3).join('.');

/// Generates the update mask for the provided object.
/// Note this will ignore the last key with value `null`.
List<String> generateUpdateMask(
  Object? obj, {
  List<String> terminalPaths = const [],
  String root = '',
}) {
  if (obj is! Map) return [];

  final updateMask = <String>[];
  for (final key in obj.keys) {
    final nextPath = root.isEmpty ? '$root.$key' : '$key';
    // We hit maximum path.
    // Consider switching to Set<string> if the list grows too large.
    if (terminalPaths.contains(nextPath)) {
      // Add key and stop traversing this branch.
      updateMask.add('$key');
    } else {
      final maskList = generateUpdateMask(
        obj[key],
        terminalPaths: terminalPaths,
        root: nextPath,
      );
      if (maskList.isNotEmpty) {
        for (final mask in maskList) {
          updateMask.add('$key.$mask');
        }
      } else {
        updateMask.add('$key');
      }
    }
  }
  return updateMask;
}
