part of '../googleapis_storage.dart';

class Bucket extends ServiceObject<BucketMetadata>
    with
        CreatableMixin<BucketMetadata, Bucket>,
        GettableMixin<BucketMetadata, Bucket>,
        SettableMixin<BucketMetadata>,
        DeletableMixin<BucketMetadata> {
  final BucketOptions _options;
  final Acl acl;
  final Acl aclDefault;
  final Crc32Generator crc32cGenerator;
  Iam? _iam;
  URLSigner? _signer;
  PreconditionOptions? get instancePreconditionOpts =>
      _options.preconditionOpts;

  /// A user project to apply to each request from this bucket.
  ///
  /// This can be set via constructor options or using [setUserProject()].
  /// When making requests, if a method doesn't provide a `userProject` in its
  /// options, this instance-level `userProject` will be used automatically.
  String? _userProject;

  final Storage storage;

  Uri get cloudStorageURI {
    return Uri(scheme: 'gs', host: name);
  }

  String? get userProject => _userProject;

  URLSigner get signer => _signer ??= URLSigner._(this, null);

  Iam get iam => _iam ??= Iam._(this);

  final String name;

  Bucket._(this.storage, String name, [BucketOptions? options])
    : // Allow for "gs://"-style input, and strip any trailing slashes.
      name = name
          .replaceAll(RegExp(r'^gs://'), '')
          .replaceAll(RegExp(r'/+$'), ''),
      _options = options ?? const BucketOptions(),
      _userProject = options?.userProject,
      acl = Acl._bucketAcl(storage, name),
      aclDefault = Acl._bucketDefaultObjectAcl(storage, name),
      crc32cGenerator = options?.crc32cGenerator ?? storage.crc32cGenerator,
      super(
        service: storage,
        id: name,
        metadata: BucketMetadata()..name = name,
      );

  @override
  Future<Bucket> create(BucketMetadata bucket) async {
    final created = await storage.createBucket(bucket);

    // Modify the current instance rather than creating a new one.
    setInstanceMetadata(created.metadata);
    id = created.id;
    return this;
  }

  @override
  Future<void> delete({DeleteOptions? options}) {
    final api = ApiExecutor(
      storage,
      preconditionOptions: options,
      shouldRetryMutation: shouldRetryBucketMutation,
    );
    return api.execute<void>((client) async {
      try {
        // Use provided userProject or fall back to instance-level userProject
        await client.buckets.delete(
          id,
          ifMetagenerationMatch: options?.ifMetagenerationMatch?.toString(),
          ifMetagenerationNotMatch: options?.ifMetagenerationNotMatch
              ?.toString(),
          userProject: options?.userProject ?? userProject,
        );
      } on ApiError catch (e) {
        if (e.code == 404 && options?.ignoreNotFound == true) {
          return;
        }
        rethrow;
      }
    });
  }

  @override
  Future<BucketMetadata> getMetadata({String? userProject}) async {
    // GET operations are idempotent, so retries are enabled by default
    // getMetadata() makes the API request directly and sets instance metadata
    final api = ApiExecutor(storage);
    final response = await api.execute<BucketMetadata>((client) async {
      // Use provided userProject or fall back to instance-level userProject
      return await client.buckets.get(
        id,
        userProject: userProject ?? this.userProject,
      );
    });
    setInstanceMetadata(response);
    return response;
  }

  /// Get the bucket, with optional auto-create functionality.
  ///
  /// This method provides extended functionality beyond the mixin's `get()` method,
  /// including `autoCreate` support. It internally calls [getMetadata()] which
  /// is provided by the mixin.
  ///
  /// To use extended options like `autoCreate`, use [getWithOptions()] instead.
  @override
  Future<Bucket> get({String? userProject}) async {
    // Use provided userProject or fall back to instance-level userProject
    await getMetadata(userProject: userProject ?? this.userProject);
    // Return this instance (matches TypeScript behavior)
    return this;
  }

  /// Get the bucket with extended options including auto-create functionality.
  ///
  /// This method provides the same functionality as [get()] but with additional
  /// options like `autoCreate`.
  Future<Bucket> getWithOptions({GetBucketOptions? options}) async {
    final getOptions = options ?? const GetBucketOptions();

    try {
      // Use provided userProject or fall back to instance-level userProject
      await getMetadata(userProject: getOptions.userProject ?? userProject);
      // Return this instance (matches TypeScript behavior)
      return this;
    } on ApiError catch (e) {
      // If 404 and autoCreate is enabled, try to create the bucket
      if (e.code == 404 && getOptions.autoCreate) {
        try {
          // Create a minimal bucket metadata with just the name
          final bucketMetadata = BucketMetadata()..name = name;
          final created = await create(bucketMetadata);
          return created;
        } on ApiError catch (createErr) {
          // If create fails with 409 (conflict), someone else created it, retry get
          if (createErr.code == 409) {
            return getWithOptions(options: getOptions);
          }
          rethrow;
        }
      }
      rethrow;
    }
  }

  @override
  Future<BucketMetadata> setMetadata(
    BucketMetadata metadata, {
    SetBucketMetadataOptions? options = const SetBucketMetadataOptions(),
  }) {
    final api = ApiExecutor(
      storage,
      preconditionOptions: options,
      shouldRetryMutation: shouldRetryBucketMutation,
    );

    return api.execute<BucketMetadata>((client) async {
      // Use provided userProject or fall back to instance-level userProject
      final updated = await client.buckets.patch(
        metadata,
        id,
        ifMetagenerationMatch: options?.ifMetagenerationMatch?.toString(),
        ifMetagenerationNotMatch: options?.ifMetagenerationNotMatch?.toString(),
        predefinedAcl: options?.predefinedAcl?.value,
        userProject: options?.userProject ?? userProject,
      );
      setInstanceMetadata(updated);
      return updated;
    });
  }

  Future<BucketMetadata> addLifecycleRule(
    List<LifecycleRule> rules, [
    AddLifecycleRuleOptions options = const AddLifecycleRuleOptions(),
  ]) async {
    // Convert AddLifecycleRuleOptions to SetBucketMetadataOptions to pass to setMetadata
    final setMetadataOptions = SetBucketMetadataOptions(
      ifMetagenerationMatch: options.ifMetagenerationMatch,
      ifMetagenerationNotMatch: options.ifMetagenerationNotMatch,
      ifGenerationMatch: options.ifGenerationMatch,
      ifGenerationNotMatch: options.ifGenerationNotMatch,
    );

    final bucketLifecycle = storage_v1.BucketLifecycle(rule: rules);
    if (options.append == false) {
      final update = BucketMetadata()..lifecycle = bucketLifecycle;
      return await setMetadata(update, options: setMetadataOptions);
    } else {
      final metadata = await getMetadata();
      final existingRules = metadata.lifecycle?.rule ?? [];
      existingRules.addAll(rules);
      metadata.lifecycle = storage_v1.BucketLifecycle(rule: existingRules);
      return await setMetadata(metadata, options: setMetadataOptions);
    }
  }

  Future<void> combine({
    required List<BucketFile> sources,
    required BucketFile destination,
    CombineOptions? options = const CombineOptions(),
  }) {
    // Validate inputs
    if (sources.isEmpty) {
      throw ArgumentError('At least one source file is required');
    }

    if (destination.id.isEmpty) {
      throw ArgumentError('Destination file name is required');
    }

    final combineOptions = options ?? const CombineOptions();
    final instancePreconditionOpts = destination.options.preconditionOpts;

    // Merge instance precondition options with combine options.
    // If ifGenerationMatch is not set in options, merge from destination's instance preconditions.
    // Also merge userProject: options takes precedence, then instance-level userProject.
    final mergedOptions = combineOptions.ifGenerationMatch == null
        ? CombineOptions(
            kmsKeyName: combineOptions.kmsKeyName,
            userProject: combineOptions.userProject ?? userProject,
            // Merge from instance preconditions first, then options take precedence
            ifGenerationMatch: instancePreconditionOpts?.ifGenerationMatch,
            ifGenerationNotMatch:
                combineOptions.ifGenerationNotMatch ??
                instancePreconditionOpts?.ifGenerationNotMatch,
            ifMetagenerationMatch:
                combineOptions.ifMetagenerationMatch ??
                instancePreconditionOpts?.ifMetagenerationMatch,
            ifMetagenerationNotMatch:
                combineOptions.ifMetagenerationNotMatch ??
                instancePreconditionOpts?.ifMetagenerationNotMatch,
          )
        : CombineOptions(
            kmsKeyName: combineOptions.kmsKeyName,
            userProject: combineOptions.userProject ?? userProject,
            ifGenerationMatch: combineOptions.ifGenerationMatch,
            ifGenerationNotMatch: combineOptions.ifGenerationNotMatch,
            ifMetagenerationMatch: combineOptions.ifMetagenerationMatch,
            ifMetagenerationNotMatch: combineOptions.ifMetagenerationNotMatch,
          );

    // Determine retry behavior based on preconditions and idempotency strategy.
    // The ApiExecutor will handle retry logic based on shouldRetryObjectMutation.
    final api = ApiExecutor(
      storage,
      preconditionOptions: mergedOptions,
      instancePreconditions: destination.options.preconditionOpts,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    return api.execute<void>((client) async {
      // Handle content type detection
      // If destination metadata doesn't have contentType, try to detect it from file name
      String? destinationContentType;
      String? destinationContentEncoding;

      // Check if destination has metadata with contentType
      destinationContentType = destination.metadata.contentType;
      destinationContentEncoding = destination.metadata.contentEncoding;

      // If no contentType in metadata, try to detect from file extension
      if (destinationContentType == null || destinationContentType.isEmpty) {
        destinationContentType = lookupMimeType(destination.id) ?? '';
      }

      // Build source objects list
      final sourceObjects = sources.map((source) {
        final sourceObj = storage_v1.ComposeRequestSourceObjects(
          name: source.id,
        );

        // Add generation if available in source metadata
        if (source.metadata.generation != null) {
          sourceObj.generation = source.metadata.generation;
        }

        return sourceObj;
      }).toList();

      // Build destination object metadata
      final destinationObj = storage_v1.Object();
      if (destinationContentType.isNotEmpty) {
        destinationObj.contentType = destinationContentType;
      }
      if (destinationContentEncoding != null) {
        destinationObj.contentEncoding = destinationContentEncoding;
      }

      // Build compose request
      final composeRequest = storage_v1.ComposeRequest(
        destination: destinationObj,
        sourceObjects: sourceObjects,
      );

      // Call the compose API
      await client.objects.compose(
        composeRequest,
        id, // destination bucket
        destination.id, // destination object
        ifGenerationMatch: mergedOptions.ifGenerationMatch?.toString(),
        ifMetagenerationMatch: mergedOptions.ifMetagenerationMatch?.toString(),
        kmsKeyName: mergedOptions.kmsKeyName,
        userProject: mergedOptions.userProject,
      );
    });
  }

  Future<Channel> createChannel(
    String id,
    CreateChannelConfig config, [
    CreateChannelOptions? options = const CreateChannelOptions(),
  ]) {
    final api = ApiExecutor(storage);

    if (id.isEmpty) {
      throw ArgumentError('An ID is required to create a channel.');
    }

    // Merge userProject: options takes precedence over config, then instance-level userProject
    final userProject =
        options?.userProject ?? config.userProject ?? this.userProject;

    return api.execute<Channel>((client) async {
      final metadata = ChannelMetadata()
        ..id = id
        ..type = 'web_hook'
        ..address = config.address;

      final response = await client.objects.watchAll(
        metadata,
        this.id,
        delimiter: config.delimiter,
        maxResults: config.maxResults,
        pageToken: config.pageToken,
        prefix: config.prefix,
        projection: config.projection,
        userProject: userProject,
        versions: config.versions,
      );

      final resourceId = response.resourceId;
      if (resourceId == null || resourceId.isEmpty) {
        throw ApiError(
          'Failed to create channel: missing resourceId in response',
        );
      }

      final channel = storage.channel(id, resourceId);
      channel.setInstanceMetadata(response);
      return channel;
    });
  }

  /// Create a notification configuration for this bucket.
  ///
  /// Creates a notification subscription for the bucket that publishes to the
  /// specified Cloud PubSub topic.
  ///
  /// See [Notifications: insert](https://cloud.google.com/storage/docs/json_api/v1/notifications/insert)
  ///
  /// [topic] The Cloud PubSub topic to which this subscription publishes.
  /// If the project ID is omitted, the current project ID will be used.
  ///
  /// Acceptable formats are:
  /// - `projects/grape-spaceship-123/topics/my-topic`
  /// - `my-topic`
  ///
  /// [options] Metadata to set for the notification.
  Future<Notification> createNotification(
    String topic, {
    CreateNotificationOptions? options,
  }) async {
    if (topic.isEmpty) {
      throw ArgumentError('A valid topic name is required.');
    }

    final createOptions = options ?? const CreateNotificationOptions();
    final api = ApiExecutor.withoutRetries(storage);

    return api.execute<Notification>((client) async {
      // Format the topic
      var formattedTopic = topic;
      if (!formattedTopic.startsWith('projects/')) {
        formattedTopic = 'projects/{{projectId}}/topics/$formattedTopic';
      }

      // Add universe domain prefix
      final universeDomain = storage.options.universeDomain ?? 'googleapis.com';
      formattedTopic = '//pubsub.$universeDomain/$formattedTopic';

      // Build notification metadata
      final metadata = storage_v1.Notification()
        ..topic = formattedTopic
        ..payloadFormat = createOptions.payloadFormat ?? 'JSON_API_V1'
        ..customAttributes = createOptions.customAttributes
        ..eventTypes = createOptions.eventTypes
        ..objectNamePrefix = createOptions.objectNamePrefix;

      // Make the API call
      // Use provided userProject or fall back to instance-level userProject
      final response = await client.notifications.insert(
        metadata,
        id,
        userProject: createOptions.userProject ?? userProject,
      );

      // Create and return the notification instance
      final notification = this.notification(response.id!);
      notification.setInstanceMetadata(response);
      return notification;
    });
  }

  /// Create a [BucketFile] handle within this bucket.
  BucketFile file(String name, [FileOptions? options]) {
    return BucketFile._(this, name, options);
  }

  /// Delete files in this bucket matching the given options.
  Future<void> deleteFiles([
    DeleteFileOptions? options = const DeleteFileOptions(),
  ]) async {
    const maxParallelLimit = 10;
    const maxQueueSize = 1000;
    final exceptions = <Error>[];

    // Convert DeleteFileOptions to PreconditionOptions for file.delete
    final preconditionOptions = options != null
        ? PreconditionOptions(
            ifGenerationMatch: options.ifGenerationMatch,
            ifGenerationNotMatch: options.ifGenerationNotMatch,
            ifMetagenerationMatch: options.ifMetagenerationMatch,
            ifMetagenerationNotMatch: options.ifMetagenerationNotMatch,
          )
        : null;

    Future<void> deleteFile(BucketFile file) async {
      try {
        await file.delete(options: preconditionOptions);
      } catch (e) {
        if (options?.force == true) {
          exceptions.add(e as Error);
        } else {
          rethrow;
        }
      }
    }

    // Limit parallel operations using ParallelLimit
    final limit = ParallelLimit(maxConcurrency: maxParallelLimit);

    Future<void> limitedDelete(BucketFile file) async {
      await limit.run(() => deleteFile(file));
    }

    final filesStream = getFilesStream(options);
    final completer = Completer<void>();
    StreamSubscription<BucketFile>? subscription;
    var hasError = false;

    final queue = BoundedQueue<void>(
      maxSize: maxQueueSize,
      subscription: null, // Will be set after subscription is created
      onError: (e) {
        if (!hasError) {
          hasError = true;
          subscription?.cancel();
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      },
    );

    subscription = filesStream.listen(
      (curFile) {
        if (hasError) return;

        // Check and wait for queue if needed (async, but we handle it via future)
        queue
            .waitIfNeeded()
            .then((_) {
              if (hasError) return;

              final future = limitedDelete(curFile);
              future.catchError((e) {
                if (options?.force != true) {
                  if (!hasError) {
                    hasError = true;
                    subscription?.cancel();
                    if (!completer.isCompleted) {
                      completer.completeError(e);
                    }
                  }
                }
              });
              queue.add(future);
            })
            .catchError((e) {
              // Error already handled in BoundedQueue.onError
            });
      },
      onError: (e) {
        if (!hasError) {
          hasError = true;
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      },
      onDone: () async {
        if (hasError) return;

        try {
          await queue.waitIfNeeded();
          await queue.waitForAll();
          if (exceptions.isNotEmpty) {
            if (!completer.isCompleted) {
              completer.completeError(exceptions.first);
            }
          } else if (!completer.isCompleted) {
            completer.complete();
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      },
      cancelOnError: false,
    );

    // Set the subscription reference in the queue after it's created
    queue.subscription = subscription;

    try {
      await completer.future;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete one or more labels from this bucket.
  ///
  /// If [labels] is null or empty, all labels are deleted.
  ///
  /// This is a convenience method that calls [setMetadata] with null values
  /// for the specified label keys. To delete all labels, it first calls
  /// [getLabels] to get the current labels, then deletes them all.
  ///
  /// See [setLabels] for setting labels.
  ///
  /// [labels] A list of label keys to delete. If null or empty, all labels are deleted.
  ///
  /// [options] Options including precondition options and userProject.
  ///
  /// Returns the updated bucket metadata.
  ///
  /// Example:
  /// ```dart
  /// // Delete all labels
  /// await bucket.deleteLabels();
  ///
  /// // Delete a single label
  /// await bucket.deleteLabels(labels: ['labelone']);
  ///
  /// // Delete multiple labels
  /// await bucket.deleteLabels(labels: ['labelone', 'labeltwo']);
  ///
  /// // Delete with options
  /// await bucket.deleteLabels(
  ///   labels: ['labelone'],
  ///   options: SetLabelsOptions(userProject: 'my-project'),
  /// );
  /// ```
  Future<BucketMetadata> deleteLabels({
    List<String>? labels,
    SetLabelsOptions? options,
  }) async {
    List<String> labelsToDelete = [];

    if (labels == null || labels.isEmpty) {
      labelsToDelete = await getLabels().then((labels) => labels.keys.toList());
    } else {
      labelsToDelete = labels;
    }

    final nullLabelMap = <String, dynamic>{};
    for (final labelKey in labelsToDelete) {
      nullLabelMap[labelKey] = null;
    }

    final update = BucketMetadata()
      ..labels = (nullLabelMap as dynamic) as Map<String, String>?;

    if (options?.ifMetagenerationMatch != null) {
      return setMetadata(update, options: options);
    } else {
      return setMetadata(
        update,
        options: SetLabelsOptions(userProject: options?.userProject),
      );
    }
  }

  Future<void> disableRequesterPays([PreconditionOptions? options]) async {
    final metadata = BucketMetadata()
      ..billing = storage_v1.BucketBilling(requesterPays: false);
    await setMetadata(
      metadata,
      options: SetBucketMetadataOptions(
        ifMetagenerationMatch: options?.ifMetagenerationMatch,
        ifMetagenerationNotMatch: options?.ifMetagenerationNotMatch,
        ifGenerationMatch: options?.ifGenerationMatch,
        ifGenerationNotMatch: options?.ifGenerationNotMatch,
      ),
    );
  }

  Future<BucketMetadata> enableLogging(EnableLoggingOptions options) async {
    final bucketId = options.bucket?.id ?? id;

    final policy = await iam.getPolicy();
    final binding = storage_v1.PolicyBindings(
      members: ['group:cloud-storage-analytics@google.com'],
      role: 'roles/storage.objectCreator',
    );

    policy.bindings = policy.bindings == null
        ? [binding]
        : [...policy.bindings!, binding];

    await iam.setPolicy(policy);

    final metadata = BucketMetadata()
      ..logging = storage_v1.BucketLogging(
        logBucket: bucketId,
        logObjectPrefix: options.prefix,
      );

    return setMetadata(
      metadata,
      options: SetBucketMetadataOptions(
        ifMetagenerationMatch: options.ifMetagenerationMatch,
        ifMetagenerationNotMatch: options.ifMetagenerationNotMatch,
      ),
    );
  }

  Future<void> enableRequesterPays([SetBucketMetadataOptions? options]) async {
    final metadata = BucketMetadata()
      ..billing = storage_v1.BucketBilling(requesterPays: true);
    await setMetadata(
      metadata,
      options: SetBucketMetadataOptions(
        ifMetagenerationMatch: options?.ifMetagenerationMatch,
        ifMetagenerationNotMatch: options?.ifMetagenerationNotMatch,
        ifGenerationMatch: options?.ifGenerationMatch,
        ifGenerationNotMatch: options?.ifGenerationNotMatch,
      ),
    );
  }

  /// List files in this bucket.
  ///
  /// When [autoPaginate] is true (default), automatically handles pagination
  /// and returns all files. When false, returns only the first page and a
  /// [nextQuery] for manual pagination.
  ///
  /// For streaming files as they arrive, use [getFilesStream] instead.
  ///
  /// Returns a record of `(files, nextQuery)` where:
  /// - `files`: List of File instances
  /// - `nextQuery`: Options for the next page (null if no more pages)
  Future<(List<BucketFile> files, GetFilesOptions? nextQuery)> getFiles([
    GetFilesOptions? options = const GetFilesOptions(),
  ]) async {
    final opts = options ?? const GetFilesOptions();
    final autoPaginate = opts.autoPaginate ?? true;

    if (autoPaginate) {
      // Collect all files from the stream
      final files = <BucketFile>[];
      await for (final file in getFilesStream(opts)) {
        files.add(file);
      }
      return (files, null);
    } else {
      // Single page request - no auto-pagination
      final api = ApiExecutor(storage);
      final response = await api.execute((client) async {
        return await client.objects.list(
          id,
          delimiter: opts.delimiter,
          endOffset: opts.endOffset,
          includeFoldersAsPrefixes: opts.includeFoldersAsPrefixes,
          includeTrailingDelimiter: opts.includeTrailingDelimiter,
          prefix: opts.prefix,
          matchGlob: opts.matchGlob,
          maxResults: opts.maxResults,
          pageToken: opts.pageToken,
          softDeleted: opts.softDeleted,
          startOffset: opts.startOffset,
          userProject: opts.userProject ?? userProject,
          versions: opts.versions,
        );
      });

      final itemsArray = response.items ?? [];
      final files = itemsArray.map((fileMetadata) {
        final fileOptions = FileOptions(
          generation: opts.versions == true && fileMetadata.generation != null
              ? int.tryParse(fileMetadata.generation ?? '')
              : null,
          kmsKeyName: fileMetadata.kmsKeyName,
          userProject: opts.userProject ?? userProject,
        );

        final fileInstance = file(fileMetadata.name!, fileOptions);
        fileInstance.setInstanceMetadata(fileMetadata);
        return fileInstance;
      }).toList();

      // Build nextQuery if there's a nextPageToken
      final nextQuery = response.nextPageToken != null
          ? opts.copyWith(pageToken: response.nextPageToken)
          : null;

      return (files, nextQuery);
    }
  }

  /// Stream files in this bucket.
  ///
  /// Automatically handles pagination and yields files as they arrive.
  /// Returns a stream of files in this bucket.
  Stream<BucketFile> getFilesStream([
    GetFilesOptions? options = const GetFilesOptions(),
  ]) {
    final opts = options ?? const GetFilesOptions();
    final api = ApiExecutor(storage);

    return Streaming<BucketFile, GetFilesOptions>(
      fetcher: (GetFilesOptions pageOptions) async {
        final response = await api.execute((client) async {
          // Use provided userProject or fall back to instance-level userProject
          return await client.objects.list(
            id,
            delimiter: pageOptions.delimiter,
            endOffset: pageOptions.endOffset,
            includeFoldersAsPrefixes: pageOptions.includeFoldersAsPrefixes,
            includeTrailingDelimiter: pageOptions.includeTrailingDelimiter,
            prefix: pageOptions.prefix,
            matchGlob: pageOptions.matchGlob,
            maxResults: pageOptions.maxResults,
            pageToken: pageOptions.pageToken,
            softDeleted: pageOptions.softDeleted,
            startOffset: pageOptions.startOffset,
            userProject: pageOptions.userProject ?? userProject,
            versions: pageOptions.versions,
          );
        });

        final itemsArray = (response.items ?? []);
        final files = itemsArray.map((fileMetadata) {
          // Build FileOptions based on the metadata and query options
          // Use provided userProject or fall back to instance-level userProject
          final fileOptions = FileOptions(
            generation:
                pageOptions.versions == true && fileMetadata.generation != null
                ? int.tryParse(fileMetadata.generation ?? '')
                : null,
            kmsKeyName: fileMetadata.kmsKeyName,
            userProject: pageOptions.userProject ?? userProject,
          );

          final fileInstance = file(fileMetadata.name ?? '', fileOptions);
          fileInstance.setInstanceMetadata(fileMetadata);
          return fileInstance;
        });

        return (files, response.nextPageToken);
      },
      initialOptions: opts,
      maxApiCalls: opts.maxApiCalls,
      updatePageToken: (options, pageToken) =>
          options.copyWith(pageToken: pageToken),
    );
  }

  /// Get the labels configured on this bucket.
  Future<Map<String, String>> getLabels() async {
    final metadata = await getMetadata();
    return metadata.labels ?? {};
  }

  /// Get all notification configurations for this bucket.
  Future<List<Notification>> getNotifications([
    GetNotificationsOptions? options = const GetNotificationsOptions(),
  ]) async {
    final api = ApiExecutor(storage);
    return api.execute<List<Notification>>((client) async {
      final response = await client.notifications.list(
        id,
        userProject: options?.userProject ?? userProject,
      );

      return response.items?.map((metadata) {
            final notification = this.notification(metadata.id!);
            notification.setInstanceMetadata(metadata);
            return notification;
          }).toList() ??
          [];
    });
  }

  /// Get a signed URL for this bucket (e.g. for listing objects).
  Future<String> getSignedUrl(GetBucketSignedUrlOptions options) {
    final method = _bucketActionToHttpMethod(options.action);
    final config = SignedUrlConfig(
      method: method,
      expires: options.expires,
      version: options.version,
      cname: options.cname,
      extensionHeaders: options.extensionHeaders,
      queryParams: options.queryParams,
      host: options.host,
      signingEndpoint: options.signingEndpoint,
    );

    return signer.getSignedUrl(config);
  }

  // /// Lock an existing retention policy on this bucket.
  Future<void> lock(num metageneration) {
    final api = ApiExecutor(
      storage,
      shouldRetryMutation: shouldRetryBucketMutation,
    );

    return api.execute<void>((client) async {
      // Use instance-level userProject if set
      await client.buckets.lockRetentionPolicy(
        id,
        metageneration.toString(),
        userProject: userProject,
      );
    });
  }

  /// Make the bucket private (optionally including all files).
  Future<List<BucketFile>> makePrivate([
    MakeBucketPrivateOptions? options = const MakeBucketPrivateOptions(),
  ]) async {
    // Merge options.metadata with acl: null
    // You aren't allowed to set both predefinedAcl & acl properties on a bucket
    // so acl must explicitly be nullified.
    final metadata = (options?.metadata ?? BucketMetadata())..acl = null;

    await setMetadata(
      metadata,
      options: SetBucketMetadataOptions(
        predefinedAcl: PredefinedAcl.projectPrivate,
        userProject: options?.userProject ?? userProject,
        ifMetagenerationMatch: options?.preconditionOpts?.ifMetagenerationMatch,
        ifMetagenerationNotMatch:
            options?.preconditionOpts?.ifMetagenerationNotMatch,
        ifGenerationMatch: options?.preconditionOpts?.ifGenerationMatch,
        ifGenerationNotMatch: options?.preconditionOpts?.ifGenerationNotMatch,
      ),
    );

    if (options?.includeFiles == true) {
      return await _makeAllFilesPublicPrivate(
        MakeAllFilesPublicPrivateOptions(
          private: true,
          force: options?.force,
          userProject: options?.userProject ?? userProject,
        ),
      );
    }

    return [];
  }

  /// Make the bucket public (optionally including all files).
  Future<List<BucketFile>> makePublic([
    MakeBucketPublicOptions? options = const MakeBucketPublicOptions(),
  ]) async {
    await acl.add(entity: 'allUsers', role: 'READER');
    await aclDefault.add(entity: 'allUsers', role: 'READER');

    if (options?.includeFiles == true) {
      return await _makeAllFilesPublicPrivate(
        MakeAllFilesPublicPrivateOptions(
          public: true,
          force: options?.force,
          userProject: userProject,
        ),
      );
    }

    return [];
  }

  /// Get a [Notification] handle for the given notification ID.
  Notification notification(String id) {
    if (id.isEmpty) {
      throw ArgumentError('A notification ID is required.');
    }
    return Notification._(this, id);
  }

  /// Remove the retention period from this bucket.
  Future<BucketMetadata> removeRetentionPeriod([
    SetBucketMetadataOptions? options = const SetBucketMetadataOptions(),
  ]) {
    // Pass options through to setMetadata, matching TypeScript behavior where
    // removeRetentionPeriod calls this.setMetadata({ retentionPolicy: null }, options)
    final update = BucketMetadata()..retentionPolicy = null;
    return setMetadata(update, options: options);
  }

  /// Restore a soft-deleted bucket (if applicable).
  Future<BucketMetadata> restore(RestoreOptions options) {
    final api = ApiExecutor(
      storage,
      shouldRetryMutation: shouldRetryBucketMutation,
    );

    return api.execute<BucketMetadata>((client) async {
      // Use provided userProject or fall back to instance-level userProject
      return await client.buckets.restore(
        id,
        options.generation.toString(),
        projection: options.projection?.name,
        userProject: options.userProject ?? userProject,
      );
    });
  }

  /// Set the retention period for this bucket.
  Future<BucketMetadata> setRetentionPeriod(
    Duration duration, [
    SetBucketMetadataOptions? options = const SetBucketMetadataOptions(),
  ]) {
    final update = BucketMetadata()
      ..retentionPolicy = storage_v1.BucketRetentionPolicy(
        retentionPeriod: duration.inSeconds.toString(),
      );
    return setMetadata(update, options: options);
  }

  /// Set the CORS configuration for this bucket.
  Future<BucketMetadata> setCorsConfiguration(
    List<CorsConfiguration> corsConfiguration, [
    SetBucketMetadataOptions? options = const SetBucketMetadataOptions(),
  ]) {
    final cors = BucketMetadata()..cors = corsConfiguration;
    return setMetadata(cors, options: options);
  }

  /// Set labels on this bucket.
  Future<BucketMetadata> setLabels(
    Map<String, String> labels, [
    SetLabelsOptions? options = const SetLabelsOptions(),
  ]) {
    final update = BucketMetadata()..labels = labels;
    return setMetadata(update, options: options);
  }

  /// Set the default storage class for this bucket.
  Future<BucketMetadata> setStorageClass(
    String storageClass, [
    SetStorageClassOptions? options = const SetStorageClassOptions(),
  ]) {
    // Convert storage class to snake_case
    final modified = storageClass
        .replaceAll('-', '_')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (Match match) => '${match[1]}_${match[2]}',
        )
        .toUpperCase();

    final update = BucketMetadata()..storageClass = modified;
    return setMetadata(update, options: options);
  }

  /// Set a user project to be billed for all requests made from this Bucket
  /// object and any files referenced from this Bucket object.
  ///
  /// This updates both the instance-level `userProject` property and the
  /// `options.userProject` field to maintain consistency.
  ///
  /// Example:
  /// ```dart
  /// final bucket = storage.bucket('albums');
  /// bucket.setUserProject('grape-spaceship-123');
  /// ```
  void setUserProject(String userProject) {
    _userProject = userProject;
  }

  /// Upload a file to the bucket. This is a convenience method that wraps
  /// File.createWriteStream().
  ///
  /// Resumable uploads are enabled by default.
  ///
  /// Example:
  /// ```dart
  /// final bucket = storage.bucket('my-bucket');
  /// final file = await bucket.upload('/local/path/image.png');
  /// ```
  Future<BucketFile> upload(io.File file, [UploadOptions? options]) async {
    final opts = options ?? const UploadOptions();

    if (!await file.exists()) {
      throw ArgumentError('File does not exist: ${file.absolute.path}');
    }

    // Determine destination File object
    late BucketFile destinationFile;
    switch (opts.destination) {
      case FileUploadDestination(:final file):
        destinationFile = file;
      case PathUploadDestination(:final path):
        destinationFile = this.file(
          path,
          FileOptions(
            encryptionKey: opts.encryptionKey,
            kmsKeyName: opts.kmsKeyName,
            preconditionOpts: opts.preconditionOpts,
          ),
        );
      case null:
        // Use basename of file path
        final destination = file.absolute.path
            .split(io.Platform.pathSeparator)
            .last;
        destinationFile = this.file(
          destination,
          FileOptions(
            encryptionKey: opts.encryptionKey,
            kmsKeyName: opts.kmsKeyName,
            preconditionOpts: opts.preconditionOpts,
          ),
        );
    }

    // Use ApiExecutor for retry logic
    // ApiExecutor will automatically disable retries based on preconditions and idempotency strategy
    final api = ApiExecutor(
      storage,
      preconditionOptions: opts.preconditionOpts,
      shouldRetryMutation: shouldRetryObjectMutation,
    );

    await api.execute<void>((client) async {
      await _uploadFile(file, destinationFile, opts);
    });

    return destinationFile;
  }

  Future<void> _uploadFile(
    io.File file,
    BucketFile destinationFile,
    UploadOptions options,
  ) async {
    final fileStream = file.openRead();

    // Convert UploadOptions to CreateWriteStreamOptions
    final writeStreamOptions = CreateWriteStreamOptions(
      contentType: options.metadata?.contentType,
      gzip: options.gzip,
      metadata: options.metadata,
      offset: options.offset,
      predefinedAcl: options.predefinedAcl,
      private: options.private,
      public: options.public,
      resumable: options.resumable,
      timeout: options.timeout,
      uri: options.uri,
      chunkSize: options.chunkSize,
      highWaterMark: options.highWaterMark,
      isPartialUpload: options.isPartialUpload,
      userProject: options.userProject,
      validation: options.validation,
      preconditionOpts: options.preconditionOpts,
      onUploadProgress: options.onUploadProgress,
    );

    final writable = destinationFile.createWriteStream(writeStreamOptions);

    // Pipe the file stream to the writable stream
    final subscription = fileStream.listen(
      (chunk) {
        writable.add(chunk);
      },
      onError: (error, stackTrace) {
        writable.addError(error, stackTrace);
      },
      onDone: () {
        // Close the writable stream when file stream is done
        writable.close();
      },
      cancelOnError: false,
    );

    // Wait for the upload to complete (writable.done waits for the actual upload)
    try {
      await writable.done;
    } catch (e) {
      rethrow;
    } finally {
      // Cancel the subscription if it's still active
      await subscription.cancel();
    }
  }

  Future<List<BucketFile>> _makeAllFilesPublicPrivate(
    MakeAllFilesPublicPrivateOptions options,
  ) async {
    const maxParallelLimit = 10;
    final errors = <Error>[];
    final updatedFiles = <BucketFile>[];

    Future<void> processFile(BucketFile file) async {
      try {
        if (options.public == true) {
          await file.makePublic();
        } else if (options.private == true) {
          await file.makePrivate();
        }
        updatedFiles.add(file);
      } catch (e) {
        if (options.force != true) {
          rethrow;
        }
        errors.add(e as Error);
      }
    }

    // Collect all files from the stream
    final files = <BucketFile>[];
    final getFilesOptions = GetFilesOptions(userProject: options.userProject);

    await for (final file in getFilesStream(getFilesOptions)) {
      files.add(file);
    }

    // Process files with parallel limit
    final limit = ParallelLimit(maxConcurrency: maxParallelLimit);
    final futures = files.map((file) => limit.run(() => processFile(file)));

    // Wait for all operations to complete
    // If force is false, Future.wait will throw on first error (fail-fast)
    // If force is true, errors are collected in processFile and Future.wait completes normally
    await Future.wait(futures);

    return updatedFiles;
  }
}

// extension on storage_v1.StorageApi {
//   storage_v1.Bucket bucketFromName(String name) =>
//       storage_v1.Bucket()..name = name;
// }

SignedUrlMethod _bucketActionToHttpMethod(String action) {
  switch (action) {
    case 'list':
      return SignedUrlMethod.get;
    default:
      throw ArgumentError('Invalid action: $action');
  }
}
