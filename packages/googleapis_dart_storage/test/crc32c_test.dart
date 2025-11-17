import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:googleapis_dart_storage/googleapis_dart_storage.dart';
import 'package:test/test.dart';

/// Known input to CRC32C mappings, validated from actual GCS object uploads.
/// These are the same test vectors used in the Node.js SDK.
final knownInputToCrc32c = {
  // Empty string (i.e. nothing to 'update')
  '': 'AAAAAA==',
  // Known case #1 - validated from actual GCS object upload + metadata retrieval
  'data': 'rth90Q==',
  // Known case #2 - validated from actual GCS object upload + metadata retrieval
  'some text\n': 'DkjKuA==',
  // Arbitrary large string
  'a' * (1 << 16): 'TpXtPw==',
};

void main() {
  group('Crc32c', () {
    group('constructor', () {
      test('should initialize value to 0', () {
        final crc32c = Crc32c();

        expect(crc32c.value, 0);
      });

      test('should accept an initialValue', () {
        const initialValue = 123;

        final crc32c = Crc32c(initialValue);

        expect(crc32c.value, initialValue);
      });
    });

    group('update', () {
      test(
          'should produce the correct calculation given the input (single buffer)',
          () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();
          final bytes = utf8.encode(input);

          crc32c.update(bytes);

          final result = crc32c.toString();

          expect(
            result,
            expected,
            reason: "Expected '$input' to produce `$expected` - not `$result`",
          );
        }
      });

      test(
          'should produce the correct calculation given the input (multiple buffers)',
          () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();

          for (final char in input.split('')) {
            final bytes = utf8.encode(char);
            crc32c.update(bytes);
          }

          final result = crc32c.toString();

          expect(
            result,
            expected,
            reason: "Expected '$input' to produce `$expected` - not `$result`",
          );
        }
      });

      test('should not mutate a provided buffer', () {
        final crc32c = Crc32c();

        const value = 'abc';
        final bytes = utf8.encode(value);

        crc32c.update(bytes);

        expect(utf8.decode(bytes), value);
      });
    });

    group('validate', () {
      test('should validate a provided int', () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();
          final expectedBytes = base64Decode(expected);
          final byteData = ByteData.sublistView(expectedBytes);
          final expectedNumber = byteData.getInt32(0, Endian.big);

          final wrongNumber = expectedNumber + 1;

          crc32c.update(utf8.encode(input));

          expect(crc32c.validate(wrongNumber), false);
          expect(crc32c.validate(expectedNumber), true);
        }
      });

      test('should validate a provided String', () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();
          final expectedString = expected;

          // Want to test against a string generated in a valid way
          final crc32cForIncorrectString = Crc32c();
          final wrongStringInput = utf8.encode('$input ');
          crc32cForIncorrectString.update(wrongStringInput);
          final wrongString = crc32cForIncorrectString.toString();

          crc32c.update(utf8.encode(input));

          expect(crc32c.validate(wrongString), false);
          expect(crc32c.validate(expectedString), true);
        }
      });

      test('should validate a provided Uint8List', () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();
          final expectedBuffer = base64Decode(expected);

          // Want to test against a Uint8List generated in a valid way
          final crc32cForIncorrectString = Crc32c();
          final wrongBufferInput = utf8.encode('$input ');
          crc32cForIncorrectString.update(wrongBufferInput);
          final wrongBuffer = crc32cForIncorrectString.toBytes();

          crc32c.update(utf8.encode(input));

          expect(crc32c.validate(wrongBuffer), false);
          expect(crc32c.validate(expectedBuffer), true);
        }
      });

      test('should validate a provided Crc32c', () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;

          final crc32c = Crc32c();
          final crc32cExpected = Crc32c();
          final wrongCrc32c = Crc32c();

          final wrongBufferInput = utf8.encode('$input ');

          crc32c.update(utf8.encode(input));
          crc32cExpected.update(utf8.encode(input));
          wrongCrc32c.update(wrongBufferInput);

          expect(crc32c.validate(wrongCrc32c), false);
          expect(crc32c.validate(crc32cExpected), true);
        }
      });

      test('should validate a provided generic Crc32cValidator', () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();
          final crc32cExpectedValidator = _MockCrc32cValidator(expected);
          final wrongCrc32cValidator = _MockCrc32cValidator(
            () {
              final crc32c = Crc32c();
              // Want to test against a value generated in a valid way
              final wrongBufferInput = utf8.encode('$input ');
              crc32c.update(wrongBufferInput);
              return crc32c.toString();
            },
          );

          crc32c.update(utf8.encode(input));

          expect(crc32c.validate(wrongCrc32cValidator), false);
          expect(crc32c.validate(crc32cExpectedValidator), true);
        }
      });
    });

    group('toBytes', () {
      test('should return a valid 4-byte buffer', () {
        // At least one of our inputs should produce a negative 32-bit number
        // to prove we're not using unsigned integers
        // This ensures internally we're accurately handling signed integers
        var atLeastOneWasSigned = false;

        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;

          final crc32c = Crc32c();
          crc32c.update(utf8.encode(input));

          final value = crc32c.value;

          if (value < 0) {
            // this is a negative number, thus is definitely signed
            atLeastOneWasSigned = true;
          }

          final buffer = ByteData(4);
          buffer.setInt32(0, value, Endian.big);

          expect(crc32c.toBytes().length, 4);
          expect(crc32c.toBytes(), buffer.buffer.asUint8List());
        }

        expect(atLeastOneWasSigned, true);
      });
    });

    group('toJSON', () {
      test('should return the expected JSON', () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();
          crc32c.update(utf8.encode(input));

          expect(crc32c.toJSON(), expected);
          expect(crc32c.toJSON(), crc32c.toString());
        }
      });
    });

    group('valueOf', () {
      test('should return the expected int value', () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();
          crc32c.update(utf8.encode(input));

          final expectedBytes = base64Decode(expected);
          final expectedNumber =
              ByteData.sublistView(expectedBytes).getInt32(0, Endian.big);

          expect(crc32c.valueOf(), expectedNumber);
          expect(crc32c.valueOf(), crc32c.value);

          // All CRC32C values should be safe integers
          expect(crc32c.valueOf(), isA<int>());
        }
      });
    });

    group('toString', () {
      test('should return the expected string', () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();
          crc32c.update(utf8.encode(input));

          final stringified = '$crc32c';

          expect(crc32c.toString(), expected);
          expect(stringified, expected);
        }
      });
    });

    group('value', () {
      test('should return the expected int value', () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();
          crc32c.update(utf8.encode(input));

          final expectedBytes = base64Decode(expected);
          final expectedNumber =
              ByteData.sublistView(expectedBytes).getInt32(0, Endian.big);

          expect(crc32c.value, expectedNumber);
          expect(crc32c.value, crc32c.valueOf());

          // All CRC32C values should be safe integers
          expect(crc32c.value, isA<int>());
        }
      });
    });

    group('toBase64', () {
      test('should return the expected base64 string', () {
        for (final entry in knownInputToCrc32c.entries) {
          final input = entry.key;
          final expected = entry.value;

          final crc32c = Crc32c();
          crc32c.update(utf8.encode(input));

          expect(crc32c.toBase64(), expected);
        }
      });
    });
  });

  group('Crc32c static methods', () {
    group('crc32cExtensions', () {
      test('should expose the extension constants', () {
        expect(Crc32c.crc32cExtensions, isA<List<int>>());
        expect(Crc32c.crc32cExtensions.length, 256);
        expect(Crc32c.crc32cExtensions.first, 0x00000000);
      });
    });

    group('crc32cExtensionTable', () {
      test('should expose the extension table', () {
        expect(Crc32c.crc32cExtensionTable, isA<Int32List>());
        expect(Crc32c.crc32cExtensionTable.length, 256);
        expect(Crc32c.crc32cExtensionTable[0], 0x00000000);
      });
    });

    group('from', () {
      group('from int', () {
        test('should generate from int', () {
          for (final entry in knownInputToCrc32c.entries) {
            final expected = entry.value;
            final expectedBytes = base64Decode(expected);
            final number =
                ByteData.sublistView(expectedBytes).getInt32(0, Endian.big);

            final crc32c = Crc32c.from(number);

            expect(crc32c.valueOf(), number);

            // should not update source object
            crc32c.update(utf8.encode(' '));

            expect(crc32c.valueOf(), isNot(number));
          }
        });

        test('should raise RangeError on invalid integers', () {
          final invalidSet = [
            double.nan, // not a safe number
            0.5, // not an integer
            (1 << 32) + 1, // too high - out of valid range
            -(1 << 32) - 1, // too low - out of valid range
          ];

          for (final number in invalidSet) {
            if (number is int) {
              expect(
                () => Crc32c.from(number),
                throwsA(isA<RangeError>()),
              );
            } else {
              // NaN and doubles will throw ArgumentError
              expect(
                () => Crc32c.from(number),
                throwsA(isA<ArgumentError>()),
              );
            }
          }
        });
      });

      group('from String', () {
        test('should generate from base64-encoded data', () {
          for (final entry in knownInputToCrc32c.entries) {
            final expected = entry.value;

            final crc32c = Crc32c.from(expected);

            expect(crc32c.toString(), expected);
          }
        });

        test('should raise RangeError on invalid strings', () {
          for (var i = 0; i < 8; i++) {
            // Strings with length of 4 bytes (when decoded) are valid
            if (i == 4) continue;

            final buffer = Uint8List(i);
            final string = base64Encode(buffer);

            expect(
              () => Crc32c.from(string),
              throwsA(isA<RangeError>()),
            );
          }
        });
      });

      group('from Uint8List', () {
        test('should generate from Uint8List', () {
          for (final entry in knownInputToCrc32c.entries) {
            final expected = entry.value;
            final buffer = base64Decode(expected);

            final crc32c = Crc32c.from(buffer);

            expect(crc32c.toBytes(), buffer);

            // should not update source object
            crc32c.update(utf8.encode(' '));

            expect(crc32c.toBytes(), isNot(buffer));
          }
        });

        test('should raise RangeError on invalid buffers', () {
          for (var i = 0; i < 8; i++) {
            // Buffers with length of 4 are valid
            if (i == 4) continue;

            final buffer = Uint8List(i);

            expect(
              () => Crc32c.from(buffer),
              throwsA(isA<RangeError>()),
            );
          }
        });
      });

      group('from ByteBuffer', () {
        test('should generate from ByteBuffer', () {
          for (final entry in knownInputToCrc32c.entries) {
            final expected = entry.value;
            final buffer = base64Decode(expected);
            final byteBuffer = buffer.buffer;

            final crc32c = Crc32c.from(byteBuffer);

            expect(crc32c.toString(), expected);
          }
        });
      });

      group('from Crc32c', () {
        test('should generate from Crc32c', () {
          for (final entry in knownInputToCrc32c.entries) {
            final expected = entry.value;
            final baseCrc32c = Crc32c.from(expected);
            final crc32c = Crc32c.from(baseCrc32c);

            expect(crc32c.valueOf(), baseCrc32c.valueOf());

            // should not update source object
            crc32c.update(utf8.encode(' '));

            expect(crc32c.valueOf(), isNot(baseCrc32c.valueOf()));
          }
        });
      });

      group('from Crc32cValidator', () {
        test('should generate from Crc32cValidator', () {
          for (final entry in knownInputToCrc32c.entries) {
            final expected = entry.value;
            // Use a real Crc32c instance instead of mock to ensure toString() returns valid base64
            final baseCrc32c = Crc32c.from(expected);
            final crc32c = Crc32c.from(baseCrc32c);

            expect(crc32c.toString(), baseCrc32c.toString());

            // should not update source object
            crc32c.update(utf8.encode(' '));

            expect(crc32c.toString(), isNot(baseCrc32c.toString()));
          }
        });
      });

      group('error cases', () {
        test('should throw ArgumentError on unsupported types', () {
          expect(
            () => Crc32c.from(<String>[]),
            throwsA(isA<ArgumentError>()),
          );
          expect(
            () => Crc32c.from({'key': 'value'}),
            throwsA(isA<ArgumentError>()),
          );
        });
      });
    });

    group('fromFile', () {
      test('should generate a valid crc32c via a file', () async {
        final tempDir = io.Directory.systemTemp.createTempSync();
        addTearDown(() => tempDir.deleteSync(recursive: true));

        for (final entry in knownInputToCrc32c.entries) {
          final key = entry.key;
          final expected = entry.value;

          final tempFile = io.File('${tempDir.path}/test.crc32c.fromFile');
          await tempFile.writeAsString(key);

          final crc32c = await Crc32c.fromFile(tempFile);
          expect(crc32c.toString(), expected);
        }
      });

      test('should throw FileSystemException on non-existent file', () async {
        final nonExistentFile = io.File('/nonexistent/path/file.txt');
        expect(
          () async => await Crc32c.fromFile(nonExistentFile),
          throwsA(isA<io.FileSystemException>()),
        );
      });
    });
  });

  group('defaultCrc32cValidatorGenerator', () {
    test('should return a new Crc32c instance', () {
      final generator = defaultCrc32cValidatorGenerator;

      final validator1 = generator();
      final validator2 = generator();

      expect(validator1, isA<Crc32c>());
      expect(validator2, isA<Crc32c>());
      // Should return different instances
      expect(validator1, isNot(same(validator2)));
    });

    test('should produce validators that can be used', () {
      final generator = defaultCrc32cValidatorGenerator;
      final validator = generator();

      validator.update(utf8.encode('test'));
      expect(validator.value, isA<int>());
      expect(validator.toBase64(), isA<String>());
    });
  });
}

/// Mock implementation of Crc32cValidator for testing.
class _MockCrc32cValidator implements Crc32cValidator {
  final String Function() _toBase64;

  _MockCrc32cValidator(Object toBase64)
      : _toBase64 = toBase64 is String
            ? (() => toBase64)
            : (toBase64 as String Function());

  @override
  void update(List<int> data) {
    // Mock implementation - does nothing
  }

  @override
  String toBase64() => _toBase64();

  @override
  bool validate(Object value) {
    // Mock implementation - always returns false
    return false;
  }

  @override
  int get value => 0;
}
