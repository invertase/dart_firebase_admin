part of '../../dart_firebase_admin.dart';

class CreateRequest extends UpdateRequest {
  CreateRequest({
    bool? disabled,
    String? displayName,
    String? email,
    bool? emailVerified,
    String? password,
    String? photoURL,
    List<String>? providersToUnlink,
    String? providerToLink,
    this.uid,
  }) : super(
          disabled: disabled,
          displayName: displayName,
          email: email,
          emailVerified: emailVerified,
          password: password,
          photoURL: photoURL,
          providersToUnlink: providersToUnlink,
          providerToLink: providerToLink,
        );

  // TODO multiFactor

  final String? uid;
}
