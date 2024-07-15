import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:firebaseapis/fcm/v1.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

void registerFallbacks() {
  registerFallbackValue(_SendMessageRequestFake());
  registerFallbackValue(Uri());
  registerFallbackValue(Request('post', Uri()));
}

class FirebaseAdminMock extends Mock implements FirebaseAdminApp {}

class ClientMock extends Mock implements Client {}

class _SendMessageRequestFake extends Fake implements SendMessageRequest {}
