// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firestore.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Settings {
  Map<String, String> get customHeaders => throw _privateConstructorUsedError;

  /// The database name. If omitted, the default database will be used.
  String? get databaseId =>
      throw _privateConstructorUsedError; // TODO do we care about those? Maybe they should be from FirebaseAdminApp?
  /// The hostname to connect to.
  String? get host =>
      throw _privateConstructorUsedError; // TODO: Appears to be a clone of host?
  String? get servicePath =>
      throw _privateConstructorUsedError; // TODO: Appears to be a clone of host?
  String? get apiEndpoint => throw _privateConstructorUsedError;

  /// The port to connect to.
  int? get port => throw _privateConstructorUsedError;

  /// Local file containing the Service Account credentials as downloaded from
  /// the Google Developers Console. Can  be omitted in environments that
  /// support {@link https://cloud.google.com/docs/authentication Application
  /// Default Credentials}. To configure Firestore with custom credentials, use
  /// the `credentials` property to provide the `client_email` and
  /// `private_key` of your service account.
  String? get keyFilename => throw _privateConstructorUsedError;

  /// The 'client_email' and 'private_key' properties of the service account
  /// to use with your Firestore project. Can be omitted in environments that
  /// support {@link https://cloud.google.com/docs/authentication Application
  /// Default Credentials}. If your credentials are stored in a JSON file, you
  /// can specify a `keyFilename` instead.
// TODO should this be taken from FirebaseAdmingApp?
  SettingsCredentials? get credentials => throw _privateConstructorUsedError;

  /// Whether to use SSL when connecting.
// TODO is this used in dart?
  bool? get ssl => throw _privateConstructorUsedError;

  /// The maximum number of idle GRPC channels to keep. A smaller number of idle
  /// channels reduces memory usage but increases request latency for clients
  /// with fluctuating request rates. If set to 0, shuts down all GRPC channels
  /// when the client becomes idle. Defaults to 1.
// TODO is this used in dart?
  int? get maxIdleChannels => throw _privateConstructorUsedError;

  /// Whether to use `BigInt` for integer types when deserializing Firestore
  /// Documents. Regardless of magnitude, all integer values are returned as
  /// `BigInt` to match the precision of the Firestore backend. Floating point
  /// numbers continue to use JavaScript's `number` type.
// TODO is this used in dart?
  bool? get useBigInt => throw _privateConstructorUsedError;

  /// Whether to skip nested properties that are set to `undefined` during
  /// object serialization. If set to `true`, these properties are skipped
  /// and not written to Firestore. If set `false` or omitted, the SDK throws
  /// an exception when it encounters properties of type `undefined`.
// TODO is this used in dart?
  bool? get ignoreUndefinedProperties => throw _privateConstructorUsedError;

  /// Whether to force the use of HTTP/1.1 REST transport until a method that requires gRPC
  /// is called. When a method requires gRPC, this Firestore client will load dependent gRPC
  /// libraries and then use gRPC transport for communication from that point forward.
  /// Currently the only operation that requires gRPC is creating a snapshot listener with
  /// the method `DocumentReference<T>.onSnapshot()`, `CollectionReference<T>.onSnapshot()`,
  /// or `Query<T>.onSnapshot()`.
// TODO is this used in dart?
  bool? get preferRest => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SettingsCopyWith<Settings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsCopyWith<$Res> {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) then) =
      _$SettingsCopyWithImpl<$Res, Settings>;
  @useResult
  $Res call(
      {Map<String, String> customHeaders,
      String? databaseId,
      String? host,
      String? servicePath,
      String? apiEndpoint,
      int? port,
      String? keyFilename,
      SettingsCredentials? credentials,
      bool? ssl,
      int? maxIdleChannels,
      bool? useBigInt,
      bool? ignoreUndefinedProperties,
      bool? preferRest});
}

