part of 'messaging.dart';

/// Request handler for Firebase Cloud Messaging API operations.
///
/// Handles complex business logic, request/response transformations,
/// and validation. Delegates simple API calls to [FirebaseMessagingHttpClient].
class FirebaseMessagingRequestHandler {
  FirebaseMessagingRequestHandler(
    FirebaseApp app, {
    FirebaseMessagingHttpClient? httpClient,
  }) : _httpClient = httpClient ?? FirebaseMessagingHttpClient(app);

  final FirebaseMessagingHttpClient _httpClient;

  /// Sends the given message via FCM.
  ///
  /// - [message] - The message payload.
  /// - [dryRun] - Whether to send the message in the dry-run
  ///   (validation only) mode.
  ///
  /// Returns a unique message ID string after the message has been successfully
  /// handed off to the FCM service for delivery.
  Future<String> send(Message message, {bool? dryRun}) {
    return _httpClient.v1(
      (client, projectId) async {
        final parent = _httpClient.buildParent(projectId);
        final response = await client.projects.messages.send(
          fmc1.SendMessageRequest(
            message: message._toProto(),
            validateOnly: dryRun,
          ),
          parent,
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
    return _httpClient.v1(
      (client, projectId) async {
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

        final parent = _httpClient.buildParent(projectId);
        final responses = await Future.wait<SendResponse>(
          messages.map((message) async {
            final response = client.projects.messages.send(
              fmc1.SendMessageRequest(
                message: message._toProto(),
                validateOnly: dryRun,
              ),
              parent,
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
  /// This method uses the [sendEach] API under the hood to send the given
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
}
