import 'dart:convert';

import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/src/google_cloud_firestore/status_code.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mock.dart';
import 'util/helpers.dart';

const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

StreamedResponse _errorResponse(int httpCode, String status, String message) {
  return StreamedResponse(
    Stream.value(
      utf8.encode(
        jsonEncode({
          'error': {'code': httpCode, 'status': status, 'message': message},
        }),
      ),
    ),
    httpCode,
    headers: _jsonHeaders,
  );
}

StreamedResponse _successResponse() {
  return StreamedResponse(
    Stream.value(
      utf8.encode(
        jsonEncode({
          'commitTime': '2024-01-01T00:00:00.000Z',
          'writeResults': [
            {'updateTime': '2024-01-01T00:00:00.000Z'},
          ],
        }),
      ),
    ),
    200,
    headers: _jsonHeaders,
  );
}

void main() {
  setUpAll(registerFallbacks);

  group('WriteBatch', () {
    test('retries on UNAVAILABLE and succeeds', () async {
      var callCount = 0;
      final clientMock = ClientMock();

      when(() => clientMock.send(any())).thenAnswer((_) {
        callCount++;
        if (callCount == 1) {
          return Future.value(
            _errorResponse(503, 'UNAVAILABLE', 'Service unavailable'),
          );
        }
        return Future.value(_successResponse());
      });

      final app = createApp(client: clientMock);
      final firestore = Firestore(app);

      await firestore.doc('test/retry').set({'value': 1});
      expect(callCount, 2);
    });

    test('retries on ABORTED and succeeds', () async {
      var callCount = 0;
      final clientMock = ClientMock();

      when(() => clientMock.send(any())).thenAnswer((_) {
        callCount++;
        if (callCount == 1) {
          return Future.value(
            _errorResponse(409, 'ABORTED', 'Transaction lock timeout'),
          );
        }
        return Future.value(_successResponse());
      });

      final app = createApp(client: clientMock);
      final firestore = Firestore(app);

      await firestore.doc('test/retry').set({'value': 1});
      expect(callCount, 2);
    });

    test('succeeds after multiple transient failures', () async {
      var callCount = 0;
      final clientMock = ClientMock();

      when(() => clientMock.send(any())).thenAnswer((_) {
        callCount++;
        if (callCount <= 3) {
          return Future.value(
            _errorResponse(503, 'UNAVAILABLE', 'Service unavailable'),
          );
        }
        return Future.value(_successResponse());
      });

      final app = createApp(client: clientMock);
      final firestore = Firestore(app);

      await firestore.doc('test/retry').set({'value': 1});
      expect(callCount, 4);
    });

    test('does not retry on PERMISSION_DENIED', () async {
      var callCount = 0;
      final clientMock = ClientMock();

      when(() => clientMock.send(any())).thenAnswer((_) {
        callCount++;
        return Future.value(
          _errorResponse(403, 'PERMISSION_DENIED', 'Missing permissions'),
        );
      });

      final app = createApp(client: clientMock);
      final firestore = Firestore(app);

      await expectLater(
        () => firestore.doc('test/retry').set({'value': 1}),
        throwsA(
          isA<FirebaseFirestoreAdminException>().having(
            (e) => e.errorCode.statusCode,
            'statusCode',
            StatusCode.permissionDenied,
          ),
        ),
      );
      expect(callCount, 1);
    });

    test('does not retry on INVALID_ARGUMENT', () async {
      var callCount = 0;
      final clientMock = ClientMock();

      when(() => clientMock.send(any())).thenAnswer((_) {
        callCount++;
        return Future.value(
          _errorResponse(400, 'INVALID_ARGUMENT', 'Invalid field'),
        );
      });

      final app = createApp(client: clientMock);
      final firestore = Firestore(app);

      await expectLater(
        () => firestore.doc('test/retry').set({'value': 1}),
        throwsA(
          isA<FirebaseFirestoreAdminException>().having(
            (e) => e.errorCode.statusCode,
            'statusCode',
            StatusCode.invalidArgument,
          ),
        ),
      );
      expect(callCount, 1);
    });
  });
}
