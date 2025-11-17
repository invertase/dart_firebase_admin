import 'dart:io';

class ApiError implements Exception {
  final int? code;
  final String message;
  final Object? details;

  ApiError(this.message, {this.code, this.details});

  factory ApiError.fromHttpResponse(HttpClientResponse response, String body) {
    return ApiError(
      'Request failed with status ${response.statusCode}',
      code: response.statusCode,
      details: body,
    );
  }

  @override
  String toString() => 'ApiError($code, $message)';
}
