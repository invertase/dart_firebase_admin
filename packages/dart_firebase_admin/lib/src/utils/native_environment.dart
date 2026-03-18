// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

import '../../dart_firebase_admin.dart';

final int Function(Pointer<Utf8>, Pointer<Utf8>, int) _setenv =
    DynamicLibrary.process().lookupFunction<
      Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Int32),
      int Function(Pointer<Utf8>, Pointer<Utf8>, int)
    >('setenv');

final int Function(Pointer<Utf16>, Pointer<Utf16>) _setEnvironmentVariableW =
    DynamicLibrary.open('kernel32.dll').lookupFunction<
      Int32 Function(Pointer<Utf16>, Pointer<Utf16>),
      int Function(Pointer<Utf16>, Pointer<Utf16>)
    >('SetEnvironmentVariableW');

@internal
void setNativeEnvironmentVariable(String name, String value) {
  if (Platform.isWindows) {
    using((arena) {
      final namePtr = name.toNativeUtf16(allocator: arena);
      final valuePtr = value.toNativeUtf16(allocator: arena);
      if (_setEnvironmentVariableW(namePtr, valuePtr) == 0) {
        throw FirebaseAppException(
          AppErrorCode.internalError,
          'Failed to set native environment variable: $name',
        );
      }
    });
  } else {
    using((arena) {
      final namePtr = name.toNativeUtf8(allocator: arena);
      final valuePtr = value.toNativeUtf8(allocator: arena);
      if (_setenv(namePtr, valuePtr, 1) == -1) {
        throw FirebaseAppException(
          AppErrorCode.internalError,
          'Failed to set native environment variable: $name',
        );
      }
    });
  }
}
