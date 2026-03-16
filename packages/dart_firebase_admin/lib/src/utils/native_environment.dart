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
