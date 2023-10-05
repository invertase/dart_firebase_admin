import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:firebaseapis/firestore/v1.dart' as firestore1;
import 'package:firebaseapis/firestore/v1beta1.dart' as firestore1beta1;
import 'package:firebaseapis/firestore/v1beta2.dart' as firestore1beta2;
import 'package:firebaseapis/identitytoolkit/v3.dart' as auth3;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:intl/intl.dart';

import '../app.dart';
import '../object_utils.dart';
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
part 'types.dart';
part 'write_batch.dart';
part 'document_change.dart';
part 'filter.dart';
part 'firestore_exception.dart';

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

  /// Gets a [DocumentReference]{@link DocumentReference} instance that
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
  /// subcollection.
  ///
  /// @example
  /// ```
  /// let documentRef = firestore.doc('col/doc');
  /// let subcollection = documentRef.collection('subcollection');
  /// console.log(`Path to subcollection: ${subcollection.path}`);
  /// ```
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

  auth.AuthClient? _client;
  // TODO refactor with auth
  // TODO is it fine to use AuthClient?
  Future<auth.AuthClient> _getClient() async {
    return _client ??= await app.credential.getAuthClient([
      auth3.IdentityToolkitApi.cloudPlatformScope,
      auth3.IdentityToolkitApi.firebaseScope,
    ]);
  }

  Future<R> v1<R>(
    Future<R> Function(firestore1.FirestoreApi client) fn,
  ) {
    return _firestoreGuard(
      () async => fn(
        firestore1.FirestoreApi(
          await _getClient(),
          rootUrl: app.firestoreApiHost.toString(),
        ),
      ),
    );
  }

  Future<R> v1Beta1<R>(
    Future<R> Function(firestore1beta1.FirestoreApi client) fn,
  ) async {
    return _firestoreGuard(
      () async => fn(
        firestore1beta1.FirestoreApi(
          await _getClient(),
          rootUrl: app.firestoreApiHost.toString(),
        ),
      ),
    );
  }

  Future<R> v1Beta2<R>(
    Future<R> Function(firestore1beta2.FirestoreApi client) fn,
  ) async {
    return _firestoreGuard(
      () async => fn(
        firestore1beta2.FirestoreApi(
          await _getClient(),
          rootUrl: app.firestoreApiHost.toString(),
        ),
      ),
    );
  }
}
