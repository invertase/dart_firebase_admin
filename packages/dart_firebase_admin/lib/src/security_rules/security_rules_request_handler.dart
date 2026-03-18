part of 'security_rules.dart';

class Release {
  Release._({
    required this.name,
    required this.rulesetName,
    required this.createTime,
    required this.updateTime,
  });

  /// Factory constructor for testing purposes.
  @visibleForTesting
  factory Release.forTest({
    required String name,
    required String rulesetName,
    String? createTime,
    String? updateTime,
  }) {
    return Release._(
      name: name,
      rulesetName: rulesetName,
      createTime: createTime,
      updateTime: updateTime,
    );
  }

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

  /// Factory constructor for testing purposes.
  @visibleForTesting
  factory RulesetResponse.forTest({
    required String name,
    required String createTime,
    required RulesetSource source,
  }) {
    return RulesetResponse._(
      name: name,
      createTime: createTime,
      source: source,
    );
  }

  final String name;
  final String createTime;
}

class ListRulesetsResponse {
  ListRulesetsResponse._({required this.rulesets, this.nextPageToken});

  /// Factory constructor for testing purposes.
  @visibleForTesting
  factory ListRulesetsResponse.forTest({
    required List<RulesetResponse> rulesets,
    String? nextPageToken,
  }) {
    return ListRulesetsResponse._(
      rulesets: rulesets,
      nextPageToken: nextPageToken,
    );
  }

  final List<RulesetResponse> rulesets;
  final String? nextPageToken;
}

/// Request handler for Firebase Security Rules API operations.
///
/// Handles complex business logic, request/response transformations,
/// and validation. Delegates simple API calls to [SecurityRulesHttpClient].
class SecurityRulesRequestHandler {
  SecurityRulesRequestHandler(FirebaseApp app)
    : _httpClient = SecurityRulesHttpClient(app);

  final SecurityRulesHttpClient _httpClient;

  String? projectIdPrefix;

  /// Builds the project path for Security Rules operations.
  ///
  /// Delegates to HTTP client.
  String buildProjectPath(String projectId) {
    return _httpClient.buildProjectPath(projectId);
  }

  /// Builds the ruleset resource path.
  ///
  /// Delegates to HTTP client.
  String buildRulesetPath(String projectId, String name) {
    return _httpClient.buildRulesetPath(projectId, name);
  }

  /// Builds the release resource path.
  ///
  /// Delegates to HTTP client.
  String buildReleasePath(String projectId, String name) {
    return _httpClient.buildReleasePath(projectId, name);
  }

  Future<RulesetResponse> getRuleset(String name) {
    return _httpClient.v1((api, projectId) async {
      final response = await api.projects.rulesets.get(
        buildRulesetPath(projectId, name),
      );

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

    return _httpClient.v1((api, projectId) async {
      final response = await api.projects.rulesets.create(
        toApiRuleset(),
        buildProjectPath(projectId),
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
    return _httpClient.v1((api, projectId) async {
      await api.projects.rulesets.delete(buildRulesetPath(projectId, name));
    });
  }

  Future<ListRulesetsResponse> listRulesets({
    int pageSize = 100,
    String? pageToken,
  }) {
    return _httpClient.v1((api, projectId) async {
      if (pageSize < 1 || pageSize > 100) {
        throw FirebaseSecurityRulesException(
          FirebaseSecurityRulesErrorCode.invalidArgument,
          'Page size must be between 1 and 100.',
        );
      }

      final response = await api.projects.rulesets.list(
        buildProjectPath(projectId),
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
    return _httpClient.v1((api, projectId) async {
      final response = await api.projects.releases.get(
        buildReleasePath(projectId, name),
      );

      return Release._(
        name: response.name!,
        rulesetName: response.rulesetName!,
        createTime: response.createTime,
        updateTime: response.updateTime,
      );
    });
  }

  Future<Release> updateRelease(String name, String rulesetName) {
    return _httpClient.v1((api, projectId) async {
      final response = await api.projects.releases.patch(
        firebase_rules_v1.UpdateReleaseRequest(
          release: firebase_rules_v1.Release(
            name: buildReleasePath(projectId, name),
            rulesetName: buildRulesetPath(projectId, rulesetName),
          ),
        ),
        buildReleasePath(projectId, name),
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
    return _httpClient.v1((api, projectId) async {
      final response = await api.projects.releases.create(
        firebase_rules_v1.Release(
          name: buildReleasePath(projectId, name),
          rulesetName: buildRulesetPath(projectId, rulesetName),
        ),
        buildProjectPath(projectId),
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
