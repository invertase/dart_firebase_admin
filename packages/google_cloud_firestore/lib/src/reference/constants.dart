// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

part of '../firestore.dart';

enum _Direction {
  ascending('ASCENDING'),
  descending('DESCENDING');

  const _Direction(this.value);

  final String value;
}
