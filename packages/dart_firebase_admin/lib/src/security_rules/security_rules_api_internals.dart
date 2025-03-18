import 'package:googleapis/firebaserules/v1.dart' as firebase_rules_v1;
import 'package:meta/meta.dart';

import '../app.dart';
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
class SecurityRulesApiClient {
  SecurityRulesApiClient(this.app);

  final FirebaseAdminApp app;
  String? projectIdPrefix;

  Future<R> _v1<R>(
    Future<R> Function(firebase_rules_v1.FirebaseRulesApi client) fn,
  ) async {
    try {
      return await fn(firebase_rules_v1.FirebaseRulesApi(await app.client));
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
    return _v1((api) async {
      final response = await api.projects.rulesets
          .get('projects/${app.projectId}/rulesets/$name');

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

    return _v1((api) async {
      final response = await api.projects.rulesets.create(
        toApiRuleset(),
        'projects/${app.projectId}',
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
    return _v1((api) async {
      await api.projects.rulesets
          .delete('projects/${app.projectId}/rulesets/$name');
    });
  }

  Future<ListRulesetsResponse> listRulesets({
    int pageSize = 100,
    String? pageToken,
  }) {
    return _v1((api) async {
      if (pageSize < 1 || pageSize > 100) {
        throw FirebaseSecurityRulesException(
          FirebaseSecurityRulesErrorCode.invalidArgument,
          'Page size must be between 1 and 100.',
        );
      }

      final response = await api.projects.rulesets.list(
        'projects/${app.projectId}',
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
    return _v1((api) async {
      final response = await api.projects.releases
          .get('projects/${app.projectId}/releases/$name');

      return Release._(
        name: response.name!,
        rulesetName: response.rulesetName!,
        createTime: response.createTime,
        updateTime: response.updateTime,
      );
    });
  }

  Future<Release> updateRelease(String name, String rulesetName) {
    return _v1((api) async {
      final response = await api.projects.releases.patch(
        firebase_rules_v1.UpdateReleaseRequest(
          release: firebase_rules_v1.Release(
            name: 'projects/${app.projectId}/releases/$name',
            rulesetName: 'projects/${app.projectId}/rulesets/$rulesetName',
          ),
        ),
        'projects/${app.projectId}/releases/$name',
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
    return _v1((api) async {
      final response = await api.projects.releases.create(
        firebase_rules_v1.Release(
          name: 'projects/${app.projectId}/releases/$name',
          rulesetName: 'projects/${app.projectId}/rulesets/$rulesetName',
        ),
        'projects/${app.projectId}',
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
