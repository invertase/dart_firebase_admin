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

/// A Timestamp represents a point in time independent of any time zone or calendar,
/// represented as seconds and fractions of seconds at nanosecond resolution in UTC
/// Epoch time. It is encoded using the Proleptic Gregorian Calendar which extends
/// the Gregorian calendar backwards to year one. It is encoded assuming all minutes
/// are 60 seconds long, i.e. leap seconds are "smeared" so that no leap second table
/// is needed for interpretation. Range is from 0001-01-01T00:00:00Z to
/// 9999-12-31T23:59:59.999999999Z. By restricting to that range, we ensure that we
/// can convert to and from RFC 3339 date strings.
///
/// For more information, see [the reference timestamp definition](https://github.com/google/protobuf/blob/master/src/google/protobuf/timestamp.proto)
@immutable
final class Timestamp implements _Serializable {
  Timestamp({required this.seconds, required this.nanoseconds}) {
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
    return Timestamp.fromMicros(date.microsecondsSinceEpoch);
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

    return Timestamp(seconds: seconds, nanoseconds: nanos);
  }

  /// Creates a new timestamp from the given number of microseconds.
  ///
  /// ```dart
  /// final documentRef = firestore.doc('col/doc');
  ///
  /// documentRef.set({ 'startTime': Timestamp.fromMicros(42) });
  /// ```
  ///
  /// - [microseconds]: Number of microseconds since Unix epoch
  /// 1970-01-01T00:00:00Z.
  ///
  /// Returns a new [Timestamp] representing the same point in time
  /// as the given number of microseconds.
  factory Timestamp.fromMicros(int microseconds) {
    final seconds = (microseconds / 1000 / 1000).floor();
    final nanos = (microseconds - seconds * 1000 * 1000) * _usToNanos;

    return Timestamp(seconds: seconds, nanoseconds: nanos);
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

    return Timestamp(
      seconds: date.millisecondsSinceEpoch ~/ 1000,
      nanoseconds: nanos,
    );
  }

  static const _msToNanos = 1000000;
  static const _usToNanos = 1000;

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
