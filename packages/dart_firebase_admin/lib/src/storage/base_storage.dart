part of '../storage.dart';

abstract class _BaseStorage {
  _BaseStorage({
    required this.app,
  });

  final FirebaseAdminApp app;

  Bucket bucket([String? name]);

  get acl {
    throw UnimplementedError('TODO');
  }

  get retryOptions {
    throw UnimplementedError('TODO');
  }

  channel() {
    throw UnimplementedError('TODO');
  }

  createBucket() {
    throw UnimplementedError('TODO');
  }

  createHMACKey() {
    throw UnimplementedError('TODO');
  }

  getBuckets() {
    throw UnimplementedError('TODO');
  }

  getHmacKeys() {
    throw UnimplementedError('TODO');
  }

  getHmacKeysStream() {
    throw UnimplementedError('TODO');
  }

  getServiceAccount() {
    throw UnimplementedError('TODO');
  }

  hmacKey() {
    throw UnimplementedError('TODO');
  }
}
