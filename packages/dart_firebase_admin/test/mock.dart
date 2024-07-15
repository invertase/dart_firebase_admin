import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class FirebaseAdminMock extends Mock implements FirebaseAdminApp {}

class ClientMock extends Mock implements Client {}
