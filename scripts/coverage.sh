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


# Fast fail the script on failures.
set -e

# To run production tests locally, set both of these:
# export GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json
# export RUN_PROD_TESTS=true
#
# RUN_PROD_TESTS is intentionally never set in CI to avoid quota-heavy tests running there.
# WIF tests (gated by hasWifEnv) still run in CI via the google-github-actions/auth step.

# Get the script's directory and the package directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGE_DIR="$SCRIPT_DIR/../packages/dart_firebase_admin"

# Change to package directory
cd "$PACKAGE_DIR"

# Build test functions for Cloud Tasks emulator
cd test/functions
npm install
npm run build
cd ../..

dart pub global activate coverage

# Use test_with_coverage which supports workspaces (dart test --coverage doesn't work with resolution: workspace)
firebase emulators:exec --project dart-firebase-admin --only auth,firestore,functions,tasks,storage "dart run coverage:test_with_coverage -- --concurrency=1"

# test_with_coverage already generates lcov.info, just move it
mv coverage/lcov.info coverage.lcov