import 'dart:async';

import 'package:googleapis/firebaserules/v1.dart' as firebase_rules_v1;
import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:meta/meta.dart';

import '../app.dart';

part 'security_rules_exception.dart';
part 'security_rules_http_client.dart';
part 'security_rules_request_handler.dart';

/// A source file containing some Firebase security rules. The content includes raw
/// source code including text formatting, indentation and comments.
class RulesFile {
  RulesFile({required this.name, required this.content});

  final String name;
  final String content;
}

/// Required metadata associated with a ruleset.
class RulesetMetadata {
  RulesetMetadata._from(RulesetResponse rs)
    : name = _stripProjectIdPrefix(rs.name),
      createTime = DateTime.parse(rs.createTime).toIso8601String();

  /// Name of the [Ruleset] as a short string. This can be directly passed into APIs
  /// like [SecurityRules.getRuleset] and [SecurityRules.deleteRuleset].
  final String name;

  /// Creation time of the [Ruleset] as a UTC timestamp string.
  final String createTime;
}

/// A page of ruleset metadata.
class RulesetMetadataList {
  RulesetMetadataList._fromResponse(ListRulesetsResponse response)
    : rulesets = response.rulesets.map(RulesetMetadata._from).toList(),
      nextPageToken = response.nextPageToken;

  /// A batch of ruleset metadata.
  final List<RulesetMetadata> rulesets;

  /// The next page token if available. This is needed to retrieve the next batch.
  final String? nextPageToken;
}

/// A set of Firebase security rules.
class Ruleset extends RulesetMetadata {
  Ruleset._fromResponse(super.rs) : source = rs.source.files, super._from();

  final List<RulesFile> source;
}

/// The Firebase `SecurityRules` service interface.
class SecurityRules implements FirebaseService {
  /// Creates or returns the cached SecurityRules instance for the given app.
  @internal
  factory SecurityRules.internal(
    FirebaseApp app, {
    SecurityRulesRequestHandler? requestHandler,
  }) {
    return app.getOrInitService(
      FirebaseServiceType.securityRules.name,
      (app) => SecurityRules._(app, requestHandler: requestHandler),
    );
  }

  SecurityRules._(this.app, {SecurityRulesRequestHandler? requestHandler})
    : _requestHandler = requestHandler ?? SecurityRulesRequestHandler(app);

  static const _cloudFirestore = 'cloud.firestore';
  static const _firebaseStorage = 'firebase.storage';

  @override
  final FirebaseApp app;
  final SecurityRulesRequestHandler _requestHandler;

  /// Gets the [Ruleset] identified by the given
  /// name. The input name should be the short name string without the project ID
  /// prefix. For example, to retrieve the `projects/project-id/rulesets/my-ruleset`,
  /// pass the short name "my-ruleset". Rejects with a `not-found` error if the
  /// specified [Ruleset] cannot be found.
  ///
  /// [name] - Name of the [Ruleset] to retrieve.
  /// Returns a future that fulfills with the specified [Ruleset].
  Future<Ruleset> getRuleset(String name) async {
    final rulesetResponse = await _requestHandler.getRuleset(name);

    return Ruleset._fromResponse(rulesetResponse);
  }

  /// Gets the [Ruleset] currently applied to
  /// Cloud Firestore. Rejects with a `not-found` error if no ruleset is applied
  /// on Firestore.
  ///
  /// Returns a future that fulfills with the Firestore ruleset.
  Future<Ruleset> getFirestoreRuleset() {
    return _getRulesetForRelease(_cloudFirestore);
  }

  /// Creates a new [Ruleset] from the given
  /// source, and applies it to Cloud Firestore.
  ///
  /// [source] - Rules source to apply.
  /// Returns a future that fulfills when the ruleset is created and released.
  Future<Ruleset> releaseFirestoreRulesetFromSource(String source) async {
    final rulesFile = RulesFile(name: 'firestore.rules', content: source);
    final ruleset = await createRuleset(rulesFile);

    await releaseFirestoreRuleset(ruleset.name);

    return ruleset;
  }

  /// Applies the specified [Ruleset] ruleset
  /// to Cloud Firestore.
  ///
  /// [ruleset] - Name of the ruleset to apply.
  /// Returns a future that fulfills when the ruleset is released.
  Future<void> releaseFirestoreRuleset(String ruleset) async {
    await _requestHandler.updateOrCreateRelease(_cloudFirestore, ruleset);
  }

