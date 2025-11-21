#!/bin/bash

# Set environment variables for emulator
export FIRESTORE_EMULATOR_HOST=localhost:8080
export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
export GOOGLE_CLOUD_PROJECT=dart-firebase-admin

# Run the example
dart run lib/main.dart
