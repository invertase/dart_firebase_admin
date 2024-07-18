import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';

void main() {
  group('Timestamp', () {
    test('constructor', () {
      final now = DateTime.now().toUtc();
      final seconds = now.millisecondsSinceEpoch ~/ 1000;
      final nanoseconds =
          (now.microsecondsSinceEpoch - seconds * 1000 * 1000) * 1000;

      expect(
        Timestamp(seconds: seconds, nanoseconds: nanoseconds),
        Timestamp.fromDate(now),
      );
    });

    test('fromDate constructor', () {
      final now = DateTime.now().toUtc();
      final timestamp = Timestamp.fromDate(now);

      expect(timestamp.seconds, now.millisecondsSinceEpoch ~/ 1000);
    });

    test('fromMillis constructor', () {
      final now = DateTime.now().toUtc();
      final timestamp = Timestamp.fromMillis(now.millisecondsSinceEpoch);

      expect(timestamp.seconds, now.millisecondsSinceEpoch ~/ 1000);
      expect(
        timestamp.nanoseconds,
        (now.millisecondsSinceEpoch % 1000) * (1000 * 1000),
      );
    });

    test('fromMicros constructor', () {
      final now = DateTime.now().toUtc();
      final timestamp = Timestamp.fromMicros(now.microsecondsSinceEpoch);

      expect(timestamp.seconds, now.microsecondsSinceEpoch ~/ (1000 * 1000));
      expect(
        timestamp.nanoseconds,
        (now.microsecondsSinceEpoch % (1000 * 1000)) * 1000,
      );
    });
  });
}
