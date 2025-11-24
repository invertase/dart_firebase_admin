#!/bin/bash

# Fast fail the script on failures.
set -e

# Get the script's directory and the package directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGE_DIR="$SCRIPT_DIR/../packages/dart_firebase_admin"

# Change to package directory
cd "$PACKAGE_DIR"

dart pub global activate coverage

# Use test_with_coverage which supports workspaces (dart test --coverage doesn't work with resolution: workspace)
firebase emulators:exec --project dart-firebase-admin --only firestore,auth "dart run coverage:test_with_coverage -- --concurrency=1"

# test_with_coverage already generates lcov.info, just move it
mv coverage/lcov.info coverage.lcov