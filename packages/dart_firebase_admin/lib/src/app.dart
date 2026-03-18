// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

library app;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:google_cloud/constants.dart' as google_cloud;
import 'package:google_cloud/google_cloud.dart' as google_cloud;
import 'package:google_cloud_firestore/google_cloud_firestore.dart'
    as google_cloud_firestore;
import 'package:googleapis/identitytoolkit/v3.dart' as auth3;
import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../app_check.dart';
import '../auth.dart';
import '../firestore.dart';
import '../functions.dart';
import '../messaging.dart';
import '../security_rules.dart';
import '../storage.dart';
import '../version.g.dart';
import 'utils/utils.dart';

part 'app/app_exception.dart';
part 'app/app_options.dart';
part 'app/app_registry.dart';
part 'app/credential.dart';
part 'app/emulator_client.dart';
part 'app/environment.dart';
part 'app/exception.dart';
part 'app/firebase_app.dart';
part 'app/firebase_service.dart';
part 'app/firebase_user_agent_client.dart';
