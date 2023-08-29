import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:firebaseapis/firestore/v1.dart' as firestore1;
import 'package:firebaseapis/firestore/v1beta1.dart' as firestore1beta1;
import 'package:firebaseapis/firestore/v1beta2.dart' as firestore1beta2;
import 'package:firebaseapis/identitytoolkit/v3.dart' as auth3;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:intl/intl.dart';

import '../../dart_firebase_admin.dart';
import '../object_utils.dart';
import 'util.dart';
import 'validate.dart';

part 'convert.dart';
part 'document.dart';
part 'document_reader.dart';
part 'field_value.dart';
part 'firestore.freezed.dart';
part 'geo_point.dart';
part 'path.dart';
part 'reference.dart';
part 'serializer.dart';
part 'timestamp.dart';
part 'transaction.dart';
part 'types.dart';
part 'write_batch.dart';
part 'document_change.dart';
part 'filter.dart';

const _defaultMaxIdleChannels = 1;

class Firestore {
  Firestore(this.app, {Settings? settings}) {
    _validateAndApplySettings(settings ?? Settings());

    // TODO set retryConfig/_backoffSettings
    final maxIdleChannels =
        _settings.maxIdleChannels ?? _defaultMaxIdleChannels;
    // TODO do we need _clientPool? If we don't, should we remove some settings params?
    // In particular, it appears that the node api either uses grpc or rest
    // But we likely will always use grpc
  }

  final FirebaseAdminApp app;
  late final _client = FirestoreHttpClient(app);

  // TODO do we need a `setSettings` method like in node?
  // If we don't, remove this frozen settings
  var _settingsFrozen = false;
  late Settings _settings;

  late final _serializer = Serializer(this);

  /// Returns the Database ID for this Firestore instance.
  String get _databaseId => _settings.databaseId ?? '(default)';

  void _validateAndApplySettings(Settings settingsArg) {
    var settings = settingsArg;

    // If preferRest is not specified in settings, but is set as environment variable,
    // then use the environment variable value.
    final preferRestEnvValue = tryGetPreferRestEnvironmentVariable();
    final settingsPreferRest = settings.preferRest;
    if (settingsPreferRest == null && preferRestEnvValue != null) {
      settings = settings.copyWith(preferRest: preferRestEnvValue);
    }

    // If the environment variable is set, it should always take precedence
    // over any user passed in settings.
    final emulatorHost = firebaseEmulatorHostEnv;
    if (emulatorHost != null) {
      settings = settings.copyWith(
        // The host will be validated in the Settings constructor.
        host: emulatorHost,
        ssl: false,
      );
    }
    final url = settings.host.let(Uri.http);

    // Only store the host if a valid value was provided in `host`.
    if (url != null) {
      if ((settings.servicePath != null && settings.servicePath != url.host) ||
          (settings.apiEndpoint != null && settings.apiEndpoint != url.host)) {
        stderr.writeln(
          'The provided host (${url.host}) in "settings" does not '
          'match the existing host (${settings.servicePath ?? settings.apiEndpoint}). '
          'Using the provided host.',
        );
      }

      settings = settings.copyWith(servicePath: url.host);
      if (url.hasPort && settings.port == null) {
        settings = settings.copyWith(port: url.port);
      }

      // We need to remove the `host` and `apiEndpoint` setting, in case a user
      // calls `settings()`, which will compare the the provided `host` to the
      // existing hostname stored on `servicePath`.
      settings = settings.copyWith(
        // TODO is setting those to null enough? could be a case of null vs undefined
        host: null,
        apiEndpoint: null,
      );
    }

    _settings = settings;
  }

