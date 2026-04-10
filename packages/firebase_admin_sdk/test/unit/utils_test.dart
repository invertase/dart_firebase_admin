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

import 'package:firebase_admin_sdk/src/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  group('generateUpdateMask', () {
    test('non-map objects', () {
      expect(generateUpdateMask(null), isEmpty);
      expect(generateUpdateMask(1), isEmpty);
      expect(generateUpdateMask('string'), isEmpty);
      expect(generateUpdateMask([]), isEmpty);
    });

    test('empty map', () {
      final obj = <String, dynamic>{};
      expect(generateUpdateMask(obj), isEmpty);
    });

    test('flat map', () {
      final obj = {'a': 1, 'b': 'string', 'c': null};
      expect(generateUpdateMask(obj), containsAll(['a', 'b', 'c']));
    });

    test('nested maps', () {
      final obj = {
        'a': 1,
        'b': {'c': 2, 'd': null},
      };
      expect(generateUpdateMask(obj), containsAll(['a', 'b.c', 'b.d']));
    });

    test('deeply nested maps', () {
      final obj = {
        'a': {
          'b': {'c': null},
        },
      };
      expect(generateUpdateMask(obj), containsAll(['a.b.c']));
    });

    test('empty maps as leaf nodes', () {
      final obj = {
        'a': <String, dynamic>{},
        'b': {'c': <String, dynamic>{}},
      };
      expect(generateUpdateMask(obj), containsAll(['a', 'b.c']));
    });
  });
}
