# Contributing | Firebase Admin Dart SDK

Thank you for contributing to the Firebase community!

 - [Have a usage question?](#question)
 - [Think you found a bug?](#issue)
 - [Have a feature request?](#feature)
 - [Want to submit a pull request?](#submit)
 - [Need to get set up locally?](#local-setup)


## <a name="question"></a>Have a usage question?

We get lots of those and we love helping you, but GitHub is not the best place for them. Issues
which just ask about usage will be closed. Here are some resources to get help:

- Go through the [guides](https://firebase.google.com/docs/admin/setup/)
- Read the full [API reference](https://pub.dev/documentation/dart_firebase_admin/latest/)

If the official documentation doesn't help, try asking a question on [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase+dart).

**Please avoid double posting across multiple channels!**


## <a name="issue"></a>Think you found a bug?

Yeah, we're definitely not perfect!

Search through [old issues](https://github.com/firebase/firebase-admin-dart/issues) before
submitting a new issue as your question may have already been answered.

If your issue appears to be a bug, and hasn't been reported,
[open a new issue](https://github.com/firebase/firebase-admin-dart/issues/new). Please use the
provided bug report template and include a minimal repro.

If you are up to the challenge, [submit a pull request](#submit) with a fix!


## <a name="feature"></a>Have a feature request?

Great, we love hearing how we can improve our products! Share you idea through our
[feature request support channel](https://firebase.google.com/support/contact/bugs-features/).


## <a name="submit"></a>Want to submit a pull request?

Sweet, we'd love to accept your contribution!
[Open a new pull request](https://github.com/firebase/firebase-admin-dart/pulls) and fill
out the provided template.

**If you want to implement a new feature, please open an issue with a proposal first so that we can
figure out if the feature makes sense and how it will work.**

Make sure your changes pass our linter and the tests all pass on your local machine. We've hooked
up this repo with continuous integration to double check those things for you.

Most non-trivial changes should include some extra test coverage. If you aren't sure how to add
tests, feel free to submit regardless and ask us for some advice.

Finally, you will need to sign our
[Contributor License Agreement](https://cla.developers.google.com/about/google-individual),
and go through our code review process before we can accept your pull request.

### Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License
Agreement. You (or your employer) retain the copyright to your contribution.
This simply gives us permission to use and redistribute your contributions as
part of the project. Head over to <https://cla.developers.google.com/> to see
your current agreements on file or to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

### Code reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.


## <a name="local-setup"></a>Need to get set up locally?

### Prerequisites

1. [Dart SDK](https://dart.dev/get-dart) (Latest stable version recommended).
2. [Melos](https://melos.invertase.dev/) (`dart pub global activate melos`).
3. Google Cloud SDK ([`gcloud`](https://cloud.google.com/sdk/downloads) utility).

### Initial Setup

Run the following commands from the command line to get your local environment set up:

```bash
$ git clone https://github.com/firebase/firebase-admin-dart.git
$ cd firebase-admin-dart    # go to the firebase-admin-dart directory
$ melos bootstrap           # install dependencies and link packages
```

In order to run the integration tests, you also need to authorize the `gcloud` utility with
Google application default credentials:

```bash
$ gcloud beta auth application-default login
```

### Running the Linter

Source files are written in Dart and analyzed using the standard Dart analyzer. Run the following command to analyze the project:

```bash
$ melos run analyze
# OR
$ dart analyze .
```

### Running Tests

There are two types of tests: unit and integration. The unit tests are intended to be run during
development, and the integration tests are intended to be run validation against a real Environment or Emulator Suite.

#### Unit Tests

To run the unit tests for all packages:

```bash
$ melos exec -- dart test
```

Or for a specific package, navigate to the package directory and run `dart test`:

```bash
$ cd packages/dart_firebase_admin
$ dart test
```

#### Integration Tests with Emulator Suite

Some of the integration tests work with the Emulator Suite and you can run them
without an actual Firebase project.

First, make sure to [install Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli).
And then start the emulators:

```bash
$ firebase emulators:start --only firestore,auth
```

Then run the tests with the necessary environment variables:

```bash
$ export FIRESTORE_EMULATOR_HOST=localhost:8080
$ export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
$ dart test test/firestore/firestore_integration_test.dart
```

#### Integration Tests with an actual Firebase project

Integration tests are executed against a real life Firebase project. If you do not already
have one suitable for running the tests against, you can create a new project in the
[Firebase Console](https://console.firebase.google.com) following the setup guide below.
If you already have a Firebase project, you'll need to obtain credentials to communicate and
authorize access to your Firebase project.

See `packages/dart_firebase_admin/README.md` for more details on project setup if needed.

### Repo Organization

This repository is a monorepo managed by Melos.

* `packages/` - Contains all the source packages.
  * `dart_firebase_admin/` - The main Firebase Admin SDK package.
  * `googleapis_firestore/` - Stand-alone Firestore package.
  * `googleapis_storage/` - Stand-alone Google Cloud Storage package.
