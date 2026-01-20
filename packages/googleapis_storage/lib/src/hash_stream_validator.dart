part of '../googleapis_storage.dart';

/// Options for configuring a [HashStreamValidator].
class HashStreamValidatorOptions {
  /// Enables CRC32C calculation. To validate a provided value use [crc32cExpected].
  final bool crc32c;

  /// Enables MD5 calculation. To validate a provided value use [md5Expected].
  final bool md5;

  /// A CRC32C instance for validation. To validate a provided value use [crc32cExpected].
  final Crc32cValidator? crc32cInstance;

  /// Set a custom CRC32C generator. Used if [crc32cInstance] has not been provided.
  final Crc32Generator? crc32cGenerator;

  /// Sets the expected CRC32C value to verify once all data has been consumed.
  /// Also sets the [crc32c] option to `true`.
  final String? crc32cExpected;

  /// Sets the expected MD5 value to verify once all data has been consumed.
  /// Also sets the [md5] option to `true`.
  final String? md5Expected;

  /// Indicates whether or not to run a validation check or only update the hash values.
  final bool updateHashesOnly;

  const HashStreamValidatorOptions({
    this.crc32c = false,
    this.md5 = false,
    this.crc32cInstance,
    this.crc32cGenerator,
    this.crc32cExpected,
    this.md5Expected,
    this.updateHashesOnly = false,
  });
}

/// A stream transformer that validates CRC32C and/or MD5 hashes of streamed data.
///
/// This transformer passes through all data unchanged while calculating hashes
/// in the background. At the end of the stream, it validates the calculated
/// hashes against expected values (if provided) and throws an [ApiError] if
/// validation fails.
///
/// Example usage:
/// ```dart
/// final validator = HashStreamValidator(
///   HashStreamValidatorOptions(
///     crc32c: true,
///     crc32cExpected: 'rth90Q==',
///   ),
/// );
///
/// final validatedStream = inputStream.transform(validator);
/// ```
class HashStreamValidator extends StreamTransformerBase<List<int>, List<int>> {
  final bool crc32cEnabled;
  final bool md5Enabled;
  final bool updateHashesOnly;
  final String? crc32cExpected;
  final String? md5Expected;
  final Crc32cValidator? _crc32cHash;

  /// Creates a new [HashStreamValidator] with the given options.
  HashStreamValidator([HashStreamValidatorOptions? options])
    : crc32cEnabled =
          options?.crc32c == true || options?.crc32cExpected != null,
      md5Enabled = options?.md5 == true || options?.md5Expected != null,
      updateHashesOnly = options?.updateHashesOnly ?? false,
      crc32cExpected = options?.crc32cExpected,
      md5Expected = options?.md5Expected,
      _crc32cHash = _createCrc32cHash(options);

  static Crc32cValidator? _createCrc32cHash(
    HashStreamValidatorOptions? options,
  ) {
    if (options?.crc32c != true && options?.crc32cExpected == null) {
      return null;
    }

    if (options?.crc32cInstance != null) {
      return options!.crc32cInstance;
    }

    final generator =
        options?.crc32cGenerator ?? defaultCrc32cValidatorGenerator;
    return generator();
  }

  /// Returns the current CRC32C value as a base64-encoded string, if available.
  String? get crc32c => _crc32cHash?.toBase64();

  @override
  Stream<List<int>> bind(Stream<List<int>> stream) {
    // Create mutable copies for the transformer closure
    final crc32cHash = _crc32cHash;
    final md5Accumulator = md5Enabled ? <int>[] : null;

    return stream.transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (data, sink) {
          // Pass through the data unchanged
          sink.add(data);

          // Update hashes
          try {
            if (crc32cHash != null) {
              crc32cHash.update(data);
            }
            if (md5Accumulator != null) {
              md5Accumulator.addAll(data);
            }
          } catch (e) {
            sink.addError(e);
          }
        },
        handleDone: (sink) {
          // Calculate final MD5 digest
          String? md5Digest;
          if (md5Accumulator != null) {
            final digest = crypto.md5.convert(md5Accumulator);
            md5Digest = base64Encode(digest.bytes);
          }

          if (updateHashesOnly) {
            sink.close();
            return;
          }

          // Perform validation if expected values are provided
          // If we're doing validation, assume the worst-- a data integrity mismatch.
          // If not, these tests won't be performed, and we can assume the best.
          bool failed = crc32cEnabled || md5Enabled;

          if (crc32cEnabled && crc32cExpected != null && crc32cHash != null) {
            failed = !crc32cHash.validate(crc32cExpected!);
          }

          if (md5Enabled && md5Expected != null && md5Digest != null) {
            failed = md5Digest != md5Expected;
          }

          if (failed) {
            final mismatchError = ApiError(
              'The downloaded data did not match the data from the server. '
              'To be sure the content is the same, you should download the file again.',
            );
            sink.addError(mismatchError);
          } else {
            sink.close();
          }
        },
        handleError: (error, stackTrace, sink) {
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  /// Tests whether a hash value matches the calculated hash.
  ///
  /// [hash] must be either 'crc32c' or 'md5'.
  /// [sum] can be a base64-encoded string or a [Uint8List].
  ///
  /// Returns `true` if the hash matches, `false` otherwise.
  ///
  /// Note: For MD5, this method can only be called after the stream has completed
  /// and the digest has been calculated. This is typically used internally during
  /// validation in [handleDone].
  bool test(String hash, Object sum) {
    String check;
    if (sum is Uint8List) {
      check = base64Encode(sum);
    } else if (sum is String) {
      check = sum;
    } else {
      return false;
    }

    if (hash == 'crc32c' && _crc32cHash != null) {
      return _crc32cHash.validate(check);
    }

    // For MD5, we can't test here because the digest is only available
    // after the stream completes. This method is mainly for CRC32C.
    // MD5 validation is handled directly in handleDone.
    return false;
  }
}
