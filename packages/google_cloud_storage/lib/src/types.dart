// ignore_for_file: use_super_parameters - Freezed generation breaks
import 'dart:convert';
import 'dart:io' as io;

import 'package:crypto/crypto.dart' as crypto;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:google_cloud_storage/google_cloud_storage.dart';

part 'types.freezed.dart';

/// Strategy for determining when to retry operations based on idempotency.
///
/// Matches the Node SDK IdempotencyStrategy enum semantics.
enum IdempotencyStrategy {
  /// Always retry operations, regardless of idempotency.
  retryAlways,

  /// Retry operations conditionally based on idempotency guarantees.
  retryConditional,

  /// Never retry operations.
  retryNever,
}

/// Function that determines if an error is retryable.
///
/// Returns `true` if the error should be retried, `false` otherwise.
typedef RetryableErrorFn = bool Function(Object error);

/// Options for getting the service account associated with a project.
///
/// See [Storage.getServiceAccount] for usage.
@freezed
abstract class GetServiceAccountOptions with _$GetServiceAccountOptions {
  const factory GetServiceAccountOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// The project identifier. If not provided, uses the default project.
    String? projectId,
  }) = _GetServiceAccountOptions;
}

/// Configuration options for retry behavior.
///
/// Controls how the client retries failed operations.
@freezed
abstract class RetryOptions with _$RetryOptions {
  const factory RetryOptions({
    /// Whether to automatically retry failed requests. Defaults to `true`.
    @Default(true) bool autoRetry,

    /// Maximum number of retry attempts. Defaults to `3`.
    @Default(3) int maxRetries,

    /// Maximum total time to spend on retries. Defaults to `600 seconds`.
    @Default(Duration(seconds: 600)) Duration totalTimeout,

    /// Maximum delay between retry attempts. Defaults to `64 seconds`.
    @Default(Duration(seconds: 64)) Duration maxRetryDelay,

    /// Multiplier for exponential backoff. Defaults to `2.0`.
    @Default(2.0) double retryDelayMultiplier,

    /// Custom function to determine if an error is retryable.
    ///
    /// If provided, this function is called for each error to determine
    /// whether it should be retried. If not provided, default retry logic is used.
    RetryableErrorFn? retryableErrorFn,

    /// Strategy for determining retry behavior based on idempotency.
    ///
    /// Defaults to [IdempotencyStrategy.retryConditional].
    @Default(IdempotencyStrategy.retryConditional)
    IdempotencyStrategy idempotencyStrategy,
  }) = _RetryOptions;
}

/// Base class for precondition options used in storage operations.
///
/// Preconditions allow you to ensure that operations only succeed if certain
/// conditions are met, preventing race conditions and ensuring data consistency.
class PreconditionOptions {
  const PreconditionOptions({
    this.ifGenerationMatch,
    this.ifGenerationNotMatch,
    this.ifMetagenerationMatch,
    this.ifMetagenerationNotMatch,
  });

  /// Only perform the operation if the object's generation matches this value.
  ///
  /// The generation is a monotonically increasing number that changes whenever
  /// the object's data or metadata is modified.
  final int? ifGenerationMatch;

  /// Only perform the operation if the object's generation does not match this value.
  final int? ifGenerationNotMatch;

  /// Only perform the operation if the object's metageneration matches this value.
  ///
  /// The metageneration is a monotonically increasing number that changes
  /// whenever the object's metadata is modified.
  final int? ifMetagenerationMatch;

  /// Only perform the operation if the object's metageneration does not match this value.
  final int? ifMetagenerationNotMatch;
}

/// Options for delete operations, mirroring Node's DeleteOptions.
///
/// Extends [PreconditionOptions] to include delete-specific options.
@freezed
abstract class DeleteOptions extends PreconditionOptions with _$DeleteOptions {
  const DeleteOptions._({
    int? ifGenerationMatch,
    int? ifGenerationNotMatch,
    int? ifMetagenerationMatch,
    int? ifMetagenerationNotMatch,
  }) : super(
         ifGenerationMatch: ifGenerationMatch,
         ifGenerationNotMatch: ifGenerationNotMatch,
         ifMetagenerationMatch: ifMetagenerationMatch,
         ifMetagenerationNotMatch: ifMetagenerationNotMatch,
       );

