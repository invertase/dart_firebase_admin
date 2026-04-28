#!/bin/bash

# Fast fail the script on failures.
set -e

# prod tests are opt-in: set GOOGLE_APPLICATION_CREDENTIALS to include them.
# export GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json

# Get the script's directory and the package directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGE_DIR="$SCRIPT_DIR/../packages/google_cloud_firestore"

# Change to package directory
cd "$PACKAGE_DIR"

dart pub global activate coverage

# Exclude prod tests unless a credential is available.
TEST_TAGS="--exclude-tags prod"
if [ -n "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]; then
  TEST_TAGS=""
fi

# Use test_with_coverage which supports workspaces (dart test --coverage doesn't work with resolution: workspace)
firebase emulators:exec --config ../firebase_admin_sdk/test/firebase.json --project dart-firebase-admin --only firestore "dart run coverage:test_with_coverage -- --concurrency=1 $TEST_TAGS"

# test_with_coverage already generates lcov.info, just move it
mv coverage/lcov.info coverage.lcov
