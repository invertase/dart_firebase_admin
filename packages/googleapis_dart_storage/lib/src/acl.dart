part of '../googleapis_dart_storage.dart';

/// Team role within a project team, matching the Node SDK's team values.
enum ProjectTeamRole {
  editors('editors'),
  owners('owners'),
  viewers('viewers');

  final String value;
  const ProjectTeamRole(this.value);
}

/// Project team information for ACL entries.
///
/// Represents a Google Cloud project team with an optional project number
/// and team role.
final class ProjectTeam {
  final String? projectNumber;
  final ProjectTeamRole? team;

  const ProjectTeam({this.projectNumber, this.team});
}

/// Simplified representation of an ACL entry, similar to the Node SDK's
/// AccessControlObject.
class AclEntry {
  final String entity;
  final String role;
  final ProjectTeam? projectTeam;

  const AclEntry({
    required this.entity,
    required this.role,
    this.projectTeam,
  });
}

/// Scope of the ACL helper, matching how Node distinguishes bucket, default
/// object, and object ACLs.
enum AclScope { bucket, bucketDefaultObject, object }

/// Core ACL helper, modeled after the Node SDK `Acl` class but implemented on
/// top of the Dart `storage_v1` API.
class Acl {
  final Storage _storage;
  final String bucket;
  final String? object;
  final AclScope scope;

  /// Convenience accessors for `owners`, `readers`, `writers`, `fullControl`,
  /// similar to the Node SDK's dynamic role accessors.
  late final AclRoleAccessor owners = AclRoleAccessor(
    this,
    _AclRole.owner.value,
  );
  late final AclRoleAccessor readers = AclRoleAccessor(
    this,
    _AclRole.reader.value,
  );
  late final AclRoleAccessor writers = AclRoleAccessor(
    this,
    _AclRole.writer.value,
  );
  late final AclRoleAccessor fullControl = AclRoleAccessor(
    this,
    _AclRole.fullControl.value,
  );

  Acl._bucketAcl(this._storage, this.bucket)
      : object = null,
        scope = AclScope.bucket;

  Acl._bucketDefaultObjectAcl(this._storage, this.bucket)
      : object = null,
        scope = AclScope.bucketDefaultObject;

  Acl._objectAcl(this._storage, this.bucket, this.object)
      : scope = AclScope.object;

  /// Add an ACL entry for the given [entity] and [role].
  ///
  /// For object ACLs, a specific [generation] may be selected. For Requester
  /// Pays buckets, [userProject] can be set.
  ///
  /// Note: this is non-idempotent, so we explicitly avoid automatic retries.
  Future<AclEntry> add({
    required String entity,
    required String role,
    int? generation,
    String? userProject,
  }) async {
    final executor = RetryExecutor.withoutRetries(_storage);

    try {
      return executor.retry<AclEntry>(
        (client) async {
          switch (scope) {
            case AclScope.bucket:
              final acl = storage_v1.BucketAccessControl()
                ..entity = entity
                ..role = role.toUpperCase();
              final resp = await client.bucketAccessControls.insert(
                acl,
                bucket,
                userProject: userProject,
              );
              return _fromBucketAccessControl(resp);
            case AclScope.bucketDefaultObject:
              final acl = storage_v1.ObjectAccessControl()
                ..entity = entity
                ..role = role.toUpperCase();
              final resp = await client.defaultObjectAccessControls.insert(
                acl,
                bucket,
                userProject: userProject,
              );
              return _fromObjectAccessControl(resp);
            case AclScope.object:
              if (object == null) {
                throw ApiError(
                    'AclScope.object requires a non-null object name.');
              }
              final acl = storage_v1.ObjectAccessControl()
                ..entity = entity
                ..role = role.toUpperCase();
              final resp = await client.objectAccessControls.insert(
                acl,
                bucket,
                object!,
                generation: generation?.toString(),
                userProject: userProject,
              );
              return _fromObjectAccessControl(resp);
          }
        },
      );
    } catch (e) {
      throw ApiError('Failed to add ACL entry for $entity', details: e);
    }
  }

