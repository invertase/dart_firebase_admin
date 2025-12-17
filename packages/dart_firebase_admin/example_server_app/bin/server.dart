import 'dart:convert';
import 'dart:io';

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/messaging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  // Get port from environment (Cloud Run sets PORT)
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  // Initialize Firebase Admin SDK
  final app = FirebaseApp.initializeApp();

  print('Firebase Admin SDK initialized');

  final router = Router()
    ..get('/health', healthHandler)
    ..post('/send-message', (Request req) => sendMessageHandler(req, app))
    ..post(
      '/subscribe-topic',
      (Request req) => subscribeToTopicHandler(req, app),
    )
    ..post('/verify-token', (Request req) => verifyTokenHandler(req, app));

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler((request) => router.call(request));

  final server = await shelf_io.serve(handler, '0.0.0.0', port);
  print('Server running on port ${server.port}');
}

Response healthHandler(Request req) => Response.ok(
  jsonEncode({
    'status': 'healthy',
    'timestamp': DateTime.now().toIso8601String(),
  }),
);

/// Send FCM message
Future<Response> sendMessageHandler(Request request, FirebaseApp app) async {
  try {
    final body =
        jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final token = body['token'] as String?;
    final title = body['title'] as String?;
    final bodyText = body['body'] as String?;

    if (token == null || title == null || bodyText == null) {
      return Response.badRequest(
        body: jsonEncode({
          'error': 'Missing required fields: token, title, body',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final messageId = await app.messaging.send(
      TokenMessage(
        token: token,
        notification: Notification(title: title, body: bodyText),
      ),
    );

    return Response.ok(
      jsonEncode({'success': true, 'messageId': messageId}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

/// Subscribe tokens to topic
Future<Response> subscribeToTopicHandler(
  Request request,
  FirebaseApp app,
) async {
  try {
    final body =
        jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final tokens = (body['tokens'] as List<dynamic>?)?.cast<String>();
    final topic = body['topic'] as String?;

    if (tokens == null || tokens.isEmpty || topic == null) {
      return Response.badRequest(
        body: jsonEncode({
          'error': 'Missing required fields: tokens (array), topic',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final response = await app.messaging.subscribeToTopic(tokens, topic);

    return Response.ok(
      jsonEncode({
        'success': true,
        'successCount': response.successCount,
        'failureCount': response.failureCount,
        'errors': response.errors
            .map((e) => {'index': e.index, 'error': e.error.message})
            .toList(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

/// Verify Firebase ID token
Future<Response> verifyTokenHandler(Request request, FirebaseApp app) async {
  try {
    final body =
        jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final idToken = body['idToken'] as String?;

    if (idToken == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Missing required field: idToken'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final decodedToken = await app.auth.verifyIdToken(idToken);

    return Response.ok(
      jsonEncode({
        'success': true,
        'uid': decodedToken.uid,
        'email': decodedToken.email,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.unauthorized(
      jsonEncode({'error': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
