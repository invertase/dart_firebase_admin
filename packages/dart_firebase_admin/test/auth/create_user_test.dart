import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

final newUserUid = uuid.v4();
final nonexistentUid = uuid.v4();
final newMultiFactorUserUid = uuid.v4();
final sessionCookieUids = [
  uuid.v4(),
  uuid.v4(),
  uuid.v4(),
  uuid.v4(),
];
const testPhoneNumber = '+11234567890';
const testPhoneNumber2 = '+16505550101';
const nonexistentPhoneNumber = '+18888888888';
final updatedEmail = '${uuid.v4().toLowerCase()}@example.com';
const updatedPhone = '+16505550102';
const customClaims = <String, Object>{
  'admin': true,
  'groupId': '1234',
};
final uids = ['$newUserUid-1', '$newUserUid-2', '$newUserUid-3'];
final mockUserData = (
  email: '${newUserUid.toLowerCase()}@example.com',
  emailVerified: false,
  phoneNumber: testPhoneNumber,
  password: 'password',
  displayName: 'Random User $newUserUid',
  photoURL: 'http://www.example.com/$newUserUid/photo.png',
  disabled: false,
);
const actionCodeSettings = (
  url: 'http://localhost/?a=1&b=2#c=3',
  handleCodeInApp: false,
);

void main() {
  final admin = FirebaseAdminApp.initializeApp(
    'dart-firebase-admin',
    Credential.fromApplicationDefaultCredentials(),
  );
  admin.useEmulator();

  test('createUser() creates a new user when called without a UID', () async {
    final auth = FirebaseAdminAuth(admin);
    final email = '${uuid.v4().toLowerCase()}@example.com';

    final user = await auth.createUser(
      CreateRequest(
        email: email,
        emailVerified: mockUserData.emailVerified,
        password: mockUserData.password,
        displayName: mockUserData.displayName,
        photoURL: mockUserData.photoURL,
        disabled: mockUserData.disabled,
      ),
    );

    print(user);
    print(user.runtimeType);
  });
}
