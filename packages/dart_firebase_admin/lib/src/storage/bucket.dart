part of '../storage.dart';

class Bucket {
  Bucket._({
    required this.name,
    required this.storage,
    required this.options,
  });

  final String name;
  final Storage storage;
  final BucketOptions options;

  get acl {
    throw UnimplementedError('TODO');
  }

  get cloudStorageURI {
    throw UnimplementedError('TODO');
  }

  get iam {
    throw UnimplementedError('TODO');
  }

  get intancePreconditionOpts {
    throw UnimplementedError('TODO');
  }

  get signer {
    throw UnimplementedError('TODO');
  }

  get userProject {
    throw UnimplementedError('TODO');
  }

  addLifecycleRule() {
    throw UnimplementedError('TODO');
  }

  combine() {
    throw UnimplementedError('TODO');
  }

  createChannel() {
    throw UnimplementedError('TODO');
  }

  createNotification() {
    throw UnimplementedError('TODO');
  }

  deleteFiles() {
    throw UnimplementedError('TODO');
  }

  deleteLabels() {
    throw UnimplementedError('TODO');
  }

  // TODO: Why does this have an underscore?
  disableAutoRetryConditionallyIdempotent_() {
    throw UnimplementedError('TODO');
  }

  disableRequesterPays() {
    throw UnimplementedError('TODO');
  }

  enableLogging() {
    throw UnimplementedError('TODO');
  }

  enableRequesterPays() {
    throw UnimplementedError('TODO');
  }

  file() {
    throw UnimplementedError('TODO');
  }

  getFiles() {
    throw UnimplementedError('TODO');
  }

  getId() {
    throw UnimplementedError('TODO');
  }

  getLabels() {
    throw UnimplementedError('TODO');
  }

  getNotifications() {
    throw UnimplementedError('TODO');
  }

  getSignedUrl() {
    throw UnimplementedError('TODO');
  }

  lock() {
    throw UnimplementedError('TODO');
  }

  makePrivate() {
    throw UnimplementedError('TODO');
  }

  makePublic() {
    throw UnimplementedError('TODO');
  }

  notification() {
    throw UnimplementedError('TODO');
  }

  removeRetentionPeriod() {
    throw UnimplementedError('TODO');
  }

  setRetentionPeriod() {
    throw UnimplementedError('TODO');
  }

  setStorageClass() {
    throw UnimplementedError('TODO');
  }

  setUserProject() {
    throw UnimplementedError('TODO');
  }

  upload() {
    throw UnimplementedError('TODO');
  }
}

class BucketOptions {
  BucketOptions({
    this.crc32cGenerator,
    this.generation,
    this.kmsKeyName,
    this.preconditionOpts,
    this.softDeleted,
    this.userProject,
  });

  final CRC32CValidatorGenerator? crc32cGenerator;
  final int? generation;
  final String? kmsKeyName;
  final PreconditionOptions? preconditionOpts;
  final bool? softDeleted;
  final String? userProject;
}
