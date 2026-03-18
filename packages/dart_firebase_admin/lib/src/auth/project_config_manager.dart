// Copyright 2024 Google LLC
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

part of '../auth.dart';

/// Manages (gets and updates) the current project config.
class ProjectConfigManager {
  /// Initializes a ProjectConfigManager instance for a specified FirebaseApp.
  ///
  /// @internal
  ProjectConfigManager._(FirebaseApp app)
    : _authRequestHandler = AuthRequestHandler(app);

  final AuthRequestHandler _authRequestHandler;

  /// Get the project configuration.
  ///
  /// Returns a [Future] fulfilled with the project configuration.
  Future<ProjectConfig> getProjectConfig() async {
    final response = await _authRequestHandler.getProjectConfig();
    return ProjectConfig.fromServerResponse(response);
  }

  /// Updates an existing project configuration.
  ///
  /// [projectConfigOptions] - The properties to update on the project.
  ///
  /// Returns a [Future] fulfilled with the updated project config.
  Future<ProjectConfig> updateProjectConfig(
    UpdateProjectConfigRequest projectConfigOptions,
  ) async {
    final response = await _authRequestHandler.updateProjectConfig(
      projectConfigOptions,
    );
    return ProjectConfig.fromServerResponse(response);
  }
}