/// @nodoc
class _$SettingsCopyWithImpl<$Res, $Val extends Settings>
    implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customHeaders = null,
    Object? databaseId = freezed,
    Object? host = freezed,
    Object? servicePath = freezed,
    Object? apiEndpoint = freezed,
    Object? port = freezed,
    Object? keyFilename = freezed,
    Object? credentials = freezed,
    Object? ssl = freezed,
    Object? maxIdleChannels = freezed,
    Object? useBigInt = freezed,
    Object? ignoreUndefinedProperties = freezed,
    Object? preferRest = freezed,
  }) {
    return _then(_value.copyWith(
      customHeaders: null == customHeaders
          ? _value.customHeaders
          : customHeaders // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      databaseId: freezed == databaseId
          ? _value.databaseId
          : databaseId // ignore: cast_nullable_to_non_nullable
              as String?,
      host: freezed == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String?,
      servicePath: freezed == servicePath
          ? _value.servicePath
          : servicePath // ignore: cast_nullable_to_non_nullable
              as String?,
      apiEndpoint: freezed == apiEndpoint
          ? _value.apiEndpoint
          : apiEndpoint // ignore: cast_nullable_to_non_nullable
              as String?,
      port: freezed == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      keyFilename: freezed == keyFilename
          ? _value.keyFilename
          : keyFilename // ignore: cast_nullable_to_non_nullable
              as String?,
      credentials: freezed == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as SettingsCredentials?,
      ssl: freezed == ssl
          ? _value.ssl
          : ssl // ignore: cast_nullable_to_non_nullable
              as bool?,
      maxIdleChannels: freezed == maxIdleChannels
          ? _value.maxIdleChannels
          : maxIdleChannels // ignore: cast_nullable_to_non_nullable
              as int?,
      useBigInt: freezed == useBigInt
          ? _value.useBigInt
          : useBigInt // ignore: cast_nullable_to_non_nullable
              as bool?,
      ignoreUndefinedProperties: freezed == ignoreUndefinedProperties
          ? _value.ignoreUndefinedProperties
          : ignoreUndefinedProperties // ignore: cast_nullable_to_non_nullable
              as bool?,
      preferRest: freezed == preferRest
          ? _value.preferRest
          : preferRest // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SettingsCopyWith<$Res> implements $SettingsCopyWith<$Res> {
  factory _$$_SettingsCopyWith(
          _$_Settings value, $Res Function(_$_Settings) then) =
      __$$_SettingsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, String> customHeaders,
      String? databaseId,
      String? host,
      String? servicePath,
      String? apiEndpoint,
      int? port,
      String? keyFilename,
      SettingsCredentials? credentials,
      bool? ssl,
      int? maxIdleChannels,
      bool? useBigInt,
      bool? ignoreUndefinedProperties,
      bool? preferRest});
}

