# Firebase Admin Dart SDK

## Table of Contents

 - [Overview](#overview)
 - [Installation](#installation)
 - [Initalization](#initalization)
 - [Usage](#usage)
   - [Authentication](#authentication)
   - [App Check](#app-check)
   - [Firestore](#firestore)
   - [Functions](#functions)
   - [Messaging](#messaging)
   - [Storage](#storage)
 - [Supported Services](#supported-services)
 - [Additional Packages](#additional-packages)
 - [Contributing](#contributing)
 - [License](#license)

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

## Initalization

### Initialize the SDK

To initalize the Firebase Admin SDK, call the `initializeApp` method on the `Firebase`
class:

```dart
// TODO: Is it Firebase, FirebaseApp, FirebaseAdmin?
final app = FirebaseApp.initializeApp();
```

This will automatically initialize the SDK with [Google Application Default Credentials](https://cloud.google.com/docs/authentication/production#providing_credentials_to_your_application). Because default credentials lookup is fully automated in Google environments, with no need to supply environment variables or other configuration, this way of initializing the SDK is strongly recommended for applications running in Google environments such as Firebase App Hosting, Cloud Run, App Engine, and Cloud Functions for Firebase.

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

## Usage

Once you have initialized an app instance with a credential, you can use any of the [supported services](#supported-services) to interact with Firebase.

### Authentication

```dart
final app = FirebaseApp.initializeApp();

// Getting a user by id
final user = await app.auth().getUser("<user-id>");

// Deleting a user by id
await app.auth().deleteUser("<user-id>");

// Listing users
final result = await app.auth().listUsers(maxResults: 10, pageToken: null);
final users = result.users;
final nextPageToken = result.pageToken;

// Verifying an ID token (e.g. from request headers) from a client application
final idToken = req.headers['Authorization'].split(' ')[1];
final decodedToken = await app.auth().verifyIdToken(idToken, checkRevoked: true);
final userId = decodedToken.uid;
```

### App Check

```dart
final app = FirebaseApp.initializeApp();

// Verifying an app check token
final response = await app.appCheck().verifyToken("<appCheckToken>");
print("App ID: ${response.appId}");

// Creating a new app check token
final result = await app.appCheck().createToken("<app-id>");
print("Token: ${result.token}");
```

### Firestore

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:googleapis_firestore/googleapis_firestore.dart';

final app = FirebaseApp.initializeApp();

// Getting a document
final snapshot = await app.firestore().collection("users").doc("<user-id>").get();
print(snapshot.data());

// Querying a collection
final querySnapshot = await app.firestore().collection("users")
  .where('age', WhereFilter.greaterThan, 18)
  .orderBy('age', descending: true)
  .get();
print(querySnapshot.docs);

// Running a transaction (e.g. adding credits to a balance)
final balance = await app.firestore().runTransaction((tsx) async {
  // Get a reference to a user document
  final ref = app.firestore().collection("users").doc("<user-id>");

  // Get the document data
  final snapshot = await tsx.get(ref);

  // Get the users current balance (or 0 if it doesn't exist)
  final currentBalance = snapshot.exists ? snapshot.data()?['balance'] ?? 0 : 0;

  // Add 10 credits to the users balance
  final newBalance = currentBalance + 10;

  // Update the document within the transaction
  tsx.update(ref, {
    'balance': newBalance,
  });

  return newBalance;
});
```

### Functions

```dart
final app = FirebaseApp.initializeApp();

// Get a task queue by name
final queue = app.functions().taskQueue("<task-name>");

// Add data to the queue
await queue.enqueue({ "hello": "world" });
```

### Messaging

```dart
final app = FirebaseApp.initializeApp();

// Send a message to a specific device
await app.messaging().send(
  TokenMessage(
    token: "<device-token>",
    data: { "hello": "world" },
    notification: Notification(title: "Hello", body: "World!"),
  )
);

// Send a message to a topic
await app.messaging().send(
  TopicMessage(
    topic: "<topic-name>",
    data: { "hello": "world" },
    notification: Notification(title: "Hello", body: "World!"),
  )
);

// Send a message to a conditional statement
await app.messaging().send(
  ConditionMessage(
    condition: "\'stock-GOOG\' in topics || \'industry-tech\' in topics",
    data: { "hello": "world" },
    notification: Notification(title: "Hello", body: "World!"),
  )
);
```

### Storage

TODO

## Supported Services

The Firebase Admin Dart SDK currently supports the following Firebase services:

🟢 - Fully supported <br />
🟡 - Partially supported / Work in progress <br />
🔴 - Not supported

| Service               | Status  | Notes                              |
|-----------------------|---------|-------------------------------------|
| App                   | 🟢      |                                     |
| App Check             | 🟢      |                                     |
| Authentication        | 🟢      |                                     |
| Data Connect          | 🔴      |                                     |
| Realtime Database     | 🔴      |                                     |
| Event Arc             | 🔴      |                                     |
| Extensions            | 🔴      |                                     |
| Firestore             | 🟢      | Excludes realtime capabilities      |
| Functions             | 🟢      |                                     |
| Installations         | 🔴      |                                     |
| Machine Learning      | 🔴      |                                     |
| Messaging             | 🟢      |                                     |
| Project Management    | 🔴      |                                     |
| Remote Config         | 🔴      |                                     |
| Security Rules        | 🟢      |                                     |
| Storage               | 🟡      | Work in progress                    |

## Additional Packages

Alongside the Firebase Admin Dart SDK, this repository contains additional workspace/pub.dev packages to accomodate the SDK:

- [googleapis_auth_utils](/packages/googleapis_auth_utils/): Additional functionality extending the [googleapis_auth](https://pub.dev/packages/googleapis_auth) package.
- [googleapis_firestore](/packages/googleapis_firestore/): Standalone Google APIs Firestore SDK, which the Firebase SDK extends.
- [googleapis_storage](/packages/googleapis_storage/): Standalone Google APIs Storage SDK, which the Firebase SDK extends.

# Contributing

TODO

# License

[Apache License Version 2.0](LICENSE)
