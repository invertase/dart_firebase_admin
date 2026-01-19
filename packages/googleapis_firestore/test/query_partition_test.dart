import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:test/test.dart';

void main() {
  group('QueryPartition Unit Tests', () {
    late Firestore firestore;

    setUp(() {
      firestore = Firestore(
        settings: const Settings(
          projectId: 'test-project',
          environmentOverride: {'GOOGLE_CLOUD_PROJECT': 'test-project'},
        ),
      );
    });

    group('getPartitions validation', () {
      test('validates partition count of zero', () async {
        final query = firestore.collectionGroup('collectionId');

        await expectLater(
          () async {
            await for (final _ in query.getPartitions(0)) {
              // Should not reach here
            }
          }(),
          throwsA(
            isA<FirestoreException>().having(
              (e) => e.message,
              'message',
              'Value for argument "desiredPartitionCount" must be within [1, Infinity] inclusive, but was: 0',
            ),
          ),
        );
      });

      test('validates negative partition count', () async {
        final query = firestore.collectionGroup('collectionId');

        await expectLater(
          () async {
            await for (final _ in query.getPartitions(-1)) {
              // Should not reach here
            }
          }(),
          throwsA(
            isA<FirestoreException>().having(
              (e) => e.message,
              'message',
              'Value for argument "desiredPartitionCount" must be within [1, Infinity] inclusive, but was: -1',
            ),
          ),
        );
      });
    });
  });
}
