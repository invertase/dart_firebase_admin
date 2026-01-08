/// Google Cloud Firestore client library for Dart.
///
/// This library provides a Dart client for Google Cloud Firestore, allowing
/// you to interact with Firestore databases from Dart applications.
library;

export 'src/firestore.dart'
    show
        Firestore,
        FirestoreException,
        FirestoreClientErrorCode,
        StatusCode,
        Settings,
        Credentials,
        CollectionReference,
        DocumentReference,
        DocumentSnapshot,
        QuerySnapshot,
        QueryDocumentSnapshot,
        WriteBatch,
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
        TransactionHandler;
