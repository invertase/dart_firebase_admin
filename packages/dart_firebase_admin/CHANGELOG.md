## Unreleased fix

- Fixes crash when updating users (thanks to @HeySreelal)

## 0.3.1

 - **FEAT**: Use GOOGLE_APPLICATION_CREDENTIALS if json value (#32).

## 0.3.0 - 2024-01-02

- **Breaking**: Removed the value `toJson` methods on objects.
  These were not intended to be public.
- Added Firebase Messaging
- Upgraded outdated dependencies

## 0.2.0 - 2023-11-30

- Increased minimum Dart SDK to `3.2.0`.
  This fixes a compilation error due to `utf8.encode`.
- Added `Credential.fromServiceAccountParams` (thanks to @akaboshinit)
- Added `FirebaseAdminApp.close`, to close open connections and stop the SDK.
- Fixed various typos
- Added `Firestore.collectionGroup` support
- Fix `Auth.getUserByEmail` parsing error.

## 0.1.0 - 2023-10-15

Added Firebase Auth

## 0.0.2

Fix 404 error when not using the emulator.

## 0.0.1

Initial release
