import 'package:meta/meta.dart';

import '../auth.dart';

/// Validates that a string is a valid phone number.
@internal
bool isPhoneNumber(String phoneNumber) {
  // Phone number validation is very lax here. Backend will enforce E.164
  // spec compliance and will normalize accordingly.
  // The phone number string must be non-empty and starts with a plus sign.
  final re1 = RegExp(r'^\+');
  // The phone number string must contain at least one alphanumeric character.
  final re2 = RegExp(r'[\da-zA-Z]+');
  return re1.hasMatch(phoneNumber) && re2.hasMatch(phoneNumber);
}

/// Verifies that a string is a valid phone number. Throws otherwise.
@internal
void assertIsPhoneNumber(String phoneNumber) {
  if (!isPhoneNumber(phoneNumber)) {
    throw FirebaseAuthAdminException(AuthClientErrorCode.invalidPhoneNumber);
  }
}

/// Validates that a string is a valid email.
@internal
bool isEmail(String email) {
  // There must at least one character before the @ symbol and another after.
  final re = RegExp(r'^[^@]+@[^@]+$');
  return re.hasMatch(email);
}

/// Verifies that a string is a valid email. Throws otherwise.
@internal
void assertIsEmail(String email) {
  if (!isEmail(email)) {
    throw FirebaseAuthAdminException(AuthClientErrorCode.invalidEmail);
  }
}

/// Validates that a string is a valid Firebase Auth uid.
@internal
bool isUid(String uid) => uid.isNotEmpty && uid.length <= 128;

/// Verifies that a string is a valid Firebase Auth uid. Throws otherwise.
@internal
void assertIsUid(String uid) {
  if (!isUid(uid)) {
    throw FirebaseAuthAdminException(AuthClientErrorCode.invalidUid);
  }
}

/// Validates that the provided topic is a valid FCM topic name.
bool isTopic(Object? topic) {
  if (topic is! String) return false;

  final validTopicRegExp = RegExp(
    r'^(\/topics\/)?(private\/)?[a-zA-Z0-9-_.~%]+$',
  );
  return validTopicRegExp.hasMatch(topic);
}
