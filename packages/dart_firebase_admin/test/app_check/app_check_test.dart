import 'dart:io';

import 'package:dart_firebase_admin/app_check.dart';
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';
import '../mock.dart';

void main() {
  late AppCheck appCheck;

  setUpAll(registerFallbacks);

  setUp(() {
    final sdk = createApp(useEmulator: false);
    appCheck = AppCheck(sdk);
  });

  final hasGoogleEnv =
      Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'] != null;

  group(skip: !hasGoogleEnv, 'AppCheck', () {
    test('e2e', () async {
      final token = await appCheck
          .createToken('1:559949546715:android:13025aec6cc3243d0ab8fe');

      await appCheck.verifyToken(token.token);
    });
  });
}
