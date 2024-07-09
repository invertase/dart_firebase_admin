#!/bin/bash

# Fast fail the script on failures.
set -e

dart pub global activate coverage

firebase emulators:exec --project dart-firebase-admin --only firestore,auth "dart test --coverage=coverage" 

format_coverage --lcov --in=coverage --out=coverage.lcov --packages=.dart_tool/package_config.json --report-on=lib