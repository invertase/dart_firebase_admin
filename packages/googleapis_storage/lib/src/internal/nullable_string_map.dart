import 'dart:collection';

/// A map that claims to be `Map<String, String>` but can hold null values.
///
/// ## Why This Exists
///
/// The Google Cloud Storage API requires `null` values to delete labels:
/// ```json
/// PATCH /storage/v1/b/bucket-name
/// {"labels": {"labelToDelete": null}}
/// ```
///
/// However, the `googleapis` Dart package types `Bucket.labels` as
/// `Map<String, String>?`, which doesn't allow `null` values within the map
/// (only the entire map can be null).
///
/// ## How It Works
///
/// This class extends `MapBase<String, String>` so it satisfies the type system,
/// but internally stores a `Map<String, dynamic>` that can hold null values.
///
/// The key trick is overriding `forEach` to use dynamic invocation:
/// ```dart
/// (action as dynamic)(key, value);  // Bypasses parameter type check
/// ```
///
/// When `json.encode()` serializes this map, it calls `forEach` which passes
/// the raw values (including null) to the JSON encoder, producing the correct
/// output: `{"labelone": null, "labeltwo": null}`.
///
/// ## Usage
///
/// ```dart
/// final nullLabels = <String, dynamic>{'labelToDelete': null};
/// bucket.labels = NullableStringMap(nullLabels);
/// // When serialized: {"labels": {"labelToDelete": null}}
/// ```
///
/// ## Technical Details
///
/// Dart's type system has two layers:
/// 1. **Compile-time** - Checked by the analyzer (bypassed via `dynamic`)
/// 2. **Runtime** - Checked when code executes
///
/// Normally, assigning `Map<String, dynamic>` to `Map<String, String>?` fails
/// at runtime. But by extending `MapBase<String, String>`, this class IS a
/// `Map<String, String>` as far as the type system is concerned.
///
/// The `forEach` override uses `(action as dynamic)` to call the callback
/// without Dart checking that the value parameter is actually a `String`.
class NullableStringMap extends MapBase<String, String> {
  final Map<String, dynamic> _inner;

  /// Creates a [NullableStringMap] wrapping the given [map].
  ///
  /// The [map] can contain `null` values which will be passed through
  /// during iteration (e.g., for JSON serialization).
  NullableStringMap(Map<String, dynamic> map) : _inner = map;

  @override
  String? operator [](Object? key) => _inner[key] as String?;

  @override
  void operator []=(String key, String value) => _inner[key] = value;

  @override
  void clear() => _inner.clear();

  @override
  Iterable<String> get keys => _inner.keys;

  @override
  String? remove(Object? key) => _inner.remove(key) as String?;

  @override
  void forEach(void Function(String key, String value) action) {
    _inner.forEach((key, value) {
      // Use dynamic invocation to bypass the parameter type check.
      // Normally Dart would verify that `value` is a String, but casting
      // `action` to dynamic skips this check, allowing null to pass through.
      // ignore: avoid_dynamic_calls
      (action as dynamic)(key, value);
    });
  }
}
