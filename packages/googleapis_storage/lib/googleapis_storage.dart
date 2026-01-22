library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;

import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:googleapis_storage/src/internal/api_error.dart';
import 'package:googleapis_storage/src/internal/api.dart';
import 'package:googleapis_storage/src/internal/service.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';

export 'package:googleapis_auth_utils/googleapis_auth_utils.dart'
    show GoogleCredential;

import 'src/internal/service_object.dart';
import 'src/internal/streaming.dart';
import 'src/internal/limit.dart';
import 'src/internal/xml_multipart_helper.dart';
import 'version.g.dart';
import 'src/types.dart';

export 'src/internal/api_error.dart';
export 'src/types.dart';

part 'src/acl.dart';
part 'src/bucket.dart';
part 'src/channel.dart';
part 'src/crc32c.dart';
part 'src/file.dart';
part 'src/hash_stream_validator.dart';
part 'src/hmac_key.dart';
part 'src/iam.dart';
part 'src/notification.dart';
part 'src/resumable_upload.dart';
part 'src/signer.dart';
part 'src/storage.dart';
part 'src/transfer_manager.dart';

/// Symbol for accessing environment variables in tests via Zones.
/// This allows tests to override Platform.environment values.
@internal
const envSymbol = #_envSymbol;
