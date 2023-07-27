part of '../dart_firebase_admin.dart';

class FirebaseAdminApp {
  factory FirebaseAdminApp.initializeApp(
    String projectId,
    Credential credential,
  ) {
    return FirebaseAdminApp._(projectId, credential);
  }

  FirebaseAdminApp._(this._projectId, this._credential);
  final String _projectId;
  final Credential _credential;
}

extension FirebaseAdminStringExtension on String {
  bool get isUid => isNotEmpty && length <= 128;
  // TODO check these are correct
  // https://github.com/firebase/firebase-admin-node/blob/aea280d325c202fedc3890850d8c04f2f7e9cd54/src/utils/validator.ts#L160
  bool get isEmail => RegExp(r'/^[^@]+@[^@]+$/').hasMatch(this);
  bool get isPhoneNumber =>
      startsWith('+') && RegExp(r'/[\da-zA-Z]+/').hasMatch(this);
}
