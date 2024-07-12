import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';

void main() {
  group('Timestamp', () {
    test('constructor', () {
      final now = DateTime.now().toUtc();
      final timestamp = Timestamp.fromDate(now);
      final seconds = now.millisecondsSinceEpoch ~/ 1000;
      final nanoseconds =
          (now.microsecondsSinceEpoch - seconds * 1000 * 1000) * 1000;
      expect(timestamp, Timestamp(seconds: seconds, nanoseconds: nanoseconds));
    });
    test('fromDate constructor', () {
      final now = DateTime.now().toUtc();
      final timestamp = Timestamp.fromDate(now);
      expect(timestamp.seconds, now.millisecondsSinceEpoch ~/ 1000);
    });
  });
}
