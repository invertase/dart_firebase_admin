// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

class ParsedResource {
  ParsedResource({this.projectId, this.locationId, required this.resourceId});

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
