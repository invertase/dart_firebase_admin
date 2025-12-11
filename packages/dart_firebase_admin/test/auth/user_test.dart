import 'package:dart_firebase_admin/auth.dart';
import 'package:googleapis/identitytoolkit/v1.dart' as auth1;
import 'package:test/test.dart';

void main() {
  group('UserMetadata', () {
    test('fromResponse with all fields', () {
      final now = DateTime.now().toUtc();

      final metadata = UserMetadata.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          createdAt: '0',
          lastLoginAt: '0',
          lastRefreshAt: now.toIso8601String(),
        ),
      );

      expect(metadata.creationTime, DateTime.fromMillisecondsSinceEpoch(0));
      expect(metadata.lastSignInTime, DateTime.fromMillisecondsSinceEpoch(0));
      expect(metadata.lastRefreshTime, now);
    });

    test('fromResponse with null lastLoginAt', () {
      final now = DateTime.now().toUtc();

      final metadata = UserMetadata.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          createdAt: '1000',
          lastRefreshAt: now.toIso8601String(),
        ),
      );

      expect(metadata.creationTime, DateTime.fromMillisecondsSinceEpoch(1000));
      expect(metadata.lastSignInTime, isNull);
      expect(metadata.lastRefreshTime, now);
    });

    test('fromResponse with null lastRefreshAt', () {
      final metadata = UserMetadata.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          createdAt: '2000',
          lastLoginAt: '3000',
        ),
      );

      expect(metadata.creationTime, DateTime.fromMillisecondsSinceEpoch(2000));
      expect(
        metadata.lastSignInTime,
        DateTime.fromMillisecondsSinceEpoch(3000),
      );
      expect(metadata.lastRefreshTime, isNull);
    });

    test('toJson serialization', () {
      final now = DateTime.now().toUtc();

      final metadata = UserMetadata.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          createdAt: '0',
          lastLoginAt: '0',
          lastRefreshAt: now.toIso8601String(),
        ),
      );

      final json = metadata.toJson();
      expect(json, {
        'lastSignInTime': '0',
        'creationTime': '0',
        'lastRefreshTime': now.toIso8601String(),
      });
    });

    test('toJson with null values', () {
      final metadata = UserMetadata.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(createdAt: '1000'),
      );

      final json = metadata.toJson();
      expect(json['creationTime'], isNotNull);
      expect(json['lastSignInTime'], isNull);
      expect(json['lastRefreshTime'], isNull);
    });
  });

  group('UserInfo', () {
    test('fromResponse with all fields', () {
      final userInfo = UserInfo.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1ProviderUserInfo(
          rawId: 'provider-uid-123',
          providerId: 'google.com',
          displayName: 'John Doe',
          email: 'john@example.com',
          phoneNumber: '+1234567890',
          photoUrl: 'https://example.com/photo.jpg',
        ),
      );

      expect(userInfo.uid, 'provider-uid-123');
      expect(userInfo.providerId, 'google.com');
      expect(userInfo.displayName, 'John Doe');
      expect(userInfo.email, 'john@example.com');
      expect(userInfo.phoneNumber, '+1234567890');
      expect(userInfo.photoUrl, 'https://example.com/photo.jpg');
    });

    test('fromResponse with minimal fields', () {
      final userInfo = UserInfo.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1ProviderUserInfo(
          rawId: 'uid',
          providerId: 'password',
        ),
      );

      expect(userInfo.uid, 'uid');
      expect(userInfo.providerId, 'password');
      expect(userInfo.displayName, isNull);
      expect(userInfo.email, isNull);
      expect(userInfo.phoneNumber, isNull);
      expect(userInfo.photoUrl, isNull);
    });

    test('toJson serialization', () {
      final userInfo = UserInfo.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1ProviderUserInfo(
          rawId: 'uid-123',
          providerId: 'facebook.com',
          displayName: 'Test User',
          email: 'test@fb.com',
        ),
      );

      final json = userInfo.toJson();
      expect(json['uid'], 'uid-123');
      expect(json['providerId'], 'facebook.com');
      expect(json['displayName'], 'Test User');
      expect(json['email'], 'test@fb.com');
      expect(json['phoneNumber'], isNull);
      expect(json['photoUrl'], isNull);
    });
  });

  group('PhoneMultiFactorInfo', () {
    test('fromResponse with all fields', () {
      final mfaInfo = PhoneMultiFactorInfo.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1MfaEnrollment(
          mfaEnrollmentId: 'mfa-123',
          displayName: 'My Phone',
          phoneInfo: '+15555551234',
          enrolledAt: '1234567890000',
        ),
      );

      expect(mfaInfo.uid, 'mfa-123');
      expect(mfaInfo.displayName, 'My Phone');
      expect(mfaInfo.phoneNumber, '+15555551234');
      expect(mfaInfo.factorId, MultiFactorId.phone);
      expect(
        mfaInfo.enrollmentTime,
        DateTime.fromMillisecondsSinceEpoch(1234567890000),
      );
    });

    test('fromResponse throws when mfaEnrollmentId is missing', () {
      expect(
        () => PhoneMultiFactorInfo.fromResponse(
          auth1.GoogleCloudIdentitytoolkitV1MfaEnrollment(
            phoneInfo: '+15555551234',
          ),
        ),
        throwsA(isA<FirebaseAuthAdminException>()),
      );
    });

    test('toJson includes phoneNumber', () {
      final mfaInfo = PhoneMultiFactorInfo.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1MfaEnrollment(
          mfaEnrollmentId: 'mfa-456',
          displayName: 'Work Phone',
          phoneInfo: '+19876543210',
          enrolledAt: '1000000000000',
        ),
      );

      final json = mfaInfo.toJson();
      expect(json['uid'], 'mfa-456');
      expect(json['displayName'], 'Work Phone');
      expect(json['phoneNumber'], '+19876543210');
      expect(json['factorId'], 'phone');
      expect(json['enrollmentTime'], isNotNull);
    });
  });

  group('MultiFactorSettings', () {
    test('fromResponse with enrolled factors', () {
      final settings = MultiFactorSettings.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          mfaInfo: [
            auth1.GoogleCloudIdentitytoolkitV1MfaEnrollment(
              mfaEnrollmentId: 'factor-1',
              phoneInfo: '+11111111111',
              enrolledAt: '1000',
            ),
            auth1.GoogleCloudIdentitytoolkitV1MfaEnrollment(
              mfaEnrollmentId: 'factor-2',
              phoneInfo: '+12222222222',
              enrolledAt: '2000',
            ),
          ],
        ),
      );

      expect(settings.enrolledFactors, hasLength(2));
      expect(settings.enrolledFactors[0].uid, 'factor-1');
      expect(settings.enrolledFactors[1].uid, 'factor-2');
    });

    test('fromResponse with no enrolled factors', () {
      final settings = MultiFactorSettings.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(mfaInfo: []),
      );

      expect(settings.enrolledFactors, isEmpty);
    });

    test('fromResponse with null mfaInfo', () {
      final settings = MultiFactorSettings.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(),
      );

      expect(settings.enrolledFactors, isEmpty);
    });

    test('toJson serialization', () {
      final settings = MultiFactorSettings.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          mfaInfo: [
            auth1.GoogleCloudIdentitytoolkitV1MfaEnrollment(
              mfaEnrollmentId: 'mfa-1',
              phoneInfo: '+15555555555',
              enrolledAt: '5000',
            ),
          ],
        ),
      );

      final json = settings.toJson();
      expect(json['enrolledFactors'], isList);
      expect(json['enrolledFactors'], hasLength(1));
      final enrolledFactors = json['enrolledFactors']! as List;
      expect((enrolledFactors[0] as Map<String, dynamic>)['uid'], 'mfa-1');
    });
  });

  group('UserRecord', () {
    test('fromResponse throws when localId is missing', () {
      expect(
        () => UserRecord.fromResponse(
          auth1.GoogleCloudIdentitytoolkitV1UserInfo(),
        ),
        throwsA(
          isA<FirebaseAuthAdminException>().having(
            (e) => e.errorCode,
            'errorCode',
            AuthClientErrorCode.internalError,
          ),
        ),
      );
    });

    test('fromResponse with minimal fields', () {
      final user = UserRecord.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          localId: 'user-123',
          createdAt: '0',
        ),
      );

      expect(user.uid, 'user-123');
      expect(user.email, isNull);
      expect(user.emailVerified, false);
      expect(user.displayName, isNull);
      expect(user.photoUrl, isNull);
      expect(user.phoneNumber, isNull);
      expect(user.disabled, false);
      expect(user.passwordHash, isNull);
      expect(user.passwordSalt, isNull);
      expect(user.customClaims, isNull);
      expect(user.tenantId, isNull);
      expect(user.tokensValidAfterTime, isNull);
      expect(user.multiFactor, isNull);
    });

    test('fromResponse with disabled flag', () {
      final user = UserRecord.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          localId: 'user-disabled',
          createdAt: '0',
          disabled: true,
        ),
      );

      expect(user.disabled, true);
    });

    test('fromResponse redacts password hash when REDACTED', () {
      final user = UserRecord.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          localId: 'user-redacted',
          createdAt: '0',
          passwordHash: 'UkVEQUNURUQ=', // base64 encoded "REDACTED"
        ),
      );

      expect(user.passwordHash, isNull);
    });

    test('fromResponse preserves actual password hash', () {
      final user = UserRecord.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          localId: 'user-hash',
          createdAt: '0',
          passwordHash: 'actualHash123==',
        ),
      );

      expect(user.passwordHash, 'actualHash123==');
    });

    test('fromResponse parses customClaims JSON', () {
      final user = UserRecord.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          localId: 'user-claims',
          createdAt: '0',
          customAttributes: '{"role":"admin","level":5}',
        ),
      );

      expect(user.customClaims, isNotNull);
      expect(user.customClaims!['role'], 'admin');
      expect(user.customClaims!['level'], 5);
    });

    test('fromResponse parses tokensValidAfterTime', () {
      final user = UserRecord.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          localId: 'user-tokens',
          createdAt: '0',
          validSince: '1234567890',
        ),
      );

      expect(
        user.tokensValidAfterTime,
        DateTime.fromMillisecondsSinceEpoch(1234567890000, isUtc: true),
      );
    });

    test('fromResponse parses multiFactor when present', () {
      final user = UserRecord.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          localId: 'user-mfa',
          createdAt: '0',
          mfaInfo: [
            auth1.GoogleCloudIdentitytoolkitV1MfaEnrollment(
              mfaEnrollmentId: 'mfa-123',
              phoneInfo: '+15555555555',
              enrolledAt: '1000',
            ),
          ],
        ),
      );

      expect(user.multiFactor, isNotNull);
      expect(user.multiFactor!.enrolledFactors, hasLength(1));
    });

    test('fromResponse sets multiFactor to null when no enrolled factors', () {
      final user = UserRecord.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          localId: 'user-no-mfa',
          createdAt: '0',
          mfaInfo: [],
        ),
      );

      expect(user.multiFactor, isNull);
    });

    test('toJson serialization with minimal fields', () {
      final user = UserRecord.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          localId: 'user-json',
          createdAt: '0',
        ),
      );

      final json = user.toJson();
      expect(json['uid'], 'user-json');
      expect(json['disabled'], false);
      expect(json['emailVerified'], false);
      expect(json['metadata'], isNotNull);
      expect(json['providerData'], isList);
      expect(json['providerData'], isEmpty);
    });

    test('toJson serialization with all fields', () {
      final user = UserRecord.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          localId: 'user-full',
          createdAt: '1000',
          email: 'full@example.com',
          emailVerified: true,
          displayName: 'Full User',
          photoUrl: 'https://example.com/photo.jpg',
          phoneNumber: '+15555555555',
          disabled: true,
          passwordHash: 'hash123',
          salt: 'salt456',
          customAttributes: '{"admin":true}',
          tenantId: 'tenant-1',
          validSince: '2000',
          mfaInfo: [
            auth1.GoogleCloudIdentitytoolkitV1MfaEnrollment(
              mfaEnrollmentId: 'mfa-1',
              phoneInfo: '+11111111111',
              enrolledAt: '3000',
            ),
          ],
        ),
      );

      final json = user.toJson();
      expect(json['uid'], 'user-full');
      expect(json['email'], 'full@example.com');
      expect(json['emailVerified'], true);
      expect(json['displayName'], 'Full User');
      expect(json['photoURL'], 'https://example.com/photo.jpg');
      expect(json['phoneNumber'], '+15555555555');
      expect(json['disabled'], true);
      expect(json['passwordHash'], 'hash123');
      expect(json['passwordSalt'], 'salt456');
      expect(json['customClaims'], isNotNull);
      expect(json['tenantId'], 'tenant-1');
      expect(json['tokensValidAfterTime'], isNotNull);
      expect(json['multiFactor'], isNotNull);
    });
  });
}
