part of '../storage.dart';

abstract class CRC32CValidatorGenerator {}

abstract class CRC32CValidator extends CRC32CValidatorGenerator {
  @override
  String toString();

  bool validate(String value);

  void update(List<int> data); // TODO: Buffer
}

class CRC32C implements CRC32CValidator {
  @override
  String toString() {
    throw UnimplementedError('TODO');
  }

  @override
  bool validate(String value) {
    throw UnimplementedError('TODO');
  }

  @override
  void update(List<int> data) {
    throw UnimplementedError('TODO');
  }
}