/// @nodoc
class __$$_SettingsCopyWithImpl<$Res>
    extends _$SettingsCopyWithImpl<$Res, _$_Settings>
    implements _$$_SettingsCopyWith<$Res> {
  __$$_SettingsCopyWithImpl(
      _$_Settings _value, $Res Function(_$_Settings) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customHeaders = null,
    Object? databaseId = freezed,
    Object? host = freezed,
    Object? servicePath = freezed,
    Object? apiEndpoint = freezed,
    Object? port = freezed,
    Object? keyFilename = freezed,
    Object? credentials = freezed,
    Object? ssl = freezed,
    Object? maxIdleChannels = freezed,
    Object? useBigInt = freezed,
    Object? ignoreUndefinedProperties = freezed,
    Object? preferRest = freezed,
  }) {
    return _then(_$_Settings(
      customHeaders: null == customHeaders
          ? _value._customHeaders
          : customHeaders // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      databaseId: freezed == databaseId
          ? _value.databaseId
          : databaseId // ignore: cast_nullable_to_non_nullable
              as String?,
      host: freezed == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String?,
      servicePath: freezed == servicePath
          ? _value.servicePath
          : servicePath // ignore: cast_nullable_to_non_nullable
              as String?,
      apiEndpoint: freezed == apiEndpoint
          ? _value.apiEndpoint
          : apiEndpoint // ignore: cast_nullable_to_non_nullable
              as String?,
      port: freezed == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      keyFilename: freezed == keyFilename
          ? _value.keyFilename
          : keyFilename // ignore: cast_nullable_to_non_nullable
              as String?,
      credentials: freezed == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as SettingsCredentials?,
      ssl: freezed == ssl
          ? _value.ssl
          : ssl // ignore: cast_nullable_to_non_nullable
              as bool?,
      maxIdleChannels: freezed == maxIdleChannels
          ? _value.maxIdleChannels
          : maxIdleChannels // ignore: cast_nullable_to_non_nullable
              as int?,
      useBigInt: freezed == useBigInt
          ? _value.useBigInt
          : useBigInt // ignore: cast_nullable_to_non_nullable
              as bool?,
      ignoreUndefinedProperties: freezed == ignoreUndefinedProperties
          ? _value.ignoreUndefinedProperties
          : ignoreUndefinedProperties // ignore: cast_nullable_to_non_nullable
              as bool?,
      preferRest: freezed == preferRest
          ? _value.preferRest
          : preferRest // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$_Settings extends _Settings {
  _$_Settings(
      {final Map<String, String> customHeaders = const <String, String>{},
      this.databaseId,
      this.host,
      this.servicePath,
      this.apiEndpoint,
      this.port,
      this.keyFilename,
      this.credentials,
      this.ssl,
      this.maxIdleChannels,
      this.useBigInt,
      this.ignoreUndefinedProperties,
      this.preferRest})
      : _customHeaders = customHeaders,
        super._();

  final Map<String, String> _customHeaders;
  @override
  @JsonKey()
  Map<String, String> get customHeaders {
    if (_customHeaders is EqualUnmodifiableMapView) return _customHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_customHeaders);
  }

  /// The database name. If omitted, the default database will be used.
  @override
  final String? databaseId;
// TODO do we care about those? Maybe they should be from FirebaseAdminApp?
  /// The hostname to connect to.
  @override
  final String? host;
// TODO: Appears to be a clone of host?
  @override
  final String? servicePath;
// TODO: Appears to be a clone of host?
  @override
  final String? apiEndpoint;

  /// The port to connect to.
  @override
  final int? port;

  /// Local file containing the Service Account credentials as downloaded from
  /// the Google Developers Console. Can  be omitted in environments that
  /// support {@link https://cloud.google.com/docs/authentication Application
  /// Default Credentials}. To configure Firestore with custom credentials, use
  /// the `credentials` property to provide the `client_email` and
  /// `private_key` of your service account.
  @override
  final String? keyFilename;

  /// The 'client_email' and 'private_key' properties of the service account
  /// to use with your Firestore project. Can be omitted in environments that
  /// support {@link https://cloud.google.com/docs/authentication Application
  /// Default Credentials}. If your credentials are stored in a JSON file, you
  /// can specify a `keyFilename` instead.
// TODO should this be taken from FirebaseAdmingApp?
  @override
  final SettingsCredentials? credentials;

  /// Whether to use SSL when connecting.
// TODO is this used in dart?
  @override
  final bool? ssl;

  /// The maximum number of idle GRPC channels to keep. A smaller number of idle
  /// channels reduces memory usage but increases request latency for clients
  /// with fluctuating request rates. If set to 0, shuts down all GRPC channels
  /// when the client becomes idle. Defaults to 1.
// TODO is this used in dart?
  @override
  final int? maxIdleChannels;

  /// Whether to use `BigInt` for integer types when deserializing Firestore
  /// Documents. Regardless of magnitude, all integer values are returned as
  /// `BigInt` to match the precision of the Firestore backend. Floating point
  /// numbers continue to use JavaScript's `number` type.
// TODO is this used in dart?
  @override
  final bool? useBigInt;

  /// Whether to skip nested properties that are set to `undefined` during
  /// object serialization. If set to `true`, these properties are skipped
  /// and not written to Firestore. If set `false` or omitted, the SDK throws
  /// an exception when it encounters properties of type `undefined`.
// TODO is this used in dart?
  @override
  final bool? ignoreUndefinedProperties;

  /// Whether to force the use of HTTP/1.1 REST transport until a method that requires gRPC
  /// is called. When a method requires gRPC, this Firestore client will load dependent gRPC
  /// libraries and then use gRPC transport for communication from that point forward.
  /// Currently the only operation that requires gRPC is creating a snapshot listener with
  /// the method `DocumentReference<T>.onSnapshot()`, `CollectionReference<T>.onSnapshot()`,
  /// or `Query<T>.onSnapshot()`.
// TODO is this used in dart?
  @override
  final bool? preferRest;

  @override
  String toString() {
    return 'Settings(customHeaders: $customHeaders, databaseId: $databaseId, host: $host, servicePath: $servicePath, apiEndpoint: $apiEndpoint, port: $port, keyFilename: $keyFilename, credentials: $credentials, ssl: $ssl, maxIdleChannels: $maxIdleChannels, useBigInt: $useBigInt, ignoreUndefinedProperties: $ignoreUndefinedProperties, preferRest: $preferRest)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Settings &&
            const DeepCollectionEquality()
                .equals(other._customHeaders, _customHeaders) &&
            (identical(other.databaseId, databaseId) ||
                other.databaseId == databaseId) &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.servicePath, servicePath) ||
                other.servicePath == servicePath) &&
            (identical(other.apiEndpoint, apiEndpoint) ||
                other.apiEndpoint == apiEndpoint) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.keyFilename, keyFilename) ||
                other.keyFilename == keyFilename) &&
            (identical(other.credentials, credentials) ||
                other.credentials == credentials) &&
            (identical(other.ssl, ssl) || other.ssl == ssl) &&
            (identical(other.maxIdleChannels, maxIdleChannels) ||
                other.maxIdleChannels == maxIdleChannels) &&
            (identical(other.useBigInt, useBigInt) ||
                other.useBigInt == useBigInt) &&
            (identical(other.ignoreUndefinedProperties,
                    ignoreUndefinedProperties) ||
                other.ignoreUndefinedProperties == ignoreUndefinedProperties) &&
            (identical(other.preferRest, preferRest) ||
                other.preferRest == preferRest));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_customHeaders),
      databaseId,
      host,
      servicePath,
      apiEndpoint,
      port,
      keyFilename,
      credentials,
      ssl,
      maxIdleChannels,
      useBigInt,
      ignoreUndefinedProperties,
      preferRest);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SettingsCopyWith<_$_Settings> get copyWith =>
      __$$_SettingsCopyWithImpl<_$_Settings>(this, _$identity);
}

