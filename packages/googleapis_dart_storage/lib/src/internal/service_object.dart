import 'api_error.dart';
import 'retry.dart';
import 'service.dart';

/// Mixin that provides the `get()` method for fetching metadata.
///
/// Classes that support fetching metadata should use this mixin.
/// This mixin also provides `exists()` and `getMetadata()` convenience methods.
///
/// Example:
/// ```dart
/// class MyObject extends ServiceObject<MyMetadata> with GettableMixin<MyMetadata> {
///   @override
///   Future<MyMetadata> get() {
///     // implementation
///   }
/// }
/// ```
mixin GettableMixin<M> on ServiceObject<M> {
  /// Fetch latest metadata from the API.
  Future<M> get();

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

/// Mixin that provides the `setMetadata()` method for updating metadata.
///
/// Classes that support updating metadata should use this mixin.
/// Example:
/// ```dart
/// class MyObject extends ServiceObject<MyMetadata> with SettableMixin<MyMetadata> {
///   @override
///   Future<MyMetadata> setMetadata(MyMetadata metadata) {
///     // implementation
///   }
/// }
/// ```
mixin SettableMixin<M> on ServiceObject<M> {
  /// Persist metadata changes to the API.
  Future<M> setMetadata(M metadata);
}

/// Mixin that provides the `delete()` method for deleting resources.
///
/// Classes that support deletion should use this mixin.
/// Example:
/// ```dart
/// class MyObject extends ServiceObject<MyMetadata> with DeletableMixin {
///   @override
///   Future<void> delete({PreconditionOptions? options}) {
///     // implementation
///   }
/// }
/// ```
mixin DeletableMixin<M> on ServiceObject<M> {
  /// Delete this resource.
  ///
  /// Subclasses may override with more specific option types (e.g., [DeleteOptions]).
  Future<void> delete({PreconditionOptions? options});
}

/// Base class for resource objects (Bucket, File, etc.).
///
/// This class provides the core structure for service objects. To opt-in to
/// specific capabilities, use the appropriate mixins:
/// - [GettableMixin] for `get()`, `exists()`, and `getMetadata()` support
/// - [SettableMixin] for `setMetadata()` support
/// - [DeletableMixin] for `delete()` support
///
/// This mirrors the Node.js SDK's pattern of using a `methods` array to
/// control which methods are available on a service object.
///
/// Methods are only available when the corresponding mixin is used. If you
/// try to call a method that isn't supported, you'll get a compile-time error.
abstract class ServiceObject<M> {
  final Service service;
  final String id;

  const ServiceObject({required this.service, required this.id});

  /// The resource metadata type used by this object.
  M get metadata;
}
