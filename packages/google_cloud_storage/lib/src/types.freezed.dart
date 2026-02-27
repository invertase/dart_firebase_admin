// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GetServiceAccountOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;/// The project identifier. If not provided, uses the default project.
 String? get projectId;
/// Create a copy of GetServiceAccountOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetServiceAccountOptionsCopyWith<GetServiceAccountOptions> get copyWith => _$GetServiceAccountOptionsCopyWithImpl<GetServiceAccountOptions>(this as GetServiceAccountOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetServiceAccountOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.projectId, projectId) || other.projectId == projectId));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,projectId);

@override
String toString() {
  return 'GetServiceAccountOptions(userProject: $userProject, projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class $GetServiceAccountOptionsCopyWith<$Res>  {
  factory $GetServiceAccountOptionsCopyWith(GetServiceAccountOptions value, $Res Function(GetServiceAccountOptions) _then) = _$GetServiceAccountOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject, String? projectId
});




}
/// @nodoc
class _$GetServiceAccountOptionsCopyWithImpl<$Res>
    implements $GetServiceAccountOptionsCopyWith<$Res> {
  _$GetServiceAccountOptionsCopyWithImpl(this._self, this._then);

  final GetServiceAccountOptions _self;
  final $Res Function(GetServiceAccountOptions) _then;

/// Create a copy of GetServiceAccountOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,Object? projectId = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _GetServiceAccountOptions implements GetServiceAccountOptions {
  const _GetServiceAccountOptions({this.userProject, this.projectId});
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// The project identifier. If not provided, uses the default project.
@override final  String? projectId;

/// Create a copy of GetServiceAccountOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetServiceAccountOptionsCopyWith<_GetServiceAccountOptions> get copyWith => __$GetServiceAccountOptionsCopyWithImpl<_GetServiceAccountOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetServiceAccountOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.projectId, projectId) || other.projectId == projectId));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,projectId);

@override
String toString() {
  return 'GetServiceAccountOptions(userProject: $userProject, projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class _$GetServiceAccountOptionsCopyWith<$Res> implements $GetServiceAccountOptionsCopyWith<$Res> {
  factory _$GetServiceAccountOptionsCopyWith(_GetServiceAccountOptions value, $Res Function(_GetServiceAccountOptions) _then) = __$GetServiceAccountOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject, String? projectId
});




}
/// @nodoc
class __$GetServiceAccountOptionsCopyWithImpl<$Res>
    implements _$GetServiceAccountOptionsCopyWith<$Res> {
  __$GetServiceAccountOptionsCopyWithImpl(this._self, this._then);

  final _GetServiceAccountOptions _self;
  final $Res Function(_GetServiceAccountOptions) _then;

/// Create a copy of GetServiceAccountOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,Object? projectId = freezed,}) {
  return _then(_GetServiceAccountOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$RetryOptions {

/// Whether to automatically retry failed requests. Defaults to `true`.
 bool get autoRetry;/// Maximum number of retry attempts. Defaults to `3`.
 int get maxRetries;/// Maximum total time to spend on retries. Defaults to `600 seconds`.
 Duration get totalTimeout;/// Maximum delay between retry attempts. Defaults to `64 seconds`.
 Duration get maxRetryDelay;/// Multiplier for exponential backoff. Defaults to `2.0`.
 double get retryDelayMultiplier;/// Custom function to determine if an error is retryable.
///
/// If provided, this function is called for each error to determine
/// whether it should be retried. If not provided, default retry logic is used.
 RetryableErrorFn? get retryableErrorFn;/// Strategy for determining retry behavior based on idempotency.
///
/// Defaults to [IdempotencyStrategy.retryConditional].
 IdempotencyStrategy get idempotencyStrategy;
/// Create a copy of RetryOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RetryOptionsCopyWith<RetryOptions> get copyWith => _$RetryOptionsCopyWithImpl<RetryOptions>(this as RetryOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RetryOptions&&(identical(other.autoRetry, autoRetry) || other.autoRetry == autoRetry)&&(identical(other.maxRetries, maxRetries) || other.maxRetries == maxRetries)&&(identical(other.totalTimeout, totalTimeout) || other.totalTimeout == totalTimeout)&&(identical(other.maxRetryDelay, maxRetryDelay) || other.maxRetryDelay == maxRetryDelay)&&(identical(other.retryDelayMultiplier, retryDelayMultiplier) || other.retryDelayMultiplier == retryDelayMultiplier)&&(identical(other.retryableErrorFn, retryableErrorFn) || other.retryableErrorFn == retryableErrorFn)&&(identical(other.idempotencyStrategy, idempotencyStrategy) || other.idempotencyStrategy == idempotencyStrategy));
}


@override
int get hashCode => Object.hash(runtimeType,autoRetry,maxRetries,totalTimeout,maxRetryDelay,retryDelayMultiplier,retryableErrorFn,idempotencyStrategy);

@override
String toString() {
  return 'RetryOptions(autoRetry: $autoRetry, maxRetries: $maxRetries, totalTimeout: $totalTimeout, maxRetryDelay: $maxRetryDelay, retryDelayMultiplier: $retryDelayMultiplier, retryableErrorFn: $retryableErrorFn, idempotencyStrategy: $idempotencyStrategy)';
}


}

/// @nodoc
abstract mixin class $RetryOptionsCopyWith<$Res>  {
  factory $RetryOptionsCopyWith(RetryOptions value, $Res Function(RetryOptions) _then) = _$RetryOptionsCopyWithImpl;
@useResult
$Res call({
 bool autoRetry, int maxRetries, Duration totalTimeout, Duration maxRetryDelay, double retryDelayMultiplier, RetryableErrorFn? retryableErrorFn, IdempotencyStrategy idempotencyStrategy
});




}
/// @nodoc
class _$RetryOptionsCopyWithImpl<$Res>
    implements $RetryOptionsCopyWith<$Res> {
  _$RetryOptionsCopyWithImpl(this._self, this._then);

  final RetryOptions _self;
  final $Res Function(RetryOptions) _then;

/// Create a copy of RetryOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? autoRetry = null,Object? maxRetries = null,Object? totalTimeout = null,Object? maxRetryDelay = null,Object? retryDelayMultiplier = null,Object? retryableErrorFn = freezed,Object? idempotencyStrategy = null,}) {
  return _then(_self.copyWith(
autoRetry: null == autoRetry ? _self.autoRetry : autoRetry // ignore: cast_nullable_to_non_nullable
as bool,maxRetries: null == maxRetries ? _self.maxRetries : maxRetries // ignore: cast_nullable_to_non_nullable
as int,totalTimeout: null == totalTimeout ? _self.totalTimeout : totalTimeout // ignore: cast_nullable_to_non_nullable
as Duration,maxRetryDelay: null == maxRetryDelay ? _self.maxRetryDelay : maxRetryDelay // ignore: cast_nullable_to_non_nullable
as Duration,retryDelayMultiplier: null == retryDelayMultiplier ? _self.retryDelayMultiplier : retryDelayMultiplier // ignore: cast_nullable_to_non_nullable
as double,retryableErrorFn: freezed == retryableErrorFn ? _self.retryableErrorFn : retryableErrorFn // ignore: cast_nullable_to_non_nullable
as RetryableErrorFn?,idempotencyStrategy: null == idempotencyStrategy ? _self.idempotencyStrategy : idempotencyStrategy // ignore: cast_nullable_to_non_nullable
as IdempotencyStrategy,
  ));
}

}



/// @nodoc


class _RetryOptions implements RetryOptions {
  const _RetryOptions({this.autoRetry = true, this.maxRetries = 3, this.totalTimeout = const Duration(seconds: 600), this.maxRetryDelay = const Duration(seconds: 64), this.retryDelayMultiplier = 2.0, this.retryableErrorFn, this.idempotencyStrategy = IdempotencyStrategy.retryConditional});
  

/// Whether to automatically retry failed requests. Defaults to `true`.
@override@JsonKey() final  bool autoRetry;
/// Maximum number of retry attempts. Defaults to `3`.
@override@JsonKey() final  int maxRetries;
/// Maximum total time to spend on retries. Defaults to `600 seconds`.
@override@JsonKey() final  Duration totalTimeout;
/// Maximum delay between retry attempts. Defaults to `64 seconds`.
@override@JsonKey() final  Duration maxRetryDelay;
/// Multiplier for exponential backoff. Defaults to `2.0`.
@override@JsonKey() final  double retryDelayMultiplier;
/// Custom function to determine if an error is retryable.
///
/// If provided, this function is called for each error to determine
/// whether it should be retried. If not provided, default retry logic is used.
@override final  RetryableErrorFn? retryableErrorFn;
/// Strategy for determining retry behavior based on idempotency.
///
/// Defaults to [IdempotencyStrategy.retryConditional].
@override@JsonKey() final  IdempotencyStrategy idempotencyStrategy;

/// Create a copy of RetryOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RetryOptionsCopyWith<_RetryOptions> get copyWith => __$RetryOptionsCopyWithImpl<_RetryOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RetryOptions&&(identical(other.autoRetry, autoRetry) || other.autoRetry == autoRetry)&&(identical(other.maxRetries, maxRetries) || other.maxRetries == maxRetries)&&(identical(other.totalTimeout, totalTimeout) || other.totalTimeout == totalTimeout)&&(identical(other.maxRetryDelay, maxRetryDelay) || other.maxRetryDelay == maxRetryDelay)&&(identical(other.retryDelayMultiplier, retryDelayMultiplier) || other.retryDelayMultiplier == retryDelayMultiplier)&&(identical(other.retryableErrorFn, retryableErrorFn) || other.retryableErrorFn == retryableErrorFn)&&(identical(other.idempotencyStrategy, idempotencyStrategy) || other.idempotencyStrategy == idempotencyStrategy));
}


@override
int get hashCode => Object.hash(runtimeType,autoRetry,maxRetries,totalTimeout,maxRetryDelay,retryDelayMultiplier,retryableErrorFn,idempotencyStrategy);

@override
String toString() {
  return 'RetryOptions(autoRetry: $autoRetry, maxRetries: $maxRetries, totalTimeout: $totalTimeout, maxRetryDelay: $maxRetryDelay, retryDelayMultiplier: $retryDelayMultiplier, retryableErrorFn: $retryableErrorFn, idempotencyStrategy: $idempotencyStrategy)';
}


}

/// @nodoc
abstract mixin class _$RetryOptionsCopyWith<$Res> implements $RetryOptionsCopyWith<$Res> {
  factory _$RetryOptionsCopyWith(_RetryOptions value, $Res Function(_RetryOptions) _then) = __$RetryOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool autoRetry, int maxRetries, Duration totalTimeout, Duration maxRetryDelay, double retryDelayMultiplier, RetryableErrorFn? retryableErrorFn, IdempotencyStrategy idempotencyStrategy
});




}
/// @nodoc
class __$RetryOptionsCopyWithImpl<$Res>
    implements _$RetryOptionsCopyWith<$Res> {
  __$RetryOptionsCopyWithImpl(this._self, this._then);

  final _RetryOptions _self;
  final $Res Function(_RetryOptions) _then;

/// Create a copy of RetryOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoRetry = null,Object? maxRetries = null,Object? totalTimeout = null,Object? maxRetryDelay = null,Object? retryDelayMultiplier = null,Object? retryableErrorFn = freezed,Object? idempotencyStrategy = null,}) {
  return _then(_RetryOptions(
autoRetry: null == autoRetry ? _self.autoRetry : autoRetry // ignore: cast_nullable_to_non_nullable
as bool,maxRetries: null == maxRetries ? _self.maxRetries : maxRetries // ignore: cast_nullable_to_non_nullable
as int,totalTimeout: null == totalTimeout ? _self.totalTimeout : totalTimeout // ignore: cast_nullable_to_non_nullable
as Duration,maxRetryDelay: null == maxRetryDelay ? _self.maxRetryDelay : maxRetryDelay // ignore: cast_nullable_to_non_nullable
as Duration,retryDelayMultiplier: null == retryDelayMultiplier ? _self.retryDelayMultiplier : retryDelayMultiplier // ignore: cast_nullable_to_non_nullable
as double,retryableErrorFn: freezed == retryableErrorFn ? _self.retryableErrorFn : retryableErrorFn // ignore: cast_nullable_to_non_nullable
as RetryableErrorFn?,idempotencyStrategy: null == idempotencyStrategy ? _self.idempotencyStrategy : idempotencyStrategy // ignore: cast_nullable_to_non_nullable
as IdempotencyStrategy,
  ));
}


}

/// @nodoc
mixin _$DeleteOptions {

/// If `true`, ignore 404 errors (treat as success if object doesn't exist).
///
/// Defaults to `false`.
 bool get ignoreNotFound;/// The ID of the project which will be billed for the request.
 String? get userProject;/// Only perform the operation if the object's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the object's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the object's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the object's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of DeleteOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteOptionsCopyWith<DeleteOptions> get copyWith => _$DeleteOptionsCopyWithImpl<DeleteOptions>(this as DeleteOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteOptions&&(identical(other.ignoreNotFound, ignoreNotFound) || other.ignoreNotFound == ignoreNotFound)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,ignoreNotFound,userProject,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'DeleteOptions(ignoreNotFound: $ignoreNotFound, userProject: $userProject, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $DeleteOptionsCopyWith<$Res>  {
  factory $DeleteOptionsCopyWith(DeleteOptions value, $Res Function(DeleteOptions) _then) = _$DeleteOptionsCopyWithImpl;
@useResult
$Res call({
 bool ignoreNotFound, String? userProject, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$DeleteOptionsCopyWithImpl<$Res>
    implements $DeleteOptionsCopyWith<$Res> {
  _$DeleteOptionsCopyWithImpl(this._self, this._then);

  final DeleteOptions _self;
  final $Res Function(DeleteOptions) _then;

/// Create a copy of DeleteOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ignoreNotFound = null,Object? userProject = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
ignoreNotFound: null == ignoreNotFound ? _self.ignoreNotFound : ignoreNotFound // ignore: cast_nullable_to_non_nullable
as bool,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _DeleteOptions extends DeleteOptions {
  const _DeleteOptions({this.ignoreNotFound = false, this.userProject, final  int? ifGenerationMatch, final  int? ifGenerationNotMatch, final  int? ifMetagenerationMatch, final  int? ifMetagenerationNotMatch}): super._(ifGenerationMatch: ifGenerationMatch, ifGenerationNotMatch: ifGenerationNotMatch, ifMetagenerationMatch: ifMetagenerationMatch, ifMetagenerationNotMatch: ifMetagenerationNotMatch);
  

/// If `true`, ignore 404 errors (treat as success if object doesn't exist).
///
/// Defaults to `false`.
@override@JsonKey() final  bool ignoreNotFound;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of DeleteOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteOptionsCopyWith<_DeleteOptions> get copyWith => __$DeleteOptionsCopyWithImpl<_DeleteOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteOptions&&(identical(other.ignoreNotFound, ignoreNotFound) || other.ignoreNotFound == ignoreNotFound)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,ignoreNotFound,userProject,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'DeleteOptions(ignoreNotFound: $ignoreNotFound, userProject: $userProject, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$DeleteOptionsCopyWith<$Res> implements $DeleteOptionsCopyWith<$Res> {
  factory _$DeleteOptionsCopyWith(_DeleteOptions value, $Res Function(_DeleteOptions) _then) = __$DeleteOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool ignoreNotFound, String? userProject, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$DeleteOptionsCopyWithImpl<$Res>
    implements _$DeleteOptionsCopyWith<$Res> {
  __$DeleteOptionsCopyWithImpl(this._self, this._then);

  final _DeleteOptions _self;
  final $Res Function(_DeleteOptions) _then;

/// Create a copy of DeleteOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ignoreNotFound = null,Object? userProject = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_DeleteOptions(
ignoreNotFound: null == ignoreNotFound ? _self.ignoreNotFound : ignoreNotFound // ignore: cast_nullable_to_non_nullable
as bool,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$RestoreOptions {

/// The generation of the bucket to restore.
 int get generation;/// The set of properties to return in the response.
 Projection? get projection;/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of RestoreOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestoreOptionsCopyWith<RestoreOptions> get copyWith => _$RestoreOptionsCopyWithImpl<RestoreOptions>(this as RestoreOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestoreOptions&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,generation,projection,userProject);

@override
String toString() {
  return 'RestoreOptions(generation: $generation, projection: $projection, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $RestoreOptionsCopyWith<$Res>  {
  factory $RestoreOptionsCopyWith(RestoreOptions value, $Res Function(RestoreOptions) _then) = _$RestoreOptionsCopyWithImpl;
@useResult
$Res call({
 int generation, Projection? projection, String? userProject
});




}
/// @nodoc
class _$RestoreOptionsCopyWithImpl<$Res>
    implements $RestoreOptionsCopyWith<$Res> {
  _$RestoreOptionsCopyWithImpl(this._self, this._then);

  final RestoreOptions _self;
  final $Res Function(RestoreOptions) _then;

/// Create a copy of RestoreOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? generation = null,Object? projection = freezed,Object? userProject = freezed,}) {
  return _then(_self.copyWith(
generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,projection: freezed == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as Projection?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _RestoreOptions implements RestoreOptions {
  const _RestoreOptions({required this.generation, this.projection, this.userProject});
  

/// The generation of the bucket to restore.
@override final  int generation;
/// The set of properties to return in the response.
@override final  Projection? projection;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of RestoreOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestoreOptionsCopyWith<_RestoreOptions> get copyWith => __$RestoreOptionsCopyWithImpl<_RestoreOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestoreOptions&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,generation,projection,userProject);

@override
String toString() {
  return 'RestoreOptions(generation: $generation, projection: $projection, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$RestoreOptionsCopyWith<$Res> implements $RestoreOptionsCopyWith<$Res> {
  factory _$RestoreOptionsCopyWith(_RestoreOptions value, $Res Function(_RestoreOptions) _then) = __$RestoreOptionsCopyWithImpl;
@override @useResult
$Res call({
 int generation, Projection? projection, String? userProject
});




}
/// @nodoc
class __$RestoreOptionsCopyWithImpl<$Res>
    implements _$RestoreOptionsCopyWith<$Res> {
  __$RestoreOptionsCopyWithImpl(this._self, this._then);

  final _RestoreOptions _self;
  final $Res Function(_RestoreOptions) _then;

/// Create a copy of RestoreOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? generation = null,Object? projection = freezed,Object? userProject = freezed,}) {
  return _then(_RestoreOptions(
generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,projection: freezed == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as Projection?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SetStorageClassOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;/// Apply a predefined set of access controls to the bucket.
 PredefinedAcl? get predefinedAcl;/// Only perform the operation if the bucket's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the bucket's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the bucket's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the bucket's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of SetStorageClassOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetStorageClassOptionsCopyWith<SetStorageClassOptions> get copyWith => _$SetStorageClassOptionsCopyWithImpl<SetStorageClassOptions>(this as SetStorageClassOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetStorageClassOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,predefinedAcl,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'SetStorageClassOptions(userProject: $userProject, predefinedAcl: $predefinedAcl, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $SetStorageClassOptionsCopyWith<$Res> implements $SetBucketMetadataOptionsCopyWith<$Res> {
  factory $SetStorageClassOptionsCopyWith(SetStorageClassOptions value, $Res Function(SetStorageClassOptions) _then) = _$SetStorageClassOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject, PredefinedAcl? predefinedAcl, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$SetStorageClassOptionsCopyWithImpl<$Res>
    implements $SetStorageClassOptionsCopyWith<$Res> {
  _$SetStorageClassOptionsCopyWithImpl(this._self, this._then);

  final SetStorageClassOptions _self;
  final $Res Function(SetStorageClassOptions) _then;

/// Create a copy of SetStorageClassOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,Object? predefinedAcl = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _SetStorageClassOptions extends SetStorageClassOptions {
  const _SetStorageClassOptions({this.userProject, this.predefinedAcl, final  int? ifGenerationMatch, final  int? ifGenerationNotMatch, final  int? ifMetagenerationMatch, final  int? ifMetagenerationNotMatch}): super._(ifGenerationMatch: ifGenerationMatch, ifGenerationNotMatch: ifGenerationNotMatch, ifMetagenerationMatch: ifMetagenerationMatch, ifMetagenerationNotMatch: ifMetagenerationNotMatch);
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Apply a predefined set of access controls to the bucket.
@override final  PredefinedAcl? predefinedAcl;

/// Create a copy of SetStorageClassOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetStorageClassOptionsCopyWith<_SetStorageClassOptions> get copyWith => __$SetStorageClassOptionsCopyWithImpl<_SetStorageClassOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetStorageClassOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,predefinedAcl,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'SetStorageClassOptions(userProject: $userProject, predefinedAcl: $predefinedAcl, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$SetStorageClassOptionsCopyWith<$Res> implements $SetStorageClassOptionsCopyWith<$Res> {
  factory _$SetStorageClassOptionsCopyWith(_SetStorageClassOptions value, $Res Function(_SetStorageClassOptions) _then) = __$SetStorageClassOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject, PredefinedAcl? predefinedAcl, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$SetStorageClassOptionsCopyWithImpl<$Res>
    implements _$SetStorageClassOptionsCopyWith<$Res> {
  __$SetStorageClassOptionsCopyWithImpl(this._self, this._then);

  final _SetStorageClassOptions _self;
  final $Res Function(_SetStorageClassOptions) _then;

/// Create a copy of SetStorageClassOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,Object? predefinedAcl = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_SetStorageClassOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$SetLabelsOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;/// Apply a predefined set of access controls to the bucket.
 PredefinedAcl? get predefinedAcl;/// Only perform the operation if the bucket's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the bucket's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the bucket's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the bucket's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of SetLabelsOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetLabelsOptionsCopyWith<SetLabelsOptions> get copyWith => _$SetLabelsOptionsCopyWithImpl<SetLabelsOptions>(this as SetLabelsOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetLabelsOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,predefinedAcl,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'SetLabelsOptions(userProject: $userProject, predefinedAcl: $predefinedAcl, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $SetLabelsOptionsCopyWith<$Res> implements $SetBucketMetadataOptionsCopyWith<$Res> {
  factory $SetLabelsOptionsCopyWith(SetLabelsOptions value, $Res Function(SetLabelsOptions) _then) = _$SetLabelsOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject, PredefinedAcl? predefinedAcl, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$SetLabelsOptionsCopyWithImpl<$Res>
    implements $SetLabelsOptionsCopyWith<$Res> {
  _$SetLabelsOptionsCopyWithImpl(this._self, this._then);

  final SetLabelsOptions _self;
  final $Res Function(SetLabelsOptions) _then;

/// Create a copy of SetLabelsOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,Object? predefinedAcl = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _SetLabelsOptions extends SetLabelsOptions {
  const _SetLabelsOptions({this.userProject, this.predefinedAcl, final  int? ifGenerationMatch, final  int? ifGenerationNotMatch, final  int? ifMetagenerationMatch, final  int? ifMetagenerationNotMatch}): super._(ifGenerationMatch: ifGenerationMatch, ifGenerationNotMatch: ifGenerationNotMatch, ifMetagenerationMatch: ifMetagenerationMatch, ifMetagenerationNotMatch: ifMetagenerationNotMatch);
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Apply a predefined set of access controls to the bucket.
@override final  PredefinedAcl? predefinedAcl;

/// Create a copy of SetLabelsOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetLabelsOptionsCopyWith<_SetLabelsOptions> get copyWith => __$SetLabelsOptionsCopyWithImpl<_SetLabelsOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetLabelsOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,predefinedAcl,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'SetLabelsOptions(userProject: $userProject, predefinedAcl: $predefinedAcl, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$SetLabelsOptionsCopyWith<$Res> implements $SetLabelsOptionsCopyWith<$Res> {
  factory _$SetLabelsOptionsCopyWith(_SetLabelsOptions value, $Res Function(_SetLabelsOptions) _then) = __$SetLabelsOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject, PredefinedAcl? predefinedAcl, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$SetLabelsOptionsCopyWithImpl<$Res>
    implements _$SetLabelsOptionsCopyWith<$Res> {
  __$SetLabelsOptionsCopyWithImpl(this._self, this._then);

  final _SetLabelsOptions _self;
  final $Res Function(_SetLabelsOptions) _then;

/// Create a copy of SetLabelsOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,Object? predefinedAcl = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_SetLabelsOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$MakeBucketPublicOptions {

/// If `true`, also make all files in the bucket public.
 bool? get includeFiles;/// If `true`, proceed even if the bucket already has public access.
 bool? get force;
/// Create a copy of MakeBucketPublicOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MakeBucketPublicOptionsCopyWith<MakeBucketPublicOptions> get copyWith => _$MakeBucketPublicOptionsCopyWithImpl<MakeBucketPublicOptions>(this as MakeBucketPublicOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MakeBucketPublicOptions&&(identical(other.includeFiles, includeFiles) || other.includeFiles == includeFiles)&&(identical(other.force, force) || other.force == force));
}


@override
int get hashCode => Object.hash(runtimeType,includeFiles,force);

@override
String toString() {
  return 'MakeBucketPublicOptions(includeFiles: $includeFiles, force: $force)';
}


}

/// @nodoc
abstract mixin class $MakeBucketPublicOptionsCopyWith<$Res>  {
  factory $MakeBucketPublicOptionsCopyWith(MakeBucketPublicOptions value, $Res Function(MakeBucketPublicOptions) _then) = _$MakeBucketPublicOptionsCopyWithImpl;
@useResult
$Res call({
 bool? includeFiles, bool? force
});




}
/// @nodoc
class _$MakeBucketPublicOptionsCopyWithImpl<$Res>
    implements $MakeBucketPublicOptionsCopyWith<$Res> {
  _$MakeBucketPublicOptionsCopyWithImpl(this._self, this._then);

  final MakeBucketPublicOptions _self;
  final $Res Function(MakeBucketPublicOptions) _then;

/// Create a copy of MakeBucketPublicOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? includeFiles = freezed,Object? force = freezed,}) {
  return _then(_self.copyWith(
includeFiles: freezed == includeFiles ? _self.includeFiles : includeFiles // ignore: cast_nullable_to_non_nullable
as bool?,force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}



/// @nodoc


class _MakeBucketPublicOptions implements MakeBucketPublicOptions {
  const _MakeBucketPublicOptions({this.includeFiles, this.force});
  

/// If `true`, also make all files in the bucket public.
@override final  bool? includeFiles;
/// If `true`, proceed even if the bucket already has public access.
@override final  bool? force;

/// Create a copy of MakeBucketPublicOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MakeBucketPublicOptionsCopyWith<_MakeBucketPublicOptions> get copyWith => __$MakeBucketPublicOptionsCopyWithImpl<_MakeBucketPublicOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MakeBucketPublicOptions&&(identical(other.includeFiles, includeFiles) || other.includeFiles == includeFiles)&&(identical(other.force, force) || other.force == force));
}


@override
int get hashCode => Object.hash(runtimeType,includeFiles,force);

@override
String toString() {
  return 'MakeBucketPublicOptions(includeFiles: $includeFiles, force: $force)';
}


}

/// @nodoc
abstract mixin class _$MakeBucketPublicOptionsCopyWith<$Res> implements $MakeBucketPublicOptionsCopyWith<$Res> {
  factory _$MakeBucketPublicOptionsCopyWith(_MakeBucketPublicOptions value, $Res Function(_MakeBucketPublicOptions) _then) = __$MakeBucketPublicOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool? includeFiles, bool? force
});




}
/// @nodoc
class __$MakeBucketPublicOptionsCopyWithImpl<$Res>
    implements _$MakeBucketPublicOptionsCopyWith<$Res> {
  __$MakeBucketPublicOptionsCopyWithImpl(this._self, this._then);

  final _MakeBucketPublicOptions _self;
  final $Res Function(_MakeBucketPublicOptions) _then;

/// Create a copy of MakeBucketPublicOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? includeFiles = freezed,Object? force = freezed,}) {
  return _then(_MakeBucketPublicOptions(
includeFiles: freezed == includeFiles ? _self.includeFiles : includeFiles // ignore: cast_nullable_to_non_nullable
as bool?,force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$MakeBucketPrivateOptions {

/// If `true`, also make all files in the bucket private.
 bool? get includeFiles;/// If `true`, proceed even if the bucket is already private.
 bool? get force;/// Metadata to update on the bucket.
 BucketMetadata? get metadata;/// The ID of the project which will be billed for the request.
 String? get userProject;/// Precondition options for the operation.
 PreconditionOptions? get preconditionOpts;
/// Create a copy of MakeBucketPrivateOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MakeBucketPrivateOptionsCopyWith<MakeBucketPrivateOptions> get copyWith => _$MakeBucketPrivateOptionsCopyWithImpl<MakeBucketPrivateOptions>(this as MakeBucketPrivateOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MakeBucketPrivateOptions&&(identical(other.includeFiles, includeFiles) || other.includeFiles == includeFiles)&&(identical(other.force, force) || other.force == force)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts));
}


@override
int get hashCode => Object.hash(runtimeType,includeFiles,force,metadata,userProject,preconditionOpts);

@override
String toString() {
  return 'MakeBucketPrivateOptions(includeFiles: $includeFiles, force: $force, metadata: $metadata, userProject: $userProject, preconditionOpts: $preconditionOpts)';
}


}

/// @nodoc
abstract mixin class $MakeBucketPrivateOptionsCopyWith<$Res>  {
  factory $MakeBucketPrivateOptionsCopyWith(MakeBucketPrivateOptions value, $Res Function(MakeBucketPrivateOptions) _then) = _$MakeBucketPrivateOptionsCopyWithImpl;
@useResult
$Res call({
 bool? includeFiles, bool? force, BucketMetadata? metadata, String? userProject, PreconditionOptions? preconditionOpts
});




}
/// @nodoc
class _$MakeBucketPrivateOptionsCopyWithImpl<$Res>
    implements $MakeBucketPrivateOptionsCopyWith<$Res> {
  _$MakeBucketPrivateOptionsCopyWithImpl(this._self, this._then);

  final MakeBucketPrivateOptions _self;
  final $Res Function(MakeBucketPrivateOptions) _then;

/// Create a copy of MakeBucketPrivateOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? includeFiles = freezed,Object? force = freezed,Object? metadata = freezed,Object? userProject = freezed,Object? preconditionOpts = freezed,}) {
  return _then(_self.copyWith(
includeFiles: freezed == includeFiles ? _self.includeFiles : includeFiles // ignore: cast_nullable_to_non_nullable
as bool?,force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as BucketMetadata?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,
  ));
}

}



/// @nodoc


class _MakeBucketPrivateOptions implements MakeBucketPrivateOptions {
  const _MakeBucketPrivateOptions({this.includeFiles, this.force, this.metadata, this.userProject, this.preconditionOpts});
  

/// If `true`, also make all files in the bucket private.
@override final  bool? includeFiles;
/// If `true`, proceed even if the bucket is already private.
@override final  bool? force;
/// Metadata to update on the bucket.
@override final  BucketMetadata? metadata;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Precondition options for the operation.
@override final  PreconditionOptions? preconditionOpts;

/// Create a copy of MakeBucketPrivateOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MakeBucketPrivateOptionsCopyWith<_MakeBucketPrivateOptions> get copyWith => __$MakeBucketPrivateOptionsCopyWithImpl<_MakeBucketPrivateOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MakeBucketPrivateOptions&&(identical(other.includeFiles, includeFiles) || other.includeFiles == includeFiles)&&(identical(other.force, force) || other.force == force)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts));
}


@override
int get hashCode => Object.hash(runtimeType,includeFiles,force,metadata,userProject,preconditionOpts);

@override
String toString() {
  return 'MakeBucketPrivateOptions(includeFiles: $includeFiles, force: $force, metadata: $metadata, userProject: $userProject, preconditionOpts: $preconditionOpts)';
}


}

/// @nodoc
abstract mixin class _$MakeBucketPrivateOptionsCopyWith<$Res> implements $MakeBucketPrivateOptionsCopyWith<$Res> {
  factory _$MakeBucketPrivateOptionsCopyWith(_MakeBucketPrivateOptions value, $Res Function(_MakeBucketPrivateOptions) _then) = __$MakeBucketPrivateOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool? includeFiles, bool? force, BucketMetadata? metadata, String? userProject, PreconditionOptions? preconditionOpts
});




}
/// @nodoc
class __$MakeBucketPrivateOptionsCopyWithImpl<$Res>
    implements _$MakeBucketPrivateOptionsCopyWith<$Res> {
  __$MakeBucketPrivateOptionsCopyWithImpl(this._self, this._then);

  final _MakeBucketPrivateOptions _self;
  final $Res Function(_MakeBucketPrivateOptions) _then;

/// Create a copy of MakeBucketPrivateOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? includeFiles = freezed,Object? force = freezed,Object? metadata = freezed,Object? userProject = freezed,Object? preconditionOpts = freezed,}) {
  return _then(_MakeBucketPrivateOptions(
includeFiles: freezed == includeFiles ? _self.includeFiles : includeFiles // ignore: cast_nullable_to_non_nullable
as bool?,force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as BucketMetadata?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,
  ));
}


}

/// @nodoc
mixin _$MakeAllFilesPublicPrivateOptions {

/// If `true`, proceed even if files already have the desired visibility.
 bool? get force;/// If `true`, make all files private.
 bool? get private;/// If `true`, make all files public.
 bool? get public;/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of MakeAllFilesPublicPrivateOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MakeAllFilesPublicPrivateOptionsCopyWith<MakeAllFilesPublicPrivateOptions> get copyWith => _$MakeAllFilesPublicPrivateOptionsCopyWithImpl<MakeAllFilesPublicPrivateOptions>(this as MakeAllFilesPublicPrivateOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MakeAllFilesPublicPrivateOptions&&(identical(other.force, force) || other.force == force)&&(identical(other.private, private) || other.private == private)&&(identical(other.public, public) || other.public == public)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,force,private,public,userProject);

@override
String toString() {
  return 'MakeAllFilesPublicPrivateOptions(force: $force, private: $private, public: $public, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $MakeAllFilesPublicPrivateOptionsCopyWith<$Res>  {
  factory $MakeAllFilesPublicPrivateOptionsCopyWith(MakeAllFilesPublicPrivateOptions value, $Res Function(MakeAllFilesPublicPrivateOptions) _then) = _$MakeAllFilesPublicPrivateOptionsCopyWithImpl;
@useResult
$Res call({
 bool? force, bool? private, bool? public, String? userProject
});




}
/// @nodoc
class _$MakeAllFilesPublicPrivateOptionsCopyWithImpl<$Res>
    implements $MakeAllFilesPublicPrivateOptionsCopyWith<$Res> {
  _$MakeAllFilesPublicPrivateOptionsCopyWithImpl(this._self, this._then);

  final MakeAllFilesPublicPrivateOptions _self;
  final $Res Function(MakeAllFilesPublicPrivateOptions) _then;

/// Create a copy of MakeAllFilesPublicPrivateOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? force = freezed,Object? private = freezed,Object? public = freezed,Object? userProject = freezed,}) {
  return _then(_self.copyWith(
force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool?,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as bool?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _MakeAllFilesPublicPrivateOptions implements MakeAllFilesPublicPrivateOptions {
  const _MakeAllFilesPublicPrivateOptions({this.force, this.private, this.public, this.userProject});
  

/// If `true`, proceed even if files already have the desired visibility.
@override final  bool? force;
/// If `true`, make all files private.
@override final  bool? private;
/// If `true`, make all files public.
@override final  bool? public;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of MakeAllFilesPublicPrivateOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MakeAllFilesPublicPrivateOptionsCopyWith<_MakeAllFilesPublicPrivateOptions> get copyWith => __$MakeAllFilesPublicPrivateOptionsCopyWithImpl<_MakeAllFilesPublicPrivateOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MakeAllFilesPublicPrivateOptions&&(identical(other.force, force) || other.force == force)&&(identical(other.private, private) || other.private == private)&&(identical(other.public, public) || other.public == public)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,force,private,public,userProject);

@override
String toString() {
  return 'MakeAllFilesPublicPrivateOptions(force: $force, private: $private, public: $public, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$MakeAllFilesPublicPrivateOptionsCopyWith<$Res> implements $MakeAllFilesPublicPrivateOptionsCopyWith<$Res> {
  factory _$MakeAllFilesPublicPrivateOptionsCopyWith(_MakeAllFilesPublicPrivateOptions value, $Res Function(_MakeAllFilesPublicPrivateOptions) _then) = __$MakeAllFilesPublicPrivateOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool? force, bool? private, bool? public, String? userProject
});




}
/// @nodoc
class __$MakeAllFilesPublicPrivateOptionsCopyWithImpl<$Res>
    implements _$MakeAllFilesPublicPrivateOptionsCopyWith<$Res> {
  __$MakeAllFilesPublicPrivateOptionsCopyWithImpl(this._self, this._then);

  final _MakeAllFilesPublicPrivateOptions _self;
  final $Res Function(_MakeAllFilesPublicPrivateOptions) _then;

/// Create a copy of MakeAllFilesPublicPrivateOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? force = freezed,Object? private = freezed,Object? public = freezed,Object? userProject = freezed,}) {
  return _then(_MakeAllFilesPublicPrivateOptions(
force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool?,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as bool?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$EnableLoggingOptions {

/// The prefix for log object names.
///
/// Log objects will be created with names starting with this prefix.
 String get prefix;/// The destination bucket where access logs will be stored.
 Bucket? get bucket;/// Only perform the operation if the bucket's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the bucket's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the bucket's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the bucket's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of EnableLoggingOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnableLoggingOptionsCopyWith<EnableLoggingOptions> get copyWith => _$EnableLoggingOptionsCopyWithImpl<EnableLoggingOptions>(this as EnableLoggingOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnableLoggingOptions&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,prefix,bucket,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'EnableLoggingOptions(prefix: $prefix, bucket: $bucket, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $EnableLoggingOptionsCopyWith<$Res>  {
  factory $EnableLoggingOptionsCopyWith(EnableLoggingOptions value, $Res Function(EnableLoggingOptions) _then) = _$EnableLoggingOptionsCopyWithImpl;
@useResult
$Res call({
 String prefix, Bucket? bucket, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$EnableLoggingOptionsCopyWithImpl<$Res>
    implements $EnableLoggingOptionsCopyWith<$Res> {
  _$EnableLoggingOptionsCopyWithImpl(this._self, this._then);

  final EnableLoggingOptions _self;
  final $Res Function(EnableLoggingOptions) _then;

/// Create a copy of EnableLoggingOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prefix = null,Object? bucket = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,bucket: freezed == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _EnableLoggingOptions implements EnableLoggingOptions {
  const _EnableLoggingOptions({required this.prefix, this.bucket, this.ifGenerationMatch, this.ifGenerationNotMatch, this.ifMetagenerationMatch, this.ifMetagenerationNotMatch});
  

/// The prefix for log object names.
///
/// Log objects will be created with names starting with this prefix.
@override final  String prefix;
/// The destination bucket where access logs will be stored.
@override final  Bucket? bucket;
/// Only perform the operation if the bucket's generation matches this value.
@override final  int? ifGenerationMatch;
/// Only perform the operation if the bucket's generation does not match this value.
@override final  int? ifGenerationNotMatch;
/// Only perform the operation if the bucket's metageneration matches this value.
@override final  int? ifMetagenerationMatch;
/// Only perform the operation if the bucket's metageneration does not match this value.
@override final  int? ifMetagenerationNotMatch;

/// Create a copy of EnableLoggingOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnableLoggingOptionsCopyWith<_EnableLoggingOptions> get copyWith => __$EnableLoggingOptionsCopyWithImpl<_EnableLoggingOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnableLoggingOptions&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,prefix,bucket,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'EnableLoggingOptions(prefix: $prefix, bucket: $bucket, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$EnableLoggingOptionsCopyWith<$Res> implements $EnableLoggingOptionsCopyWith<$Res> {
  factory _$EnableLoggingOptionsCopyWith(_EnableLoggingOptions value, $Res Function(_EnableLoggingOptions) _then) = __$EnableLoggingOptionsCopyWithImpl;
@override @useResult
$Res call({
 String prefix, Bucket? bucket, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$EnableLoggingOptionsCopyWithImpl<$Res>
    implements _$EnableLoggingOptionsCopyWith<$Res> {
  __$EnableLoggingOptionsCopyWithImpl(this._self, this._then);

  final _EnableLoggingOptions _self;
  final $Res Function(_EnableLoggingOptions) _then;

/// Create a copy of EnableLoggingOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prefix = null,Object? bucket = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_EnableLoggingOptions(
prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,bucket: freezed == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$UploadOptions {

 UploadDestination? get destination;/// A custom encryption key. See Customer-supplied Encryption Keys.
 EncryptionKey? get encryptionKey;/// Automatically gzip the file. This will set metadata.contentEncoding to 'gzip'.
/// If null, the contentType is used to determine if the file should be gzipped (auto-detect).
 bool? get gzip;/// The name of the Cloud KMS key that will be used to encrypt the object.
 String? get kmsKeyName;/// Metadata for the file. See Objects: insert request body for details.
 FileMetadata? get metadata;/// The starting byte of the upload stream, for resuming an interrupted upload. Defaults to 0.
 int? get offset;/// Apply a predefined set of access controls to this object.
 PredefinedAcl? get predefinedAcl;/// Make the uploaded file private. (Alias for predefinedAcl = 'private')
 bool? get private;/// Make the uploaded file public. (Alias for predefinedAcl = 'publicRead')
 bool? get public;/// Resumable uploads are automatically enabled and must be shut off explicitly by setting to false.
 bool? get resumable;/// Set the HTTP request timeout in milliseconds. This option is not available for resumable uploads. Default: 60000
 int? get timeout;/// The URI for an already-created resumable upload. See File.createResumableUpload().
 String? get uri;/// The ID of the project which will be billed for the request.
 String? get userProject;/// Validation type for data integrity checks. By default, data integrity is validated with an MD5 checksum.
 ValidationType? get validation;/// Precondition options for the upload.
 PreconditionOptions? get preconditionOpts;/// Callback for upload progress events.
 void Function(UploadProgress)? get onUploadProgress;/// Chunk size for resumable uploads. Default: 256KB
 int? get chunkSize;/// High water mark for the stream. Controls buffer size.
 int? get highWaterMark;/// Whether this is a partial upload.
 bool? get isPartialUpload;
/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadOptionsCopyWith<UploadOptions> get copyWith => _$UploadOptionsCopyWithImpl<UploadOptions>(this as UploadOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadOptions&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.encryptionKey, encryptionKey) || other.encryptionKey == encryptionKey)&&(identical(other.gzip, gzip) || other.gzip == gzip)&&(identical(other.kmsKeyName, kmsKeyName) || other.kmsKeyName == kmsKeyName)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.private, private) || other.private == private)&&(identical(other.public, public) || other.public == public)&&(identical(other.resumable, resumable) || other.resumable == resumable)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.onUploadProgress, onUploadProgress) || other.onUploadProgress == onUploadProgress)&&(identical(other.chunkSize, chunkSize) || other.chunkSize == chunkSize)&&(identical(other.highWaterMark, highWaterMark) || other.highWaterMark == highWaterMark)&&(identical(other.isPartialUpload, isPartialUpload) || other.isPartialUpload == isPartialUpload));
}


@override
int get hashCode => Object.hashAll([runtimeType,destination,encryptionKey,gzip,kmsKeyName,metadata,offset,predefinedAcl,private,public,resumable,timeout,uri,userProject,validation,preconditionOpts,onUploadProgress,chunkSize,highWaterMark,isPartialUpload]);

@override
String toString() {
  return 'UploadOptions(destination: $destination, encryptionKey: $encryptionKey, gzip: $gzip, kmsKeyName: $kmsKeyName, metadata: $metadata, offset: $offset, predefinedAcl: $predefinedAcl, private: $private, public: $public, resumable: $resumable, timeout: $timeout, uri: $uri, userProject: $userProject, validation: $validation, preconditionOpts: $preconditionOpts, onUploadProgress: $onUploadProgress, chunkSize: $chunkSize, highWaterMark: $highWaterMark, isPartialUpload: $isPartialUpload)';
}


}

/// @nodoc
abstract mixin class $UploadOptionsCopyWith<$Res>  {
  factory $UploadOptionsCopyWith(UploadOptions value, $Res Function(UploadOptions) _then) = _$UploadOptionsCopyWithImpl;
@useResult
$Res call({
 UploadDestination? destination, EncryptionKey? encryptionKey, bool? gzip, String? kmsKeyName, FileMetadata? metadata, int? offset, PredefinedAcl? predefinedAcl, bool? private, bool? public, bool? resumable, int? timeout, String? uri, String? userProject, ValidationType? validation, PreconditionOptions? preconditionOpts, void Function(UploadProgress)? onUploadProgress, int? chunkSize, int? highWaterMark, bool? isPartialUpload
});


$UploadDestinationCopyWith<$Res>? get destination;$EncryptionKeyCopyWith<$Res>? get encryptionKey;

}
/// @nodoc
class _$UploadOptionsCopyWithImpl<$Res>
    implements $UploadOptionsCopyWith<$Res> {
  _$UploadOptionsCopyWithImpl(this._self, this._then);

  final UploadOptions _self;
  final $Res Function(UploadOptions) _then;

/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? destination = freezed,Object? encryptionKey = freezed,Object? gzip = freezed,Object? kmsKeyName = freezed,Object? metadata = freezed,Object? offset = freezed,Object? predefinedAcl = freezed,Object? private = freezed,Object? public = freezed,Object? resumable = freezed,Object? timeout = freezed,Object? uri = freezed,Object? userProject = freezed,Object? validation = freezed,Object? preconditionOpts = freezed,Object? onUploadProgress = freezed,Object? chunkSize = freezed,Object? highWaterMark = freezed,Object? isPartialUpload = freezed,}) {
  return _then(_self.copyWith(
destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as UploadDestination?,encryptionKey: freezed == encryptionKey ? _self.encryptionKey : encryptionKey // ignore: cast_nullable_to_non_nullable
as EncryptionKey?,gzip: freezed == gzip ? _self.gzip : gzip // ignore: cast_nullable_to_non_nullable
as bool?,kmsKeyName: freezed == kmsKeyName ? _self.kmsKeyName : kmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as bool?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,resumable: freezed == resumable ? _self.resumable : resumable // ignore: cast_nullable_to_non_nullable
as bool?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,onUploadProgress: freezed == onUploadProgress ? _self.onUploadProgress : onUploadProgress // ignore: cast_nullable_to_non_nullable
as void Function(UploadProgress)?,chunkSize: freezed == chunkSize ? _self.chunkSize : chunkSize // ignore: cast_nullable_to_non_nullable
as int?,highWaterMark: freezed == highWaterMark ? _self.highWaterMark : highWaterMark // ignore: cast_nullable_to_non_nullable
as int?,isPartialUpload: freezed == isPartialUpload ? _self.isPartialUpload : isPartialUpload // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadDestinationCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $UploadDestinationCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncryptionKeyCopyWith<$Res>? get encryptionKey {
    if (_self.encryptionKey == null) {
    return null;
  }

  return $EncryptionKeyCopyWith<$Res>(_self.encryptionKey!, (value) {
    return _then(_self.copyWith(encryptionKey: value));
  });
}
}



/// @nodoc


class _UploadOptions implements UploadOptions {
  const _UploadOptions({this.destination, this.encryptionKey, this.gzip, this.kmsKeyName, this.metadata, this.offset, this.predefinedAcl, this.private, this.public, this.resumable, this.timeout, this.uri, this.userProject, this.validation, this.preconditionOpts, this.onUploadProgress, this.chunkSize, this.highWaterMark, this.isPartialUpload});
  

@override final  UploadDestination? destination;
/// A custom encryption key. See Customer-supplied Encryption Keys.
@override final  EncryptionKey? encryptionKey;
/// Automatically gzip the file. This will set metadata.contentEncoding to 'gzip'.
/// If null, the contentType is used to determine if the file should be gzipped (auto-detect).
@override final  bool? gzip;
/// The name of the Cloud KMS key that will be used to encrypt the object.
@override final  String? kmsKeyName;
/// Metadata for the file. See Objects: insert request body for details.
@override final  FileMetadata? metadata;
/// The starting byte of the upload stream, for resuming an interrupted upload. Defaults to 0.
@override final  int? offset;
/// Apply a predefined set of access controls to this object.
@override final  PredefinedAcl? predefinedAcl;
/// Make the uploaded file private. (Alias for predefinedAcl = 'private')
@override final  bool? private;
/// Make the uploaded file public. (Alias for predefinedAcl = 'publicRead')
@override final  bool? public;
/// Resumable uploads are automatically enabled and must be shut off explicitly by setting to false.
@override final  bool? resumable;
/// Set the HTTP request timeout in milliseconds. This option is not available for resumable uploads. Default: 60000
@override final  int? timeout;
/// The URI for an already-created resumable upload. See File.createResumableUpload().
@override final  String? uri;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Validation type for data integrity checks. By default, data integrity is validated with an MD5 checksum.
@override final  ValidationType? validation;
/// Precondition options for the upload.
@override final  PreconditionOptions? preconditionOpts;
/// Callback for upload progress events.
@override final  void Function(UploadProgress)? onUploadProgress;
/// Chunk size for resumable uploads. Default: 256KB
@override final  int? chunkSize;
/// High water mark for the stream. Controls buffer size.
@override final  int? highWaterMark;
/// Whether this is a partial upload.
@override final  bool? isPartialUpload;

/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadOptionsCopyWith<_UploadOptions> get copyWith => __$UploadOptionsCopyWithImpl<_UploadOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadOptions&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.encryptionKey, encryptionKey) || other.encryptionKey == encryptionKey)&&(identical(other.gzip, gzip) || other.gzip == gzip)&&(identical(other.kmsKeyName, kmsKeyName) || other.kmsKeyName == kmsKeyName)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.private, private) || other.private == private)&&(identical(other.public, public) || other.public == public)&&(identical(other.resumable, resumable) || other.resumable == resumable)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.onUploadProgress, onUploadProgress) || other.onUploadProgress == onUploadProgress)&&(identical(other.chunkSize, chunkSize) || other.chunkSize == chunkSize)&&(identical(other.highWaterMark, highWaterMark) || other.highWaterMark == highWaterMark)&&(identical(other.isPartialUpload, isPartialUpload) || other.isPartialUpload == isPartialUpload));
}


@override
int get hashCode => Object.hashAll([runtimeType,destination,encryptionKey,gzip,kmsKeyName,metadata,offset,predefinedAcl,private,public,resumable,timeout,uri,userProject,validation,preconditionOpts,onUploadProgress,chunkSize,highWaterMark,isPartialUpload]);

@override
String toString() {
  return 'UploadOptions(destination: $destination, encryptionKey: $encryptionKey, gzip: $gzip, kmsKeyName: $kmsKeyName, metadata: $metadata, offset: $offset, predefinedAcl: $predefinedAcl, private: $private, public: $public, resumable: $resumable, timeout: $timeout, uri: $uri, userProject: $userProject, validation: $validation, preconditionOpts: $preconditionOpts, onUploadProgress: $onUploadProgress, chunkSize: $chunkSize, highWaterMark: $highWaterMark, isPartialUpload: $isPartialUpload)';
}


}

/// @nodoc
abstract mixin class _$UploadOptionsCopyWith<$Res> implements $UploadOptionsCopyWith<$Res> {
  factory _$UploadOptionsCopyWith(_UploadOptions value, $Res Function(_UploadOptions) _then) = __$UploadOptionsCopyWithImpl;
@override @useResult
$Res call({
 UploadDestination? destination, EncryptionKey? encryptionKey, bool? gzip, String? kmsKeyName, FileMetadata? metadata, int? offset, PredefinedAcl? predefinedAcl, bool? private, bool? public, bool? resumable, int? timeout, String? uri, String? userProject, ValidationType? validation, PreconditionOptions? preconditionOpts, void Function(UploadProgress)? onUploadProgress, int? chunkSize, int? highWaterMark, bool? isPartialUpload
});


@override $UploadDestinationCopyWith<$Res>? get destination;@override $EncryptionKeyCopyWith<$Res>? get encryptionKey;

}
/// @nodoc
class __$UploadOptionsCopyWithImpl<$Res>
    implements _$UploadOptionsCopyWith<$Res> {
  __$UploadOptionsCopyWithImpl(this._self, this._then);

  final _UploadOptions _self;
  final $Res Function(_UploadOptions) _then;

/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? destination = freezed,Object? encryptionKey = freezed,Object? gzip = freezed,Object? kmsKeyName = freezed,Object? metadata = freezed,Object? offset = freezed,Object? predefinedAcl = freezed,Object? private = freezed,Object? public = freezed,Object? resumable = freezed,Object? timeout = freezed,Object? uri = freezed,Object? userProject = freezed,Object? validation = freezed,Object? preconditionOpts = freezed,Object? onUploadProgress = freezed,Object? chunkSize = freezed,Object? highWaterMark = freezed,Object? isPartialUpload = freezed,}) {
  return _then(_UploadOptions(
destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as UploadDestination?,encryptionKey: freezed == encryptionKey ? _self.encryptionKey : encryptionKey // ignore: cast_nullable_to_non_nullable
as EncryptionKey?,gzip: freezed == gzip ? _self.gzip : gzip // ignore: cast_nullable_to_non_nullable
as bool?,kmsKeyName: freezed == kmsKeyName ? _self.kmsKeyName : kmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as bool?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,resumable: freezed == resumable ? _self.resumable : resumable // ignore: cast_nullable_to_non_nullable
as bool?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,onUploadProgress: freezed == onUploadProgress ? _self.onUploadProgress : onUploadProgress // ignore: cast_nullable_to_non_nullable
as void Function(UploadProgress)?,chunkSize: freezed == chunkSize ? _self.chunkSize : chunkSize // ignore: cast_nullable_to_non_nullable
as int?,highWaterMark: freezed == highWaterMark ? _self.highWaterMark : highWaterMark // ignore: cast_nullable_to_non_nullable
as int?,isPartialUpload: freezed == isPartialUpload ? _self.isPartialUpload : isPartialUpload // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadDestinationCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $UploadDestinationCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncryptionKeyCopyWith<$Res>? get encryptionKey {
    if (_self.encryptionKey == null) {
    return null;
  }

  return $EncryptionKeyCopyWith<$Res>(_self.encryptionKey!, (value) {
    return _then(_self.copyWith(encryptionKey: value));
  });
}
}

/// @nodoc
mixin _$GetBucketsOptions {

/// Automatically paginate through all results. Defaults to `true`.
 bool? get autoPaginate;/// The project ID to list buckets for. If not provided, uses the default project.
 String? get projectId;/// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
 int? get maxApiCalls;/// Maximum number of results to return per page.
 int? get maxResults;/// Token for the next page of results.
 String? get pageToken;/// Filter results to buckets whose names begin with this prefix.
 String? get prefix;/// The set of properties to return in the response.
 Projection? get projection;/// If `true`, include soft-deleted buckets in the results.
 bool? get softDeleted;/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of GetBucketsOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetBucketsOptionsCopyWith<GetBucketsOptions> get copyWith => _$GetBucketsOptionsCopyWithImpl<GetBucketsOptions>(this as GetBucketsOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetBucketsOptions&&(identical(other.autoPaginate, autoPaginate) || other.autoPaginate == autoPaginate)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.maxApiCalls, maxApiCalls) || other.maxApiCalls == maxApiCalls)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.softDeleted, softDeleted) || other.softDeleted == softDeleted)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,autoPaginate,projectId,maxApiCalls,maxResults,pageToken,prefix,projection,softDeleted,userProject);

@override
String toString() {
  return 'GetBucketsOptions(autoPaginate: $autoPaginate, projectId: $projectId, maxApiCalls: $maxApiCalls, maxResults: $maxResults, pageToken: $pageToken, prefix: $prefix, projection: $projection, softDeleted: $softDeleted, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $GetBucketsOptionsCopyWith<$Res>  {
  factory $GetBucketsOptionsCopyWith(GetBucketsOptions value, $Res Function(GetBucketsOptions) _then) = _$GetBucketsOptionsCopyWithImpl;
@useResult
$Res call({
 bool? autoPaginate, String? projectId, int? maxApiCalls, int? maxResults, String? pageToken, String? prefix, Projection? projection, bool? softDeleted, String? userProject
});




}
/// @nodoc
class _$GetBucketsOptionsCopyWithImpl<$Res>
    implements $GetBucketsOptionsCopyWith<$Res> {
  _$GetBucketsOptionsCopyWithImpl(this._self, this._then);

  final GetBucketsOptions _self;
  final $Res Function(GetBucketsOptions) _then;

/// Create a copy of GetBucketsOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? autoPaginate = freezed,Object? projectId = freezed,Object? maxApiCalls = freezed,Object? maxResults = freezed,Object? pageToken = freezed,Object? prefix = freezed,Object? projection = freezed,Object? softDeleted = freezed,Object? userProject = freezed,}) {
  return _then(_self.copyWith(
autoPaginate: freezed == autoPaginate ? _self.autoPaginate : autoPaginate // ignore: cast_nullable_to_non_nullable
as bool?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,maxApiCalls: freezed == maxApiCalls ? _self.maxApiCalls : maxApiCalls // ignore: cast_nullable_to_non_nullable
as int?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,projection: freezed == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as Projection?,softDeleted: freezed == softDeleted ? _self.softDeleted : softDeleted // ignore: cast_nullable_to_non_nullable
as bool?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _GetBucketsOptions implements GetBucketsOptions {
  const _GetBucketsOptions({this.autoPaginate = true, this.projectId, this.maxApiCalls, this.maxResults, this.pageToken, this.prefix, this.projection, this.softDeleted, this.userProject});
  

/// Automatically paginate through all results. Defaults to `true`.
@override@JsonKey() final  bool? autoPaginate;
/// The project ID to list buckets for. If not provided, uses the default project.
@override final  String? projectId;
/// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
@override final  int? maxApiCalls;
/// Maximum number of results to return per page.
@override final  int? maxResults;
/// Token for the next page of results.
@override final  String? pageToken;
/// Filter results to buckets whose names begin with this prefix.
@override final  String? prefix;
/// The set of properties to return in the response.
@override final  Projection? projection;
/// If `true`, include soft-deleted buckets in the results.
@override final  bool? softDeleted;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of GetBucketsOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetBucketsOptionsCopyWith<_GetBucketsOptions> get copyWith => __$GetBucketsOptionsCopyWithImpl<_GetBucketsOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetBucketsOptions&&(identical(other.autoPaginate, autoPaginate) || other.autoPaginate == autoPaginate)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.maxApiCalls, maxApiCalls) || other.maxApiCalls == maxApiCalls)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.softDeleted, softDeleted) || other.softDeleted == softDeleted)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,autoPaginate,projectId,maxApiCalls,maxResults,pageToken,prefix,projection,softDeleted,userProject);

@override
String toString() {
  return 'GetBucketsOptions(autoPaginate: $autoPaginate, projectId: $projectId, maxApiCalls: $maxApiCalls, maxResults: $maxResults, pageToken: $pageToken, prefix: $prefix, projection: $projection, softDeleted: $softDeleted, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$GetBucketsOptionsCopyWith<$Res> implements $GetBucketsOptionsCopyWith<$Res> {
  factory _$GetBucketsOptionsCopyWith(_GetBucketsOptions value, $Res Function(_GetBucketsOptions) _then) = __$GetBucketsOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool? autoPaginate, String? projectId, int? maxApiCalls, int? maxResults, String? pageToken, String? prefix, Projection? projection, bool? softDeleted, String? userProject
});




}
/// @nodoc
class __$GetBucketsOptionsCopyWithImpl<$Res>
    implements _$GetBucketsOptionsCopyWith<$Res> {
  __$GetBucketsOptionsCopyWithImpl(this._self, this._then);

  final _GetBucketsOptions _self;
  final $Res Function(_GetBucketsOptions) _then;

/// Create a copy of GetBucketsOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoPaginate = freezed,Object? projectId = freezed,Object? maxApiCalls = freezed,Object? maxResults = freezed,Object? pageToken = freezed,Object? prefix = freezed,Object? projection = freezed,Object? softDeleted = freezed,Object? userProject = freezed,}) {
  return _then(_GetBucketsOptions(
autoPaginate: freezed == autoPaginate ? _self.autoPaginate : autoPaginate // ignore: cast_nullable_to_non_nullable
as bool?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,maxApiCalls: freezed == maxApiCalls ? _self.maxApiCalls : maxApiCalls // ignore: cast_nullable_to_non_nullable
as int?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,projection: freezed == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as Projection?,softDeleted: freezed == softDeleted ? _self.softDeleted : softDeleted // ignore: cast_nullable_to_non_nullable
as bool?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AddLifecycleRuleOptions {

/// If `true`, append the rule to existing rules. If `false`, replace all rules.
///
/// Defaults to `true`.
 bool get append;/// Only perform the operation if the bucket's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the bucket's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;/// Only perform the operation if the bucket's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the bucket's generation does not match this value.
 int? get ifGenerationNotMatch;
/// Create a copy of AddLifecycleRuleOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddLifecycleRuleOptionsCopyWith<AddLifecycleRuleOptions> get copyWith => _$AddLifecycleRuleOptionsCopyWithImpl<AddLifecycleRuleOptions>(this as AddLifecycleRuleOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddLifecycleRuleOptions&&(identical(other.append, append) || other.append == append)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,append,ifMetagenerationMatch,ifMetagenerationNotMatch,ifGenerationMatch,ifGenerationNotMatch);

@override
String toString() {
  return 'AddLifecycleRuleOptions(append: $append, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $AddLifecycleRuleOptionsCopyWith<$Res>  {
  factory $AddLifecycleRuleOptionsCopyWith(AddLifecycleRuleOptions value, $Res Function(AddLifecycleRuleOptions) _then) = _$AddLifecycleRuleOptionsCopyWithImpl;
@useResult
$Res call({
 bool append, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch, int? ifGenerationMatch, int? ifGenerationNotMatch
});




}
/// @nodoc
class _$AddLifecycleRuleOptionsCopyWithImpl<$Res>
    implements $AddLifecycleRuleOptionsCopyWith<$Res> {
  _$AddLifecycleRuleOptionsCopyWithImpl(this._self, this._then);

  final AddLifecycleRuleOptions _self;
  final $Res Function(AddLifecycleRuleOptions) _then;

/// Create a copy of AddLifecycleRuleOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? append = null,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
append: null == append ? _self.append : append // ignore: cast_nullable_to_non_nullable
as bool,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _AddLifecycleRuleOptions implements AddLifecycleRuleOptions {
  const _AddLifecycleRuleOptions({this.append = true, this.ifMetagenerationMatch, this.ifMetagenerationNotMatch, this.ifGenerationMatch, this.ifGenerationNotMatch});
  

/// If `true`, append the rule to existing rules. If `false`, replace all rules.
///
/// Defaults to `true`.
@override@JsonKey() final  bool append;
/// Only perform the operation if the bucket's metageneration matches this value.
@override final  int? ifMetagenerationMatch;
/// Only perform the operation if the bucket's metageneration does not match this value.
@override final  int? ifMetagenerationNotMatch;
/// Only perform the operation if the bucket's generation matches this value.
@override final  int? ifGenerationMatch;
/// Only perform the operation if the bucket's generation does not match this value.
@override final  int? ifGenerationNotMatch;

/// Create a copy of AddLifecycleRuleOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddLifecycleRuleOptionsCopyWith<_AddLifecycleRuleOptions> get copyWith => __$AddLifecycleRuleOptionsCopyWithImpl<_AddLifecycleRuleOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddLifecycleRuleOptions&&(identical(other.append, append) || other.append == append)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,append,ifMetagenerationMatch,ifMetagenerationNotMatch,ifGenerationMatch,ifGenerationNotMatch);

@override
String toString() {
  return 'AddLifecycleRuleOptions(append: $append, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$AddLifecycleRuleOptionsCopyWith<$Res> implements $AddLifecycleRuleOptionsCopyWith<$Res> {
  factory _$AddLifecycleRuleOptionsCopyWith(_AddLifecycleRuleOptions value, $Res Function(_AddLifecycleRuleOptions) _then) = __$AddLifecycleRuleOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool append, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch, int? ifGenerationMatch, int? ifGenerationNotMatch
});




}
/// @nodoc
class __$AddLifecycleRuleOptionsCopyWithImpl<$Res>
    implements _$AddLifecycleRuleOptionsCopyWith<$Res> {
  __$AddLifecycleRuleOptionsCopyWithImpl(this._self, this._then);

  final _AddLifecycleRuleOptions _self;
  final $Res Function(_AddLifecycleRuleOptions) _then;

/// Create a copy of AddLifecycleRuleOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? append = null,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,}) {
  return _then(_AddLifecycleRuleOptions(
append: null == append ? _self.append : append // ignore: cast_nullable_to_non_nullable
as bool,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$CombineOptions {

/// The name of the Cloud KMS key that will be used to encrypt the combined object.
 String? get kmsKeyName;/// The ID of the project which will be billed for the request.
 String? get userProject;/// Only perform the operation if the destination object's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the destination object's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the destination object's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the destination object's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of CombineOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CombineOptionsCopyWith<CombineOptions> get copyWith => _$CombineOptionsCopyWithImpl<CombineOptions>(this as CombineOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CombineOptions&&(identical(other.kmsKeyName, kmsKeyName) || other.kmsKeyName == kmsKeyName)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,kmsKeyName,userProject,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'CombineOptions(kmsKeyName: $kmsKeyName, userProject: $userProject, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $CombineOptionsCopyWith<$Res>  {
  factory $CombineOptionsCopyWith(CombineOptions value, $Res Function(CombineOptions) _then) = _$CombineOptionsCopyWithImpl;
@useResult
$Res call({
 String? kmsKeyName, String? userProject, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$CombineOptionsCopyWithImpl<$Res>
    implements $CombineOptionsCopyWith<$Res> {
  _$CombineOptionsCopyWithImpl(this._self, this._then);

  final CombineOptions _self;
  final $Res Function(CombineOptions) _then;

/// Create a copy of CombineOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kmsKeyName = freezed,Object? userProject = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
kmsKeyName: freezed == kmsKeyName ? _self.kmsKeyName : kmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _CombineOptions extends CombineOptions {
  const _CombineOptions({this.kmsKeyName, this.userProject, final  int? ifGenerationMatch, final  int? ifGenerationNotMatch, final  int? ifMetagenerationMatch, final  int? ifMetagenerationNotMatch}): super._(ifGenerationMatch: ifGenerationMatch, ifGenerationNotMatch: ifGenerationNotMatch, ifMetagenerationMatch: ifMetagenerationMatch, ifMetagenerationNotMatch: ifMetagenerationNotMatch);
  

/// The name of the Cloud KMS key that will be used to encrypt the combined object.
@override final  String? kmsKeyName;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of CombineOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CombineOptionsCopyWith<_CombineOptions> get copyWith => __$CombineOptionsCopyWithImpl<_CombineOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CombineOptions&&(identical(other.kmsKeyName, kmsKeyName) || other.kmsKeyName == kmsKeyName)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,kmsKeyName,userProject,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'CombineOptions(kmsKeyName: $kmsKeyName, userProject: $userProject, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$CombineOptionsCopyWith<$Res> implements $CombineOptionsCopyWith<$Res> {
  factory _$CombineOptionsCopyWith(_CombineOptions value, $Res Function(_CombineOptions) _then) = __$CombineOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? kmsKeyName, String? userProject, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$CombineOptionsCopyWithImpl<$Res>
    implements _$CombineOptionsCopyWith<$Res> {
  __$CombineOptionsCopyWithImpl(this._self, this._then);

  final _CombineOptions _self;
  final $Res Function(_CombineOptions) _then;

/// Create a copy of CombineOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kmsKeyName = freezed,Object? userProject = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_CombineOptions(
kmsKeyName: freezed == kmsKeyName ? _self.kmsKeyName : kmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$SetBucketMetadataOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;/// Apply a predefined set of access controls to the bucket.
 PredefinedAcl? get predefinedAcl;/// Only perform the operation if the bucket's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the bucket's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the bucket's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the bucket's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of SetBucketMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetBucketMetadataOptionsCopyWith<SetBucketMetadataOptions> get copyWith => _$SetBucketMetadataOptionsCopyWithImpl<SetBucketMetadataOptions>(this as SetBucketMetadataOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetBucketMetadataOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,predefinedAcl,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'SetBucketMetadataOptions(userProject: $userProject, predefinedAcl: $predefinedAcl, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $SetBucketMetadataOptionsCopyWith<$Res>  {
  factory $SetBucketMetadataOptionsCopyWith(SetBucketMetadataOptions value, $Res Function(SetBucketMetadataOptions) _then) = _$SetBucketMetadataOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject, PredefinedAcl? predefinedAcl, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$SetBucketMetadataOptionsCopyWithImpl<$Res>
    implements $SetBucketMetadataOptionsCopyWith<$Res> {
  _$SetBucketMetadataOptionsCopyWithImpl(this._self, this._then);

  final SetBucketMetadataOptions _self;
  final $Res Function(SetBucketMetadataOptions) _then;

/// Create a copy of SetBucketMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,Object? predefinedAcl = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _SetBucketMetadataOptions extends SetBucketMetadataOptions {
  const _SetBucketMetadataOptions({this.userProject, this.predefinedAcl, final  int? ifGenerationMatch, final  int? ifGenerationNotMatch, final  int? ifMetagenerationMatch, final  int? ifMetagenerationNotMatch}): super._(ifGenerationMatch: ifGenerationMatch, ifGenerationNotMatch: ifGenerationNotMatch, ifMetagenerationMatch: ifMetagenerationMatch, ifMetagenerationNotMatch: ifMetagenerationNotMatch);
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Apply a predefined set of access controls to the bucket.
@override final  PredefinedAcl? predefinedAcl;

/// Create a copy of SetBucketMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetBucketMetadataOptionsCopyWith<_SetBucketMetadataOptions> get copyWith => __$SetBucketMetadataOptionsCopyWithImpl<_SetBucketMetadataOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetBucketMetadataOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,predefinedAcl,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'SetBucketMetadataOptions(userProject: $userProject, predefinedAcl: $predefinedAcl, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$SetBucketMetadataOptionsCopyWith<$Res> implements $SetBucketMetadataOptionsCopyWith<$Res> {
  factory _$SetBucketMetadataOptionsCopyWith(_SetBucketMetadataOptions value, $Res Function(_SetBucketMetadataOptions) _then) = __$SetBucketMetadataOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject, PredefinedAcl? predefinedAcl, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$SetBucketMetadataOptionsCopyWithImpl<$Res>
    implements _$SetBucketMetadataOptionsCopyWith<$Res> {
  __$SetBucketMetadataOptionsCopyWithImpl(this._self, this._then);

  final _SetBucketMetadataOptions _self;
  final $Res Function(_SetBucketMetadataOptions) _then;

/// Create a copy of SetBucketMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,Object? predefinedAcl = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_SetBucketMetadataOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$GetBucketOptions {

/// Automatically create the bucket if it doesn't already exist.
///
/// Defaults to `false`.
 bool get autoCreate;/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of GetBucketOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetBucketOptionsCopyWith<GetBucketOptions> get copyWith => _$GetBucketOptionsCopyWithImpl<GetBucketOptions>(this as GetBucketOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetBucketOptions&&(identical(other.autoCreate, autoCreate) || other.autoCreate == autoCreate)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,autoCreate,userProject);

@override
String toString() {
  return 'GetBucketOptions(autoCreate: $autoCreate, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $GetBucketOptionsCopyWith<$Res>  {
  factory $GetBucketOptionsCopyWith(GetBucketOptions value, $Res Function(GetBucketOptions) _then) = _$GetBucketOptionsCopyWithImpl;
@useResult
$Res call({
 bool autoCreate, String? userProject
});




}
/// @nodoc
class _$GetBucketOptionsCopyWithImpl<$Res>
    implements $GetBucketOptionsCopyWith<$Res> {
  _$GetBucketOptionsCopyWithImpl(this._self, this._then);

  final GetBucketOptions _self;
  final $Res Function(GetBucketOptions) _then;

/// Create a copy of GetBucketOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? autoCreate = null,Object? userProject = freezed,}) {
  return _then(_self.copyWith(
autoCreate: null == autoCreate ? _self.autoCreate : autoCreate // ignore: cast_nullable_to_non_nullable
as bool,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _GetBucketOptions implements GetBucketOptions {
  const _GetBucketOptions({this.autoCreate = false, this.userProject});
  

/// Automatically create the bucket if it doesn't already exist.
///
/// Defaults to `false`.
@override@JsonKey() final  bool autoCreate;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of GetBucketOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetBucketOptionsCopyWith<_GetBucketOptions> get copyWith => __$GetBucketOptionsCopyWithImpl<_GetBucketOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetBucketOptions&&(identical(other.autoCreate, autoCreate) || other.autoCreate == autoCreate)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,autoCreate,userProject);

@override
String toString() {
  return 'GetBucketOptions(autoCreate: $autoCreate, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$GetBucketOptionsCopyWith<$Res> implements $GetBucketOptionsCopyWith<$Res> {
  factory _$GetBucketOptionsCopyWith(_GetBucketOptions value, $Res Function(_GetBucketOptions) _then) = __$GetBucketOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool autoCreate, String? userProject
});




}
/// @nodoc
class __$GetBucketOptionsCopyWithImpl<$Res>
    implements _$GetBucketOptionsCopyWith<$Res> {
  __$GetBucketOptionsCopyWithImpl(this._self, this._then);

  final _GetBucketOptions _self;
  final $Res Function(_GetBucketOptions) _then;

/// Create a copy of GetBucketOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoCreate = null,Object? userProject = freezed,}) {
  return _then(_GetBucketOptions(
autoCreate: null == autoCreate ? _self.autoCreate : autoCreate // ignore: cast_nullable_to_non_nullable
as bool,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$GetBucketSignedUrlOptions {

/// Custom host for the signed URL. Inherited from [SignedUrlConfig].
 Uri? get host;/// Custom signing endpoint. Inherited from [SignedUrlConfig].
 Uri? get signingEndpoint;/// The action to perform. Defaults to `'list'`.
 String get action;/// The version of the signing algorithm to use.
 SignedUrlVersion? get version;/// Custom domain name for the signed URL.
 String? get cname;/// Use virtual-hosted-style URLs. Defaults to `false`.
 bool? get virtualHostedStyle;/// When the signed URL should expire.
 DateTime get expires;/// Additional headers to include in the signed URL.
 Map<String, String>? get extensionHeaders;/// Additional query parameters to include in the signed URL.
 Map<String, String>? get queryParams;
/// Create a copy of GetBucketSignedUrlOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetBucketSignedUrlOptionsCopyWith<GetBucketSignedUrlOptions> get copyWith => _$GetBucketSignedUrlOptionsCopyWithImpl<GetBucketSignedUrlOptions>(this as GetBucketSignedUrlOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetBucketSignedUrlOptions&&(identical(other.host, host) || other.host == host)&&(identical(other.signingEndpoint, signingEndpoint) || other.signingEndpoint == signingEndpoint)&&(identical(other.action, action) || other.action == action)&&(identical(other.version, version) || other.version == version)&&(identical(other.cname, cname) || other.cname == cname)&&(identical(other.virtualHostedStyle, virtualHostedStyle) || other.virtualHostedStyle == virtualHostedStyle)&&(identical(other.expires, expires) || other.expires == expires)&&const DeepCollectionEquality().equals(other.extensionHeaders, extensionHeaders)&&const DeepCollectionEquality().equals(other.queryParams, queryParams));
}


@override
int get hashCode => Object.hash(runtimeType,host,signingEndpoint,action,version,cname,virtualHostedStyle,expires,const DeepCollectionEquality().hash(extensionHeaders),const DeepCollectionEquality().hash(queryParams));

@override
String toString() {
  return 'GetBucketSignedUrlOptions(host: $host, signingEndpoint: $signingEndpoint, action: $action, version: $version, cname: $cname, virtualHostedStyle: $virtualHostedStyle, expires: $expires, extensionHeaders: $extensionHeaders, queryParams: $queryParams)';
}


}

/// @nodoc
abstract mixin class $GetBucketSignedUrlOptionsCopyWith<$Res>  {
  factory $GetBucketSignedUrlOptionsCopyWith(GetBucketSignedUrlOptions value, $Res Function(GetBucketSignedUrlOptions) _then) = _$GetBucketSignedUrlOptionsCopyWithImpl;
@useResult
$Res call({
 Uri? host, Uri? signingEndpoint, String action, SignedUrlVersion? version, String? cname, bool? virtualHostedStyle, DateTime expires, Map<String, String>? extensionHeaders, Map<String, String>? queryParams
});




}
/// @nodoc
class _$GetBucketSignedUrlOptionsCopyWithImpl<$Res>
    implements $GetBucketSignedUrlOptionsCopyWith<$Res> {
  _$GetBucketSignedUrlOptionsCopyWithImpl(this._self, this._then);

  final GetBucketSignedUrlOptions _self;
  final $Res Function(GetBucketSignedUrlOptions) _then;

/// Create a copy of GetBucketSignedUrlOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = freezed,Object? signingEndpoint = freezed,Object? action = null,Object? version = freezed,Object? cname = freezed,Object? virtualHostedStyle = freezed,Object? expires = null,Object? extensionHeaders = freezed,Object? queryParams = freezed,}) {
  return _then(_self.copyWith(
host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as Uri?,signingEndpoint: freezed == signingEndpoint ? _self.signingEndpoint : signingEndpoint // ignore: cast_nullable_to_non_nullable
as Uri?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as SignedUrlVersion?,cname: freezed == cname ? _self.cname : cname // ignore: cast_nullable_to_non_nullable
as String?,virtualHostedStyle: freezed == virtualHostedStyle ? _self.virtualHostedStyle : virtualHostedStyle // ignore: cast_nullable_to_non_nullable
as bool?,expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime,extensionHeaders: freezed == extensionHeaders ? _self.extensionHeaders : extensionHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,queryParams: freezed == queryParams ? _self.queryParams : queryParams // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}



/// @nodoc


class _GetBucketSignedUrlOptions implements GetBucketSignedUrlOptions {
  const _GetBucketSignedUrlOptions({this.host, this.signingEndpoint, this.action = 'list', this.version, this.cname, this.virtualHostedStyle = false, required this.expires, final  Map<String, String>? extensionHeaders, final  Map<String, String>? queryParams}): _extensionHeaders = extensionHeaders,_queryParams = queryParams;
  

/// Custom host for the signed URL. Inherited from [SignedUrlConfig].
@override final  Uri? host;
/// Custom signing endpoint. Inherited from [SignedUrlConfig].
@override final  Uri? signingEndpoint;
/// The action to perform. Defaults to `'list'`.
@override@JsonKey() final  String action;
/// The version of the signing algorithm to use.
@override final  SignedUrlVersion? version;
/// Custom domain name for the signed URL.
@override final  String? cname;
/// Use virtual-hosted-style URLs. Defaults to `false`.
@override@JsonKey() final  bool? virtualHostedStyle;
/// When the signed URL should expire.
@override final  DateTime expires;
/// Additional headers to include in the signed URL.
 final  Map<String, String>? _extensionHeaders;
/// Additional headers to include in the signed URL.
@override Map<String, String>? get extensionHeaders {
  final value = _extensionHeaders;
  if (value == null) return null;
  if (_extensionHeaders is EqualUnmodifiableMapView) return _extensionHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Additional query parameters to include in the signed URL.
 final  Map<String, String>? _queryParams;
/// Additional query parameters to include in the signed URL.
@override Map<String, String>? get queryParams {
  final value = _queryParams;
  if (value == null) return null;
  if (_queryParams is EqualUnmodifiableMapView) return _queryParams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of GetBucketSignedUrlOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetBucketSignedUrlOptionsCopyWith<_GetBucketSignedUrlOptions> get copyWith => __$GetBucketSignedUrlOptionsCopyWithImpl<_GetBucketSignedUrlOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetBucketSignedUrlOptions&&(identical(other.host, host) || other.host == host)&&(identical(other.signingEndpoint, signingEndpoint) || other.signingEndpoint == signingEndpoint)&&(identical(other.action, action) || other.action == action)&&(identical(other.version, version) || other.version == version)&&(identical(other.cname, cname) || other.cname == cname)&&(identical(other.virtualHostedStyle, virtualHostedStyle) || other.virtualHostedStyle == virtualHostedStyle)&&(identical(other.expires, expires) || other.expires == expires)&&const DeepCollectionEquality().equals(other._extensionHeaders, _extensionHeaders)&&const DeepCollectionEquality().equals(other._queryParams, _queryParams));
}


@override
int get hashCode => Object.hash(runtimeType,host,signingEndpoint,action,version,cname,virtualHostedStyle,expires,const DeepCollectionEquality().hash(_extensionHeaders),const DeepCollectionEquality().hash(_queryParams));

@override
String toString() {
  return 'GetBucketSignedUrlOptions(host: $host, signingEndpoint: $signingEndpoint, action: $action, version: $version, cname: $cname, virtualHostedStyle: $virtualHostedStyle, expires: $expires, extensionHeaders: $extensionHeaders, queryParams: $queryParams)';
}


}

/// @nodoc
abstract mixin class _$GetBucketSignedUrlOptionsCopyWith<$Res> implements $GetBucketSignedUrlOptionsCopyWith<$Res> {
  factory _$GetBucketSignedUrlOptionsCopyWith(_GetBucketSignedUrlOptions value, $Res Function(_GetBucketSignedUrlOptions) _then) = __$GetBucketSignedUrlOptionsCopyWithImpl;
@override @useResult
$Res call({
 Uri? host, Uri? signingEndpoint, String action, SignedUrlVersion? version, String? cname, bool? virtualHostedStyle, DateTime expires, Map<String, String>? extensionHeaders, Map<String, String>? queryParams
});




}
/// @nodoc
class __$GetBucketSignedUrlOptionsCopyWithImpl<$Res>
    implements _$GetBucketSignedUrlOptionsCopyWith<$Res> {
  __$GetBucketSignedUrlOptionsCopyWithImpl(this._self, this._then);

  final _GetBucketSignedUrlOptions _self;
  final $Res Function(_GetBucketSignedUrlOptions) _then;

/// Create a copy of GetBucketSignedUrlOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = freezed,Object? signingEndpoint = freezed,Object? action = null,Object? version = freezed,Object? cname = freezed,Object? virtualHostedStyle = freezed,Object? expires = null,Object? extensionHeaders = freezed,Object? queryParams = freezed,}) {
  return _then(_GetBucketSignedUrlOptions(
host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as Uri?,signingEndpoint: freezed == signingEndpoint ? _self.signingEndpoint : signingEndpoint // ignore: cast_nullable_to_non_nullable
as Uri?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as SignedUrlVersion?,cname: freezed == cname ? _self.cname : cname // ignore: cast_nullable_to_non_nullable
as String?,virtualHostedStyle: freezed == virtualHostedStyle ? _self.virtualHostedStyle : virtualHostedStyle // ignore: cast_nullable_to_non_nullable
as bool?,expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime,extensionHeaders: freezed == extensionHeaders ? _self._extensionHeaders : extensionHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,queryParams: freezed == queryParams ? _self._queryParams : queryParams // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

/// @nodoc
mixin _$CreateNotificationOptions {

/// An optional list of additional attributes to attach to each Cloud PubSub
/// message published for this notification subscription.
 Map<String, String>? get customAttributes;/// If present, only send notifications about listed event types.
/// If empty, send notifications for all event types.
 List<String>? get eventTypes;/// If present, only apply this notification configuration to object names
/// that begin with this prefix.
 String? get objectNamePrefix;/// The desired content of the Payload. Defaults to `JSON_API_V1`.
///
/// Acceptable values are:
/// - `JSON_API_V1`
/// - `NONE`
 String? get payloadFormat;/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of CreateNotificationOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateNotificationOptionsCopyWith<CreateNotificationOptions> get copyWith => _$CreateNotificationOptionsCopyWithImpl<CreateNotificationOptions>(this as CreateNotificationOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateNotificationOptions&&const DeepCollectionEquality().equals(other.customAttributes, customAttributes)&&const DeepCollectionEquality().equals(other.eventTypes, eventTypes)&&(identical(other.objectNamePrefix, objectNamePrefix) || other.objectNamePrefix == objectNamePrefix)&&(identical(other.payloadFormat, payloadFormat) || other.payloadFormat == payloadFormat)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(customAttributes),const DeepCollectionEquality().hash(eventTypes),objectNamePrefix,payloadFormat,userProject);

@override
String toString() {
  return 'CreateNotificationOptions(customAttributes: $customAttributes, eventTypes: $eventTypes, objectNamePrefix: $objectNamePrefix, payloadFormat: $payloadFormat, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $CreateNotificationOptionsCopyWith<$Res>  {
  factory $CreateNotificationOptionsCopyWith(CreateNotificationOptions value, $Res Function(CreateNotificationOptions) _then) = _$CreateNotificationOptionsCopyWithImpl;
@useResult
$Res call({
 Map<String, String>? customAttributes, List<String>? eventTypes, String? objectNamePrefix, String? payloadFormat, String? userProject
});




}
/// @nodoc
class _$CreateNotificationOptionsCopyWithImpl<$Res>
    implements $CreateNotificationOptionsCopyWith<$Res> {
  _$CreateNotificationOptionsCopyWithImpl(this._self, this._then);

  final CreateNotificationOptions _self;
  final $Res Function(CreateNotificationOptions) _then;

/// Create a copy of CreateNotificationOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customAttributes = freezed,Object? eventTypes = freezed,Object? objectNamePrefix = freezed,Object? payloadFormat = freezed,Object? userProject = freezed,}) {
  return _then(_self.copyWith(
customAttributes: freezed == customAttributes ? _self.customAttributes : customAttributes // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,eventTypes: freezed == eventTypes ? _self.eventTypes : eventTypes // ignore: cast_nullable_to_non_nullable
as List<String>?,objectNamePrefix: freezed == objectNamePrefix ? _self.objectNamePrefix : objectNamePrefix // ignore: cast_nullable_to_non_nullable
as String?,payloadFormat: freezed == payloadFormat ? _self.payloadFormat : payloadFormat // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _CreateNotificationOptions implements CreateNotificationOptions {
  const _CreateNotificationOptions({final  Map<String, String>? customAttributes, final  List<String>? eventTypes, this.objectNamePrefix, this.payloadFormat, this.userProject}): _customAttributes = customAttributes,_eventTypes = eventTypes;
  

/// An optional list of additional attributes to attach to each Cloud PubSub
/// message published for this notification subscription.
 final  Map<String, String>? _customAttributes;
/// An optional list of additional attributes to attach to each Cloud PubSub
/// message published for this notification subscription.
@override Map<String, String>? get customAttributes {
  final value = _customAttributes;
  if (value == null) return null;
  if (_customAttributes is EqualUnmodifiableMapView) return _customAttributes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// If present, only send notifications about listed event types.
/// If empty, send notifications for all event types.
 final  List<String>? _eventTypes;
/// If present, only send notifications about listed event types.
/// If empty, send notifications for all event types.
@override List<String>? get eventTypes {
  final value = _eventTypes;
  if (value == null) return null;
  if (_eventTypes is EqualUnmodifiableListView) return _eventTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// If present, only apply this notification configuration to object names
/// that begin with this prefix.
@override final  String? objectNamePrefix;
/// The desired content of the Payload. Defaults to `JSON_API_V1`.
///
/// Acceptable values are:
/// - `JSON_API_V1`
/// - `NONE`
@override final  String? payloadFormat;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of CreateNotificationOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateNotificationOptionsCopyWith<_CreateNotificationOptions> get copyWith => __$CreateNotificationOptionsCopyWithImpl<_CreateNotificationOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateNotificationOptions&&const DeepCollectionEquality().equals(other._customAttributes, _customAttributes)&&const DeepCollectionEquality().equals(other._eventTypes, _eventTypes)&&(identical(other.objectNamePrefix, objectNamePrefix) || other.objectNamePrefix == objectNamePrefix)&&(identical(other.payloadFormat, payloadFormat) || other.payloadFormat == payloadFormat)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_customAttributes),const DeepCollectionEquality().hash(_eventTypes),objectNamePrefix,payloadFormat,userProject);

@override
String toString() {
  return 'CreateNotificationOptions(customAttributes: $customAttributes, eventTypes: $eventTypes, objectNamePrefix: $objectNamePrefix, payloadFormat: $payloadFormat, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$CreateNotificationOptionsCopyWith<$Res> implements $CreateNotificationOptionsCopyWith<$Res> {
  factory _$CreateNotificationOptionsCopyWith(_CreateNotificationOptions value, $Res Function(_CreateNotificationOptions) _then) = __$CreateNotificationOptionsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, String>? customAttributes, List<String>? eventTypes, String? objectNamePrefix, String? payloadFormat, String? userProject
});




}
/// @nodoc
class __$CreateNotificationOptionsCopyWithImpl<$Res>
    implements _$CreateNotificationOptionsCopyWith<$Res> {
  __$CreateNotificationOptionsCopyWithImpl(this._self, this._then);

  final _CreateNotificationOptions _self;
  final $Res Function(_CreateNotificationOptions) _then;

/// Create a copy of CreateNotificationOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customAttributes = freezed,Object? eventTypes = freezed,Object? objectNamePrefix = freezed,Object? payloadFormat = freezed,Object? userProject = freezed,}) {
  return _then(_CreateNotificationOptions(
customAttributes: freezed == customAttributes ? _self._customAttributes : customAttributes // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,eventTypes: freezed == eventTypes ? _self._eventTypes : eventTypes // ignore: cast_nullable_to_non_nullable
as List<String>?,objectNamePrefix: freezed == objectNamePrefix ? _self.objectNamePrefix : objectNamePrefix // ignore: cast_nullable_to_non_nullable
as String?,payloadFormat: freezed == payloadFormat ? _self.payloadFormat : payloadFormat // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$BucketOptions {

/// Custom CRC32C generator for validation.
 Crc32Generator? get crc32cGenerator;/// The name of the Cloud KMS key that will be used to encrypt objects in this bucket.
 String? get kmsKeyName;/// Precondition options for the operation.
 PreconditionOptions? get preconditionOpts;/// The ID of the project which will be billed for the request.
 String? get userProject;/// The generation of the bucket to operate on.
 int? get generation;/// If `true`, operate on soft-deleted buckets.
 bool? get softDeleted;
/// Create a copy of BucketOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BucketOptionsCopyWith<BucketOptions> get copyWith => _$BucketOptionsCopyWithImpl<BucketOptions>(this as BucketOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BucketOptions&&(identical(other.crc32cGenerator, crc32cGenerator) || other.crc32cGenerator == crc32cGenerator)&&(identical(other.kmsKeyName, kmsKeyName) || other.kmsKeyName == kmsKeyName)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.softDeleted, softDeleted) || other.softDeleted == softDeleted));
}


@override
int get hashCode => Object.hash(runtimeType,crc32cGenerator,kmsKeyName,preconditionOpts,userProject,generation,softDeleted);

@override
String toString() {
  return 'BucketOptions(crc32cGenerator: $crc32cGenerator, kmsKeyName: $kmsKeyName, preconditionOpts: $preconditionOpts, userProject: $userProject, generation: $generation, softDeleted: $softDeleted)';
}


}

/// @nodoc
abstract mixin class $BucketOptionsCopyWith<$Res>  {
  factory $BucketOptionsCopyWith(BucketOptions value, $Res Function(BucketOptions) _then) = _$BucketOptionsCopyWithImpl;
@useResult
$Res call({
 Crc32Generator? crc32cGenerator, String? kmsKeyName, PreconditionOptions? preconditionOpts, String? userProject, int? generation, bool? softDeleted
});




}
/// @nodoc
class _$BucketOptionsCopyWithImpl<$Res>
    implements $BucketOptionsCopyWith<$Res> {
  _$BucketOptionsCopyWithImpl(this._self, this._then);

  final BucketOptions _self;
  final $Res Function(BucketOptions) _then;

/// Create a copy of BucketOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? crc32cGenerator = freezed,Object? kmsKeyName = freezed,Object? preconditionOpts = freezed,Object? userProject = freezed,Object? generation = freezed,Object? softDeleted = freezed,}) {
  return _then(_self.copyWith(
crc32cGenerator: freezed == crc32cGenerator ? _self.crc32cGenerator : crc32cGenerator // ignore: cast_nullable_to_non_nullable
as Crc32Generator?,kmsKeyName: freezed == kmsKeyName ? _self.kmsKeyName : kmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,softDeleted: freezed == softDeleted ? _self.softDeleted : softDeleted // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}



/// @nodoc


class _BucketOptions implements BucketOptions {
  const _BucketOptions({this.crc32cGenerator, this.kmsKeyName, this.preconditionOpts, this.userProject, this.generation, this.softDeleted});
  

/// Custom CRC32C generator for validation.
@override final  Crc32Generator? crc32cGenerator;
/// The name of the Cloud KMS key that will be used to encrypt objects in this bucket.
@override final  String? kmsKeyName;
/// Precondition options for the operation.
@override final  PreconditionOptions? preconditionOpts;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// The generation of the bucket to operate on.
@override final  int? generation;
/// If `true`, operate on soft-deleted buckets.
@override final  bool? softDeleted;

/// Create a copy of BucketOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BucketOptionsCopyWith<_BucketOptions> get copyWith => __$BucketOptionsCopyWithImpl<_BucketOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BucketOptions&&(identical(other.crc32cGenerator, crc32cGenerator) || other.crc32cGenerator == crc32cGenerator)&&(identical(other.kmsKeyName, kmsKeyName) || other.kmsKeyName == kmsKeyName)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.softDeleted, softDeleted) || other.softDeleted == softDeleted));
}


@override
int get hashCode => Object.hash(runtimeType,crc32cGenerator,kmsKeyName,preconditionOpts,userProject,generation,softDeleted);

@override
String toString() {
  return 'BucketOptions(crc32cGenerator: $crc32cGenerator, kmsKeyName: $kmsKeyName, preconditionOpts: $preconditionOpts, userProject: $userProject, generation: $generation, softDeleted: $softDeleted)';
}


}

/// @nodoc
abstract mixin class _$BucketOptionsCopyWith<$Res> implements $BucketOptionsCopyWith<$Res> {
  factory _$BucketOptionsCopyWith(_BucketOptions value, $Res Function(_BucketOptions) _then) = __$BucketOptionsCopyWithImpl;
@override @useResult
$Res call({
 Crc32Generator? crc32cGenerator, String? kmsKeyName, PreconditionOptions? preconditionOpts, String? userProject, int? generation, bool? softDeleted
});




}
/// @nodoc
class __$BucketOptionsCopyWithImpl<$Res>
    implements _$BucketOptionsCopyWith<$Res> {
  __$BucketOptionsCopyWithImpl(this._self, this._then);

  final _BucketOptions _self;
  final $Res Function(_BucketOptions) _then;

/// Create a copy of BucketOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? crc32cGenerator = freezed,Object? kmsKeyName = freezed,Object? preconditionOpts = freezed,Object? userProject = freezed,Object? generation = freezed,Object? softDeleted = freezed,}) {
  return _then(_BucketOptions(
crc32cGenerator: freezed == crc32cGenerator ? _self.crc32cGenerator : crc32cGenerator // ignore: cast_nullable_to_non_nullable
as Crc32Generator?,kmsKeyName: freezed == kmsKeyName ? _self.kmsKeyName : kmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,softDeleted: freezed == softDeleted ? _self.softDeleted : softDeleted // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$WatchAllOptions {

/// Delimiter to use for grouping object names.
 String? get delimiter;/// Maximum number of results to return.
 int? get maxResults;/// Token for the next page of results.
 String? get pageToken;/// Filter results to objects whose names begin with this prefix.
 String? get prefix;/// The set of properties to return in the response.
 String? get projection;/// The ID of the project which will be billed for the request.
 String? get userProject;/// If `true`, include object versions in the results.
 bool? get versions;
/// Create a copy of WatchAllOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WatchAllOptionsCopyWith<WatchAllOptions> get copyWith => _$WatchAllOptionsCopyWithImpl<WatchAllOptions>(this as WatchAllOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WatchAllOptions&&(identical(other.delimiter, delimiter) || other.delimiter == delimiter)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.versions, versions) || other.versions == versions));
}


@override
int get hashCode => Object.hash(runtimeType,delimiter,maxResults,pageToken,prefix,projection,userProject,versions);

@override
String toString() {
  return 'WatchAllOptions(delimiter: $delimiter, maxResults: $maxResults, pageToken: $pageToken, prefix: $prefix, projection: $projection, userProject: $userProject, versions: $versions)';
}


}

/// @nodoc
abstract mixin class $WatchAllOptionsCopyWith<$Res>  {
  factory $WatchAllOptionsCopyWith(WatchAllOptions value, $Res Function(WatchAllOptions) _then) = _$WatchAllOptionsCopyWithImpl;
@useResult
$Res call({
 String? delimiter, int? maxResults, String? pageToken, String? prefix, String? projection, String? userProject, bool? versions
});




}
/// @nodoc
class _$WatchAllOptionsCopyWithImpl<$Res>
    implements $WatchAllOptionsCopyWith<$Res> {
  _$WatchAllOptionsCopyWithImpl(this._self, this._then);

  final WatchAllOptions _self;
  final $Res Function(WatchAllOptions) _then;

/// Create a copy of WatchAllOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? delimiter = freezed,Object? maxResults = freezed,Object? pageToken = freezed,Object? prefix = freezed,Object? projection = freezed,Object? userProject = freezed,Object? versions = freezed,}) {
  return _then(_self.copyWith(
delimiter: freezed == delimiter ? _self.delimiter : delimiter // ignore: cast_nullable_to_non_nullable
as String?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,projection: freezed == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,versions: freezed == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}



/// @nodoc


class _WatchAllOptions implements WatchAllOptions {
  const _WatchAllOptions({this.delimiter, this.maxResults, this.pageToken, this.prefix, this.projection, this.userProject, this.versions});
  

/// Delimiter to use for grouping object names.
@override final  String? delimiter;
/// Maximum number of results to return.
@override final  int? maxResults;
/// Token for the next page of results.
@override final  String? pageToken;
/// Filter results to objects whose names begin with this prefix.
@override final  String? prefix;
/// The set of properties to return in the response.
@override final  String? projection;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// If `true`, include object versions in the results.
@override final  bool? versions;

/// Create a copy of WatchAllOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WatchAllOptionsCopyWith<_WatchAllOptions> get copyWith => __$WatchAllOptionsCopyWithImpl<_WatchAllOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WatchAllOptions&&(identical(other.delimiter, delimiter) || other.delimiter == delimiter)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.versions, versions) || other.versions == versions));
}


@override
int get hashCode => Object.hash(runtimeType,delimiter,maxResults,pageToken,prefix,projection,userProject,versions);

@override
String toString() {
  return 'WatchAllOptions(delimiter: $delimiter, maxResults: $maxResults, pageToken: $pageToken, prefix: $prefix, projection: $projection, userProject: $userProject, versions: $versions)';
}


}

/// @nodoc
abstract mixin class _$WatchAllOptionsCopyWith<$Res> implements $WatchAllOptionsCopyWith<$Res> {
  factory _$WatchAllOptionsCopyWith(_WatchAllOptions value, $Res Function(_WatchAllOptions) _then) = __$WatchAllOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? delimiter, int? maxResults, String? pageToken, String? prefix, String? projection, String? userProject, bool? versions
});




}
/// @nodoc
class __$WatchAllOptionsCopyWithImpl<$Res>
    implements _$WatchAllOptionsCopyWith<$Res> {
  __$WatchAllOptionsCopyWithImpl(this._self, this._then);

  final _WatchAllOptions _self;
  final $Res Function(_WatchAllOptions) _then;

/// Create a copy of WatchAllOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? delimiter = freezed,Object? maxResults = freezed,Object? pageToken = freezed,Object? prefix = freezed,Object? projection = freezed,Object? userProject = freezed,Object? versions = freezed,}) {
  return _then(_WatchAllOptions(
delimiter: freezed == delimiter ? _self.delimiter : delimiter // ignore: cast_nullable_to_non_nullable
as String?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,projection: freezed == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,versions: freezed == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$CreateChannelConfig {

/// The address where notifications should be sent.
 String get address;/// Delimiter to use for grouping object names.
 String? get delimiter;/// Maximum number of results to return.
 int? get maxResults;/// Token for the next page of results.
 String? get pageToken;/// Filter results to objects whose names begin with this prefix.
 String? get prefix;/// The set of properties to return in the response.
 String? get projection;/// The ID of the project which will be billed for the request.
 String? get userProject;/// If `true`, include object versions in the results.
 bool? get versions;
/// Create a copy of CreateChannelConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateChannelConfigCopyWith<CreateChannelConfig> get copyWith => _$CreateChannelConfigCopyWithImpl<CreateChannelConfig>(this as CreateChannelConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateChannelConfig&&(identical(other.address, address) || other.address == address)&&(identical(other.delimiter, delimiter) || other.delimiter == delimiter)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.versions, versions) || other.versions == versions));
}


@override
int get hashCode => Object.hash(runtimeType,address,delimiter,maxResults,pageToken,prefix,projection,userProject,versions);

@override
String toString() {
  return 'CreateChannelConfig(address: $address, delimiter: $delimiter, maxResults: $maxResults, pageToken: $pageToken, prefix: $prefix, projection: $projection, userProject: $userProject, versions: $versions)';
}


}

/// @nodoc
abstract mixin class $CreateChannelConfigCopyWith<$Res>  {
  factory $CreateChannelConfigCopyWith(CreateChannelConfig value, $Res Function(CreateChannelConfig) _then) = _$CreateChannelConfigCopyWithImpl;
@useResult
$Res call({
 String address, String? delimiter, int? maxResults, String? pageToken, String? prefix, String? projection, String? userProject, bool? versions
});




}
/// @nodoc
class _$CreateChannelConfigCopyWithImpl<$Res>
    implements $CreateChannelConfigCopyWith<$Res> {
  _$CreateChannelConfigCopyWithImpl(this._self, this._then);

  final CreateChannelConfig _self;
  final $Res Function(CreateChannelConfig) _then;

/// Create a copy of CreateChannelConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? delimiter = freezed,Object? maxResults = freezed,Object? pageToken = freezed,Object? prefix = freezed,Object? projection = freezed,Object? userProject = freezed,Object? versions = freezed,}) {
  return _then(_self.copyWith(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,delimiter: freezed == delimiter ? _self.delimiter : delimiter // ignore: cast_nullable_to_non_nullable
as String?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,projection: freezed == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,versions: freezed == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}



/// @nodoc


class _CreateChannelConfig implements CreateChannelConfig {
  const _CreateChannelConfig({required this.address, this.delimiter, this.maxResults, this.pageToken, this.prefix, this.projection, this.userProject, this.versions});
  

/// The address where notifications should be sent.
@override final  String address;
/// Delimiter to use for grouping object names.
@override final  String? delimiter;
/// Maximum number of results to return.
@override final  int? maxResults;
/// Token for the next page of results.
@override final  String? pageToken;
/// Filter results to objects whose names begin with this prefix.
@override final  String? prefix;
/// The set of properties to return in the response.
@override final  String? projection;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// If `true`, include object versions in the results.
@override final  bool? versions;

/// Create a copy of CreateChannelConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateChannelConfigCopyWith<_CreateChannelConfig> get copyWith => __$CreateChannelConfigCopyWithImpl<_CreateChannelConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateChannelConfig&&(identical(other.address, address) || other.address == address)&&(identical(other.delimiter, delimiter) || other.delimiter == delimiter)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.versions, versions) || other.versions == versions));
}


@override
int get hashCode => Object.hash(runtimeType,address,delimiter,maxResults,pageToken,prefix,projection,userProject,versions);

@override
String toString() {
  return 'CreateChannelConfig(address: $address, delimiter: $delimiter, maxResults: $maxResults, pageToken: $pageToken, prefix: $prefix, projection: $projection, userProject: $userProject, versions: $versions)';
}


}

/// @nodoc
abstract mixin class _$CreateChannelConfigCopyWith<$Res> implements $CreateChannelConfigCopyWith<$Res> {
  factory _$CreateChannelConfigCopyWith(_CreateChannelConfig value, $Res Function(_CreateChannelConfig) _then) = __$CreateChannelConfigCopyWithImpl;
@override @useResult
$Res call({
 String address, String? delimiter, int? maxResults, String? pageToken, String? prefix, String? projection, String? userProject, bool? versions
});




}
/// @nodoc
class __$CreateChannelConfigCopyWithImpl<$Res>
    implements _$CreateChannelConfigCopyWith<$Res> {
  __$CreateChannelConfigCopyWithImpl(this._self, this._then);

  final _CreateChannelConfig _self;
  final $Res Function(_CreateChannelConfig) _then;

/// Create a copy of CreateChannelConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? delimiter = freezed,Object? maxResults = freezed,Object? pageToken = freezed,Object? prefix = freezed,Object? projection = freezed,Object? userProject = freezed,Object? versions = freezed,}) {
  return _then(_CreateChannelConfig(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,delimiter: freezed == delimiter ? _self.delimiter : delimiter // ignore: cast_nullable_to_non_nullable
as String?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,projection: freezed == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,versions: freezed == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$CreateChannelOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of CreateChannelOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateChannelOptionsCopyWith<CreateChannelOptions> get copyWith => _$CreateChannelOptionsCopyWithImpl<CreateChannelOptions>(this as CreateChannelOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateChannelOptions&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,userProject);

@override
String toString() {
  return 'CreateChannelOptions(userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $CreateChannelOptionsCopyWith<$Res>  {
  factory $CreateChannelOptionsCopyWith(CreateChannelOptions value, $Res Function(CreateChannelOptions) _then) = _$CreateChannelOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject
});




}
/// @nodoc
class _$CreateChannelOptionsCopyWithImpl<$Res>
    implements $CreateChannelOptionsCopyWith<$Res> {
  _$CreateChannelOptionsCopyWithImpl(this._self, this._then);

  final CreateChannelOptions _self;
  final $Res Function(CreateChannelOptions) _then;

/// Create a copy of CreateChannelOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _CreateChannelOptions implements CreateChannelOptions {
  const _CreateChannelOptions({this.userProject});
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of CreateChannelOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateChannelOptionsCopyWith<_CreateChannelOptions> get copyWith => __$CreateChannelOptionsCopyWithImpl<_CreateChannelOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateChannelOptions&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,userProject);

@override
String toString() {
  return 'CreateChannelOptions(userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$CreateChannelOptionsCopyWith<$Res> implements $CreateChannelOptionsCopyWith<$Res> {
  factory _$CreateChannelOptionsCopyWith(_CreateChannelOptions value, $Res Function(_CreateChannelOptions) _then) = __$CreateChannelOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject
});




}
/// @nodoc
class __$CreateChannelOptionsCopyWithImpl<$Res>
    implements _$CreateChannelOptionsCopyWith<$Res> {
  __$CreateChannelOptionsCopyWithImpl(this._self, this._then);

  final _CreateChannelOptions _self;
  final $Res Function(_CreateChannelOptions) _then;

/// Create a copy of CreateChannelOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,}) {
  return _then(_CreateChannelOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$FileOptions {

/// Custom CRC32C generator for validation.
 Crc32Generator? get crc32cGenerator;/// Customer-supplied encryption key.
 EncryptionKey? get encryptionKey;/// The generation of the file to operate on.
 int? get generation;/// Token for restoring a soft-deleted file.
 String? get restoreToken;/// The name of the Cloud KMS key that will be used to encrypt the file.
 String? get kmsKeyName;/// Precondition options for the operation.
 PreconditionOptions? get preconditionOpts;/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of FileOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileOptionsCopyWith<FileOptions> get copyWith => _$FileOptionsCopyWithImpl<FileOptions>(this as FileOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileOptions&&(identical(other.crc32cGenerator, crc32cGenerator) || other.crc32cGenerator == crc32cGenerator)&&(identical(other.encryptionKey, encryptionKey) || other.encryptionKey == encryptionKey)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.restoreToken, restoreToken) || other.restoreToken == restoreToken)&&(identical(other.kmsKeyName, kmsKeyName) || other.kmsKeyName == kmsKeyName)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,crc32cGenerator,encryptionKey,generation,restoreToken,kmsKeyName,preconditionOpts,userProject);

@override
String toString() {
  return 'FileOptions(crc32cGenerator: $crc32cGenerator, encryptionKey: $encryptionKey, generation: $generation, restoreToken: $restoreToken, kmsKeyName: $kmsKeyName, preconditionOpts: $preconditionOpts, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $FileOptionsCopyWith<$Res>  {
  factory $FileOptionsCopyWith(FileOptions value, $Res Function(FileOptions) _then) = _$FileOptionsCopyWithImpl;
@useResult
$Res call({
 Crc32Generator? crc32cGenerator, EncryptionKey? encryptionKey, int? generation, String? restoreToken, String? kmsKeyName, PreconditionOptions? preconditionOpts, String? userProject
});


$EncryptionKeyCopyWith<$Res>? get encryptionKey;

}
/// @nodoc
class _$FileOptionsCopyWithImpl<$Res>
    implements $FileOptionsCopyWith<$Res> {
  _$FileOptionsCopyWithImpl(this._self, this._then);

  final FileOptions _self;
  final $Res Function(FileOptions) _then;

/// Create a copy of FileOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? crc32cGenerator = freezed,Object? encryptionKey = freezed,Object? generation = freezed,Object? restoreToken = freezed,Object? kmsKeyName = freezed,Object? preconditionOpts = freezed,Object? userProject = freezed,}) {
  return _then(_self.copyWith(
crc32cGenerator: freezed == crc32cGenerator ? _self.crc32cGenerator : crc32cGenerator // ignore: cast_nullable_to_non_nullable
as Crc32Generator?,encryptionKey: freezed == encryptionKey ? _self.encryptionKey : encryptionKey // ignore: cast_nullable_to_non_nullable
as EncryptionKey?,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,restoreToken: freezed == restoreToken ? _self.restoreToken : restoreToken // ignore: cast_nullable_to_non_nullable
as String?,kmsKeyName: freezed == kmsKeyName ? _self.kmsKeyName : kmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of FileOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncryptionKeyCopyWith<$Res>? get encryptionKey {
    if (_self.encryptionKey == null) {
    return null;
  }

  return $EncryptionKeyCopyWith<$Res>(_self.encryptionKey!, (value) {
    return _then(_self.copyWith(encryptionKey: value));
  });
}
}



/// @nodoc


class _FileOptions implements FileOptions {
  const _FileOptions({this.crc32cGenerator, this.encryptionKey, this.generation, this.restoreToken, this.kmsKeyName, this.preconditionOpts, this.userProject});
  

/// Custom CRC32C generator for validation.
@override final  Crc32Generator? crc32cGenerator;
/// Customer-supplied encryption key.
@override final  EncryptionKey? encryptionKey;
/// The generation of the file to operate on.
@override final  int? generation;
/// Token for restoring a soft-deleted file.
@override final  String? restoreToken;
/// The name of the Cloud KMS key that will be used to encrypt the file.
@override final  String? kmsKeyName;
/// Precondition options for the operation.
@override final  PreconditionOptions? preconditionOpts;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of FileOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileOptionsCopyWith<_FileOptions> get copyWith => __$FileOptionsCopyWithImpl<_FileOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileOptions&&(identical(other.crc32cGenerator, crc32cGenerator) || other.crc32cGenerator == crc32cGenerator)&&(identical(other.encryptionKey, encryptionKey) || other.encryptionKey == encryptionKey)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.restoreToken, restoreToken) || other.restoreToken == restoreToken)&&(identical(other.kmsKeyName, kmsKeyName) || other.kmsKeyName == kmsKeyName)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,crc32cGenerator,encryptionKey,generation,restoreToken,kmsKeyName,preconditionOpts,userProject);

@override
String toString() {
  return 'FileOptions(crc32cGenerator: $crc32cGenerator, encryptionKey: $encryptionKey, generation: $generation, restoreToken: $restoreToken, kmsKeyName: $kmsKeyName, preconditionOpts: $preconditionOpts, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$FileOptionsCopyWith<$Res> implements $FileOptionsCopyWith<$Res> {
  factory _$FileOptionsCopyWith(_FileOptions value, $Res Function(_FileOptions) _then) = __$FileOptionsCopyWithImpl;
@override @useResult
$Res call({
 Crc32Generator? crc32cGenerator, EncryptionKey? encryptionKey, int? generation, String? restoreToken, String? kmsKeyName, PreconditionOptions? preconditionOpts, String? userProject
});


@override $EncryptionKeyCopyWith<$Res>? get encryptionKey;

}
/// @nodoc
class __$FileOptionsCopyWithImpl<$Res>
    implements _$FileOptionsCopyWith<$Res> {
  __$FileOptionsCopyWithImpl(this._self, this._then);

  final _FileOptions _self;
  final $Res Function(_FileOptions) _then;

/// Create a copy of FileOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? crc32cGenerator = freezed,Object? encryptionKey = freezed,Object? generation = freezed,Object? restoreToken = freezed,Object? kmsKeyName = freezed,Object? preconditionOpts = freezed,Object? userProject = freezed,}) {
  return _then(_FileOptions(
crc32cGenerator: freezed == crc32cGenerator ? _self.crc32cGenerator : crc32cGenerator // ignore: cast_nullable_to_non_nullable
as Crc32Generator?,encryptionKey: freezed == encryptionKey ? _self.encryptionKey : encryptionKey // ignore: cast_nullable_to_non_nullable
as EncryptionKey?,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,restoreToken: freezed == restoreToken ? _self.restoreToken : restoreToken // ignore: cast_nullable_to_non_nullable
as String?,kmsKeyName: freezed == kmsKeyName ? _self.kmsKeyName : kmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of FileOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncryptionKeyCopyWith<$Res>? get encryptionKey {
    if (_self.encryptionKey == null) {
    return null;
  }

  return $EncryptionKeyCopyWith<$Res>(_self.encryptionKey!, (value) {
    return _then(_self.copyWith(encryptionKey: value));
  });
}
}

/// @nodoc
mixin _$GetFilesOptions {

/// Automatically paginate through all results. Defaults to `true`.
 bool? get autoPaginate;/// Delimiter to use for grouping object names.
 String? get delimiter;/// End offset for listing objects.
 String? get endOffset;/// If `true`, include folders as prefixes in the results.
 bool? get includeFoldersAsPrefixes;/// If `true`, include trailing delimiter in prefix results.
 bool? get includeTrailingDelimiter;/// Filter results to objects whose names begin with this prefix.
 String? get prefix;/// Glob pattern to match object names.
 String? get matchGlob;/// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
 int? get maxApiCalls;/// Maximum number of results to return per page.
 int? get maxResults;/// Token for the next page of results.
 String? get pageToken;/// If `true`, include soft-deleted objects in the results.
 bool? get softDeleted;/// Start offset for listing objects.
 String? get startOffset;/// The ID of the project which will be billed for the request.
 String? get userProject;/// If `true`, include object versions in the results.
 bool? get versions;/// Comma-separated list of fields to return in the response.
 String? get fields;/// Only perform the operation if the object's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the object's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the object's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the object's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of GetFilesOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetFilesOptionsCopyWith<GetFilesOptions> get copyWith => _$GetFilesOptionsCopyWithImpl<GetFilesOptions>(this as GetFilesOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetFilesOptions&&(identical(other.autoPaginate, autoPaginate) || other.autoPaginate == autoPaginate)&&(identical(other.delimiter, delimiter) || other.delimiter == delimiter)&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset)&&(identical(other.includeFoldersAsPrefixes, includeFoldersAsPrefixes) || other.includeFoldersAsPrefixes == includeFoldersAsPrefixes)&&(identical(other.includeTrailingDelimiter, includeTrailingDelimiter) || other.includeTrailingDelimiter == includeTrailingDelimiter)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.matchGlob, matchGlob) || other.matchGlob == matchGlob)&&(identical(other.maxApiCalls, maxApiCalls) || other.maxApiCalls == maxApiCalls)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken)&&(identical(other.softDeleted, softDeleted) || other.softDeleted == softDeleted)&&(identical(other.startOffset, startOffset) || other.startOffset == startOffset)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.versions, versions) || other.versions == versions)&&(identical(other.fields, fields) || other.fields == fields)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hashAll([runtimeType,autoPaginate,delimiter,endOffset,includeFoldersAsPrefixes,includeTrailingDelimiter,prefix,matchGlob,maxApiCalls,maxResults,pageToken,softDeleted,startOffset,userProject,versions,fields,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch]);

@override
String toString() {
  return 'GetFilesOptions(autoPaginate: $autoPaginate, delimiter: $delimiter, endOffset: $endOffset, includeFoldersAsPrefixes: $includeFoldersAsPrefixes, includeTrailingDelimiter: $includeTrailingDelimiter, prefix: $prefix, matchGlob: $matchGlob, maxApiCalls: $maxApiCalls, maxResults: $maxResults, pageToken: $pageToken, softDeleted: $softDeleted, startOffset: $startOffset, userProject: $userProject, versions: $versions, fields: $fields, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $GetFilesOptionsCopyWith<$Res>  {
  factory $GetFilesOptionsCopyWith(GetFilesOptions value, $Res Function(GetFilesOptions) _then) = _$GetFilesOptionsCopyWithImpl;
@useResult
$Res call({
 bool? autoPaginate, String? delimiter, String? endOffset, bool? includeFoldersAsPrefixes, bool? includeTrailingDelimiter, String? prefix, String? matchGlob, int? maxApiCalls, int? maxResults, String? pageToken, bool? softDeleted, String? startOffset, String? userProject, bool? versions, String? fields, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$GetFilesOptionsCopyWithImpl<$Res>
    implements $GetFilesOptionsCopyWith<$Res> {
  _$GetFilesOptionsCopyWithImpl(this._self, this._then);

  final GetFilesOptions _self;
  final $Res Function(GetFilesOptions) _then;

/// Create a copy of GetFilesOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? autoPaginate = freezed,Object? delimiter = freezed,Object? endOffset = freezed,Object? includeFoldersAsPrefixes = freezed,Object? includeTrailingDelimiter = freezed,Object? prefix = freezed,Object? matchGlob = freezed,Object? maxApiCalls = freezed,Object? maxResults = freezed,Object? pageToken = freezed,Object? softDeleted = freezed,Object? startOffset = freezed,Object? userProject = freezed,Object? versions = freezed,Object? fields = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
autoPaginate: freezed == autoPaginate ? _self.autoPaginate : autoPaginate // ignore: cast_nullable_to_non_nullable
as bool?,delimiter: freezed == delimiter ? _self.delimiter : delimiter // ignore: cast_nullable_to_non_nullable
as String?,endOffset: freezed == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as String?,includeFoldersAsPrefixes: freezed == includeFoldersAsPrefixes ? _self.includeFoldersAsPrefixes : includeFoldersAsPrefixes // ignore: cast_nullable_to_non_nullable
as bool?,includeTrailingDelimiter: freezed == includeTrailingDelimiter ? _self.includeTrailingDelimiter : includeTrailingDelimiter // ignore: cast_nullable_to_non_nullable
as bool?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,matchGlob: freezed == matchGlob ? _self.matchGlob : matchGlob // ignore: cast_nullable_to_non_nullable
as String?,maxApiCalls: freezed == maxApiCalls ? _self.maxApiCalls : maxApiCalls // ignore: cast_nullable_to_non_nullable
as int?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,softDeleted: freezed == softDeleted ? _self.softDeleted : softDeleted // ignore: cast_nullable_to_non_nullable
as bool?,startOffset: freezed == startOffset ? _self.startOffset : startOffset // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,versions: freezed == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as bool?,fields: freezed == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _GetFilesOptions extends GetFilesOptions {
  const _GetFilesOptions({this.autoPaginate = true, this.delimiter, this.endOffset, this.includeFoldersAsPrefixes, this.includeTrailingDelimiter, this.prefix, this.matchGlob, this.maxApiCalls, this.maxResults, this.pageToken, this.softDeleted, this.startOffset, this.userProject, this.versions, this.fields, final  int? ifGenerationMatch, final  int? ifGenerationNotMatch, final  int? ifMetagenerationMatch, final  int? ifMetagenerationNotMatch}): super._(ifGenerationMatch: ifGenerationMatch, ifGenerationNotMatch: ifGenerationNotMatch, ifMetagenerationMatch: ifMetagenerationMatch, ifMetagenerationNotMatch: ifMetagenerationNotMatch);
  

/// Automatically paginate through all results. Defaults to `true`.
@override@JsonKey() final  bool? autoPaginate;
/// Delimiter to use for grouping object names.
@override final  String? delimiter;
/// End offset for listing objects.
@override final  String? endOffset;
/// If `true`, include folders as prefixes in the results.
@override final  bool? includeFoldersAsPrefixes;
/// If `true`, include trailing delimiter in prefix results.
@override final  bool? includeTrailingDelimiter;
/// Filter results to objects whose names begin with this prefix.
@override final  String? prefix;
/// Glob pattern to match object names.
@override final  String? matchGlob;
/// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
@override final  int? maxApiCalls;
/// Maximum number of results to return per page.
@override final  int? maxResults;
/// Token for the next page of results.
@override final  String? pageToken;
/// If `true`, include soft-deleted objects in the results.
@override final  bool? softDeleted;
/// Start offset for listing objects.
@override final  String? startOffset;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// If `true`, include object versions in the results.
@override final  bool? versions;
/// Comma-separated list of fields to return in the response.
@override final  String? fields;

/// Create a copy of GetFilesOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetFilesOptionsCopyWith<_GetFilesOptions> get copyWith => __$GetFilesOptionsCopyWithImpl<_GetFilesOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetFilesOptions&&(identical(other.autoPaginate, autoPaginate) || other.autoPaginate == autoPaginate)&&(identical(other.delimiter, delimiter) || other.delimiter == delimiter)&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset)&&(identical(other.includeFoldersAsPrefixes, includeFoldersAsPrefixes) || other.includeFoldersAsPrefixes == includeFoldersAsPrefixes)&&(identical(other.includeTrailingDelimiter, includeTrailingDelimiter) || other.includeTrailingDelimiter == includeTrailingDelimiter)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.matchGlob, matchGlob) || other.matchGlob == matchGlob)&&(identical(other.maxApiCalls, maxApiCalls) || other.maxApiCalls == maxApiCalls)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken)&&(identical(other.softDeleted, softDeleted) || other.softDeleted == softDeleted)&&(identical(other.startOffset, startOffset) || other.startOffset == startOffset)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.versions, versions) || other.versions == versions)&&(identical(other.fields, fields) || other.fields == fields)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hashAll([runtimeType,autoPaginate,delimiter,endOffset,includeFoldersAsPrefixes,includeTrailingDelimiter,prefix,matchGlob,maxApiCalls,maxResults,pageToken,softDeleted,startOffset,userProject,versions,fields,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch]);

@override
String toString() {
  return 'GetFilesOptions(autoPaginate: $autoPaginate, delimiter: $delimiter, endOffset: $endOffset, includeFoldersAsPrefixes: $includeFoldersAsPrefixes, includeTrailingDelimiter: $includeTrailingDelimiter, prefix: $prefix, matchGlob: $matchGlob, maxApiCalls: $maxApiCalls, maxResults: $maxResults, pageToken: $pageToken, softDeleted: $softDeleted, startOffset: $startOffset, userProject: $userProject, versions: $versions, fields: $fields, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$GetFilesOptionsCopyWith<$Res> implements $GetFilesOptionsCopyWith<$Res> {
  factory _$GetFilesOptionsCopyWith(_GetFilesOptions value, $Res Function(_GetFilesOptions) _then) = __$GetFilesOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool? autoPaginate, String? delimiter, String? endOffset, bool? includeFoldersAsPrefixes, bool? includeTrailingDelimiter, String? prefix, String? matchGlob, int? maxApiCalls, int? maxResults, String? pageToken, bool? softDeleted, String? startOffset, String? userProject, bool? versions, String? fields, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$GetFilesOptionsCopyWithImpl<$Res>
    implements _$GetFilesOptionsCopyWith<$Res> {
  __$GetFilesOptionsCopyWithImpl(this._self, this._then);

  final _GetFilesOptions _self;
  final $Res Function(_GetFilesOptions) _then;

/// Create a copy of GetFilesOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoPaginate = freezed,Object? delimiter = freezed,Object? endOffset = freezed,Object? includeFoldersAsPrefixes = freezed,Object? includeTrailingDelimiter = freezed,Object? prefix = freezed,Object? matchGlob = freezed,Object? maxApiCalls = freezed,Object? maxResults = freezed,Object? pageToken = freezed,Object? softDeleted = freezed,Object? startOffset = freezed,Object? userProject = freezed,Object? versions = freezed,Object? fields = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_GetFilesOptions(
autoPaginate: freezed == autoPaginate ? _self.autoPaginate : autoPaginate // ignore: cast_nullable_to_non_nullable
as bool?,delimiter: freezed == delimiter ? _self.delimiter : delimiter // ignore: cast_nullable_to_non_nullable
as String?,endOffset: freezed == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as String?,includeFoldersAsPrefixes: freezed == includeFoldersAsPrefixes ? _self.includeFoldersAsPrefixes : includeFoldersAsPrefixes // ignore: cast_nullable_to_non_nullable
as bool?,includeTrailingDelimiter: freezed == includeTrailingDelimiter ? _self.includeTrailingDelimiter : includeTrailingDelimiter // ignore: cast_nullable_to_non_nullable
as bool?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,matchGlob: freezed == matchGlob ? _self.matchGlob : matchGlob // ignore: cast_nullable_to_non_nullable
as String?,maxApiCalls: freezed == maxApiCalls ? _self.maxApiCalls : maxApiCalls // ignore: cast_nullable_to_non_nullable
as int?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,softDeleted: freezed == softDeleted ? _self.softDeleted : softDeleted // ignore: cast_nullable_to_non_nullable
as bool?,startOffset: freezed == startOffset ? _self.startOffset : startOffset // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,versions: freezed == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as bool?,fields: freezed == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$DeleteFileOptions {

/// If `true`, force deletion even if there are errors.
 bool? get force;/// Automatically paginate through all results. Defaults to `true`.
 bool? get autoPaginate;/// Delimiter to use for grouping object names.
 String? get delimiter;/// End offset for listing objects.
 String? get endOffset;/// If `true`, include folders as prefixes in the results.
 bool? get includeFoldersAsPrefixes;/// If `true`, include trailing delimiter in prefix results.
 bool? get includeTrailingDelimiter;/// Filter results to objects whose names begin with this prefix.
 String? get prefix;/// Glob pattern to match object names.
 String? get matchGlob;/// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
 int? get maxApiCalls;/// Maximum number of results to return per page.
 int? get maxResults;/// Token for the next page of results.
 String? get pageToken;/// If `true`, include soft-deleted objects in the results.
 bool? get softDeleted;/// Start offset for listing objects.
 String? get startOffset;/// The ID of the project which will be billed for the request.
 String? get userProject;/// If `true`, include object versions in the results.
 bool? get versions;/// Comma-separated list of fields to return in the response.
 String? get fields;/// Only perform the operation if the object's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the object's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the object's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the object's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of DeleteFileOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteFileOptionsCopyWith<DeleteFileOptions> get copyWith => _$DeleteFileOptionsCopyWithImpl<DeleteFileOptions>(this as DeleteFileOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteFileOptions&&(identical(other.force, force) || other.force == force)&&(identical(other.autoPaginate, autoPaginate) || other.autoPaginate == autoPaginate)&&(identical(other.delimiter, delimiter) || other.delimiter == delimiter)&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset)&&(identical(other.includeFoldersAsPrefixes, includeFoldersAsPrefixes) || other.includeFoldersAsPrefixes == includeFoldersAsPrefixes)&&(identical(other.includeTrailingDelimiter, includeTrailingDelimiter) || other.includeTrailingDelimiter == includeTrailingDelimiter)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.matchGlob, matchGlob) || other.matchGlob == matchGlob)&&(identical(other.maxApiCalls, maxApiCalls) || other.maxApiCalls == maxApiCalls)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken)&&(identical(other.softDeleted, softDeleted) || other.softDeleted == softDeleted)&&(identical(other.startOffset, startOffset) || other.startOffset == startOffset)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.versions, versions) || other.versions == versions)&&(identical(other.fields, fields) || other.fields == fields)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hashAll([runtimeType,force,autoPaginate,delimiter,endOffset,includeFoldersAsPrefixes,includeTrailingDelimiter,prefix,matchGlob,maxApiCalls,maxResults,pageToken,softDeleted,startOffset,userProject,versions,fields,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch]);

@override
String toString() {
  return 'DeleteFileOptions(force: $force, autoPaginate: $autoPaginate, delimiter: $delimiter, endOffset: $endOffset, includeFoldersAsPrefixes: $includeFoldersAsPrefixes, includeTrailingDelimiter: $includeTrailingDelimiter, prefix: $prefix, matchGlob: $matchGlob, maxApiCalls: $maxApiCalls, maxResults: $maxResults, pageToken: $pageToken, softDeleted: $softDeleted, startOffset: $startOffset, userProject: $userProject, versions: $versions, fields: $fields, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $DeleteFileOptionsCopyWith<$Res> implements $GetFilesOptionsCopyWith<$Res> {
  factory $DeleteFileOptionsCopyWith(DeleteFileOptions value, $Res Function(DeleteFileOptions) _then) = _$DeleteFileOptionsCopyWithImpl;
@useResult
$Res call({
 bool? force, bool? autoPaginate, String? delimiter, String? endOffset, bool? includeFoldersAsPrefixes, bool? includeTrailingDelimiter, String? prefix, String? matchGlob, int? maxApiCalls, int? maxResults, String? pageToken, bool? softDeleted, String? startOffset, String? userProject, bool? versions, String? fields, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$DeleteFileOptionsCopyWithImpl<$Res>
    implements $DeleteFileOptionsCopyWith<$Res> {
  _$DeleteFileOptionsCopyWithImpl(this._self, this._then);

  final DeleteFileOptions _self;
  final $Res Function(DeleteFileOptions) _then;

/// Create a copy of DeleteFileOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? force = freezed,Object? autoPaginate = freezed,Object? delimiter = freezed,Object? endOffset = freezed,Object? includeFoldersAsPrefixes = freezed,Object? includeTrailingDelimiter = freezed,Object? prefix = freezed,Object? matchGlob = freezed,Object? maxApiCalls = freezed,Object? maxResults = freezed,Object? pageToken = freezed,Object? softDeleted = freezed,Object? startOffset = freezed,Object? userProject = freezed,Object? versions = freezed,Object? fields = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool?,autoPaginate: freezed == autoPaginate ? _self.autoPaginate : autoPaginate // ignore: cast_nullable_to_non_nullable
as bool?,delimiter: freezed == delimiter ? _self.delimiter : delimiter // ignore: cast_nullable_to_non_nullable
as String?,endOffset: freezed == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as String?,includeFoldersAsPrefixes: freezed == includeFoldersAsPrefixes ? _self.includeFoldersAsPrefixes : includeFoldersAsPrefixes // ignore: cast_nullable_to_non_nullable
as bool?,includeTrailingDelimiter: freezed == includeTrailingDelimiter ? _self.includeTrailingDelimiter : includeTrailingDelimiter // ignore: cast_nullable_to_non_nullable
as bool?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,matchGlob: freezed == matchGlob ? _self.matchGlob : matchGlob // ignore: cast_nullable_to_non_nullable
as String?,maxApiCalls: freezed == maxApiCalls ? _self.maxApiCalls : maxApiCalls // ignore: cast_nullable_to_non_nullable
as int?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,softDeleted: freezed == softDeleted ? _self.softDeleted : softDeleted // ignore: cast_nullable_to_non_nullable
as bool?,startOffset: freezed == startOffset ? _self.startOffset : startOffset // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,versions: freezed == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as bool?,fields: freezed == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _DeleteFileOptions extends DeleteFileOptions {
  const _DeleteFileOptions({this.force, this.autoPaginate = true, this.delimiter, this.endOffset, this.includeFoldersAsPrefixes, this.includeTrailingDelimiter, this.prefix, this.matchGlob, this.maxApiCalls, this.maxResults, this.pageToken, this.softDeleted, this.startOffset, this.userProject, this.versions, this.fields, final  int? ifGenerationMatch, final  int? ifGenerationNotMatch, final  int? ifMetagenerationMatch, final  int? ifMetagenerationNotMatch}): super._(ifGenerationMatch: ifGenerationMatch, ifGenerationNotMatch: ifGenerationNotMatch, ifMetagenerationMatch: ifMetagenerationMatch, ifMetagenerationNotMatch: ifMetagenerationNotMatch);
  

/// If `true`, force deletion even if there are errors.
@override final  bool? force;
/// Automatically paginate through all results. Defaults to `true`.
@override@JsonKey() final  bool? autoPaginate;
/// Delimiter to use for grouping object names.
@override final  String? delimiter;
/// End offset for listing objects.
@override final  String? endOffset;
/// If `true`, include folders as prefixes in the results.
@override final  bool? includeFoldersAsPrefixes;
/// If `true`, include trailing delimiter in prefix results.
@override final  bool? includeTrailingDelimiter;
/// Filter results to objects whose names begin with this prefix.
@override final  String? prefix;
/// Glob pattern to match object names.
@override final  String? matchGlob;
/// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
@override final  int? maxApiCalls;
/// Maximum number of results to return per page.
@override final  int? maxResults;
/// Token for the next page of results.
@override final  String? pageToken;
/// If `true`, include soft-deleted objects in the results.
@override final  bool? softDeleted;
/// Start offset for listing objects.
@override final  String? startOffset;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// If `true`, include object versions in the results.
@override final  bool? versions;
/// Comma-separated list of fields to return in the response.
@override final  String? fields;

/// Create a copy of DeleteFileOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteFileOptionsCopyWith<_DeleteFileOptions> get copyWith => __$DeleteFileOptionsCopyWithImpl<_DeleteFileOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteFileOptions&&(identical(other.force, force) || other.force == force)&&(identical(other.autoPaginate, autoPaginate) || other.autoPaginate == autoPaginate)&&(identical(other.delimiter, delimiter) || other.delimiter == delimiter)&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset)&&(identical(other.includeFoldersAsPrefixes, includeFoldersAsPrefixes) || other.includeFoldersAsPrefixes == includeFoldersAsPrefixes)&&(identical(other.includeTrailingDelimiter, includeTrailingDelimiter) || other.includeTrailingDelimiter == includeTrailingDelimiter)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.matchGlob, matchGlob) || other.matchGlob == matchGlob)&&(identical(other.maxApiCalls, maxApiCalls) || other.maxApiCalls == maxApiCalls)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken)&&(identical(other.softDeleted, softDeleted) || other.softDeleted == softDeleted)&&(identical(other.startOffset, startOffset) || other.startOffset == startOffset)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.versions, versions) || other.versions == versions)&&(identical(other.fields, fields) || other.fields == fields)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hashAll([runtimeType,force,autoPaginate,delimiter,endOffset,includeFoldersAsPrefixes,includeTrailingDelimiter,prefix,matchGlob,maxApiCalls,maxResults,pageToken,softDeleted,startOffset,userProject,versions,fields,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch]);

@override
String toString() {
  return 'DeleteFileOptions(force: $force, autoPaginate: $autoPaginate, delimiter: $delimiter, endOffset: $endOffset, includeFoldersAsPrefixes: $includeFoldersAsPrefixes, includeTrailingDelimiter: $includeTrailingDelimiter, prefix: $prefix, matchGlob: $matchGlob, maxApiCalls: $maxApiCalls, maxResults: $maxResults, pageToken: $pageToken, softDeleted: $softDeleted, startOffset: $startOffset, userProject: $userProject, versions: $versions, fields: $fields, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$DeleteFileOptionsCopyWith<$Res> implements $DeleteFileOptionsCopyWith<$Res> {
  factory _$DeleteFileOptionsCopyWith(_DeleteFileOptions value, $Res Function(_DeleteFileOptions) _then) = __$DeleteFileOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool? force, bool? autoPaginate, String? delimiter, String? endOffset, bool? includeFoldersAsPrefixes, bool? includeTrailingDelimiter, String? prefix, String? matchGlob, int? maxApiCalls, int? maxResults, String? pageToken, bool? softDeleted, String? startOffset, String? userProject, bool? versions, String? fields, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$DeleteFileOptionsCopyWithImpl<$Res>
    implements _$DeleteFileOptionsCopyWith<$Res> {
  __$DeleteFileOptionsCopyWithImpl(this._self, this._then);

  final _DeleteFileOptions _self;
  final $Res Function(_DeleteFileOptions) _then;

/// Create a copy of DeleteFileOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? force = freezed,Object? autoPaginate = freezed,Object? delimiter = freezed,Object? endOffset = freezed,Object? includeFoldersAsPrefixes = freezed,Object? includeTrailingDelimiter = freezed,Object? prefix = freezed,Object? matchGlob = freezed,Object? maxApiCalls = freezed,Object? maxResults = freezed,Object? pageToken = freezed,Object? softDeleted = freezed,Object? startOffset = freezed,Object? userProject = freezed,Object? versions = freezed,Object? fields = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_DeleteFileOptions(
force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool?,autoPaginate: freezed == autoPaginate ? _self.autoPaginate : autoPaginate // ignore: cast_nullable_to_non_nullable
as bool?,delimiter: freezed == delimiter ? _self.delimiter : delimiter // ignore: cast_nullable_to_non_nullable
as String?,endOffset: freezed == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as String?,includeFoldersAsPrefixes: freezed == includeFoldersAsPrefixes ? _self.includeFoldersAsPrefixes : includeFoldersAsPrefixes // ignore: cast_nullable_to_non_nullable
as bool?,includeTrailingDelimiter: freezed == includeTrailingDelimiter ? _self.includeTrailingDelimiter : includeTrailingDelimiter // ignore: cast_nullable_to_non_nullable
as bool?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,matchGlob: freezed == matchGlob ? _self.matchGlob : matchGlob // ignore: cast_nullable_to_non_nullable
as String?,maxApiCalls: freezed == maxApiCalls ? _self.maxApiCalls : maxApiCalls // ignore: cast_nullable_to_non_nullable
as int?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,softDeleted: freezed == softDeleted ? _self.softDeleted : softDeleted // ignore: cast_nullable_to_non_nullable
as bool?,startOffset: freezed == startOffset ? _self.startOffset : startOffset // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,versions: freezed == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as bool?,fields: freezed == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$GetFileMetadataOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of GetFileMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetFileMetadataOptionsCopyWith<GetFileMetadataOptions> get copyWith => _$GetFileMetadataOptionsCopyWithImpl<GetFileMetadataOptions>(this as GetFileMetadataOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetFileMetadataOptions&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,userProject);

@override
String toString() {
  return 'GetFileMetadataOptions(userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $GetFileMetadataOptionsCopyWith<$Res>  {
  factory $GetFileMetadataOptionsCopyWith(GetFileMetadataOptions value, $Res Function(GetFileMetadataOptions) _then) = _$GetFileMetadataOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject
});




}
/// @nodoc
class _$GetFileMetadataOptionsCopyWithImpl<$Res>
    implements $GetFileMetadataOptionsCopyWith<$Res> {
  _$GetFileMetadataOptionsCopyWithImpl(this._self, this._then);

  final GetFileMetadataOptions _self;
  final $Res Function(GetFileMetadataOptions) _then;

/// Create a copy of GetFileMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _GetFileMetadataOptions implements GetFileMetadataOptions {
  const _GetFileMetadataOptions({this.userProject});
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of GetFileMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetFileMetadataOptionsCopyWith<_GetFileMetadataOptions> get copyWith => __$GetFileMetadataOptionsCopyWithImpl<_GetFileMetadataOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetFileMetadataOptions&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,userProject);

@override
String toString() {
  return 'GetFileMetadataOptions(userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$GetFileMetadataOptionsCopyWith<$Res> implements $GetFileMetadataOptionsCopyWith<$Res> {
  factory _$GetFileMetadataOptionsCopyWith(_GetFileMetadataOptions value, $Res Function(_GetFileMetadataOptions) _then) = __$GetFileMetadataOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject
});




}
/// @nodoc
class __$GetFileMetadataOptionsCopyWithImpl<$Res>
    implements _$GetFileMetadataOptionsCopyWith<$Res> {
  __$GetFileMetadataOptionsCopyWithImpl(this._self, this._then);

  final _GetFileMetadataOptions _self;
  final $Res Function(_GetFileMetadataOptions) _then;

/// Create a copy of GetFileMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,}) {
  return _then(_GetFileMetadataOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SetFileMetadataOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;/// Only perform the operation if the object's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the object's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the object's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the object's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of SetFileMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetFileMetadataOptionsCopyWith<SetFileMetadataOptions> get copyWith => _$SetFileMetadataOptionsCopyWithImpl<SetFileMetadataOptions>(this as SetFileMetadataOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetFileMetadataOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'SetFileMetadataOptions(userProject: $userProject, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $SetFileMetadataOptionsCopyWith<$Res>  {
  factory $SetFileMetadataOptionsCopyWith(SetFileMetadataOptions value, $Res Function(SetFileMetadataOptions) _then) = _$SetFileMetadataOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$SetFileMetadataOptionsCopyWithImpl<$Res>
    implements $SetFileMetadataOptionsCopyWith<$Res> {
  _$SetFileMetadataOptionsCopyWithImpl(this._self, this._then);

  final SetFileMetadataOptions _self;
  final $Res Function(SetFileMetadataOptions) _then;

/// Create a copy of SetFileMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _SetFileMetadataOptions extends SetFileMetadataOptions {
  const _SetFileMetadataOptions({this.userProject, final  int? ifGenerationMatch, final  int? ifGenerationNotMatch, final  int? ifMetagenerationMatch, final  int? ifMetagenerationNotMatch}): super._(ifGenerationMatch: ifGenerationMatch, ifGenerationNotMatch: ifGenerationNotMatch, ifMetagenerationMatch: ifMetagenerationMatch, ifMetagenerationNotMatch: ifMetagenerationNotMatch);
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of SetFileMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetFileMetadataOptionsCopyWith<_SetFileMetadataOptions> get copyWith => __$SetFileMetadataOptionsCopyWithImpl<_SetFileMetadataOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetFileMetadataOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'SetFileMetadataOptions(userProject: $userProject, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$SetFileMetadataOptionsCopyWith<$Res> implements $SetFileMetadataOptionsCopyWith<$Res> {
  factory _$SetFileMetadataOptionsCopyWith(_SetFileMetadataOptions value, $Res Function(_SetFileMetadataOptions) _then) = __$SetFileMetadataOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$SetFileMetadataOptionsCopyWithImpl<$Res>
    implements _$SetFileMetadataOptionsCopyWith<$Res> {
  __$SetFileMetadataOptionsCopyWithImpl(this._self, this._then);

  final _SetFileMetadataOptions _self;
  final $Res Function(_SetFileMetadataOptions) _then;

/// Create a copy of SetFileMetadataOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_SetFileMetadataOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$CopyOptions {

/// Cache-Control header value for the destination file.
 String? get cacheControl;/// Content-Encoding header value for the destination file.
 String? get contentEncoding;/// Content-Type header value for the destination file.
 String? get contentType;/// Content-Disposition header value for the destination file.
 String? get contentDisposition;/// The name of the Cloud KMS key that will be used to encrypt the destination file.
 String? get destinationKmsKeyName;/// Custom metadata to set on the destination file.
 Map<String, String>? get metadata;/// Apply a predefined set of access controls to the destination file.
 PredefinedAcl? get predefinedAcl;/// Token for resuming a copy operation.
 String? get token;/// The ID of the project which will be billed for the request.
 String? get userProject;/// Precondition options for the copy operation.
 PreconditionOptions? get preconditionOpts;
/// Create a copy of CopyOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CopyOptionsCopyWith<CopyOptions> get copyWith => _$CopyOptionsCopyWithImpl<CopyOptions>(this as CopyOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CopyOptions&&(identical(other.cacheControl, cacheControl) || other.cacheControl == cacheControl)&&(identical(other.contentEncoding, contentEncoding) || other.contentEncoding == contentEncoding)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentDisposition, contentDisposition) || other.contentDisposition == contentDisposition)&&(identical(other.destinationKmsKeyName, destinationKmsKeyName) || other.destinationKmsKeyName == destinationKmsKeyName)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.token, token) || other.token == token)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts));
}


@override
int get hashCode => Object.hash(runtimeType,cacheControl,contentEncoding,contentType,contentDisposition,destinationKmsKeyName,const DeepCollectionEquality().hash(metadata),predefinedAcl,token,userProject,preconditionOpts);

@override
String toString() {
  return 'CopyOptions(cacheControl: $cacheControl, contentEncoding: $contentEncoding, contentType: $contentType, contentDisposition: $contentDisposition, destinationKmsKeyName: $destinationKmsKeyName, metadata: $metadata, predefinedAcl: $predefinedAcl, token: $token, userProject: $userProject, preconditionOpts: $preconditionOpts)';
}


}

/// @nodoc
abstract mixin class $CopyOptionsCopyWith<$Res>  {
  factory $CopyOptionsCopyWith(CopyOptions value, $Res Function(CopyOptions) _then) = _$CopyOptionsCopyWithImpl;
@useResult
$Res call({
 String? cacheControl, String? contentEncoding, String? contentType, String? contentDisposition, String? destinationKmsKeyName, Map<String, String>? metadata, PredefinedAcl? predefinedAcl, String? token, String? userProject, PreconditionOptions? preconditionOpts
});




}
/// @nodoc
class _$CopyOptionsCopyWithImpl<$Res>
    implements $CopyOptionsCopyWith<$Res> {
  _$CopyOptionsCopyWithImpl(this._self, this._then);

  final CopyOptions _self;
  final $Res Function(CopyOptions) _then;

/// Create a copy of CopyOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cacheControl = freezed,Object? contentEncoding = freezed,Object? contentType = freezed,Object? contentDisposition = freezed,Object? destinationKmsKeyName = freezed,Object? metadata = freezed,Object? predefinedAcl = freezed,Object? token = freezed,Object? userProject = freezed,Object? preconditionOpts = freezed,}) {
  return _then(_self.copyWith(
cacheControl: freezed == cacheControl ? _self.cacheControl : cacheControl // ignore: cast_nullable_to_non_nullable
as String?,contentEncoding: freezed == contentEncoding ? _self.contentEncoding : contentEncoding // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,contentDisposition: freezed == contentDisposition ? _self.contentDisposition : contentDisposition // ignore: cast_nullable_to_non_nullable
as String?,destinationKmsKeyName: freezed == destinationKmsKeyName ? _self.destinationKmsKeyName : destinationKmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,
  ));
}

}



/// @nodoc


class _CopyOptions implements CopyOptions {
  const _CopyOptions({this.cacheControl, this.contentEncoding, this.contentType, this.contentDisposition, this.destinationKmsKeyName, final  Map<String, String>? metadata, this.predefinedAcl, this.token, this.userProject, this.preconditionOpts}): _metadata = metadata;
  

/// Cache-Control header value for the destination file.
@override final  String? cacheControl;
/// Content-Encoding header value for the destination file.
@override final  String? contentEncoding;
/// Content-Type header value for the destination file.
@override final  String? contentType;
/// Content-Disposition header value for the destination file.
@override final  String? contentDisposition;
/// The name of the Cloud KMS key that will be used to encrypt the destination file.
@override final  String? destinationKmsKeyName;
/// Custom metadata to set on the destination file.
 final  Map<String, String>? _metadata;
/// Custom metadata to set on the destination file.
@override Map<String, String>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Apply a predefined set of access controls to the destination file.
@override final  PredefinedAcl? predefinedAcl;
/// Token for resuming a copy operation.
@override final  String? token;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Precondition options for the copy operation.
@override final  PreconditionOptions? preconditionOpts;

/// Create a copy of CopyOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CopyOptionsCopyWith<_CopyOptions> get copyWith => __$CopyOptionsCopyWithImpl<_CopyOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CopyOptions&&(identical(other.cacheControl, cacheControl) || other.cacheControl == cacheControl)&&(identical(other.contentEncoding, contentEncoding) || other.contentEncoding == contentEncoding)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentDisposition, contentDisposition) || other.contentDisposition == contentDisposition)&&(identical(other.destinationKmsKeyName, destinationKmsKeyName) || other.destinationKmsKeyName == destinationKmsKeyName)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.token, token) || other.token == token)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts));
}


@override
int get hashCode => Object.hash(runtimeType,cacheControl,contentEncoding,contentType,contentDisposition,destinationKmsKeyName,const DeepCollectionEquality().hash(_metadata),predefinedAcl,token,userProject,preconditionOpts);

@override
String toString() {
  return 'CopyOptions(cacheControl: $cacheControl, contentEncoding: $contentEncoding, contentType: $contentType, contentDisposition: $contentDisposition, destinationKmsKeyName: $destinationKmsKeyName, metadata: $metadata, predefinedAcl: $predefinedAcl, token: $token, userProject: $userProject, preconditionOpts: $preconditionOpts)';
}


}

/// @nodoc
abstract mixin class _$CopyOptionsCopyWith<$Res> implements $CopyOptionsCopyWith<$Res> {
  factory _$CopyOptionsCopyWith(_CopyOptions value, $Res Function(_CopyOptions) _then) = __$CopyOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? cacheControl, String? contentEncoding, String? contentType, String? contentDisposition, String? destinationKmsKeyName, Map<String, String>? metadata, PredefinedAcl? predefinedAcl, String? token, String? userProject, PreconditionOptions? preconditionOpts
});




}
/// @nodoc
class __$CopyOptionsCopyWithImpl<$Res>
    implements _$CopyOptionsCopyWith<$Res> {
  __$CopyOptionsCopyWithImpl(this._self, this._then);

  final _CopyOptions _self;
  final $Res Function(_CopyOptions) _then;

/// Create a copy of CopyOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cacheControl = freezed,Object? contentEncoding = freezed,Object? contentType = freezed,Object? contentDisposition = freezed,Object? destinationKmsKeyName = freezed,Object? metadata = freezed,Object? predefinedAcl = freezed,Object? token = freezed,Object? userProject = freezed,Object? preconditionOpts = freezed,}) {
  return _then(_CopyOptions(
cacheControl: freezed == cacheControl ? _self.cacheControl : cacheControl // ignore: cast_nullable_to_non_nullable
as String?,contentEncoding: freezed == contentEncoding ? _self.contentEncoding : contentEncoding // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,contentDisposition: freezed == contentDisposition ? _self.contentDisposition : contentDisposition // ignore: cast_nullable_to_non_nullable
as String?,destinationKmsKeyName: freezed == destinationKmsKeyName ? _self.destinationKmsKeyName : destinationKmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,
  ));
}


}

/// @nodoc
mixin _$MoveOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;/// Precondition options for the move operation.
 PreconditionOptions? get preconditionOpts;
/// Create a copy of MoveOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveOptionsCopyWith<MoveOptions> get copyWith => _$MoveOptionsCopyWithImpl<MoveOptions>(this as MoveOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,preconditionOpts);

@override
String toString() {
  return 'MoveOptions(userProject: $userProject, preconditionOpts: $preconditionOpts)';
}


}

/// @nodoc
abstract mixin class $MoveOptionsCopyWith<$Res>  {
  factory $MoveOptionsCopyWith(MoveOptions value, $Res Function(MoveOptions) _then) = _$MoveOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject, PreconditionOptions? preconditionOpts
});




}
/// @nodoc
class _$MoveOptionsCopyWithImpl<$Res>
    implements $MoveOptionsCopyWith<$Res> {
  _$MoveOptionsCopyWithImpl(this._self, this._then);

  final MoveOptions _self;
  final $Res Function(MoveOptions) _then;

/// Create a copy of MoveOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,Object? preconditionOpts = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,
  ));
}

}



/// @nodoc


class _MoveOptions implements MoveOptions {
  const _MoveOptions({this.userProject, this.preconditionOpts});
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Precondition options for the move operation.
@override final  PreconditionOptions? preconditionOpts;

/// Create a copy of MoveOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveOptionsCopyWith<_MoveOptions> get copyWith => __$MoveOptionsCopyWithImpl<_MoveOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,preconditionOpts);

@override
String toString() {
  return 'MoveOptions(userProject: $userProject, preconditionOpts: $preconditionOpts)';
}


}

/// @nodoc
abstract mixin class _$MoveOptionsCopyWith<$Res> implements $MoveOptionsCopyWith<$Res> {
  factory _$MoveOptionsCopyWith(_MoveOptions value, $Res Function(_MoveOptions) _then) = __$MoveOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject, PreconditionOptions? preconditionOpts
});




}
/// @nodoc
class __$MoveOptionsCopyWithImpl<$Res>
    implements _$MoveOptionsCopyWith<$Res> {
  __$MoveOptionsCopyWithImpl(this._self, this._then);

  final _MoveOptions _self;
  final $Res Function(_MoveOptions) _then;

/// Create a copy of MoveOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,Object? preconditionOpts = freezed,}) {
  return _then(_MoveOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,
  ));
}


}

/// @nodoc
mixin _$RotateEncryptionKeyOptions {

/// Customer-supplied encryption key.
 EncryptionKey? get encryptionKey;/// The name of the Cloud KMS key that will be used to encrypt the object.
 String? get kmsKeyName;/// Precondition options for the copy operation.
 PreconditionOptions? get preconditionOpts;
/// Create a copy of RotateEncryptionKeyOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RotateEncryptionKeyOptionsCopyWith<RotateEncryptionKeyOptions> get copyWith => _$RotateEncryptionKeyOptionsCopyWithImpl<RotateEncryptionKeyOptions>(this as RotateEncryptionKeyOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RotateEncryptionKeyOptions&&(identical(other.encryptionKey, encryptionKey) || other.encryptionKey == encryptionKey)&&(identical(other.kmsKeyName, kmsKeyName) || other.kmsKeyName == kmsKeyName)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts));
}


@override
int get hashCode => Object.hash(runtimeType,encryptionKey,kmsKeyName,preconditionOpts);

@override
String toString() {
  return 'RotateEncryptionKeyOptions(encryptionKey: $encryptionKey, kmsKeyName: $kmsKeyName, preconditionOpts: $preconditionOpts)';
}


}

/// @nodoc
abstract mixin class $RotateEncryptionKeyOptionsCopyWith<$Res>  {
  factory $RotateEncryptionKeyOptionsCopyWith(RotateEncryptionKeyOptions value, $Res Function(RotateEncryptionKeyOptions) _then) = _$RotateEncryptionKeyOptionsCopyWithImpl;
@useResult
$Res call({
 EncryptionKey? encryptionKey, String? kmsKeyName, PreconditionOptions? preconditionOpts
});


$EncryptionKeyCopyWith<$Res>? get encryptionKey;

}
/// @nodoc
class _$RotateEncryptionKeyOptionsCopyWithImpl<$Res>
    implements $RotateEncryptionKeyOptionsCopyWith<$Res> {
  _$RotateEncryptionKeyOptionsCopyWithImpl(this._self, this._then);

  final RotateEncryptionKeyOptions _self;
  final $Res Function(RotateEncryptionKeyOptions) _then;

/// Create a copy of RotateEncryptionKeyOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? encryptionKey = freezed,Object? kmsKeyName = freezed,Object? preconditionOpts = freezed,}) {
  return _then(_self.copyWith(
encryptionKey: freezed == encryptionKey ? _self.encryptionKey : encryptionKey // ignore: cast_nullable_to_non_nullable
as EncryptionKey?,kmsKeyName: freezed == kmsKeyName ? _self.kmsKeyName : kmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,
  ));
}
/// Create a copy of RotateEncryptionKeyOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncryptionKeyCopyWith<$Res>? get encryptionKey {
    if (_self.encryptionKey == null) {
    return null;
  }

  return $EncryptionKeyCopyWith<$Res>(_self.encryptionKey!, (value) {
    return _then(_self.copyWith(encryptionKey: value));
  });
}
}



/// @nodoc


class _RotateEncryptionKeyOptions implements RotateEncryptionKeyOptions {
  const _RotateEncryptionKeyOptions({this.encryptionKey, this.kmsKeyName, this.preconditionOpts});
  

/// Customer-supplied encryption key.
@override final  EncryptionKey? encryptionKey;
/// The name of the Cloud KMS key that will be used to encrypt the object.
@override final  String? kmsKeyName;
/// Precondition options for the copy operation.
@override final  PreconditionOptions? preconditionOpts;

/// Create a copy of RotateEncryptionKeyOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RotateEncryptionKeyOptionsCopyWith<_RotateEncryptionKeyOptions> get copyWith => __$RotateEncryptionKeyOptionsCopyWithImpl<_RotateEncryptionKeyOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RotateEncryptionKeyOptions&&(identical(other.encryptionKey, encryptionKey) || other.encryptionKey == encryptionKey)&&(identical(other.kmsKeyName, kmsKeyName) || other.kmsKeyName == kmsKeyName)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts));
}


@override
int get hashCode => Object.hash(runtimeType,encryptionKey,kmsKeyName,preconditionOpts);

@override
String toString() {
  return 'RotateEncryptionKeyOptions(encryptionKey: $encryptionKey, kmsKeyName: $kmsKeyName, preconditionOpts: $preconditionOpts)';
}


}

/// @nodoc
abstract mixin class _$RotateEncryptionKeyOptionsCopyWith<$Res> implements $RotateEncryptionKeyOptionsCopyWith<$Res> {
  factory _$RotateEncryptionKeyOptionsCopyWith(_RotateEncryptionKeyOptions value, $Res Function(_RotateEncryptionKeyOptions) _then) = __$RotateEncryptionKeyOptionsCopyWithImpl;
@override @useResult
$Res call({
 EncryptionKey? encryptionKey, String? kmsKeyName, PreconditionOptions? preconditionOpts
});


@override $EncryptionKeyCopyWith<$Res>? get encryptionKey;

}
/// @nodoc
class __$RotateEncryptionKeyOptionsCopyWithImpl<$Res>
    implements _$RotateEncryptionKeyOptionsCopyWith<$Res> {
  __$RotateEncryptionKeyOptionsCopyWithImpl(this._self, this._then);

  final _RotateEncryptionKeyOptions _self;
  final $Res Function(_RotateEncryptionKeyOptions) _then;

/// Create a copy of RotateEncryptionKeyOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? encryptionKey = freezed,Object? kmsKeyName = freezed,Object? preconditionOpts = freezed,}) {
  return _then(_RotateEncryptionKeyOptions(
encryptionKey: freezed == encryptionKey ? _self.encryptionKey : encryptionKey // ignore: cast_nullable_to_non_nullable
as EncryptionKey?,kmsKeyName: freezed == kmsKeyName ? _self.kmsKeyName : kmsKeyName // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,
  ));
}

/// Create a copy of RotateEncryptionKeyOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncryptionKeyCopyWith<$Res>? get encryptionKey {
    if (_self.encryptionKey == null) {
    return null;
  }

  return $EncryptionKeyCopyWith<$Res>(_self.encryptionKey!, (value) {
    return _then(_self.copyWith(encryptionKey: value));
  });
}
}

/// @nodoc
mixin _$MakeFilePrivateOptions {

/// Metadata to update on the file.
 FileMetadata? get metadata;/// If `true`, throw an error if the file is already private.
 bool? get strict;/// The ID of the project which will be billed for the request.
 String? get userProject;/// Precondition options for the operation.
 PreconditionOptions? get preconditionOpts;
/// Create a copy of MakeFilePrivateOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MakeFilePrivateOptionsCopyWith<MakeFilePrivateOptions> get copyWith => _$MakeFilePrivateOptionsCopyWithImpl<MakeFilePrivateOptions>(this as MakeFilePrivateOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MakeFilePrivateOptions&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.strict, strict) || other.strict == strict)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts));
}


@override
int get hashCode => Object.hash(runtimeType,metadata,strict,userProject,preconditionOpts);

@override
String toString() {
  return 'MakeFilePrivateOptions(metadata: $metadata, strict: $strict, userProject: $userProject, preconditionOpts: $preconditionOpts)';
}


}

/// @nodoc
abstract mixin class $MakeFilePrivateOptionsCopyWith<$Res>  {
  factory $MakeFilePrivateOptionsCopyWith(MakeFilePrivateOptions value, $Res Function(MakeFilePrivateOptions) _then) = _$MakeFilePrivateOptionsCopyWithImpl;
@useResult
$Res call({
 FileMetadata? metadata, bool? strict, String? userProject, PreconditionOptions? preconditionOpts
});




}
/// @nodoc
class _$MakeFilePrivateOptionsCopyWithImpl<$Res>
    implements $MakeFilePrivateOptionsCopyWith<$Res> {
  _$MakeFilePrivateOptionsCopyWithImpl(this._self, this._then);

  final MakeFilePrivateOptions _self;
  final $Res Function(MakeFilePrivateOptions) _then;

/// Create a copy of MakeFilePrivateOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metadata = freezed,Object? strict = freezed,Object? userProject = freezed,Object? preconditionOpts = freezed,}) {
  return _then(_self.copyWith(
metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata?,strict: freezed == strict ? _self.strict : strict // ignore: cast_nullable_to_non_nullable
as bool?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,
  ));
}

}



/// @nodoc


class _MakeFilePrivateOptions implements MakeFilePrivateOptions {
  const _MakeFilePrivateOptions({this.metadata, this.strict, this.userProject, this.preconditionOpts});
  

/// Metadata to update on the file.
@override final  FileMetadata? metadata;
/// If `true`, throw an error if the file is already private.
@override final  bool? strict;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Precondition options for the operation.
@override final  PreconditionOptions? preconditionOpts;

/// Create a copy of MakeFilePrivateOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MakeFilePrivateOptionsCopyWith<_MakeFilePrivateOptions> get copyWith => __$MakeFilePrivateOptionsCopyWithImpl<_MakeFilePrivateOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MakeFilePrivateOptions&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.strict, strict) || other.strict == strict)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts));
}


@override
int get hashCode => Object.hash(runtimeType,metadata,strict,userProject,preconditionOpts);

@override
String toString() {
  return 'MakeFilePrivateOptions(metadata: $metadata, strict: $strict, userProject: $userProject, preconditionOpts: $preconditionOpts)';
}


}

/// @nodoc
abstract mixin class _$MakeFilePrivateOptionsCopyWith<$Res> implements $MakeFilePrivateOptionsCopyWith<$Res> {
  factory _$MakeFilePrivateOptionsCopyWith(_MakeFilePrivateOptions value, $Res Function(_MakeFilePrivateOptions) _then) = __$MakeFilePrivateOptionsCopyWithImpl;
@override @useResult
$Res call({
 FileMetadata? metadata, bool? strict, String? userProject, PreconditionOptions? preconditionOpts
});




}
/// @nodoc
class __$MakeFilePrivateOptionsCopyWithImpl<$Res>
    implements _$MakeFilePrivateOptionsCopyWith<$Res> {
  __$MakeFilePrivateOptionsCopyWithImpl(this._self, this._then);

  final _MakeFilePrivateOptions _self;
  final $Res Function(_MakeFilePrivateOptions) _then;

/// Create a copy of MakeFilePrivateOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metadata = freezed,Object? strict = freezed,Object? userProject = freezed,Object? preconditionOpts = freezed,}) {
  return _then(_MakeFilePrivateOptions(
metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata?,strict: freezed == strict ? _self.strict : strict // ignore: cast_nullable_to_non_nullable
as bool?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,
  ));
}


}

/// @nodoc
mixin _$GetFileSignedUrlOptions {

/// Custom host for the signed URL. Inherited from [SignedUrlConfig].
 Uri? get host;/// Custom signing endpoint. Inherited from [SignedUrlConfig].
 Uri? get signingEndpoint;/// The action to perform: 'read', 'write', 'delete', or 'resumable'.
 String get action;/// The version of the signing algorithm to use.
 SignedUrlVersion? get version;/// Custom domain name for the signed URL.
 String? get cname;/// Use virtual-hosted-style URLs. Defaults to `false`.
 bool? get virtualHostedStyle;/// When the signed URL should expire.
 DateTime get expires;/// Additional headers to include in the signed URL.
 Map<String, String>? get extensionHeaders;/// Additional query parameters to include in the signed URL.
 Map<String, String>? get queryParams;/// MD5 hash of the content (for PUT requests).
 String? get contentMd5;/// Content-Type header value.
 String? get contentType;/// Filename to suggest when downloading the file.
 String? get promptSaveAs;/// Content-Disposition header value.
 String? get responseDisposition;/// Content-Type for the response.
 String? get responseType;/// When the signed URL becomes accessible (for v4 signing).
 DateTime? get accessibleAt;
/// Create a copy of GetFileSignedUrlOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetFileSignedUrlOptionsCopyWith<GetFileSignedUrlOptions> get copyWith => _$GetFileSignedUrlOptionsCopyWithImpl<GetFileSignedUrlOptions>(this as GetFileSignedUrlOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetFileSignedUrlOptions&&(identical(other.host, host) || other.host == host)&&(identical(other.signingEndpoint, signingEndpoint) || other.signingEndpoint == signingEndpoint)&&(identical(other.action, action) || other.action == action)&&(identical(other.version, version) || other.version == version)&&(identical(other.cname, cname) || other.cname == cname)&&(identical(other.virtualHostedStyle, virtualHostedStyle) || other.virtualHostedStyle == virtualHostedStyle)&&(identical(other.expires, expires) || other.expires == expires)&&const DeepCollectionEquality().equals(other.extensionHeaders, extensionHeaders)&&const DeepCollectionEquality().equals(other.queryParams, queryParams)&&(identical(other.contentMd5, contentMd5) || other.contentMd5 == contentMd5)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.promptSaveAs, promptSaveAs) || other.promptSaveAs == promptSaveAs)&&(identical(other.responseDisposition, responseDisposition) || other.responseDisposition == responseDisposition)&&(identical(other.responseType, responseType) || other.responseType == responseType)&&(identical(other.accessibleAt, accessibleAt) || other.accessibleAt == accessibleAt));
}


@override
int get hashCode => Object.hash(runtimeType,host,signingEndpoint,action,version,cname,virtualHostedStyle,expires,const DeepCollectionEquality().hash(extensionHeaders),const DeepCollectionEquality().hash(queryParams),contentMd5,contentType,promptSaveAs,responseDisposition,responseType,accessibleAt);

@override
String toString() {
  return 'GetFileSignedUrlOptions(host: $host, signingEndpoint: $signingEndpoint, action: $action, version: $version, cname: $cname, virtualHostedStyle: $virtualHostedStyle, expires: $expires, extensionHeaders: $extensionHeaders, queryParams: $queryParams, contentMd5: $contentMd5, contentType: $contentType, promptSaveAs: $promptSaveAs, responseDisposition: $responseDisposition, responseType: $responseType, accessibleAt: $accessibleAt)';
}


}

/// @nodoc
abstract mixin class $GetFileSignedUrlOptionsCopyWith<$Res>  {
  factory $GetFileSignedUrlOptionsCopyWith(GetFileSignedUrlOptions value, $Res Function(GetFileSignedUrlOptions) _then) = _$GetFileSignedUrlOptionsCopyWithImpl;
@useResult
$Res call({
 Uri? host, Uri? signingEndpoint, String action, SignedUrlVersion? version, String? cname, bool? virtualHostedStyle, DateTime expires, Map<String, String>? extensionHeaders, Map<String, String>? queryParams, String? contentMd5, String? contentType, String? promptSaveAs, String? responseDisposition, String? responseType, DateTime? accessibleAt
});




}
/// @nodoc
class _$GetFileSignedUrlOptionsCopyWithImpl<$Res>
    implements $GetFileSignedUrlOptionsCopyWith<$Res> {
  _$GetFileSignedUrlOptionsCopyWithImpl(this._self, this._then);

  final GetFileSignedUrlOptions _self;
  final $Res Function(GetFileSignedUrlOptions) _then;

/// Create a copy of GetFileSignedUrlOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = freezed,Object? signingEndpoint = freezed,Object? action = null,Object? version = freezed,Object? cname = freezed,Object? virtualHostedStyle = freezed,Object? expires = null,Object? extensionHeaders = freezed,Object? queryParams = freezed,Object? contentMd5 = freezed,Object? contentType = freezed,Object? promptSaveAs = freezed,Object? responseDisposition = freezed,Object? responseType = freezed,Object? accessibleAt = freezed,}) {
  return _then(_self.copyWith(
host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as Uri?,signingEndpoint: freezed == signingEndpoint ? _self.signingEndpoint : signingEndpoint // ignore: cast_nullable_to_non_nullable
as Uri?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as SignedUrlVersion?,cname: freezed == cname ? _self.cname : cname // ignore: cast_nullable_to_non_nullable
as String?,virtualHostedStyle: freezed == virtualHostedStyle ? _self.virtualHostedStyle : virtualHostedStyle // ignore: cast_nullable_to_non_nullable
as bool?,expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime,extensionHeaders: freezed == extensionHeaders ? _self.extensionHeaders : extensionHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,queryParams: freezed == queryParams ? _self.queryParams : queryParams // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,contentMd5: freezed == contentMd5 ? _self.contentMd5 : contentMd5 // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,promptSaveAs: freezed == promptSaveAs ? _self.promptSaveAs : promptSaveAs // ignore: cast_nullable_to_non_nullable
as String?,responseDisposition: freezed == responseDisposition ? _self.responseDisposition : responseDisposition // ignore: cast_nullable_to_non_nullable
as String?,responseType: freezed == responseType ? _self.responseType : responseType // ignore: cast_nullable_to_non_nullable
as String?,accessibleAt: freezed == accessibleAt ? _self.accessibleAt : accessibleAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}



/// @nodoc


class _GetFileSignedUrlOptions implements GetFileSignedUrlOptions {
  const _GetFileSignedUrlOptions({this.host, this.signingEndpoint, required this.action, this.version, this.cname, this.virtualHostedStyle = false, required this.expires, final  Map<String, String>? extensionHeaders, final  Map<String, String>? queryParams, this.contentMd5, this.contentType, this.promptSaveAs, this.responseDisposition, this.responseType, this.accessibleAt}): _extensionHeaders = extensionHeaders,_queryParams = queryParams;
  

/// Custom host for the signed URL. Inherited from [SignedUrlConfig].
@override final  Uri? host;
/// Custom signing endpoint. Inherited from [SignedUrlConfig].
@override final  Uri? signingEndpoint;
/// The action to perform: 'read', 'write', 'delete', or 'resumable'.
@override final  String action;
/// The version of the signing algorithm to use.
@override final  SignedUrlVersion? version;
/// Custom domain name for the signed URL.
@override final  String? cname;
/// Use virtual-hosted-style URLs. Defaults to `false`.
@override@JsonKey() final  bool? virtualHostedStyle;
/// When the signed URL should expire.
@override final  DateTime expires;
/// Additional headers to include in the signed URL.
 final  Map<String, String>? _extensionHeaders;
/// Additional headers to include in the signed URL.
@override Map<String, String>? get extensionHeaders {
  final value = _extensionHeaders;
  if (value == null) return null;
  if (_extensionHeaders is EqualUnmodifiableMapView) return _extensionHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Additional query parameters to include in the signed URL.
 final  Map<String, String>? _queryParams;
/// Additional query parameters to include in the signed URL.
@override Map<String, String>? get queryParams {
  final value = _queryParams;
  if (value == null) return null;
  if (_queryParams is EqualUnmodifiableMapView) return _queryParams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// MD5 hash of the content (for PUT requests).
@override final  String? contentMd5;
/// Content-Type header value.
@override final  String? contentType;
/// Filename to suggest when downloading the file.
@override final  String? promptSaveAs;
/// Content-Disposition header value.
@override final  String? responseDisposition;
/// Content-Type for the response.
@override final  String? responseType;
/// When the signed URL becomes accessible (for v4 signing).
@override final  DateTime? accessibleAt;

/// Create a copy of GetFileSignedUrlOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetFileSignedUrlOptionsCopyWith<_GetFileSignedUrlOptions> get copyWith => __$GetFileSignedUrlOptionsCopyWithImpl<_GetFileSignedUrlOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetFileSignedUrlOptions&&(identical(other.host, host) || other.host == host)&&(identical(other.signingEndpoint, signingEndpoint) || other.signingEndpoint == signingEndpoint)&&(identical(other.action, action) || other.action == action)&&(identical(other.version, version) || other.version == version)&&(identical(other.cname, cname) || other.cname == cname)&&(identical(other.virtualHostedStyle, virtualHostedStyle) || other.virtualHostedStyle == virtualHostedStyle)&&(identical(other.expires, expires) || other.expires == expires)&&const DeepCollectionEquality().equals(other._extensionHeaders, _extensionHeaders)&&const DeepCollectionEquality().equals(other._queryParams, _queryParams)&&(identical(other.contentMd5, contentMd5) || other.contentMd5 == contentMd5)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.promptSaveAs, promptSaveAs) || other.promptSaveAs == promptSaveAs)&&(identical(other.responseDisposition, responseDisposition) || other.responseDisposition == responseDisposition)&&(identical(other.responseType, responseType) || other.responseType == responseType)&&(identical(other.accessibleAt, accessibleAt) || other.accessibleAt == accessibleAt));
}


@override
int get hashCode => Object.hash(runtimeType,host,signingEndpoint,action,version,cname,virtualHostedStyle,expires,const DeepCollectionEquality().hash(_extensionHeaders),const DeepCollectionEquality().hash(_queryParams),contentMd5,contentType,promptSaveAs,responseDisposition,responseType,accessibleAt);

@override
String toString() {
  return 'GetFileSignedUrlOptions(host: $host, signingEndpoint: $signingEndpoint, action: $action, version: $version, cname: $cname, virtualHostedStyle: $virtualHostedStyle, expires: $expires, extensionHeaders: $extensionHeaders, queryParams: $queryParams, contentMd5: $contentMd5, contentType: $contentType, promptSaveAs: $promptSaveAs, responseDisposition: $responseDisposition, responseType: $responseType, accessibleAt: $accessibleAt)';
}


}

/// @nodoc
abstract mixin class _$GetFileSignedUrlOptionsCopyWith<$Res> implements $GetFileSignedUrlOptionsCopyWith<$Res> {
  factory _$GetFileSignedUrlOptionsCopyWith(_GetFileSignedUrlOptions value, $Res Function(_GetFileSignedUrlOptions) _then) = __$GetFileSignedUrlOptionsCopyWithImpl;
@override @useResult
$Res call({
 Uri? host, Uri? signingEndpoint, String action, SignedUrlVersion? version, String? cname, bool? virtualHostedStyle, DateTime expires, Map<String, String>? extensionHeaders, Map<String, String>? queryParams, String? contentMd5, String? contentType, String? promptSaveAs, String? responseDisposition, String? responseType, DateTime? accessibleAt
});




}
/// @nodoc
class __$GetFileSignedUrlOptionsCopyWithImpl<$Res>
    implements _$GetFileSignedUrlOptionsCopyWith<$Res> {
  __$GetFileSignedUrlOptionsCopyWithImpl(this._self, this._then);

  final _GetFileSignedUrlOptions _self;
  final $Res Function(_GetFileSignedUrlOptions) _then;

/// Create a copy of GetFileSignedUrlOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = freezed,Object? signingEndpoint = freezed,Object? action = null,Object? version = freezed,Object? cname = freezed,Object? virtualHostedStyle = freezed,Object? expires = null,Object? extensionHeaders = freezed,Object? queryParams = freezed,Object? contentMd5 = freezed,Object? contentType = freezed,Object? promptSaveAs = freezed,Object? responseDisposition = freezed,Object? responseType = freezed,Object? accessibleAt = freezed,}) {
  return _then(_GetFileSignedUrlOptions(
host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as Uri?,signingEndpoint: freezed == signingEndpoint ? _self.signingEndpoint : signingEndpoint // ignore: cast_nullable_to_non_nullable
as Uri?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as SignedUrlVersion?,cname: freezed == cname ? _self.cname : cname // ignore: cast_nullable_to_non_nullable
as String?,virtualHostedStyle: freezed == virtualHostedStyle ? _self.virtualHostedStyle : virtualHostedStyle // ignore: cast_nullable_to_non_nullable
as bool?,expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime,extensionHeaders: freezed == extensionHeaders ? _self._extensionHeaders : extensionHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,queryParams: freezed == queryParams ? _self._queryParams : queryParams // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,contentMd5: freezed == contentMd5 ? _self.contentMd5 : contentMd5 // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,promptSaveAs: freezed == promptSaveAs ? _self.promptSaveAs : promptSaveAs // ignore: cast_nullable_to_non_nullable
as String?,responseDisposition: freezed == responseDisposition ? _self.responseDisposition : responseDisposition // ignore: cast_nullable_to_non_nullable
as String?,responseType: freezed == responseType ? _self.responseType : responseType // ignore: cast_nullable_to_non_nullable
as String?,accessibleAt: freezed == accessibleAt ? _self.accessibleAt : accessibleAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$SetFileStorageClassOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;/// Only perform the operation if the object's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the object's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the object's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the object's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of SetFileStorageClassOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetFileStorageClassOptionsCopyWith<SetFileStorageClassOptions> get copyWith => _$SetFileStorageClassOptionsCopyWithImpl<SetFileStorageClassOptions>(this as SetFileStorageClassOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetFileStorageClassOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'SetFileStorageClassOptions(userProject: $userProject, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $SetFileStorageClassOptionsCopyWith<$Res>  {
  factory $SetFileStorageClassOptionsCopyWith(SetFileStorageClassOptions value, $Res Function(SetFileStorageClassOptions) _then) = _$SetFileStorageClassOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$SetFileStorageClassOptionsCopyWithImpl<$Res>
    implements $SetFileStorageClassOptionsCopyWith<$Res> {
  _$SetFileStorageClassOptionsCopyWithImpl(this._self, this._then);

  final SetFileStorageClassOptions _self;
  final $Res Function(SetFileStorageClassOptions) _then;

/// Create a copy of SetFileStorageClassOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _SetFileStorageClassOptions extends SetFileStorageClassOptions {
  const _SetFileStorageClassOptions({this.userProject, final  int? ifGenerationMatch, final  int? ifGenerationNotMatch, final  int? ifMetagenerationMatch, final  int? ifMetagenerationNotMatch}): super._(ifGenerationMatch: ifGenerationMatch, ifGenerationNotMatch: ifGenerationNotMatch, ifMetagenerationMatch: ifMetagenerationMatch, ifMetagenerationNotMatch: ifMetagenerationNotMatch);
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of SetFileStorageClassOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetFileStorageClassOptionsCopyWith<_SetFileStorageClassOptions> get copyWith => __$SetFileStorageClassOptionsCopyWithImpl<_SetFileStorageClassOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetFileStorageClassOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'SetFileStorageClassOptions(userProject: $userProject, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$SetFileStorageClassOptionsCopyWith<$Res> implements $SetFileStorageClassOptionsCopyWith<$Res> {
  factory _$SetFileStorageClassOptionsCopyWith(_SetFileStorageClassOptions value, $Res Function(_SetFileStorageClassOptions) _then) = __$SetFileStorageClassOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$SetFileStorageClassOptionsCopyWithImpl<$Res>
    implements _$SetFileStorageClassOptionsCopyWith<$Res> {
  __$SetFileStorageClassOptionsCopyWithImpl(this._self, this._then);

  final _SetFileStorageClassOptions _self;
  final $Res Function(_SetFileStorageClassOptions) _then;

/// Create a copy of SetFileStorageClassOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_SetFileStorageClassOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$RestoreFileOptions {

/// The generation of the file to restore.
 int get generation;/// Token for restoring a soft-deleted file.
 String? get restoreToken;/// The set of properties to return in the response.
 Projection? get projection;/// The ID of the project which will be billed for the request.
 String? get userProject;/// Only perform the operation if the object's generation matches this value.
 int? get ifGenerationMatch;/// Only perform the operation if the object's generation does not match this value.
 int? get ifGenerationNotMatch;/// Only perform the operation if the object's metageneration matches this value.
 int? get ifMetagenerationMatch;/// Only perform the operation if the object's metageneration does not match this value.
 int? get ifMetagenerationNotMatch;
/// Create a copy of RestoreFileOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestoreFileOptionsCopyWith<RestoreFileOptions> get copyWith => _$RestoreFileOptionsCopyWithImpl<RestoreFileOptions>(this as RestoreFileOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestoreFileOptions&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.restoreToken, restoreToken) || other.restoreToken == restoreToken)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,generation,restoreToken,projection,userProject,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'RestoreFileOptions(generation: $generation, restoreToken: $restoreToken, projection: $projection, userProject: $userProject, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class $RestoreFileOptionsCopyWith<$Res>  {
  factory $RestoreFileOptionsCopyWith(RestoreFileOptions value, $Res Function(RestoreFileOptions) _then) = _$RestoreFileOptionsCopyWithImpl;
@useResult
$Res call({
 int generation, String? restoreToken, Projection? projection, String? userProject, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class _$RestoreFileOptionsCopyWithImpl<$Res>
    implements $RestoreFileOptionsCopyWith<$Res> {
  _$RestoreFileOptionsCopyWithImpl(this._self, this._then);

  final RestoreFileOptions _self;
  final $Res Function(RestoreFileOptions) _then;

/// Create a copy of RestoreFileOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? generation = null,Object? restoreToken = freezed,Object? projection = freezed,Object? userProject = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_self.copyWith(
generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,restoreToken: freezed == restoreToken ? _self.restoreToken : restoreToken // ignore: cast_nullable_to_non_nullable
as String?,projection: freezed == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as Projection?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _RestoreFileOptions extends RestoreFileOptions {
  const _RestoreFileOptions({required this.generation, this.restoreToken, this.projection, this.userProject, final  int? ifGenerationMatch, final  int? ifGenerationNotMatch, final  int? ifMetagenerationMatch, final  int? ifMetagenerationNotMatch}): super._(ifGenerationMatch: ifGenerationMatch, ifGenerationNotMatch: ifGenerationNotMatch, ifMetagenerationMatch: ifMetagenerationMatch, ifMetagenerationNotMatch: ifMetagenerationNotMatch);
  

/// The generation of the file to restore.
@override final  int generation;
/// Token for restoring a soft-deleted file.
@override final  String? restoreToken;
/// The set of properties to return in the response.
@override final  Projection? projection;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of RestoreFileOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestoreFileOptionsCopyWith<_RestoreFileOptions> get copyWith => __$RestoreFileOptionsCopyWithImpl<_RestoreFileOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestoreFileOptions&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.restoreToken, restoreToken) || other.restoreToken == restoreToken)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.ifGenerationMatch, ifGenerationMatch) || other.ifGenerationMatch == ifGenerationMatch)&&(identical(other.ifGenerationNotMatch, ifGenerationNotMatch) || other.ifGenerationNotMatch == ifGenerationNotMatch)&&(identical(other.ifMetagenerationMatch, ifMetagenerationMatch) || other.ifMetagenerationMatch == ifMetagenerationMatch)&&(identical(other.ifMetagenerationNotMatch, ifMetagenerationNotMatch) || other.ifMetagenerationNotMatch == ifMetagenerationNotMatch));
}


@override
int get hashCode => Object.hash(runtimeType,generation,restoreToken,projection,userProject,ifGenerationMatch,ifGenerationNotMatch,ifMetagenerationMatch,ifMetagenerationNotMatch);

@override
String toString() {
  return 'RestoreFileOptions(generation: $generation, restoreToken: $restoreToken, projection: $projection, userProject: $userProject, ifGenerationMatch: $ifGenerationMatch, ifGenerationNotMatch: $ifGenerationNotMatch, ifMetagenerationMatch: $ifMetagenerationMatch, ifMetagenerationNotMatch: $ifMetagenerationNotMatch)';
}


}

/// @nodoc
abstract mixin class _$RestoreFileOptionsCopyWith<$Res> implements $RestoreFileOptionsCopyWith<$Res> {
  factory _$RestoreFileOptionsCopyWith(_RestoreFileOptions value, $Res Function(_RestoreFileOptions) _then) = __$RestoreFileOptionsCopyWithImpl;
@override @useResult
$Res call({
 int generation, String? restoreToken, Projection? projection, String? userProject, int? ifGenerationMatch, int? ifGenerationNotMatch, int? ifMetagenerationMatch, int? ifMetagenerationNotMatch
});




}
/// @nodoc
class __$RestoreFileOptionsCopyWithImpl<$Res>
    implements _$RestoreFileOptionsCopyWith<$Res> {
  __$RestoreFileOptionsCopyWithImpl(this._self, this._then);

  final _RestoreFileOptions _self;
  final $Res Function(_RestoreFileOptions) _then;

/// Create a copy of RestoreFileOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? generation = null,Object? restoreToken = freezed,Object? projection = freezed,Object? userProject = freezed,Object? ifGenerationMatch = freezed,Object? ifGenerationNotMatch = freezed,Object? ifMetagenerationMatch = freezed,Object? ifMetagenerationNotMatch = freezed,}) {
  return _then(_RestoreFileOptions(
generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,restoreToken: freezed == restoreToken ? _self.restoreToken : restoreToken // ignore: cast_nullable_to_non_nullable
as String?,projection: freezed == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as Projection?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,ifGenerationMatch: freezed == ifGenerationMatch ? _self.ifGenerationMatch : ifGenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifGenerationNotMatch: freezed == ifGenerationNotMatch ? _self.ifGenerationNotMatch : ifGenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationMatch: freezed == ifMetagenerationMatch ? _self.ifMetagenerationMatch : ifMetagenerationMatch // ignore: cast_nullable_to_non_nullable
as int?,ifMetagenerationNotMatch: freezed == ifMetagenerationNotMatch ? _self.ifMetagenerationNotMatch : ifMetagenerationNotMatch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$UploadProgress {

/// Number of bytes written so far.
 int get bytesWritten;/// Total number of bytes to upload, if known.
 int? get totalBytes;
/// Create a copy of UploadProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadProgressCopyWith<UploadProgress> get copyWith => _$UploadProgressCopyWithImpl<UploadProgress>(this as UploadProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadProgress&&(identical(other.bytesWritten, bytesWritten) || other.bytesWritten == bytesWritten)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes));
}


@override
int get hashCode => Object.hash(runtimeType,bytesWritten,totalBytes);

@override
String toString() {
  return 'UploadProgress(bytesWritten: $bytesWritten, totalBytes: $totalBytes)';
}


}

/// @nodoc
abstract mixin class $UploadProgressCopyWith<$Res>  {
  factory $UploadProgressCopyWith(UploadProgress value, $Res Function(UploadProgress) _then) = _$UploadProgressCopyWithImpl;
@useResult
$Res call({
 int bytesWritten, int? totalBytes
});




}
/// @nodoc
class _$UploadProgressCopyWithImpl<$Res>
    implements $UploadProgressCopyWith<$Res> {
  _$UploadProgressCopyWithImpl(this._self, this._then);

  final UploadProgress _self;
  final $Res Function(UploadProgress) _then;

/// Create a copy of UploadProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bytesWritten = null,Object? totalBytes = freezed,}) {
  return _then(_self.copyWith(
bytesWritten: null == bytesWritten ? _self.bytesWritten : bytesWritten // ignore: cast_nullable_to_non_nullable
as int,totalBytes: freezed == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _UploadProgress implements UploadProgress {
  const _UploadProgress({required this.bytesWritten, this.totalBytes});
  

/// Number of bytes written so far.
@override final  int bytesWritten;
/// Total number of bytes to upload, if known.
@override final  int? totalBytes;

/// Create a copy of UploadProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadProgressCopyWith<_UploadProgress> get copyWith => __$UploadProgressCopyWithImpl<_UploadProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadProgress&&(identical(other.bytesWritten, bytesWritten) || other.bytesWritten == bytesWritten)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes));
}


@override
int get hashCode => Object.hash(runtimeType,bytesWritten,totalBytes);

@override
String toString() {
  return 'UploadProgress(bytesWritten: $bytesWritten, totalBytes: $totalBytes)';
}


}

/// @nodoc
abstract mixin class _$UploadProgressCopyWith<$Res> implements $UploadProgressCopyWith<$Res> {
  factory _$UploadProgressCopyWith(_UploadProgress value, $Res Function(_UploadProgress) _then) = __$UploadProgressCopyWithImpl;
@override @useResult
$Res call({
 int bytesWritten, int? totalBytes
});




}
/// @nodoc
class __$UploadProgressCopyWithImpl<$Res>
    implements _$UploadProgressCopyWith<$Res> {
  __$UploadProgressCopyWithImpl(this._self, this._then);

  final _UploadProgress _self;
  final $Res Function(_UploadProgress) _then;

/// Create a copy of UploadProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bytesWritten = null,Object? totalBytes = freezed,}) {
  return _then(_UploadProgress(
bytesWritten: null == bytesWritten ? _self.bytesWritten : bytesWritten // ignore: cast_nullable_to_non_nullable
as int,totalBytes: freezed == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$CreateWriteStreamOptions {

/// Content type of the file. If set to 'auto', the file name is used to determine the contentType.
 String? get contentType;/// If true, automatically gzip the file. If null, the contentType is used to determine if the file should be gzipped (auto-detect).
 bool? get gzip;/// Metadata for the file. See Objects: insert request body for details.
 FileMetadata? get metadata;/// The starting byte of the upload stream, for resuming an interrupted upload. Defaults to 0.
 int? get offset;/// Apply a predefined set of access controls to this object.
 PredefinedAcl? get predefinedAcl;/// Make the uploaded file private. (Alias for predefinedAcl = 'private')
 bool? get private;/// Make the uploaded file public. (Alias for predefinedAcl = 'publicRead')
 bool? get public;/// Force a resumable upload. Defaults to true.
 bool? get resumable;/// Set the HTTP request timeout in milliseconds. This option is not available for resumable uploads. Default: 60000
 int? get timeout;/// The URI for an already-created resumable upload. See File.createResumableUpload().
 String? get uri;/// The ID of the project which will be billed for the request.
 String? get userProject;/// Validation type for data integrity checks. By default, data integrity is validated with a CRC32c checksum.
 ValidationType? get validation;/// A CRC32C to resume from when continuing a previous upload.
 String? get resumeCRC32C;/// Precondition options for the upload.
 PreconditionOptions? get preconditionOpts;/// Chunk size for resumable uploads. Default: 256KB
 int? get chunkSize;/// High water mark for the stream. Controls buffer size.
 int? get highWaterMark;/// Whether this is a partial upload.
 bool? get isPartialUpload;/// Callback for upload progress events.
 void Function(UploadProgress)? get onUploadProgress;
/// Create a copy of CreateWriteStreamOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWriteStreamOptionsCopyWith<CreateWriteStreamOptions> get copyWith => _$CreateWriteStreamOptionsCopyWithImpl<CreateWriteStreamOptions>(this as CreateWriteStreamOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWriteStreamOptions&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.gzip, gzip) || other.gzip == gzip)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.private, private) || other.private == private)&&(identical(other.public, public) || other.public == public)&&(identical(other.resumable, resumable) || other.resumable == resumable)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.resumeCRC32C, resumeCRC32C) || other.resumeCRC32C == resumeCRC32C)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.chunkSize, chunkSize) || other.chunkSize == chunkSize)&&(identical(other.highWaterMark, highWaterMark) || other.highWaterMark == highWaterMark)&&(identical(other.isPartialUpload, isPartialUpload) || other.isPartialUpload == isPartialUpload)&&(identical(other.onUploadProgress, onUploadProgress) || other.onUploadProgress == onUploadProgress));
}


@override
int get hashCode => Object.hash(runtimeType,contentType,gzip,metadata,offset,predefinedAcl,private,public,resumable,timeout,uri,userProject,validation,resumeCRC32C,preconditionOpts,chunkSize,highWaterMark,isPartialUpload,onUploadProgress);

@override
String toString() {
  return 'CreateWriteStreamOptions(contentType: $contentType, gzip: $gzip, metadata: $metadata, offset: $offset, predefinedAcl: $predefinedAcl, private: $private, public: $public, resumable: $resumable, timeout: $timeout, uri: $uri, userProject: $userProject, validation: $validation, resumeCRC32C: $resumeCRC32C, preconditionOpts: $preconditionOpts, chunkSize: $chunkSize, highWaterMark: $highWaterMark, isPartialUpload: $isPartialUpload, onUploadProgress: $onUploadProgress)';
}


}

/// @nodoc
abstract mixin class $CreateWriteStreamOptionsCopyWith<$Res>  {
  factory $CreateWriteStreamOptionsCopyWith(CreateWriteStreamOptions value, $Res Function(CreateWriteStreamOptions) _then) = _$CreateWriteStreamOptionsCopyWithImpl;
@useResult
$Res call({
 String? contentType, bool? gzip, FileMetadata? metadata, int? offset, PredefinedAcl? predefinedAcl, bool? private, bool? public, bool? resumable, int? timeout, String? uri, String? userProject, ValidationType? validation, String? resumeCRC32C, PreconditionOptions? preconditionOpts, int? chunkSize, int? highWaterMark, bool? isPartialUpload, void Function(UploadProgress)? onUploadProgress
});




}
/// @nodoc
class _$CreateWriteStreamOptionsCopyWithImpl<$Res>
    implements $CreateWriteStreamOptionsCopyWith<$Res> {
  _$CreateWriteStreamOptionsCopyWithImpl(this._self, this._then);

  final CreateWriteStreamOptions _self;
  final $Res Function(CreateWriteStreamOptions) _then;

/// Create a copy of CreateWriteStreamOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contentType = freezed,Object? gzip = freezed,Object? metadata = freezed,Object? offset = freezed,Object? predefinedAcl = freezed,Object? private = freezed,Object? public = freezed,Object? resumable = freezed,Object? timeout = freezed,Object? uri = freezed,Object? userProject = freezed,Object? validation = freezed,Object? resumeCRC32C = freezed,Object? preconditionOpts = freezed,Object? chunkSize = freezed,Object? highWaterMark = freezed,Object? isPartialUpload = freezed,Object? onUploadProgress = freezed,}) {
  return _then(_self.copyWith(
contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,gzip: freezed == gzip ? _self.gzip : gzip // ignore: cast_nullable_to_non_nullable
as bool?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as bool?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,resumable: freezed == resumable ? _self.resumable : resumable // ignore: cast_nullable_to_non_nullable
as bool?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,resumeCRC32C: freezed == resumeCRC32C ? _self.resumeCRC32C : resumeCRC32C // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,chunkSize: freezed == chunkSize ? _self.chunkSize : chunkSize // ignore: cast_nullable_to_non_nullable
as int?,highWaterMark: freezed == highWaterMark ? _self.highWaterMark : highWaterMark // ignore: cast_nullable_to_non_nullable
as int?,isPartialUpload: freezed == isPartialUpload ? _self.isPartialUpload : isPartialUpload // ignore: cast_nullable_to_non_nullable
as bool?,onUploadProgress: freezed == onUploadProgress ? _self.onUploadProgress : onUploadProgress // ignore: cast_nullable_to_non_nullable
as void Function(UploadProgress)?,
  ));
}

}



/// @nodoc


class _CreateWriteStreamOptions extends CreateWriteStreamOptions {
  const _CreateWriteStreamOptions({this.contentType, this.gzip, this.metadata, this.offset, this.predefinedAcl, this.private, this.public, this.resumable, this.timeout, this.uri, this.userProject, this.validation, this.resumeCRC32C, this.preconditionOpts, this.chunkSize, this.highWaterMark, this.isPartialUpload, this.onUploadProgress}): super._();
  

/// Content type of the file. If set to 'auto', the file name is used to determine the contentType.
@override final  String? contentType;
/// If true, automatically gzip the file. If null, the contentType is used to determine if the file should be gzipped (auto-detect).
@override final  bool? gzip;
/// Metadata for the file. See Objects: insert request body for details.
@override final  FileMetadata? metadata;
/// The starting byte of the upload stream, for resuming an interrupted upload. Defaults to 0.
@override final  int? offset;
/// Apply a predefined set of access controls to this object.
@override final  PredefinedAcl? predefinedAcl;
/// Make the uploaded file private. (Alias for predefinedAcl = 'private')
@override final  bool? private;
/// Make the uploaded file public. (Alias for predefinedAcl = 'publicRead')
@override final  bool? public;
/// Force a resumable upload. Defaults to true.
@override final  bool? resumable;
/// Set the HTTP request timeout in milliseconds. This option is not available for resumable uploads. Default: 60000
@override final  int? timeout;
/// The URI for an already-created resumable upload. See File.createResumableUpload().
@override final  String? uri;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Validation type for data integrity checks. By default, data integrity is validated with a CRC32c checksum.
@override final  ValidationType? validation;
/// A CRC32C to resume from when continuing a previous upload.
@override final  String? resumeCRC32C;
/// Precondition options for the upload.
@override final  PreconditionOptions? preconditionOpts;
/// Chunk size for resumable uploads. Default: 256KB
@override final  int? chunkSize;
/// High water mark for the stream. Controls buffer size.
@override final  int? highWaterMark;
/// Whether this is a partial upload.
@override final  bool? isPartialUpload;
/// Callback for upload progress events.
@override final  void Function(UploadProgress)? onUploadProgress;

/// Create a copy of CreateWriteStreamOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWriteStreamOptionsCopyWith<_CreateWriteStreamOptions> get copyWith => __$CreateWriteStreamOptionsCopyWithImpl<_CreateWriteStreamOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWriteStreamOptions&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.gzip, gzip) || other.gzip == gzip)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.private, private) || other.private == private)&&(identical(other.public, public) || other.public == public)&&(identical(other.resumable, resumable) || other.resumable == resumable)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.resumeCRC32C, resumeCRC32C) || other.resumeCRC32C == resumeCRC32C)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.chunkSize, chunkSize) || other.chunkSize == chunkSize)&&(identical(other.highWaterMark, highWaterMark) || other.highWaterMark == highWaterMark)&&(identical(other.isPartialUpload, isPartialUpload) || other.isPartialUpload == isPartialUpload)&&(identical(other.onUploadProgress, onUploadProgress) || other.onUploadProgress == onUploadProgress));
}


@override
int get hashCode => Object.hash(runtimeType,contentType,gzip,metadata,offset,predefinedAcl,private,public,resumable,timeout,uri,userProject,validation,resumeCRC32C,preconditionOpts,chunkSize,highWaterMark,isPartialUpload,onUploadProgress);

@override
String toString() {
  return 'CreateWriteStreamOptions(contentType: $contentType, gzip: $gzip, metadata: $metadata, offset: $offset, predefinedAcl: $predefinedAcl, private: $private, public: $public, resumable: $resumable, timeout: $timeout, uri: $uri, userProject: $userProject, validation: $validation, resumeCRC32C: $resumeCRC32C, preconditionOpts: $preconditionOpts, chunkSize: $chunkSize, highWaterMark: $highWaterMark, isPartialUpload: $isPartialUpload, onUploadProgress: $onUploadProgress)';
}


}

/// @nodoc
abstract mixin class _$CreateWriteStreamOptionsCopyWith<$Res> implements $CreateWriteStreamOptionsCopyWith<$Res> {
  factory _$CreateWriteStreamOptionsCopyWith(_CreateWriteStreamOptions value, $Res Function(_CreateWriteStreamOptions) _then) = __$CreateWriteStreamOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? contentType, bool? gzip, FileMetadata? metadata, int? offset, PredefinedAcl? predefinedAcl, bool? private, bool? public, bool? resumable, int? timeout, String? uri, String? userProject, ValidationType? validation, String? resumeCRC32C, PreconditionOptions? preconditionOpts, int? chunkSize, int? highWaterMark, bool? isPartialUpload, void Function(UploadProgress)? onUploadProgress
});




}
/// @nodoc
class __$CreateWriteStreamOptionsCopyWithImpl<$Res>
    implements _$CreateWriteStreamOptionsCopyWith<$Res> {
  __$CreateWriteStreamOptionsCopyWithImpl(this._self, this._then);

  final _CreateWriteStreamOptions _self;
  final $Res Function(_CreateWriteStreamOptions) _then;

/// Create a copy of CreateWriteStreamOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contentType = freezed,Object? gzip = freezed,Object? metadata = freezed,Object? offset = freezed,Object? predefinedAcl = freezed,Object? private = freezed,Object? public = freezed,Object? resumable = freezed,Object? timeout = freezed,Object? uri = freezed,Object? userProject = freezed,Object? validation = freezed,Object? resumeCRC32C = freezed,Object? preconditionOpts = freezed,Object? chunkSize = freezed,Object? highWaterMark = freezed,Object? isPartialUpload = freezed,Object? onUploadProgress = freezed,}) {
  return _then(_CreateWriteStreamOptions(
contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,gzip: freezed == gzip ? _self.gzip : gzip // ignore: cast_nullable_to_non_nullable
as bool?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as bool?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,resumable: freezed == resumable ? _self.resumable : resumable // ignore: cast_nullable_to_non_nullable
as bool?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,resumeCRC32C: freezed == resumeCRC32C ? _self.resumeCRC32C : resumeCRC32C // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,chunkSize: freezed == chunkSize ? _self.chunkSize : chunkSize // ignore: cast_nullable_to_non_nullable
as int?,highWaterMark: freezed == highWaterMark ? _self.highWaterMark : highWaterMark // ignore: cast_nullable_to_non_nullable
as int?,isPartialUpload: freezed == isPartialUpload ? _self.isPartialUpload : isPartialUpload // ignore: cast_nullable_to_non_nullable
as bool?,onUploadProgress: freezed == onUploadProgress ? _self.onUploadProgress : onUploadProgress // ignore: cast_nullable_to_non_nullable
as void Function(UploadProgress)?,
  ));
}


}

/// @nodoc
mixin _$SaveOptions {

 String? get contentType; bool? get gzip; FileMetadata? get metadata; int? get offset; PredefinedAcl? get predefinedAcl; bool? get private; bool? get public; bool? get resumable; int? get timeout; String? get uri; String? get userProject; ValidationType? get validation; String? get resumeCRC32C; PreconditionOptions? get preconditionOpts; int? get chunkSize; int? get highWaterMark; bool? get isPartialUpload;/// Callback for upload progress events.
 void Function(UploadProgress)? get onUploadProgress;
/// Create a copy of SaveOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveOptionsCopyWith<SaveOptions> get copyWith => _$SaveOptionsCopyWithImpl<SaveOptions>(this as SaveOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveOptions&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.gzip, gzip) || other.gzip == gzip)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.private, private) || other.private == private)&&(identical(other.public, public) || other.public == public)&&(identical(other.resumable, resumable) || other.resumable == resumable)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.resumeCRC32C, resumeCRC32C) || other.resumeCRC32C == resumeCRC32C)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.chunkSize, chunkSize) || other.chunkSize == chunkSize)&&(identical(other.highWaterMark, highWaterMark) || other.highWaterMark == highWaterMark)&&(identical(other.isPartialUpload, isPartialUpload) || other.isPartialUpload == isPartialUpload)&&(identical(other.onUploadProgress, onUploadProgress) || other.onUploadProgress == onUploadProgress));
}


@override
int get hashCode => Object.hash(runtimeType,contentType,gzip,metadata,offset,predefinedAcl,private,public,resumable,timeout,uri,userProject,validation,resumeCRC32C,preconditionOpts,chunkSize,highWaterMark,isPartialUpload,onUploadProgress);

@override
String toString() {
  return 'SaveOptions(contentType: $contentType, gzip: $gzip, metadata: $metadata, offset: $offset, predefinedAcl: $predefinedAcl, private: $private, public: $public, resumable: $resumable, timeout: $timeout, uri: $uri, userProject: $userProject, validation: $validation, resumeCRC32C: $resumeCRC32C, preconditionOpts: $preconditionOpts, chunkSize: $chunkSize, highWaterMark: $highWaterMark, isPartialUpload: $isPartialUpload, onUploadProgress: $onUploadProgress)';
}


}

/// @nodoc
abstract mixin class $SaveOptionsCopyWith<$Res> implements $CreateWriteStreamOptionsCopyWith<$Res> {
  factory $SaveOptionsCopyWith(SaveOptions value, $Res Function(SaveOptions) _then) = _$SaveOptionsCopyWithImpl;
@useResult
$Res call({
 String? contentType, bool? gzip, FileMetadata? metadata, int? offset, PredefinedAcl? predefinedAcl, bool? private, bool? public, bool? resumable, int? timeout, String? uri, String? userProject, ValidationType? validation, String? resumeCRC32C, PreconditionOptions? preconditionOpts, int? chunkSize, int? highWaterMark, bool? isPartialUpload, void Function(UploadProgress)? onUploadProgress
});




}
/// @nodoc
class _$SaveOptionsCopyWithImpl<$Res>
    implements $SaveOptionsCopyWith<$Res> {
  _$SaveOptionsCopyWithImpl(this._self, this._then);

  final SaveOptions _self;
  final $Res Function(SaveOptions) _then;

/// Create a copy of SaveOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contentType = freezed,Object? gzip = freezed,Object? metadata = freezed,Object? offset = freezed,Object? predefinedAcl = freezed,Object? private = freezed,Object? public = freezed,Object? resumable = freezed,Object? timeout = freezed,Object? uri = freezed,Object? userProject = freezed,Object? validation = freezed,Object? resumeCRC32C = freezed,Object? preconditionOpts = freezed,Object? chunkSize = freezed,Object? highWaterMark = freezed,Object? isPartialUpload = freezed,Object? onUploadProgress = freezed,}) {
  return _then(_self.copyWith(
contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,gzip: freezed == gzip ? _self.gzip : gzip // ignore: cast_nullable_to_non_nullable
as bool?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as bool?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,resumable: freezed == resumable ? _self.resumable : resumable // ignore: cast_nullable_to_non_nullable
as bool?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,resumeCRC32C: freezed == resumeCRC32C ? _self.resumeCRC32C : resumeCRC32C // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,chunkSize: freezed == chunkSize ? _self.chunkSize : chunkSize // ignore: cast_nullable_to_non_nullable
as int?,highWaterMark: freezed == highWaterMark ? _self.highWaterMark : highWaterMark // ignore: cast_nullable_to_non_nullable
as int?,isPartialUpload: freezed == isPartialUpload ? _self.isPartialUpload : isPartialUpload // ignore: cast_nullable_to_non_nullable
as bool?,onUploadProgress: freezed == onUploadProgress ? _self.onUploadProgress : onUploadProgress // ignore: cast_nullable_to_non_nullable
as void Function(UploadProgress)?,
  ));
}

}



/// @nodoc


class _SaveOptions extends SaveOptions {
  const _SaveOptions({this.contentType, this.gzip, this.metadata, this.offset, this.predefinedAcl, this.private, this.public, this.resumable, this.timeout, this.uri, this.userProject, this.validation, this.resumeCRC32C, this.preconditionOpts, this.chunkSize, this.highWaterMark, this.isPartialUpload, this.onUploadProgress}): super._();
  

@override final  String? contentType;
@override final  bool? gzip;
@override final  FileMetadata? metadata;
@override final  int? offset;
@override final  PredefinedAcl? predefinedAcl;
@override final  bool? private;
@override final  bool? public;
@override final  bool? resumable;
@override final  int? timeout;
@override final  String? uri;
@override final  String? userProject;
@override final  ValidationType? validation;
@override final  String? resumeCRC32C;
@override final  PreconditionOptions? preconditionOpts;
@override final  int? chunkSize;
@override final  int? highWaterMark;
@override final  bool? isPartialUpload;
/// Callback for upload progress events.
@override final  void Function(UploadProgress)? onUploadProgress;

/// Create a copy of SaveOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveOptionsCopyWith<_SaveOptions> get copyWith => __$SaveOptionsCopyWithImpl<_SaveOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveOptions&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.gzip, gzip) || other.gzip == gzip)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.private, private) || other.private == private)&&(identical(other.public, public) || other.public == public)&&(identical(other.resumable, resumable) || other.resumable == resumable)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.resumeCRC32C, resumeCRC32C) || other.resumeCRC32C == resumeCRC32C)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.chunkSize, chunkSize) || other.chunkSize == chunkSize)&&(identical(other.highWaterMark, highWaterMark) || other.highWaterMark == highWaterMark)&&(identical(other.isPartialUpload, isPartialUpload) || other.isPartialUpload == isPartialUpload)&&(identical(other.onUploadProgress, onUploadProgress) || other.onUploadProgress == onUploadProgress));
}


@override
int get hashCode => Object.hash(runtimeType,contentType,gzip,metadata,offset,predefinedAcl,private,public,resumable,timeout,uri,userProject,validation,resumeCRC32C,preconditionOpts,chunkSize,highWaterMark,isPartialUpload,onUploadProgress);

@override
String toString() {
  return 'SaveOptions(contentType: $contentType, gzip: $gzip, metadata: $metadata, offset: $offset, predefinedAcl: $predefinedAcl, private: $private, public: $public, resumable: $resumable, timeout: $timeout, uri: $uri, userProject: $userProject, validation: $validation, resumeCRC32C: $resumeCRC32C, preconditionOpts: $preconditionOpts, chunkSize: $chunkSize, highWaterMark: $highWaterMark, isPartialUpload: $isPartialUpload, onUploadProgress: $onUploadProgress)';
}


}

/// @nodoc
abstract mixin class _$SaveOptionsCopyWith<$Res> implements $SaveOptionsCopyWith<$Res> {
  factory _$SaveOptionsCopyWith(_SaveOptions value, $Res Function(_SaveOptions) _then) = __$SaveOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? contentType, bool? gzip, FileMetadata? metadata, int? offset, PredefinedAcl? predefinedAcl, bool? private, bool? public, bool? resumable, int? timeout, String? uri, String? userProject, ValidationType? validation, String? resumeCRC32C, PreconditionOptions? preconditionOpts, int? chunkSize, int? highWaterMark, bool? isPartialUpload, void Function(UploadProgress)? onUploadProgress
});




}
/// @nodoc
class __$SaveOptionsCopyWithImpl<$Res>
    implements _$SaveOptionsCopyWith<$Res> {
  __$SaveOptionsCopyWithImpl(this._self, this._then);

  final _SaveOptions _self;
  final $Res Function(_SaveOptions) _then;

/// Create a copy of SaveOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contentType = freezed,Object? gzip = freezed,Object? metadata = freezed,Object? offset = freezed,Object? predefinedAcl = freezed,Object? private = freezed,Object? public = freezed,Object? resumable = freezed,Object? timeout = freezed,Object? uri = freezed,Object? userProject = freezed,Object? validation = freezed,Object? resumeCRC32C = freezed,Object? preconditionOpts = freezed,Object? chunkSize = freezed,Object? highWaterMark = freezed,Object? isPartialUpload = freezed,Object? onUploadProgress = freezed,}) {
  return _then(_SaveOptions(
contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,gzip: freezed == gzip ? _self.gzip : gzip // ignore: cast_nullable_to_non_nullable
as bool?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as bool?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,resumable: freezed == resumable ? _self.resumable : resumable // ignore: cast_nullable_to_non_nullable
as bool?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,resumeCRC32C: freezed == resumeCRC32C ? _self.resumeCRC32C : resumeCRC32C // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,chunkSize: freezed == chunkSize ? _self.chunkSize : chunkSize // ignore: cast_nullable_to_non_nullable
as int?,highWaterMark: freezed == highWaterMark ? _self.highWaterMark : highWaterMark // ignore: cast_nullable_to_non_nullable
as int?,isPartialUpload: freezed == isPartialUpload ? _self.isPartialUpload : isPartialUpload // ignore: cast_nullable_to_non_nullable
as bool?,onUploadProgress: freezed == onUploadProgress ? _self.onUploadProgress : onUploadProgress // ignore: cast_nullable_to_non_nullable
as void Function(UploadProgress)?,
  ));
}


}

/// @nodoc
mixin _$CreateResumableUploadOptions {

/// Metadata for the file.
 FileMetadata? get metadata;/// The starting byte of the upload stream, for resuming an interrupted upload. Defaults to 0.
 int? get offset;/// Apply a predefined set of access controls to this object.
 PredefinedAcl? get predefinedAcl;/// Make the uploaded file private. (Alias for predefinedAcl = 'private')
 bool? get private;/// Make the uploaded file public. (Alias for predefinedAcl = 'publicRead')
 bool? get public;/// The URI for an already-created resumable upload.
 String? get uri;/// The ID of the project which will be billed for the request.
 String? get userProject;/// Precondition options for the upload.
 PreconditionOptions? get preconditionOpts;/// Chunk size for resumable uploads. Default: 256KB
 int? get chunkSize;/// High water mark for the stream. Controls buffer size.
 int? get highWaterMark;/// Whether this is a partial upload.
 bool? get isPartialUpload;
/// Create a copy of CreateResumableUploadOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateResumableUploadOptionsCopyWith<CreateResumableUploadOptions> get copyWith => _$CreateResumableUploadOptionsCopyWithImpl<CreateResumableUploadOptions>(this as CreateResumableUploadOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateResumableUploadOptions&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.private, private) || other.private == private)&&(identical(other.public, public) || other.public == public)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.chunkSize, chunkSize) || other.chunkSize == chunkSize)&&(identical(other.highWaterMark, highWaterMark) || other.highWaterMark == highWaterMark)&&(identical(other.isPartialUpload, isPartialUpload) || other.isPartialUpload == isPartialUpload));
}


@override
int get hashCode => Object.hash(runtimeType,metadata,offset,predefinedAcl,private,public,uri,userProject,preconditionOpts,chunkSize,highWaterMark,isPartialUpload);

@override
String toString() {
  return 'CreateResumableUploadOptions(metadata: $metadata, offset: $offset, predefinedAcl: $predefinedAcl, private: $private, public: $public, uri: $uri, userProject: $userProject, preconditionOpts: $preconditionOpts, chunkSize: $chunkSize, highWaterMark: $highWaterMark, isPartialUpload: $isPartialUpload)';
}


}

/// @nodoc
abstract mixin class $CreateResumableUploadOptionsCopyWith<$Res>  {
  factory $CreateResumableUploadOptionsCopyWith(CreateResumableUploadOptions value, $Res Function(CreateResumableUploadOptions) _then) = _$CreateResumableUploadOptionsCopyWithImpl;
@useResult
$Res call({
 FileMetadata? metadata, int? offset, PredefinedAcl? predefinedAcl, bool? private, bool? public, String? uri, String? userProject, PreconditionOptions? preconditionOpts, int? chunkSize, int? highWaterMark, bool? isPartialUpload
});




}
/// @nodoc
class _$CreateResumableUploadOptionsCopyWithImpl<$Res>
    implements $CreateResumableUploadOptionsCopyWith<$Res> {
  _$CreateResumableUploadOptionsCopyWithImpl(this._self, this._then);

  final CreateResumableUploadOptions _self;
  final $Res Function(CreateResumableUploadOptions) _then;

/// Create a copy of CreateResumableUploadOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metadata = freezed,Object? offset = freezed,Object? predefinedAcl = freezed,Object? private = freezed,Object? public = freezed,Object? uri = freezed,Object? userProject = freezed,Object? preconditionOpts = freezed,Object? chunkSize = freezed,Object? highWaterMark = freezed,Object? isPartialUpload = freezed,}) {
  return _then(_self.copyWith(
metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as bool?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,chunkSize: freezed == chunkSize ? _self.chunkSize : chunkSize // ignore: cast_nullable_to_non_nullable
as int?,highWaterMark: freezed == highWaterMark ? _self.highWaterMark : highWaterMark // ignore: cast_nullable_to_non_nullable
as int?,isPartialUpload: freezed == isPartialUpload ? _self.isPartialUpload : isPartialUpload // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}



/// @nodoc


class _CreateResumableUploadOptions implements CreateResumableUploadOptions {
  const _CreateResumableUploadOptions({this.metadata, this.offset, this.predefinedAcl, this.private, this.public, this.uri, this.userProject, this.preconditionOpts, this.chunkSize, this.highWaterMark, this.isPartialUpload});
  

/// Metadata for the file.
@override final  FileMetadata? metadata;
/// The starting byte of the upload stream, for resuming an interrupted upload. Defaults to 0.
@override final  int? offset;
/// Apply a predefined set of access controls to this object.
@override final  PredefinedAcl? predefinedAcl;
/// Make the uploaded file private. (Alias for predefinedAcl = 'private')
@override final  bool? private;
/// Make the uploaded file public. (Alias for predefinedAcl = 'publicRead')
@override final  bool? public;
/// The URI for an already-created resumable upload.
@override final  String? uri;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Precondition options for the upload.
@override final  PreconditionOptions? preconditionOpts;
/// Chunk size for resumable uploads. Default: 256KB
@override final  int? chunkSize;
/// High water mark for the stream. Controls buffer size.
@override final  int? highWaterMark;
/// Whether this is a partial upload.
@override final  bool? isPartialUpload;

/// Create a copy of CreateResumableUploadOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateResumableUploadOptionsCopyWith<_CreateResumableUploadOptions> get copyWith => __$CreateResumableUploadOptionsCopyWithImpl<_CreateResumableUploadOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateResumableUploadOptions&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.predefinedAcl, predefinedAcl) || other.predefinedAcl == predefinedAcl)&&(identical(other.private, private) || other.private == private)&&(identical(other.public, public) || other.public == public)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.preconditionOpts, preconditionOpts) || other.preconditionOpts == preconditionOpts)&&(identical(other.chunkSize, chunkSize) || other.chunkSize == chunkSize)&&(identical(other.highWaterMark, highWaterMark) || other.highWaterMark == highWaterMark)&&(identical(other.isPartialUpload, isPartialUpload) || other.isPartialUpload == isPartialUpload));
}


@override
int get hashCode => Object.hash(runtimeType,metadata,offset,predefinedAcl,private,public,uri,userProject,preconditionOpts,chunkSize,highWaterMark,isPartialUpload);

@override
String toString() {
  return 'CreateResumableUploadOptions(metadata: $metadata, offset: $offset, predefinedAcl: $predefinedAcl, private: $private, public: $public, uri: $uri, userProject: $userProject, preconditionOpts: $preconditionOpts, chunkSize: $chunkSize, highWaterMark: $highWaterMark, isPartialUpload: $isPartialUpload)';
}


}

/// @nodoc
abstract mixin class _$CreateResumableUploadOptionsCopyWith<$Res> implements $CreateResumableUploadOptionsCopyWith<$Res> {
  factory _$CreateResumableUploadOptionsCopyWith(_CreateResumableUploadOptions value, $Res Function(_CreateResumableUploadOptions) _then) = __$CreateResumableUploadOptionsCopyWithImpl;
@override @useResult
$Res call({
 FileMetadata? metadata, int? offset, PredefinedAcl? predefinedAcl, bool? private, bool? public, String? uri, String? userProject, PreconditionOptions? preconditionOpts, int? chunkSize, int? highWaterMark, bool? isPartialUpload
});




}
/// @nodoc
class __$CreateResumableUploadOptionsCopyWithImpl<$Res>
    implements _$CreateResumableUploadOptionsCopyWith<$Res> {
  __$CreateResumableUploadOptionsCopyWithImpl(this._self, this._then);

  final _CreateResumableUploadOptions _self;
  final $Res Function(_CreateResumableUploadOptions) _then;

/// Create a copy of CreateResumableUploadOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metadata = freezed,Object? offset = freezed,Object? predefinedAcl = freezed,Object? private = freezed,Object? public = freezed,Object? uri = freezed,Object? userProject = freezed,Object? preconditionOpts = freezed,Object? chunkSize = freezed,Object? highWaterMark = freezed,Object? isPartialUpload = freezed,}) {
  return _then(_CreateResumableUploadOptions(
metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,predefinedAcl: freezed == predefinedAcl ? _self.predefinedAcl : predefinedAcl // ignore: cast_nullable_to_non_nullable
as PredefinedAcl?,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as bool?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,preconditionOpts: freezed == preconditionOpts ? _self.preconditionOpts : preconditionOpts // ignore: cast_nullable_to_non_nullable
as PreconditionOptions?,chunkSize: freezed == chunkSize ? _self.chunkSize : chunkSize // ignore: cast_nullable_to_non_nullable
as int?,highWaterMark: freezed == highWaterMark ? _self.highWaterMark : highWaterMark // ignore: cast_nullable_to_non_nullable
as int?,isPartialUpload: freezed == isPartialUpload ? _self.isPartialUpload : isPartialUpload // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$CreateReadStreamOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;/// Data integrity validation type.
 ValidationType? get validation;/// Start byte for range requests.
 int? get start;/// End byte for range requests. Negative values indicate tail requests.
 int? get end;/// Whether to decompress gzip content. Defaults to true.
 bool? get decompress;
/// Create a copy of CreateReadStreamOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateReadStreamOptionsCopyWith<CreateReadStreamOptions> get copyWith => _$CreateReadStreamOptionsCopyWithImpl<CreateReadStreamOptions>(this as CreateReadStreamOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateReadStreamOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.decompress, decompress) || other.decompress == decompress));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,validation,start,end,decompress);

@override
String toString() {
  return 'CreateReadStreamOptions(userProject: $userProject, validation: $validation, start: $start, end: $end, decompress: $decompress)';
}


}

/// @nodoc
abstract mixin class $CreateReadStreamOptionsCopyWith<$Res>  {
  factory $CreateReadStreamOptionsCopyWith(CreateReadStreamOptions value, $Res Function(CreateReadStreamOptions) _then) = _$CreateReadStreamOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject, ValidationType? validation, int? start, int? end, bool? decompress
});




}
/// @nodoc
class _$CreateReadStreamOptionsCopyWithImpl<$Res>
    implements $CreateReadStreamOptionsCopyWith<$Res> {
  _$CreateReadStreamOptionsCopyWithImpl(this._self, this._then);

  final CreateReadStreamOptions _self;
  final $Res Function(CreateReadStreamOptions) _then;

/// Create a copy of CreateReadStreamOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,Object? validation = freezed,Object? start = freezed,Object? end = freezed,Object? decompress = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int?,decompress: freezed == decompress ? _self.decompress : decompress // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}



/// @nodoc


class _CreateReadStreamOptions implements CreateReadStreamOptions {
  const _CreateReadStreamOptions({this.userProject, this.validation, this.start, this.end, this.decompress});
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Data integrity validation type.
@override final  ValidationType? validation;
/// Start byte for range requests.
@override final  int? start;
/// End byte for range requests. Negative values indicate tail requests.
@override final  int? end;
/// Whether to decompress gzip content. Defaults to true.
@override final  bool? decompress;

/// Create a copy of CreateReadStreamOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateReadStreamOptionsCopyWith<_CreateReadStreamOptions> get copyWith => __$CreateReadStreamOptionsCopyWithImpl<_CreateReadStreamOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateReadStreamOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.decompress, decompress) || other.decompress == decompress));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,validation,start,end,decompress);

@override
String toString() {
  return 'CreateReadStreamOptions(userProject: $userProject, validation: $validation, start: $start, end: $end, decompress: $decompress)';
}


}

/// @nodoc
abstract mixin class _$CreateReadStreamOptionsCopyWith<$Res> implements $CreateReadStreamOptionsCopyWith<$Res> {
  factory _$CreateReadStreamOptionsCopyWith(_CreateReadStreamOptions value, $Res Function(_CreateReadStreamOptions) _then) = __$CreateReadStreamOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject, ValidationType? validation, int? start, int? end, bool? decompress
});




}
/// @nodoc
class __$CreateReadStreamOptionsCopyWithImpl<$Res>
    implements _$CreateReadStreamOptionsCopyWith<$Res> {
  __$CreateReadStreamOptionsCopyWithImpl(this._self, this._then);

  final _CreateReadStreamOptions _self;
  final $Res Function(_CreateReadStreamOptions) _then;

/// Create a copy of CreateReadStreamOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,Object? validation = freezed,Object? start = freezed,Object? end = freezed,Object? decompress = freezed,}) {
  return _then(_CreateReadStreamOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int?,decompress: freezed == decompress ? _self.decompress : decompress // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$DownloadOptions {

/// Local file to write the downloaded content to.
 io.File? get destination;/// Customer-supplied encryption key.
 EncryptionKey? get encryptionKey;// CreateReadStreamOptions fields
 String? get userProject; ValidationType? get validation; int? get start; int? get end; bool? get decompress;
/// Create a copy of DownloadOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadOptionsCopyWith<DownloadOptions> get copyWith => _$DownloadOptionsCopyWithImpl<DownloadOptions>(this as DownloadOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadOptions&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.encryptionKey, encryptionKey) || other.encryptionKey == encryptionKey)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.decompress, decompress) || other.decompress == decompress));
}


@override
int get hashCode => Object.hash(runtimeType,destination,encryptionKey,userProject,validation,start,end,decompress);

@override
String toString() {
  return 'DownloadOptions(destination: $destination, encryptionKey: $encryptionKey, userProject: $userProject, validation: $validation, start: $start, end: $end, decompress: $decompress)';
}


}

/// @nodoc
abstract mixin class $DownloadOptionsCopyWith<$Res>  {
  factory $DownloadOptionsCopyWith(DownloadOptions value, $Res Function(DownloadOptions) _then) = _$DownloadOptionsCopyWithImpl;
@useResult
$Res call({
 io.File? destination, EncryptionKey? encryptionKey, String? userProject, ValidationType? validation, int? start, int? end, bool? decompress
});


$EncryptionKeyCopyWith<$Res>? get encryptionKey;

}
/// @nodoc
class _$DownloadOptionsCopyWithImpl<$Res>
    implements $DownloadOptionsCopyWith<$Res> {
  _$DownloadOptionsCopyWithImpl(this._self, this._then);

  final DownloadOptions _self;
  final $Res Function(DownloadOptions) _then;

/// Create a copy of DownloadOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? destination = freezed,Object? encryptionKey = freezed,Object? userProject = freezed,Object? validation = freezed,Object? start = freezed,Object? end = freezed,Object? decompress = freezed,}) {
  return _then(_self.copyWith(
destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as io.File?,encryptionKey: freezed == encryptionKey ? _self.encryptionKey : encryptionKey // ignore: cast_nullable_to_non_nullable
as EncryptionKey?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int?,decompress: freezed == decompress ? _self.decompress : decompress // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of DownloadOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncryptionKeyCopyWith<$Res>? get encryptionKey {
    if (_self.encryptionKey == null) {
    return null;
  }

  return $EncryptionKeyCopyWith<$Res>(_self.encryptionKey!, (value) {
    return _then(_self.copyWith(encryptionKey: value));
  });
}
}



/// @nodoc


class _DownloadOptions implements DownloadOptions {
  const _DownloadOptions({this.destination, this.encryptionKey, this.userProject, this.validation, this.start, this.end, this.decompress});
  

/// Local file to write the downloaded content to.
@override final  io.File? destination;
/// Customer-supplied encryption key.
@override final  EncryptionKey? encryptionKey;
// CreateReadStreamOptions fields
@override final  String? userProject;
@override final  ValidationType? validation;
@override final  int? start;
@override final  int? end;
@override final  bool? decompress;

/// Create a copy of DownloadOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadOptionsCopyWith<_DownloadOptions> get copyWith => __$DownloadOptionsCopyWithImpl<_DownloadOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadOptions&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.encryptionKey, encryptionKey) || other.encryptionKey == encryptionKey)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.decompress, decompress) || other.decompress == decompress));
}


@override
int get hashCode => Object.hash(runtimeType,destination,encryptionKey,userProject,validation,start,end,decompress);

@override
String toString() {
  return 'DownloadOptions(destination: $destination, encryptionKey: $encryptionKey, userProject: $userProject, validation: $validation, start: $start, end: $end, decompress: $decompress)';
}


}

/// @nodoc
abstract mixin class _$DownloadOptionsCopyWith<$Res> implements $DownloadOptionsCopyWith<$Res> {
  factory _$DownloadOptionsCopyWith(_DownloadOptions value, $Res Function(_DownloadOptions) _then) = __$DownloadOptionsCopyWithImpl;
@override @useResult
$Res call({
 io.File? destination, EncryptionKey? encryptionKey, String? userProject, ValidationType? validation, int? start, int? end, bool? decompress
});


@override $EncryptionKeyCopyWith<$Res>? get encryptionKey;

}
/// @nodoc
class __$DownloadOptionsCopyWithImpl<$Res>
    implements _$DownloadOptionsCopyWith<$Res> {
  __$DownloadOptionsCopyWithImpl(this._self, this._then);

  final _DownloadOptions _self;
  final $Res Function(_DownloadOptions) _then;

/// Create a copy of DownloadOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? destination = freezed,Object? encryptionKey = freezed,Object? userProject = freezed,Object? validation = freezed,Object? start = freezed,Object? end = freezed,Object? decompress = freezed,}) {
  return _then(_DownloadOptions(
destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as io.File?,encryptionKey: freezed == encryptionKey ? _self.encryptionKey : encryptionKey // ignore: cast_nullable_to_non_nullable
as EncryptionKey?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int?,decompress: freezed == decompress ? _self.decompress : decompress // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of DownloadOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncryptionKeyCopyWith<$Res>? get encryptionKey {
    if (_self.encryptionKey == null) {
    return null;
  }

  return $EncryptionKeyCopyWith<$Res>(_self.encryptionKey!, (value) {
    return _then(_self.copyWith(encryptionKey: value));
  });
}
}

/// @nodoc
mixin _$EncryptionKey {

/// The encryption key encoded as base64.
 String get keyBase64;/// The SHA256 hash of the key, encoded as base64.
 String get keyHash;
/// Create a copy of EncryptionKey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncryptionKeyCopyWith<EncryptionKey> get copyWith => _$EncryptionKeyCopyWithImpl<EncryptionKey>(this as EncryptionKey, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncryptionKey&&(identical(other.keyBase64, keyBase64) || other.keyBase64 == keyBase64)&&(identical(other.keyHash, keyHash) || other.keyHash == keyHash));
}


@override
int get hashCode => Object.hash(runtimeType,keyBase64,keyHash);

@override
String toString() {
  return 'EncryptionKey(keyBase64: $keyBase64, keyHash: $keyHash)';
}


}

/// @nodoc
abstract mixin class $EncryptionKeyCopyWith<$Res>  {
  factory $EncryptionKeyCopyWith(EncryptionKey value, $Res Function(EncryptionKey) _then) = _$EncryptionKeyCopyWithImpl;
@useResult
$Res call({
 String keyBase64, String keyHash
});




}
/// @nodoc
class _$EncryptionKeyCopyWithImpl<$Res>
    implements $EncryptionKeyCopyWith<$Res> {
  _$EncryptionKeyCopyWithImpl(this._self, this._then);

  final EncryptionKey _self;
  final $Res Function(EncryptionKey) _then;

/// Create a copy of EncryptionKey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keyBase64 = null,Object? keyHash = null,}) {
  return _then(_self.copyWith(
keyBase64: null == keyBase64 ? _self.keyBase64 : keyBase64 // ignore: cast_nullable_to_non_nullable
as String,keyHash: null == keyHash ? _self.keyHash : keyHash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}



/// @nodoc


class _EncryptionKey implements EncryptionKey {
  const _EncryptionKey({required this.keyBase64, required this.keyHash});
  

/// The encryption key encoded as base64.
@override final  String keyBase64;
/// The SHA256 hash of the key, encoded as base64.
@override final  String keyHash;

/// Create a copy of EncryptionKey
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptionKeyCopyWith<_EncryptionKey> get copyWith => __$EncryptionKeyCopyWithImpl<_EncryptionKey>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncryptionKey&&(identical(other.keyBase64, keyBase64) || other.keyBase64 == keyBase64)&&(identical(other.keyHash, keyHash) || other.keyHash == keyHash));
}


@override
int get hashCode => Object.hash(runtimeType,keyBase64,keyHash);

@override
String toString() {
  return 'EncryptionKey(keyBase64: $keyBase64, keyHash: $keyHash)';
}


}

/// @nodoc
abstract mixin class _$EncryptionKeyCopyWith<$Res> implements $EncryptionKeyCopyWith<$Res> {
  factory _$EncryptionKeyCopyWith(_EncryptionKey value, $Res Function(_EncryptionKey) _then) = __$EncryptionKeyCopyWithImpl;
@override @useResult
$Res call({
 String keyBase64, String keyHash
});




}
/// @nodoc
class __$EncryptionKeyCopyWithImpl<$Res>
    implements _$EncryptionKeyCopyWith<$Res> {
  __$EncryptionKeyCopyWithImpl(this._self, this._then);

  final _EncryptionKey _self;
  final $Res Function(_EncryptionKey) _then;

/// Create a copy of EncryptionKey
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keyBase64 = null,Object? keyHash = null,}) {
  return _then(_EncryptionKey(
keyBase64: null == keyBase64 ? _self.keyBase64 : keyBase64 // ignore: cast_nullable_to_non_nullable
as String,keyHash: null == keyHash ? _self.keyHash : keyHash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$HmacKeyOptions {

/// The project ID. If not provided, uses the default project.
 String? get projectId;
/// Create a copy of HmacKeyOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HmacKeyOptionsCopyWith<HmacKeyOptions> get copyWith => _$HmacKeyOptionsCopyWithImpl<HmacKeyOptions>(this as HmacKeyOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HmacKeyOptions&&(identical(other.projectId, projectId) || other.projectId == projectId));
}


@override
int get hashCode => Object.hash(runtimeType,projectId);

@override
String toString() {
  return 'HmacKeyOptions(projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class $HmacKeyOptionsCopyWith<$Res>  {
  factory $HmacKeyOptionsCopyWith(HmacKeyOptions value, $Res Function(HmacKeyOptions) _then) = _$HmacKeyOptionsCopyWithImpl;
@useResult
$Res call({
 String? projectId
});




}
/// @nodoc
class _$HmacKeyOptionsCopyWithImpl<$Res>
    implements $HmacKeyOptionsCopyWith<$Res> {
  _$HmacKeyOptionsCopyWithImpl(this._self, this._then);

  final HmacKeyOptions _self;
  final $Res Function(HmacKeyOptions) _then;

/// Create a copy of HmacKeyOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? projectId = freezed,}) {
  return _then(_self.copyWith(
projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _HmacKeyOptions implements HmacKeyOptions {
  const _HmacKeyOptions({this.projectId});
  

/// The project ID. If not provided, uses the default project.
@override final  String? projectId;

/// Create a copy of HmacKeyOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HmacKeyOptionsCopyWith<_HmacKeyOptions> get copyWith => __$HmacKeyOptionsCopyWithImpl<_HmacKeyOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HmacKeyOptions&&(identical(other.projectId, projectId) || other.projectId == projectId));
}


@override
int get hashCode => Object.hash(runtimeType,projectId);

@override
String toString() {
  return 'HmacKeyOptions(projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class _$HmacKeyOptionsCopyWith<$Res> implements $HmacKeyOptionsCopyWith<$Res> {
  factory _$HmacKeyOptionsCopyWith(_HmacKeyOptions value, $Res Function(_HmacKeyOptions) _then) = __$HmacKeyOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? projectId
});




}
/// @nodoc
class __$HmacKeyOptionsCopyWithImpl<$Res>
    implements _$HmacKeyOptionsCopyWith<$Res> {
  __$HmacKeyOptionsCopyWithImpl(this._self, this._then);

  final _HmacKeyOptions _self;
  final $Res Function(_HmacKeyOptions) _then;

/// Create a copy of HmacKeyOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? projectId = freezed,}) {
  return _then(_HmacKeyOptions(
projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CreateHmacKeyOptions {

/// The project ID. If not provided, uses the default project.
 String? get projectId;/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of CreateHmacKeyOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateHmacKeyOptionsCopyWith<CreateHmacKeyOptions> get copyWith => _$CreateHmacKeyOptionsCopyWithImpl<CreateHmacKeyOptions>(this as CreateHmacKeyOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateHmacKeyOptions&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,projectId,userProject);

@override
String toString() {
  return 'CreateHmacKeyOptions(projectId: $projectId, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $CreateHmacKeyOptionsCopyWith<$Res>  {
  factory $CreateHmacKeyOptionsCopyWith(CreateHmacKeyOptions value, $Res Function(CreateHmacKeyOptions) _then) = _$CreateHmacKeyOptionsCopyWithImpl;
@useResult
$Res call({
 String? projectId, String? userProject
});




}
/// @nodoc
class _$CreateHmacKeyOptionsCopyWithImpl<$Res>
    implements $CreateHmacKeyOptionsCopyWith<$Res> {
  _$CreateHmacKeyOptionsCopyWithImpl(this._self, this._then);

  final CreateHmacKeyOptions _self;
  final $Res Function(CreateHmacKeyOptions) _then;

/// Create a copy of CreateHmacKeyOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? projectId = freezed,Object? userProject = freezed,}) {
  return _then(_self.copyWith(
projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _CreateHmacKeyOptions implements CreateHmacKeyOptions {
  const _CreateHmacKeyOptions({this.projectId, this.userProject});
  

/// The project ID. If not provided, uses the default project.
@override final  String? projectId;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of CreateHmacKeyOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateHmacKeyOptionsCopyWith<_CreateHmacKeyOptions> get copyWith => __$CreateHmacKeyOptionsCopyWithImpl<_CreateHmacKeyOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateHmacKeyOptions&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,projectId,userProject);

@override
String toString() {
  return 'CreateHmacKeyOptions(projectId: $projectId, userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$CreateHmacKeyOptionsCopyWith<$Res> implements $CreateHmacKeyOptionsCopyWith<$Res> {
  factory _$CreateHmacKeyOptionsCopyWith(_CreateHmacKeyOptions value, $Res Function(_CreateHmacKeyOptions) _then) = __$CreateHmacKeyOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? projectId, String? userProject
});




}
/// @nodoc
class __$CreateHmacKeyOptionsCopyWithImpl<$Res>
    implements _$CreateHmacKeyOptionsCopyWith<$Res> {
  __$CreateHmacKeyOptionsCopyWithImpl(this._self, this._then);

  final _CreateHmacKeyOptions _self;
  final $Res Function(_CreateHmacKeyOptions) _then;

/// Create a copy of CreateHmacKeyOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? projectId = freezed,Object? userProject = freezed,}) {
  return _then(_CreateHmacKeyOptions(
projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$GetHmacKeysOptions {

/// Automatically paginate through all results. Defaults to `true`.
 bool? get autoPaginate;/// The project ID. If not provided, uses the default project.
 String? get projectId;/// The ID of the project which will be billed for the request.
 String? get userProject;/// Filter results to keys for this service account email.
 String? get serviceAccountEmail;/// If `true`, include deleted keys in the results.
 bool? get showDeletedKeys;/// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
 int? get maxApiCalls;/// Maximum number of results to return per page.
 int? get maxResults;/// Token for the next page of results.
 String? get pageToken;
/// Create a copy of GetHmacKeysOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetHmacKeysOptionsCopyWith<GetHmacKeysOptions> get copyWith => _$GetHmacKeysOptionsCopyWithImpl<GetHmacKeysOptions>(this as GetHmacKeysOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetHmacKeysOptions&&(identical(other.autoPaginate, autoPaginate) || other.autoPaginate == autoPaginate)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.serviceAccountEmail, serviceAccountEmail) || other.serviceAccountEmail == serviceAccountEmail)&&(identical(other.showDeletedKeys, showDeletedKeys) || other.showDeletedKeys == showDeletedKeys)&&(identical(other.maxApiCalls, maxApiCalls) || other.maxApiCalls == maxApiCalls)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken));
}


@override
int get hashCode => Object.hash(runtimeType,autoPaginate,projectId,userProject,serviceAccountEmail,showDeletedKeys,maxApiCalls,maxResults,pageToken);

@override
String toString() {
  return 'GetHmacKeysOptions(autoPaginate: $autoPaginate, projectId: $projectId, userProject: $userProject, serviceAccountEmail: $serviceAccountEmail, showDeletedKeys: $showDeletedKeys, maxApiCalls: $maxApiCalls, maxResults: $maxResults, pageToken: $pageToken)';
}


}

/// @nodoc
abstract mixin class $GetHmacKeysOptionsCopyWith<$Res>  {
  factory $GetHmacKeysOptionsCopyWith(GetHmacKeysOptions value, $Res Function(GetHmacKeysOptions) _then) = _$GetHmacKeysOptionsCopyWithImpl;
@useResult
$Res call({
 bool? autoPaginate, String? projectId, String? userProject, String? serviceAccountEmail, bool? showDeletedKeys, int? maxApiCalls, int? maxResults, String? pageToken
});




}
/// @nodoc
class _$GetHmacKeysOptionsCopyWithImpl<$Res>
    implements $GetHmacKeysOptionsCopyWith<$Res> {
  _$GetHmacKeysOptionsCopyWithImpl(this._self, this._then);

  final GetHmacKeysOptions _self;
  final $Res Function(GetHmacKeysOptions) _then;

/// Create a copy of GetHmacKeysOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? autoPaginate = freezed,Object? projectId = freezed,Object? userProject = freezed,Object? serviceAccountEmail = freezed,Object? showDeletedKeys = freezed,Object? maxApiCalls = freezed,Object? maxResults = freezed,Object? pageToken = freezed,}) {
  return _then(_self.copyWith(
autoPaginate: freezed == autoPaginate ? _self.autoPaginate : autoPaginate // ignore: cast_nullable_to_non_nullable
as bool?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,serviceAccountEmail: freezed == serviceAccountEmail ? _self.serviceAccountEmail : serviceAccountEmail // ignore: cast_nullable_to_non_nullable
as String?,showDeletedKeys: freezed == showDeletedKeys ? _self.showDeletedKeys : showDeletedKeys // ignore: cast_nullable_to_non_nullable
as bool?,maxApiCalls: freezed == maxApiCalls ? _self.maxApiCalls : maxApiCalls // ignore: cast_nullable_to_non_nullable
as int?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _GetHmacKeysOptions implements GetHmacKeysOptions {
  const _GetHmacKeysOptions({this.autoPaginate = true, this.projectId, this.userProject, this.serviceAccountEmail, this.showDeletedKeys, this.maxApiCalls, this.maxResults, this.pageToken});
  

/// Automatically paginate through all results. Defaults to `true`.
@override@JsonKey() final  bool? autoPaginate;
/// The project ID. If not provided, uses the default project.
@override final  String? projectId;
/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// Filter results to keys for this service account email.
@override final  String? serviceAccountEmail;
/// If `true`, include deleted keys in the results.
@override final  bool? showDeletedKeys;
/// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
@override final  int? maxApiCalls;
/// Maximum number of results to return per page.
@override final  int? maxResults;
/// Token for the next page of results.
@override final  String? pageToken;

/// Create a copy of GetHmacKeysOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetHmacKeysOptionsCopyWith<_GetHmacKeysOptions> get copyWith => __$GetHmacKeysOptionsCopyWithImpl<_GetHmacKeysOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetHmacKeysOptions&&(identical(other.autoPaginate, autoPaginate) || other.autoPaginate == autoPaginate)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.serviceAccountEmail, serviceAccountEmail) || other.serviceAccountEmail == serviceAccountEmail)&&(identical(other.showDeletedKeys, showDeletedKeys) || other.showDeletedKeys == showDeletedKeys)&&(identical(other.maxApiCalls, maxApiCalls) || other.maxApiCalls == maxApiCalls)&&(identical(other.maxResults, maxResults) || other.maxResults == maxResults)&&(identical(other.pageToken, pageToken) || other.pageToken == pageToken));
}


@override
int get hashCode => Object.hash(runtimeType,autoPaginate,projectId,userProject,serviceAccountEmail,showDeletedKeys,maxApiCalls,maxResults,pageToken);

@override
String toString() {
  return 'GetHmacKeysOptions(autoPaginate: $autoPaginate, projectId: $projectId, userProject: $userProject, serviceAccountEmail: $serviceAccountEmail, showDeletedKeys: $showDeletedKeys, maxApiCalls: $maxApiCalls, maxResults: $maxResults, pageToken: $pageToken)';
}


}

/// @nodoc
abstract mixin class _$GetHmacKeysOptionsCopyWith<$Res> implements $GetHmacKeysOptionsCopyWith<$Res> {
  factory _$GetHmacKeysOptionsCopyWith(_GetHmacKeysOptions value, $Res Function(_GetHmacKeysOptions) _then) = __$GetHmacKeysOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool? autoPaginate, String? projectId, String? userProject, String? serviceAccountEmail, bool? showDeletedKeys, int? maxApiCalls, int? maxResults, String? pageToken
});




}
/// @nodoc
class __$GetHmacKeysOptionsCopyWithImpl<$Res>
    implements _$GetHmacKeysOptionsCopyWith<$Res> {
  __$GetHmacKeysOptionsCopyWithImpl(this._self, this._then);

  final _GetHmacKeysOptions _self;
  final $Res Function(_GetHmacKeysOptions) _then;

/// Create a copy of GetHmacKeysOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoPaginate = freezed,Object? projectId = freezed,Object? userProject = freezed,Object? serviceAccountEmail = freezed,Object? showDeletedKeys = freezed,Object? maxApiCalls = freezed,Object? maxResults = freezed,Object? pageToken = freezed,}) {
  return _then(_GetHmacKeysOptions(
autoPaginate: freezed == autoPaginate ? _self.autoPaginate : autoPaginate // ignore: cast_nullable_to_non_nullable
as bool?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,serviceAccountEmail: freezed == serviceAccountEmail ? _self.serviceAccountEmail : serviceAccountEmail // ignore: cast_nullable_to_non_nullable
as String?,showDeletedKeys: freezed == showDeletedKeys ? _self.showDeletedKeys : showDeletedKeys // ignore: cast_nullable_to_non_nullable
as bool?,maxApiCalls: freezed == maxApiCalls ? _self.maxApiCalls : maxApiCalls // ignore: cast_nullable_to_non_nullable
as int?,maxResults: freezed == maxResults ? _self.maxResults : maxResults // ignore: cast_nullable_to_non_nullable
as int?,pageToken: freezed == pageToken ? _self.pageToken : pageToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$GetPolicyOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;/// The version of the policy to retrieve.
 int? get requestedPolicyVersion;
/// Create a copy of GetPolicyOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetPolicyOptionsCopyWith<GetPolicyOptions> get copyWith => _$GetPolicyOptionsCopyWithImpl<GetPolicyOptions>(this as GetPolicyOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetPolicyOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.requestedPolicyVersion, requestedPolicyVersion) || other.requestedPolicyVersion == requestedPolicyVersion));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,requestedPolicyVersion);

@override
String toString() {
  return 'GetPolicyOptions(userProject: $userProject, requestedPolicyVersion: $requestedPolicyVersion)';
}


}

/// @nodoc
abstract mixin class $GetPolicyOptionsCopyWith<$Res>  {
  factory $GetPolicyOptionsCopyWith(GetPolicyOptions value, $Res Function(GetPolicyOptions) _then) = _$GetPolicyOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject, int? requestedPolicyVersion
});




}
/// @nodoc
class _$GetPolicyOptionsCopyWithImpl<$Res>
    implements $GetPolicyOptionsCopyWith<$Res> {
  _$GetPolicyOptionsCopyWithImpl(this._self, this._then);

  final GetPolicyOptions _self;
  final $Res Function(GetPolicyOptions) _then;

/// Create a copy of GetPolicyOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,Object? requestedPolicyVersion = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,requestedPolicyVersion: freezed == requestedPolicyVersion ? _self.requestedPolicyVersion : requestedPolicyVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc


class _GetPolicyOptions implements GetPolicyOptions {
  const _GetPolicyOptions({this.userProject, this.requestedPolicyVersion});
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;
/// The version of the policy to retrieve.
@override final  int? requestedPolicyVersion;

/// Create a copy of GetPolicyOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetPolicyOptionsCopyWith<_GetPolicyOptions> get copyWith => __$GetPolicyOptionsCopyWithImpl<_GetPolicyOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetPolicyOptions&&(identical(other.userProject, userProject) || other.userProject == userProject)&&(identical(other.requestedPolicyVersion, requestedPolicyVersion) || other.requestedPolicyVersion == requestedPolicyVersion));
}


@override
int get hashCode => Object.hash(runtimeType,userProject,requestedPolicyVersion);

@override
String toString() {
  return 'GetPolicyOptions(userProject: $userProject, requestedPolicyVersion: $requestedPolicyVersion)';
}


}

/// @nodoc
abstract mixin class _$GetPolicyOptionsCopyWith<$Res> implements $GetPolicyOptionsCopyWith<$Res> {
  factory _$GetPolicyOptionsCopyWith(_GetPolicyOptions value, $Res Function(_GetPolicyOptions) _then) = __$GetPolicyOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject, int? requestedPolicyVersion
});




}
/// @nodoc
class __$GetPolicyOptionsCopyWithImpl<$Res>
    implements _$GetPolicyOptionsCopyWith<$Res> {
  __$GetPolicyOptionsCopyWithImpl(this._self, this._then);

  final _GetPolicyOptions _self;
  final $Res Function(_GetPolicyOptions) _then;

/// Create a copy of GetPolicyOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,Object? requestedPolicyVersion = freezed,}) {
  return _then(_GetPolicyOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,requestedPolicyVersion: freezed == requestedPolicyVersion ? _self.requestedPolicyVersion : requestedPolicyVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$SetPolicyOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of SetPolicyOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetPolicyOptionsCopyWith<SetPolicyOptions> get copyWith => _$SetPolicyOptionsCopyWithImpl<SetPolicyOptions>(this as SetPolicyOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetPolicyOptions&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,userProject);

@override
String toString() {
  return 'SetPolicyOptions(userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $SetPolicyOptionsCopyWith<$Res>  {
  factory $SetPolicyOptionsCopyWith(SetPolicyOptions value, $Res Function(SetPolicyOptions) _then) = _$SetPolicyOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject
});




}
/// @nodoc
class _$SetPolicyOptionsCopyWithImpl<$Res>
    implements $SetPolicyOptionsCopyWith<$Res> {
  _$SetPolicyOptionsCopyWithImpl(this._self, this._then);

  final SetPolicyOptions _self;
  final $Res Function(SetPolicyOptions) _then;

/// Create a copy of SetPolicyOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _SetPolicyOptions implements SetPolicyOptions {
  const _SetPolicyOptions({this.userProject});
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of SetPolicyOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetPolicyOptionsCopyWith<_SetPolicyOptions> get copyWith => __$SetPolicyOptionsCopyWithImpl<_SetPolicyOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetPolicyOptions&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,userProject);

@override
String toString() {
  return 'SetPolicyOptions(userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$SetPolicyOptionsCopyWith<$Res> implements $SetPolicyOptionsCopyWith<$Res> {
  factory _$SetPolicyOptionsCopyWith(_SetPolicyOptions value, $Res Function(_SetPolicyOptions) _then) = __$SetPolicyOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject
});




}
/// @nodoc
class __$SetPolicyOptionsCopyWithImpl<$Res>
    implements _$SetPolicyOptionsCopyWith<$Res> {
  __$SetPolicyOptionsCopyWithImpl(this._self, this._then);

  final _SetPolicyOptions _self;
  final $Res Function(_SetPolicyOptions) _then;

/// Create a copy of SetPolicyOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,}) {
  return _then(_SetPolicyOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$TestIamPermissionsOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of TestIamPermissionsOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestIamPermissionsOptionsCopyWith<TestIamPermissionsOptions> get copyWith => _$TestIamPermissionsOptionsCopyWithImpl<TestIamPermissionsOptions>(this as TestIamPermissionsOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestIamPermissionsOptions&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,userProject);

@override
String toString() {
  return 'TestIamPermissionsOptions(userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $TestIamPermissionsOptionsCopyWith<$Res>  {
  factory $TestIamPermissionsOptionsCopyWith(TestIamPermissionsOptions value, $Res Function(TestIamPermissionsOptions) _then) = _$TestIamPermissionsOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject
});




}
/// @nodoc
class _$TestIamPermissionsOptionsCopyWithImpl<$Res>
    implements $TestIamPermissionsOptionsCopyWith<$Res> {
  _$TestIamPermissionsOptionsCopyWithImpl(this._self, this._then);

  final TestIamPermissionsOptions _self;
  final $Res Function(TestIamPermissionsOptions) _then;

/// Create a copy of TestIamPermissionsOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _TestIamPermissionsOptions implements TestIamPermissionsOptions {
  const _TestIamPermissionsOptions({this.userProject});
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of TestIamPermissionsOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestIamPermissionsOptionsCopyWith<_TestIamPermissionsOptions> get copyWith => __$TestIamPermissionsOptionsCopyWithImpl<_TestIamPermissionsOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestIamPermissionsOptions&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,userProject);

@override
String toString() {
  return 'TestIamPermissionsOptions(userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$TestIamPermissionsOptionsCopyWith<$Res> implements $TestIamPermissionsOptionsCopyWith<$Res> {
  factory _$TestIamPermissionsOptionsCopyWith(_TestIamPermissionsOptions value, $Res Function(_TestIamPermissionsOptions) _then) = __$TestIamPermissionsOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject
});




}
/// @nodoc
class __$TestIamPermissionsOptionsCopyWithImpl<$Res>
    implements _$TestIamPermissionsOptionsCopyWith<$Res> {
  __$TestIamPermissionsOptionsCopyWithImpl(this._self, this._then);

  final _TestIamPermissionsOptions _self;
  final $Res Function(_TestIamPermissionsOptions) _then;

/// Create a copy of TestIamPermissionsOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,}) {
  return _then(_TestIamPermissionsOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$GetNotificationsOptions {

/// The ID of the project which will be billed for the request.
 String? get userProject;
/// Create a copy of GetNotificationsOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetNotificationsOptionsCopyWith<GetNotificationsOptions> get copyWith => _$GetNotificationsOptionsCopyWithImpl<GetNotificationsOptions>(this as GetNotificationsOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetNotificationsOptions&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,userProject);

@override
String toString() {
  return 'GetNotificationsOptions(userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class $GetNotificationsOptionsCopyWith<$Res>  {
  factory $GetNotificationsOptionsCopyWith(GetNotificationsOptions value, $Res Function(GetNotificationsOptions) _then) = _$GetNotificationsOptionsCopyWithImpl;
@useResult
$Res call({
 String? userProject
});




}
/// @nodoc
class _$GetNotificationsOptionsCopyWithImpl<$Res>
    implements $GetNotificationsOptionsCopyWith<$Res> {
  _$GetNotificationsOptionsCopyWithImpl(this._self, this._then);

  final GetNotificationsOptions _self;
  final $Res Function(GetNotificationsOptions) _then;

/// Create a copy of GetNotificationsOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProject = freezed,}) {
  return _then(_self.copyWith(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc


class _GetNotificationsOptions implements GetNotificationsOptions {
  const _GetNotificationsOptions({this.userProject});
  

/// The ID of the project which will be billed for the request.
@override final  String? userProject;

/// Create a copy of GetNotificationsOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetNotificationsOptionsCopyWith<_GetNotificationsOptions> get copyWith => __$GetNotificationsOptionsCopyWithImpl<_GetNotificationsOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetNotificationsOptions&&(identical(other.userProject, userProject) || other.userProject == userProject));
}


@override
int get hashCode => Object.hash(runtimeType,userProject);

@override
String toString() {
  return 'GetNotificationsOptions(userProject: $userProject)';
}


}

/// @nodoc
abstract mixin class _$GetNotificationsOptionsCopyWith<$Res> implements $GetNotificationsOptionsCopyWith<$Res> {
  factory _$GetNotificationsOptionsCopyWith(_GetNotificationsOptions value, $Res Function(_GetNotificationsOptions) _then) = __$GetNotificationsOptionsCopyWithImpl;
@override @useResult
$Res call({
 String? userProject
});




}
/// @nodoc
class __$GetNotificationsOptionsCopyWithImpl<$Res>
    implements _$GetNotificationsOptionsCopyWith<$Res> {
  __$GetNotificationsOptionsCopyWithImpl(this._self, this._then);

  final _GetNotificationsOptions _self;
  final $Res Function(_GetNotificationsOptions) _then;

/// Create a copy of GetNotificationsOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProject = freezed,}) {
  return _then(_GetNotificationsOptions(
userProject: freezed == userProject ? _self.userProject : userProject // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SignedUrlConfig {

/// The HTTP method for the signed URL (GET, PUT, DELETE, POST).
 SignedUrlMethod get method;/// When the signed URL should expire.
 DateTime get expires;/// When the signed URL becomes accessible (for v4 signing).
 DateTime? get accessibleAt;/// Use virtual-hosted-style URLs instead of path-style URLs.
 bool? get virtualHostedStyle;/// The version of the signing algorithm to use.
 SignedUrlVersion? get version;/// Custom domain name for the signed URL.
 String? get cname;/// Additional headers to include in the signed URL.
 Map<String, String>? get extensionHeaders;/// Additional query parameters to include in the signed URL.
 Map<String, String>? get queryParams;/// MD5 hash of the content (for PUT requests).
 String? get contentMd5;/// Content-Type header value.
 String? get contentType;/// Custom host for the signed URL.
 Uri? get host;/// Custom signing endpoint.
 Uri? get signingEndpoint;
/// Create a copy of SignedUrlConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignedUrlConfigCopyWith<SignedUrlConfig> get copyWith => _$SignedUrlConfigCopyWithImpl<SignedUrlConfig>(this as SignedUrlConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignedUrlConfig&&(identical(other.method, method) || other.method == method)&&(identical(other.expires, expires) || other.expires == expires)&&(identical(other.accessibleAt, accessibleAt) || other.accessibleAt == accessibleAt)&&(identical(other.virtualHostedStyle, virtualHostedStyle) || other.virtualHostedStyle == virtualHostedStyle)&&(identical(other.version, version) || other.version == version)&&(identical(other.cname, cname) || other.cname == cname)&&const DeepCollectionEquality().equals(other.extensionHeaders, extensionHeaders)&&const DeepCollectionEquality().equals(other.queryParams, queryParams)&&(identical(other.contentMd5, contentMd5) || other.contentMd5 == contentMd5)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.host, host) || other.host == host)&&(identical(other.signingEndpoint, signingEndpoint) || other.signingEndpoint == signingEndpoint));
}


@override
int get hashCode => Object.hash(runtimeType,method,expires,accessibleAt,virtualHostedStyle,version,cname,const DeepCollectionEquality().hash(extensionHeaders),const DeepCollectionEquality().hash(queryParams),contentMd5,contentType,host,signingEndpoint);

@override
String toString() {
  return 'SignedUrlConfig(method: $method, expires: $expires, accessibleAt: $accessibleAt, virtualHostedStyle: $virtualHostedStyle, version: $version, cname: $cname, extensionHeaders: $extensionHeaders, queryParams: $queryParams, contentMd5: $contentMd5, contentType: $contentType, host: $host, signingEndpoint: $signingEndpoint)';
}


}

/// @nodoc
abstract mixin class $SignedUrlConfigCopyWith<$Res>  {
  factory $SignedUrlConfigCopyWith(SignedUrlConfig value, $Res Function(SignedUrlConfig) _then) = _$SignedUrlConfigCopyWithImpl;
@useResult
$Res call({
 SignedUrlMethod method, DateTime expires, DateTime? accessibleAt, bool? virtualHostedStyle, SignedUrlVersion? version, String? cname, Map<String, String>? extensionHeaders, Map<String, String>? queryParams, String? contentMd5, String? contentType, Uri? host, Uri? signingEndpoint
});




}
/// @nodoc
class _$SignedUrlConfigCopyWithImpl<$Res>
    implements $SignedUrlConfigCopyWith<$Res> {
  _$SignedUrlConfigCopyWithImpl(this._self, this._then);

  final SignedUrlConfig _self;
  final $Res Function(SignedUrlConfig) _then;

/// Create a copy of SignedUrlConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? expires = null,Object? accessibleAt = freezed,Object? virtualHostedStyle = freezed,Object? version = freezed,Object? cname = freezed,Object? extensionHeaders = freezed,Object? queryParams = freezed,Object? contentMd5 = freezed,Object? contentType = freezed,Object? host = freezed,Object? signingEndpoint = freezed,}) {
  return _then(_self.copyWith(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as SignedUrlMethod,expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime,accessibleAt: freezed == accessibleAt ? _self.accessibleAt : accessibleAt // ignore: cast_nullable_to_non_nullable
as DateTime?,virtualHostedStyle: freezed == virtualHostedStyle ? _self.virtualHostedStyle : virtualHostedStyle // ignore: cast_nullable_to_non_nullable
as bool?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as SignedUrlVersion?,cname: freezed == cname ? _self.cname : cname // ignore: cast_nullable_to_non_nullable
as String?,extensionHeaders: freezed == extensionHeaders ? _self.extensionHeaders : extensionHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,queryParams: freezed == queryParams ? _self.queryParams : queryParams // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,contentMd5: freezed == contentMd5 ? _self.contentMd5 : contentMd5 // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as Uri?,signingEndpoint: freezed == signingEndpoint ? _self.signingEndpoint : signingEndpoint // ignore: cast_nullable_to_non_nullable
as Uri?,
  ));
}

}



/// @nodoc


class _SignedUrlConfig implements SignedUrlConfig {
  const _SignedUrlConfig({required this.method, required this.expires, this.accessibleAt, this.virtualHostedStyle, this.version, this.cname, final  Map<String, String>? extensionHeaders, final  Map<String, String>? queryParams, this.contentMd5, this.contentType, this.host, this.signingEndpoint}): _extensionHeaders = extensionHeaders,_queryParams = queryParams;
  

/// The HTTP method for the signed URL (GET, PUT, DELETE, POST).
@override final  SignedUrlMethod method;
/// When the signed URL should expire.
@override final  DateTime expires;
/// When the signed URL becomes accessible (for v4 signing).
@override final  DateTime? accessibleAt;
/// Use virtual-hosted-style URLs instead of path-style URLs.
@override final  bool? virtualHostedStyle;
/// The version of the signing algorithm to use.
@override final  SignedUrlVersion? version;
/// Custom domain name for the signed URL.
@override final  String? cname;
/// Additional headers to include in the signed URL.
 final  Map<String, String>? _extensionHeaders;
/// Additional headers to include in the signed URL.
@override Map<String, String>? get extensionHeaders {
  final value = _extensionHeaders;
  if (value == null) return null;
  if (_extensionHeaders is EqualUnmodifiableMapView) return _extensionHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Additional query parameters to include in the signed URL.
 final  Map<String, String>? _queryParams;
/// Additional query parameters to include in the signed URL.
@override Map<String, String>? get queryParams {
  final value = _queryParams;
  if (value == null) return null;
  if (_queryParams is EqualUnmodifiableMapView) return _queryParams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// MD5 hash of the content (for PUT requests).
@override final  String? contentMd5;
/// Content-Type header value.
@override final  String? contentType;
/// Custom host for the signed URL.
@override final  Uri? host;
/// Custom signing endpoint.
@override final  Uri? signingEndpoint;

/// Create a copy of SignedUrlConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignedUrlConfigCopyWith<_SignedUrlConfig> get copyWith => __$SignedUrlConfigCopyWithImpl<_SignedUrlConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignedUrlConfig&&(identical(other.method, method) || other.method == method)&&(identical(other.expires, expires) || other.expires == expires)&&(identical(other.accessibleAt, accessibleAt) || other.accessibleAt == accessibleAt)&&(identical(other.virtualHostedStyle, virtualHostedStyle) || other.virtualHostedStyle == virtualHostedStyle)&&(identical(other.version, version) || other.version == version)&&(identical(other.cname, cname) || other.cname == cname)&&const DeepCollectionEquality().equals(other._extensionHeaders, _extensionHeaders)&&const DeepCollectionEquality().equals(other._queryParams, _queryParams)&&(identical(other.contentMd5, contentMd5) || other.contentMd5 == contentMd5)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.host, host) || other.host == host)&&(identical(other.signingEndpoint, signingEndpoint) || other.signingEndpoint == signingEndpoint));
}


@override
int get hashCode => Object.hash(runtimeType,method,expires,accessibleAt,virtualHostedStyle,version,cname,const DeepCollectionEquality().hash(_extensionHeaders),const DeepCollectionEquality().hash(_queryParams),contentMd5,contentType,host,signingEndpoint);

@override
String toString() {
  return 'SignedUrlConfig(method: $method, expires: $expires, accessibleAt: $accessibleAt, virtualHostedStyle: $virtualHostedStyle, version: $version, cname: $cname, extensionHeaders: $extensionHeaders, queryParams: $queryParams, contentMd5: $contentMd5, contentType: $contentType, host: $host, signingEndpoint: $signingEndpoint)';
}


}

/// @nodoc
abstract mixin class _$SignedUrlConfigCopyWith<$Res> implements $SignedUrlConfigCopyWith<$Res> {
  factory _$SignedUrlConfigCopyWith(_SignedUrlConfig value, $Res Function(_SignedUrlConfig) _then) = __$SignedUrlConfigCopyWithImpl;
@override @useResult
$Res call({
 SignedUrlMethod method, DateTime expires, DateTime? accessibleAt, bool? virtualHostedStyle, SignedUrlVersion? version, String? cname, Map<String, String>? extensionHeaders, Map<String, String>? queryParams, String? contentMd5, String? contentType, Uri? host, Uri? signingEndpoint
});




}
/// @nodoc
class __$SignedUrlConfigCopyWithImpl<$Res>
    implements _$SignedUrlConfigCopyWith<$Res> {
  __$SignedUrlConfigCopyWithImpl(this._self, this._then);

  final _SignedUrlConfig _self;
  final $Res Function(_SignedUrlConfig) _then;

/// Create a copy of SignedUrlConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? expires = null,Object? accessibleAt = freezed,Object? virtualHostedStyle = freezed,Object? version = freezed,Object? cname = freezed,Object? extensionHeaders = freezed,Object? queryParams = freezed,Object? contentMd5 = freezed,Object? contentType = freezed,Object? host = freezed,Object? signingEndpoint = freezed,}) {
  return _then(_SignedUrlConfig(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as SignedUrlMethod,expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime,accessibleAt: freezed == accessibleAt ? _self.accessibleAt : accessibleAt // ignore: cast_nullable_to_non_nullable
as DateTime?,virtualHostedStyle: freezed == virtualHostedStyle ? _self.virtualHostedStyle : virtualHostedStyle // ignore: cast_nullable_to_non_nullable
as bool?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as SignedUrlVersion?,cname: freezed == cname ? _self.cname : cname // ignore: cast_nullable_to_non_nullable
as String?,extensionHeaders: freezed == extensionHeaders ? _self._extensionHeaders : extensionHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,queryParams: freezed == queryParams ? _self._queryParams : queryParams // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,contentMd5: freezed == contentMd5 ? _self.contentMd5 : contentMd5 // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as Uri?,signingEndpoint: freezed == signingEndpoint ? _self.signingEndpoint : signingEndpoint // ignore: cast_nullable_to_non_nullable
as Uri?,
  ));
}


}

/// @nodoc
mixin _$TransferSource {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferSource);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TransferSource()';
}


}

/// @nodoc
class $TransferSourceCopyWith<$Res>  {
$TransferSourceCopyWith(TransferSource _, $Res Function(TransferSource) __);
}



/// @nodoc


class FileTransferSource implements TransferSource {
  const FileTransferSource(this.path);
  

 final  String path;

/// Create a copy of TransferSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTransferSourceCopyWith<FileTransferSource> get copyWith => _$FileTransferSourceCopyWithImpl<FileTransferSource>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTransferSource&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'TransferSource.file(path: $path)';
}


}

/// @nodoc
abstract mixin class $FileTransferSourceCopyWith<$Res> implements $TransferSourceCopyWith<$Res> {
  factory $FileTransferSourceCopyWith(FileTransferSource value, $Res Function(FileTransferSource) _then) = _$FileTransferSourceCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$FileTransferSourceCopyWithImpl<$Res>
    implements $FileTransferSourceCopyWith<$Res> {
  _$FileTransferSourceCopyWithImpl(this._self, this._then);

  final FileTransferSource _self;
  final $Res Function(FileTransferSource) _then;

/// Create a copy of TransferSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(FileTransferSource(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FilesTransferSource implements TransferSource {
  const FilesTransferSource(final  List<String> paths): _paths = paths;
  

 final  List<String> _paths;
 List<String> get paths {
  if (_paths is EqualUnmodifiableListView) return _paths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paths);
}


/// Create a copy of TransferSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilesTransferSourceCopyWith<FilesTransferSource> get copyWith => _$FilesTransferSourceCopyWithImpl<FilesTransferSource>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesTransferSource&&const DeepCollectionEquality().equals(other._paths, _paths));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_paths));

@override
String toString() {
  return 'TransferSource.files(paths: $paths)';
}


}

/// @nodoc
abstract mixin class $FilesTransferSourceCopyWith<$Res> implements $TransferSourceCopyWith<$Res> {
  factory $FilesTransferSourceCopyWith(FilesTransferSource value, $Res Function(FilesTransferSource) _then) = _$FilesTransferSourceCopyWithImpl;
@useResult
$Res call({
 List<String> paths
});




}
/// @nodoc
class _$FilesTransferSourceCopyWithImpl<$Res>
    implements $FilesTransferSourceCopyWith<$Res> {
  _$FilesTransferSourceCopyWithImpl(this._self, this._then);

  final FilesTransferSource _self;
  final $Res Function(FilesTransferSource) _then;

/// Create a copy of TransferSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? paths = null,}) {
  return _then(FilesTransferSource(
null == paths ? _self._paths : paths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class DirectoryTransferSource implements TransferSource {
  const DirectoryTransferSource(this.path);
  

 final  String path;

/// Create a copy of TransferSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DirectoryTransferSourceCopyWith<DirectoryTransferSource> get copyWith => _$DirectoryTransferSourceCopyWithImpl<DirectoryTransferSource>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectoryTransferSource&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'TransferSource.directory(path: $path)';
}


}

/// @nodoc
abstract mixin class $DirectoryTransferSourceCopyWith<$Res> implements $TransferSourceCopyWith<$Res> {
  factory $DirectoryTransferSourceCopyWith(DirectoryTransferSource value, $Res Function(DirectoryTransferSource) _then) = _$DirectoryTransferSourceCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$DirectoryTransferSourceCopyWithImpl<$Res>
    implements $DirectoryTransferSourceCopyWith<$Res> {
  _$DirectoryTransferSourceCopyWithImpl(this._self, this._then);

  final DirectoryTransferSource _self;
  final $Res Function(DirectoryTransferSource) _then;

/// Create a copy of TransferSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(DirectoryTransferSource(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CopyDestination {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CopyDestination);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CopyDestination()';
}


}

/// @nodoc
class $CopyDestinationCopyWith<$Res>  {
$CopyDestinationCopyWith(CopyDestination _, $Res Function(CopyDestination) __);
}



/// @nodoc


class PathCopyDestination implements CopyDestination {
  const PathCopyDestination(this.path);
  

 final  String path;

/// Create a copy of CopyDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PathCopyDestinationCopyWith<PathCopyDestination> get copyWith => _$PathCopyDestinationCopyWithImpl<PathCopyDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PathCopyDestination&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'CopyDestination.path(path: $path)';
}


}

/// @nodoc
abstract mixin class $PathCopyDestinationCopyWith<$Res> implements $CopyDestinationCopyWith<$Res> {
  factory $PathCopyDestinationCopyWith(PathCopyDestination value, $Res Function(PathCopyDestination) _then) = _$PathCopyDestinationCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$PathCopyDestinationCopyWithImpl<$Res>
    implements $PathCopyDestinationCopyWith<$Res> {
  _$PathCopyDestinationCopyWithImpl(this._self, this._then);

  final PathCopyDestination _self;
  final $Res Function(PathCopyDestination) _then;

/// Create a copy of CopyDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(PathCopyDestination(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FileCopyDestination implements CopyDestination {
  const FileCopyDestination(this.file);
  

 final  BucketFile file;

/// Create a copy of CopyDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileCopyDestinationCopyWith<FileCopyDestination> get copyWith => _$FileCopyDestinationCopyWithImpl<FileCopyDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileCopyDestination&&(identical(other.file, file) || other.file == file));
}


@override
int get hashCode => Object.hash(runtimeType,file);

@override
String toString() {
  return 'CopyDestination.file(file: $file)';
}


}

/// @nodoc
abstract mixin class $FileCopyDestinationCopyWith<$Res> implements $CopyDestinationCopyWith<$Res> {
  factory $FileCopyDestinationCopyWith(FileCopyDestination value, $Res Function(FileCopyDestination) _then) = _$FileCopyDestinationCopyWithImpl;
@useResult
$Res call({
 BucketFile file
});




}
/// @nodoc
class _$FileCopyDestinationCopyWithImpl<$Res>
    implements $FileCopyDestinationCopyWith<$Res> {
  _$FileCopyDestinationCopyWithImpl(this._self, this._then);

  final FileCopyDestination _self;
  final $Res Function(FileCopyDestination) _then;

/// Create a copy of CopyDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? file = null,}) {
  return _then(FileCopyDestination(
null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as BucketFile,
  ));
}


}

/// @nodoc


class BucketCopyDestination implements CopyDestination {
  const BucketCopyDestination(this.bucket);
  

 final  Bucket bucket;

/// Create a copy of CopyDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BucketCopyDestinationCopyWith<BucketCopyDestination> get copyWith => _$BucketCopyDestinationCopyWithImpl<BucketCopyDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BucketCopyDestination&&(identical(other.bucket, bucket) || other.bucket == bucket));
}


@override
int get hashCode => Object.hash(runtimeType,bucket);

@override
String toString() {
  return 'CopyDestination.bucket(bucket: $bucket)';
}


}

/// @nodoc
abstract mixin class $BucketCopyDestinationCopyWith<$Res> implements $CopyDestinationCopyWith<$Res> {
  factory $BucketCopyDestinationCopyWith(BucketCopyDestination value, $Res Function(BucketCopyDestination) _then) = _$BucketCopyDestinationCopyWithImpl;
@useResult
$Res call({
 Bucket bucket
});




}
/// @nodoc
class _$BucketCopyDestinationCopyWithImpl<$Res>
    implements $BucketCopyDestinationCopyWith<$Res> {
  _$BucketCopyDestinationCopyWithImpl(this._self, this._then);

  final BucketCopyDestination _self;
  final $Res Function(BucketCopyDestination) _then;

/// Create a copy of CopyDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bucket = null,}) {
  return _then(BucketCopyDestination(
null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,
  ));
}


}

/// @nodoc
mixin _$MoveFileAtomicDestination {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveFileAtomicDestination);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MoveFileAtomicDestination()';
}


}

/// @nodoc
class $MoveFileAtomicDestinationCopyWith<$Res>  {
$MoveFileAtomicDestinationCopyWith(MoveFileAtomicDestination _, $Res Function(MoveFileAtomicDestination) __);
}



/// @nodoc


class PathMoveFileAtomicDestination implements MoveFileAtomicDestination {
  const PathMoveFileAtomicDestination(this.path);
  

 final  String path;

/// Create a copy of MoveFileAtomicDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PathMoveFileAtomicDestinationCopyWith<PathMoveFileAtomicDestination> get copyWith => _$PathMoveFileAtomicDestinationCopyWithImpl<PathMoveFileAtomicDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PathMoveFileAtomicDestination&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'MoveFileAtomicDestination.path(path: $path)';
}


}

/// @nodoc
abstract mixin class $PathMoveFileAtomicDestinationCopyWith<$Res> implements $MoveFileAtomicDestinationCopyWith<$Res> {
  factory $PathMoveFileAtomicDestinationCopyWith(PathMoveFileAtomicDestination value, $Res Function(PathMoveFileAtomicDestination) _then) = _$PathMoveFileAtomicDestinationCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$PathMoveFileAtomicDestinationCopyWithImpl<$Res>
    implements $PathMoveFileAtomicDestinationCopyWith<$Res> {
  _$PathMoveFileAtomicDestinationCopyWithImpl(this._self, this._then);

  final PathMoveFileAtomicDestination _self;
  final $Res Function(PathMoveFileAtomicDestination) _then;

/// Create a copy of MoveFileAtomicDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(PathMoveFileAtomicDestination(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FileMoveFileAtomicDestination implements MoveFileAtomicDestination {
  const FileMoveFileAtomicDestination(this.file);
  

 final  BucketFile file;

/// Create a copy of MoveFileAtomicDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileMoveFileAtomicDestinationCopyWith<FileMoveFileAtomicDestination> get copyWith => _$FileMoveFileAtomicDestinationCopyWithImpl<FileMoveFileAtomicDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileMoveFileAtomicDestination&&(identical(other.file, file) || other.file == file));
}


@override
int get hashCode => Object.hash(runtimeType,file);

@override
String toString() {
  return 'MoveFileAtomicDestination.file(file: $file)';
}


}

/// @nodoc
abstract mixin class $FileMoveFileAtomicDestinationCopyWith<$Res> implements $MoveFileAtomicDestinationCopyWith<$Res> {
  factory $FileMoveFileAtomicDestinationCopyWith(FileMoveFileAtomicDestination value, $Res Function(FileMoveFileAtomicDestination) _then) = _$FileMoveFileAtomicDestinationCopyWithImpl;
@useResult
$Res call({
 BucketFile file
});




}
/// @nodoc
class _$FileMoveFileAtomicDestinationCopyWithImpl<$Res>
    implements $FileMoveFileAtomicDestinationCopyWith<$Res> {
  _$FileMoveFileAtomicDestinationCopyWithImpl(this._self, this._then);

  final FileMoveFileAtomicDestination _self;
  final $Res Function(FileMoveFileAtomicDestination) _then;

/// Create a copy of MoveFileAtomicDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? file = null,}) {
  return _then(FileMoveFileAtomicDestination(
null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as BucketFile,
  ));
}


}

/// @nodoc
mixin _$UploadDestination {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadDestination);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UploadDestination()';
}


}

/// @nodoc
class $UploadDestinationCopyWith<$Res>  {
$UploadDestinationCopyWith(UploadDestination _, $Res Function(UploadDestination) __);
}



/// @nodoc


class PathUploadDestination implements UploadDestination {
  const PathUploadDestination(this.path);
  

 final  String path;

/// Create a copy of UploadDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PathUploadDestinationCopyWith<PathUploadDestination> get copyWith => _$PathUploadDestinationCopyWithImpl<PathUploadDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PathUploadDestination&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'UploadDestination.path(path: $path)';
}


}

/// @nodoc
abstract mixin class $PathUploadDestinationCopyWith<$Res> implements $UploadDestinationCopyWith<$Res> {
  factory $PathUploadDestinationCopyWith(PathUploadDestination value, $Res Function(PathUploadDestination) _then) = _$PathUploadDestinationCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$PathUploadDestinationCopyWithImpl<$Res>
    implements $PathUploadDestinationCopyWith<$Res> {
  _$PathUploadDestinationCopyWithImpl(this._self, this._then);

  final PathUploadDestination _self;
  final $Res Function(PathUploadDestination) _then;

/// Create a copy of UploadDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(PathUploadDestination(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FileUploadDestination implements UploadDestination {
  const FileUploadDestination(this.file);
  

 final  BucketFile file;

/// Create a copy of UploadDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileUploadDestinationCopyWith<FileUploadDestination> get copyWith => _$FileUploadDestinationCopyWithImpl<FileUploadDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileUploadDestination&&(identical(other.file, file) || other.file == file));
}


@override
int get hashCode => Object.hash(runtimeType,file);

@override
String toString() {
  return 'UploadDestination.file(file: $file)';
}


}

/// @nodoc
abstract mixin class $FileUploadDestinationCopyWith<$Res> implements $UploadDestinationCopyWith<$Res> {
  factory $FileUploadDestinationCopyWith(FileUploadDestination value, $Res Function(FileUploadDestination) _then) = _$FileUploadDestinationCopyWithImpl;
@useResult
$Res call({
 BucketFile file
});




}
/// @nodoc
class _$FileUploadDestinationCopyWithImpl<$Res>
    implements $FileUploadDestinationCopyWith<$Res> {
  _$FileUploadDestinationCopyWithImpl(this._self, this._then);

  final FileUploadDestination _self;
  final $Res Function(FileUploadDestination) _then;

/// Create a copy of UploadDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? file = null,}) {
  return _then(FileUploadDestination(
null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as BucketFile,
  ));
}


}

/// @nodoc
mixin _$UploadManyFilesOptions {

/// Maximum number of concurrent uploads. Defaults to a reasonable value.
 int? get concurrencyLimit;/// Custom function to build the destination path for each file.
///
/// If provided, this function is called for each file to determine
/// its destination path in the bucket.
 String Function(String path, UploadManyFilesOptions options)? get customDestinationBuilder;/// If `true`, skip files that already exist in the destination.
 bool? get skipIfExists;/// Prefix to add to all destination paths.
 String? get prefix;/// Additional options to pass through to individual upload operations.
 UploadOptions? get passthroughOptions;
/// Create a copy of UploadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadManyFilesOptionsCopyWith<UploadManyFilesOptions> get copyWith => _$UploadManyFilesOptionsCopyWithImpl<UploadManyFilesOptions>(this as UploadManyFilesOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadManyFilesOptions&&(identical(other.concurrencyLimit, concurrencyLimit) || other.concurrencyLimit == concurrencyLimit)&&(identical(other.customDestinationBuilder, customDestinationBuilder) || other.customDestinationBuilder == customDestinationBuilder)&&(identical(other.skipIfExists, skipIfExists) || other.skipIfExists == skipIfExists)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.passthroughOptions, passthroughOptions) || other.passthroughOptions == passthroughOptions));
}


@override
int get hashCode => Object.hash(runtimeType,concurrencyLimit,customDestinationBuilder,skipIfExists,prefix,passthroughOptions);

@override
String toString() {
  return 'UploadManyFilesOptions(concurrencyLimit: $concurrencyLimit, customDestinationBuilder: $customDestinationBuilder, skipIfExists: $skipIfExists, prefix: $prefix, passthroughOptions: $passthroughOptions)';
}


}

/// @nodoc
abstract mixin class $UploadManyFilesOptionsCopyWith<$Res>  {
  factory $UploadManyFilesOptionsCopyWith(UploadManyFilesOptions value, $Res Function(UploadManyFilesOptions) _then) = _$UploadManyFilesOptionsCopyWithImpl;
@useResult
$Res call({
 int? concurrencyLimit, String Function(String path, UploadManyFilesOptions options)? customDestinationBuilder, bool? skipIfExists, String? prefix, UploadOptions? passthroughOptions
});


$UploadOptionsCopyWith<$Res>? get passthroughOptions;

}
/// @nodoc
class _$UploadManyFilesOptionsCopyWithImpl<$Res>
    implements $UploadManyFilesOptionsCopyWith<$Res> {
  _$UploadManyFilesOptionsCopyWithImpl(this._self, this._then);

  final UploadManyFilesOptions _self;
  final $Res Function(UploadManyFilesOptions) _then;

/// Create a copy of UploadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? concurrencyLimit = freezed,Object? customDestinationBuilder = freezed,Object? skipIfExists = freezed,Object? prefix = freezed,Object? passthroughOptions = freezed,}) {
  return _then(_self.copyWith(
concurrencyLimit: freezed == concurrencyLimit ? _self.concurrencyLimit : concurrencyLimit // ignore: cast_nullable_to_non_nullable
as int?,customDestinationBuilder: freezed == customDestinationBuilder ? _self.customDestinationBuilder : customDestinationBuilder // ignore: cast_nullable_to_non_nullable
as String Function(String path, UploadManyFilesOptions options)?,skipIfExists: freezed == skipIfExists ? _self.skipIfExists : skipIfExists // ignore: cast_nullable_to_non_nullable
as bool?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,passthroughOptions: freezed == passthroughOptions ? _self.passthroughOptions : passthroughOptions // ignore: cast_nullable_to_non_nullable
as UploadOptions?,
  ));
}
/// Create a copy of UploadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadOptionsCopyWith<$Res>? get passthroughOptions {
    if (_self.passthroughOptions == null) {
    return null;
  }

  return $UploadOptionsCopyWith<$Res>(_self.passthroughOptions!, (value) {
    return _then(_self.copyWith(passthroughOptions: value));
  });
}
}



/// @nodoc


class _UploadManyFilesOptions implements UploadManyFilesOptions {
  const _UploadManyFilesOptions({this.concurrencyLimit, this.customDestinationBuilder, this.skipIfExists, this.prefix, this.passthroughOptions});
  

/// Maximum number of concurrent uploads. Defaults to a reasonable value.
@override final  int? concurrencyLimit;
/// Custom function to build the destination path for each file.
///
/// If provided, this function is called for each file to determine
/// its destination path in the bucket.
@override final  String Function(String path, UploadManyFilesOptions options)? customDestinationBuilder;
/// If `true`, skip files that already exist in the destination.
@override final  bool? skipIfExists;
/// Prefix to add to all destination paths.
@override final  String? prefix;
/// Additional options to pass through to individual upload operations.
@override final  UploadOptions? passthroughOptions;

/// Create a copy of UploadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadManyFilesOptionsCopyWith<_UploadManyFilesOptions> get copyWith => __$UploadManyFilesOptionsCopyWithImpl<_UploadManyFilesOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadManyFilesOptions&&(identical(other.concurrencyLimit, concurrencyLimit) || other.concurrencyLimit == concurrencyLimit)&&(identical(other.customDestinationBuilder, customDestinationBuilder) || other.customDestinationBuilder == customDestinationBuilder)&&(identical(other.skipIfExists, skipIfExists) || other.skipIfExists == skipIfExists)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.passthroughOptions, passthroughOptions) || other.passthroughOptions == passthroughOptions));
}


@override
int get hashCode => Object.hash(runtimeType,concurrencyLimit,customDestinationBuilder,skipIfExists,prefix,passthroughOptions);

@override
String toString() {
  return 'UploadManyFilesOptions(concurrencyLimit: $concurrencyLimit, customDestinationBuilder: $customDestinationBuilder, skipIfExists: $skipIfExists, prefix: $prefix, passthroughOptions: $passthroughOptions)';
}


}

/// @nodoc
abstract mixin class _$UploadManyFilesOptionsCopyWith<$Res> implements $UploadManyFilesOptionsCopyWith<$Res> {
  factory _$UploadManyFilesOptionsCopyWith(_UploadManyFilesOptions value, $Res Function(_UploadManyFilesOptions) _then) = __$UploadManyFilesOptionsCopyWithImpl;
@override @useResult
$Res call({
 int? concurrencyLimit, String Function(String path, UploadManyFilesOptions options)? customDestinationBuilder, bool? skipIfExists, String? prefix, UploadOptions? passthroughOptions
});


@override $UploadOptionsCopyWith<$Res>? get passthroughOptions;

}
/// @nodoc
class __$UploadManyFilesOptionsCopyWithImpl<$Res>
    implements _$UploadManyFilesOptionsCopyWith<$Res> {
  __$UploadManyFilesOptionsCopyWithImpl(this._self, this._then);

  final _UploadManyFilesOptions _self;
  final $Res Function(_UploadManyFilesOptions) _then;

/// Create a copy of UploadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? concurrencyLimit = freezed,Object? customDestinationBuilder = freezed,Object? skipIfExists = freezed,Object? prefix = freezed,Object? passthroughOptions = freezed,}) {
  return _then(_UploadManyFilesOptions(
concurrencyLimit: freezed == concurrencyLimit ? _self.concurrencyLimit : concurrencyLimit // ignore: cast_nullable_to_non_nullable
as int?,customDestinationBuilder: freezed == customDestinationBuilder ? _self.customDestinationBuilder : customDestinationBuilder // ignore: cast_nullable_to_non_nullable
as String Function(String path, UploadManyFilesOptions options)?,skipIfExists: freezed == skipIfExists ? _self.skipIfExists : skipIfExists // ignore: cast_nullable_to_non_nullable
as bool?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,passthroughOptions: freezed == passthroughOptions ? _self.passthroughOptions : passthroughOptions // ignore: cast_nullable_to_non_nullable
as UploadOptions?,
  ));
}

/// Create a copy of UploadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadOptionsCopyWith<$Res>? get passthroughOptions {
    if (_self.passthroughOptions == null) {
    return null;
  }

  return $UploadOptionsCopyWith<$Res>(_self.passthroughOptions!, (value) {
    return _then(_self.copyWith(passthroughOptions: value));
  });
}
}

/// @nodoc
mixin _$DownloadManyFilesOptions {

/// Maximum number of concurrent downloads. Defaults to a reasonable value.
 int? get concurrencyLimit;/// Prefix to filter files to download.
 String? get prefix;/// Prefix to strip from file paths when saving locally.
 String? get stripPrefix;/// Additional options to pass through to individual download operations.
 DownloadOptions? get passthroughOptions;/// If `true`, skip files that already exist locally.
 bool? get skipIfExists;
/// Create a copy of DownloadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadManyFilesOptionsCopyWith<DownloadManyFilesOptions> get copyWith => _$DownloadManyFilesOptionsCopyWithImpl<DownloadManyFilesOptions>(this as DownloadManyFilesOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadManyFilesOptions&&(identical(other.concurrencyLimit, concurrencyLimit) || other.concurrencyLimit == concurrencyLimit)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.stripPrefix, stripPrefix) || other.stripPrefix == stripPrefix)&&(identical(other.passthroughOptions, passthroughOptions) || other.passthroughOptions == passthroughOptions)&&(identical(other.skipIfExists, skipIfExists) || other.skipIfExists == skipIfExists));
}


@override
int get hashCode => Object.hash(runtimeType,concurrencyLimit,prefix,stripPrefix,passthroughOptions,skipIfExists);

@override
String toString() {
  return 'DownloadManyFilesOptions(concurrencyLimit: $concurrencyLimit, prefix: $prefix, stripPrefix: $stripPrefix, passthroughOptions: $passthroughOptions, skipIfExists: $skipIfExists)';
}


}

/// @nodoc
abstract mixin class $DownloadManyFilesOptionsCopyWith<$Res>  {
  factory $DownloadManyFilesOptionsCopyWith(DownloadManyFilesOptions value, $Res Function(DownloadManyFilesOptions) _then) = _$DownloadManyFilesOptionsCopyWithImpl;
@useResult
$Res call({
 int? concurrencyLimit, String? prefix, String? stripPrefix, DownloadOptions? passthroughOptions, bool? skipIfExists
});


$DownloadOptionsCopyWith<$Res>? get passthroughOptions;

}
/// @nodoc
class _$DownloadManyFilesOptionsCopyWithImpl<$Res>
    implements $DownloadManyFilesOptionsCopyWith<$Res> {
  _$DownloadManyFilesOptionsCopyWithImpl(this._self, this._then);

  final DownloadManyFilesOptions _self;
  final $Res Function(DownloadManyFilesOptions) _then;

/// Create a copy of DownloadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? concurrencyLimit = freezed,Object? prefix = freezed,Object? stripPrefix = freezed,Object? passthroughOptions = freezed,Object? skipIfExists = freezed,}) {
  return _then(_self.copyWith(
concurrencyLimit: freezed == concurrencyLimit ? _self.concurrencyLimit : concurrencyLimit // ignore: cast_nullable_to_non_nullable
as int?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,stripPrefix: freezed == stripPrefix ? _self.stripPrefix : stripPrefix // ignore: cast_nullable_to_non_nullable
as String?,passthroughOptions: freezed == passthroughOptions ? _self.passthroughOptions : passthroughOptions // ignore: cast_nullable_to_non_nullable
as DownloadOptions?,skipIfExists: freezed == skipIfExists ? _self.skipIfExists : skipIfExists // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of DownloadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DownloadOptionsCopyWith<$Res>? get passthroughOptions {
    if (_self.passthroughOptions == null) {
    return null;
  }

  return $DownloadOptionsCopyWith<$Res>(_self.passthroughOptions!, (value) {
    return _then(_self.copyWith(passthroughOptions: value));
  });
}
}



/// @nodoc


class _DownloadManyFilesOptions implements DownloadManyFilesOptions {
  const _DownloadManyFilesOptions({this.concurrencyLimit, this.prefix, this.stripPrefix, this.passthroughOptions, this.skipIfExists});
  

/// Maximum number of concurrent downloads. Defaults to a reasonable value.
@override final  int? concurrencyLimit;
/// Prefix to filter files to download.
@override final  String? prefix;
/// Prefix to strip from file paths when saving locally.
@override final  String? stripPrefix;
/// Additional options to pass through to individual download operations.
@override final  DownloadOptions? passthroughOptions;
/// If `true`, skip files that already exist locally.
@override final  bool? skipIfExists;

/// Create a copy of DownloadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadManyFilesOptionsCopyWith<_DownloadManyFilesOptions> get copyWith => __$DownloadManyFilesOptionsCopyWithImpl<_DownloadManyFilesOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadManyFilesOptions&&(identical(other.concurrencyLimit, concurrencyLimit) || other.concurrencyLimit == concurrencyLimit)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.stripPrefix, stripPrefix) || other.stripPrefix == stripPrefix)&&(identical(other.passthroughOptions, passthroughOptions) || other.passthroughOptions == passthroughOptions)&&(identical(other.skipIfExists, skipIfExists) || other.skipIfExists == skipIfExists));
}


@override
int get hashCode => Object.hash(runtimeType,concurrencyLimit,prefix,stripPrefix,passthroughOptions,skipIfExists);

@override
String toString() {
  return 'DownloadManyFilesOptions(concurrencyLimit: $concurrencyLimit, prefix: $prefix, stripPrefix: $stripPrefix, passthroughOptions: $passthroughOptions, skipIfExists: $skipIfExists)';
}


}

/// @nodoc
abstract mixin class _$DownloadManyFilesOptionsCopyWith<$Res> implements $DownloadManyFilesOptionsCopyWith<$Res> {
  factory _$DownloadManyFilesOptionsCopyWith(_DownloadManyFilesOptions value, $Res Function(_DownloadManyFilesOptions) _then) = __$DownloadManyFilesOptionsCopyWithImpl;
@override @useResult
$Res call({
 int? concurrencyLimit, String? prefix, String? stripPrefix, DownloadOptions? passthroughOptions, bool? skipIfExists
});


@override $DownloadOptionsCopyWith<$Res>? get passthroughOptions;

}
/// @nodoc
class __$DownloadManyFilesOptionsCopyWithImpl<$Res>
    implements _$DownloadManyFilesOptionsCopyWith<$Res> {
  __$DownloadManyFilesOptionsCopyWithImpl(this._self, this._then);

  final _DownloadManyFilesOptions _self;
  final $Res Function(_DownloadManyFilesOptions) _then;

/// Create a copy of DownloadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? concurrencyLimit = freezed,Object? prefix = freezed,Object? stripPrefix = freezed,Object? passthroughOptions = freezed,Object? skipIfExists = freezed,}) {
  return _then(_DownloadManyFilesOptions(
concurrencyLimit: freezed == concurrencyLimit ? _self.concurrencyLimit : concurrencyLimit // ignore: cast_nullable_to_non_nullable
as int?,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,stripPrefix: freezed == stripPrefix ? _self.stripPrefix : stripPrefix // ignore: cast_nullable_to_non_nullable
as String?,passthroughOptions: freezed == passthroughOptions ? _self.passthroughOptions : passthroughOptions // ignore: cast_nullable_to_non_nullable
as DownloadOptions?,skipIfExists: freezed == skipIfExists ? _self.skipIfExists : skipIfExists // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of DownloadManyFilesOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DownloadOptionsCopyWith<$Res>? get passthroughOptions {
    if (_self.passthroughOptions == null) {
    return null;
  }

  return $DownloadOptionsCopyWith<$Res>(_self.passthroughOptions!, (value) {
    return _then(_self.copyWith(passthroughOptions: value));
  });
}
}

/// @nodoc
mixin _$UploadFileInChunksOptions {

/// Maximum number of concurrent chunk uploads.
 int? get concurrencyLimit;/// Size of each chunk in bytes.
 int? get chunkSizeBytes;/// Name for the upload operation.
 String? get uploadName;/// Maximum size of the upload queue.
 int? get maxQueueSize;/// ID of an existing upload to resume.
 String? get uploadId;/// If `true`, automatically abort the upload on failure.
 bool? get autoAbortFailure;/// Map of chunk indices to their part identifiers (for resuming).
 Map<int, String>? get partsMap;/// Validation type for data integrity checks.
 ValidationType? get validation;/// Additional headers to include in upload requests.
 Map<String, String>? get headers;
/// Create a copy of UploadFileInChunksOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadFileInChunksOptionsCopyWith<UploadFileInChunksOptions> get copyWith => _$UploadFileInChunksOptionsCopyWithImpl<UploadFileInChunksOptions>(this as UploadFileInChunksOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadFileInChunksOptions&&(identical(other.concurrencyLimit, concurrencyLimit) || other.concurrencyLimit == concurrencyLimit)&&(identical(other.chunkSizeBytes, chunkSizeBytes) || other.chunkSizeBytes == chunkSizeBytes)&&(identical(other.uploadName, uploadName) || other.uploadName == uploadName)&&(identical(other.maxQueueSize, maxQueueSize) || other.maxQueueSize == maxQueueSize)&&(identical(other.uploadId, uploadId) || other.uploadId == uploadId)&&(identical(other.autoAbortFailure, autoAbortFailure) || other.autoAbortFailure == autoAbortFailure)&&const DeepCollectionEquality().equals(other.partsMap, partsMap)&&(identical(other.validation, validation) || other.validation == validation)&&const DeepCollectionEquality().equals(other.headers, headers));
}


@override
int get hashCode => Object.hash(runtimeType,concurrencyLimit,chunkSizeBytes,uploadName,maxQueueSize,uploadId,autoAbortFailure,const DeepCollectionEquality().hash(partsMap),validation,const DeepCollectionEquality().hash(headers));

@override
String toString() {
  return 'UploadFileInChunksOptions(concurrencyLimit: $concurrencyLimit, chunkSizeBytes: $chunkSizeBytes, uploadName: $uploadName, maxQueueSize: $maxQueueSize, uploadId: $uploadId, autoAbortFailure: $autoAbortFailure, partsMap: $partsMap, validation: $validation, headers: $headers)';
}


}

/// @nodoc
abstract mixin class $UploadFileInChunksOptionsCopyWith<$Res>  {
  factory $UploadFileInChunksOptionsCopyWith(UploadFileInChunksOptions value, $Res Function(UploadFileInChunksOptions) _then) = _$UploadFileInChunksOptionsCopyWithImpl;
@useResult
$Res call({
 int? concurrencyLimit, int? chunkSizeBytes, String? uploadName, int? maxQueueSize, String? uploadId, bool? autoAbortFailure, Map<int, String>? partsMap, ValidationType? validation, Map<String, String>? headers
});




}
/// @nodoc
class _$UploadFileInChunksOptionsCopyWithImpl<$Res>
    implements $UploadFileInChunksOptionsCopyWith<$Res> {
  _$UploadFileInChunksOptionsCopyWithImpl(this._self, this._then);

  final UploadFileInChunksOptions _self;
  final $Res Function(UploadFileInChunksOptions) _then;

/// Create a copy of UploadFileInChunksOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? concurrencyLimit = freezed,Object? chunkSizeBytes = freezed,Object? uploadName = freezed,Object? maxQueueSize = freezed,Object? uploadId = freezed,Object? autoAbortFailure = freezed,Object? partsMap = freezed,Object? validation = freezed,Object? headers = freezed,}) {
  return _then(_self.copyWith(
concurrencyLimit: freezed == concurrencyLimit ? _self.concurrencyLimit : concurrencyLimit // ignore: cast_nullable_to_non_nullable
as int?,chunkSizeBytes: freezed == chunkSizeBytes ? _self.chunkSizeBytes : chunkSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,uploadName: freezed == uploadName ? _self.uploadName : uploadName // ignore: cast_nullable_to_non_nullable
as String?,maxQueueSize: freezed == maxQueueSize ? _self.maxQueueSize : maxQueueSize // ignore: cast_nullable_to_non_nullable
as int?,uploadId: freezed == uploadId ? _self.uploadId : uploadId // ignore: cast_nullable_to_non_nullable
as String?,autoAbortFailure: freezed == autoAbortFailure ? _self.autoAbortFailure : autoAbortFailure // ignore: cast_nullable_to_non_nullable
as bool?,partsMap: freezed == partsMap ? _self.partsMap : partsMap // ignore: cast_nullable_to_non_nullable
as Map<int, String>?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,headers: freezed == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}



/// @nodoc


class _UploadFileInChunksOptions implements UploadFileInChunksOptions {
  const _UploadFileInChunksOptions({this.concurrencyLimit, this.chunkSizeBytes, this.uploadName, this.maxQueueSize, this.uploadId, this.autoAbortFailure, final  Map<int, String>? partsMap, this.validation, final  Map<String, String>? headers}): _partsMap = partsMap,_headers = headers;
  

/// Maximum number of concurrent chunk uploads.
@override final  int? concurrencyLimit;
/// Size of each chunk in bytes.
@override final  int? chunkSizeBytes;
/// Name for the upload operation.
@override final  String? uploadName;
/// Maximum size of the upload queue.
@override final  int? maxQueueSize;
/// ID of an existing upload to resume.
@override final  String? uploadId;
/// If `true`, automatically abort the upload on failure.
@override final  bool? autoAbortFailure;
/// Map of chunk indices to their part identifiers (for resuming).
 final  Map<int, String>? _partsMap;
/// Map of chunk indices to their part identifiers (for resuming).
@override Map<int, String>? get partsMap {
  final value = _partsMap;
  if (value == null) return null;
  if (_partsMap is EqualUnmodifiableMapView) return _partsMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Validation type for data integrity checks.
@override final  ValidationType? validation;
/// Additional headers to include in upload requests.
 final  Map<String, String>? _headers;
/// Additional headers to include in upload requests.
@override Map<String, String>? get headers {
  final value = _headers;
  if (value == null) return null;
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of UploadFileInChunksOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadFileInChunksOptionsCopyWith<_UploadFileInChunksOptions> get copyWith => __$UploadFileInChunksOptionsCopyWithImpl<_UploadFileInChunksOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadFileInChunksOptions&&(identical(other.concurrencyLimit, concurrencyLimit) || other.concurrencyLimit == concurrencyLimit)&&(identical(other.chunkSizeBytes, chunkSizeBytes) || other.chunkSizeBytes == chunkSizeBytes)&&(identical(other.uploadName, uploadName) || other.uploadName == uploadName)&&(identical(other.maxQueueSize, maxQueueSize) || other.maxQueueSize == maxQueueSize)&&(identical(other.uploadId, uploadId) || other.uploadId == uploadId)&&(identical(other.autoAbortFailure, autoAbortFailure) || other.autoAbortFailure == autoAbortFailure)&&const DeepCollectionEquality().equals(other._partsMap, _partsMap)&&(identical(other.validation, validation) || other.validation == validation)&&const DeepCollectionEquality().equals(other._headers, _headers));
}


@override
int get hashCode => Object.hash(runtimeType,concurrencyLimit,chunkSizeBytes,uploadName,maxQueueSize,uploadId,autoAbortFailure,const DeepCollectionEquality().hash(_partsMap),validation,const DeepCollectionEquality().hash(_headers));

@override
String toString() {
  return 'UploadFileInChunksOptions(concurrencyLimit: $concurrencyLimit, chunkSizeBytes: $chunkSizeBytes, uploadName: $uploadName, maxQueueSize: $maxQueueSize, uploadId: $uploadId, autoAbortFailure: $autoAbortFailure, partsMap: $partsMap, validation: $validation, headers: $headers)';
}


}

/// @nodoc
abstract mixin class _$UploadFileInChunksOptionsCopyWith<$Res> implements $UploadFileInChunksOptionsCopyWith<$Res> {
  factory _$UploadFileInChunksOptionsCopyWith(_UploadFileInChunksOptions value, $Res Function(_UploadFileInChunksOptions) _then) = __$UploadFileInChunksOptionsCopyWithImpl;
@override @useResult
$Res call({
 int? concurrencyLimit, int? chunkSizeBytes, String? uploadName, int? maxQueueSize, String? uploadId, bool? autoAbortFailure, Map<int, String>? partsMap, ValidationType? validation, Map<String, String>? headers
});




}
/// @nodoc
class __$UploadFileInChunksOptionsCopyWithImpl<$Res>
    implements _$UploadFileInChunksOptionsCopyWith<$Res> {
  __$UploadFileInChunksOptionsCopyWithImpl(this._self, this._then);

  final _UploadFileInChunksOptions _self;
  final $Res Function(_UploadFileInChunksOptions) _then;

/// Create a copy of UploadFileInChunksOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? concurrencyLimit = freezed,Object? chunkSizeBytes = freezed,Object? uploadName = freezed,Object? maxQueueSize = freezed,Object? uploadId = freezed,Object? autoAbortFailure = freezed,Object? partsMap = freezed,Object? validation = freezed,Object? headers = freezed,}) {
  return _then(_UploadFileInChunksOptions(
concurrencyLimit: freezed == concurrencyLimit ? _self.concurrencyLimit : concurrencyLimit // ignore: cast_nullable_to_non_nullable
as int?,chunkSizeBytes: freezed == chunkSizeBytes ? _self.chunkSizeBytes : chunkSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,uploadName: freezed == uploadName ? _self.uploadName : uploadName // ignore: cast_nullable_to_non_nullable
as String?,maxQueueSize: freezed == maxQueueSize ? _self.maxQueueSize : maxQueueSize // ignore: cast_nullable_to_non_nullable
as int?,uploadId: freezed == uploadId ? _self.uploadId : uploadId // ignore: cast_nullable_to_non_nullable
as String?,autoAbortFailure: freezed == autoAbortFailure ? _self.autoAbortFailure : autoAbortFailure // ignore: cast_nullable_to_non_nullable
as bool?,partsMap: freezed == partsMap ? _self._partsMap : partsMap // ignore: cast_nullable_to_non_nullable
as Map<int, String>?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

/// @nodoc
mixin _$DownloadFileInChunksOptions {

/// Maximum number of concurrent chunk downloads.
 int? get concurrencyLimit;/// Size of each chunk in bytes.
 int? get chunkSizeBytes;/// Local file to save the downloaded content to.
 io.File? get destination;/// Validation type for data integrity checks.
 ValidationType? get validation;/// If `true`, don't return the downloaded data (only save to file).
 bool? get noReturnData;
/// Create a copy of DownloadFileInChunksOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadFileInChunksOptionsCopyWith<DownloadFileInChunksOptions> get copyWith => _$DownloadFileInChunksOptionsCopyWithImpl<DownloadFileInChunksOptions>(this as DownloadFileInChunksOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadFileInChunksOptions&&(identical(other.concurrencyLimit, concurrencyLimit) || other.concurrencyLimit == concurrencyLimit)&&(identical(other.chunkSizeBytes, chunkSizeBytes) || other.chunkSizeBytes == chunkSizeBytes)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.noReturnData, noReturnData) || other.noReturnData == noReturnData));
}


@override
int get hashCode => Object.hash(runtimeType,concurrencyLimit,chunkSizeBytes,destination,validation,noReturnData);

@override
String toString() {
  return 'DownloadFileInChunksOptions(concurrencyLimit: $concurrencyLimit, chunkSizeBytes: $chunkSizeBytes, destination: $destination, validation: $validation, noReturnData: $noReturnData)';
}


}

/// @nodoc
abstract mixin class $DownloadFileInChunksOptionsCopyWith<$Res>  {
  factory $DownloadFileInChunksOptionsCopyWith(DownloadFileInChunksOptions value, $Res Function(DownloadFileInChunksOptions) _then) = _$DownloadFileInChunksOptionsCopyWithImpl;
@useResult
$Res call({
 int? concurrencyLimit, int? chunkSizeBytes, io.File? destination, ValidationType? validation, bool? noReturnData
});




}
/// @nodoc
class _$DownloadFileInChunksOptionsCopyWithImpl<$Res>
    implements $DownloadFileInChunksOptionsCopyWith<$Res> {
  _$DownloadFileInChunksOptionsCopyWithImpl(this._self, this._then);

  final DownloadFileInChunksOptions _self;
  final $Res Function(DownloadFileInChunksOptions) _then;

/// Create a copy of DownloadFileInChunksOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? concurrencyLimit = freezed,Object? chunkSizeBytes = freezed,Object? destination = freezed,Object? validation = freezed,Object? noReturnData = freezed,}) {
  return _then(_self.copyWith(
concurrencyLimit: freezed == concurrencyLimit ? _self.concurrencyLimit : concurrencyLimit // ignore: cast_nullable_to_non_nullable
as int?,chunkSizeBytes: freezed == chunkSizeBytes ? _self.chunkSizeBytes : chunkSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as io.File?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,noReturnData: freezed == noReturnData ? _self.noReturnData : noReturnData // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}



/// @nodoc


class _DownloadFileInChunksOptions implements DownloadFileInChunksOptions {
  const _DownloadFileInChunksOptions({this.concurrencyLimit, this.chunkSizeBytes, this.destination, this.validation, this.noReturnData});
  

/// Maximum number of concurrent chunk downloads.
@override final  int? concurrencyLimit;
/// Size of each chunk in bytes.
@override final  int? chunkSizeBytes;
/// Local file to save the downloaded content to.
@override final  io.File? destination;
/// Validation type for data integrity checks.
@override final  ValidationType? validation;
/// If `true`, don't return the downloaded data (only save to file).
@override final  bool? noReturnData;

/// Create a copy of DownloadFileInChunksOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadFileInChunksOptionsCopyWith<_DownloadFileInChunksOptions> get copyWith => __$DownloadFileInChunksOptionsCopyWithImpl<_DownloadFileInChunksOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadFileInChunksOptions&&(identical(other.concurrencyLimit, concurrencyLimit) || other.concurrencyLimit == concurrencyLimit)&&(identical(other.chunkSizeBytes, chunkSizeBytes) || other.chunkSizeBytes == chunkSizeBytes)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.noReturnData, noReturnData) || other.noReturnData == noReturnData));
}


@override
int get hashCode => Object.hash(runtimeType,concurrencyLimit,chunkSizeBytes,destination,validation,noReturnData);

@override
String toString() {
  return 'DownloadFileInChunksOptions(concurrencyLimit: $concurrencyLimit, chunkSizeBytes: $chunkSizeBytes, destination: $destination, validation: $validation, noReturnData: $noReturnData)';
}


}

/// @nodoc
abstract mixin class _$DownloadFileInChunksOptionsCopyWith<$Res> implements $DownloadFileInChunksOptionsCopyWith<$Res> {
  factory _$DownloadFileInChunksOptionsCopyWith(_DownloadFileInChunksOptions value, $Res Function(_DownloadFileInChunksOptions) _then) = __$DownloadFileInChunksOptionsCopyWithImpl;
@override @useResult
$Res call({
 int? concurrencyLimit, int? chunkSizeBytes, io.File? destination, ValidationType? validation, bool? noReturnData
});




}
/// @nodoc
class __$DownloadFileInChunksOptionsCopyWithImpl<$Res>
    implements _$DownloadFileInChunksOptionsCopyWith<$Res> {
  __$DownloadFileInChunksOptionsCopyWithImpl(this._self, this._then);

  final _DownloadFileInChunksOptions _self;
  final $Res Function(_DownloadFileInChunksOptions) _then;

/// Create a copy of DownloadFileInChunksOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? concurrencyLimit = freezed,Object? chunkSizeBytes = freezed,Object? destination = freezed,Object? validation = freezed,Object? noReturnData = freezed,}) {
  return _then(_DownloadFileInChunksOptions(
concurrencyLimit: freezed == concurrencyLimit ? _self.concurrencyLimit : concurrencyLimit // ignore: cast_nullable_to_non_nullable
as int?,chunkSizeBytes: freezed == chunkSizeBytes ? _self.chunkSizeBytes : chunkSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as io.File?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationType?,noReturnData: freezed == noReturnData ? _self.noReturnData : noReturnData // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$ContentLengthRange {

/// Minimum content length in bytes.
 int get min;/// Maximum content length in bytes.
 int get max;
/// Create a copy of ContentLengthRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentLengthRangeCopyWith<ContentLengthRange> get copyWith => _$ContentLengthRangeCopyWithImpl<ContentLengthRange>(this as ContentLengthRange, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentLengthRange&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'ContentLengthRange(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class $ContentLengthRangeCopyWith<$Res>  {
  factory $ContentLengthRangeCopyWith(ContentLengthRange value, $Res Function(ContentLengthRange) _then) = _$ContentLengthRangeCopyWithImpl;
@useResult
$Res call({
 int min, int max
});




}
/// @nodoc
class _$ContentLengthRangeCopyWithImpl<$Res>
    implements $ContentLengthRangeCopyWith<$Res> {
  _$ContentLengthRangeCopyWithImpl(this._self, this._then);

  final ContentLengthRange _self;
  final $Res Function(ContentLengthRange) _then;

/// Create a copy of ContentLengthRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? min = null,Object? max = null,}) {
  return _then(_self.copyWith(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}



/// @nodoc


class _ContentLengthRange implements ContentLengthRange {
  const _ContentLengthRange({required this.min, required this.max});
  

/// Minimum content length in bytes.
@override final  int min;
/// Maximum content length in bytes.
@override final  int max;

/// Create a copy of ContentLengthRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentLengthRangeCopyWith<_ContentLengthRange> get copyWith => __$ContentLengthRangeCopyWithImpl<_ContentLengthRange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentLengthRange&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'ContentLengthRange(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class _$ContentLengthRangeCopyWith<$Res> implements $ContentLengthRangeCopyWith<$Res> {
  factory _$ContentLengthRangeCopyWith(_ContentLengthRange value, $Res Function(_ContentLengthRange) _then) = __$ContentLengthRangeCopyWithImpl;
@override @useResult
$Res call({
 int min, int max
});




}
/// @nodoc
class __$ContentLengthRangeCopyWithImpl<$Res>
    implements _$ContentLengthRangeCopyWith<$Res> {
  __$ContentLengthRangeCopyWithImpl(this._self, this._then);

  final _ContentLengthRange _self;
  final $Res Function(_ContentLengthRange) _then;

/// Create a copy of ContentLengthRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? min = null,Object? max = null,}) {
  return _then(_ContentLengthRange(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GenerateSignedPostPolicyV2Options {

/// Expiration time for the policy.
 DateTime get expires;/// Equality conditions for form fields.
///
/// Each condition is an array of `['$field', 'value']`.
/// Example: `[['\$Content-Type', 'image/jpeg']]`
 List<List<String>>? get equals;/// Prefix conditions for form fields.
///
/// Each condition is an array of `['$field', 'prefix']`.
/// Example: `[['\$key', 'uploads/']]`
 List<List<String>>? get startsWith;/// ACL for the uploaded object (e.g., 'public-read', 'private').
 String? get acl;/// URL to redirect to on successful upload.
 String? get successRedirect;/// HTTP status to return on success (as string, e.g., '200', '201').
 String? get successStatus;/// Content length range constraint.
 ContentLengthRange? get contentLengthRange;/// Custom signing endpoint for the IAM signBlob API.
 Uri? get signingEndpoint;
/// Create a copy of GenerateSignedPostPolicyV2Options
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateSignedPostPolicyV2OptionsCopyWith<GenerateSignedPostPolicyV2Options> get copyWith => _$GenerateSignedPostPolicyV2OptionsCopyWithImpl<GenerateSignedPostPolicyV2Options>(this as GenerateSignedPostPolicyV2Options, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateSignedPostPolicyV2Options&&(identical(other.expires, expires) || other.expires == expires)&&const DeepCollectionEquality().equals(other.equals, equals)&&const DeepCollectionEquality().equals(other.startsWith, startsWith)&&(identical(other.acl, acl) || other.acl == acl)&&(identical(other.successRedirect, successRedirect) || other.successRedirect == successRedirect)&&(identical(other.successStatus, successStatus) || other.successStatus == successStatus)&&(identical(other.contentLengthRange, contentLengthRange) || other.contentLengthRange == contentLengthRange)&&(identical(other.signingEndpoint, signingEndpoint) || other.signingEndpoint == signingEndpoint));
}


@override
int get hashCode => Object.hash(runtimeType,expires,const DeepCollectionEquality().hash(equals),const DeepCollectionEquality().hash(startsWith),acl,successRedirect,successStatus,contentLengthRange,signingEndpoint);

@override
String toString() {
  return 'GenerateSignedPostPolicyV2Options(expires: $expires, equals: $equals, startsWith: $startsWith, acl: $acl, successRedirect: $successRedirect, successStatus: $successStatus, contentLengthRange: $contentLengthRange, signingEndpoint: $signingEndpoint)';
}


}

/// @nodoc
abstract mixin class $GenerateSignedPostPolicyV2OptionsCopyWith<$Res>  {
  factory $GenerateSignedPostPolicyV2OptionsCopyWith(GenerateSignedPostPolicyV2Options value, $Res Function(GenerateSignedPostPolicyV2Options) _then) = _$GenerateSignedPostPolicyV2OptionsCopyWithImpl;
@useResult
$Res call({
 DateTime expires, List<List<String>>? equals, List<List<String>>? startsWith, String? acl, String? successRedirect, String? successStatus, ContentLengthRange? contentLengthRange, Uri? signingEndpoint
});


$ContentLengthRangeCopyWith<$Res>? get contentLengthRange;

}
/// @nodoc
class _$GenerateSignedPostPolicyV2OptionsCopyWithImpl<$Res>
    implements $GenerateSignedPostPolicyV2OptionsCopyWith<$Res> {
  _$GenerateSignedPostPolicyV2OptionsCopyWithImpl(this._self, this._then);

  final GenerateSignedPostPolicyV2Options _self;
  final $Res Function(GenerateSignedPostPolicyV2Options) _then;

/// Create a copy of GenerateSignedPostPolicyV2Options
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expires = null,Object? equals = freezed,Object? startsWith = freezed,Object? acl = freezed,Object? successRedirect = freezed,Object? successStatus = freezed,Object? contentLengthRange = freezed,Object? signingEndpoint = freezed,}) {
  return _then(_self.copyWith(
expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime,equals: freezed == equals ? _self.equals : equals // ignore: cast_nullable_to_non_nullable
as List<List<String>>?,startsWith: freezed == startsWith ? _self.startsWith : startsWith // ignore: cast_nullable_to_non_nullable
as List<List<String>>?,acl: freezed == acl ? _self.acl : acl // ignore: cast_nullable_to_non_nullable
as String?,successRedirect: freezed == successRedirect ? _self.successRedirect : successRedirect // ignore: cast_nullable_to_non_nullable
as String?,successStatus: freezed == successStatus ? _self.successStatus : successStatus // ignore: cast_nullable_to_non_nullable
as String?,contentLengthRange: freezed == contentLengthRange ? _self.contentLengthRange : contentLengthRange // ignore: cast_nullable_to_non_nullable
as ContentLengthRange?,signingEndpoint: freezed == signingEndpoint ? _self.signingEndpoint : signingEndpoint // ignore: cast_nullable_to_non_nullable
as Uri?,
  ));
}
/// Create a copy of GenerateSignedPostPolicyV2Options
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentLengthRangeCopyWith<$Res>? get contentLengthRange {
    if (_self.contentLengthRange == null) {
    return null;
  }

  return $ContentLengthRangeCopyWith<$Res>(_self.contentLengthRange!, (value) {
    return _then(_self.copyWith(contentLengthRange: value));
  });
}
}



/// @nodoc


class _GenerateSignedPostPolicyV2Options implements GenerateSignedPostPolicyV2Options {
  const _GenerateSignedPostPolicyV2Options({required this.expires, final  List<List<String>>? equals, final  List<List<String>>? startsWith, this.acl, this.successRedirect, this.successStatus, this.contentLengthRange, this.signingEndpoint}): _equals = equals,_startsWith = startsWith;
  

/// Expiration time for the policy.
@override final  DateTime expires;
/// Equality conditions for form fields.
///
/// Each condition is an array of `['$field', 'value']`.
/// Example: `[['\$Content-Type', 'image/jpeg']]`
 final  List<List<String>>? _equals;
/// Equality conditions for form fields.
///
/// Each condition is an array of `['$field', 'value']`.
/// Example: `[['\$Content-Type', 'image/jpeg']]`
@override List<List<String>>? get equals {
  final value = _equals;
  if (value == null) return null;
  if (_equals is EqualUnmodifiableListView) return _equals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Prefix conditions for form fields.
///
/// Each condition is an array of `['$field', 'prefix']`.
/// Example: `[['\$key', 'uploads/']]`
 final  List<List<String>>? _startsWith;
/// Prefix conditions for form fields.
///
/// Each condition is an array of `['$field', 'prefix']`.
/// Example: `[['\$key', 'uploads/']]`
@override List<List<String>>? get startsWith {
  final value = _startsWith;
  if (value == null) return null;
  if (_startsWith is EqualUnmodifiableListView) return _startsWith;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// ACL for the uploaded object (e.g., 'public-read', 'private').
@override final  String? acl;
/// URL to redirect to on successful upload.
@override final  String? successRedirect;
/// HTTP status to return on success (as string, e.g., '200', '201').
@override final  String? successStatus;
/// Content length range constraint.
@override final  ContentLengthRange? contentLengthRange;
/// Custom signing endpoint for the IAM signBlob API.
@override final  Uri? signingEndpoint;

/// Create a copy of GenerateSignedPostPolicyV2Options
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerateSignedPostPolicyV2OptionsCopyWith<_GenerateSignedPostPolicyV2Options> get copyWith => __$GenerateSignedPostPolicyV2OptionsCopyWithImpl<_GenerateSignedPostPolicyV2Options>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateSignedPostPolicyV2Options&&(identical(other.expires, expires) || other.expires == expires)&&const DeepCollectionEquality().equals(other._equals, _equals)&&const DeepCollectionEquality().equals(other._startsWith, _startsWith)&&(identical(other.acl, acl) || other.acl == acl)&&(identical(other.successRedirect, successRedirect) || other.successRedirect == successRedirect)&&(identical(other.successStatus, successStatus) || other.successStatus == successStatus)&&(identical(other.contentLengthRange, contentLengthRange) || other.contentLengthRange == contentLengthRange)&&(identical(other.signingEndpoint, signingEndpoint) || other.signingEndpoint == signingEndpoint));
}


@override
int get hashCode => Object.hash(runtimeType,expires,const DeepCollectionEquality().hash(_equals),const DeepCollectionEquality().hash(_startsWith),acl,successRedirect,successStatus,contentLengthRange,signingEndpoint);

@override
String toString() {
  return 'GenerateSignedPostPolicyV2Options(expires: $expires, equals: $equals, startsWith: $startsWith, acl: $acl, successRedirect: $successRedirect, successStatus: $successStatus, contentLengthRange: $contentLengthRange, signingEndpoint: $signingEndpoint)';
}


}

/// @nodoc
abstract mixin class _$GenerateSignedPostPolicyV2OptionsCopyWith<$Res> implements $GenerateSignedPostPolicyV2OptionsCopyWith<$Res> {
  factory _$GenerateSignedPostPolicyV2OptionsCopyWith(_GenerateSignedPostPolicyV2Options value, $Res Function(_GenerateSignedPostPolicyV2Options) _then) = __$GenerateSignedPostPolicyV2OptionsCopyWithImpl;
@override @useResult
$Res call({
 DateTime expires, List<List<String>>? equals, List<List<String>>? startsWith, String? acl, String? successRedirect, String? successStatus, ContentLengthRange? contentLengthRange, Uri? signingEndpoint
});


@override $ContentLengthRangeCopyWith<$Res>? get contentLengthRange;

}
/// @nodoc
class __$GenerateSignedPostPolicyV2OptionsCopyWithImpl<$Res>
    implements _$GenerateSignedPostPolicyV2OptionsCopyWith<$Res> {
  __$GenerateSignedPostPolicyV2OptionsCopyWithImpl(this._self, this._then);

  final _GenerateSignedPostPolicyV2Options _self;
  final $Res Function(_GenerateSignedPostPolicyV2Options) _then;

/// Create a copy of GenerateSignedPostPolicyV2Options
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expires = null,Object? equals = freezed,Object? startsWith = freezed,Object? acl = freezed,Object? successRedirect = freezed,Object? successStatus = freezed,Object? contentLengthRange = freezed,Object? signingEndpoint = freezed,}) {
  return _then(_GenerateSignedPostPolicyV2Options(
expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime,equals: freezed == equals ? _self._equals : equals // ignore: cast_nullable_to_non_nullable
as List<List<String>>?,startsWith: freezed == startsWith ? _self._startsWith : startsWith // ignore: cast_nullable_to_non_nullable
as List<List<String>>?,acl: freezed == acl ? _self.acl : acl // ignore: cast_nullable_to_non_nullable
as String?,successRedirect: freezed == successRedirect ? _self.successRedirect : successRedirect // ignore: cast_nullable_to_non_nullable
as String?,successStatus: freezed == successStatus ? _self.successStatus : successStatus // ignore: cast_nullable_to_non_nullable
as String?,contentLengthRange: freezed == contentLengthRange ? _self.contentLengthRange : contentLengthRange // ignore: cast_nullable_to_non_nullable
as ContentLengthRange?,signingEndpoint: freezed == signingEndpoint ? _self.signingEndpoint : signingEndpoint // ignore: cast_nullable_to_non_nullable
as Uri?,
  ));
}

/// Create a copy of GenerateSignedPostPolicyV2Options
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentLengthRangeCopyWith<$Res>? get contentLengthRange {
    if (_self.contentLengthRange == null) {
    return null;
  }

  return $ContentLengthRangeCopyWith<$Res>(_self.contentLengthRange!, (value) {
    return _then(_self.copyWith(contentLengthRange: value));
  });
}
}

/// @nodoc
mixin _$GenerateSignedPostPolicyV4Options {

/// Expiration time for the policy (max 7 days from now).
 DateTime get expires;/// Custom bucket-bound hostname (e.g., 'https://cdn.example.com').
///
/// If provided, the returned URL will use this hostname.
 String? get bucketBoundHostname;/// Use virtual hosted-style URLs.
///
/// If `true`, URLs will be like `https://bucket.storage.googleapis.com/`
/// instead of `https://storage.googleapis.com/bucket/`.
 bool get virtualHostedStyle;/// Additional policy conditions.
///
/// Can include arrays like `['starts-with', '\$key', 'uploads/']`
/// or objects like `{acl: 'public-read'}`.
 List<Object>? get conditions;/// Form fields to include in the signed policy.
///
/// Fields prefixed with 'x-ignore-' are included in the returned fields
/// but excluded from the policy signature.
 Map<String, String>? get fields;/// Custom signing endpoint for the IAM signBlob API.
 Uri? get signingEndpoint;
/// Create a copy of GenerateSignedPostPolicyV4Options
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateSignedPostPolicyV4OptionsCopyWith<GenerateSignedPostPolicyV4Options> get copyWith => _$GenerateSignedPostPolicyV4OptionsCopyWithImpl<GenerateSignedPostPolicyV4Options>(this as GenerateSignedPostPolicyV4Options, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateSignedPostPolicyV4Options&&(identical(other.expires, expires) || other.expires == expires)&&(identical(other.bucketBoundHostname, bucketBoundHostname) || other.bucketBoundHostname == bucketBoundHostname)&&(identical(other.virtualHostedStyle, virtualHostedStyle) || other.virtualHostedStyle == virtualHostedStyle)&&const DeepCollectionEquality().equals(other.conditions, conditions)&&const DeepCollectionEquality().equals(other.fields, fields)&&(identical(other.signingEndpoint, signingEndpoint) || other.signingEndpoint == signingEndpoint));
}


@override
int get hashCode => Object.hash(runtimeType,expires,bucketBoundHostname,virtualHostedStyle,const DeepCollectionEquality().hash(conditions),const DeepCollectionEquality().hash(fields),signingEndpoint);

@override
String toString() {
  return 'GenerateSignedPostPolicyV4Options(expires: $expires, bucketBoundHostname: $bucketBoundHostname, virtualHostedStyle: $virtualHostedStyle, conditions: $conditions, fields: $fields, signingEndpoint: $signingEndpoint)';
}


}

/// @nodoc
abstract mixin class $GenerateSignedPostPolicyV4OptionsCopyWith<$Res>  {
  factory $GenerateSignedPostPolicyV4OptionsCopyWith(GenerateSignedPostPolicyV4Options value, $Res Function(GenerateSignedPostPolicyV4Options) _then) = _$GenerateSignedPostPolicyV4OptionsCopyWithImpl;
@useResult
$Res call({
 DateTime expires, String? bucketBoundHostname, bool virtualHostedStyle, List<Object>? conditions, Map<String, String>? fields, Uri? signingEndpoint
});




}
/// @nodoc
class _$GenerateSignedPostPolicyV4OptionsCopyWithImpl<$Res>
    implements $GenerateSignedPostPolicyV4OptionsCopyWith<$Res> {
  _$GenerateSignedPostPolicyV4OptionsCopyWithImpl(this._self, this._then);

  final GenerateSignedPostPolicyV4Options _self;
  final $Res Function(GenerateSignedPostPolicyV4Options) _then;

/// Create a copy of GenerateSignedPostPolicyV4Options
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expires = null,Object? bucketBoundHostname = freezed,Object? virtualHostedStyle = null,Object? conditions = freezed,Object? fields = freezed,Object? signingEndpoint = freezed,}) {
  return _then(_self.copyWith(
expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime,bucketBoundHostname: freezed == bucketBoundHostname ? _self.bucketBoundHostname : bucketBoundHostname // ignore: cast_nullable_to_non_nullable
as String?,virtualHostedStyle: null == virtualHostedStyle ? _self.virtualHostedStyle : virtualHostedStyle // ignore: cast_nullable_to_non_nullable
as bool,conditions: freezed == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<Object>?,fields: freezed == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,signingEndpoint: freezed == signingEndpoint ? _self.signingEndpoint : signingEndpoint // ignore: cast_nullable_to_non_nullable
as Uri?,
  ));
}

}



/// @nodoc


class _GenerateSignedPostPolicyV4Options implements GenerateSignedPostPolicyV4Options {
  const _GenerateSignedPostPolicyV4Options({required this.expires, this.bucketBoundHostname, this.virtualHostedStyle = false, final  List<Object>? conditions, final  Map<String, String>? fields, this.signingEndpoint}): _conditions = conditions,_fields = fields;
  

/// Expiration time for the policy (max 7 days from now).
@override final  DateTime expires;
/// Custom bucket-bound hostname (e.g., 'https://cdn.example.com').
///
/// If provided, the returned URL will use this hostname.
@override final  String? bucketBoundHostname;
/// Use virtual hosted-style URLs.
///
/// If `true`, URLs will be like `https://bucket.storage.googleapis.com/`
/// instead of `https://storage.googleapis.com/bucket/`.
@override@JsonKey() final  bool virtualHostedStyle;
/// Additional policy conditions.
///
/// Can include arrays like `['starts-with', '\$key', 'uploads/']`
/// or objects like `{acl: 'public-read'}`.
 final  List<Object>? _conditions;
/// Additional policy conditions.
///
/// Can include arrays like `['starts-with', '\$key', 'uploads/']`
/// or objects like `{acl: 'public-read'}`.
@override List<Object>? get conditions {
  final value = _conditions;
  if (value == null) return null;
  if (_conditions is EqualUnmodifiableListView) return _conditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Form fields to include in the signed policy.
///
/// Fields prefixed with 'x-ignore-' are included in the returned fields
/// but excluded from the policy signature.
 final  Map<String, String>? _fields;
/// Form fields to include in the signed policy.
///
/// Fields prefixed with 'x-ignore-' are included in the returned fields
/// but excluded from the policy signature.
@override Map<String, String>? get fields {
  final value = _fields;
  if (value == null) return null;
  if (_fields is EqualUnmodifiableMapView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Custom signing endpoint for the IAM signBlob API.
@override final  Uri? signingEndpoint;

/// Create a copy of GenerateSignedPostPolicyV4Options
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerateSignedPostPolicyV4OptionsCopyWith<_GenerateSignedPostPolicyV4Options> get copyWith => __$GenerateSignedPostPolicyV4OptionsCopyWithImpl<_GenerateSignedPostPolicyV4Options>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateSignedPostPolicyV4Options&&(identical(other.expires, expires) || other.expires == expires)&&(identical(other.bucketBoundHostname, bucketBoundHostname) || other.bucketBoundHostname == bucketBoundHostname)&&(identical(other.virtualHostedStyle, virtualHostedStyle) || other.virtualHostedStyle == virtualHostedStyle)&&const DeepCollectionEquality().equals(other._conditions, _conditions)&&const DeepCollectionEquality().equals(other._fields, _fields)&&(identical(other.signingEndpoint, signingEndpoint) || other.signingEndpoint == signingEndpoint));
}


@override
int get hashCode => Object.hash(runtimeType,expires,bucketBoundHostname,virtualHostedStyle,const DeepCollectionEquality().hash(_conditions),const DeepCollectionEquality().hash(_fields),signingEndpoint);

@override
String toString() {
  return 'GenerateSignedPostPolicyV4Options(expires: $expires, bucketBoundHostname: $bucketBoundHostname, virtualHostedStyle: $virtualHostedStyle, conditions: $conditions, fields: $fields, signingEndpoint: $signingEndpoint)';
}


}

/// @nodoc
abstract mixin class _$GenerateSignedPostPolicyV4OptionsCopyWith<$Res> implements $GenerateSignedPostPolicyV4OptionsCopyWith<$Res> {
  factory _$GenerateSignedPostPolicyV4OptionsCopyWith(_GenerateSignedPostPolicyV4Options value, $Res Function(_GenerateSignedPostPolicyV4Options) _then) = __$GenerateSignedPostPolicyV4OptionsCopyWithImpl;
@override @useResult
$Res call({
 DateTime expires, String? bucketBoundHostname, bool virtualHostedStyle, List<Object>? conditions, Map<String, String>? fields, Uri? signingEndpoint
});




}
/// @nodoc
class __$GenerateSignedPostPolicyV4OptionsCopyWithImpl<$Res>
    implements _$GenerateSignedPostPolicyV4OptionsCopyWith<$Res> {
  __$GenerateSignedPostPolicyV4OptionsCopyWithImpl(this._self, this._then);

  final _GenerateSignedPostPolicyV4Options _self;
  final $Res Function(_GenerateSignedPostPolicyV4Options) _then;

/// Create a copy of GenerateSignedPostPolicyV4Options
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expires = null,Object? bucketBoundHostname = freezed,Object? virtualHostedStyle = null,Object? conditions = freezed,Object? fields = freezed,Object? signingEndpoint = freezed,}) {
  return _then(_GenerateSignedPostPolicyV4Options(
expires: null == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime,bucketBoundHostname: freezed == bucketBoundHostname ? _self.bucketBoundHostname : bucketBoundHostname // ignore: cast_nullable_to_non_nullable
as String?,virtualHostedStyle: null == virtualHostedStyle ? _self.virtualHostedStyle : virtualHostedStyle // ignore: cast_nullable_to_non_nullable
as bool,conditions: freezed == conditions ? _self._conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<Object>?,fields: freezed == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,signingEndpoint: freezed == signingEndpoint ? _self.signingEndpoint : signingEndpoint // ignore: cast_nullable_to_non_nullable
as Uri?,
  ));
}


}

/// @nodoc
mixin _$PolicyDocument {

/// The policy document as plain text JSON.
 String get string;/// The policy document base64-encoded.
 String get base64;/// The base64-encoded signature.
 String get signature;
/// Create a copy of PolicyDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PolicyDocumentCopyWith<PolicyDocument> get copyWith => _$PolicyDocumentCopyWithImpl<PolicyDocument>(this as PolicyDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PolicyDocument&&(identical(other.string, string) || other.string == string)&&(identical(other.base64, base64) || other.base64 == base64)&&(identical(other.signature, signature) || other.signature == signature));
}


@override
int get hashCode => Object.hash(runtimeType,string,base64,signature);

@override
String toString() {
  return 'PolicyDocument(string: $string, base64: $base64, signature: $signature)';
}


}

/// @nodoc
abstract mixin class $PolicyDocumentCopyWith<$Res>  {
  factory $PolicyDocumentCopyWith(PolicyDocument value, $Res Function(PolicyDocument) _then) = _$PolicyDocumentCopyWithImpl;
@useResult
$Res call({
 String string, String base64, String signature
});




}
/// @nodoc
class _$PolicyDocumentCopyWithImpl<$Res>
    implements $PolicyDocumentCopyWith<$Res> {
  _$PolicyDocumentCopyWithImpl(this._self, this._then);

  final PolicyDocument _self;
  final $Res Function(PolicyDocument) _then;

/// Create a copy of PolicyDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? string = null,Object? base64 = null,Object? signature = null,}) {
  return _then(_self.copyWith(
string: null == string ? _self.string : string // ignore: cast_nullable_to_non_nullable
as String,base64: null == base64 ? _self.base64 : base64 // ignore: cast_nullable_to_non_nullable
as String,signature: null == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}



/// @nodoc


class _PolicyDocument implements PolicyDocument {
  const _PolicyDocument({required this.string, required this.base64, required this.signature});
  

/// The policy document as plain text JSON.
@override final  String string;
/// The policy document base64-encoded.
@override final  String base64;
/// The base64-encoded signature.
@override final  String signature;

/// Create a copy of PolicyDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PolicyDocumentCopyWith<_PolicyDocument> get copyWith => __$PolicyDocumentCopyWithImpl<_PolicyDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PolicyDocument&&(identical(other.string, string) || other.string == string)&&(identical(other.base64, base64) || other.base64 == base64)&&(identical(other.signature, signature) || other.signature == signature));
}


@override
int get hashCode => Object.hash(runtimeType,string,base64,signature);

@override
String toString() {
  return 'PolicyDocument(string: $string, base64: $base64, signature: $signature)';
}


}

/// @nodoc
abstract mixin class _$PolicyDocumentCopyWith<$Res> implements $PolicyDocumentCopyWith<$Res> {
  factory _$PolicyDocumentCopyWith(_PolicyDocument value, $Res Function(_PolicyDocument) _then) = __$PolicyDocumentCopyWithImpl;
@override @useResult
$Res call({
 String string, String base64, String signature
});




}
/// @nodoc
class __$PolicyDocumentCopyWithImpl<$Res>
    implements _$PolicyDocumentCopyWith<$Res> {
  __$PolicyDocumentCopyWithImpl(this._self, this._then);

  final _PolicyDocument _self;
  final $Res Function(_PolicyDocument) _then;

/// Create a copy of PolicyDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? string = null,Object? base64 = null,Object? signature = null,}) {
  return _then(_PolicyDocument(
string: null == string ? _self.string : string // ignore: cast_nullable_to_non_nullable
as String,base64: null == base64 ? _self.base64 : base64 // ignore: cast_nullable_to_non_nullable
as String,signature: null == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SignedPostPolicyV4Output {

/// The POST request URL.
 String get url;/// Form fields to include in the POST request.
///
/// Includes the `policy` and `x-goog-signature` fields along with
/// any user-provided fields.
 Map<String, String> get fields;
/// Create a copy of SignedPostPolicyV4Output
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignedPostPolicyV4OutputCopyWith<SignedPostPolicyV4Output> get copyWith => _$SignedPostPolicyV4OutputCopyWithImpl<SignedPostPolicyV4Output>(this as SignedPostPolicyV4Output, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignedPostPolicyV4Output&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.fields, fields));
}


@override
int get hashCode => Object.hash(runtimeType,url,const DeepCollectionEquality().hash(fields));

@override
String toString() {
  return 'SignedPostPolicyV4Output(url: $url, fields: $fields)';
}


}

/// @nodoc
abstract mixin class $SignedPostPolicyV4OutputCopyWith<$Res>  {
  factory $SignedPostPolicyV4OutputCopyWith(SignedPostPolicyV4Output value, $Res Function(SignedPostPolicyV4Output) _then) = _$SignedPostPolicyV4OutputCopyWithImpl;
@useResult
$Res call({
 String url, Map<String, String> fields
});




}
/// @nodoc
class _$SignedPostPolicyV4OutputCopyWithImpl<$Res>
    implements $SignedPostPolicyV4OutputCopyWith<$Res> {
  _$SignedPostPolicyV4OutputCopyWithImpl(this._self, this._then);

  final SignedPostPolicyV4Output _self;
  final $Res Function(SignedPostPolicyV4Output) _then;

/// Create a copy of SignedPostPolicyV4Output
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? fields = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}



/// @nodoc


class _SignedPostPolicyV4Output implements SignedPostPolicyV4Output {
  const _SignedPostPolicyV4Output({required this.url, required final  Map<String, String> fields}): _fields = fields;
  

/// The POST request URL.
@override final  String url;
/// Form fields to include in the POST request.
///
/// Includes the `policy` and `x-goog-signature` fields along with
/// any user-provided fields.
 final  Map<String, String> _fields;
/// Form fields to include in the POST request.
///
/// Includes the `policy` and `x-goog-signature` fields along with
/// any user-provided fields.
@override Map<String, String> get fields {
  if (_fields is EqualUnmodifiableMapView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fields);
}


/// Create a copy of SignedPostPolicyV4Output
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignedPostPolicyV4OutputCopyWith<_SignedPostPolicyV4Output> get copyWith => __$SignedPostPolicyV4OutputCopyWithImpl<_SignedPostPolicyV4Output>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignedPostPolicyV4Output&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._fields, _fields));
}


@override
int get hashCode => Object.hash(runtimeType,url,const DeepCollectionEquality().hash(_fields));

@override
String toString() {
  return 'SignedPostPolicyV4Output(url: $url, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$SignedPostPolicyV4OutputCopyWith<$Res> implements $SignedPostPolicyV4OutputCopyWith<$Res> {
  factory _$SignedPostPolicyV4OutputCopyWith(_SignedPostPolicyV4Output value, $Res Function(_SignedPostPolicyV4Output) _then) = __$SignedPostPolicyV4OutputCopyWithImpl;
@override @useResult
$Res call({
 String url, Map<String, String> fields
});




}
/// @nodoc
class __$SignedPostPolicyV4OutputCopyWithImpl<$Res>
    implements _$SignedPostPolicyV4OutputCopyWith<$Res> {
  __$SignedPostPolicyV4OutputCopyWithImpl(this._self, this._then);

  final _SignedPostPolicyV4Output _self;
  final $Res Function(_SignedPostPolicyV4Output) _then;

/// Create a copy of SignedPostPolicyV4Output
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? fields = null,}) {
  return _then(_SignedPostPolicyV4Output(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
