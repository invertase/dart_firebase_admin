part of 'dart_firebase_admin.dart';

class FirebaseAdminApp {
  FirebaseAdminApp.initializeApp(this.projectId, this.credential);

  final String projectId;
  final Credential credential;

  bool get isUsingEmulator => _isUsingEmulator;
  var _isUsingEmulator = false;

  @internal
  Uri authApiHost = Uri.https('identitytoolkit.googleapis.com', '/');
  @internal
  Uri firestoreApiHost = Uri.https('identitytoolkit.googleapis.com', '/');

  void useEmulator() {
    _isUsingEmulator = true;
    // TODO use different apiHost for every service
    authApiHost = Uri.http('127.0.0.1:9099', 'identitytoolkit.googleapis.com/');
    firestoreApiHost = Uri.http('127.0.0.1:8080', '/'
        // 'identitytoolkit.googleapis.com/',
        );
  }
}

extension FirebaseAdminStringExtension on String {
  bool get isUid => isNotEmpty && length <= 128;
  // TODO check these are correct
  // https://github.com/firebase/firebase-admin-node/blob/aea280d325c202fedc3890850d8c04f2f7e9cd54/src/utils/validator.ts#L160
  bool get isEmail => RegExp(r'/^[^@]+@[^@]+$/').hasMatch(this);
  bool get isPhoneNumber =>
      startsWith('+') && RegExp(r'/[\da-zA-Z]+/').hasMatch(this);
}
