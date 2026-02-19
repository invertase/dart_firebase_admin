import 'dart:async';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:dart_firebase_admin/src/utils/utils.dart';
import 'package:dart_firebase_admin/version.g.dart';
import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  group('FirebaseUserAgentClient', () {
    test('adds X-Firebase-Client header to every request', () async {
      final captured = <BaseRequest>[];
      final client = FirebaseUserAgentClient(_CapturingAuthClient(captured));

      await client.send(Request('GET', Uri.parse('https://example.com/')));

      expect(captured.length, 1);
      expect(
        captured.first.headers['X-Firebase-Client'],
        'fire-admin-dart/$packageVersion',
      );
    });

    test('header value is fire-admin-dart/<version>', () async {
      final captured = <BaseRequest>[];
      final client = FirebaseUserAgentClient(_CapturingAuthClient(captured));

      await client.send(Request('GET', Uri.parse('https://example.com/')));

      final value = captured.first.headers['X-Firebase-Client']!;
      expect(value, startsWith('fire-admin-dart/'));
      expect(value.split('/').last, packageVersion);
    });

    test('adds X-Goog-Api-Client header to every request', () async {
      final captured = <BaseRequest>[];
      final client = FirebaseUserAgentClient(_CapturingAuthClient(captured));

      await client.send(Request('GET', Uri.parse('https://example.com/')));

      expect(captured.length, 1);
      expect(
        captured.first.headers['X-Goog-Api-Client'],
        'gl-dart/$dartVersion fire-admin-dart/$packageVersion',
      );
    });

    test(
      'X-Goog-Api-Client has correct format gl-dart/<version> fire-admin-dart/<version>',
      () async {
        final captured = <BaseRequest>[];
        final client = FirebaseUserAgentClient(_CapturingAuthClient(captured));

        await client.send(Request('GET', Uri.parse('https://example.com/')));

        final value = captured.first.headers['X-Goog-Api-Client']!;
        final parts = value.split(' ');
        expect(parts.length, 2);
        expect(parts[0], startsWith('gl-dart/'));
        expect(parts[1], startsWith('fire-admin-dart/'));
        expect(parts[1].split('/').last, packageVersion);
      },
    );

    test('preserves other headers on the request', () async {
      final captured = <BaseRequest>[];
      final client = FirebaseUserAgentClient(_CapturingAuthClient(captured));

      final request = Request('POST', Uri.parse('https://example.com/'));
      request.headers['content-type'] = 'application/json';
      request.headers['Authorization'] = 'Bearer tok';
      await client.send(request);

      expect(captured.first.headers['content-type'], 'application/json');
      expect(captured.first.headers['Authorization'], 'Bearer tok');
    });

    test('overwrites any pre-existing X-Firebase-Client header', () async {
      // The legacy messaging client used to set fire-admin-node/<version>;
      // FirebaseUserAgentClient should replace it with the correct value.
      final captured = <BaseRequest>[];
      final client = FirebaseUserAgentClient(_CapturingAuthClient(captured));

      final request = Request('POST', Uri.parse('https://example.com/'));
      request.headers['X-Firebase-Client'] = 'fire-admin-node/12.0.0';
      await client.send(request);

      expect(
        captured.first.headers['X-Firebase-Client'],
        'fire-admin-dart/$packageVersion',
      );
    });

    test('overwrites any pre-existing X-Goog-Api-Client header', () async {
      final captured = <BaseRequest>[];
      final client = FirebaseUserAgentClient(_CapturingAuthClient(captured));

      final request = Request('POST', Uri.parse('https://example.com/'));
      request.headers['X-Goog-Api-Client'] = 'gl-node/18.0.0 fire-admin/12.0.0';
      await client.send(request);

      expect(
        captured.first.headers['X-Goog-Api-Client'],
        'gl-dart/$dartVersion fire-admin-dart/$packageVersion',
      );
    });

    test('injects both headers on every individual request', () async {
      final captured = <BaseRequest>[];
      final client = FirebaseUserAgentClient(_CapturingAuthClient(captured));

      await client.send(Request('GET', Uri.parse('https://example.com/1')));
      await client.send(Request('POST', Uri.parse('https://example.com/2')));
      await client.send(Request('PUT', Uri.parse('https://example.com/3')));

      expect(captured.length, 3);
      for (final req in captured) {
        expect(
          req.headers['X-Firebase-Client'],
          'fire-admin-dart/$packageVersion',
        );
        expect(
          req.headers['X-Goog-Api-Client'],
          'gl-dart/$dartVersion fire-admin-dart/$packageVersion',
        );
      }
    });

    test('delegates close() to the inner client', () async {
      var closed = false;
      final client = FirebaseUserAgentClient(
        _CapturingAuthClient([], onClose: () => closed = true),
      );

      client.close();

      expect(closed, isTrue);
    });

    test('delegates credentials getter to the inner client', () {
      final inner = _CapturingAuthClient([]);
      final client = FirebaseUserAgentClient(inner);

      // credentials throws UnimplementedError on our stub — same as EmulatorClient.
      expect(() => client.credentials, throwsUnimplementedError);
    });
  });
}

/// Minimal [googleapis_auth.AuthClient] that records every [BaseRequest]
/// passed to [send] without making real network calls.
class _CapturingAuthClient extends BaseClient
    implements googleapis_auth.AuthClient {
  _CapturingAuthClient(this._captured, {void Function()? onClose})
    : _onClose = onClose;

  final List<BaseRequest> _captured;
  final void Function()? _onClose;

  @override
  googleapis_auth.AccessCredentials get credentials =>
      throw UnimplementedError();

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    _captured.add(request);
    return StreamedResponse(const Stream.empty(), 200);
  }

  @override
  void close() => _onClose?.call();
}
