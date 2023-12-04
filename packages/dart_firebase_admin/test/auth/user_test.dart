import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/src/auth.dart' show UserMetadataToJson;
import 'package:firebaseapis/identitytoolkit/v1.dart' as auth1;
import 'package:test/test.dart';

void main() {
  group('UserMetadata', () {
    test('_toJson', () {
      final now = DateTime.now().toUtc();

      final metadata = UserMetadata.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          createdAt: '0',
          lastLoginAt: '0',
          lastRefreshAt: now.toIso8601String(),
        ),
      );

      final json = metadata.toJson();
      expect(
        json,
        {
          'lastSignInTime': '0',
          'creationTime': '0',
          'lastRefreshTime': now.toIso8601String(),
        },
      );

      final recoded = UserMetadata.fromResponse(
        auth1.GoogleCloudIdentitytoolkitV1UserInfo(
          createdAt: json['creationTime']! as String,
          lastLoginAt: json['lastSignInTime']! as String,
          lastRefreshAt: json['lastRefreshTime']! as String,
        ),
      );

      expect(recoded.creationTime, metadata.creationTime);
      expect(recoded.lastSignInTime, metadata.lastSignInTime);
      expect(recoded.lastRefreshTime, metadata.lastRefreshTime);
    });
  });
}
