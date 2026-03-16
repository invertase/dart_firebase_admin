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

extension ObjectUtils<T> on T? {
  T orThrow(Never Function() thrower) => this ?? thrower();

  R? let<R>(R Function(T) block) {
    final that = this;
    return that == null ? null : block(that);
  }
}

@internal
extension MapWhereValue<K, V> on Map<K, V?> {
  Map<K, V> whereValueNotNull() {
    return Map<K, V>.fromEntries(
      entries
          .where((e) => e.value != null)
          // ignore: null_check_on_nullable_type_parameter
          .map((e) => MapEntry(e.key, e.value!)),
    );
  }
}

@internal
Uint8List randomBytes(int length) {
  final rnd = math.Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (i) => rnd.nextInt(256)),
  );
}

/// Generate a unique client-side identifier.
///
/// Used for the creation of new documents.
/// Returns a unique 20-character wide identifier.
@internal
String autoId() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var autoId = '';
  while (autoId.length < 20) {
    final bytes = randomBytes(40);
    for (final b in bytes) {
      // Length of `chars` is 62. We only take bytes between 0 and 62*4-1
      // (both inclusive). The value is then evenly mapped to indices of `char`
      // via a modulo operation.
      const maxValue = 62 * 4 - 1;
      if (autoId.length < 20 && b <= maxValue) {
        autoId += chars[b % 62];
      }
    }
  }
  return autoId;
}

/// Generate a short and semi-random client-side identifier.
///
/// Used for the creation of request tags.
@internal
String requestTag() => autoId().substring(0, 5);
