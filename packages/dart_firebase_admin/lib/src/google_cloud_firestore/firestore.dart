import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:googleapis/firestore/v1.dart' as firestore1;
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../object_utils.dart';
import '../utils/base_http_client.dart';
import 'backoff.dart';
import 'status_code.dart';
import 'util.dart';

part 'collection_group.dart';
part 'convert.dart';
part 'document.dart';
part 'document_change.dart';
part 'document_reader.dart';
part 'field_value.dart';
part 'filter.dart';
part 'firestore.freezed.dart';
part 'firestore_api_request_internal.dart';
part 'firestore_exception.dart';
part 'geo_point.dart';
part 'path.dart';
part 'reference.dart';
part 'serializer.dart';
part 'timestamp.dart';
part 'transaction.dart';
part 'types.dart';
part 'write_batch.dart';

class Firestore implements FirebaseService {
  /// Creates or returns the cached Firestore instance for the given app.
  ///
  /// Note: Settings can only be specified on the first call. Subsequent calls
  /// will return the cached instance and ignore any new settings.
  factory Firestore(FirebaseApp app, {Settings? settings}) {
    return app.getOrInitService(
      'firestore',
      (app) => Firestore._(app, settings: settings),
    ) as Firestore;
  }

  Firestore._(this.app, {Settings? settings})
      : _settings = settings ?? Settings();

  /// Returns the Database ID for this Firestore instance.
  String get _databaseId => _settings.databaseId ?? '(default)';

  /// Gets the cached project ID.
  /// This must only be called after the first operation that triggers discovery.
  /// Otherwise it will throw.
  String get _projectId {
    final cached = _client.cachedProjectId;
    if (cached == null) {
      throw StateError(
        'Project ID has not been discovered yet. '
        'This should only be called within operations after v1() has been invoked.',
      );
    }
    return cached;
  }

  /// The Database ID, using the format 'projects/${projectId}/databases/$_databaseId'
  String get _formattedDatabaseName {
    return 'projects/$_projectId/databases/$_databaseId';
  }

  final FirebaseApp app;
  final Settings _settings;

  late final _client = _FirestoreHttpClient(app);
  late final _serializer = _Serializer(this);

  // TODO batch
  // TODO bulkWriter
  // TODO bundle
  // TODO getAll
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
  Future<List<CollectionReference<DocumentData>>> listCollections() {
    final rootDocument = DocumentReference._(
      firestore: this,
      path: _ResourcePath.empty,
      converter: _jsonConverter,
    );

    return rootDocument.listCollections();
  }

  /// Gets a [DocumentReference] instance that
  /// refers to the document at the specified path.
  ///
  /// - [documentPath]: A slash-separated path to a document.
  ///
  /// Returns The [DocumentReference] instance.
  ///
  /// ```dart
  /// final documentRef = firestore.doc('collection/document');
  /// print('Path of document is ${documentRef.path}');
  /// ```
  DocumentReference<DocumentData> doc(String documentPath) {
    _validateResourcePath('documentPath', documentPath);

    final path = _ResourcePath.empty._append(documentPath);
    if (!path.isDocument) {
      throw ArgumentError.value(
        documentPath,
        'documentPath',
        'Value for argument "documentPath" must point to a document, but was "$documentPath". '
            'Your path does not contain an even number of components.',
      );
    }

    return DocumentReference._(
      firestore: this,
      path: path,
      converter: _jsonConverter,
    );
  }

