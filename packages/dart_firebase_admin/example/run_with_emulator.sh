#!/bin/bash
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Set environment variables for emulator
export FIRESTORE_EMULATOR_HOST=localhost:8080
export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
export CLOUD_TASKS_EMULATOR_HOST=localhost:9499
export FIREBASE_STORAGE_EMULATOR_HOST=localhost:9199
export GOOGLE_CLOUD_PROJECT=dart-firebase-admin

# Run the example
firebase emulators:exec --only auth,firestore,functions,tasks,storage "dart run lib/main.dart"
