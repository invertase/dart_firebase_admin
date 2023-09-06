part of 'firestore.dart';

/// Encode seconds+nanoseconds to a Google Firestore timestamp string.
String _toGoogleDateTime({required int seconds, required int nanoseconds}) {
  final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  var formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(date);

  if (nanoseconds > 0) {
    final nanoString =
        nanoseconds.toString().padLeft(9, '0'); // Ensure it has 9 digits
    formattedDate = '$formattedDate.$nanoString';
  }

  return '${formattedDate}Z';
}

@immutable
class Timestamp implements _Serializable {
  Timestamp._({required this.seconds, required this.nanoseconds}) {
    const minSeconds = -62135596800;
    const maxSeconds = 253402300799;

    if (seconds < minSeconds || seconds > maxSeconds) {
      throw ArgumentError.value(
        seconds,
        'seconds',
        'must be between $minSeconds and $maxSeconds.',
      );
    }

    const maxNanoSeconds = 999999999;
    if (nanoseconds < 0 || nanoseconds > maxNanoSeconds) {
      throw ArgumentError.value(
        nanoseconds,
        'nanoseconds',
        'must be between 0 and $maxNanoSeconds.',
      );
    }
  }

  /// Creates a new timestamp with the current date, with millisecond precision.
  ///
  /// ```dart
  /// final documentRef = firestore.doc('col/doc');
  ///
  /// documentRef.set({'updateTime': Timestamp.now()});
  /// ```
  /// Returns a new `Timestamp` representing the current date.
  factory Timestamp.now() => Timestamp.fromDate(DateTime.now());

  /// Creates a new timestamp from the given date.
  ///
  /// ```dart
  /// final documentRef = firestore.doc('col/doc');
  ///
  /// final date = Date.parse('01 Jan 2000 00:00:00 GMT');
  /// documentRef.set({ 'startTime': Timestamp.fromDate(date) });
  ///
  /// ```
  ///
  /// - [date]: The date to initialize the `Timestamp` from.
  ///
  /// Returns a new [Timestamp] representing the same point in time
  /// as the given date.
  factory Timestamp.fromDate(DateTime date) {
    return Timestamp.fromMillis(date.millisecondsSinceEpoch);
  }

  /// Creates a new timestamp from the given number of milliseconds.
  ///
  /// ```dart
  /// final documentRef = firestore.doc('col/doc');
  ///
  /// documentRef.set({ 'startTime': Timestamp.fromMillis(42) });
  /// ```
  ///
  /// - [milliseconds]: Number of milliseconds since Unix epoch
  /// 1970-01-01T00:00:00Z.
  ///
  /// Returns a new [Timestamp] representing the same point in time
  /// as the given number of milliseconds.
  factory Timestamp.fromMillis(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final nanos = (milliseconds - seconds * 1000) * _msToNanos;
    return Timestamp._(seconds: seconds, nanoseconds: nanos);
  }

  factory Timestamp._fromString(String timestampValue) {
    final date = DateTime.parse(timestampValue);
    var nanos = 0;

    if (timestampValue.length > 20) {
      final nanoString = timestampValue.substring(
        20,
        timestampValue.length - 1,
      );
      final trailingZeroes = 9 - nanoString.length;
      nanos = int.parse(nanoString) * (math.pow(10, trailingZeroes).toInt());
    }

    if (nanos.isNaN || date.second.isNaN) {
      throw ArgumentError.value(
        timestampValue,
        'timestampValue',
        'Specify a valid ISO 8601 timestamp.',
      );
    }

    return Timestamp._(
      seconds: date.millisecondsSinceEpoch ~/ 1000,
      nanoseconds: nanos,
    );
  }

  static const _msToNanos = 1000000;

  final int seconds;
  final int nanoseconds;

  @override
  firestore1.Value _toProto() {
    return firestore1.Value(
      timestampValue: _toGoogleDateTime(
        seconds: seconds,
        nanoseconds: nanoseconds,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Timestamp &&
        seconds == other.seconds &&
        nanoseconds == other.nanoseconds;
  }

  @override
  int get hashCode => Object.hash(seconds, nanoseconds);

  @override
  String toString() {
    return 'Timestamp(seconds=$seconds, nanoseconds=$nanoseconds)';
  }
}
