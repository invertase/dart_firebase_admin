import '../auth.dart';

/// Validates that a string is a valid phone number.
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
void assertIsPhoneNumber(String phoneNumber) {
  if (!isPhoneNumber(phoneNumber)) {
    throw FirebaseAuthAdminException(AuthClientErrorCode.invalidPhoneNumber);
  }
}

/// Validates that a string is a valid email.
bool isEmail(String email) {
  // There must at least one character before the @ symbol and another after.
  final re = RegExp(r'^[^@]+@[^@]+$');
  return re.hasMatch(email);
}

/// Verifies that a string is a valid email. Throws otherwise.
void assertIsEmail(String email) {
  if (!isEmail(email)) {
    throw FirebaseAuthAdminException(AuthClientErrorCode.invalidEmail);
  }
}

/// Validates that a string is a valid Firebase Auth uid.
bool isUid(String uid) => uid.isNotEmpty && uid.length <= 128;

/// Verifies that a string is a valid Firebase Auth uid. Throws otherwise.
void assertIsUid(String uid) {
  if (!isUid(uid)) {
    throw FirebaseAuthAdminException(AuthClientErrorCode.invalidUid);
  }
}
