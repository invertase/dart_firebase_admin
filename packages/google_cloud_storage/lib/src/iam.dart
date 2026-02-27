part of '../google_cloud_storage.dart';

class Iam {
  final Bucket bucket;

  Iam._(this.bucket);

  Future<Policy> getPolicy([GetPolicyOptions? options]) async {
    final api = ApiExecutor(bucket.storage);
    return await api.execute<Policy>((client) async {
      return await client.buckets.getIamPolicy(
        bucket.id,
        userProject: options?.userProject,
        optionsRequestedPolicyVersion: options?.requestedPolicyVersion,
      );
    });
  }

  Future<Policy> setPolicy(Policy policy, [SetPolicyOptions? options]) async {
    final api = policy.etag == null
        ? ApiExecutor.withoutRetries(bucket.storage)
        : ApiExecutor(bucket.storage);

    return await api.execute<Policy>((client) async {
      return await client.buckets.setIamPolicy(
        policy,
        bucket.id,
        userProject: options?.userProject,
      );
    });
  }

  Future<Map<String, bool>> testPermissions(
    List<String> permissions, [
    TestIamPermissionsOptions? options,
  ]) async {
    final api = ApiExecutor(bucket.storage);
    return await api.execute((client) async {
      final response = await client.buckets.testIamPermissions(
        bucket.id,
        permissions,
        userProject: options?.userProject,
      );

      final availablePermissions = response.permissions ?? [];

      final permissionMap = <String, bool>{};
      for (final permission in permissions) {
        permissionMap[permission] = availablePermissions.contains(permission);
      }
      return permissionMap;
    });
  }
}
