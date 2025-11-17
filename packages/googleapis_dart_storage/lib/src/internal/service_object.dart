import 'package:meta/meta.dart';

import 'api_error.dart';
import 'retry.dart';
import 'service.dart';

/// Base class for resource objects (Bucket, File, etc.).
@immutable
abstract class ServiceObject<M> {
  final Service service;
  final String id;

  const ServiceObject({required this.service, required this.id});

  /// The resource metadata type used by this object.
  M get metadata;

  /// Fetch latest metadata from the API.
  Future<M> get();

  /// Persist metadata changes to the API.
  Future<M> setMetadata(M metadata);

  /// Delete this resource.
  ///
  /// Subclasses may override with more specific option types (e.g., [DeleteOptions]).
  Future<void> delete({PreconditionOptions? options});

  /// Check if the underlying resource exists.
  ///
  /// Mirrors Node's ServiceObject.exists semantics: returns false on 404,
  /// rethrows other errors.
  Future<bool> exists() async {
    try {
      await get();
      return true;
    } on ApiError catch (e) {
      if (e.code == 404) return false;
      rethrow;
    }
  }

  /// Convenience alias that mirrors Node's getMetadata.
  Future<M> getMetadata() => get();
}
