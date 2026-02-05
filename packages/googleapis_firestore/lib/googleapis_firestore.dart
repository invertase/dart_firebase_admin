/// Google Cloud Firestore client library for Dart.
///
/// This library provides a Dart client for Google Cloud Firestore, allowing
/// you to interact with Firestore databases from Dart applications.
library;

import 'package:meta/meta.dart';

export 'src/firestore.dart'
    show
        Firestore,
        Settings,
        Credentials,
        CollectionReference,
        DocumentReference,
        DocumentSnapshot,
        QuerySnapshot,
        QueryDocumentSnapshot,
        WriteBatch,
        BulkWriter,
        BulkWriterOptions,
        BulkWriterThrottling,
        EnabledThrottling,
        DisabledThrottling,
        BulkWriterError,
        Transaction,
        TransactionOptions,
        ReadOnlyTransactionOptions,
        ReadWriteTransactionOptions,
        FieldValue,
        GeoPoint,
        Timestamp,
        FieldPath,
        CollectionGroup,
        Query,
        QueryPartition,
        AggregateQuery,
        AggregateQuerySnapshot,
        AggregateField,
        count,
        sum,
        average,
        Filter,
        WhereFilter,
        DocumentData,
        ReadOptions,
        WriteResult,
        DocumentChange,
        DocumentChangeType,
        Precondition,
        TransactionHandler,
        SetOptions,
        BundleBuilder,
        VectorValue,
        VectorQuery,
        VectorQuerySnapshot,
        VectorQueryOptions,
        DistanceMeasure,
        ExplainOptions,
        ExplainResults,
        ExplainMetrics,
        PlanSummary,
        ExecutionStats,
        // Pipeline classes
        Pipeline,
        PipelineSource,
        PipelineSnapshot,
        PipelineResult,
        ExplainStats,
        // Expression classes
        Expression,
        Field,
        Constant,
        FunctionExpression,
        BooleanExpression,
        // Aggregate classes
        AggregateFunction,
        CountAggregate,
        CountAllAggregate,
        CountDistinctAggregate,
        CountIfAggregate,
        SumAggregate,
        AverageAggregate,
        MinimumAggregate,
        MaximumAggregate,
        // Supporting classes
        Ordering,
        AliasedExpression,
        AliasedAggregate,
        Selectable;
export 'src/firestore_exception.dart'
    show FirestoreException, FirestoreClientErrorCode;
export 'src/status_code.dart' show StatusCode;

/// Symbol for accessing environment variables in tests via Zones.
/// This allows tests to override Platform.environment values.
@internal
const envSymbol = #_envSymbol;
