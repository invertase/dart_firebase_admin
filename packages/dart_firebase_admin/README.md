## Dart Firebase Admin

Welcome! This project is a port of [Node's Firebase Admin SDK](https://github.com/firebase/firebase-admin-node) to Dart.

⚠️ This project is still in its early stages, and some features may be missing or bugged.
Currently, only Firestore is available, with more to come (auth next).

- [Dart Firebase Admin](#dart-firebase-admin)
- [Usage](#usage)
  - [Connecting to the SDK](#connecting-to-the-sdk)
    - [Connecting using the environment](#connecting-using-the-environment)
    - [Connecting using a `service-account.json` file](#connecting-using-a-service-accountjson-file)
  - [Using Firestore](#using-firestore)

## Usage

### Connecting to the SDK

Before using Firebase, we must first authenticate.

There are currently two options:

- You can connect using environment variables
- Alternatively, you can specify a `service-account.json` file

#### Connecting using the environment

To connect using environment variables, you will need to have
the [Firebase CLI](https://firebaseopensource.com/projects/firebase/firebase-tools/) installed.

Once done, you can run:

```sh
firebase login
```

And log-in to the project of your choice.

From there, you can have your Dart program authenticate
using the environment with:

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

void main() {
  final admin = FirebaseAdminApp.initializeApp(
    '<your project name>',
    // This will obtain authentication informations from the environment
    Credential.fromApplicationDefaultCredentials(),
  );

  // TODO use the Admin SDK
  final firestore = Firestore(admin);
  firestore.doc('hello/world').get();
}
```

#### Connecting using a `service-account.json` file

Alternatively, you can choose to use a `service-account.json` file.  
This file can be obtained in your firebase console by going to:

```
https://console.firebase.google.com/u/0/project/<your-project-name>/settings/serviceaccounts/adminsdk
```

Make sure to replace `<your-project-name>` with the name of your project.
One there, follow the steps and download the file. Place it anywhere you want in your project.

**⚠️ Note**:
This file should be kept private. Do not commit it on public repositories.

After all of that is done, you can now authenticate in your Dart program using:

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

void main() {
  final admin = FirebaseAdminApp.initializeApp(
    '<your project name>',
    // Log-in using the newly downloaded file.
    Credential.fromServiceAccount(
      File('<path to your service-account.json file>'),
    ),
  );

  // TODO use the Admin SDK
  final firestore = Firestore(admin);
  firestore.doc('hello/world').get();
}
```

### Using Firestore

First, make sure to follow the steps on [how to authenticate](#connecting-to-the-sdk).
You should now have an instance of a `FirebaseAdminApp` object.

You can now use this object to create a `Firestore` object as followed:

```dart
// Obtained in the previous steps
FirebaseAdminApp admin;
final firestore = Firestore(admin);
```

From this point onwards, using Firestore with the admin ADK
is roughtly equivalent to using [FlutterFire](https://github.com/firebase/flutterfire).

Using this `Firestore` object, you'll find your usual collection/query/document
objects.

For example you can perform a `where` query:

```dart
// The following lists all users above 18 years old
final collection = firestore.collection('users');
final adults = collection.where('age', WhereFilter.greaterThan, 18);

final adultsSnapshot = await adults.get();

for (final adult in adultsSnapshot.docs) {
  print(adult.data()['age']);
}
```

Composite queries are also supported:

```dart
// List users with either John or Jack as first name.
firestore
  .collection('users')
  .whereFilter(
    Filter.or([
      Filter.where('firstName', WhereFilter.equal, 'John'),
      Filter.where('firstName', WhereFilter.equal, 'Jack'),
    ]),
  );
```

Alternatively, you can fetch a specific document too:

```dart
// Print the age of the user with ID "123"
final user = await firestore.doc('users/123').get();
print(user.data()?['age']);
```

---

<p align="center">
  <a href="https://invertase.io/?utm_source=readme&utm_medium=footer&utm_campaign=dart_custom_lint">
    <img width="75px" src="https://static.invertase.io/assets/invertase/invertase-rounded-avatar.png">
  </a>
  <p align="center">
    Built and maintained by <a href="https://invertase.io/?utm_source=readme&utm_medium=footer&utm_campaign=dart_custom_lint">Invertase</a>.
  </p>
</p>
