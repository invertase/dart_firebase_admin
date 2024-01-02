import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:firebaseapis/fcm/v1.dart' as fmc1;
import 'package:googleapis_auth/auth_io.dart';
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
            MessagingClientErrorCode.internal,
            'No name in response',
          );
        }

        return name;
      },
    );
  }

  /// Sends each message in the given array via Firebase Cloud Messaging.
  ///
  /// Unlike [Messaging.sendAll], this method makes a single RPC call for each message
  /// in the given array.
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
                          MessagingClientErrorCode.internal,
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
  // /// Subscribes a device to an FCM topic.
  // ///
  // /// See [Subscribe to a topic](https://firebase.google.com/docs/cloud-messaging/manage-topics#suscribe_and_unsubscribe_using_the)
  // /// for code samples and detailed documentation. Optionally, you can provide an
  // /// array of tokens to subscribe multiple devices.
  // ///
  // /// - [registrationTokens]: A token or array of registration tokens
  // ///   for the devices to subscribe to the topic.
  // /// - [topic]: The topic to which to subscribe.
  // ///
  // /// Returns a future fulfilled with the server's response after the device has been
  // /// subscribed to the topic.
  // Future<MessagingTopicManagementResponse> subscribeToTopic(
  //   List<String> registrationTokenOrTokens,
  //   String topic,
  // ) {
  //   return _sendTopicManagementRequest(
  //     registrationTokenOrTokens,
  //     topic: topic,
  //     methodName: 'subscribeToTopic',
  //     path: _fcmTopicManagementAddPath,
  //   );
  // }

  // /// Unsubscribes a device from an FCM topic.
  // ///
  // /// See [Unsubscribe from a topic](https://firebase.google.com/docs/cloud-messaging/admin/manage-topic-subscriptions#unsubscribe_from_a_topic)
  // /// for code samples and detailed documentation.  Optionally, you can provide an
  // /// array of tokens to unsubscribe multiple devices.
  // ///
  // /// - [registrationTokens]: A device registration token or an array of
  // ///   device registration tokens to unsubscribe from the topic.
  // /// - [topic]: The topic from which to unsubscribe.
  // ///
  // /// Returns a Future fulfilled with the server's response after the device has been
  // /// unsubscribed from the topic.
  // Future<MessagingTopicManagementResponse> unsubscribeFromTopic(
  //   List<String> registrationTokenOrTokens,
  //   String topic,
  // ) {
  //   return _sendTopicManagementRequest(
  //     registrationTokenOrTokens,
  //     topic: topic,
  //     methodName: 'unsubscribeFromTopic',
  //     path: _fcmTopicManagementRemovePath,
  //   );
  // }

  // /// Helper method which sends and handles topic subscription management requests.
  // Future<MessagingTopicManagementResponse> _sendTopicManagementRequest(
  //   List<String> registrationTokenOrTokens, {
  //   required String topic,
  //   required String methodName,
  //   required String path,
  // }) async {
  //   _validateRegistrationTokensType(
  //     registrationTokenOrTokens,
  //     methodName: methodName,
  //   );
  //   _validateTopicType(topic, methodName: methodName);

  //   // Prepend the topic with /topics/ if necessary.
  //   topic = _normalizeTopic(topic);

  //   _validateRegistrationTokens(
  //     registrationTokenOrTokens,
  //     methodName: methodName,
  //   );
  //   _validateTopic(topic, methodName: methodName);

  //   final response = await _requestHandler.invokeRequestHandler(
  //     host: _fcmTopicManagementHost,
  //     path: path,
  //     requestData: {
  //       'to': topic,
  //       'registration_tokens': registrationTokenOrTokens,
  //     },
  //   );

  //   return MessagingTopicManagementResponse._fromResponse(response);
  // }

  // /// Validates the type of the provided registration token(s).
  // /// If invalid, an error will be thrown.
  // void _validateRegistrationTokensType(
  //   List<String> registrationTokenOrTokens, {
  //   required String methodName,
  //   MessagingClientErrorCode errorInfo =
  //       MessagingClientErrorCode.invalidArgument,
  // }) {
  //   if (registrationTokenOrTokens.isEmpty) {
  //     throw FirebaseMessagingAdminException(
  //       errorInfo,
  //       'Registration token(s) provided to $methodName() must be a non-empty string or a '
  //       'non-empty array.',
  //     );
  //   }
  // }

  // /// Validates the provided registration tokens.
  // /// If invalid, an error will be thrown.
  // void _validateRegistrationTokens(
  //   List<String> registrationTokenOrTokens, {
  //   required String methodName,
  //   MessagingClientErrorCode errorInfo =
  //       MessagingClientErrorCode.invalidArgument,
  // }) {
  //   // Validate the array contains no more than 1,000 registration tokens.
  //   if (registrationTokenOrTokens.length > 1000) {
  //     throw FirebaseMessagingAdminException(
  //       errorInfo,
  //       'Too many registration tokens provided in a single request to $methodName(). Batch '
  //       'your requests to contain no more than 1,000 registration tokens per request.',
  //     );
  //   }

  //   // Validate the array contains registration tokens which are non-empty strings.
  //   registrationTokenOrTokens.forEachIndexed((index, registrationToken) {
  //     if (registrationToken.isEmpty) {
  //       throw FirebaseMessagingAdminException(
  //         errorInfo,
  //         'Registration token provided to $methodName() at index $index must be a '
  //         'non-empty string.',
  //       );
  //     }
  //   });
  // }

  // /// Validates the type of the provided topic. If invalid, an error will be thrown.
  // void _validateTopicType(
  //   String topic, {
  //   required String methodName,
  //   MessagingClientErrorCode errorInfo =
  //       MessagingClientErrorCode.invalidArgument,
  // }) {
  //   if (topic.isEmpty) {
  //     throw FirebaseMessagingAdminException(
  //       errorInfo,
  //       'Topic provided to $methodName() must be a string which matches the format '
  //       '"/topics/[a-zA-Z0-9-_.~%]+".',
  //     );
  //   }
  // }

  // /// Normalizes the provided topic name by prepending it with '/topics/', if necessary.
  // String _normalizeTopic(String topic) {
  //   if (!topic.startsWith('/topics/')) {
  //     return '/topics/$topic';
  //   }
  //   return topic;
  // }

  // /// Validates the provided topic. If invalid, an error will be thrown.
  // void _validateTopic(
  //   String topic, {
  //   required String methodName,
  //   MessagingClientErrorCode errorInfo =
  //       MessagingClientErrorCode.invalidArgument,
  // }) {
  //   if (!validator.isTopic(topic)) {
  //     throw FirebaseMessagingAdminException(
  //       errorInfo,
  //       'Topic provided to $methodName() must be a string which matches the format '
  //       '"/topics/[a-zA-Z0-9-_.~%]+".',
  //     );
  //   }
  // }

  // TODO sendAll – missing batch client implementation
  // TODO sendMulticast - relies on sendAll
}
