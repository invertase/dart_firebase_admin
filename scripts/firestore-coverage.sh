#!/bin/bash

# Fast fail the script on failures.
set -e

# To run production tests locally, set both of these:
# export GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json
# export RUN_PROD_TESTS=true
#
# RUN_PROD_TESTS is intentionally never set in CI to avoid quota-heavy tests running there.

# Get the script's directory and the package directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGE_DIR="$SCRIPT_DIR/../packages/google_cloud_firestore"

# Change to package directory
cd "$PACKAGE_DIR"

dart pub global activate coverage

# Use test_with_coverage which supports workspaces (dart test --coverage doesn't work with resolution: workspace)
firebase emulators:exec --config ../firebase_admin_sdk/test/firebase.json --project dart-firebase-admin --only firestore "dart run coverage:test_with_coverage -- --concurrency=1"

# test_with_coverage already generates lcov.info, just move it
mv coverage/lcov.info coverage.lcov