abstract class _Settings extends Settings {
  factory _Settings(
      {final Map<String, String> customHeaders,
      final String? databaseId,
      final String? host,
      final String? servicePath,
      final String? apiEndpoint,
      final int? port,
      final String? keyFilename,
      final SettingsCredentials? credentials,
      final bool? ssl,
      final int? maxIdleChannels,
      final bool? useBigInt,
      final bool? ignoreUndefinedProperties,
      final bool? preferRest}) = _$_Settings;
  _Settings._() : super._();

  @override
  Map<String, String> get customHeaders;
  @override

  /// The database name. If omitted, the default database will be used.
  String? get databaseId;
  @override // TODO do we care about those? Maybe they should be from FirebaseAdminApp?
  /// The hostname to connect to.
  String? get host;
  @override // TODO: Appears to be a clone of host?
  String? get servicePath;
  @override // TODO: Appears to be a clone of host?
  String? get apiEndpoint;
  @override

  /// The port to connect to.
  int? get port;
  @override

  /// Local file containing the Service Account credentials as downloaded from
  /// the Google Developers Console. Can  be omitted in environments that
  /// support {@link https://cloud.google.com/docs/authentication Application
  /// Default Credentials}. To configure Firestore with custom credentials, use
  /// the `credentials` property to provide the `client_email` and
  /// `private_key` of your service account.
  String? get keyFilename;
  @override

  /// The 'client_email' and 'private_key' properties of the service account
  /// to use with your Firestore project. Can be omitted in environments that
  /// support {@link https://cloud.google.com/docs/authentication Application
  /// Default Credentials}. If your credentials are stored in a JSON file, you
  /// can specify a `keyFilename` instead.
// TODO should this be taken from FirebaseAdmingApp?
  SettingsCredentials? get credentials;
  @override

  /// Whether to use SSL when connecting.
// TODO is this used in dart?
  bool? get ssl;
  @override

  /// The maximum number of idle GRPC channels to keep. A smaller number of idle
  /// channels reduces memory usage but increases request latency for clients
  /// with fluctuating request rates. If set to 0, shuts down all GRPC channels
  /// when the client becomes idle. Defaults to 1.
// TODO is this used in dart?
  int? get maxIdleChannels;
  @override

  /// Whether to use `BigInt` for integer types when deserializing Firestore
  /// Documents. Regardless of magnitude, all integer values are returned as
  /// `BigInt` to match the precision of the Firestore backend. Floating point
  /// numbers continue to use JavaScript's `number` type.
// TODO is this used in dart?
  bool? get useBigInt;
  @override

  /// Whether to skip nested properties that are set to `undefined` during
  /// object serialization. If set to `true`, these properties are skipped
  /// and not written to Firestore. If set `false` or omitted, the SDK throws
  /// an exception when it encounters properties of type `undefined`.
// TODO is this used in dart?
  bool? get ignoreUndefinedProperties;
  @override

  /// Whether to force the use of HTTP/1.1 REST transport until a method that requires gRPC
  /// is called. When a method requires gRPC, this Firestore client will load dependent gRPC
  /// libraries and then use gRPC transport for communication from that point forward.
  /// Currently the only operation that requires gRPC is creating a snapshot listener with
  /// the method `DocumentReference<T>.onSnapshot()`, `CollectionReference<T>.onSnapshot()`,
  /// or `Query<T>.onSnapshot()`.
// TODO is this used in dart?
  bool? get preferRest;
  @override
  @JsonKey(ignore: true)
  _$$_SettingsCopyWith<_$_Settings> get copyWith =>
      throw _privateConstructorUsedError;
}
