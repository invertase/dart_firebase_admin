import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' as dart_jsonwebtoken;
import 'package:googleapis/identitytoolkit/v1.dart' as auth1;
import 'package:googleapis/identitytoolkit/v1.dart' as v1;
import 'package:googleapis/identitytoolkit/v2.dart' as auth2;
import 'package:googleapis/identitytoolkit/v2.dart' as v2;
import 'package:googleapis/identitytoolkit/v3.dart' as auth3;
import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'app.dart';
import 'object_utils.dart';
import 'utils/crypto_signer.dart';
import 'utils/jwt.dart';
import 'utils/utils.dart';
import 'utils/validator.dart';

part 'auth/action_code_settings_builder.dart';
part 'auth/auth.dart';
part 'auth/auth_config.dart';
part 'auth/auth_config_tenant.dart';
part 'auth/auth_exception.dart';
part 'auth/auth_http_client.dart';
part 'auth/auth_request_handler.dart';
part 'auth/base_auth.dart';
part 'auth/identifier.dart';
part 'auth/tenant.dart';
part 'auth/tenant_manager.dart';
part 'auth/token_generator.dart';
part 'auth/token_verifier.dart';
part 'auth/user.dart';
part 'auth/user_import_builder.dart';
