import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:firebaseapis/firestore/v1.dart' as firestore1;
import 'package:firebaseapis/firestore/v1beta1.dart' as firestore1beta1;
import 'package:firebaseapis/firestore/v1beta2.dart' as firestore1beta2;
import 'package:firebaseapis/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../../messaging.dart';
import '../app.dart';
import '../object_utils.dart';
import 'backoff.dart';
import 'status_code.dart';
import 'util.dart';

part 'convert.dart';
part 'document.dart';
part 'document_reader.dart';
part 'field_value.dart';
part 'firestore.freezed.dart';
part 'geo_point.dart';
part 'path.dart';
part 'reference.dart';
part 'serializer.dart';
part 'timestamp.dart';
part 'transaction.dart';
part 'transaction remake.dart';

part 'types.dart';
part 'write_batch.dart';
part 'document_change.dart';
part 'filter.dart';
part 'firestore_exception.dart';
part 'firestore_api_request_internal.dart';
part 'collection_group.dart';

class Firestore {
  Firestore(this.app, {Settings? settings})
      : _settings = settings ?? Settings();

  /// Returns the Database ID for this Firestore instance.
  String get _databaseId => _settings.databaseId ?? '(default)';

  /// The Database ID, using the format 'projects/${app.projectId}/databases/$_databaseId'
  String get _formattedDatabaseName {
    return 'projects/${app.projectId}/databases/$_databaseId';
  }

  final FirebaseAdminApp app;
  final Settings _settings;

  late final _client = _FirestoreHttpClient(app);
  late final _serializer = _Serializer(this);

  // TODO batch
  // TODO bulkWriter
  // TODO bundle
  // TODO getAll
  // TODO runTransaction
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
      path: path._toQualifiedResourcePath(app.projectId, _databaseId),
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
      path: path._toQualifiedResourcePath(app.projectId, _databaseId),
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
    final tag = requestTag();

    final reader = _DocumentReader(
      firestore: this,
      documents: documents,
      transactionId: null,
      fieldMask: fieldMask,
    );

    return reader.get(tag);
  }

  Future<T> runTransactionRemake<T>(
    TransactionHandlerRemake<T> updateFuntion, {
    TransactionOptions? transactionOptions,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final tag = requestTag();
    if (transactionOptions != null) {}

    final transaction = NewTransaction(this, tag, transactionOptions);

    return transaction._runTransaction(updateFuntion);
  }

  Future<T> runTransaction<T>(
    /// - Returns: A Future that resolves with the result of the transaction.
    /// - Returns: A Future that resolves with the result of the transaction.
    TransactionHandler<T> transactionHandler, {
    int maxAttempts = 5,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (maxAttempts <= 0) {
      return Future.error(
        FirebaseFirestoreAdminException(
          FirestoreClientErrorCode.failedPrecondition,
          'Transaction max attemps must be > 0.',
        ),
      );
    }
    return Future<T>(() async {
      var attempts = 1;
      while (true) {
        try {
          return await _runTransaction(transactionHandler);
        } on FirebaseFirestoreAdminException catch (firebaseError) {
          if (firebaseError.errorCode == FirestoreClientErrorCode.aborted ||
              firebaseError.errorCode == FirestoreClientErrorCode.unavailable ||
              firebaseError.errorCode == FirestoreClientErrorCode.internal) {
            if (attempts < maxAttempts) {
              attempts += 1;
            } else {
              return Future.error(
                FirebaseFirestoreAdminException(
                  FirestoreClientErrorCode.failedPrecondition,
                  'Transaction max atempts exceded.',
                ),
              );
            }
          } else {
            return Future.error(firebaseError);
          }
        } catch (e) {
          return Future.error(e);
        }
      }
    }).timeout(
      timeout,
      onTimeout: () => Future.error(
        FirebaseFirestoreAdminException(
          FirestoreClientErrorCode.deadlineExceeded,
          'Transaction timout.',
        ),
      ),
    );
  }

  Future<T> _runTransaction<T>(
    TransactionHandler<T> transactionHandler,
  ) async {
    final transactionRequest = firestore1.BeginTransactionRequest();

    return _client.v1(
      (client) async {
        final transactionResponse = await client.projects.databases.documents
            .beginTransaction(transactionRequest, _formattedDatabaseName)
            .catchError(_handleException);

        final transactionId = transactionResponse.transaction;
        final transaction = Transaction(this, transactionId!);
        final result = await transactionHandler(transaction);
        await transaction._transactionWriteBatch
            .commit(transactionId)
            .catchError(_handleException);

        return result;
      },
    );
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

class _FirestoreHttpClient {
  _FirestoreHttpClient(this.app);

  // TODO needs to send "owner" as bearer token when using the emulator
  final FirebaseAdminApp app;

  // TODO refactor with auth
  // TODO is it fine to use AuthClient?
  Future<R> _run<R>(
    Future<R> Function(Client client) fn,
  ) {
    return _firestoreGuard(() => app.client.then(fn));
  }

  Future<R> v1<R>(
    Future<R> Function(firestore1.FirestoreApi client) fn,
  ) {
    return _run(
      (client) => fn(
        firestore1.FirestoreApi(
          client,
          rootUrl: app.firestoreApiHost.toString(),
        ),
      ),
    );
  }

  Future<R> v1Beta1<R>(
    Future<R> Function(firestore1beta1.FirestoreApi client) fn,
  ) async {
    return _run(
      (client) => fn(
        firestore1beta1.FirestoreApi(
          client,
          rootUrl: app.firestoreApiHost.toString(),
        ),
      ),
    );
  }

  Future<R> v1Beta2<R>(
    Future<R> Function(firestore1beta2.FirestoreApi client) fn,
  ) async {
    return _run(
      (client) => fn(
        firestore1beta2.FirestoreApi(
          client,
          rootUrl: app.firestoreApiHost.toString(),
        ),
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
