# Firebase Admin Dart SDK

## Table of Contents

 - [Prerequisites](#prerequisites)
 - [Overview](#overview)
 - [Installation](#installation)
 - [Add the Firebase Admin SDK to your server](#add-the-firebase-admin-sdk-to-your-server)
   - [Initialize the SDK](#initialize-the-sdk)
   - [Initialize the SDK in non-Google environments](#initialize-the-sdk-in-non-google-environments)
   - [Using Workload Identity Federation](#using-workload-identity-federation)
   - [Initialize multiple apps](#initialize-multiple-apps)
   - [Testing with gcloud end user credentials](#testing-with-gcloud-end-user-credentials)
 - [Usage](#usage)
   - [Authentication](#authentication)
   - [App Check](#app-check)
   - [Firestore](#firestore)
   - [Functions](#functions)
   - [Messaging](#messaging)
   - [Storage](#storage)
   - [Security Rules](#security-rules)
 - [Supported Services](#supported-services)
 - [Additional Packages](#additional-packages)
 - [Contributing](#contributing)
 - [License](#license)

## Prerequisites

Make sure that your server runs **Dart SDK 3.9 or higher**.

## Overview

[Firebase](https://firebase.google.com) provides the tools and infrastructure
you need to develop your app, grow your user base, and earn money. The Firebase
Admin Dart SDK enables access to Firebase services from privileged environments
(such as servers or cloud) in Dart.

For more information, visit the
[Firebase Admin SDK setup guide](https://firebase.google.com/docs/admin/setup/).

## Installation

The Firebase Admin Dart SDK is available on [pub.dev](https://pub.dev/) as `dart_firebase_admin`:

```bash
$ dart pub add dart_firebase_admin
```

To use the SDK in your application, `import` it from any Dart file:

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
```

## Add the Firebase Admin SDK to your server

### Initialize the SDK

To initalize the Firebase Admin SDK, call the `initializeApp` method on the `Firebase`
class:

```dart
final app = FirebaseApp.initializeApp();
```

This will automatically initialize the SDK with [Google Application Default Credentials](https://cloud.google.com/docs/authentication/production#providing_credentials_to_your_application). Because default credentials lookup is fully automated in Google environments, with no need to supply environment variables or other configuration, this way of initializing the SDK is strongly recommended for applications running in Google environments such as Firebase App Hosting, Cloud Run, App Engine, and Cloud Functions for Firebase.

To optionally specify initialization options, use the `FIREBASE_CONFIG` environment variable. If the content begins with `{` it will be parsed as a JSON object, otherwise it is treated as a path to a JSON file containing the options:

```bash
export FIREBASE_CONFIG='{"projectId":"my-project"}'
```

```dart
// Options are read automatically from FIREBASE_CONFIG
final app = FirebaseApp.initializeApp();
```

### Initialize the SDK in non-Google environments

If you are working in a non-Google server environment in which default credentials lookup can't be fully automated, you can initialize the SDK with an exported service account key file.

The `initializeApp` method allows for creating multiple named app instances and specifying a custom credential, project ID and other options:

```dart
final app = FirebaseApp.initializeApp(
  options: AppOptions(
    credential: Credential.fromServiceAccount(File("path/to/credential.json")),
    projectId: "custom-project-id",
  ),
  name: "CUSTOM_APP",
);
```

The following `Credential` constructors are available:

- `Credential.fromApplicationDefaultCredentials({String? serviceAccountId})` — Uses [Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials) (recommended for Google environments). Optionally accepts a `serviceAccountId` to override the service account email.
- `Credential.fromServiceAccount(File)` — Loads credentials from a service account JSON file downloaded from the Firebase Console.
- `Credential.fromServiceAccountParams({required String privateKey, required String email, required String projectId, String? clientId})` — Builds credentials from individual service account fields directly.

#### Using Workload Identity Federation

[Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) lets external workloads (such as GitHub Actions, AWS, or Azure) authenticate as a Google service account without a long-lived key file.

Once your WIF credential configuration file is generated, point `GOOGLE_APPLICATION_CREDENTIALS` to it:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/wif-credential-config.json"
```

Then initialize the SDK with ADC, providing the impersonated service account email via `serviceAccountId`. This is required because WIF credential configs do not embed a `client_email` field, unlike service account key files:

```dart
final app = FirebaseApp.initializeApp(
  options: AppOptions(
    credential: Credential.fromApplicationDefaultCredentials(
      serviceAccountId: 'my-service-account@my-project.iam.gserviceaccount.com',
    ),
    projectId: 'my-project',
  ),
);
```

### Initialize multiple apps

In most cases, you only have to initialize a single default app:

```dart
// Initialize the default app
final defaultApp = FirebaseApp.initializeApp();

print(defaultApp.name); // '[DEFAULT]'

// Access services from the default app
final defaultAuth = defaultApp.auth();
final defaultFirestore = defaultApp.firestore();
```

Some use cases require multiple app instances at the same time — for example, reading data from one Firebase project and creating custom tokens for another, or authenticating two apps with separate credentials:

```dart
// Each AppOptions points to a different Firebase project
final defaultApp = FirebaseApp.initializeApp(
  options: AppOptions(
    credential: Credential.fromServiceAccount(File('path/to/default-service-account.json')),
    projectId: 'my-default-project',
  ),
);

// Initialize another app with a different config
final otherApp = FirebaseApp.initializeApp(
  options: AppOptions(
    credential: Credential.fromServiceAccount(File('path/to/other-service-account.json')),
    projectId: 'my-other-project',
  ),
  name: 'other',
);

print(defaultApp.name); // '[DEFAULT]'
print(otherApp.name);   // 'other'

// Access services from each app
final defaultAuth = defaultApp.auth();
final defaultFirestore = defaultApp.firestore();

final otherAuth = otherApp.auth();
final otherFirestore = otherApp.firestore();
```

### Testing with gcloud end user credentials

When testing locally with Google Application Default Credentials obtained via `gcloud auth application-default login`, you must explicitly provide a project ID because Firebase Authentication does not accept gcloud end-user credentials without one:

```dart
final app = FirebaseApp.initializeApp(
  options: AppOptions(
    credential: Credential.fromApplicationDefaultCredentials(),
    projectId: '<FIREBASE_PROJECT_ID>',
  ),
);
```

Alternatively, set the `GOOGLE_CLOUD_PROJECT` environment variable to avoid changing your code:

```bash
export GOOGLE_CLOUD_PROJECT="<FIREBASE_PROJECT_ID>"
```

## Usage

Once you have initialized an app instance with a credential, you can use any of the [supported services](#supported-services) to interact with Firebase.

### Authentication

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/auth.dart';

final app = FirebaseApp.initializeApp();
final auth = app.auth();
```

#### getUser / getUserByEmail

```dart
// Get user by UID
final userById = await auth.getUser('<user-id>');
print(userById.displayName);

// Get user by email
final userByEmail = await auth.getUserByEmail('user@example.com');
print(userByEmail.displayName);
```

#### createUser

```dart
final user = await auth.createUser(
  CreateRequest(
    email: 'user@example.com',
    password: 'password123',
    displayName: 'John Doe',
  ),
);
print(user.uid);
```

#### updateUser

```dart
final updatedUser = await auth.updateUser(
  '<user-id>',
  UpdateRequest(
    displayName: 'Jane Doe',
    disabled: false,
  ),
);
print(updatedUser.displayName);
```

#### deleteUser / listUsers

```dart
// Delete a user
await auth.deleteUser('<user-id>');

// List users (max 1000 per page)
final result = await auth.listUsers(maxResults: 100);
final users = result.users;
final nextPageToken = result.pageToken;
```

#### verifyIdToken

```dart
// Verify an ID token from a client application (e.g. from request headers)
final idToken = req.headers['Authorization'].split(' ')[1];
final decodedToken = await auth.verifyIdToken(idToken, checkRevoked: true);
print(decodedToken.uid);
```

#### createCustomToken

```dart
final customToken = await auth.createCustomToken(
  '<user-id>',
  developerClaims: {'role': 'admin'},
);
```

#### setCustomUserClaims

```dart
await auth.setCustomUserClaims('<user-id>', customUserClaims: {'role': 'admin'});
```

### App Check

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

final app = FirebaseApp.initializeApp();
```

#### verifyToken

```dart
final response = await app.appCheck().verifyToken('<app-check-token>');
print('App ID: ${response.appId}');
```

#### createToken

```dart
final result = await app.appCheck().createToken('<app-id>');
print('Token: ${result.token}');
```

### Firestore

```dart
import 'dart:async';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';

final app = FirebaseApp.initializeApp();
final firestore = app.firestore();
```

#### set / update / delete

```dart
final ref = firestore.collection('users').doc('<user-id>');

// Set a document (creates or overwrites)
await ref.set({'name': 'John Doe', 'age': 27});

// Update specific fields
await ref.update({'age': 28});

// Delete a document
await ref.delete();
```

#### get / query

```dart
// Get a single document
final snapshot = await firestore.collection('users').doc('<user-id>').get();
print(snapshot.data());

// Query a collection
final querySnapshot = await firestore
    .collection('users')
    .where('age', WhereFilter.greaterThan, 18)
    .orderBy('age', descending: true)
    .get();
print(querySnapshot.docs);
```

#### getAll

```dart
// Fetch multiple documents at once
final snapshots = await firestore.getAll([
  firestore.collection('users').doc('user-1'),
  firestore.collection('users').doc('user-2'),
]);
for (final snap in snapshots) {
  print(snap.data());
}
```

#### batch

```dart
final batch = firestore.batch();
batch.set(firestore.collection('users').doc('user-1'), {'name': 'Alice'});
batch.update(firestore.collection('users').doc('user-2'), {FieldPath(const ['age']): 30});
batch.delete(firestore.collection('users').doc('user-3'));
await batch.commit();
```

#### bulkWriter

```dart
final bulkWriter = firestore.bulkWriter();
for (var i = 0; i < 10; i++) {
  unawaited(
    bulkWriter.set(
      firestore.collection('items').doc('item-$i'),
      {'index': i},
    ),
  );
}
await bulkWriter.close();
```

#### runTransaction

```dart
final balance = await firestore.runTransaction((tsx) async {
  final ref = firestore.collection('users').doc('<user-id>');
  final snapshot = await tsx.get(ref);
  final currentBalance = snapshot.exists ? snapshot.data()?['balance'] ?? 0 : 0;
  final newBalance = currentBalance + 10;
  tsx.update(ref, {'balance': newBalance});
  return newBalance;
});
```

### Functions

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/functions.dart';

final app = FirebaseApp.initializeApp();
final queue = app.functions().taskQueue('<task-name>');
```

#### enqueue

```dart
await queue.enqueue({'userId': 'user-123', 'action': 'sendWelcomeEmail'});
```

#### enqueue with TaskOptions

```dart
// Delay delivery by 1 hour
await queue.enqueue(
  {'action': 'cleanupTempFiles'},
  TaskOptions(schedule: DelayDelivery(3600)),
);

// Schedule at a specific time
await queue.enqueue(
  {'action': 'sendReport'},
  TaskOptions(schedule: AbsoluteDelivery(DateTime.now().add(Duration(hours: 1)))),
);

// Use a custom ID for deduplication
await queue.enqueue(
  {'orderId': 'order-456', 'action': 'processPayment'},
  TaskOptions(id: 'payment-order-456'),
);
```

#### delete

```dart
await queue.delete('payment-order-456');
```

### Messaging

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/messaging.dart';

final app = FirebaseApp.initializeApp();
final messaging = app.messaging();
```

#### send

```dart
// Send to a specific device
await messaging.send(
  TokenMessage(
    token: '<device-token>',
    notification: Notification(title: 'Hello', body: 'World!'),
    data: {'key': 'value'},
  ),
);

// Send to a topic
await messaging.send(
  TopicMessage(
    topic: '<topic-name>',
    notification: Notification(title: 'Hello', body: 'World!'),
  ),
);

// Send to a condition
await messaging.send(
  ConditionMessage(
    condition: "'stock-GOOG' in topics || 'industry-tech' in topics",
    notification: Notification(title: 'Hello', body: 'World!'),
  ),
);
```

#### sendEach

```dart
// Send up to 500 messages in a single call
final response = await messaging.sendEach([
  TopicMessage(topic: 'topic-1', notification: Notification(title: 'Message 1')),
  TopicMessage(topic: 'topic-2', notification: Notification(title: 'Message 2')),
]);
print('Sent: ${response.successCount}, Failed: ${response.failureCount}');
```

#### sendEachForMulticast

```dart
// Send one message to multiple device tokens
final response = await messaging.sendEachForMulticast(
  MulticastMessage(
    tokens: ['<token-1>', '<token-2>', '<token-3>'],
    notification: Notification(title: 'Hello', body: 'World!'),
  ),
);
print('Sent: ${response.successCount}, Failed: ${response.failureCount}');
```

#### subscribeToTopic / unsubscribeFromTopic

```dart
// Subscribe tokens to a topic
await messaging.subscribeToTopic(['<token-1>', '<token-2>'], 'news');

// Unsubscribe tokens from a topic
await messaging.unsubscribeFromTopic(['<token-1>', '<token-2>'], 'news');
```

### Storage

```dart
import 'dart:typed_data';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:google_cloud_storage/google_cloud_storage.dart' as gcs;

final app = FirebaseApp.initializeApp();
final storage = app.storage();
final bucket = storage.bucket('<bucket-name>');
```

#### insertObject (upload)

```dart
await bucket.storage.insertObject(
  bucket.name,
  'path/to/file.txt',
  Uint8List.fromList('Hello, world!'.codeUnits),
  metadata: gcs.ObjectMetadata(contentType: 'text/plain'),
);
```

#### downloadObject

```dart
final bytes = await bucket.storage.downloadObject(bucket.name, 'path/to/file.txt');
print(String.fromCharCodes(bytes));
```

#### objectMetadata

```dart
final metadata = await bucket.storage.objectMetadata(bucket.name, 'path/to/file.txt');
print('Size: ${metadata.size} bytes');
print('Content type: ${metadata.contentType}');
```

#### deleteObject

```dart
await bucket.storage.deleteObject(bucket.name, 'path/to/file.txt');
```

#### getDownloadURL

Returns a long-lived public download URL backed by a Firebase download token, suitable for sharing with end-users.

```dart
final url = await storage.getDownloadURL(bucket, 'path/to/file.txt');
print('Download URL: $url');
```

### Security Rules

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

final app = FirebaseApp.initializeApp();
final securityRules = app.securityRules();
```

#### getFirestoreRuleset

```dart
final ruleset = await securityRules.getFirestoreRuleset();
print(ruleset.name);
```

#### releaseFirestoreRulesetFromSource

```dart
final source = '''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
''';

final ruleset = await securityRules.releaseFirestoreRulesetFromSource(source);
print('Applied ruleset: ${ruleset.name}');
```

#### getStorageRuleset

```dart
final ruleset = await securityRules.getStorageRuleset();
print(ruleset.name);
```

#### releaseStorageRulesetFromSource

```dart
final source = '''
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
''';

final ruleset = await securityRules.releaseStorageRulesetFromSource(source);
print('Applied ruleset: ${ruleset.name}');
```

#### createRuleset / deleteRuleset

```dart
// Create a ruleset without applying it
const source = "rules_version = '2'; service cloud.firestore { match /databases/{database}/documents { match /{document=**} { allow read, write: if false; } } }";
final rulesFile = RulesFile(name: 'firestore.rules', content: source);
final ruleset = await securityRules.createRuleset(rulesFile);
print('Created ruleset: ${ruleset.name}');

// Delete a ruleset by name
await securityRules.deleteRuleset(ruleset.name);
```

## Supported Services

The Firebase Admin Dart SDK currently supports the following Firebase services:

🟢 - Fully supported <br />
🟡 - Partially supported / Work in progress <br />
🔴 - Not supported

| Service               | Status  | Notes                          |
|-----------------------|---------|--------------------------------|
| App                   | 🟢      |                                |
| App Check             | 🟢      |                                |
| Authentication        | 🟢      |                                |
| Data Connect          | 🔴      |                                |
| Realtime Database     | 🔴      |                                |
| Event Arc             | 🔴      |                                |
| Extensions            | 🔴      |                                |
| Firestore             | 🟢      | Excludes realtime capabilities |
| Functions             | 🟢      |                                |
| Installations         | 🔴      |                                |
| Machine Learning      | 🔴      |                                |
| Messaging             | 🟢      |                                |
| Project Management    | 🔴      |                                |
| Remote Config         | 🔴      |                                |
| Security Rules        | 🟢      |                                |
| Storage               | 🟢      |                                |

## Additional Packages

Alongside the Firebase Admin Dart SDK, this repository contains additional workspace/pub.dev packages to accomodate the SDK:

- [google_cloud_firestore](/packages/google_cloud_firestore/): Standalone Google APIs Firestore SDK, which the Firebase SDK extends.
- [google_cloud_storage](https://github.com/googleapis/google-cloud-dart/tree/main/packages/google_cloud_storage): Standalone Google Cloud Storage SDK, which the Firebase SDK extends.

# Contributing

Contributions are welcome! Please read the [contributing guide](CONTRIBUTING.md) to get started.

# License

[Apache License Version 2.0](LICENSE)
