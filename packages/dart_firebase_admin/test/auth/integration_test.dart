import 'package:dart_firebase_admin/auth.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../google_cloud_firestore/util/helpers.dart';

const _uid = Uuid();

void main() {
  late Auth auth;

  setUp(() {
    final sdk = createApp();
    sdk.useEmulator();
    auth = Auth(sdk);
  });

  tearDown(() => cleanup(auth));

  group('createUser', () {
    test('supports no specified uid', () async {
      final user = await auth.createUser(
        CreateRequest(email: 'example@gmail.com'),
      );

      expect(user.uid, isNotEmpty);
      expect(user.email, 'example@gmail.com');
    });

    test('supports specifying uid', () async {
      final user = await auth.createUser(
        CreateRequest(
          email: 'example@gmail.com',
          uid: '42',
        ),
      );

      expect(user.uid, '42');
      expect(user.email, 'example@gmail.com');
    });

    test('supports users with enrolled second factors', () async {
      const phoneNumber = '+16505550002';

      final user = await auth.createUser(
        CreateRequest(
          email: 'example@gmail.com',
          multiFactor: MultiFactorCreateSettings(
            enrolledFactors: [
              CreatePhoneMultiFactorInfoRequest(
                displayName: 'home phone',
                phoneNumber: phoneNumber,
              ),
            ],
          ),
        ),
      );

      expect(user.email, 'example@gmail.com');
      expect(user.multiFactor?.enrolledFactors, hasLength(1));
      expect(
        user.multiFactor?.enrolledFactors
            .cast<PhoneMultiFactorInfo>()
            .map((e) => (e.phoneNumber, e.displayName)),
        [(phoneNumber, 'home phone')],
      );
    });

    test('Fails when uid is already in use', () async {
      final user = await auth.createUser(
        CreateRequest(email: 'example@gmail.com'),
      );

      final user2 = auth.createUser(
        CreateRequest(
          uid: user.uid,
          email: 'user2@gmail.com',
        ),
      );

      expect(
        user2,
        throwsA(
          isA<FirebaseAuthAdminException>().having(
            (e) => e.errorCode,
            'errorCode',
            AuthClientErrorCode.uidAlreadyExists,
          ),
        ),
      );
    });
  });

  test('getUserByEmail', () async {
    final user = await auth.createUser(
      CreateRequest(email: 'example@gmail.com'),
    );

    final user2 = await auth.getUserByEmail(user.email!);

    expect(user2.uid, user.uid);
    expect(user2.email, user.email);
  });

  test('getUserByPhoneNumber', () async {
    const phoneNumber = '+16505550002';
    final user = await auth.createUser(
      CreateRequest(phoneNumber: phoneNumber),
    );

    final user2 = await auth.getUserByPhoneNumber(user.phoneNumber!);

    expect(user2.uid, user.uid);
    expect(user2.phoneNumber, user.phoneNumber);
  });

  group('getUserByProviderUid', () {
    test('works', () async {
      final importUser = UserImportRecord(
        uid: 'import_${_uid.v4()}',
        email: 'user@example.com',
        phoneNumber: '+15555550000',
        providerData: [
          UserProviderRequest(
            displayName: 'User Name',
            email: 'user@example.com',
            phoneNumber: '+15555550000',
            photoURL: 'http://example.com/user',
            providerId: 'google.com',
            uid: 'google_uid',
          ),
        ],
      );

      await auth.importUsers(
        [importUser],
      );

      final user = await auth.getUserByProviderUid(
        providerId: 'google.com',
        uid: 'google_uid',
      );

      expect(user.uid, importUser.uid);
    });
  });
}

Future<void> cleanup(Auth auth) async {
  if (!auth.app.isUsingEmulator) {
    throw Exception('Cannot cleanup non-emulator app');
  }

  final users = await auth.listUsers();
  await Future.wait([
    for (final user in users.users) auth.deleteUser(user.uid),
  ]);
}