  /// Gets the [Ruleset] currently applied to a
  /// Cloud Storage bucket. Rejects with a `not-found` error if no ruleset is applied
  /// on the bucket.
  ///
  /// [bucket] - Optional name of the Cloud Storage bucket to be retrieved. If not
  ///   specified, retrieves the ruleset applied on the default bucket configured via
  ///   [AppOptions.storageBucket].
  /// Returns a future that fulfills with the Cloud Storage ruleset.
  Future<Ruleset> getStorageRuleset([String? bucket]) async {
    final bucketName = _getBucketName(bucket);
    return _getRulesetForRelease('$_firebaseStorage/$bucketName');
  }

  /// Creates a new [Ruleset] from the given
  /// source, and applies it to a Cloud Storage bucket.
  ///
  /// [source] - Rules source to apply.
  /// [bucket] - Optional name of the Cloud Storage bucket to apply the rules on. If
  ///   not specified, applies the ruleset on the default bucket configured via
  ///   [AppOptions.storageBucket].
  /// Returns a future that fulfills when the ruleset is created and released.
  Future<Ruleset> releaseStorageRulesetFromSource(
    String source, [
    String? bucket,
  ]) async {
    // Bucket name is not required until the last step. But since there's a createRuleset step
    // before then, make sure to run this check and fail early if the bucket name is invalid.
    _getBucketName(bucket);

    final rulesFile = RulesFile(name: 'storage.rules', content: source);
    final ruleset = await createRuleset(rulesFile);
    await releaseStorageRuleset(ruleset.name, bucket);

    return ruleset;
  }

  /// Applies the specified [Ruleset] ruleset
  /// to a Cloud Storage bucket.
  ///
  /// [ruleset] - Name of the ruleset to apply.
  /// [bucket] - Optional name of the Cloud Storage bucket to apply the rules on. If
  ///   not specified, applies the ruleset on the default bucket configured via
  ///   [AppOptions.storageBucket].
  /// Returns a future that fulfills when the ruleset is released.
  Future<void> releaseStorageRuleset(String ruleset, [String? bucket]) async {
    final bucketName = _getBucketName(bucket);
    await _requestHandler.updateOrCreateRelease(
      '$_firebaseStorage/$bucketName',
      ruleset,
    );
  }

  /// Creates a new [Ruleset] from the given [RulesFile].
  ///
  /// [file] - Rules file to include in the new [Ruleset].
  /// Returns a future that fulfills with the newly created [Ruleset].
  Future<Ruleset> createRuleset(RulesFile file) async {
    final ruleset = RulesetContent(source: RulesetSource(files: [file]));

    final rulesetResponse = await _requestHandler.createRuleset(ruleset);
    return Ruleset._fromResponse(rulesetResponse);
  }

  /// Deletes the [Ruleset] identified by the given
  /// name. The input name should be the short name string without the project ID
  /// prefix. For example, to delete the `projects/project-id/rulesets/my-ruleset`,
  /// pass the  short name "my-ruleset". Rejects with a `not-found` error if the
  /// specified [Ruleset] cannot be found.
  ///
  /// [name] - Name of the [Ruleset] to delete.
  /// Returns a future that fulfills when the [Ruleset] is deleted.
  Future<void> deleteRuleset(String name) {
    return _requestHandler.deleteRuleset(name);
  }

  /// Retrieves a page of ruleset metadata.
  ///
  /// [pageSize] - The page size, 100 if undefined. This is also the maximum allowed
  ///   limit.
  /// [nextPageToken] - The next page token. If not specified, returns rulesets
  ///   starting without any offset.
  /// Returns a future that fulfills with a page of rulesets.
  Future<RulesetMetadataList> listRulesetMetadata({
    int pageSize = 100,
    String? nextPageToken,
  }) async {
    final response = await _requestHandler.listRulesets(
      pageSize: pageSize,
      pageToken: nextPageToken,
    );
    return RulesetMetadataList._fromResponse(response);
  }

  Future<Ruleset> _getRulesetForRelease(String releaseName) async {
    final release = await _requestHandler.getRelease(releaseName);
    final rulesetName = release.rulesetName;

    return getRuleset(_stripProjectIdPrefix(rulesetName));
  }

  String _getBucketName(String? bucket) {
    final bucketName = bucket ?? app.options.storageBucket;
    if (bucketName == null || bucketName.isEmpty) {
      throw FirebaseSecurityRulesException(
        FirebaseSecurityRulesErrorCode.invalidArgument,
        'Bucket name not specified or invalid. Specify a default bucket name via the '
        'storageBucket option when initializing the app, or specify the bucket name '
        'explicitly when calling the rules API.',
      );
    }
    return bucketName;
  }

  @override
  Future<void> delete() async {
    // SecurityRules service cleanup if needed
  }
}

String _stripProjectIdPrefix(String name) => name.split('/').last;
