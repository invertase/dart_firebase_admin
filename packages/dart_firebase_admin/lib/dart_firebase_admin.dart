library dart_firebase_admin;

import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebaseapis/identitytoolkit/v1.dart' as firebase_auth_v1;
import 'package:firebaseapis/identitytoolkit/v2.dart' as firebase_auth_v2;
import 'package:firebaseapis/identitytoolkit/v3.dart' as firebase_auth_v3;

part 'src/exception.dart';
part 'src/firebase_admin.dart';
part 'src/credential.dart';

part 'src/auth/firebase_admin_auth.dart';
part 'src/auth/auth_exception.dart';
part 'src/auth/delete_users_result.dart';
part 'src/auth/create_request.dart';
part 'src/auth/update_request.dart';
part 'src/auth/user_record.dart';
part 'src/auth/user_metadata.dart';
part 'src/auth/user_info.dart';
