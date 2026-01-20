import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:googleapis_storage/googleapis_storage.dart';
import 'package:test/test.dart';

void main() {
  group('HashStreamValidator', () {
    group('constructor', () {
      test('should create with default options', () {
        final validator = HashStreamValidator();
        expect(validator, isA<HashStreamValidator>());
      });

      test('should enable CRC32C when crc32c is true', () {
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true),
        );
        expect(validator.crc32c, isNotNull);
      });

      test('should enable CRC32C when crc32cExpected is provided', () {
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32cExpected: 'rth90Q=='),
        );
        expect(validator.crc32c, isNotNull);
      });

      test('should enable MD5 when md5 is true', () {
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(md5: true),
        );
        expect(validator, isA<HashStreamValidator>());
      });

      test('should enable MD5 when md5Expected is provided', () {
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(md5Expected: 'test'),
        );
        expect(validator, isA<HashStreamValidator>());
      });

      test('should use provided crc32cInstance', () {
        final instance = Crc32c();
        instance.update(utf8.encode('test'));
        final expectedCrc32c = instance.toBase64();

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true, crc32cInstance: instance),
        );

        expect(validator.crc32c, expectedCrc32c);
      });

      test('should use custom crc32cGenerator', () {
        Crc32cValidator customGenerator() => Crc32c(123);

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(
            crc32c: true,
            crc32cGenerator: customGenerator,
          ),
        );

        expect(validator.crc32c, isNotNull);
      });
    });

    group('data passthrough', () {
      test('should pass through data unchanged', () async {
        final inputData = utf8.encode('test data').toList();
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true),
        );

        final stream = Stream.value(inputData).transform<List<int>>(validator);
        final output = await stream.toList();

        expect(output, hasLength(1));
        expect(output[0], inputData);
      });

      test('should pass through multiple chunks unchanged', () async {
        final chunks = [
          utf8.encode('chunk1').toList(),
          utf8.encode('chunk2').toList(),
          utf8.encode('chunk3').toList(),
        ];
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true),
        );

        final stream = Stream.fromIterable(
          chunks,
        ).transform<List<int>>(validator);
        final output = await stream.toList();

        expect(output, chunks);
      });

      test('should pass through empty stream', () async {
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true),
        );

        final stream = Stream<List<int>>.empty().transform<List<int>>(
          validator,
        );
        final output = await stream.toList();

        expect(output, isEmpty);
      });
    });

    group('CRC32C validation', () {
      test('should calculate CRC32C correctly', () async {
        final input = 'data';
        final expectedCrc32c = 'rth90Q=='; // Known value from crc32c_test.dart

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(
            crc32c: true,
            crc32cExpected: expectedCrc32c,
          ),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await stream.drain();

        expect(validator.crc32c, expectedCrc32c);
      });

      test('should validate CRC32C successfully when hash matches', () async {
        final input = 'data';
        final expectedCrc32c = 'rth90Q==';

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(
            crc32c: true,
            crc32cExpected: expectedCrc32c,
          ),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsDone);
      });

      test('should throw ApiError when CRC32C does not match', () async {
        final input = 'data';
        final wrongCrc32c = 'AAAAAA==';

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true, crc32cExpected: wrongCrc32c),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsError(isA<ApiError>()));
      });

      test('should calculate CRC32C across multiple chunks', () async {
        final input = 'some text\n';
        final expectedCrc32c = 'DkjKuA=='; // Known value from crc32c_test.dart

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true),
        );

        // Split into chunks
        final chunks = input
            .split('')
            .map((c) => utf8.encode(c).toList())
            .toList();
        final stream = Stream.fromIterable(
          chunks,
        ).transform<List<int>>(validator);
        await stream.drain();

        expect(validator.crc32c, expectedCrc32c);
      });
    });

    group('MD5 validation', () {
      test('should calculate MD5 correctly', () async {
        final input = 'data';
        final md5Hash = crypto.md5.convert(utf8.encode(input));
        final expectedMd5 = base64Encode(md5Hash.bytes);

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(md5: true, md5Expected: expectedMd5),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsDone);
      });

      test('should validate MD5 successfully when hash matches', () async {
        final input = 'test data';
        final md5Hash = crypto.md5.convert(utf8.encode(input));
        final expectedMd5 = base64Encode(md5Hash.bytes);

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(md5: true, md5Expected: expectedMd5),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsDone);
      });

      test('should throw ApiError when MD5 does not match', () async {
        final input = 'test data';
        final wrongMd5 = 'AAAAAA==';

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(md5: true, md5Expected: wrongMd5),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsError(isA<ApiError>()));
      });

      test('should calculate MD5 across multiple chunks', () async {
        final input = 'some text\n';
        final md5Hash = crypto.md5.convert(utf8.encode(input));
        final expectedMd5 = base64Encode(md5Hash.bytes);

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(md5: true, md5Expected: expectedMd5),
        );

        // Split into chunks
        final chunks = input
            .split('')
            .map((c) => utf8.encode(c).toList())
            .toList();
        final stream = Stream.fromIterable(
          chunks,
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsDone);
      });
    });

    group('combined CRC32C and MD5 validation', () {
      test('should validate both hashes successfully', () async {
        final input = 'data';
        final expectedCrc32c = 'rth90Q==';
        final md5Hash = crypto.md5.convert(utf8.encode(input));
        final expectedMd5 = base64Encode(md5Hash.bytes);

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(
            crc32c: true,
            crc32cExpected: expectedCrc32c,
            md5: true,
            md5Expected: expectedMd5,
          ),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsDone);
      });

      test(
        'should throw ApiError when CRC32C matches but MD5 does not',
        () async {
          final input = 'data';
          final expectedCrc32c = 'rth90Q==';
          final wrongMd5 = 'AAAAAA==';

          final validator = HashStreamValidator(
            HashStreamValidatorOptions(
              crc32c: true,
              crc32cExpected: expectedCrc32c,
              md5: true,
              md5Expected: wrongMd5,
            ),
          );

          final stream = Stream.value(
            utf8.encode(input).toList(),
          ).transform<List<int>>(validator);
          await expectLater(stream, emitsError(isA<ApiError>()));
        },
      );

      test(
        'should throw ApiError when MD5 matches but CRC32C does not',
        () async {
          final input = 'data';
          final wrongCrc32c = 'AAAAAA==';
          final md5Hash = crypto.md5.convert(utf8.encode(input));
          final expectedMd5 = base64Encode(md5Hash.bytes);

          final validator = HashStreamValidator(
            HashStreamValidatorOptions(
              crc32c: true,
              crc32cExpected: wrongCrc32c,
              md5: true,
              md5Expected: expectedMd5,
            ),
          );

          final stream = Stream.value(
            utf8.encode(input).toList(),
          ).transform<List<int>>(validator);
          await expectLater(stream, emitsError(isA<ApiError>()));
        },
      );
    });

    group('updateHashesOnly mode', () {
      test('should calculate hashes without validation', () async {
        final input = 'data';
        final expectedCrc32c = 'rth90Q==';

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true, updateHashesOnly: true),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsDone);

        expect(validator.crc32c, expectedCrc32c);
      });

      test('should not throw error even with wrong expected hash', () async {
        final input = 'data';
        final wrongCrc32c = 'AAAAAA==';

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(
            crc32c: true,
            crc32cExpected: wrongCrc32c,
            updateHashesOnly: true,
          ),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsDone);
      });
    });

    group('test method', () {
      test('should test CRC32C with string', () async {
        final input = 'data';
        final expectedCrc32c = 'rth90Q==';

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await stream.drain();

        expect(validator.test('crc32c', expectedCrc32c), true);
        expect(validator.test('crc32c', 'AAAAAA=='), false);
      });

      test('should test CRC32C with Uint8List', () async {
        final input = 'data';
        final expectedCrc32c = 'rth90Q==';
        final expectedBytes = base64Decode(expectedCrc32c);

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true),
        );

        final stream = Stream.value(
          utf8.encode(input).toList(),
        ).transform<List<int>>(validator);
        await stream.drain();

        expect(validator.test('crc32c', expectedBytes), true);
      });

      test('should return false for invalid hash type', () async {
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true),
        );

        expect(validator.test('invalid', 'test'), false);
      });

      test('should return false for invalid sum type', () async {
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true),
        );

        expect(validator.test('crc32c', 123), false);
      });
    });

    group('error handling', () {
      test('should propagate errors from stream', () async {
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(crc32c: true),
        );

        final error = Exception('test error');
        final stream = Stream<List<int>>.error(
          error,
        ).transform<List<int>>(validator);

        await expectLater(stream, emitsError(error));
      });

      test('should handle errors during hash calculation', () async {
        // Create a validator with a custom CRC32C instance that throws
        final throwingValidator = _ThrowingCrc32cValidator();
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(
            crc32c: true,
            crc32cInstance: throwingValidator,
          ),
        );

        final stream = Stream.value(
          utf8.encode('test').toList(),
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsError(isA<Exception>()));
      });
    });

    group('edge cases', () {
      test('should handle empty data with CRC32C enabled', () async {
        final validator = HashStreamValidator(
          HashStreamValidatorOptions(
            crc32c: true,
            crc32cExpected: 'AAAAAA==', // Empty string CRC32C
          ),
        );

        final stream = Stream.value(<int>[]).transform<List<int>>(validator);
        await expectLater(stream, emitsDone);
      });

      test('should handle empty data with MD5 enabled', () async {
        final emptyMd5 = base64Encode(crypto.md5.convert([]).bytes);

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(md5: true, md5Expected: emptyMd5),
        );

        final stream = Stream.value(<int>[]).transform<List<int>>(validator);
        await expectLater(stream, emitsDone);
      });

      test('should handle large data streams', () async {
        final largeData = List.generate(10000, (i) => i % 256);
        final md5Hash = crypto.md5.convert(largeData);
        final expectedMd5 = base64Encode(md5Hash.bytes);

        final validator = HashStreamValidator(
          HashStreamValidatorOptions(md5: true, md5Expected: expectedMd5),
        );

        // Split into chunks
        final chunks = <List<int>>[];
        for (var i = 0; i < largeData.length; i += 100) {
          chunks.add(
            largeData.sublist(i, (i + 100).clamp(0, largeData.length)),
          );
        }

        final stream = Stream.fromIterable(
          chunks,
        ).transform<List<int>>(validator);
        await expectLater(stream, emitsDone);
      });
    });
  });
}

/// Mock CRC32C validator that throws on update for testing error handling.
class _ThrowingCrc32cValidator implements Crc32cValidator {
  @override
  void update(List<int> data) {
    throw Exception('Test error');
  }

  @override
  String toBase64() => 'AAAAAA==';

  @override
  bool validate(Object value) => false;

  @override
  int get value => 0;
}
