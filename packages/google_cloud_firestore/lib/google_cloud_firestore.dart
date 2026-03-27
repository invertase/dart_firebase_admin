/// Google Cloud Firestore client library for Dart.
///
/// This library provides a Dart client for Google Cloud Firestore, allowing
/// you to interact with Firestore databases from Dart applications.
library;

import 'package:meta/meta.dart';

export 'src/credential.dart' show Credential;
export 'src/firestore.dart'
    show
        AggregateField,
        AggregateQuery,
        AggregateQuerySnapshot,
        BulkWriter,
        BulkWriterError,
        BulkWriterOptions,
        BulkWriterThrottling,
        BundleBuilder,
        CollectionGroup,
        CollectionReference,
        DisabledThrottling,
        DistanceMeasure,
        DocumentChange,
        DocumentChangeType,
        DocumentData,
        DocumentReference,
        DocumentSnapshot,
        EnabledThrottling,
        ExecutionStats,
        ExplainMetrics,
        ExplainOptions,
        ExplainResults,
        FieldPath,
        FieldValue,
        Filter,
        Firestore,
        GeoPoint,
        PlanSummary,
        Precondition,
        Query,
        QueryDocumentSnapshot,
        QueryPartition,
        QuerySnapshot,
        ReadOnlyTransactionOptions,
        ReadOptions,
        ReadWriteTransactionOptions,
        SetOptions,
        Settings,
        Timestamp,
        Transaction,
        TransactionHandler,
        TransactionOptions,
        VectorQuery,
        VectorQueryOptions,
        VectorQuerySnapshot,
        VectorValue,
        WhereFilter,
        WriteBatch,
        WriteResult,
        average,
        count,
        sum;
export 'src/firestore_exception.dart'
    show FirestoreClientErrorCode, FirestoreException;
export 'src/status_code.dart' show StatusCode;

/// Symbol for accessing environment variables in tests via Zones.
/// This allows tests to override Platform.environment values.
@internal
const envSymbol = #_envSymbol;
