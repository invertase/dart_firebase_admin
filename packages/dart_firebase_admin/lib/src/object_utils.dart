// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

extension ObjectUtils<T> on T? {
  T orThrow(Never Function() thrower) => this ?? thrower();

  R? let<R>(R Function(T) block) {
    final that = this;
    return that == null ? null : block(that);
  }
}
