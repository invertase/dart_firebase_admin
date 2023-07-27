part of '../../dart_firebase_admin.dart';

class DeleteUsersResult {
  DeleteUsersResult._(this.localIds, this._delegate);

  final List<String> localIds;

  final firebase_auth_v1.GoogleCloudIdentitytoolkitV1BatchDeleteAccountsResponse
      _delegate;

  /// The number of user records that failed to be deleted (possibly zero).
  int get failureCount => _delegate.errors?.length ?? 0;

  /// The number of users that were deleted successfully (possibly zero).
  ///
  /// Users that did not exist prior to calling [FirebaseAdminAuth.deleteUsers]
  /// are considered to be successfully deleted.
  int get successCount => localIds.length - failureCount;

  /// A list of FirebaseArrayIndexError instances describing the errors that
  /// were encountered during the deletion
  List<FirebaseArrayIndexException> get errors =>
      _delegate.errors?.map((e) {
        return FirebaseArrayIndexException(e.index!, e.message ?? 'Unknown');
      }).toList() ??
      [];
}
