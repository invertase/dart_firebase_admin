part of '../storage.dart';

abstract class ServiceObject<T> {
  ServiceObject();

  create() {
    throw UnimplementedError('TODO');
  }

  delete() {
    throw UnimplementedError('TODO');
  }

  exists() {
    throw UnimplementedError('TODO');
  }

  get() {
    throw UnimplementedError('TODO');
  }

  getMetadata() {
    throw UnimplementedError('TODO');
  }

  // TODO: Do we need this?
  getRequestInterceptors() {
    throw UnimplementedError('TODO');
  }

  setMetadata() {
    throw UnimplementedError('TODO');
  }

  request() {
    throw UnimplementedError('TODO');
  }

  requestStream() {
    throw UnimplementedError('TODO');
  }
}
