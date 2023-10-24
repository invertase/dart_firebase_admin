import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' as dart_jsonwebtoken;
import 'package:firebaseapis/identitytoolkit/v1.dart' as auth1;
import 'package:firebaseapis/identitytoolkit/v1.dart' as v1;
import 'package:firebaseapis/identitytoolkit/v2.dart' as auth2;
import 'package:firebaseapis/identitytoolkit/v2.dart' as v2;
import 'package:firebaseapis/identitytoolkit/v3.dart' as auth3;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:meta/meta.dart';

import 'app.dart';
import 'object_utils.dart';
import 'utils/crypto_signer.dart';
import 'utils/jwt.dart';
import 'utils/utils.dart';
import 'utils/validator.dart';

part 'auth/action_code_settings_builder.dart';
part 'auth/auth.dart';
part 'auth/auth_api_request.dart';
part 'auth/auth_config.dart';
part 'auth/auth_exception.dart';
part 'auth/base_auth.dart';
part 'auth/identifier.dart';
part 'auth/token_generator.dart';
part 'auth/token_verifier.dart';
part 'auth/user.dart';
part 'auth/user_import_builder.dart';
