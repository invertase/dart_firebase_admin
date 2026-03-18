part of '../firestore.dart';

enum _Direction {
  ascending('ASCENDING'),
  descending('DESCENDING');

  const _Direction(this.value);

  final String value;
}
