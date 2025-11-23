part of '../app.dart';

enum FirebaseServiceType {
  appCheck(name: 'app-check'),
  auth(name: 'auth'),
  firestore(name: 'firestore'),
  messaging(name: 'messaging'),
  securityRules(name: 'security-rules');

  const FirebaseServiceType({required this.name});

  final String name;
}

/// Base class for all Firebase services.
///
/// All Firebase services (Auth, Messaging, Firestore, etc.) implement this
/// interface to enable proper lifecycle management.
///
/// Services are automatically registered with the [FirebaseApp] when first
/// accessed via factory constructors. When the app is closed via
/// [FirebaseApp.close], all registered services have their [delete] method
/// called to clean up resources.
///
/// Example implementation:
/// ```dart
/// class MyService implements FirebaseService {
///   factory MyService(FirebaseApp app) {
///     return app.getOrInitService(
///       'my-service',
///       (app) => MyService._(app),
///     ) as MyService;
///   }
///
///   MyService._(this.app);
///
///   @override
///   final FirebaseApp app;
///
///   @override
///   Future<void> delete() async {
///     // Cleanup logic here
///   }
/// }
/// ```
abstract class FirebaseService {
  FirebaseService(this.app);

  /// The Firebase app this service is associated with.
  final FirebaseApp app;

  /// Cleans up resources used by this service.
  ///
  /// This method is called automatically when [FirebaseApp.close] is called
  /// on the parent app. Services should override this to release any held
  /// resources such as:
  /// - Network connections
  /// - File handles
  /// - Cached data
  /// - Subscriptions or listeners
  Future<void> delete();
}
