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
    return _httpClient.v1((api, projectId) async {
      final parent = _httpClient.buildParent(projectId);
      final response = await api.projects.messages.send(
        fmc1.SendMessageRequest(
          message: message._toRequest(),
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
    });
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
    return _httpClient.v1((api, projectId) async {
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
          final response = api.projects.messages.send(
            fmc1.SendMessageRequest(
              message: message._toRequest(),
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
              // Convert DetailedApiRequestError to FirebaseMessagingAdminException
              final messagingError = error is FirebaseMessagingAdminException
                  ? error
                  : error is fmc1.DetailedApiRequestError
                  ? _createFirebaseError(
                      statusCode: error.status,
                      body: switch (error.jsonResponse) {
                        null => '',
                        final json => jsonEncode(json),
                      },
                      isJson: error.jsonResponse != null,
                    )
                  : FirebaseMessagingAdminException(
                      MessagingClientErrorCode.internalError,
                      error.toString(),
                    );

              return SendResponse._(success: false, error: messagingError);
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
    });
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

  /// Subscribes a list of registration tokens to an FCM topic.
  Future<MessagingTopicManagementResponse> subscribeToTopic(
    List<String> registrationTokens,
    String topic,
  ) {
    return _sendTopicManagementRequest(
      registrationTokens,
      topic,
      'subscribeToTopic',
      '/iid/v1:batchAdd',
    );
  }

  /// Unsubscribes a list of registration tokens from an FCM topic.
  Future<MessagingTopicManagementResponse> unsubscribeFromTopic(
    List<String> registrationTokens,
    String topic,
  ) {
    return _sendTopicManagementRequest(
      registrationTokens,
      topic,
      'unsubscribeFromTopic',
      '/iid/v1:batchRemove',
    );
  }

  /// Sends a topic management request to the IID API.
  Future<MessagingTopicManagementResponse> _sendTopicManagementRequest(
    List<String> registrationTokens,
    String topic,
    String methodName,
    String path,
  ) async {
    // Validate inputs
    _validateRegistrationTokens(registrationTokens, methodName);
    _validateTopic(topic, methodName);

    // Normalize topic (prepend /topics/ if needed)
    final normalizedTopic = _normalizeTopic(topic);

    // Make the request
    final response = await _httpClient.invokeRequestHandler(
      host: _httpClient.iidApiHost,
      path: path,
      requestData: {
        'to': normalizedTopic,
        'registration_tokens': registrationTokens,
      },
    );

    // Map the response
    return _mapRawResponseToTopicManagementResponse(response);
  }

  /// Validates registration tokens list.
  void _validateRegistrationTokens(
    List<String> registrationTokens,
    String methodName,
  ) {
    if (registrationTokens.isEmpty) {
      throw FirebaseMessagingAdminException(
        MessagingClientErrorCode.invalidArgument,
        'Registration tokens provided to $methodName() must be a non-empty list.',
      );
    }

    for (final token in registrationTokens) {
      if (token.isEmpty) {
        throw FirebaseMessagingAdminException(
          MessagingClientErrorCode.invalidArgument,
          'Registration tokens provided to $methodName() must all be non-empty strings.',
        );
      }
    }
  }

  /// Validates the topic format.
  void _validateTopic(String topic, String methodName) {
    if (topic.isEmpty) {
      throw FirebaseMessagingAdminException(
        MessagingClientErrorCode.invalidArgument,
        'Topic provided to $methodName() must be a non-empty string.',
      );
    }

    // Topic should match pattern: /topics/[a-zA-Z0-9-_.~%]+
    final normalizedTopic = _normalizeTopic(topic);
    final topicRegex = RegExp(r'^/topics/[a-zA-Z0-9\-_.~%]+$');

    if (!topicRegex.hasMatch(normalizedTopic)) {
      throw FirebaseMessagingAdminException(
        MessagingClientErrorCode.invalidArgument,
        'Topic provided to $methodName() must be a string which matches the format '
        '"/topics/[a-zA-Z0-9-_.~%]+".',
      );
    }
  }

  /// Normalizes a topic by prepending '/topics/' if necessary.
  String _normalizeTopic(String topic) {
    if (!topic.startsWith('/topics/')) {
      return '/topics/$topic';
    }
    return topic;
  }

  /// Maps the raw IID API response to MessagingTopicManagementResponse.
  MessagingTopicManagementResponse _mapRawResponseToTopicManagementResponse(
    Object? response,
  ) {
    var successCount = 0;
    var failureCount = 0;
    final errors = <FirebaseArrayIndexError>[];

    if (response is Map && response.containsKey('results')) {
      final results = response['results'] as List<dynamic>;

      for (var index = 0; index < results.length; index++) {
        final result = results[index] as Map;

        if (result.containsKey('error')) {
          failureCount++;
          final errorMessage = result['error'] as String;

          errors.add(
            FirebaseArrayIndexError(
              index: index,
              error: FirebaseMessagingAdminException(
                MessagingClientErrorCode.unknownError,
                errorMessage,
              ),
            ),
          );
        } else {
          successCount++;
        }
      }
    }

    return MessagingTopicManagementResponse._(
      failureCount: failureCount,
      successCount: successCount,
      errors: errors,
    );
  }
}
