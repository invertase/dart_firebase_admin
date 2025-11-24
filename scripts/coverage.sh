#!/bin/bash

# Fast fail the script on failures.
set -e

dart pub global activate coverage

firebase emulators:exec --project dart-firebase-admin --only firestore,auth "cd packages/dart_firebase_admin && dart test --concurrency=1 --coverage=coverage" 

cd packages/dart_firebase_admin
format_coverage --lcov --in=coverage --out=coverage.lcov --package=. --report-on=lib