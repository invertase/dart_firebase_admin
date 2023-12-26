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
  /// The database name. If omitted, the default database will be used.
  String? get databaseId => throw _privateConstructorUsedError;

  /// Whether to use `BigInt` for integer types when deserializing Firestore
  /// Documents. Regardless of magnitude, all integer values are returned as
  /// `BigInt` to match the precision of the Firestore backend. Floating point
  /// numbers continue to use JavaScript's `number` type.
  bool? get useBigInt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SettingsCopyWith<Settings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsCopyWith<$Res> {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) then) =
      _$SettingsCopyWithImpl<$Res, Settings>;
  @useResult
  $Res call({String? databaseId, bool? useBigInt});
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
    Object? databaseId = freezed,
    Object? useBigInt = freezed,
  }) {
    return _then(_value.copyWith(
      databaseId: freezed == databaseId
          ? _value.databaseId
          : databaseId // ignore: cast_nullable_to_non_nullable
              as String?,
      useBigInt: freezed == useBigInt
          ? _value.useBigInt
          : useBigInt // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingsImplCopyWith<$Res>
    implements $SettingsCopyWith<$Res> {
  factory _$$SettingsImplCopyWith(
          _$SettingsImpl value, $Res Function(_$SettingsImpl) then) =
      __$$SettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? databaseId, bool? useBigInt});
}

/// @nodoc
class __$$SettingsImplCopyWithImpl<$Res>
    extends _$SettingsCopyWithImpl<$Res, _$SettingsImpl>
    implements _$$SettingsImplCopyWith<$Res> {
  __$$SettingsImplCopyWithImpl(
      _$SettingsImpl _value, $Res Function(_$SettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? databaseId = freezed,
    Object? useBigInt = freezed,
  }) {
    return _then(_$SettingsImpl(
      databaseId: freezed == databaseId
          ? _value.databaseId
          : databaseId // ignore: cast_nullable_to_non_nullable
              as String?,
      useBigInt: freezed == useBigInt
          ? _value.useBigInt
          : useBigInt // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$SettingsImpl implements _Settings {
  _$SettingsImpl({this.databaseId, this.useBigInt});

  /// The database name. If omitted, the default database will be used.
  @override
  final String? databaseId;

  /// Whether to use `BigInt` for integer types when deserializing Firestore
  /// Documents. Regardless of magnitude, all integer values are returned as
  /// `BigInt` to match the precision of the Firestore backend. Floating point
  /// numbers continue to use JavaScript's `number` type.
  @override
  final bool? useBigInt;

  @override
  String toString() {
    return 'Settings(databaseId: $databaseId, useBigInt: $useBigInt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsImpl &&
            (identical(other.databaseId, databaseId) ||
                other.databaseId == databaseId) &&
            (identical(other.useBigInt, useBigInt) ||
                other.useBigInt == useBigInt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, databaseId, useBigInt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsImplCopyWith<_$SettingsImpl> get copyWith =>
      __$$SettingsImplCopyWithImpl<_$SettingsImpl>(this, _$identity);
}

abstract class _Settings implements Settings {
  factory _Settings({final String? databaseId, final bool? useBigInt}) =
      _$SettingsImpl;

  @override

  /// The database name. If omitted, the default database will be used.
  String? get databaseId;
  @override

  /// Whether to use `BigInt` for integer types when deserializing Firestore
  /// Documents. Regardless of magnitude, all integer values are returned as
  /// `BigInt` to match the precision of the Firestore backend. Floating point
  /// numbers continue to use JavaScript's `number` type.
  bool? get useBigInt;
  @override
  @JsonKey(ignore: true)
  _$$SettingsImplCopyWith<_$SettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$QueryOptions<T> {
  _ResourcePath get parentPath => throw _privateConstructorUsedError;
  String get collectionId => throw _privateConstructorUsedError;
  ({
    T Function(QueryDocumentSnapshot<Map<String, Object?>>) fromFirestore,
    Map<String, Object?> Function(T) toFirestore
  }) get converter => throw _privateConstructorUsedError;
  bool get allDescendants => throw _privateConstructorUsedError;
  List<_FilterInternal> get filters => throw _privateConstructorUsedError;
  List<_FieldOrder> get fieldOrders => throw _privateConstructorUsedError;
  _QueryCursor? get startAt => throw _privateConstructorUsedError;
  _QueryCursor? get endAt => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;
  firestore1.Projection? get projection => throw _privateConstructorUsedError;
  LimitType? get limitType => throw _privateConstructorUsedError;
  int? get offset =>
      throw _privateConstructorUsedError; // Whether to select all documents under `parentPath`. By default, only
// collections that match `collectionId` are selected.
  bool get kindless =>
      throw _privateConstructorUsedError; // Whether to require consistent documents when restarting the query. By
// default, restarting the query uses the readTime offset of the original
// query to provide consistent results.
  bool get requireConsistency => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  _$QueryOptionsCopyWith<T, _QueryOptions<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$QueryOptionsCopyWith<T, $Res> {
  factory _$QueryOptionsCopyWith(
          _QueryOptions<T> value, $Res Function(_QueryOptions<T>) then) =
      __$QueryOptionsCopyWithImpl<T, $Res, _QueryOptions<T>>;
  @useResult
  $Res call(
      {_ResourcePath parentPath,
      String collectionId,
      ({
        T Function(QueryDocumentSnapshot<Map<String, Object?>>) fromFirestore,
        Map<String, Object?> Function(T) toFirestore
      }) converter,
      bool allDescendants,
      List<_FilterInternal> filters,
      List<_FieldOrder> fieldOrders,
      _QueryCursor? startAt,
      _QueryCursor? endAt,
      int? limit,
      firestore1.Projection? projection,
      LimitType? limitType,
      int? offset,
      bool kindless,
      bool requireConsistency});
}

/// @nodoc
class __$QueryOptionsCopyWithImpl<T, $Res, $Val extends _QueryOptions<T>>
    implements _$QueryOptionsCopyWith<T, $Res> {
  __$QueryOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentPath = null,
    Object? collectionId = null,
    Object? converter = null,
    Object? allDescendants = null,
    Object? filters = null,
    Object? fieldOrders = null,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? limit = freezed,
    Object? projection = freezed,
    Object? limitType = freezed,
    Object? offset = freezed,
    Object? kindless = null,
    Object? requireConsistency = null,
  }) {
    return _then(_value.copyWith(
      parentPath: null == parentPath
          ? _value.parentPath
          : parentPath // ignore: cast_nullable_to_non_nullable
              as _ResourcePath,
      collectionId: null == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as String,
      converter: null == converter
          ? _value.converter
          : converter // ignore: cast_nullable_to_non_nullable
              as ({
              T Function(
                  QueryDocumentSnapshot<Map<String, Object?>>) fromFirestore,
              Map<String, Object?> Function(T) toFirestore
            }),
      allDescendants: null == allDescendants
          ? _value.allDescendants
          : allDescendants // ignore: cast_nullable_to_non_nullable
              as bool,
      filters: null == filters
          ? _value.filters
          : filters // ignore: cast_nullable_to_non_nullable
              as List<_FilterInternal>,
      fieldOrders: null == fieldOrders
          ? _value.fieldOrders
          : fieldOrders // ignore: cast_nullable_to_non_nullable
              as List<_FieldOrder>,
      startAt: freezed == startAt
          ? _value.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as _QueryCursor?,
      endAt: freezed == endAt
          ? _value.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as _QueryCursor?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      projection: freezed == projection
          ? _value.projection
          : projection // ignore: cast_nullable_to_non_nullable
              as firestore1.Projection?,
      limitType: freezed == limitType
          ? _value.limitType
          : limitType // ignore: cast_nullable_to_non_nullable
              as LimitType?,
      offset: freezed == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int?,
      kindless: null == kindless
          ? _value.kindless
          : kindless // ignore: cast_nullable_to_non_nullable
              as bool,
      requireConsistency: null == requireConsistency
          ? _value.requireConsistency
          : requireConsistency // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_QueryOptionsImplCopyWith<T, $Res>
    implements _$QueryOptionsCopyWith<T, $Res> {
  factory _$$_QueryOptionsImplCopyWith(_$_QueryOptionsImpl<T> value,
          $Res Function(_$_QueryOptionsImpl<T>) then) =
      __$$_QueryOptionsImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call(
      {_ResourcePath parentPath,
      String collectionId,
      ({
        T Function(QueryDocumentSnapshot<Map<String, Object?>>) fromFirestore,
        Map<String, Object?> Function(T) toFirestore
      }) converter,
      bool allDescendants,
      List<_FilterInternal> filters,
      List<_FieldOrder> fieldOrders,
      _QueryCursor? startAt,
      _QueryCursor? endAt,
      int? limit,
      firestore1.Projection? projection,
      LimitType? limitType,
      int? offset,
      bool kindless,
      bool requireConsistency});
}

/// @nodoc
class __$$_QueryOptionsImplCopyWithImpl<T, $Res>
    extends __$QueryOptionsCopyWithImpl<T, $Res, _$_QueryOptionsImpl<T>>
    implements _$$_QueryOptionsImplCopyWith<T, $Res> {
  __$$_QueryOptionsImplCopyWithImpl(_$_QueryOptionsImpl<T> _value,
      $Res Function(_$_QueryOptionsImpl<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentPath = null,
    Object? collectionId = null,
    Object? converter = null,
    Object? allDescendants = null,
    Object? filters = null,
    Object? fieldOrders = null,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? limit = freezed,
    Object? projection = freezed,
    Object? limitType = freezed,
    Object? offset = freezed,
    Object? kindless = null,
    Object? requireConsistency = null,
  }) {
    return _then(_$_QueryOptionsImpl<T>(
      parentPath: null == parentPath
          ? _value.parentPath
          : parentPath // ignore: cast_nullable_to_non_nullable
              as _ResourcePath,
      collectionId: null == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as String,
      converter: null == converter
          ? _value.converter
          : converter // ignore: cast_nullable_to_non_nullable
              as ({
              T Function(
                  QueryDocumentSnapshot<Map<String, Object?>>) fromFirestore,
              Map<String, Object?> Function(T) toFirestore
            }),
      allDescendants: null == allDescendants
          ? _value.allDescendants
          : allDescendants // ignore: cast_nullable_to_non_nullable
              as bool,
      filters: null == filters
          ? _value._filters
          : filters // ignore: cast_nullable_to_non_nullable
              as List<_FilterInternal>,
      fieldOrders: null == fieldOrders
          ? _value._fieldOrders
          : fieldOrders // ignore: cast_nullable_to_non_nullable
              as List<_FieldOrder>,
      startAt: freezed == startAt
          ? _value.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as _QueryCursor?,
      endAt: freezed == endAt
          ? _value.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as _QueryCursor?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      projection: freezed == projection
          ? _value.projection
          : projection // ignore: cast_nullable_to_non_nullable
              as firestore1.Projection?,
      limitType: freezed == limitType
          ? _value.limitType
          : limitType // ignore: cast_nullable_to_non_nullable
              as LimitType?,
      offset: freezed == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int?,
      kindless: null == kindless
          ? _value.kindless
          : kindless // ignore: cast_nullable_to_non_nullable
              as bool,
      requireConsistency: null == requireConsistency
          ? _value.requireConsistency
          : requireConsistency // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_QueryOptionsImpl<T> extends __QueryOptions<T> {
  _$_QueryOptionsImpl(
      {required this.parentPath,
      required this.collectionId,
      required this.converter,
      required this.allDescendants,
      required final List<_FilterInternal> filters,
      required final List<_FieldOrder> fieldOrders,
      this.startAt,
      this.endAt,
      this.limit,
      this.projection,
      this.limitType,
      this.offset,
      this.kindless = false,
      this.requireConsistency = true})
      : _filters = filters,
        _fieldOrders = fieldOrders,
        super._();

  @override
  final _ResourcePath parentPath;
  @override
  final String collectionId;
  @override
  final ({
    T Function(QueryDocumentSnapshot<Map<String, Object?>>) fromFirestore,
    Map<String, Object?> Function(T) toFirestore
  }) converter;
  @override
  final bool allDescendants;
  final List<_FilterInternal> _filters;
  @override
  List<_FilterInternal> get filters {
    if (_filters is EqualUnmodifiableListView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filters);
  }

  final List<_FieldOrder> _fieldOrders;
  @override
  List<_FieldOrder> get fieldOrders {
    if (_fieldOrders is EqualUnmodifiableListView) return _fieldOrders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fieldOrders);
  }

  @override
  final _QueryCursor? startAt;
  @override
  final _QueryCursor? endAt;
  @override
  final int? limit;
  @override
  final firestore1.Projection? projection;
  @override
  final LimitType? limitType;
  @override
  final int? offset;
// Whether to select all documents under `parentPath`. By default, only
// collections that match `collectionId` are selected.
  @override
  @JsonKey()
  final bool kindless;
// Whether to require consistent documents when restarting the query. By
// default, restarting the query uses the readTime offset of the original
// query to provide consistent results.
  @override
  @JsonKey()
  final bool requireConsistency;

  @override
  String toString() {
    return '_QueryOptions<$T>(parentPath: $parentPath, collectionId: $collectionId, converter: $converter, allDescendants: $allDescendants, filters: $filters, fieldOrders: $fieldOrders, startAt: $startAt, endAt: $endAt, limit: $limit, projection: $projection, limitType: $limitType, offset: $offset, kindless: $kindless, requireConsistency: $requireConsistency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_QueryOptionsImpl<T> &&
            (identical(other.parentPath, parentPath) ||
                other.parentPath == parentPath) &&
            (identical(other.collectionId, collectionId) ||
                other.collectionId == collectionId) &&
            (identical(other.converter, converter) ||
                other.converter == converter) &&
            (identical(other.allDescendants, allDescendants) ||
                other.allDescendants == allDescendants) &&
            const DeepCollectionEquality().equals(other._filters, _filters) &&
            const DeepCollectionEquality()
                .equals(other._fieldOrders, _fieldOrders) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.projection, projection) ||
                other.projection == projection) &&
            (identical(other.limitType, limitType) ||
                other.limitType == limitType) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.kindless, kindless) ||
                other.kindless == kindless) &&
            (identical(other.requireConsistency, requireConsistency) ||
                other.requireConsistency == requireConsistency));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      parentPath,
      collectionId,
      converter,
      allDescendants,
      const DeepCollectionEquality().hash(_filters),
      const DeepCollectionEquality().hash(_fieldOrders),
      startAt,
      endAt,
      limit,
      projection,
      limitType,
      offset,
      kindless,
      requireConsistency);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_QueryOptionsImplCopyWith<T, _$_QueryOptionsImpl<T>> get copyWith =>
      __$$_QueryOptionsImplCopyWithImpl<T, _$_QueryOptionsImpl<T>>(
          this, _$identity);
}

abstract class __QueryOptions<T> extends _QueryOptions<T> {
  factory __QueryOptions(
      {required final _ResourcePath parentPath,
      required final String collectionId,
      required final ({
        T Function(QueryDocumentSnapshot<Map<String, Object?>>) fromFirestore,
        Map<String, Object?> Function(T) toFirestore
      }) converter,
      required final bool allDescendants,
      required final List<_FilterInternal> filters,
      required final List<_FieldOrder> fieldOrders,
      final _QueryCursor? startAt,
      final _QueryCursor? endAt,
      final int? limit,
      final firestore1.Projection? projection,
      final LimitType? limitType,
      final int? offset,
      final bool kindless,
      final bool requireConsistency}) = _$_QueryOptionsImpl<T>;
  __QueryOptions._() : super._();

  @override
  _ResourcePath get parentPath;
  @override
  String get collectionId;
  @override
  ({
    T Function(QueryDocumentSnapshot<Map<String, Object?>>) fromFirestore,
    Map<String, Object?> Function(T) toFirestore
  }) get converter;
  @override
  bool get allDescendants;
  @override
  List<_FilterInternal> get filters;
  @override
  List<_FieldOrder> get fieldOrders;
  @override
  _QueryCursor? get startAt;
  @override
  _QueryCursor? get endAt;
  @override
  int? get limit;
  @override
  firestore1.Projection? get projection;
  @override
  LimitType? get limitType;
  @override
  int? get offset;
  @override // Whether to select all documents under `parentPath`. By default, only
// collections that match `collectionId` are selected.
  bool get kindless;
  @override // Whether to require consistent documents when restarting the query. By
// default, restarting the query uses the readTime offset of the original
// query to provide consistent results.
  bool get requireConsistency;
  @override
  @JsonKey(ignore: true)
  _$$_QueryOptionsImplCopyWith<T, _$_QueryOptionsImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
