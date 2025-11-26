import 'dart:async';
import 'dart:convert';

import 'package:googleapis/fcm/v1.dart' as fmc1;
import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../app.dart';

part 'fmc_exception.dart';
part 'messaging_api.dart';
part 'messaging_http_client.dart';
part 'messaging_request_handler.dart';

const _fmcMaxBatchSize = 500;

// const _fcmTopicManagementHost = 'iid.googleapis.com';
// const _fcmTopicManagementAddPath = '/iid/v1:batchAdd';
// const _fcmTopicManagementRemovePath = '/iid/v1:batchRemove';

/// An interface for interacting with the Firebase Cloud Messaging service.
class Messaging implements FirebaseService {
  /// Creates or returns the cached Messaging instance for the given app.
  factory Messaging(
    FirebaseApp app, {
    @internal FirebaseMessagingRequestHandler? requestHandler,
  }) {
    return app.getOrInitService(
      FirebaseServiceType.messaging.name,
      (app) => Messaging._(app, requestHandler: requestHandler),
    );
  }

  /// An interface for interacting with the Firebase Cloud Messaging service.
  Messaging._(
    this.app, {
    @internal FirebaseMessagingRequestHandler? requestHandler,
  }) : _requestHandler = requestHandler ?? FirebaseMessagingRequestHandler(app);

  /// The app associated with this Messaging instance.
  @override
  final FirebaseApp app;

  final FirebaseMessagingRequestHandler _requestHandler;

  /// Sends the given message via FCM.
  ///
  /// - [message] - The message payload.
  /// - [dryRun] - Whether to send the message in the dry-run
  ///   (validation only) mode.
  ///
  /// Returns a unique message ID string after the message has been successfully
  /// handed off to the FCM service for delivery.
  Future<String> send(Message message, {bool? dryRun}) {
    return _requestHandler.send(message, dryRun: dryRun);
  }

  /// Sends each message in the given array via Firebase Cloud Messaging.
  ///
  // TODO once we have Messaging.sendAll, add the following:
  // Unlike [Messaging.sendAll], this method makes a single RPC call for each message
  // in the given array.
  ///
  /// The responses list obtained from the return value corresponds to the order of `messages`.
  /// An error from this method or a `BatchResponse` with all failures indicates a total failure,
  /// meaning that none of the messages in the list could be sent. Partial failures or no
  /// failures are only indicated by a `BatchResponse` return value.
  ///
  /// - [messages]: A non-empty array containing up to 500 messages.
  /// - [dryRun]: Whether to send the messages in the dry-run
  ///   (validation only) mode.
  Future<BatchResponse> sendEach(List<Message> messages, {bool? dryRun}) {
    return _requestHandler.sendEach(messages, dryRun: dryRun);
  }

  /// Sends the given multicast message to all the FCM registration tokens
  /// specified in it.
  ///
  /// This method uses the [Messaging.sendEach] API under the hood to send the given
  /// message to all the target recipients. The responses list obtained from the
  /// return value corresponds to the order of tokens in the `MulticastMessage`.
  /// An error from this method or a `BatchResponse` with all failures indicates a total
  /// failure, meaning that the messages in the list could be sent. Partial failures or
  /// failures are only indicated by a `BatchResponse` return value.
  ///
  /// - [message]: A multicast message containing up to 500 tokens.
  /// - [dryRun]: Whether to send the message in the dry-run
  ///   (validation only) mode.
  Future<BatchResponse> sendEachForMulticast(
    MulticastMessage message, {
    bool? dryRun,
  }) {
    return _requestHandler.sendEachForMulticast(message, dryRun: dryRun);
  }

  @override
  Future<void> delete() async {
    // Messaging service cleanup if needed
  }
}
