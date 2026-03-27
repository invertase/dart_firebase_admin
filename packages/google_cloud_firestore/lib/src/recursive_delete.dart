part of 'firestore.dart';

/// Datastore allowed numeric IDs where Firestore only allows strings. Numeric
/// IDs are exposed to Firestore as __idNUM__, so this is the lowest possible
/// negative numeric value expressed in that format.
///
/// This constant is used to specify startAt/endAt values when querying for all
/// descendants in a single collection.
const _referenceNameMinId = '__id-9223372036854775808__';

/// The query limit used for recursive deletes when fetching all descendants of
/// the specified reference to delete. This is done to prevent the query
/// from fetching documents faster than Firestore can delete.
const _recursiveDeleteMaxPendingOps = 5000;

/// The number of pending BulkWriter operations at which _RecursiveDelete
/// starts the next limit query to fetch descendants. By starting the query
/// while there are pending operations, Firestore can improve BulkWriter
/// throughput. This helps prevent BulkWriter from idling while Firestore
/// fetches the next query.
const _recursiveDeleteMinPendingOps = 1000;

/// Class used to store state required for running a recursive delete operation.
/// Each recursive delete call should use a new instance of the class.
/// @private
/// @internal
class _RecursiveDelete {
  _RecursiveDelete({
    required this.firestore,
    required this.writer,
    required this.ref,
  });

  final Firestore firestore;
  final BulkWriter writer;
  final Object ref;

  /// The number of deletes that failed with a permanent error.
  int _errorCount = 0;

  /// The most recently thrown error. Used to populate the developer-facing
  /// error message when the recursive delete operation completes.
  Exception? _lastError;

  /// Whether run() has been called.
  bool _started = false;

  /// The last document snapshot returned by the query. Used to set the
  /// startAfter() field in the subsequent query.
  QueryDocumentSnapshot<DocumentData>? _lastDocumentSnap;

  /// The number of pending BulkWriter operations.
  int _pendingOpsCount = 0;

  /// Recursively deletes the reference provided in the class constructor.
  /// Returns a Future that resolves when all descendants have been deleted, or
  /// if an error occurs.
  Future<void> run() async {
    if (_started) {
      throw StateError('RecursiveDelete.run() should only be called once.');
    }
    _started = true;

    // Fetch and delete all descendants
    await _fetchAndDelete();

    // Delete the root reference if it's a document
    if (ref is DocumentReference) {
      _pendingOpsCount++;
      writer
          .delete(ref as DocumentReference)
          // ignore: unawaited_futures
          .then(
            (_) {
              _pendingOpsCount--;
            },
            onError: (Object error) {
              _incrementErrorCount(error as Exception);
              _pendingOpsCount--;
            },
          );
    }

    // Wait for all pending operations to complete
    await writer.flush();

    // Check if there were any errors
    if (_lastError != null) {
      throw FirestoreException(
        FirestoreClientErrorCode.unknown,
        '$_errorCount ${_errorCount != 1 ? 'deletes' : 'delete'} failed. '
        'The last delete failed with: $_lastError',
      );
    }
  }

  /// Fetches and deletes all descendants of the reference.
  Future<void> _fetchAndDelete() async {
    var hasMore = true;

    while (hasMore) {
      final query = _getAllDescendants();
      final snapshot = await query.get();
      final docs = snapshot.docs;

      if (docs.isEmpty) {
        hasMore = false;
        break;
      }

      // Delete all documents in this batch
      for (final doc in docs) {
        _lastDocumentSnap = doc;
        _deleteRef(doc.ref);
      }

      // Wait for pending operations to drop below threshold before continuing
      while (_pendingOpsCount >= _recursiveDeleteMinPendingOps) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      // If we got fewer documents than the limit, we're done
      if (docs.length < _recursiveDeleteMaxPendingOps) {
        hasMore = false;
      }
    }
  }

  /// Retrieves a query for all descendant documents nested under the provided reference.
  Query<DocumentData> _getAllDescendants() {
    // The parent is the closest ancestor document to the location we're
    // deleting. If we are deleting a document, the parent is the path of that
    // document. If we are deleting a collection, the parent is the path of the
    // document containing that collection (or the database root, if it is a
    // root collection).
    late _ResourcePath parentPath;
    late String collectionId;

    if (ref is CollectionReference) {
      final collRef = ref as CollectionReference<DocumentData>;
      parentPath = collRef._queryOptions.parentPath;
      collectionId = collRef.id;
    } else if (ref is DocumentReference) {
      final docRef = ref as DocumentReference<DocumentData>;
      parentPath = docRef._path;
      collectionId = docRef.parent.id;
    } else {
      throw ArgumentError(
        'ref must be DocumentReference or CollectionReference',
      );
    }

    var query = Query<DocumentData>._(
      firestore: firestore,
      queryOptions: _QueryOptions.forKindlessAllDescendants(
        parentPath,
        collectionId,
        requireConsistency: false,
      ),
    );

    // Query for IDs only to minimize data transfer
    query = query
        .select([FieldPath.documentId])
        .limit(_recursiveDeleteMaxPendingOps);

    if (ref is CollectionReference) {
      // To find all descendants of a collection reference, we need to use a
      // composite filter that captures all documents that start with the
      // collection prefix.
      final nullChar = String.fromCharCode(0);

      // Build full path including parent for nested collections
      final parentPrefix = parentPath.segments.isEmpty
          ? ''
          : '${parentPath.relativeName}/';
      final startAtPath = '$parentPrefix$collectionId/$_referenceNameMinId';
      final endAtPath =
          '$parentPrefix$collectionId$nullChar/$_referenceNameMinId';

      // Convert paths to DocumentReference instances for querying by __name__
      final startAtRef = firestore.doc(startAtPath);
      final endAtRef = firestore.doc(endAtPath);

      query = query
          .where(
            FieldPath.documentId,
            WhereFilter.greaterThanOrEqual,
            startAtRef,
          )
          .where(FieldPath.documentId, WhereFilter.lessThan, endAtRef);
    }

    if (_lastDocumentSnap != null) {
      query = query.startAfter([_lastDocumentSnap!.ref]);
    }

    return query;
  }

  /// Deletes the provided reference and updates pending operation count.
  void _deleteRef(DocumentReference<DocumentData> docRef) {
    _pendingOpsCount++;
    writer
        .delete(docRef)
        .then(
          (_) {
            _pendingOpsCount--;
          },
          onError: (Object error) {
            _incrementErrorCount(error as Exception);
            _pendingOpsCount--;
          },
        );
  }

  /// Increments the error count and stores the last error.
  void _incrementErrorCount(Exception error) {
    _errorCount++;
    _lastError = error;
  }
}
