import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebaseapis/fcm/v1.dart' as fmc1;
import 'package:googleapis_auth/auth_io.dart';
import 'package:meta/meta.dart';

import 'app.dart';

part 'messaging/fmc_exception.dart';
part 'messaging/messaging_api_request_internal.dart';
part 'messaging/messaging_api.dart';

const _fmcMaxBatchSize = 500;

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

        final responses = <SendResponse>[];

        await Future.wait(
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
                responses.add(
                  SendResponse._(success: true, messageId: value.name),
                );
              },
              // ignore: avoid_types_on_closure_parameters
              onError: (Object? error) {
                responses.add(
                  SendResponse._(
                    success: false,
                    error: error is FirebaseMessagingAdminException
                        ? error
                        : FirebaseMessagingAdminException(
                            MessagingClientErrorCode.internal,
                            error.toString(),
                          ),
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

  // TODO sendEach
  // TODO sendEachForMulticast
  // TODO sendAll
  // TODO sendMulticast
  // TODO sendToDevice
  // TODO sendToDeviceGroup
  // TODO sendToTopic
  // TODO sendToCondition
  // TODO subscribeToTopic
  // TODO unsubscribeFromTopic
}
