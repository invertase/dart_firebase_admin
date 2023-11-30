part of '../messaging.dart';

class _FirebaseMessagingRequestHandler {
  _FirebaseMessagingRequestHandler(this.firebase);

  final FirebaseAdminApp firebase;

  Future<R> _run<R>(
    Future<R> Function(AutoRefreshingAuthClient client) fn,
  ) {
    return _fmcGuard(() => firebase.credential.client.then(fn));
  }

  Future<T> _fmcGuard<T>(
    FutureOr<T> Function() fn,
  ) async {
    try {
      final value = fn();

      if (value is T) return value;

      return value.catchError(_handleException);
    } catch (error, stackTrace) {
      _handleException(error, stackTrace);
    }
  }

  Future<R> v1<R>(
    Future<R> Function(fmc1.FirebaseCloudMessagingApi client) fn,
  ) {
    return _run((client) => fn(fmc1.FirebaseCloudMessagingApi(client)));
  }
}
