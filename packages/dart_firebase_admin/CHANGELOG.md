## 0.5.0 - 2026-03-10

### Breaking Changes

- `initializeApp()` now accepts `AppOptions` instead of positional `projectId` and `credential` arguments. Project ID is auto-discovered from credentials, environment variables, or the GCE metadata server if not provided.
- Firebase service constructors (`Auth(app)`, `Firestore(app)`, etc.) have been removed. Use the instance methods on `FirebaseApp` instead: `app.auth()`, `app.firestore()`, `app.messaging()`, etc. Service instances are now cached — calling `app.auth()` multiple times returns the same instance.
- `ActionCodeSettings.dynamicLinkDomain` has been removed. Use `linkDomain` instead.
- `Credential` is now a sealed class with `ServiceAccountCredential` and `ApplicationDefaultCredential` subtypes.

### New Features

**App**
- Added multi-app support: `initializeApp(options, name: 'secondary')` and `FirebaseApp.getApp('name')` (#106)
- Added `app.serviceAccountEmail()` and `app.sign()` extension methods on `FirebaseApp` (#171)
- All outgoing SDK requests now include an `X-Firebase-Client: fire-admin-dart/<version>` usage tracking header (#169)

**Auth**
- Added tenant support: `app.auth().tenantManager()` returns a `TenantManager`; use `tenantManager.authForTenant(tenantId)` for tenant-scoped auth operations (#103)
- Added `ProjectConfigManager` for managing project-level auth configuration (email privacy, SMS regions, password policies, MFA, reCAPTCHA, mobile links) via `app.auth().projectConfigManager()` (#111)
- Added TOTP multi-factor authentication support (#114)
- Added `SessionCookieOptions` type for `createSessionCookie` (#114)
- Added `linkDomain` to `ActionCodeSettings` (#111)
- Added `Credential.getAccessToken()` to retrieve an OAuth2 access token (#110)
- Added reCAPTCHA managed rules, key types, and toll fraud protection configuration in tenant settings (#114)

**Firestore**
- Added multi-database support: `app.firestore(databaseId: 'analytics-db')` (#121)
- Added `Transaction.getQuery()` to execute queries within a transaction (#113)
- Added `Transaction.getAggregateQuery()` to execute aggregation queries within a transaction (#127)
- Added `BulkWriter` for high-throughput writes with automatic batching (20 ops/batch) and rate limiting using the 500/50/5 rule (#123)
- Added `SetOptions` for merge operations, available on `WriteBatch`, `Transaction`, `BulkWriter`, and `DocumentReference` (#123)
- Added Vector Search support: `FieldValue.vector()`, `VectorValue`, `query.findNearest()`, `VectorQuery`, `VectorQuerySnapshot` (#125)
- Added Query Explain API: `query.explain()` and `vectorQuery.explain()` (#125)
- Added query partitioning: `CollectionGroup.getPartitions(desiredPartitionCount)` returns a list of `QueryPartition` objects; call `partition.toQuery()` to execute each chunk in parallel (#126)
- Added `Firestore.recursiveDelete(ref, bulkWriter)` for bulk deletion of documents and collections (#164)
- `withConverter()` now accepts `null` to reset a typed reference back to `DocumentData` (#164)

**Storage** _(new service)_
- Added `app.storage()` with full `FirebaseApp` lifecycle integration (#129)
- Added emulator support via `FIREBASE_STORAGE_EMULATOR_HOST` (#129)
- Added `file.getDownloadURL()` for retrieving a permanent download URL (#182)

**Messaging**
- Added `messaging.subscribeToTopic(tokens, topic)` and `messaging.unsubscribeFromTopic(tokens, topic)` (#115)

**Functions** _(new service)_
- Added `app.functions()` for Cloud Functions admin operations (#116)
- Added Task Queue API: `functions.taskQueue(functionName)` with `enqueue()` and `delete()`, supporting scheduling, deadlines, custom headers, and custom task IDs (#116)
- Added Cloud Tasks emulator support via `CLOUD_TASKS_EMULATOR_HOST` (#116)

### Bug Fixes

- Fixed exceptions being silently swallowed instead of rethrown across all services (#131)
- Fixed `Messaging.sendEach()` incorrectly returning `internalError` for invalid registration tokens; now correctly returns `invalidArgument` (#115)
- Fixed JWT decode exceptions and integer division issues in `verifySessionCookie` (#114)
- Fixed missing `INVALID_ARGUMENT` error code mapping in `SecurityRules` (#119)
- Fixed `ExponentialBackoff` in Firestore not correctly tracking backoff completion state (#183)
- Fixed Auth using `invalidProviderUid` instead of `invalidUid` in `getAccountInfoByFederatedUid` (#114)

## 0.4.1 - 2025-03-21

- Bump intl to `0.20.0`
- Fixed `verifyIdToken` (thanks to @jtdLab)
- Added Transaction support (thanks to @evandrobubiak)
- Firebase Emulators now obtain port information from the environment ; if available (thanks to @dinko7)
- Fix incorrect read of GOOGLE_APPLICATION_CREDENTIALS. It now correctly expects a file path instead of JSON
- Added `AppCheck` and `SecurityRules` support

## 0.4.0 - 2024-09-11

- Added `firestore.listCollections()` and `doc.listCollections()`
- Fixes some errors incorrectly coming back as "unknown".
- `Apns` parameters are no-longer required
- Fixes argument error in FMC when sending booleans
- Renamed various error codes to remove duplicates and removed
  unused codes.
- Fixes crash when updating users (thanks to @HeySreelal)
- Marked various classes that cannot be extended as base/final.
- Added a default constructor on `Timestamp` (thanks to @KKimj)
- Fixes the `Auth.verifyIdToken()` implementation by adding the
    token signature verification part. 

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
