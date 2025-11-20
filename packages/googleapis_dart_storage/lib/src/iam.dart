part of '../googleapis_dart_storage.dart';

typedef Policy = storage_v1.Policy;

class Iam {
  final Bucket bucket;

  Iam._(this.bucket);

  Future<Policy> getPolicy([GetPolicyOptions? options]) async {
    final executor = RetryExecutor(bucket.storage);
    return await executor.retry<Policy>(
      (client) async {
        return await client.buckets.getIamPolicy(
          bucket.id,
          userProject: options?.userProject,
          optionsRequestedPolicyVersion: options?.requestedPolicyVersion,
        );
      },
    );
  }

  Future<Policy> setPolicy(Policy policy, [SetPolicyOptions? options]) async {
    final executor = policy.etag == null
        ? RetryExecutor.withoutRetries(bucket.storage)
        : RetryExecutor(bucket.storage);

    return await executor.retry<Policy>(
      (client) async {
        return await client.buckets.setIamPolicy(
          policy,
          bucket.id,
          userProject: options?.userProject,
        );
      },
    );
  }

  Future<Map<String, bool>> testPermissions(List<String> permissions,
      [TestIamPermissionsOptions? options]) async {
    final executor = RetryExecutor(bucket.storage);
    return await executor.retry(
      (client) async {
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
      },
    );
  }
}

class GetPolicyOptions {
  final String? userProject;
  final int? requestedPolicyVersion;

  const GetPolicyOptions({
    this.userProject,
    this.requestedPolicyVersion,
  });
}

class SetPolicyOptions {
  final String? userProject;

  const SetPolicyOptions({
    this.userProject,
  });
}

class TestIamPermissionsOptions {
  final String? userProject;

  const TestIamPermissionsOptions({
    this.userProject,
  });
}
