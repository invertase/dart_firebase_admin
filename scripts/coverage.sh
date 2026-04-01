#!/bin/bash

# Fast fail the script on failures.
set -e

# To run production tests locally, set both of these:
# export GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json
# export RUN_PROD_TESTS=true
#
# To also run the refresh token credential integration tests, set:
# export FIREBASE_REFRESH_TOKEN_CREDENTIALS=~/.config/gcloud/application_default_credentials.json
# (run `gcloud auth application-default login` first if the file doesn't exist)
#
# RUN_PROD_TESTS is intentionally never set in CI to avoid quota-heavy tests running there.
# WIF tests (gated by hasWifEnv) still run in CI via the google-github-actions/auth step.

# Get the script's directory and the package directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGE_DIR="$SCRIPT_DIR/../packages/dart_firebase_admin"

# Change to package directory
cd "$PACKAGE_DIR"

# Build test functions for Cloud Tasks emulator
cd test/fixtures/task_queue_functions
npm install
npm run build
cd ../../..

dart pub global activate coverage

# Use test_with_coverage which supports workspaces (dart test --coverage doesn't work with resolution: workspace)
firebase emulators:exec --project dart-firebase-admin --only auth,firestore,functions,tasks,storage "dart run coverage:test_with_coverage -- --concurrency=1"

# test_with_coverage already generates lcov.info, just move it
mv coverage/lcov.info coverage.lcov