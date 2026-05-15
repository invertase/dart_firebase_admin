part of '../firestore.dart';

/// Entry point for creating Firestore pipelines.
///
/// Obtained via [Firestore.pipeline].
@immutable
final class PipelineSource {
  const PipelineSource._({required this.firestore});

  /// The Firestore instance.
  final Firestore firestore;

  /// Creates a pipeline that operates on documents in a specific collection.
  ///
  /// Example:
  /// ```dart
  /// firestore.pipeline().collection('cities')
  /// ```
  Pipeline collection(String collectionId) {
    return Pipeline._(
      firestore: firestore,
      stages: [_CollectionStage(collectionId)],
    );
  }

  /// Creates a pipeline that operates on all collections with the given ID.
  ///
  /// Example:
  /// ```dart
  /// firestore.pipeline().collectionGroup('landmarks')
  /// ```
  Pipeline collectionGroup(String collectionId) {
    return Pipeline._(
      firestore: firestore,
      stages: [_CollectionGroupStage(collectionId)],
    );
  }

  /// Creates a pipeline that operates on the entire database.
  ///
  /// Example:
  /// ```dart
  /// firestore.pipeline().database()
  /// ```
  Pipeline database() {
    return Pipeline._(
      firestore: firestore,
      stages: const [_DatabaseStage(kDefaultDatabase)],
    );
  }

  /// Creates a pipeline that operates on specific documents.
  ///
  /// Example:
  /// ```dart
  /// firestore.pipeline().documents([
  ///   firestore.doc('cities/SF'),
  ///   firestore.doc('cities/LA'),
  /// ])
  /// ```
  Pipeline documents(List<DocumentReference<Object?>> documents) {
    return Pipeline._(
      firestore: firestore,
      stages: [_DocumentsStage(documents)],
    );
  }

  /// Creates a pipeline from another pipeline (for composition).
  Pipeline createFrom(Pipeline source) {
    return Pipeline._(firestore: firestore, stages: List.from(source._stages));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineSource &&
          runtimeType == other.runtimeType &&
          firestore == other.firestore;

  @override
  int get hashCode => firestore.hashCode;

  @override
  String toString() => 'PipelineSource(firestore: $firestore)';
}

/// A Firestore pipeline for complex data transformations.
///
/// Pipelines provide a flexible framework for building multi-stage
/// data transformations and queries. Each method returns a new Pipeline
/// instance, allowing for method chaining.
///
/// Example:
/// ```dart
/// final pipeline = firestore
///   .pipeline()
///   .collection('books')
///   .where(greaterThan(field('rating'), constant(4.5)))
///   .select('title', 'author')
///   .sort(Ordering.descending(field('rating')))
///   .limit(10);
/// ```
@immutable
final class Pipeline {
  const Pipeline._({required this.firestore, required List<_Stage> stages})
    : _stages = stages;

  /// The Firestore instance.
  final Firestore firestore;

  /// The stages that make up this pipeline (internal).
  final List<_Stage> _stages;