  const factory DeleteOptions({
    /// If `true`, ignore 404 errors (treat as success if object doesn't exist).
    ///
    /// Defaults to `false`.
    @Default(false) bool ignoreNotFound,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Only perform the operation if the object's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the object's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the object's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the object's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _DeleteOptions;
}

/// Configuration for Cross-Origin Resource Sharing (CORS) on a bucket.
///
/// See [Bucket.setCorsConfiguration] for usage.
typedef CorsConfiguration = storage_v1.BucketCors;

/// Options for restoring a soft-deleted bucket.
@freezed
abstract class RestoreOptions with _$RestoreOptions {
  const factory RestoreOptions({
    /// The generation of the bucket to restore.
    required int generation,

    /// The set of properties to return in the response.
    Projection? projection,

    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _RestoreOptions;
}

/// Options for setting storage class, mirroring Node's SetStorageClassOptions.
///
/// Extends [SetBucketMetadataOptions] to include storage class-specific options.
@freezed
abstract class SetStorageClassOptions extends SetBucketMetadataOptions
    with _$SetStorageClassOptions {
  const SetStorageClassOptions._({
    int? ifGenerationMatch,
    int? ifGenerationNotMatch,
    int? ifMetagenerationMatch,
    int? ifMetagenerationNotMatch,
  }) : super._(
         ifGenerationMatch: ifGenerationMatch,
         ifGenerationNotMatch: ifGenerationNotMatch,
         ifMetagenerationMatch: ifMetagenerationMatch,
         ifMetagenerationNotMatch: ifMetagenerationNotMatch,
       );

  const factory SetStorageClassOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Apply a predefined set of access controls to the bucket.
    PredefinedAcl? predefinedAcl,

    /// Only perform the operation if the bucket's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the bucket's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the bucket's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the bucket's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _SetStorageClassOptions;
}

/// Options for setting labels, mirroring Node's SetLabelsOptions.
///
/// Extends [SetBucketMetadataOptions] to include label-specific options.
@freezed
abstract class SetLabelsOptions extends SetBucketMetadataOptions
    with _$SetLabelsOptions {
  const SetLabelsOptions._({
    int? ifGenerationMatch,
    int? ifGenerationNotMatch,
    int? ifMetagenerationMatch,
    int? ifMetagenerationNotMatch,
  }) : super._(
         ifGenerationMatch: ifGenerationMatch,
         ifGenerationNotMatch: ifGenerationNotMatch,
         ifMetagenerationMatch: ifMetagenerationMatch,
         ifMetagenerationNotMatch: ifMetagenerationNotMatch,
       );

  const factory SetLabelsOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Apply a predefined set of access controls to the bucket.
    PredefinedAcl? predefinedAcl,

    /// Only perform the operation if the bucket's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the bucket's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the bucket's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the bucket's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _SetLabelsOptions;
}

/// Base class for bucket visibility options.
///
/// This is a sealed class that cannot be instantiated directly.
/// Use [MakeBucketPublicOptions] or [MakeBucketPrivateOptions] instead.
sealed class MakeBucketVisibilityOptions {
  const MakeBucketVisibilityOptions._();
}

/// Options for making a bucket public.
@freezed
abstract class MakeBucketPublicOptions with _$MakeBucketPublicOptions {
  const factory MakeBucketPublicOptions({
    /// If `true`, also make all files in the bucket public.
    bool? includeFiles,

    /// If `true`, proceed even if the bucket already has public access.
    bool? force,
  }) = _MakeBucketPublicOptions;
}

/// Options for making a bucket private.
@freezed
abstract class MakeBucketPrivateOptions with _$MakeBucketPrivateOptions {
  const factory MakeBucketPrivateOptions({
    /// If `true`, also make all files in the bucket private.
    bool? includeFiles,

    /// If `true`, proceed even if the bucket is already private.
    bool? force,

    /// Metadata to update on the bucket.
    BucketMetadata? metadata,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Precondition options for the operation.
    PreconditionOptions? preconditionOpts,
  }) = _MakeBucketPrivateOptions;
}

/// Options for making all files in a bucket public or private.
@freezed
abstract class MakeAllFilesPublicPrivateOptions
    with _$MakeAllFilesPublicPrivateOptions {
  const factory MakeAllFilesPublicPrivateOptions({
    /// If `true`, proceed even if files already have the desired visibility.
    bool? force,

    /// If `true`, make all files private.
    bool? private,

    /// If `true`, make all files public.
    bool? public,

    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _MakeAllFilesPublicPrivateOptions;
}

/// Options for enabling access logging on a bucket.
@freezed
abstract class EnableLoggingOptions with _$EnableLoggingOptions {
  const factory EnableLoggingOptions({
    /// The prefix for log object names.
    ///
    /// Log objects will be created with names starting with this prefix.
    required String prefix,

    /// The destination bucket where access logs will be stored.
    Bucket? bucket,

    /// Only perform the operation if the bucket's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the bucket's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the bucket's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the bucket's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _EnableLoggingOptions;
}

/// Options for uploading a file from the filesystem.
@freezed
abstract class UploadOptions with _$UploadOptions {
  /// The place to save your file. If given a String path, the file will be uploaded to the bucket
  /// using the string as a filename. When given a File object, your local file will be uploaded
  /// to the File object's bucket and under the File object's name. If omitted, the file is uploaded
  /// to your bucket using the name of the local file.
  const factory UploadOptions({
    UploadDestination? destination,

    /// A custom encryption key. See Customer-supplied Encryption Keys.
    EncryptionKey? encryptionKey,

    /// Automatically gzip the file. This will set metadata.contentEncoding to 'gzip'.
    /// If null, the contentType is used to determine if the file should be gzipped (auto-detect).
    bool? gzip,

    /// The name of the Cloud KMS key that will be used to encrypt the object.
    String? kmsKeyName,

    /// Metadata for the file. See Objects: insert request body for details.
    FileMetadata? metadata,

    /// The starting byte of the upload stream, for resuming an interrupted upload. Defaults to 0.
    int? offset,

    /// Apply a predefined set of access controls to this object.
    PredefinedAcl? predefinedAcl,

    /// Make the uploaded file private. (Alias for predefinedAcl = 'private')
    bool? private,

    /// Make the uploaded file public. (Alias for predefinedAcl = 'publicRead')
    bool? public,

    /// Resumable uploads are automatically enabled and must be shut off explicitly by setting to false.
    bool? resumable,

    /// Set the HTTP request timeout in milliseconds. This option is not available for resumable uploads. Default: 60000
    int? timeout,

    /// The URI for an already-created resumable upload. See File.createResumableUpload().
    String? uri,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Validation type for data integrity checks. By default, data integrity is validated with an MD5 checksum.
    ValidationType? validation,

    /// Precondition options for the upload.
    PreconditionOptions? preconditionOpts,

    /// Callback for upload progress events.
    void Function(UploadProgress)? onUploadProgress,

    /// Chunk size for resumable uploads. Default: 256KB
    int? chunkSize,

    /// High water mark for the stream. Controls buffer size.
    int? highWaterMark,

    /// Whether this is a partial upload.
    bool? isPartialUpload,
  }) = _UploadOptions;
}

/// Options for listing buckets.
@freezed
abstract class GetBucketsOptions with _$GetBucketsOptions {
  const factory GetBucketsOptions({
    /// Automatically paginate through all results. Defaults to `true`.
    @Default(true) bool? autoPaginate,

    /// The project ID to list buckets for. If not provided, uses the default project.
    String? projectId,

    /// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
    int? maxApiCalls,

    /// Maximum number of results to return per page.
    int? maxResults,

    /// Token for the next page of results.
    String? pageToken,

    /// Filter results to buckets whose names begin with this prefix.
    String? prefix,

    /// The set of properties to return in the response.
    Projection? projection,

    /// If `true`, include soft-deleted buckets in the results.
    bool? softDeleted,

    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _GetBucketsOptions;
}

/// Options for adding a lifecycle rule to a bucket.
@freezed
abstract class AddLifecycleRuleOptions with _$AddLifecycleRuleOptions {
  const factory AddLifecycleRuleOptions({
    /// If `true`, append the rule to existing rules. If `false`, replace all rules.
    ///
    /// Defaults to `true`.
    @Default(true) bool append,

    /// Only perform the operation if the bucket's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the bucket's metageneration does not match this value.
    int? ifMetagenerationNotMatch,

    /// Only perform the operation if the bucket's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the bucket's generation does not match this value.
    int? ifGenerationNotMatch,
  }) = _AddLifecycleRuleOptions;
}

/// Options for combining files, mirroring Node's CombineOptions.
///
/// Extends [PreconditionOptions] to include combine-specific options.
///
/// See [File.combine] for usage.
@freezed
abstract class CombineOptions extends PreconditionOptions
    with _$CombineOptions {
  const CombineOptions._({
    int? ifGenerationMatch,
    int? ifGenerationNotMatch,
    int? ifMetagenerationMatch,
    int? ifMetagenerationNotMatch,
  }) : super(
         ifGenerationMatch: ifGenerationMatch,
         ifGenerationNotMatch: ifGenerationNotMatch,
         ifMetagenerationMatch: ifMetagenerationMatch,
         ifMetagenerationNotMatch: ifMetagenerationNotMatch,
       );

  const factory CombineOptions({
    /// The name of the Cloud KMS key that will be used to encrypt the combined object.
    String? kmsKeyName,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Only perform the operation if the destination object's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the destination object's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the destination object's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the destination object's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _CombineOptions;
}

/// Options for setting bucket metadata, mirroring Node's SetBucketMetadataOptions.
///
/// Extends [PreconditionOptions] to include metadata-specific options.
@freezed
abstract class SetBucketMetadataOptions extends PreconditionOptions
    with _$SetBucketMetadataOptions {
  const SetBucketMetadataOptions._({
    int? ifGenerationMatch,
    int? ifGenerationNotMatch,
    int? ifMetagenerationMatch,
    int? ifMetagenerationNotMatch,
  }) : super(
         ifGenerationMatch: ifGenerationMatch,
         ifGenerationNotMatch: ifGenerationNotMatch,
         ifMetagenerationMatch: ifMetagenerationMatch,
         ifMetagenerationNotMatch: ifMetagenerationNotMatch,
       );

  const factory SetBucketMetadataOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Apply a predefined set of access controls to the bucket.
    PredefinedAcl? predefinedAcl,

    /// Only perform the operation if the bucket's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the bucket's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the bucket's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the bucket's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _SetBucketMetadataOptions;
}

/// Predefined access control lists for buckets and objects.
enum PredefinedAcl {
  /// All authenticated Google account holders have read access.
  authenticatedRead('authenticatedRead'),

  /// Only the owner has access. This is the default for new buckets and objects.
  private('private'),

  /// Project team members have access according to their roles.
  projectPrivate('projectPrivate'),

  /// All users have read access.
  publicRead('publicRead'),

  /// All users have read and write access.
  publicReadWrite('publicReadWrite');

  /// The string value expected by the Google Cloud Storage API.
  final String value;

  const PredefinedAcl(this.value);
}

/// Predefined access control lists for default object ACLs.
enum PredefinedDefaultObjectAcl {
  /// All authenticated Google account holders have read access.
  authenticatedRead,

  /// The bucket owner has full control.
  bucketOwnerFullControl,

  /// The bucket owner has read access.
  bucketOwnerRead,

  /// Only the owner has access.
  private,

  /// Project team members have access according to their roles.
  projectPrivate,

  /// All users have read access.
  publicRead,
}

/// The set of properties to return in API responses.
enum Projection {
  /// Return all properties.
  full,

  /// Return all properties except ACLs.
  noAcl,
}

/// Options for getting a bucket.
@freezed
abstract class GetBucketOptions with _$GetBucketOptions {
  const factory GetBucketOptions({
    /// Automatically create the bucket if it doesn't already exist.
    ///
    /// Defaults to `false`.
    @Default(false) bool autoCreate,

    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _GetBucketOptions;
}

/// Options for generating a signed URL for bucket operations.
@freezed
abstract class GetBucketSignedUrlOptions with _$GetBucketSignedUrlOptions {
  const factory GetBucketSignedUrlOptions({
    /// Custom host for the signed URL. Inherited from [SignedUrlConfig].
    Uri? host,

    /// Custom signing endpoint. Inherited from [SignedUrlConfig].
    Uri? signingEndpoint,

    /// The action to perform. Defaults to `'list'`.
    @Default('list') String action,

    /// The version of the signing algorithm to use.
    SignedUrlVersion? version,

    /// Custom domain name for the signed URL.
    String? cname,

    /// Use virtual-hosted-style URLs. Defaults to `false`.
    @Default(false) bool? virtualHostedStyle,

    /// When the signed URL should expire.
    required DateTime expires,

    /// Additional headers to include in the signed URL.
    Map<String, String>? extensionHeaders,

    /// Additional query parameters to include in the signed URL.
    Map<String, String>? queryParams,
  }) = _GetBucketSignedUrlOptions;
}

@freezed
abstract class CreateNotificationOptions with _$CreateNotificationOptions {
  /// An optional list of additional attributes to attach to each Cloud PubSub
  /// message published for this notification subscription.
  const factory CreateNotificationOptions({
    /// An optional list of additional attributes to attach to each Cloud PubSub
    /// message published for this notification subscription.
    Map<String, String>? customAttributes,

    /// If present, only send notifications about listed event types.
    /// If empty, send notifications for all event types.
    List<String>? eventTypes,

    /// If present, only apply this notification configuration to object names
    /// that begin with this prefix.
    String? objectNamePrefix,

    /// The desired content of the Payload. Defaults to `JSON_API_V1`.
    ///
    /// Acceptable values are:
    /// - `JSON_API_V1`
    /// - `NONE`
    String? payloadFormat,

    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _CreateNotificationOptions;
}

/// Options for bucket operations.
@freezed
abstract class BucketOptions with _$BucketOptions {
  const factory BucketOptions({
    /// Custom CRC32C generator for validation.
    Crc32Generator? crc32cGenerator,

    /// The name of the Cloud KMS key that will be used to encrypt objects in this bucket.
    String? kmsKeyName,

    /// Precondition options for the operation.
    PreconditionOptions? preconditionOpts,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// The generation of the bucket to operate on.
    int? generation,

    /// If `true`, operate on soft-deleted buckets.
    bool? softDeleted,
  }) = _BucketOptions;
}

/// Metadata for a bucket.
///
/// This is a type alias for the Google Cloud Storage API's Bucket resource.
typedef BucketMetadata = storage_v1.Bucket;

/// A lifecycle rule for a bucket.
///
/// Defines actions to take on objects based on their age or other conditions.
typedef LifecycleRule = storage_v1.BucketLifecycleRule;

/// Options for watching bucket changes.
@freezed
abstract class WatchAllOptions with _$WatchAllOptions {
  const factory WatchAllOptions({
    /// Delimiter to use for grouping object names.
    String? delimiter,

    /// Maximum number of results to return.
    int? maxResults,

    /// Token for the next page of results.
    String? pageToken,

    /// Filter results to objects whose names begin with this prefix.
    String? prefix,

    /// The set of properties to return in the response.
    String? projection,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// If `true`, include object versions in the results.
    bool? versions,
  }) = _WatchAllOptions;
}

/// Configuration for creating a notification channel.
@freezed
abstract class CreateChannelConfig with _$CreateChannelConfig {
  const factory CreateChannelConfig({
    /// The address where notifications should be sent.
    required String address,

    /// Delimiter to use for grouping object names.
    String? delimiter,

    /// Maximum number of results to return.
    int? maxResults,

    /// Token for the next page of results.
    String? pageToken,

    /// Filter results to objects whose names begin with this prefix.
    String? prefix,

    /// The set of properties to return in the response.
    String? projection,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// If `true`, include object versions in the results.
    bool? versions,
  }) = _CreateChannelConfig;
}

/// Options for creating a notification channel.
@freezed
abstract class CreateChannelOptions with _$CreateChannelOptions {
  const factory CreateChannelOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _CreateChannelOptions;
}

/// Metadata for a notification channel.
///
/// This is a type alias for the Google Cloud Storage API's Channel resource.
typedef ChannelMetadata = storage_v1.Channel;

/// Metadata for a file (object) in Google Cloud Storage.
///
/// This is a type alias for the Google Cloud Storage API's Object resource.
typedef FileMetadata = storage_v1.Object;

/// Options for file operations.
@freezed
abstract class FileOptions with _$FileOptions {
  const factory FileOptions({
    /// Custom CRC32C generator for validation.
    Crc32Generator? crc32cGenerator,

    /// Customer-supplied encryption key.
    EncryptionKey? encryptionKey,

    /// The generation of the file to operate on.
    int? generation,

    /// Token for restoring a soft-deleted file.
    String? restoreToken,

    /// The name of the Cloud KMS key that will be used to encrypt the file.
    String? kmsKeyName,

    /// Precondition options for the operation.
    PreconditionOptions? preconditionOpts,

    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _FileOptions;
}

/// Options for getting files, mirroring Node's GetFilesOptions.
///
/// Extends [PreconditionOptions] to include file listing options.
@freezed
abstract class GetFilesOptions extends PreconditionOptions
    with _$GetFilesOptions {
  const GetFilesOptions._({
    int? ifGenerationMatch,
    int? ifGenerationNotMatch,
    int? ifMetagenerationMatch,
    int? ifMetagenerationNotMatch,
  }) : super(
         ifGenerationMatch: ifGenerationMatch,
         ifGenerationNotMatch: ifGenerationNotMatch,
         ifMetagenerationMatch: ifMetagenerationMatch,
         ifMetagenerationNotMatch: ifMetagenerationNotMatch,
       );

  const factory GetFilesOptions({
    /// Automatically paginate through all results. Defaults to `true`.
    @Default(true) bool? autoPaginate,

    /// Delimiter to use for grouping object names.
    String? delimiter,

    /// End offset for listing objects.
    String? endOffset,

    /// If `true`, include folders as prefixes in the results.
    bool? includeFoldersAsPrefixes,

    /// If `true`, include trailing delimiter in prefix results.
    bool? includeTrailingDelimiter,

    /// Filter results to objects whose names begin with this prefix.
    String? prefix,

    /// Glob pattern to match object names.
    String? matchGlob,

    /// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
    int? maxApiCalls,

    /// Maximum number of results to return per page.
    int? maxResults,

    /// Token for the next page of results.
    String? pageToken,

    /// If `true`, include soft-deleted objects in the results.
    bool? softDeleted,

    /// Start offset for listing objects.
    String? startOffset,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// If `true`, include object versions in the results.
    bool? versions,

    /// Comma-separated list of fields to return in the response.
    String? fields,

    /// Only perform the operation if the object's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the object's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the object's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the object's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _GetFilesOptions;
}

/// Options for deleting files, mirroring Node's DeleteFilesOptions.
///
/// Extends [GetFilesOptions] (which extends [PreconditionOptions]) to include delete-specific options.
@freezed
abstract class DeleteFileOptions extends GetFilesOptions
    with _$DeleteFileOptions {
  const DeleteFileOptions._({
    int? ifGenerationMatch,
    int? ifGenerationNotMatch,
    int? ifMetagenerationMatch,
    int? ifMetagenerationNotMatch,
  }) : super._(
         ifGenerationMatch: ifGenerationMatch,
         ifGenerationNotMatch: ifGenerationNotMatch,
         ifMetagenerationMatch: ifMetagenerationMatch,
         ifMetagenerationNotMatch: ifMetagenerationNotMatch,
       );

  const factory DeleteFileOptions({
    /// If `true`, force deletion even if there are errors.
    bool? force,

    /// Automatically paginate through all results. Defaults to `true`.
    @Default(true) bool? autoPaginate,

    /// Delimiter to use for grouping object names.
    String? delimiter,

    /// End offset for listing objects.
    String? endOffset,

    /// If `true`, include folders as prefixes in the results.
    bool? includeFoldersAsPrefixes,

    /// If `true`, include trailing delimiter in prefix results.
    bool? includeTrailingDelimiter,

    /// Filter results to objects whose names begin with this prefix.
    String? prefix,

    /// Glob pattern to match object names.
    String? matchGlob,

    /// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
    int? maxApiCalls,

    /// Maximum number of results to return per page.
    int? maxResults,

    /// Token for the next page of results.
    String? pageToken,

    /// If `true`, include soft-deleted objects in the results.
    bool? softDeleted,

    /// Start offset for listing objects.
    String? startOffset,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// If `true`, include object versions in the results.
    bool? versions,

    /// Comma-separated list of fields to return in the response.
    String? fields,

    /// Only perform the operation if the object's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the object's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the object's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the object's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _DeleteFileOptions;
}

/// Options for getting file metadata.
@freezed
abstract class GetFileMetadataOptions with _$GetFileMetadataOptions {
  const factory GetFileMetadataOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _GetFileMetadataOptions;
}

/// Options for setting file metadata, mirroring Node's SetFileMetadataOptions.
///
/// Extends [PreconditionOptions] to include metadata-specific options.
@freezed
abstract class SetFileMetadataOptions extends PreconditionOptions
    with _$SetFileMetadataOptions {
  const SetFileMetadataOptions._({
    int? ifGenerationMatch,
    int? ifGenerationNotMatch,
    int? ifMetagenerationMatch,
    int? ifMetagenerationNotMatch,
  }) : super(
         ifGenerationMatch: ifGenerationMatch,
         ifGenerationNotMatch: ifGenerationNotMatch,
         ifMetagenerationMatch: ifMetagenerationMatch,
         ifMetagenerationNotMatch: ifMetagenerationNotMatch,
       );

  const factory SetFileMetadataOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Only perform the operation if the object's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the object's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the object's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the object's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _SetFileMetadataOptions;
}

/// Options for copying a file.
@freezed
abstract class CopyOptions with _$CopyOptions {
  const factory CopyOptions({
    /// Cache-Control header value for the destination file.
    String? cacheControl,

    /// Content-Encoding header value for the destination file.
    String? contentEncoding,

    /// Content-Type header value for the destination file.
    String? contentType,

    /// Content-Disposition header value for the destination file.
    String? contentDisposition,

    /// The name of the Cloud KMS key that will be used to encrypt the destination file.
    String? destinationKmsKeyName,

    /// Custom metadata to set on the destination file.
    Map<String, String>? metadata,

    /// Apply a predefined set of access controls to the destination file.
    PredefinedAcl? predefinedAcl,

    /// Token for resuming a copy operation.
    String? token,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Precondition options for the copy operation.
    PreconditionOptions? preconditionOpts,
  }) = _CopyOptions;
}

/// Options for moving a file.
@freezed
abstract class MoveOptions with _$MoveOptions {
  const factory MoveOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Precondition options for the move operation.
    PreconditionOptions? preconditionOpts,
  }) = _MoveOptions;
}

@freezed
abstract class RotateEncryptionKeyOptions with _$RotateEncryptionKeyOptions {
  /// Customer-supplied encryption key.
  const factory RotateEncryptionKeyOptions({
    /// Customer-supplied encryption key.
    EncryptionKey? encryptionKey,

    /// The name of the Cloud KMS key that will be used to encrypt the object.
    String? kmsKeyName,

    /// Precondition options for the copy operation.
    PreconditionOptions? preconditionOpts,
  }) = _RotateEncryptionKeyOptions;
}

/// Options for making a file private.
@freezed
abstract class MakeFilePrivateOptions with _$MakeFilePrivateOptions {
  const factory MakeFilePrivateOptions({
    /// Metadata to update on the file.
    FileMetadata? metadata,

    /// If `true`, throw an error if the file is already private.
    bool? strict,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Precondition options for the operation.
    PreconditionOptions? preconditionOpts,
  }) = _MakeFilePrivateOptions;
}

/// Options for generating a signed URL for file operations.
@freezed
abstract class GetFileSignedUrlOptions with _$GetFileSignedUrlOptions {
  const factory GetFileSignedUrlOptions({
    /// Custom host for the signed URL. Inherited from [SignedUrlConfig].
    Uri? host,

    /// Custom signing endpoint. Inherited from [SignedUrlConfig].
    Uri? signingEndpoint,

    /// The action to perform: 'read', 'write', 'delete', or 'resumable'.
    required String action,

    /// The version of the signing algorithm to use.
    SignedUrlVersion? version,

    /// Custom domain name for the signed URL.
    String? cname,

    /// Use virtual-hosted-style URLs. Defaults to `false`.
    @Default(false) bool? virtualHostedStyle,

    /// When the signed URL should expire.
    required DateTime expires,

    /// Additional headers to include in the signed URL.
    Map<String, String>? extensionHeaders,

    /// Additional query parameters to include in the signed URL.
    Map<String, String>? queryParams,

    /// MD5 hash of the content (for PUT requests).
    String? contentMd5,

    /// Content-Type header value.
    String? contentType,

    /// Filename to suggest when downloading the file.
    String? promptSaveAs,

    /// Content-Disposition header value.
    String? responseDisposition,

    /// Content-Type for the response.
    String? responseType,

    /// When the signed URL becomes accessible (for v4 signing).
    DateTime? accessibleAt,
  }) = _GetFileSignedUrlOptions;
}

/// Options for setting file storage class, mirroring Node's SetFileStorageClassOptions.
///
/// Extends [PreconditionOptions] to include storage class-specific options.
@freezed
abstract class SetFileStorageClassOptions extends PreconditionOptions
    with _$SetFileStorageClassOptions {
  const SetFileStorageClassOptions._({
    int? ifGenerationMatch,
    int? ifGenerationNotMatch,
    int? ifMetagenerationMatch,
    int? ifMetagenerationNotMatch,
  }) : super(
         ifGenerationMatch: ifGenerationMatch,
         ifGenerationNotMatch: ifGenerationNotMatch,
         ifMetagenerationMatch: ifMetagenerationMatch,
         ifMetagenerationNotMatch: ifMetagenerationNotMatch,
       );

  const factory SetFileStorageClassOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Only perform the operation if the object's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the object's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the object's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the object's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _SetFileStorageClassOptions;
}

/// Options for restoring a file, mirroring Node's RestoreFileOptions.
///
/// Extends [PreconditionOptions] to include restore-specific options.
@freezed
abstract class RestoreFileOptions extends PreconditionOptions
    with _$RestoreFileOptions {
  const RestoreFileOptions._({
    int? ifGenerationMatch,
    int? ifGenerationNotMatch,
    int? ifMetagenerationMatch,
    int? ifMetagenerationNotMatch,
  }) : super(
         ifGenerationMatch: ifGenerationMatch,
         ifGenerationNotMatch: ifGenerationNotMatch,
         ifMetagenerationMatch: ifMetagenerationMatch,
         ifMetagenerationNotMatch: ifMetagenerationNotMatch,
       );

  const factory RestoreFileOptions({
    /// The generation of the file to restore.
    required int generation,

    /// Token for restoring a soft-deleted file.
    String? restoreToken,

    /// The set of properties to return in the response.
    Projection? projection,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Only perform the operation if the object's generation matches this value.
    int? ifGenerationMatch,

    /// Only perform the operation if the object's generation does not match this value.
    int? ifGenerationNotMatch,

    /// Only perform the operation if the object's metageneration matches this value.
    int? ifMetagenerationMatch,

    /// Only perform the operation if the object's metageneration does not match this value.
    int? ifMetagenerationNotMatch,
  }) = _RestoreFileOptions;
}

/// Validation type for data integrity checks during upload and download.
enum ValidationType {
  /// Validate using CRC32C checksum (default).
  ///
  /// CRC32C is recommended for Google Cloud Storage as it's faster and
  /// more efficient than MD5.
  crc32c,

  /// Validate using MD5 checksum.
  ///
  /// MD5 is supported for compatibility but CRC32C is preferred.
  md5,

  /// Disable validation.
  ///
  /// Not recommended for production use as it skips data integrity verification.
  none,
}

/// Progress information for an upload operation.
@freezed
abstract class UploadProgress with _$UploadProgress {
  /// Number of bytes written so far.
  const factory UploadProgress({
    /// Number of bytes written so far.
    required int bytesWritten,

    /// Total number of bytes to upload, if known.
    int? totalBytes,
  }) = _UploadProgress;
}

/// Options for creating a write stream to upload a file.
@freezed
abstract class CreateWriteStreamOptions with _$CreateWriteStreamOptions {
  const CreateWriteStreamOptions._();

  /// Content type of the file. If set to 'auto', the file name is used to determine the contentType.
  const factory CreateWriteStreamOptions({
    /// Content type of the file. If set to 'auto', the file name is used to determine the contentType.
    String? contentType,

    /// If true, automatically gzip the file. If null, the contentType is used to determine if the file should be gzipped (auto-detect).
    bool? gzip,

    /// Metadata for the file. See Objects: insert request body for details.
    FileMetadata? metadata,

    /// The starting byte of the upload stream, for resuming an interrupted upload. Defaults to 0.
    int? offset,

    /// Apply a predefined set of access controls to this object.
    PredefinedAcl? predefinedAcl,

    /// Make the uploaded file private. (Alias for predefinedAcl = 'private')
    bool? private,

    /// Make the uploaded file public. (Alias for predefinedAcl = 'publicRead')
    bool? public,

    /// Force a resumable upload. Defaults to true.
    bool? resumable,

    /// Set the HTTP request timeout in milliseconds. This option is not available for resumable uploads. Default: 60000
    int? timeout,

    /// The URI for an already-created resumable upload. See File.createResumableUpload().
    String? uri,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Validation type for data integrity checks. By default, data integrity is validated with a CRC32c checksum.
    ValidationType? validation,

    /// A CRC32C to resume from when continuing a previous upload.
    String? resumeCRC32C,

    /// Precondition options for the upload.
    PreconditionOptions? preconditionOpts,

    /// Chunk size for resumable uploads. Default: 256KB
    int? chunkSize,

    /// High water mark for the stream. Controls buffer size.
    int? highWaterMark,

    /// Whether this is a partial upload.
    bool? isPartialUpload,

    /// Callback for upload progress events.
    void Function(UploadProgress)? onUploadProgress,
  }) = _CreateWriteStreamOptions;
}

/// Options for saving data to a file, mirroring Node's SaveOptions.
///
/// Extends [CreateWriteStreamOptions] to include save-specific options.
@freezed
abstract class SaveOptions extends CreateWriteStreamOptions with _$SaveOptions {
  const SaveOptions._() : super._();

  /// Options for saving data to a file.
  const factory SaveOptions({
    String? contentType,
    bool? gzip,
    FileMetadata? metadata,
    int? offset,
    PredefinedAcl? predefinedAcl,
    bool? private,
    bool? public,
    bool? resumable,
    int? timeout,
    String? uri,
    String? userProject,
    ValidationType? validation,
    String? resumeCRC32C,
    PreconditionOptions? preconditionOpts,
    int? chunkSize,
    int? highWaterMark,
    bool? isPartialUpload,

    /// Callback for upload progress events.
    void Function(UploadProgress)? onUploadProgress,
  }) = _SaveOptions;
}

/// Options for creating a resumable upload URI.
@freezed
abstract class CreateResumableUploadOptions
    with _$CreateResumableUploadOptions {
  /// Options for creating a resumable upload URI.
  const factory CreateResumableUploadOptions({
    /// Metadata for the file.
    FileMetadata? metadata,

    /// The starting byte of the upload stream, for resuming an interrupted upload. Defaults to 0.
    int? offset,

    /// Apply a predefined set of access controls to this object.
    PredefinedAcl? predefinedAcl,

    /// Make the uploaded file private. (Alias for predefinedAcl = 'private')
    bool? private,

    /// Make the uploaded file public. (Alias for predefinedAcl = 'publicRead')
    bool? public,

    /// The URI for an already-created resumable upload.
    String? uri,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Precondition options for the upload.
    PreconditionOptions? preconditionOpts,

    /// Chunk size for resumable uploads. Default: 256KB
    int? chunkSize,

    /// High water mark for the stream. Controls buffer size.
    int? highWaterMark,

    /// Whether this is a partial upload.
    bool? isPartialUpload,
  }) = _CreateResumableUploadOptions;
}

/// Options for creating a readable stream to download a file.
@freezed
abstract class CreateReadStreamOptions with _$CreateReadStreamOptions {
  /// Options for creating a readable stream to download a file.
  const factory CreateReadStreamOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Data integrity validation type.
    ValidationType? validation,

    /// Start byte for range requests.
    int? start,

    /// End byte for range requests. Negative values indicate tail requests.
    int? end,

    /// Whether to decompress gzip content. Defaults to true.
    bool? decompress,
  }) = _CreateReadStreamOptions;
}

/// Options for downloading a file.
@freezed
abstract class DownloadOptions with _$DownloadOptions {
  /// Options for downloading a file.
  const factory DownloadOptions({
    /// Local file to write the downloaded content to.
    io.File? destination,

    /// Customer-supplied encryption key.
    EncryptionKey? encryptionKey,
    // CreateReadStreamOptions fields
    String? userProject,
    ValidationType? validation,
    int? start,
    int? end,
    bool? decompress,
  }) = _DownloadOptions;
}

/// Type alias for data that can be saved to a file.
///
/// Can be:
/// - `String` - Text data
/// - `Uint8List` - Binary data
/// - `List<int>` - Byte data
/// - `Stream<List<int>>` - Streaming data
typedef SaveData = Object;

/// Customer-supplied encryption key for encrypting and decrypting objects.
///
/// See [Customer-supplied Encryption Keys](https://cloud.google.com/storage/docs/encryption/customer-supplied-keys)
/// for more information.
@freezed
abstract class EncryptionKey with _$EncryptionKey {
  const factory EncryptionKey({
    /// The encryption key encoded as base64.
    required String keyBase64,

    /// The SHA256 hash of the key, encoded as base64.
    required String keyHash,
  }) = _EncryptionKey;

  /// Creates an [EncryptionKey] from a string.
  ///
  /// The string is converted to base64, and then a SHA256 hash is computed
  /// by decoding the base64 string back to bytes and hashing those bytes.
  /// The hash is then encoded as base64.
  ///
  /// This matches the Node.js SDK's behavior for creating encryption keys.
  factory EncryptionKey.fromString(String key) {
    // Convert string to bytes, then to base64
    // This mimics: Buffer.from(encryptionKey as string).toString('base64')
    final keyBytes = utf8.encode(key);
    final keyBase64 = base64.encode(keyBytes);

    // Create SHA256 hash by decoding the base64 string back to bytes and hashing
    // This mimics: crypto.createHash('sha256').update(this.encryptionKeyBase64, 'base64').digest('base64')
    final decodedBase64 = base64.decode(keyBase64);
    final hash = crypto.sha256.convert(decodedBase64);
    final keyHash = base64.encode(hash.bytes);

    return EncryptionKey(keyBase64: keyBase64, keyHash: keyHash);
  }

  /// Creates an [EncryptionKey] from a buffer (`List<int>`).
  ///
  /// The buffer is converted to base64, and then a SHA256 hash is computed
  /// by decoding the base64 string back to bytes and hashing those bytes.
  /// The hash is then encoded as base64.
  ///
  /// This matches the Node.js SDK's behavior for creating encryption keys.
  factory EncryptionKey.fromBuffer(List<int> buffer) {
    return EncryptionKey.fromString(base64.encode(buffer));
  }
}

/// Options when constructing an [HmacKey] handle.
/// Options when constructing an HMAC key handle.
@freezed
abstract class HmacKeyOptions with _$HmacKeyOptions {
  const factory HmacKeyOptions({
    /// The project ID. If not provided, uses the default project.
    String? projectId,
  }) = _HmacKeyOptions;
}

/// Options for creating an HMAC key.
@freezed
abstract class CreateHmacKeyOptions with _$CreateHmacKeyOptions {
  const factory CreateHmacKeyOptions({
    /// The project ID. If not provided, uses the default project.
    String? projectId,

    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _CreateHmacKeyOptions;
}

/// Options for listing HMAC keys.
@freezed
abstract class GetHmacKeysOptions with _$GetHmacKeysOptions {
  const factory GetHmacKeysOptions({
    /// Automatically paginate through all results. Defaults to `true`.
    @Default(true) bool? autoPaginate,

    /// The project ID. If not provided, uses the default project.
    String? projectId,

    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// Filter results to keys for this service account email.
    String? serviceAccountEmail,

    /// If `true`, include deleted keys in the results.
    bool? showDeletedKeys,

    /// Maximum number of API calls to make. Only used if `autoPaginate` is `true`.
    int? maxApiCalls,

    /// Maximum number of results to return per page.
    int? maxResults,

    /// Token for the next page of results.
    String? pageToken,
  }) = _GetHmacKeysOptions;
}

/// State of an HMAC key.
enum HmacKeyState {
  /// The key is active and can be used for signing requests.
  active('ACTIVE'),

  /// The key is inactive and cannot be used for signing requests.
  inactive('INACTIVE'),

  /// The key has been deleted.
  deleted('DELETED');

  /// The string value expected by the Google Cloud Storage API.
  final String value;

  const HmacKeyState(this.value);
}

/// Subset of HMAC metadata that can be updated, mirroring Node's
/// SetHmacKeyMetadata.
///
/// This class represents the fields that can be updated on an HMAC key.
class SetHmacKeyMetadata extends storage_v1.HmacKeyMetadata {
  /// Creates a new [SetHmacKeyMetadata] instance.
  ///
  /// [state] must be either [HmacKeyState.active] or [HmacKeyState.inactive].
  SetHmacKeyMetadata({HmacKeyState? state, super.etag})
    : super(state: state?.value);
}

/// Metadata for an HMAC key.
///
/// This is a type alias for the Google Cloud Storage API's HmacKeyMetadata resource.
typedef HmacKeyMetadata = storage_v1.HmacKeyMetadata;

/// Options for getting an IAM policy.
@freezed
abstract class GetPolicyOptions with _$GetPolicyOptions {
  const factory GetPolicyOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,

    /// The version of the policy to retrieve.
    int? requestedPolicyVersion,
  }) = _GetPolicyOptions;
}

/// Options for setting an IAM policy.
@freezed
abstract class SetPolicyOptions with _$SetPolicyOptions {
  const factory SetPolicyOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _SetPolicyOptions;
}

/// Options for testing IAM permissions.
@freezed
abstract class TestIamPermissionsOptions with _$TestIamPermissionsOptions {
  const factory TestIamPermissionsOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _TestIamPermissionsOptions;
}

/// IAM policy for a bucket or object.
///
/// This is a type alias for the Google Cloud Storage API's Policy resource.
typedef Policy = storage_v1.Policy;

/// Options for getting notification configurations.
@freezed
abstract class GetNotificationsOptions with _$GetNotificationsOptions {
  const factory GetNotificationsOptions({
    /// The ID of the project which will be billed for the request.
    String? userProject,
  }) = _GetNotificationsOptions;
}

/// Metadata for a notification configuration.
///
/// This is a type alias for the Google Cloud Storage API's Notification resource.
typedef NotificationMetadata = storage_v1.Notification;

/// HTTP method for a signed URL.
enum SignedUrlMethod {
  /// GET method - for reading/downloading objects.
  get('GET'),

  /// PUT method - for uploading objects.
  put('PUT'),

  /// DELETE method - for deleting objects.
  delete('DELETE'),

  /// POST method - for resumable uploads.
  post('POST');

  /// The HTTP method string value.
  final String value;

  const SignedUrlMethod(this.value);
}

/// Version of the signed URL signing algorithm.
enum SignedUrlVersion {
  /// Version 2 signing (legacy).
  v2,

  /// Version 4 signing (recommended).
  v4,
}

/// Configuration for generating a signed URL, modeled after the Node SDK's
/// `SignerGetSignedUrlConfig` but simplified for v4 signing.
@freezed
abstract class SignedUrlConfig with _$SignedUrlConfig {
  const factory SignedUrlConfig({
    /// The HTTP method for the signed URL (GET, PUT, DELETE, POST).
    required SignedUrlMethod method,

    /// When the signed URL should expire.
    required DateTime expires,

    /// When the signed URL becomes accessible (for v4 signing).
    DateTime? accessibleAt,

    /// Use virtual-hosted-style URLs instead of path-style URLs.
    bool? virtualHostedStyle,

    /// The version of the signing algorithm to use.
    SignedUrlVersion? version,

    /// Custom domain name for the signed URL.
    String? cname,

    /// Additional headers to include in the signed URL.
    Map<String, String>? extensionHeaders,

    /// Additional query parameters to include in the signed URL.
    Map<String, String>? queryParams,

    /// MD5 hash of the content (for PUT requests).
    String? contentMd5,

    /// Content-Type header value.
    String? contentType,

    /// Custom host for the signed URL.
    Uri? host,

    /// Custom signing endpoint.
    Uri? signingEndpoint,
  }) = _SignedUrlConfig;
}

/// Sealed class for type-safe file/directory inputs for transfer operations.
///
/// This provides type-safe ways to specify sources for upload, download, and
/// transfer operations.
@freezed
sealed class TransferSource with _$TransferSource {
  /// Transfer a single file from the given path.
  const factory TransferSource.file(String path) = FileTransferSource;

  /// Transfer multiple files from the given paths.
  const factory TransferSource.files(List<String> paths) = FilesTransferSource;

  /// Transfer all files from the given directory path.
  const factory TransferSource.directory(String path) = DirectoryTransferSource;
}

/// Sealed class for type-safe destination inputs for copy operations.
///
/// This provides type-safe ways to specify destinations for copy operations.
@freezed
sealed class CopyDestination with _$CopyDestination {
  /// Copy to a file at the given path.
  const factory CopyDestination.path(String path) = PathCopyDestination;

  /// Copy to the given [File] object.
  const factory CopyDestination.file(BucketFile file) = FileCopyDestination;

  /// Copy to the given [Bucket] object.
  const factory CopyDestination.bucket(Bucket bucket) = BucketCopyDestination;
}

/// Sealed class for type-safe destination inputs for atomic move operations.
@freezed
sealed class MoveFileAtomicDestination with _$MoveFileAtomicDestination {
  /// Move to a file at the given path.
  const factory MoveFileAtomicDestination.path(String path) =
      PathMoveFileAtomicDestination;

  /// Move to the given [File] object.
  const factory MoveFileAtomicDestination.file(BucketFile file) =
      FileMoveFileAtomicDestination;
}

/// Destination for move operations.
///
/// Uses [CopyDestination] since move operations internally use copy.
typedef MoveDestination = CopyDestination;

/// Sealed class for type-safe destination inputs for upload operations.
@freezed
sealed class UploadDestination with _$UploadDestination {
  /// Upload to a file at the given path.
  const factory UploadDestination.path(String path) = PathUploadDestination;

  /// Upload to the given [File] object.
  const factory UploadDestination.file(BucketFile file) = FileUploadDestination;
}

/// Options for uploading many files.
@freezed
abstract class UploadManyFilesOptions with _$UploadManyFilesOptions {
  const factory UploadManyFilesOptions({
    /// Maximum number of concurrent uploads. Defaults to a reasonable value.
    int? concurrencyLimit,

    /// Custom function to build the destination path for each file.
    ///
    /// If provided, this function is called for each file to determine
    /// its destination path in the bucket.
    String Function(String path, UploadManyFilesOptions options)?
    customDestinationBuilder,

    /// If `true`, skip files that already exist in the destination.
    bool? skipIfExists,

    /// Prefix to add to all destination paths.
    String? prefix,

    /// Additional options to pass through to individual upload operations.
    UploadOptions? passthroughOptions,
  }) = _UploadManyFilesOptions;
}

/// Options for downloading many files.
@freezed
abstract class DownloadManyFilesOptions with _$DownloadManyFilesOptions {
  const factory DownloadManyFilesOptions({
    /// Maximum number of concurrent downloads. Defaults to a reasonable value.
    int? concurrencyLimit,

    /// Prefix to filter files to download.
    String? prefix,

    /// Prefix to strip from file paths when saving locally.
    String? stripPrefix,

    /// Additional options to pass through to individual download operations.
    DownloadOptions? passthroughOptions,

    /// If `true`, skip files that already exist locally.
    bool? skipIfExists,
  }) = _DownloadManyFilesOptions;
}

/// Options for uploading a file in chunks (multipart upload).
@freezed
abstract class UploadFileInChunksOptions with _$UploadFileInChunksOptions {
  const factory UploadFileInChunksOptions({
    /// Maximum number of concurrent chunk uploads.
    int? concurrencyLimit,

    /// Size of each chunk in bytes.
    int? chunkSizeBytes,

    /// Name for the upload operation.
    String? uploadName,

    /// Maximum size of the upload queue.
    int? maxQueueSize,

    /// ID of an existing upload to resume.
    String? uploadId,

    /// If `true`, automatically abort the upload on failure.
    bool? autoAbortFailure,

    /// Map of chunk indices to their part identifiers (for resuming).
    Map<int, String>? partsMap,

    /// Validation type for data integrity checks.
    ValidationType? validation,

    /// Additional headers to include in upload requests.
    Map<String, String>? headers,
  }) = _UploadFileInChunksOptions;
}

/// Options for downloading a file in chunks.
@freezed
abstract class DownloadFileInChunksOptions with _$DownloadFileInChunksOptions {
  const factory DownloadFileInChunksOptions({
    /// Maximum number of concurrent chunk downloads.
    int? concurrencyLimit,

    /// Size of each chunk in bytes.
    int? chunkSizeBytes,

    /// Local file to save the downloaded content to.
    io.File? destination,

    /// Validation type for data integrity checks.
    ValidationType? validation,

    /// If `true`, don't return the downloaded data (only save to file).
    bool? noReturnData,
  }) = _DownloadFileInChunksOptions;
}

/// Content length range constraint for POST policy.
///
/// Used in [GenerateSignedPostPolicyV2Options] to specify min/max content length.
@freezed
abstract class ContentLengthRange with _$ContentLengthRange {
  const factory ContentLengthRange({
    /// Minimum content length in bytes.
    required int min,

    /// Maximum content length in bytes.
    required int max,
  }) = _ContentLengthRange;
}

/// Options for generating a V2 signed POST policy.
///
/// V2 signed POST policies allow browser-based uploads directly to GCS.
/// See https://cloud.google.com/storage/docs/xml-api/post-object-v2
@freezed
abstract class GenerateSignedPostPolicyV2Options
    with _$GenerateSignedPostPolicyV2Options {
  const factory GenerateSignedPostPolicyV2Options({
    /// Expiration time for the policy.
    required DateTime expires,

    /// Equality conditions for form fields.
    ///
    /// Each condition is an array of `['$field', 'value']`.
    /// Example: `[['\$Content-Type', 'image/jpeg']]`
    List<List<String>>? equals,

    /// Prefix conditions for form fields.
    ///
    /// Each condition is an array of `['$field', 'prefix']`.
    /// Example: `[['\$key', 'uploads/']]`
    List<List<String>>? startsWith,

    /// ACL for the uploaded object (e.g., 'public-read', 'private').
    String? acl,

    /// URL to redirect to on successful upload.
    String? successRedirect,

    /// HTTP status to return on success (as string, e.g., '200', '201').
    String? successStatus,

    /// Content length range constraint.
    ContentLengthRange? contentLengthRange,

    /// Custom signing endpoint for the IAM signBlob API.
    Uri? signingEndpoint,
  }) = _GenerateSignedPostPolicyV2Options;
}

/// Options for generating a V4 signed POST policy.
///
/// V4 signed POST policies allow browser-based uploads directly to GCS.
/// Maximum expiration is 7 days.
/// See https://cloud.google.com/storage/docs/xml-api/post-object
@freezed
abstract class GenerateSignedPostPolicyV4Options
    with _$GenerateSignedPostPolicyV4Options {
  const factory GenerateSignedPostPolicyV4Options({
    /// Expiration time for the policy (max 7 days from now).
    required DateTime expires,

    /// Custom bucket-bound hostname (e.g., 'https://cdn.example.com').
    ///
    /// If provided, the returned URL will use this hostname.
    String? bucketBoundHostname,

    /// Use virtual hosted-style URLs.
    ///
    /// If `true`, URLs will be like `https://bucket.storage.googleapis.com/`
    /// instead of `https://storage.googleapis.com/bucket/`.
    @Default(false) bool virtualHostedStyle,

    /// Additional policy conditions.
    ///
    /// Can include arrays like `['starts-with', '\$key', 'uploads/']`
    /// or objects like `{acl: 'public-read'}`.
    List<Object>? conditions,

    /// Form fields to include in the signed policy.
    ///
    /// Fields prefixed with 'x-ignore-' are included in the returned fields
    /// but excluded from the policy signature.
    Map<String, String>? fields,

    /// Custom signing endpoint for the IAM signBlob API.
    Uri? signingEndpoint,
  }) = _GenerateSignedPostPolicyV4Options;
}

/// V2 signed policy document.
///
/// Returned by [BucketFile.generateSignedPostPolicyV2].
@freezed
abstract class PolicyDocument with _$PolicyDocument {
  const factory PolicyDocument({
    /// The policy document as plain text JSON.
    required String string,

    /// The policy document base64-encoded.
    required String base64,

    /// The base64-encoded signature.
    required String signature,
  }) = _PolicyDocument;
}

/// V4 signed POST policy output.
///
/// Returned by [BucketFile.generateSignedPostPolicyV4].
@freezed
abstract class SignedPostPolicyV4Output with _$SignedPostPolicyV4Output {
  const factory SignedPostPolicyV4Output({
    /// The POST request URL.
    required String url,

    /// Form fields to include in the POST request.
    ///
    /// Includes the `policy` and `x-goog-signature` fields along with
    /// any user-provided fields.
    required Map<String, String> fields,
  }) = _SignedPostPolicyV4Output;
}

/// Exception thrown when signing a policy fails.
class SigningError implements Exception {
  /// Creates a new [SigningError] with the given [message].
  SigningError(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'SigningError: $message';
}