  /// Gets a [DocumentReference]{@link DocumentReference} instance that
  /// refers to the document at the specified path.
  ///
  /// - [documentPath]: A slash-separated path to a document.
  ///
  /// Returns The [DocumentReference] instance.
  ///
  /// ```dart
  /// final documentRef = firestore.doc('collection/document');
  /// print('Path of document is ${documentRef.path}');
  /// ```
  DocumentReference<DocumentData> doc(String documentPath) {
    _validateResourcePath('documentPath', documentPath);

    final path = _ResourcePath.empty._append(documentPath);
    if (!path.isDocument) {
      throw ArgumentError.value(
        documentPath,
        'documentPath',
        'Value for argument "documentPath" must point to a document, but was "$documentPath". '
            'Your path does not contain an even number of components.',
      );
    }

    return DocumentReference._(
      firestore: this,
      path: path,
      converter: FirestoreDataConverter.jsonConverter,
    );
  }

  /// Gets a [CollectionReference] instance
  /// that refers to the collection at the specified path.
  ///
  /// - [collectionPath]: A slash-separated path to a collection.
  ///
  /// Returns [CollectionReference] A reference to the new
  /// subcollection.
  ///
  /// @example
  /// ```
  /// let documentRef = firestore.doc('col/doc');
  /// let subcollection = documentRef.collection('subcollection');
  /// console.log(`Path to subcollection: ${subcollection.path}`);
  /// ```
  CollectionReference<DocumentData> collection(String collectionPath) {
    _validateResourcePath('collectionPath', collectionPath);

    final path = _ResourcePath.empty._append(collectionPath);
    if (!path.isCollection) {
      throw ArgumentError.value(
        collectionPath,
        'collectionPath',
        'Value for argument "collectionPath" must point to a collection, but was '
            '"$collectionPath". Your path does not contain an odd number of components.',
      );
    }

    return CollectionReference._(
      firestore: this,
      path: path,
      converter: FirestoreDataConverter.jsonConverter,
    );
  }

  // Retrieves multiple documents from Firestore.
  Future<List<DocumentSnapshot<T>>> getAll<T>(
    List<DocumentReference<T>> documents, [
    ReadOptions? readOptions,
  ]) async {
    if (documents.isEmpty) {
      throw ArgumentError.value(
        documents,
        'documents',
        'must not be an empty array.',
      );
    }

    final fieldMask = parseFieldMask(readOptions);
    final tag = requestTag();

    final reader = DocumentReader(
      firestore: this,
      documents: documents,
      transactionId: null,
      fieldMask: fieldMask,
    );

    return reader.get(tag);
  }
}

class SettingsCredentials {
  SettingsCredentials({this.clientEmail, this.privateKey});

  final String? clientEmail;
  final String? privateKey;
}

