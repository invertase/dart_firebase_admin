class ParsedResource {
  ParsedResource({
    this.projectId,
    this.locationId,
    required this.resourceId,
  });

  /// Parses the top level resources of a given resource name.
  /// Supports both full and partial resources names, example:
  /// `locations/{location}/functions/{functionName}`,
  /// `projects/{project}/locations/{location}/functions/{functionName}`, or {functionName}
  /// Does not support deeply nested resource names.
  ///
  /// [resourceName] - The resource name string.
  /// [resourceIdKey] - The key of the resource name to be parsed.
  /// Returns a parsed resource name object.
  factory ParsedResource.parse(String resourceName, String resourceIdKey) {
    if (!resourceName.contains('/')) {
      return ParsedResource(resourceId: resourceName);
    }
    final channelNameRegex = RegExp(
      '^(projects/([^/]+)/)?locations/([^/]+)/$resourceIdKey/([^/]+)\$',
    );
    final match = channelNameRegex.firstMatch(resourceName);
    if (match == null) {
      throw const FormatException('Invalid resource name format.');
    }

    final projectId = match[2];
    final locationId = match[3];
    final resourceId = match[4];

    return ParsedResource(
      projectId: projectId,
      locationId: locationId,
      resourceId: resourceId!,
    );
  }

  String? projectId;
  String? locationId;
  String resourceId;
}
