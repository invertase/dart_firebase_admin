#!/bin/bash

# Fast fail the script on failures.
set -e

# Uncomment these to run prod tests locally, CI doesn't have service-account-key.json
# (service account credentials) only application default credentials and uses gcloud auth login.
# export FIRESTORE_EMULATOR_HOST=localhost:8080
# export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
# export GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json

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
firebase emulators:exec --project dart-firebase-admin --only firestore,auth,functions,tasks "dart run coverage:test_with_coverage -- --concurrency=1"

# test_with_coverage already generates lcov.info, just move it
mv coverage/lcov.info coverage.lcov