  /// Delete an ACL entry for [entity].
  Future<void> delete({
    required String entity,
    int? generation,
    String? userProject,
  }) async {
    final executor = RetryExecutor(_storage);

    await executor.retry<void>(
      (client) async {
        switch (scope) {
          case AclScope.bucket:
            await client.bucketAccessControls.delete(
              bucket,
              entity,
              userProject: userProject,
            );
            break;
          case AclScope.bucketDefaultObject:
            await client.defaultObjectAccessControls.delete(
              bucket,
              entity,
              userProject: userProject,
            );
            break;
          case AclScope.object:
            if (object == null) {
              throw ApiError(
                'AclScope.object requires a non-null object name.',
              );
            }
            await client.objectAccessControls.delete(
              bucket,
              object!,
              entity,
              generation: generation?.toString(),
              userProject: userProject,
            );
            break;
        }
      },
    );
  }

  /// Get a single ACL entry for [entity].
  Future<AclEntry> get({
    required String entity,
    int? generation,
    String? userProject,
  }) async {
    final executor = RetryExecutor(_storage);

    try {
      return executor.retry<AclEntry>(
        (client) async {
          switch (scope) {
            case AclScope.bucket:
              final resp = await client.bucketAccessControls.get(
                bucket,
                entity,
                userProject: userProject,
              );
              return _fromBucketAccessControl(resp);
            case AclScope.bucketDefaultObject:
              final resp = await client.defaultObjectAccessControls.get(
                bucket,
                entity,
                userProject: userProject,
              );
              return _fromObjectAccessControl(resp);
            case AclScope.object:
              if (object == null) {
                throw ApiError(
                    'AclScope.object requires a non-null object name.');
              }
              final resp = await client.objectAccessControls.get(
                bucket,
                object!,
                entity,
                generation: generation?.toString(),
                userProject: userProject,
              );
              return _fromObjectAccessControl(resp);
          }
        },
      );
    } catch (e) {
      throw ApiError('Failed to get ACL entry for $entity', details: e);
    }
  }

  /// List all ACL entries for this scope.
  Future<List<AclEntry>> getAll({int? generation, String? userProject}) async {
    final executor = RetryExecutor(_storage);

    try {
      return executor.retry<List<AclEntry>>(
        (client) async {
          switch (scope) {
            case AclScope.bucket:
              final resp = await client.bucketAccessControls.list(
                bucket,
                userProject: userProject,
              );
              final items =
                  resp.items ?? const <storage_v1.BucketAccessControl>[];
              return items.map(_fromBucketAccessControl).toList();
            case AclScope.bucketDefaultObject:
              final resp = await client.defaultObjectAccessControls.list(
                bucket,
                userProject: userProject,
              );
              final items =
                  resp.items ?? const <storage_v1.ObjectAccessControl>[];
              return items.map(_fromObjectAccessControl).toList();
            case AclScope.object:
              if (object == null) {
                throw ApiError(
                    'AclScope.object requires a non-null object name.');
              }
              final resp = await client.objectAccessControls.list(
                bucket,
                object!,
                generation: generation?.toString(),
                userProject: userProject,
              );
              final items =
                  resp.items ?? const <storage_v1.ObjectAccessControl>[];
              return items.map(_fromObjectAccessControl).toList();
          }
        },
      );
    } catch (e) {
      throw ApiError('Failed to list ACL entries', details: e);
    }
  }

  /// Update an existing ACL entry for [entity] with a new [role].
  Future<AclEntry> update({
    required String entity,
    required String role,
    int? generation,
    String? userProject,
  }) async {
    final executor = RetryExecutor(_storage);

    return executor.retry<AclEntry>(
      (client) async {
        switch (scope) {
          case AclScope.bucket:
            final acl = storage_v1.BucketAccessControl()
              ..role = role.toUpperCase();
            final resp = await client.bucketAccessControls.update(
              acl,
              bucket,
              entity,
              userProject: userProject,
            );
            return _fromBucketAccessControl(resp);
          case AclScope.bucketDefaultObject:
            final acl = storage_v1.ObjectAccessControl()
              ..role = role.toUpperCase();
            final resp = await client.defaultObjectAccessControls.update(
              acl,
              bucket,
              entity,
              userProject: userProject,
            );
            return _fromObjectAccessControl(resp);
          case AclScope.object:
            if (object == null) {
              throw ApiError(
                'AclScope.object requires a non-null object name.',
              );
            }
            final acl = storage_v1.ObjectAccessControl()
              ..role = role.toUpperCase();
            final resp = await client.objectAccessControls.update(
              acl,
              bucket,
              object!,
              entity,
              generation: generation?.toString(),
              userProject: userProject,
            );
            return _fromObjectAccessControl(resp);
        }
      },
    );
  }

