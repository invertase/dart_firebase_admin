import 'dart:io';

import 'package:googleapis/storage/v1.dart' as storage_v1;

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

  /// Create an ApiError from an exception, handling DetailedApiRequestError
  /// and other error types from the googleapis package.
  factory ApiError.fromException(Object exception) {
    // Handle DetailedApiRequestError from googleapis package
    if (exception is storage_v1.DetailedApiRequestError) {
      return ApiError(
        exception.message ?? 'API request failed',
        code: exception.status,
        details: exception,
      );
    }

    // Generic fallback for other exception types
    return ApiError(exception.toString(), details: exception);
  }

  @override
  String toString() => 'ApiError($code, $message)';
}
