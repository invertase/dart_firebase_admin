part of dart_firebase_admin;

class UpdateRequest {
  UpdateRequest({
    this.disabled,
    this.displayName,
    this.email,
    this.emailVerified,
    this.password,
    this.photoURL,
    this.providersToUnlink,
    this.providerToLink,
  });

  final bool? disabled;
  final String? displayName;
  final String? email;
  final bool? emailVerified;
  // TODO multifactor
  final String? password;
  final String? photoURL;
  final List<String>? providersToUnlink;
  // TODO UserProvider
  final Object? providerToLink;
}
