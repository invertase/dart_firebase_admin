library app;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:googleapis/identitytoolkit/v3.dart' as auth3;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:meta/meta.dart';

part 'app/app_options.dart';
part 'app/app_registry.dart';
part 'app/credential.dart';
part 'app/emulator_client.dart';
part 'app/exception.dart';
part 'app/firebase_app.dart';

final _defaultAppRegistry = AppRegistry();