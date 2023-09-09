part of 'firestore.dart';

/// A generic guard wrapper for API calls to handle exceptions.
R _firestoreGuard<R>(R Function() cb) {
  try {
    final value = cb();

    if (value is Future) {
      return value.catchError(_handleException) as R;
    }

    return value;
  } catch (error, stackTrace) {
    _handleException(error, stackTrace);
  }
}

/// Converts a Exception to a FirebaseAdminException.
Never _handleException(Object exception, StackTrace stackTrace) {
  if (exception is firestore1.DetailedApiRequestError) {
    Error.throwWithStackTrace(
      FirebaseFirestoreAdminException.fromServerError(exception),
      stackTrace,
    );
  }

  Error.throwWithStackTrace(exception, stackTrace);
}

class FirebaseFirestoreAdminException extends FirebaseAdminException {
  FirebaseFirestoreAdminException.fromServerError(
    this.serverError,
  ) : super('firestore', 'unknown', serverError.message);

  /// The error thrown by the http/grpc client.
  ///
  /// This is exposed temporarily as a workaround until proper status codes
  /// are exposed officially.
  // TODO handle firestore error codes.
  @experimental
  final firestore1.DetailedApiRequestError serverError;

  @override
  String toString() =>
      'FirebaseFirestoreAdminException: $code: $message ${serverError.jsonResponse} ';
}
