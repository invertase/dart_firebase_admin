import 'dart:async';

import 'package:googleapis_firestore/googleapis_firestore.dart'
    as googleapis_firestore;
import 'package:meta/meta.dart';

import '../app.dart';

// part 'firestore_exception.dart';

class Firestore implements FirebaseService {
  /// Creates or returns the cached Firestore instance for the given app.
  ///
  /// Note: Settings can only be specified on the first call. Subsequent calls
  /// will return the cached instance and ignore any new settings.
  @internal
  factory Firestore.internal(
    FirebaseApp app, {
    googleapis_firestore.Settings? settings,
  }) {
    return app.getOrInitService(
      FirebaseServiceType.firestore.name,
      (app) => Firestore._(app, settings: settings),
    );
  }

  Firestore._(this.app, {googleapis_firestore.Settings? settings}) {
    _delegate = googleapis_firestore.Firestore(settings: settings);
  }

  @override
  final FirebaseApp app;
  late final googleapis_firestore.Firestore _delegate;

  // TODO batch
  // TODO bulkWriter
  // TODO bundle
  // TODO recursiveDelete

  /// Fetches the root collections that are associated with this Firestore
  /// database.
  ///
  /// Returns a Promise that resolves with an array of CollectionReferences.
  ///
  /// ```dart
  /// firestore.listCollections().then((collections) {
  ///   for (final collection in collections) {
  ///     print('Found collection with id: ${collection.id}');
  ///   }
  /// });
  /// ```
  Future<
    List<
      googleapis_firestore.CollectionReference<
        googleapis_firestore.DocumentData
      >
    >
  >
  listCollections() => _delegate.listCollections();

  /// Gets a [googleapis_firestore.DocumentReference] instance that
  /// refers to the document at the specified path.
  ///
  /// - [documentPath]: A slash-separated path to a document.
  ///
  /// Returns The [googleapis_firestore.DocumentReference] instance.
  ///
  /// ```dart
  /// final documentRef = firestore.doc('collection/document');
  /// print('Path of document is ${documentRef.path}');
  /// ```
  googleapis_firestore.DocumentReference<googleapis_firestore.DocumentData> doc(
    String documentPath,
  ) => _delegate.doc(documentPath);

  /// Gets a [googleapis_firestore.CollectionReference] instance
  /// that refers to the collection at the specified path.
  ///
  /// - [collectionPath]: A slash-separated path to a collection.
  ///
  /// Returns [googleapis_firestore.CollectionReference] A reference to the new
  /// sub-collection.
  googleapis_firestore.CollectionReference<googleapis_firestore.DocumentData>
  collection(String collectionPath) {
    throw UnimplementedError();
  }

  /// Creates and returns a new Query that includes all documents in the
  /// database that are contained in a collection or subcollection with the
  /// given collectionId.
  ///
  /// - [collectionId] Identifies the collections to query over.
  /// Every collection or subcollection with this ID as the last segment of its
  /// path will be included. Cannot contain a slash.
  ///
  /// ```dart
  /// final docA = await firestore.doc('my-group/docA').set({foo: 'bar'});
  /// final docB = await firestore.doc('abc/def/my-group/docB').set({foo: 'bar'});
  ///
  /// final query = firestore.collectionGroup('my-group')
  ///    .where('foo', WhereOperator.equal 'bar');
  /// final snapshot = await query.get();
  /// print('Found ${snapshot.size} documents.');
  /// ```
  googleapis_firestore.CollectionGroup<googleapis_firestore.DocumentData>
  collectionGroup(String collectionId) {
    throw UnimplementedError();
  }

  // Retrieves multiple documents from Firestore.
  Future<List<googleapis_firestore.DocumentSnapshot<T>>> getAll<T>(
    List<googleapis_firestore.DocumentReference<T>> documents, [
    googleapis_firestore.ReadOptions? readOptions,
  ]) async {
    throw UnimplementedError();
  }

  /// Executes the given updateFunction and commits the changes applied within
  /// the transaction.
  /// You can use the transaction object passed to 'updateFunction' to read and
  /// modify Firestore documents under lock. You have to perform all reads
  /// before before you perform any write.
  /// Transactions can be performed as read-only or read-write transactions. By
  /// default, transactions are executed in read-write mode.
  /// A read-write transaction obtains a pessimistic lock on all documents that
  /// are read during the transaction. These locks block other transactions,
  /// batched writes, and other non-transactional writes from changing that
  /// document. Any writes in a read-write transactions are committed once
  /// 'updateFunction' resolves, which also releases all locks.
  /// If a read-write transaction fails with contention, the transaction is
  /// retried up to five times. The updateFunction is invoked once for each
  /// attempt.
  /// Read-only transactions do not lock documents. They can be used to read
  /// documents at a consistent snapshot in time, which may be up to 60 seconds
  /// in the past. Read-only transactions are not retried.
  /// Transactions time out after 60 seconds if no documents are read.
  /// Transactions that are not committed within than 270 seconds are also
  /// aborted. Any remaining locks are released when a transaction times out.
  Future<T> runTransaction<T>(
    googleapis_firestore.TransactionHandler<T> updateFunction, {
    googleapis_firestore.TransactionOptions? transactionOptions,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete() async {
    // Close HTTP client if we created it (emulator mode)
  }
}
