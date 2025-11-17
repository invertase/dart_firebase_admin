library;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io show File, Platform;
import 'dart:typed_data';

import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_dart_storage/src/internal/api_error.dart';
import 'package:googleapis_dart_storage/src/internal/retry.dart';
import 'package:googleapis_dart_storage/src/internal/service.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'src/internal/service_object.dart';

export 'src/internal/api_error.dart';
export 'src/internal/retry.dart';

part 'src/acl.dart';
part 'src/storage.dart';
part 'src/bucket.dart';
part 'src/file.dart';
part 'src/crc32c.dart';

/// Symbol for accessing environment variables in tests via Zones.
/// This allows tests to override Platform.environment values.
@internal
const envSymbol = #_envSymbol;
