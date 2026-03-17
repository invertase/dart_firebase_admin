# Contributing to Firebase Admin SDK for Dart

Thank you for contributing to Firebase Admin SDK for Dart! This guide will help you get set up and familiar with the project conventions.

## Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License Agreement (CLA). You (or your employer) retain the copyright to your contribution; the CLA gives us permission to use and redistribute your contributions as part of the project.

Visit <https://cla.developers.google.com/> to see your current agreements on file or to sign a new one. You generally only need to submit a CLA once, so if you have already submitted one you probably don't need to do it again.

## Code Reviews

All submissions, including submissions by project members, require review. We use GitHub pull requests for this purpose. Consult [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information on pull requests.

## Getting Started

### Prerequisites

- **Dart SDK** >= 3.9.0
- **Java 21+** (required for the Firestore emulator)
- **Node.js** (required for the Firebase Emulator and Cloud Tasks emulator)
- **Melos** — Dart monorepo tool (`dart pub global activate melos`)
- **Firebase CLI** (`npm install -g firebase-tools`)

### Setup

1. Fork and clone the repository.

2. Install Melos and bootstrap the workspace from the repo root:

   ```bash
   dart pub global activate melos
   melos bootstrap
   ```

3. Verify your setup by running the analyzer and formatter:

   ```bash
   cd packages/dart_firebase_admin
   dart format --set-exit-if-changed .
   dart analyze
   ```

## Development Workflow

### Project Structure

```
dart_firebase_admin/             # Workspace root
├── packages/
│   └── dart_firebase_admin/
│       ├── lib/
│       │   ├── dart_firebase_admin.dart  # Public API barrel file
│       │   ├── auth.dart                 # Auth public exports
│       │   ├── firestore.dart            # Firestore public exports
│       │   ├── messaging.dart            # Messaging public exports
│       │   ├── storage.dart              # Storage public exports
│       │   ├── app_check.dart            # App Check public exports
│       │   ├── security_rules.dart       # Security Rules public exports
│       │   ├── functions.dart            # Functions public exports
│       │   └── src/                      # Private implementation
│       │       ├── app/                  # FirebaseApp & credential management
│       │       ├── auth/                 # Authentication (users, tenants, tokens)
│       │       ├── app_check/            # App Check token verification
│       │       ├── firestore/            # Firestore wrapper
│       │       ├── messaging/            # FCM messaging
│       │       ├── storage/              # Cloud Storage
│       │       ├── security_rules/       # Security Rules management
│       │       ├── functions/            # Cloud Functions invocation
│       │       └── utils/               # Shared utilities
│       └── test/
│           ├── auth/                     # Auth unit & integration tests
│           ├── app/                      # App unit & integration tests
│           ├── firestore/                # Firestore tests
│           ├── messaging/                # Messaging tests
│           ├── storage/                  # Storage tests
│           └── helpers.dart             # Shared test utilities
└── scripts/
    ├── coverage.sh                       # Run tests with coverage
    └── firestore-coverage.sh             # Firestore package coverage
```

### Running Tests

Tests are split into unit tests (run against emulators) and integration/production tests (run against a real Firebase project).

```bash
# From packages/dart_firebase_admin

# Run all tests against emulators (requires Firebase CLI)
firebase emulators:exec --project dart-firebase-admin --only auth,firestore,functions,tasks,storage \
  "dart run coverage:test_with_coverage -- --concurrency=1"

# Or use the convenience script from the repo root
./scripts/coverage.sh

# Run a specific test file
dart test test/auth/auth_test.dart

# Run production integration tests (requires real credentials)
# Set GOOGLE_APPLICATION_CREDENTIALS and RUN_PROD_TESTS=true first
dart test test/app/firebase_app_prod_test.dart --concurrency=1
```

### Code Formatting and Analysis

```bash
# Check formatting (CI will reject unformatted code)
dart format --set-exit-if-changed .

# Apply formatting
dart format .

# Run the analyzer (must pass with zero issues)
dart analyze
```

### License Headers

All source files must include a license header. The project uses [addlicense](https://github.com/google/addlicense) to manage this automatically, using the template in `header_template.txt` at the repo root.

**Install addlicense:**

Download the binary for your platform from the [v1.2.0 release](https://github.com/google/addlicense/releases/tag/v1.2.0) and place it on your `PATH`. For example, on macOS ARM64:

```bash
curl -sL https://github.com/google/addlicense/releases/download/v1.2.0/addlicense_v1.2.0_macOS_arm64.tar.gz | tar xz
sudo mv addlicense /usr/local/bin/
```

**Add headers to new files (run from repo root):**

```bash
addlicense -f header_template.txt \
  --ignore "**/*.yml" --ignore "**/*.yaml" --ignore "**/*.xml" \
  --ignore "**/*.g.dart" --ignore "**/*.sh" --ignore "**/*.html" \
  --ignore "**/*.js" --ignore "**/*.ts" --ignore "**/*.txt" \
  --ignore "**/.dart_tool/**" \
  --ignore "**/node_modules/**" \
  .
```

**Check headers (dry run, same as CI):**

```bash
addlicense -f header_template.txt --check \
  --ignore "**/*.yml" --ignore "**/*.yaml" --ignore "**/*.xml" \
  --ignore "**/*.g.dart" --ignore "**/*.sh" --ignore "**/*.html" \
  --ignore "**/*.js" --ignore "**/*.ts" --ignore "**/*.txt" \
  --ignore "**/.dart_tool/**" \
  --ignore "**/node_modules/**" \
  .
```

CI will fail if any source file is missing its license header.

### Local Validation

Run the full check suite locally before pushing:

```bash
dart format --set-exit-if-changed .
dart analyze
./scripts/coverage.sh
```

## Code Standards

### Style

The project uses strict analysis settings (`strict-casts`, `strict-inference`, `strict-raw-types`). Key conventions enforced by `analysis_options.yaml`:

- **Use single quotes** for strings (`prefer_single_quotes`).
- **Use `final` for local variables** where values are not reassigned.
- **Prefer relative imports** within the package.
- **Always declare return types** on functions and methods.

### Public API

- Each Firebase product has its own barrel file (e.g., `lib/auth.dart`, `lib/firestore.dart`). Only add exports there for types that users need directly.
- The top-level `lib/dart_firebase_admin.dart` re-exports core types. Product-specific types belong in their respective barrel files.
- Classes under `lib/src/` are implementation details and should not be exported from barrel files unless they are part of the public API.

### Documentation

- Add dartdoc (`///`) comments to all new public APIs.
- Include code examples in doc comments where they help clarify usage.

### Error Handling

- Use typed exceptions (e.g., `FirebaseAuthException`, `FirebaseMessagingException`) with appropriate error codes for user-facing errors.
- Match the behaviour of the Node.js Admin SDK where applicable.

## Testing Requirements

- **All new features and bug fixes must include tests.**
- **Unit/emulator tests** go in the appropriate subdirectory under `test/`. Use the `helpers.dart` utilities and `mocktail` for mocking where needed.
- **Integration tests** (files named `*_integration_test.dart`) run against the Firebase Emulator in CI.
- **Production tests** (files named `*_prod_test.dart`) require real credentials and are not run in CI by default — gate them behind `RUN_PROD_TESTS`.
- Maintain the overall coverage above the **40% threshold** enforced by CI.

## Pull Request Process

1. Create a feature branch from `main`.
2. Make your changes, including tests.
3. Run formatting, analysis, and tests locally (see commands above).
4. Push your branch and open a pull request.
5. Fill in the PR description:
   - **What** the change does and **why**.
   - Link to any related issues.
   - Note any breaking changes.
6. CI will run automatically. All checks must pass before merging.
7. A project maintainer will review and may request changes.

### Commit Messages

- Write clear, descriptive commit messages.
- Use imperative mood (e.g., "Add App Check token verification" not "Added App Check token verification").
- Reference issues with `#number` where applicable.

## CI/CD

The project uses a single **build.yml** GitHub Actions workflow with four jobs:

| Job | Trigger | What it does |
|-----|---------|--------------|
| `check-license-header` | PRs & schedule | Validates license headers on all source files |
| `lint` | PRs & schedule | Runs `dart format` and `dart analyze` |
| `test` | PRs & schedule | Runs tests against emulators with coverage reporting |
| `test-integration` | PRs (non-fork) & schedule | Runs production integration tests with Workload Identity Federation |
| `build` | After all above pass | Validates `dart pub publish --dry-run` |

Tests run against both `stable` and `beta` Dart SDK channels. Coverage is reported as a PR comment and uploaded to Codecov. The minimum coverage threshold is **40%**.

## License

By contributing, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).
