part of '../firestore.dart';

// Internal stage classes - NOT exported

/// Base class for pipeline stages (internal use only).
@immutable
abstract class _Stage {
  const _Stage();
}

/// Collection stage.
@immutable
class _CollectionStage extends _Stage {
  const _CollectionStage(this.collectionId);

  final String collectionId;
}

/// Collection group stage.
@immutable
class _CollectionGroupStage extends _Stage {
  const _CollectionGroupStage(this.collectionId);

  final String collectionId;
}

/// Database stage.
@immutable
class _DatabaseStage extends _Stage {
  const _DatabaseStage(this.database);

  final String database;
}

/// Documents stage.
@immutable
class _DocumentsStage extends _Stage {
  const _DocumentsStage(this.documents);

  final List<DocumentReference<Object?>> documents;
}

/// Select stage.
@immutable
class _SelectStage extends _Stage {
  const _SelectStage(this.fields);

  final List<Selectable> fields;
}

/// AddFields stage.
@immutable
class _AddFieldsStage extends _Stage {
  const _AddFieldsStage(this.fields);

  final Map<String, Expression> fields;
}

/// RemoveFields stage.
@immutable
class _RemoveFieldsStage extends _Stage {
  const _RemoveFieldsStage(this.fields);

  final List<String> fields;
}

/// Where stage.
@immutable
class _WhereStage extends _Stage {
  const _WhereStage(this.condition);

  final BooleanExpression condition;
}

/// Sort stage.
@immutable
class _SortStage extends _Stage {
  const _SortStage(this.orderings);

  final List<Ordering> orderings;
}

/// Limit stage.
@immutable
class _LimitStage extends _Stage {
  const _LimitStage(this.limit);

  final int limit;
}

/// Offset stage.
@immutable
class _OffsetStage extends _Stage {
  const _OffsetStage(this.offset);

  final int offset;
}

/// Distinct stage.
@immutable
class _DistinctStage extends _Stage {
  const _DistinctStage(this.fields);

  final List<Expression> fields;
}

/// Aggregate stage.
@immutable
class _AggregateStage extends _Stage {
  const _AggregateStage(this.aggregates, this.groupBy);

  final List<AliasedAggregate> aggregates;
  final List<Expression>? groupBy;
}

/// FindNearest stage.
@immutable
class _FindNearestStage extends _Stage {
  const _FindNearestStage({
    required this.vectorField,
    required this.queryVector,
    required this.limit,
    required this.distanceMeasure,
    this.distanceResultField,
  });

  final Expression vectorField;
  final Expression queryVector;
  final int limit;
  final String distanceMeasure;
  final String? distanceResultField;
}

/// ReplaceWith stage.
@immutable
class _ReplaceWithStage extends _Stage {
  const _ReplaceWithStage(this.expression);

  final Expression expression;
}

/// Sample stage.
@immutable
class _SampleStage extends _Stage {
  const _SampleStage(this.size);

  final int size;
}

/// Union stage.
@immutable
class _UnionStage extends _Stage {
  const _UnionStage(this.pipelines);

  final List<Pipeline> pipelines;
}

/// Unnest stage.
@immutable
class _UnnestStage extends _Stage {
  const _UnnestStage(
    this.field,
    this.alias, {
    required this.preserveNullAndEmptyArrays,
    this.indexField,
  });

  final Expression field;
  final String alias;
  final bool preserveNullAndEmptyArrays;
  final String? indexField;
}

/// Raw stage (for custom stages).
@immutable
class _RawStage extends _Stage {
  const _RawStage(this.data);

  final Map<String, dynamic> data;
}
