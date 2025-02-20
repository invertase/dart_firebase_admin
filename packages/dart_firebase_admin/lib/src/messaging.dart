import 'dart:async';
import 'dart:convert';

import 'package:firebaseapis/fcm/v1.dart' as fmc1;
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import 'app.dart';

part 'messaging/fmc_exception.dart';
part 'messaging/messaging_api.dart';
part 'messaging/messaging_api_request_internal.dart';

const _fmcMaxBatchSize = 500;

// const _fcmTopicManagementHost = 'iid.googleapis.com';
// const _fcmTopicManagementAddPath = '/iid/v1:batchAdd';
// const _fcmTopicManagementRemovePath = '/iid/v1:batchRemove';

/// An interface for interacting with the Firebase Cloud Messaging service.
class Messaging {
  /// An interface for interacting with the Firebase Cloud Messaging service.
  Messaging(
    this.firebase, {
    @internal FirebaseMessagingRequestHandler? requestHandler,
  }) : _requestHandler =
            requestHandler ?? FirebaseMessagingRequestHandler(firebase);

  /// The app associated with this Messaging instance.
  final FirebaseAdminApp firebase;

  final FirebaseMessagingRequestHandler _requestHandler;

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
            MessagingClientErrorCode.internalError,
            'No name in response',
          );
        }

        return name;
      },
    );
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
    return _requestHandler.v1(
      (client) async {
        if (messages.isEmpty) {
          throw FirebaseMessagingAdminException(
            MessagingClientErrorCode.invalidArgument,
            'messages must be a non-empty array',
          );
        }
        if (messages.length > _fmcMaxBatchSize) {
          throw FirebaseMessagingAdminException(
            MessagingClientErrorCode.invalidArgument,
            'messages list must not contain more than $_fmcMaxBatchSize items',
          );
        }

        final responses = await Future.wait<SendResponse>(
          messages.map((message) async {
            final response = client.projects.messages.send(
              fmc1.SendMessageRequest(
                message: message._toProto(),
                validateOnly: dryRun,
              ),
              _parent,
            );

            return response.then(
              (value) {
                return SendResponse._(success: true, messageId: value.name);
              },
              // ignore: avoid_types_on_closure_parameters
              onError: (Object? error) {
                return SendResponse._(
                  success: false,
                  error: error is FirebaseMessagingAdminException
                      ? error
                      : FirebaseMessagingAdminException(
                          MessagingClientErrorCode.internalError,
                          error.toString(),
                        ),
                );
              },
            );
          }),
        );

        final successCount = responses.where((r) => r.success).length;

        return BatchResponse._(
          responses: responses,
          successCount: successCount,
          failureCount: responses.length - successCount,
        );
      },
    );
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
    return sendEach(
      message.tokens
          .map(
            (token) => TokenMessage(
              token: token,
              data: message.data,
              notification: message.notification,
              android: message.android,
              apns: message.apns,
              fcmOptions: message.fcmOptions,
              webpush: message.webpush,
            ),
          )
          .toList(),
      dryRun: dryRun,
    );
  }

  // TODO uncomment code below when we figure out hot to send the subscription request
  // TODO also unmark the response as internal
  // TODO subscribeToTopic, unsubscribeFromTopic
  // TODO sendAll – missing batch client implementation
  // TODO sendMulticast - relies on sendAll
}