  /// Adds fields to documents in the pipeline.
  ///
  /// Example:
  /// ```dart
  /// pipeline.addFields({
  ///   'fullName': stringConcat(field('firstName'), field('lastName')),
  ///   'discountedPrice': multiply(field('price'), constant(0.9)),
  /// })
  /// ```
  Pipeline addFields(Map<String, Expression> fields) {
    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _AddFieldsStage(fields)],
    );
  }

  /// Removes fields from documents in the pipeline.
  ///
  /// Example:
  /// ```dart
  /// pipeline.removeFields(['internalId', 'metadata'])
  /// ```
  Pipeline removeFields(List<String> fields) {
    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _RemoveFieldsStage(fields)],
    );
  }

  /// Selects specific fields to include in the results.
  ///
  /// Accepts field names (Strings), field paths (Lists), [Field]s, or [AliasedExpression]s.
  ///
  /// Example:
  /// ```dart
  /// pipeline.select([
  ///   'name',
  ///   'age',
  ///   Expression.field('price').as('cost'),
  /// ])
  /// ```
  Pipeline select(List<Object> fields) {
    if (fields.isEmpty) {
      throw ArgumentError('fields cannot be empty');
    }

    final selectables = <Selectable>[];

    for (final fieldArg in fields) {
      if (fieldArg is String) {
        selectables.add(Field._(fieldArg) as Selectable);
      } else if (fieldArg is List) {
        selectables.add(Field._(fieldArg.join('.')) as Selectable);
      } else if (fieldArg is AliasedExpression) {
        selectables.add(fieldArg);
      } else if (fieldArg is Field) {
        selectables.add(fieldArg);
      } else {
        throw ArgumentError('Invalid field type: ${fieldArg.runtimeType}');
      }
    }

    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _SelectStage(selectables)],
    );
  }

  /// Filters documents based on a condition.
  ///
  /// Example:
  /// ```dart
  /// pipeline.where(greaterThan(field('age'), constant(18)))
  /// ```
  Pipeline where(BooleanExpression condition) {
    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _WhereStage(condition)],
    );
  }

  /// Sorts documents by the specified orderings.
  ///
  /// Example:
  /// ```dart
  /// pipeline.sort([
  ///   Ordering.ascending(Expression.field('lastName')),
  ///   Ordering.descending(Expression.field('age')),
  /// ])
  /// ```
  Pipeline sort(List<Ordering> orderings) {
    if (orderings.isEmpty) {
      throw ArgumentError('orderings cannot be empty');
    }

    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _SortStage(orderings)],
    );
  }

  /// Limits the number of documents returned.
  ///
  /// Example:
  /// ```dart
  /// pipeline.limit(10)
  /// ```
  Pipeline limit(int count) {
    if (count <= 0) {
      throw ArgumentError('limit must be positive, got $count');
    }
    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _LimitStage(count)],
    );
  }

  /// Skips the specified number of documents.
  ///
  /// Example:
  /// ```dart
  /// pipeline.offset(20)
  /// ```
  Pipeline offset(int count) {
    if (count < 0) {
      throw ArgumentError('offset must be non-negative, got $count');
    }
    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _OffsetStage(count)],
    );
  }

  /// Returns only distinct values for the specified fields.
  ///
  /// Example:
  /// ```dart
  /// pipeline.distinct([
  ///   Expression.field('category'),
  ///   Expression.field('brand'),
  /// ])
  /// ```
  Pipeline distinct(List<Expression> fields) {
    if (fields.isEmpty) {
      throw ArgumentError('fields cannot be empty');
    }

    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _DistinctStage(fields)],
    );
  }

  /// Performs optionally grouped aggregation operations.
  ///
  /// This allows you to calculate aggregate values over a set of documents,
  /// optionally grouped by one or more fields or expressions. You can specify:
  ///
  /// - **Accumulators:** One or more aggregation operations to perform. Each
  ///   aggregation calculates a value (e.g., sum, average, count) based on the
  ///   documents within each group.
  /// - **Grouping:** Optional fields or expressions to group documents by. For
  ///   each distinct combination of values in these fields, a separate group is
  ///   created. If no grouping is specified, all documents are treated as a
  ///   single group.
  ///
  /// Example without grouping:
  /// ```dart
  /// pipeline.aggregate(
  ///   accumulators: [
  ///     AggregateFunction.count().as('totalCount'),
  ///     AggregateFunction.average('price').as('avgPrice'),
  ///   ],
  /// )
  /// ```
  ///
  /// Example with grouping:
  /// ```dart
  /// pipeline.aggregate(
  ///   accumulators: [
  ///     AggregateFunction.count().as('count'),
  ///     AggregateFunction.average('rating').as('avgRating'),
  ///   ],
  ///   groupBy: [Expression.field('category')],
  /// )
  /// ```
  Pipeline aggregate({
    required List<AliasedAggregate> accumulators,
    List<Expression>? groupBy,
  }) {
    if (accumulators.isEmpty) {
      throw ArgumentError('accumulators cannot be empty');
    }

    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _AggregateStage(accumulators, groupBy)],
    );
  }

  /// Finds documents nearest to a query vector.
  ///
  /// Example:
  /// ```dart
  /// pipeline.findNearest(
  ///   vectorField: field('embedding'),
  ///   queryVector: constant([0.1, 0.2, 0.3]),
  ///   limit: 10,
  ///   distanceMeasure: 'COSINE',
  /// )
  /// ```
  Pipeline findNearest({
    required Expression vectorField,
    required Expression queryVector,
    required int limit,
    required String distanceMeasure,
    String? distanceResultField,
  }) {
    return Pipeline._(
      firestore: firestore,
      stages: [
        ..._stages,
        _FindNearestStage(
          vectorField: vectorField,
          queryVector: queryVector,
          limit: limit,
          distanceMeasure: distanceMeasure,
          distanceResultField: distanceResultField,
        ),
      ],
    );
  }

  /// Replaces each document with the result of an expression.
  ///
  /// Example:
  /// ```dart
  /// pipeline.replaceWith(map({'name': field('fullName'), 'age': field('age')}))
  /// ```
  Pipeline replaceWith(Expression expression) {
    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _ReplaceWithStage(expression)],
    );
  }

  /// Randomly samples documents from the pipeline.
  ///
  /// Example:
  /// ```dart
  /// pipeline.sample(100)
  /// ```
  Pipeline sample(int size) {
    if (size <= 0) {
      throw ArgumentError('sample size must be positive, got $size');
    }
    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _SampleStage(size)],
    );
  }

  /// Combines this pipeline with other pipelines.
  ///
  /// Example:
  /// ```dart
  /// pipeline1.union([pipeline2, pipeline3])
  /// ```
  Pipeline union(List<Pipeline> pipelines) {
    if (pipelines.isEmpty) {
      throw ArgumentError('pipelines cannot be empty');
    }

    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _UnionStage(pipelines)],
    );
  }

  /// Produces a document for each element in an input array.
  ///
  /// For each input document, this stage emits zero or more augmented documents.
  /// The input array specified by [field] is evaluated, and for each array element,
  /// an augmented document is emitted with the array element value set to the alias
  /// field (if the field is an [AliasedExpression]).
  ///
  /// When [field] evaluates to a non-array value (e.g., number, null, absent), the
  /// stage becomes a no-op for that document, returning it as-is with the alias field
  /// absent. No documents are emitted when the field evaluates to an empty array,
  /// unless [preserveNullAndEmptyArrays] is true.
  ///
  /// Example:
  /// ```dart
  /// // Input: { "title": "Book", "tags": ["comedy", "space", "adventure"] }
  ///
  /// pipeline.unnest(
  ///   field: Expression.field('tags').as('tag'),
  ///   indexField: 'tagIndex',
  /// )
  ///
  /// // Output:
  /// // { "title": "Book", "tag": "comedy", "tagIndex": 0 }
  /// // { "title": "Book", "tag": "space", "tagIndex": 1 }
  /// // { "title": "Book", "tag": "adventure", "tagIndex": 2 }
  /// ```
  Pipeline unnest({
    required Selectable field,
    String? indexField,
    bool preserveNullAndEmptyArrays = false,
  }) {
    // Extract the expression and alias from the Selectable
    Expression expr;
    String alias;
    if (field is AliasedExpression) {
      expr = field.expression;
      alias = field.alias;
    } else if (field is Field) {
      expr = field;
      alias = field.fieldPath; // Use field path as alias
    } else {
      throw ArgumentError('field must be a Field or AliasedExpression');
    }

    return Pipeline._(
      firestore: firestore,
      stages: [
        ..._stages,
        _UnnestStage(
          expr,
          alias,
          preserveNullAndEmptyArrays: preserveNullAndEmptyArrays,
          indexField: indexField,
        ),
      ],
    );
  }

  /// Adds a raw stage to the pipeline (for advanced use cases).
  ///
  /// Example:
  /// ```dart
  /// pipeline.rawStage({'customStage': {'param': 'value'}})
  /// ```
  Pipeline rawStage(Map<String, dynamic> data) {
    return Pipeline._(
      firestore: firestore,
      stages: [..._stages, _RawStage(data)],
    );
  }

  /// Executes the pipeline and returns the results.
  ///
  /// Example:
  /// ```dart
  /// final snapshot = await pipeline.execute();
  /// for (final result in snapshot.results) {
  ///   print(result.data());
  /// }
  /// ```
  Future<PipelineSnapshot> execute() async {
    final request = firestore_v1.ExecutePipelineRequest(
      database: firestore._formattedDatabaseName,
      structuredPipeline: firestore_v1.StructuredPipeline(pipeline: _toProto()),
    );

    final stream = await firestore._firestoreClient.v1((api, projectId) async {
      return api.executePipeline(request);
    });

    final results = <PipelineResult>[];
    ExplainStats? explainStats;
    Timestamp? executionTime;

    await for (final response in stream) {
      if (response.executionTime != null) {
        executionTime = Timestamp._fromProto(response.executionTime!);
      }
      if (response.explainStats != null) {
        explainStats = ExplainStats._fromProto(response.explainStats!);
      }
      for (final resultDoc in response.results) {
        final data = <String, Object?>{
          for (final prop in resultDoc.fields.entries)
            prop.key: firestore._serializer.decodeValue(prop.value),
        };

        results.add(
          PipelineResult._(
            ref: resultDoc.name.isNotEmpty
                ? firestore.doc(resultDoc.name)
                : null,
            id: resultDoc.name.isNotEmpty
                ? resultDoc.name.split('/').last
                : null,
            createTime: resultDoc.createTime != null
                ? Timestamp._fromProto(resultDoc.createTime!)
                : null,
            updateTime: resultDoc.updateTime != null
                ? Timestamp._fromProto(resultDoc.updateTime!)
                : null,
            data: data,
          ),
        );
      }
    }

    return PipelineSnapshot._(
      pipeline: this,
      results: results,
      executionTime: executionTime ?? Timestamp.now(),
      explainStats: explainStats,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pipeline &&
          runtimeType == other.runtimeType &&
          firestore == other.firestore &&
          const ListEquality<_Stage>().equals(_stages, other._stages);

  @override
  int get hashCode =>
      Object.hash(firestore, const ListEquality<_Stage>().hash(_stages));

  @override
  String toString() => 'Pipeline(${_stages.length} stages)';

  /// Converts this pipeline to googleapis proto format.
  firestore_v1.Pipeline _toProto() {
    final stages = _stages.map(_stageToProto).toList();
    return firestore_v1.Pipeline(stages: stages);
  }

  /// Converts a stage to googleapis proto format.
  firestore_v1.Pipeline_Stage _stageToProto(_Stage stage) {
    switch (stage) {
      case _CollectionStage(:final collectionId):
        return firestore_v1.Pipeline_Stage(
          name: 'collection',
          args: [_collectionReferenceValue(collectionId)],
        );
      case _CollectionGroupStage(:final collectionId):
        return firestore_v1.Pipeline_Stage(
          name: 'collection_group',
          args: [_collectionReferenceValue(collectionId)],
        );
      case _DatabaseStage(:final database):
        return firestore_v1.Pipeline_Stage(
          name: 'database',
          args: [_databaseReferenceValue(database)],
        );
      case _DocumentsStage(:final documents):
        return firestore_v1.Pipeline_Stage(
          name: 'documents',
          args: documents.map((doc) => _stringValue(doc.path)).toList(),
        );
      case _SelectStage(:final fields):
        // Server expects a single map argument: Map<FieldName, Expr>
        final selectionsMap = <String, firestore_v1.Value>{};
        for (final selectable in fields) {
          if (selectable is AliasedExpression) {
            selectionsMap[selectable.alias] = _expressionToValue(
              selectable.expression,
            );
          } else if (selectable is Field) {
            // For fields without alias, use the field name as the key
            selectionsMap[selectable.fieldPath] = _expressionToValue(
              selectable,
            );
          }
        }
        return firestore_v1.Pipeline_Stage(
          name: 'select',
          args: [
            firestore_v1.Value(
              mapValue: firestore_v1.MapValue(fields: selectionsMap),
            ),
          ],
        );
      case _AddFieldsStage(:final fields):
        return firestore_v1.Pipeline_Stage(
          name: 'add_fields',
          options: fields.map((k, v) => MapEntry(k, _expressionToValue(v))),
        );
      case _RemoveFieldsStage(:final fields):
        return firestore_v1.Pipeline_Stage(
          name: 'remove_fields',
          args: fields
              .map((f) => firestore_v1.Value(fieldReferenceValue: f))
              .toList(),
        );
      case _WhereStage(:final condition):
        return firestore_v1.Pipeline_Stage(
          name: 'where',
          args: [_expressionToValue(condition)],
        );
      case _SortStage(:final orderings):
        return firestore_v1.Pipeline_Stage(
          name: 'sort',
          args: orderings.map(_orderingToValue).toList(),
        );
      case _LimitStage(:final limit):
        return firestore_v1.Pipeline_Stage(
          name: 'limit',
          args: [_intValue(limit)],
        );
      case _OffsetStage(:final offset):
        return firestore_v1.Pipeline_Stage(
          name: 'offset',
          args: [_intValue(offset)],
        );
      case _DistinctStage(:final fields):
        // Server expects a single map argument: Map<FieldName, Expr>
        final groupsMap = <String, firestore_v1.Value>{};
        for (var i = 0; i < fields.length; i++) {
          // Use field name as key if available, otherwise use index
          final key = fields[i] is Field
              ? (fields[i] as Field).fieldPath
              : 'field_$i';
          groupsMap[key] = _expressionToValue(fields[i]);
        }
        return firestore_v1.Pipeline_Stage(
          name: 'distinct',
          args: [
            firestore_v1.Value(
              mapValue: firestore_v1.MapValue(fields: groupsMap),
            ),
          ],
        );
      case _AggregateStage(:final aggregates, :final groupBy):
        // Server expects 2 args: (accumulators Map, groups Map)
        final accumulatorsMap = <String, firestore_v1.Value>{};
        for (final agg in aggregates) {
          accumulatorsMap[agg.alias] = agg.aggregate._toProto(firestore);
        }

        final groupsMap = <String, firestore_v1.Value>{};
        if (groupBy != null) {
          for (var i = 0; i < groupBy.length; i++) {
            // Use field name as key if available, otherwise use index
            final key = groupBy[i] is Field
                ? (groupBy[i] as Field).fieldPath
                : 'group_$i';
            groupsMap[key] = _expressionToValue(groupBy[i]);
          }
        }

        return firestore_v1.Pipeline_Stage(
          name: 'aggregate',
          args: [
            firestore_v1.Value(
              mapValue: firestore_v1.MapValue(fields: accumulatorsMap),
            ),
            firestore_v1.Value(
              mapValue: firestore_v1.MapValue(fields: groupsMap),
            ),
          ],
        );
      case _FindNearestStage(
        :final vectorField,
        :final queryVector,
        :final limit,
        :final distanceMeasure,
        :final distanceResultField,
      ):
        return firestore_v1.Pipeline_Stage(
          name: 'find_nearest',
          options: {
            'vector_field': _expressionToValue(vectorField),
            'query_vector': _expressionToValue(queryVector),
            'limit': _intValue(limit),
            'distance_measure': _stringValue(distanceMeasure),
            if (distanceResultField != null)
              'distance_result_field': firestore_v1.Value(
                fieldReferenceValue: distanceResultField,
              ),
          },
        );
      case _ReplaceWithStage(:final expression):
        return firestore_v1.Pipeline_Stage(
          name: 'replace_with',
          args: [_expressionToValue(expression)],
        );
      case _SampleStage(:final size):
        return firestore_v1.Pipeline_Stage(
          name: 'sample',
          args: [_intValue(size)],
        );
      case _UnionStage(:final pipelines):
        return firestore_v1.Pipeline_Stage(
          name: 'union',
          args: pipelines.map((p) => _pipelineValue(p._toProto())).toList(),
        );
      case _UnnestStage(
        :final field,
        :final alias,
        :final preserveNullAndEmptyArrays,
        :final indexField,
      ):
        // Server expects 2 args: (field Expr, alias FieldName)
        // Note: preserve_null_and_empty_arrays is not supported by the server
        return firestore_v1.Pipeline_Stage(
          name: 'unnest',
          args: [
            _expressionToValue(field),
            firestore_v1.Value(
              fieldReferenceValue: alias,
            ), // Field reference for alias
          ],
          options: indexField != null
              ? {
                  'index_field': firestore_v1.Value(
                    fieldReferenceValue: indexField,
                  ),
                }
              : const {},
        );
      case _RawStage(:final data):
        // For raw stages, convert the data map directly
        final name = data.keys.first;
        final value = data[name];
        return firestore_v1.Pipeline_Stage(
          name: name,
          args: value is List ? value.map(_anyToValue).toList() : const [],
          options: value is Map
              ? (value as Map<String, dynamic>).map(
                  (k, v) => MapEntry(k, _anyToValue(v)),
                )
              : const {},
        );
      default:
        throw ArgumentError('Unknown stage type: ${stage.runtimeType}');
    }
  }

  // Value conversion helpers
  firestore_v1.Value _stringValue(String value) =>
      firestore_v1.Value(stringValue: value);

  firestore_v1.Value _intValue(int value) =>
      firestore_v1.Value(integerValue: value);

  firestore_v1.Value _boolValue(bool value) =>
      firestore_v1.Value(booleanValue: value);

  firestore_v1.Value _collectionReferenceValue(String collectionId) {
    // Prepend slash if not present (matching Node.js SDK behavior)
    final path = collectionId.startsWith('/') ? collectionId : '/$collectionId';
    return firestore_v1.Value(referenceValue: path);
  }

  firestore_v1.Value _databaseReferenceValue(String databasePath) {
    // Prepend slash if not present
    final path = databasePath.startsWith('/') ? databasePath : '/$databasePath';
    return firestore_v1.Value(referenceValue: path);
  }

  firestore_v1.Value _arrayValue(List<firestore_v1.Value> values) =>
      firestore_v1.Value(arrayValue: firestore_v1.ArrayValue(values: values));

  firestore_v1.Value _pipelineValue(firestore_v1.Pipeline pipeline) =>
      firestore_v1.Value(
        mapValue: firestore_v1.MapValue(
          fields: {
            'stages': _arrayValue(pipeline.stages.map(_stageValue).toList()),
          },
        ),
      );

  firestore_v1.Value _stageValue(firestore_v1.Pipeline_Stage stage) =>
      firestore_v1.Value(
        mapValue: firestore_v1.MapValue(
          fields: {
            'name': _stringValue(stage.name),
            if (stage.args.isNotEmpty) 'args': _arrayValue(stage.args),
            if (stage.options.isNotEmpty)
              'options': firestore_v1.Value(
                mapValue: firestore_v1.MapValue(fields: stage.options),
              ),
          },
        ),
      );

  firestore_v1.Value _expressionToValue(Expression expr) {
    return expr._toProto(firestore);
  }

  firestore_v1.Value _orderingToValue(Ordering ordering) {
    return ordering._toProto(firestore);
  }

  firestore_v1.Value _anyToValue(dynamic value) {
    if (value == null) {
      return firestore_v1.Value(nullValue: protobuf_v1.NullValue.nullValue);
    } else if (value is String) {
      return _stringValue(value);
    } else if (value is int) {
      return _intValue(value);
    } else if (value is bool) {
      return _boolValue(value);
    } else if (value is List) {
      return _arrayValue(value.map(_anyToValue).toList());
    } else if (value is Map) {
      return firestore_v1.Value(
        mapValue: firestore_v1.MapValue(
          fields: value.map((k, v) => MapEntry(k.toString(), _anyToValue(v))),
        ),
      );
    }
    // Fall back to serializer
    return firestore._serializer.encodeValue(value)!;
  }
}
