import 'api_error.dart';
import 'retry.dart';
import 'service.dart';

mixin CreatableMixin<M, T> on ServiceObject<M> {
  Future<T> create(M metadata);
}

/// Mixin that provides the `get()` method for fetching metadata.
///
/// Classes that support fetching metadata should use this mixin.
/// This mixin also provides `exists()` and `get()` convenience methods.
///
/// Example:
/// ```dart
/// class MyObject extends ServiceObject<MyMetadata> with GettableMixin<MyMetadata, MyObject> {
///   @override
///   Future<MyMetadata> getMetadata({String? userProject}) {
///     // Make API call, set metadata, and return it
///   }
/// }
/// ```
mixin GettableMixin<M, T> on ServiceObject<M> {
  /// Fetch metadata from the API and update this instance's metadata.
  ///
  /// This is the core method that makes the API request and sets `this.metadata`.
  /// It mirrors the TypeScript implementation where getMetadata() makes the API
  /// request directly and sets `this.metadata = body`.
  ///
  /// Subclasses must implement this method to make the actual API call.
  /// After fetching metadata, they should call `setInstanceMetadata(metadata)`
  /// to update this instance's metadata.
  Future<M> getMetadata({String? userProject});

  /// Fetch latest metadata from the API and return this instance.
  ///
  /// This calls [getMetadata()] to fetch and update metadata, then returns
  /// this instance. This mirrors the TypeScript implementation where get()
  /// calls getMetadata() internally and returns `self`.
  Future<T> get({String? userProject}) async {
    await getMetadata(userProject: userProject);
    return this as T;
  }

  /// Check if the underlying resource exists.
  ///
  /// Mirrors Node's ServiceObject.exists semantics: returns false on 404,
  /// rethrows other errors.
  Future<bool> exists({String? userProject}) async {
    try {
      await getMetadata(userProject: userProject);
      return true;
    } on ApiError catch (e) {
      if (e.code == 404) return false;
      rethrow;
    }
  }
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
  Future<void> delete({DeleteOptions? options});
}

mixin SettableMixin<M> on ServiceObject<M> {
  /// Set the metadata for this resource.
  ///
  /// Subclasses may override with more specific option types (e.g., [SetMetadataOptions]).
  Future<M> setMetadata(M metadata);
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
  String id;
  M _metadata;

  ServiceObject({required this.service, required this.id, required M metadata})
      : _metadata = metadata;

  /// The resource metadata type used by this object.
  M get metadata => _metadata;
}

// TODO: Check this is hidden from the public API
extension ServiceObjectExtension<M> on ServiceObject<M> {
  void setInstanceMetadata(M metadata) {
    _metadata = metadata;
  }
}
