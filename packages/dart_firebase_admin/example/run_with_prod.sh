#!/bin/bash

# Run example against Firebase production
#
# Authentication Options:
#
# Option 1: Service Account Key (used by this script)
#   1. Download your service account key from Firebase Console:
#      - Go to Project Settings > Service Accounts
#      - Click "Generate New Private Key"
#      - Save as serviceAccountKey.json in this directory
#   2. Set GOOGLE_APPLICATION_CREDENTIALS below (already configured)
#
# Option 2: Application Default Credentials (alternative)
#   1. Run: gcloud auth application-default login
#   2. Set GOOGLE_CLOUD_PROJECT or GCLOUD_PROJECT (uncomment below)
#   3. Comment out GOOGLE_APPLICATION_CREDENTIALS
#
# For available environment variables, see:
# ../lib/src/app/environment.dart

# Service account credentials file path
# See: Environment.googleApplicationCredentials
export GOOGLE_APPLICATION_CREDENTIALS=serviceAccountKey.json

# (Optional) Explicit project ID - uncomment if needed
# See: Environment.googleCloudProject
# export GOOGLE_CLOUD_PROJECT=your-project-id

# (Optional) Legacy gcloud project ID - uncomment if needed
# See: Environment.gcloudProject
# export GCLOUD_PROJECT=your-project-id

# Run the example
dart run lib/main.dart
