library dart_firebase_admin;

import 'dart:convert';
import 'dart:io';

import 'package:firebaseapis/identitytoolkit/v1.dart' as firebase_auth_v1;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:meta/meta.dart';

import 'src/app/core.dart';

part 'src/auth/auth_exception.dart';
part 'src/credential.dart';
part 'src/exception.dart';
part 'src/firebase_admin.dart';
