library;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io show File, Platform;
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;

import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis/iamcredentials/v1.dart' as iamcredentials_v1;
import 'package:googleapis_dart_storage/src/internal/api_error.dart';
import 'package:googleapis_dart_storage/src/internal/retry.dart';
import 'package:googleapis_dart_storage/src/internal/service.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';

import 'src/internal/service_object.dart';
import 'src/internal/streaming.dart';
import 'src/internal/limit.dart';

export 'src/internal/api_error.dart';

part 'src/acl.dart';
part 'src/bucket.dart';
part 'src/channel.dart';
part 'src/crc32c.dart';
part 'src/file.dart';
part 'src/hmac_key.dart';
part 'src/notification.dart';
part 'src/signer.dart';
part 'src/storage.dart';

/// Symbol for accessing environment variables in tests via Zones.
/// This allows tests to override Platform.environment values.
@internal
const envSymbol = #_envSymbol;
