import 'package:googleapis/firebaserules/v1.dart' as firebase_rules_v1;
import 'package:meta/meta.dart';

import '../utils/base_http_client.dart';
import 'security_rules.dart';
import 'security_rules_internals.dart';

class Release {
  Release._({
    required this.name,
    required this.rulesetName,
    required this.createTime,
    required this.updateTime,
  });

  final String name;
  final String rulesetName;
  final String? createTime;
  final String? updateTime;
}

class RulesetContent {
  RulesetContent({required this.source});

  final RulesetSource source;
}

class RulesetSource {
  RulesetSource({required this.files});

  factory RulesetSource._fromSource(firebase_rules_v1.Source source) {
    return RulesetSource(
      files: [
        for (final file in source.files ?? <firebase_rules_v1.File>[])
          RulesFile(name: file.name!, content: file.content!),
      ],
    );
  }

  final List<RulesFile> files;
}

class RulesetResponse extends RulesetContent {
  factory RulesetResponse._from(firebase_rules_v1.Ruleset response) {
    return RulesetResponse._(
      name: response.name!,
      createTime: response.createTime!,
      source: RulesetSource._fromSource(
        response.source ?? firebase_rules_v1.Source(),
      ),
    );
  }
  RulesetResponse._({
    required this.name,
    required this.createTime,
    required super.source,
  });

  final String name;
  final String createTime;
}

class ListRulesetsResponse {
  ListRulesetsResponse._({
    required this.rulesets,
    this.nextPageToken,
  });

  final List<RulesetResponse> rulesets;
  final String? nextPageToken;
}

@internal
class SecurityRulesApiClient extends BaseHttpClient {
  SecurityRulesApiClient(super.app);

  String? projectIdPrefix;

  /// Executes a SecurityRules v1 API operation with automatic projectId injection.
  Future<R> v1<R>(
    Future<R> Function(firebase_rules_v1.FirebaseRulesApi client, String projectId) fn,
  ) async {
    final projectId = await discoverProjectId();
    try {
      return await fn(firebase_rules_v1.FirebaseRulesApi(await app.client), projectId);
    } on FirebaseSecurityRulesException {
      rethrow;
    } on firebase_rules_v1.DetailedApiRequestError catch (e, stack) {
      switch (e.jsonResponse) {
        case {'error': {'status': final status}}:
          final code = _errorMapping[status];
          if (code == null) break;

          Error.throwWithStackTrace(
            FirebaseSecurityRulesException(code, e.message),
            stack,
          );
      }

      Error.throwWithStackTrace(
        FirebaseSecurityRulesException(
          FirebaseSecurityRulesErrorCode.unknownError,
          'Unexpected error: $e',
        ),
        stack,
      );
    } catch (e, stack) {
      Error.throwWithStackTrace(
        FirebaseSecurityRulesException(
          FirebaseSecurityRulesErrorCode.unknownError,
          'Unexpected error: $e',
        ),
        stack,
      );
    }
  }

  Future<RulesetResponse> getRuleset(String name) {
    return v1((api, projectId) async {
      final response = await api.projects.rulesets
          .get('projects/$projectId/rulesets/$name');

      return RulesetResponse._from(response);
    });
  }

  Future<RulesetResponse> createRuleset(RulesetContent ruleset) {
    firebase_rules_v1.Ruleset toApiRuleset() {
      return firebase_rules_v1.Ruleset(
        source: firebase_rules_v1.Source(
          files: ruleset.source.files
              .map(
                (file) => firebase_rules_v1.File(
                  name: file.name,
                  content: file.content,
                ),
              )
              .toList(),
        ),
      );
    }

    return v1((api, projectId) async {
      final response = await api.projects.rulesets.create(
        toApiRuleset(),
        'projects/$projectId',
      );

      return RulesetResponse._(
        name: response.name!,
        createTime: response.createTime!,
        source: RulesetSource._fromSource(response.source!),
      );
    });
  }

  Future<Release> updateOrCreateRelease(String name, String rulesetName) async {
    try {
      return await updateRelease(name, rulesetName);
    } on FirebaseSecurityRulesException catch (e) {
      if (e.code ==
          'security-rules/${FirebaseSecurityRulesErrorCode.notFound}') {
        return createRelease(name, rulesetName);
      }
      rethrow;
    }
  }

  Future<void> deleteRuleset(String name) {
    return v1((api, projectId) async {
      await api.projects.rulesets
          .delete('projects/$projectId/rulesets/$name');
    });
  }

  Future<ListRulesetsResponse> listRulesets({
    int pageSize = 100,
    String? pageToken,
  }) {
    return v1((api, projectId) async {
      if (pageSize < 1 || pageSize > 100) {
        throw FirebaseSecurityRulesException(
          FirebaseSecurityRulesErrorCode.invalidArgument,
          'Page size must be between 1 and 100.',
        );
      }

      final response = await api.projects.rulesets.list(
        'projects/$projectId',
        pageSize: pageSize,
        pageToken: pageToken,
      );

      return ListRulesetsResponse._(
        rulesets: response.rulesets!.map(RulesetResponse._from).toList(),
        nextPageToken: response.nextPageToken,
      );
    });
  }

  Future<Release> getRelease(String name) {
    return v1((api, projectId) async {
      final response = await api.projects.releases
          .get('projects/$projectId/releases/$name');

      return Release._(
        name: response.name!,
        rulesetName: response.rulesetName!,
        createTime: response.createTime,
        updateTime: response.updateTime,
      );
    });
  }

  Future<Release> updateRelease(String name, String rulesetName) {
    return v1((api, projectId) async {
      final response = await api.projects.releases.patch(
        firebase_rules_v1.UpdateReleaseRequest(
          release: firebase_rules_v1.Release(
            name: 'projects/$projectId/releases/$name',
            rulesetName: 'projects/$projectId/rulesets/$rulesetName',
          ),
        ),
        'projects/$projectId/releases/$name',
      );

      return Release._(
        name: response.name!,
        rulesetName: response.rulesetName!,
        createTime: response.createTime,
        updateTime: response.updateTime,
      );
    });
  }

  Future<Release> createRelease(String name, String rulesetName) {
    return v1((api, projectId) async {
      final response = await api.projects.releases.create(
        firebase_rules_v1.Release(
          name: 'projects/$projectId/releases/$name',
          rulesetName: 'projects/$projectId/rulesets/$rulesetName',
        ),
        'projects/$projectId',
      );

      return Release._(
        name: response.name!,
        rulesetName: response.rulesetName!,
        createTime: response.createTime,
        updateTime: response.updateTime,
      );
    });
  }
}

const _errorMapping = <String, FirebaseSecurityRulesErrorCode>{
  'INVALID_ARGUMENT': FirebaseSecurityRulesErrorCode.invalidArgument,
  'NOT_FOUND': FirebaseSecurityRulesErrorCode.notFound,
  'RESOURCE_EXHAUSTED': FirebaseSecurityRulesErrorCode.resourceExhausted,
  'UNAUTHENTICATED': FirebaseSecurityRulesErrorCode.authenticationError,
  'UNKNOWN': FirebaseSecurityRulesErrorCode.unknownError,
};
