# # Firebase Admin SDK Cloud Run Example

A simple Dart server demonstrating Firebase Admin SDK features deployed to Cloud Run.

## Prerequisites

- Google Cloud Project with billing enabled
- Firebase project linked to your GCP project
- gcloud CLI installed
- Docker installed (for local testing)

## Local Development

1. Set up Application Default Credentials:

  ```bash
  gcloud auth application-default login
  ```

2. Install dependencies:

   ```bash
   dart pub get
   ```

3. Run locally:
   ```bash
   dart run bin/server.dart
   ```

4. Test endpoints:

# Health check

curl http://localhost:8080/health

# Send message

curl -X POST http://localhost:8080/send-message \
-H "Content-Type: application/json" \
-d '{"token":"DEVICE_TOKEN","title":"Hello","body":"World"}'

# Subscribe to topic

curl -X POST http://localhost:8080/subscribe-topic \
-H "Content-Type: application/json" \
-d '{"tokens":["TOKEN1","TOKEN2"],"topic":"news"}'

**Deploy to Cloud Run**

1. Set your project ID:
   export PROJECT_ID="your-project-id"
   gcloud config set project $PROJECT_ID

2. Build and push container:
   gcloud builds submit --tag gcr.io/$PROJECT_ID/firebase-admin-server

3. Deploy to Cloud Run:
   gcloud run deploy firebase-admin-server \
   --image gcr.io/$PROJECT_ID/firebase-admin-server \
   --platform managed \
   --region us-central1 \
   --allow-unauthenticated

4. Get the service URL:
   gcloud run services describe firebase-admin-server \
   --platform managed \
   --region us-central1 \
   --format 'value(status.url)'

**API Endpoints**

**GET /health**

Health check endpoint.

**POST /send-message**

Send an FCM message to a device token.

**Body:**
{
"token": "DEVICE_TOKEN",
"title": "Notification Title",
"body": "Notification body"
}

**POST /subscribe-topic**

Subscribe device tokens to a topic.

**Body:**
{
"tokens": ["TOKEN1", "TOKEN2"],
"topic": "news"
}

**POST /verify-token**

Verify a Firebase ID token.

**Body:**
{
"idToken": "FIREBASE_ID_TOKEN"
}

**Notes**

- Cloud Run automatically injects Application Default Credentials
- The service will scale to zero when not in use
- Each request gets a fresh instance if needed