  AclEntry _fromBucketAccessControl(storage_v1.BucketAccessControl acl) {
    return AclEntry(
      entity: acl.entity ?? '',
      role: acl.role ?? '',
      projectTeam: null,
    );
  }

  AclEntry _fromObjectAccessControl(storage_v1.ObjectAccessControl acl) {
    ProjectTeam? projectTeam;
    final teamData = acl.projectTeam;
    if (teamData != null) {
      ProjectTeamRole? teamRole;
      final teamValue = teamData.team;
      if (teamValue == 'editors') {
        teamRole = ProjectTeamRole.editors;
      } else if (teamValue == 'owners') {
        teamRole = ProjectTeamRole.owners;
      } else if (teamValue == 'viewers') {
        teamRole = ProjectTeamRole.viewers;
      }
      projectTeam = ProjectTeam(
        projectNumber: teamData.projectNumber,
        team: teamRole,
      );
    }

    return AclEntry(
      entity: acl.entity ?? '',
      role: acl.role ?? '',
      projectTeam: projectTeam,
    );
  }
}

/// Internal enum of roles, mirroring the Node SDK's OWNER/READER/WRITER/FULL_CONTROL.
enum _AclRole {
  owner('OWNER'),
  reader('READER'),
  writer('WRITER'),
  fullControl('FULL_CONTROL');

  final String value;
  const _AclRole(this.value);
}

/// Helper that mirrors Node's `AclRoleAccessorMethods`, but with a typed API.
class AclRoleAccessor {
  final Acl _acl;
  final String _role;

  AclRoleAccessor(this._acl, this._role);

  // Special entity groups.

  Future<AclEntry> addAllUsers({int? generation, String? userProject}) =>
      _acl.add(
        entity: 'allUsers',
        role: _role,
        generation: generation,
        userProject: userProject,
      );

  Future<void> deleteAllUsers({int? generation, String? userProject}) =>
      _acl.delete(
        entity: 'allUsers',
        generation: generation,
        userProject: userProject,
      );

  Future<AclEntry> addAllAuthenticatedUsers({
    int? generation,
    String? userProject,
  }) =>
      _acl.add(
        entity: 'allAuthenticatedUsers',
        role: _role,
        generation: generation,
        userProject: userProject,
      );

  Future<void> deleteAllAuthenticatedUsers({
    int? generation,
    String? userProject,
  }) =>
      _acl.delete(
        entity: 'allAuthenticatedUsers',
        generation: generation,
        userProject: userProject,
      );

  // Domain, group, project, and user.

  Future<AclEntry> addDomain(
    String domain, {
    int? generation,
    String? userProject,
  }) =>
      _acl.add(
        entity: 'domain-$domain',
        role: _role,
        generation: generation,
        userProject: userProject,
      );

  Future<void> deleteDomain(
    String domain, {
    int? generation,
    String? userProject,
  }) =>
      _acl.delete(
        entity: 'domain-$domain',
        generation: generation,
        userProject: userProject,
      );

  Future<AclEntry> addGroup(
    String idOrEmail, {
    int? generation,
    String? userProject,
  }) =>
      _acl.add(
        entity: 'group-$idOrEmail',
        role: _role,
        generation: generation,
        userProject: userProject,
      );

  Future<void> deleteGroup(
    String idOrEmail, {
    int? generation,
    String? userProject,
  }) =>
      _acl.delete(
        entity: 'group-$idOrEmail',
        generation: generation,
        userProject: userProject,
      );

  Future<AclEntry> addProject(
    String projectId, {
    int? generation,
    String? userProject,
  }) =>
      _acl.add(
        entity: 'project-$projectId',
        role: _role,
        generation: generation,
        userProject: userProject,
      );

  Future<void> deleteProject(
    String projectId, {
    int? generation,
    String? userProject,
  }) =>
      _acl.delete(
        entity: 'project-$projectId',
        generation: generation,
        userProject: userProject,
      );

  Future<AclEntry> addUser(
    String idOrEmail, {
    int? generation,
    String? userProject,
  }) =>
      _acl.add(
        entity: 'user-$idOrEmail',
        role: _role,
        generation: generation,
        userProject: userProject,
      );

  Future<void> deleteUser(
    String idOrEmail, {
    int? generation,
    String? userProject,
  }) =>
      _acl.delete(
        entity: 'user-$idOrEmail',
        generation: generation,
        userProject: userProject,
      );
}
