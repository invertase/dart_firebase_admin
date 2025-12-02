import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/src/auth.dart';
import 'package:googleapis/fcm/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

void registerFallbacks() {
  registerFallbackValue(_SendMessageRequestFake());
  registerFallbackValue(Uri());
  registerFallbackValue(Request('post', Uri()));
}

class FirebaseAdminMock extends Mock implements FirebaseApp {}

class ClientMock extends Mock implements AuthClient {}

class AuthRequestHandlerMock extends Mock implements AuthRequestHandler {}

class AuthHttpClientMock extends Mock implements AuthHttpClient {}

class _SendMessageRequestFake extends Fake implements SendMessageRequest {}