  /// Gets a [CollectionReference] instance
  /// that refers to the collection at the specified path.
  ///
  /// - [collectionPath]: A slash-separated path to a collection.
  ///
  /// Returns [CollectionReference] A reference to the new
  /// sub-collection.
  CollectionReference<DocumentData> collection(String collectionPath) {
    _validateResourcePath('collectionPath', collectionPath);

    final path = _ResourcePath.empty._append(collectionPath);
    if (!path.isCollection) {
      throw ArgumentError.value(
        collectionPath,
        'collectionPath',
        'Value for argument "collectionPath" must point to a collection, but was '
            '"$collectionPath". Your path does not contain an odd number of components.',
      );
    }

    return CollectionReference._(
      firestore: this,
      path: path,
      converter: _jsonConverter,
    );
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
  CollectionGroup<DocumentData> collectionGroup(String collectionId) {
    if (collectionId.contains('/')) {
      throw ArgumentError.value(
        collectionId,
        'collectionId',
        'Invalid collectionId "$collectionId". Collection IDs must not contain "/".',
      );
    }

    return CollectionGroup._(
      collectionId,
      firestore: this,
      converter: _jsonConverter,
    );
  }

  // Retrieves multiple documents from Firestore.
  Future<List<DocumentSnapshot<T>>> getAll<T>(
    List<DocumentReference<T>> documents, [
    ReadOptions? readOptions,
  ]) async {
    if (documents.isEmpty) {
      throw ArgumentError.value(
        documents,
        'documents',
        'must not be an empty array.',
      );
    }

    final fieldMask = _parseFieldMask(readOptions);

    final reader = _DocumentReader(
      firestore: this,
      documents: documents,
      fieldMask: fieldMask,
    );

    return reader.get();
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
    TransactionHandler<T> updateFuntion, {
    TransactionOptions? transactionOptions,
  }) {
    if (transactionOptions != null) {}

    final transaction = Transaction(this, transactionOptions);

    return transaction._runTransaction(updateFuntion);
  }

  @override
  Future<void> delete() async {
    // Firestore service cleanup if needed
  }
}

class SettingsCredentials {
  SettingsCredentials({this.clientEmail, this.privateKey});

  final String? clientEmail;
  final String? privateKey;
}

/// Settings used to directly configure a `Firestore` instance.
@freezed
class Settings with _$Settings {
  /// Settings used to directly configure a `Firestore` instance.
  factory Settings({
    /// The database name. If omitted, the default database will be used.
    String? databaseId,

    /// Whether to use `BigInt` for integer types when deserializing Firestore
    /// Documents. Regardless of magnitude, all integer values are returned as
    /// `BigInt` to match the precision of the Firestore backend. Floating point
    /// numbers continue to use JavaScript's `number` type.
    bool? useBigInt,
  }) = _Settings;
}

class _FirestoreHttpClient extends BaseHttpClient {
  _FirestoreHttpClient(super.app);

  // TODO needs to send "owner" as bearer token when using the emulator

  /// Gets the Firestore API host URL based on emulator configuration.
  Uri get _firestoreApiHost {
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    final emulatorHost = env['FIRESTORE_EMULATOR_HOST'];

    if (emulatorHost != null) {
      return Uri.http(emulatorHost, '/');
    }

    return Uri.https('firestore.googleapis.com', '/');
  }

  // TODO refactor with auth
  // TODO is it fine to use AuthClient?
  Future<R> _run<R>(
    Future<R> Function(Client client) fn,
  ) {
    return _firestoreGuard(() => app.client.then(fn));
  }

  /// Executes a Firestore v1 API operation with automatic projectId injection.
  ///
  /// Discovers and caches the projectId on first call, then provides it to
  /// all subsequent operations. This matches the Auth service pattern.
  Future<R> v1<R>(
    Future<R> Function(firestore1.FirestoreApi client, String projectId) fn,
  ) async {
    final projectId = await discoverProjectId();
    return _run(
      (client) => fn(
        firestore1.FirestoreApi(
          client,
          rootUrl: _firestoreApiHost.toString(),
        ),
        projectId,
      ),
    );
  }
}

sealed class TransactionOptions {
  bool get readOnly;

  int get maxAttempts;
}

class ReadOnlyTransactionOptions extends TransactionOptions {
  ReadOnlyTransactionOptions({Timestamp? readTime}) : _readTime = readTime;
  @override
  bool readOnly = true;

  @override
  int get maxAttempts => 1;

  Timestamp? get readTime => _readTime;

  final Timestamp? _readTime;
}

class ReadWriteTransactionOptions extends TransactionOptions {
  ReadWriteTransactionOptions({int maxAttempts = 5})
      : _maxAttempts = maxAttempts;

  final int _maxAttempts;

  @override
  bool readOnly = false;

  @override
  int get maxAttempts => _maxAttempts;
}
