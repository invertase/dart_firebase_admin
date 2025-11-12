part of '../storage.dart';

class PreconditionOptions {
  PreconditionOptions({
    this.ifGenerationMatch,
    this.ifGenerationNotMatch,
    this.ifMetagenerationMatch,
    this.ifMetagenerationNotMatch,
  });

  final PreconditionOption? ifGenerationMatch;
  final PreconditionOption? ifGenerationNotMatch;
  final PreconditionOption? ifMetagenerationMatch;
  final PreconditionOption? ifMetagenerationNotMatch;
}

sealed class PreconditionOption {
  PreconditionOption._();

  factory PreconditionOption.string(String value) =>
      _PreconditionOptionString(value);
  factory PreconditionOption.int(int value) => _PreconditionOptionInt(value);
}

final class _PreconditionOptionString extends PreconditionOption {
  _PreconditionOptionString(this.value) : super._();
  final String value;
}

final class _PreconditionOptionInt extends PreconditionOption {
  _PreconditionOptionInt(this.value) : super._();
  final int value;
}
