#!/bin/bash

# Set environment variables for emulator
export FIRESTORE_EMULATOR_HOST=localhost:8080
export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
export CLOUD_TASKS_EMULATOR_HOST=localhost:9499
export FIREBASE_STORAGE_EMULATOR_HOST=localhost:9199
export GOOGLE_CLOUD_PROJECT=dart-firebase-admin

# Run the example
firebase emulators:exec --only auth,firestore,functions,tasks,storage "dart run lib/main.dart"
