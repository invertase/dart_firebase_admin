import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebaseapis/fcm/v1.dart' as fmc1;
import 'package:googleapis_auth/auth_io.dart';

import 'app.dart';

part 'messaging/fmc_exception.dart';
part 'messaging/messaging_api_request_internal.dart';
part 'messaging/messaging_api.dart';

/// An interface for interacting with the Firebase Cloud Messaging service.
class Messaging {
  /// An interface for interacting with the Firebase Cloud Messaging service.
  Messaging(this.firebase)
      : _requestHandler = _FirebaseMessagingRequestHandler(firebase);

  /// The app associated with this Messaging instance.
  final FirebaseAdminApp firebase;

  final _FirebaseMessagingRequestHandler _requestHandler;

  String get _parent => 'projects/${firebase.projectId}';

  /// Sends the given message via FCM.
  ///
  /// - [message] - The message payload.
  /// - [dryRun] - Whether to send the message in the dry-run
  ///   (validation only) mode.
  ///
  /// Returns a unique message ID string after the message has been successfully
  /// handed off to the FCM service for delivery.
  Future<String> send(Message message, {bool? dryRun}) {
    return _requestHandler.v1(
      (client) async {
        final response = await client.projects.messages.send(
          fmc1.SendMessageRequest(
            message: message._toProto(),
            validateOnly: dryRun,
          ),
          _parent,
        );

        final name = response.name;
        if (name == null) {
          throw FirebaseMessagingAdminException(
            MessagingClientErrorCode.internal,
            'No name in response',
          );
        }

        return name;
      },
    );
  }
}
