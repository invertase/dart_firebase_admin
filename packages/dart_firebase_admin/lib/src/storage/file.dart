part of '../storage.dart';

class File {
  File._({
    required this.name,
    required this.bucket,
    required this.options,
  });

  final String name;
  final Bucket bucket;
  final FileOptions options;

  get acl {
    throw UnimplementedError('TODO');
  }

  get cloudStorageURL {
    throw UnimplementedError('TODO');
  }

  get crc32cGenerator {
    throw UnimplementedError('TODO');
  }

  get generation {
    throw UnimplementedError('TODO');
  }

  get parent {
    throw UnimplementedError('TODO');
  }

  get restoreToken {
    throw UnimplementedError('TODO');
  }

  get signer {
    throw UnimplementedError('TODO');
  }

  get userProject {
    throw UnimplementedError('TODO');
  }

  copy() {
    throw UnimplementedError('TODO');
  }

  createReadStream() {
    throw UnimplementedError('TODO');
  }

  createResumableUpload() {
    throw UnimplementedError('TODO');
  }

  createWriteStream() {
    throw UnimplementedError('TODO');
  }

  delete() {
    throw UnimplementedError('TODO');
  }

  download() {
    throw UnimplementedError('TODO');
  }

  from() {
    throw UnimplementedError('TODO');
  }

  generateSignedPostPolicyV2() {
    throw UnimplementedError('TODO');
  }

  generateSignedPostPolicyV4() {
    throw UnimplementedError('TODO');
  }

  get() {
    throw UnimplementedError('TODO');
  }

  getExpirationDate() {
    throw UnimplementedError('TODO');
  }

  getSignedUrl() {
    throw UnimplementedError('TODO');
  }

  isPublic() {
    throw UnimplementedError('TODO');
  }

  makePrivate() {
    throw UnimplementedError('TODO');
  }

  makePublic() {
    throw UnimplementedError('TODO');
  }

  move() {
    throw UnimplementedError('TODO');
  }

  moveFileAtomic() {
    throw UnimplementedError('TODO');
  }

  publicUrl() {
    throw UnimplementedError('TODO');
  }

  rename() {
    throw UnimplementedError('TODO');
  }

  // TODO: Do we need this?
  request() {
    throw UnimplementedError('TODO');
  }

  restore() {
    throw UnimplementedError('TODO');
  }

  rotateEncryptionKey() {
    throw UnimplementedError('TODO');
  }

  save() {
    throw UnimplementedError('TODO');
  }

  setEncryptionKey() {
    throw UnimplementedError('TODO');
  }

  setMetadata() {
    throw UnimplementedError('TODO');
  }

  setStorageClass() {
    throw UnimplementedError('TODO');
  }

  setUserProject() {
    throw UnimplementedError('TODO');
  }
}

class FileOptions {
  FileOptions({
    this.crc32cGenerator,
    this.encryptionKey,
    this.generation,
    this.kmsKeyName,
    this.preconditionOpts,
    this.restoreToken,
    this.userProject,
  });

  final CRC32CValidatorGenerator? crc32cGenerator;
  final Object? encryptionKey;
  final Object? generation;
  final String? kmsKeyName;
  final PreconditionOptions? preconditionOpts;
  final String? restoreToken;
  final String? userProject;
}
