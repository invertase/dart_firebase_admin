#!/bin/bash

# Set environment variables
export FIREBASE_AUTH_EMULATOR_HOST="127.0.0.1:9000"
export FIRESTORE_EMULATOR_HOST="127.0.0.1:8000"

# Run the Dart test file
dart test test/firebase_admin_app_test.dart

# Clean up environment variables
unset FIREBASE_AUTH_EMULATOR_HOST
unset FIRESTORE_EMULATOR_HOST