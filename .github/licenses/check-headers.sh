#!/bin/bash
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Checks license headers on all source files (dry run).
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

COMMON_IGNORES=(
  --ignore "**/*.yml"
  --ignore "**/*.yaml"
  --ignore "**/*.xml"
  --ignore "**/*.html"
  --ignore "**/*.js"
  --ignore "**/*.txt"
  --ignore "**/*.json"
  --ignore "**/*.md"
  --ignore "**/*.lock"
  --ignore "**/.dart_tool/**"
  --ignore "**/node_modules/**"
)

# Dart files
addlicense -l apache -c "Google LLC" --check \
  "${COMMON_IGNORES[@]}" \
  --ignore "**/*.g.dart" \
  --ignore "**/*.sh" \
  --ignore "**/*.ts" \
  .

# TypeScript and shell files
addlicense -f "$REPO_ROOT/.github/licenses/default.txt" -c "Google LLC" --check \
  "${COMMON_IGNORES[@]}" \
  --ignore "**/*.dart" \
  .