/// Settings used to directly configure a `Firestore` instance.
@freezed
class Settings with _$Settings {
  /// Settings used to directly configure a `Firestore` instance.
  factory Settings({
    @Default(<String, String>{}) Map<String, String> customHeaders,

    /// The database name. If omitted, the default database will be used.
    String? databaseId,

    // TODO do we care about those? Maybe they should be from FirebaseAdminApp?
    /// The hostname to connect to.
    String? host,
    // TODO: Appears to be a clone of host?
    String? servicePath,
    // TODO: Appears to be a clone of host?
    String? apiEndpoint,

    /// The port to connect to.
    int? port,

    /// Local file containing the Service Account credentials as downloaded from
    /// the Google Developers Console. Can  be omitted in environments that
    /// support {@link https://cloud.google.com/docs/authentication Application
    /// Default Credentials}. To configure Firestore with custom credentials, use
    /// the `credentials` property to provide the `client_email` and
    /// `private_key` of your service account.
    String? keyFilename,

    /// The 'client_email' and 'private_key' properties of the service account
    /// to use with your Firestore project. Can be omitted in environments that
    /// support {@link https://cloud.google.com/docs/authentication Application
    /// Default Credentials}. If your credentials are stored in a JSON file, you
    /// can specify a `keyFilename` instead.
    // TODO should this be taken from FirebaseAdmingApp?
    SettingsCredentials? credentials,

    /// Whether to use SSL when connecting.
    // TODO is this used in dart?
    bool? ssl,

    /// The maximum number of idle GRPC channels to keep. A smaller number of idle
    /// channels reduces memory usage but increases request latency for clients
    /// with fluctuating request rates. If set to 0, shuts down all GRPC channels
    /// when the client becomes idle. Defaults to 1.
    // TODO is this used in dart?
    int? maxIdleChannels,

    /// Whether to use `BigInt` for integer types when deserializing Firestore
    /// Documents. Regardless of magnitude, all integer values are returned as
    /// `BigInt` to match the precision of the Firestore backend. Floating point
    /// numbers continue to use JavaScript's `number` type.
    // TODO is this used in dart?
    bool? useBigInt,

    /// Whether to skip nested properties that are set to `undefined` during
    /// object serialization. If set to `true`, these properties are skipped
    /// and not written to Firestore. If set `false` or omitted, the SDK throws
    /// an exception when it encounters properties of type `undefined`.
    // TODO is this used in dart?
    bool? ignoreUndefinedProperties,

    /// Whether to force the use of HTTP/1.1 REST transport until a method that requires gRPC
    /// is called. When a method requires gRPC, this Firestore client will load dependent gRPC
    /// libraries and then use gRPC transport for communication from that point forward.
    /// Currently the only operation that requires gRPC is creating a snapshot listener with
    /// the method `DocumentReference<T>.onSnapshot()`, `CollectionReference<T>.onSnapshot()`,
    /// or `Query<T>.onSnapshot()`.
    // TODO is this used in dart?
    bool? preferRest,

    // TODO
    // [key: String]: any; // Accept other properties, such as GRPC settings.
  }) = _Settings;

  Settings._() {
    final host = this.host;
    if (host != null) validateHost(host, argName: 'host');

    final maxIdleChannels = this.maxIdleChannels;
    if (maxIdleChannels != null) {
      throw ArgumentError.value(
        maxIdleChannels,
        'maxIdleChannels',
        'Must be a positive number',
      );
    }
  }

  // TODO should we specify a custom name?
  String get libName => 'gccl';
  // TODO automate this version to be picked up from pubspec.yaml?
  // TODO include firebaseVersion if present?
  String get libVersion => '0.0.1';

  toJson() {
    // TODO set privateKey & clientEmail to ***
  }
}

@internal
class FirestoreHttpClient {
  FirestoreHttpClient(this.app);

  // TODO needs to send "owner" as bearer token when using the emulator
  final FirebaseAdminApp app;

  auth.AuthClient? _client;
  // TODO refactor with auth
  // TODO is it fine to use AuthClient?
  Future<auth.AuthClient> _getClient() async {
    return _client ??= await app.credential.getAuthClient([
      auth3.IdentityToolkitApi.cloudPlatformScope,
      auth3.IdentityToolkitApi.firebaseScope,
    ]);
  }

  Future<R> v1<R>(
    Future<R> Function(firestore1.FirestoreApi client) fn,
  ) {
    return guard(
      () async => fn(
        firestore1.FirestoreApi(
          await _getClient(),
          rootUrl: app.apiHost.toString(),
        ),
      ),
    );
  }

  Future<R> v1Beta1<R>(
    Future<R> Function(firestore1beta1.FirestoreApi client) fn,
  ) async {
    return guard(
      () async => fn(
        firestore1beta1.FirestoreApi(
          await _getClient(),
          rootUrl: app.apiHost.toString(),
        ),
      ),
    );
  }

  Future<R> v1Beta2<R>(
    Future<R> Function(firestore1beta2.FirestoreApi client) fn,
  ) async {
    return guard(
      () async => fn(
        firestore1beta2.FirestoreApi(
          await _getClient(),
          rootUrl: app.apiHost.toString(),
        ),
      ),
    );
  }
}
