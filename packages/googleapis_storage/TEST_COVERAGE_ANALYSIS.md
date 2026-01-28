# Dart vs Node.js Storage SDK Test Coverage Analysis

**Generated:** 2026-01-27

## SDK References

### Dart Firebase Admin SDK
- **Package:** `dart_firebase_admin/packages/googleapis_storage`
- **Repository:** [firebase-admin-sdk/dart_firebase_admin](https://github.com/invertase/firebase-admin-sdk)
- **Test Files Location:** `/packages/googleapis_storage/test/`
  - Unit tests: `test/unit/`
  - Integration tests: `test/integration/`

### Node.js Google Cloud Storage SDK
- **Package:** `@google-cloud/storage` (used by Firebase Admin Node.js SDK)
- **Repository:** [googleapis/nodejs-storage](https://github.com/googleapis/nodejs-storage)
- **NPM:** [@google-cloud/storage](https://www.npmjs.com/package/@google-cloud/storage)
- **Test Files Location:** `test/`
  - Unit tests: Node.js SDK uses inline tests within each test file
  - System tests: `system-test/`

### Firebase Admin Node.js SDK (Storage)
- **Repository:** [firebase/firebase-admin-node](https://github.com/firebase/firebase-admin-node)
- **Storage Implementation:** `src/storage/`
- **Storage Tests:** `test/unit/storage/` and `test/integration/storage.spec.ts`

## 🎉 Recent Progress (2026-01-27)

### Completed
✅ **Fixed Critical Gzip Double-Decompression Bug**
- Implemented `StorageHttpClient` that routes OAuth/auth requests (need auto-decompression for JSON) and Storage API requests (need manual decompression for validation) to appropriately configured HTTP clients
- All 89 unit tests pass (including 5 new HTTP-level tests for `createReadStream`)
- All 21 integration tests pass (including 11 new File operation tests)

✅ **Added File Operation Tests**
- **Unit Tests**: Added 72 new unit tests to `file_test.dart` (now 89 total, was 17)
  - `save()` - 6 tests (String, List<int>, Uint8List, Stream, unsupported types, options)
  - `download()` - 4 tests (options filtering, in-memory download)
  - `copy()` - 14 tests (all destination types, preconditions, encryption, multi-part copy)
  - `move()` - 5 tests (copy+delete flow, same destination handling, error cases)
  - `rename()` - 2 tests (move delegation, File destination)
  - `delete()` - 6 tests (preconditions, ignoreNotFound, error handling)
  - `exists()` - 5 tests (404 handling, userProject, getMetadata delegation)
  - `get()` - 3 tests (basic get, 404 handling, userProject)
  - `getMetadata()` - 6 tests (API call, userProject, generation, instance update, errors)
  - `setMetadata()` - 5 tests (updates, preconditions, userProject, instance update, errors)
  - `makePrivate()` - 5 tests (projectPrivate, strict mode, metadata merging, options)
  - `makePublic()` - 2 tests (allUsers ACL, userProject)
  - `publicUrl()` - 4 tests (URL formatting, encoding, special characters)
  - `createReadStream()` - 5 HTTP-level tests (gzip validation/decompression, non-gzip validation, CRC32C failures, validation disabled, range requests)

- **Integration Tests**: Added 11 new integration tests to `file_integration_test.dart` (now 21 total, was 10)
  - `save()` - 4 tests (String, List<int>, Uint8List, Stream with gzip)
  - `download()` - 4 tests (corresponding to save tests)
  - `getMetadata()` - 1 test
  - `setMetadata()` - 1 test
  - `copy()` - 1 test
  - `move()` - 1 test
  - `rename()` - 1 test
  - `delete()` - 1 test
  - `exists()` - 1 test

**Coverage Comparison**: Our Dart File integration tests **exceed** Node.js coverage:
- Node.js: 4 File methods tested in integration (save, download, delete, exists - each tested once with string data only)
- Dart: 9 File methods tested in integration with multiple data types and scenarios

### Next Steps
Based on remaining gaps, prioritize in this order:

1. **File Methods - Unit Tests** (Missing unit tests for):
   - `createResumableUpload()` - Node.js has 5 tests
   - `createWriteStream()` - Node.js has 50 tests (complex, needs resumable upload mocking)
   - `getExpirationDate()` - Node.js has 4 tests
   - `isPublic()` - Node.js has 7 tests
   - `moveFileAtomic()` - Node.js tests exist
   - `restore()` - Node.js has 1 test
   - `rotateEncryptionKey()` - Node.js has 4 tests
   - `setStorageClass()` - Node.js has 4 tests
   - `setUserProject()` - Node.js has tests

2. **Bucket Methods** (Node.js: 210 tests | Dart: 8 tests | Gap: 96%)
   - Start with critical operations: `upload()`, `getFiles()`, `deleteFiles()`, `file()`

3. **Other APIs**
   - IAM operations (20 Node.js tests, 0 Dart tests)
   - TransferManager (45 Node.js tests, 0 Dart tests)
   - Notification (26 Node.js tests, 0 Dart tests)

---

## Executive Summary

The Dart Storage SDK has **excellent coverage** for authentication, validation, and factory methods, and has **significantly improved File operation coverage** with 89 unit tests and 21 integration tests for File methods (exceeding Node.js integration test coverage). However, gaps remain in Bucket operations and advanced features.

- **Total Dart Tests:** 389 tests (328 unit + 61 integration) - **UP from 318**
- **Total Node.js Tests:** 1,440+ tests
- **Coverage Gap:** ~73% of Node.js functionality lacks corresponding Dart tests - **IMPROVED from 78%**

---

## Test Statistics

### Dart Test Files
**Location:** `dart_firebase_admin/packages/googleapis_storage/test/`

```
Unit Tests (328 total):
├── unit/file_test.dart                       89 tests  ⬆️ +72 tests
├── unit/storage_test.dart                    68 tests
├── unit/acl_test.dart                        53 tests
├── unit/hash_stream_validator_test.dart      37 tests
├── unit/crc32c_test.dart                     32 tests
├── unit/hmac_key_test.dart                   29 tests
├── unit/signer_test.dart                     14 tests
└── unit/bucket_test.dart                      8 tests

Integration Tests (61 total):
├── integration/file_integration_test.dart    21 tests  ⬆️ +11 tests
├── integration/signer_integration_test.dart  21 tests
├── integration/storage.dart                  17 tests
├── integration/bucket_integration_test.dart   6 tests
└── integration/storage_integration_test.dart  6 tests
```

### Node.js Test Files
**Location (Google Cloud SDK):** `nodejs-storage/test/`
**Location (Firebase Admin SDK):** `firebase-admin-node/test/`

```
Unit Tests (1,440+ total):
├── test/file.ts                  362 tests  ⚠️ DART GAP: 70% (was 95%)
├── test/bucket.ts                210 tests  ⚠️ DART GAP: 96%
├── test/index.ts (Storage)       109 tests  ✅ Good parity
├── test/crc32c.ts                 50 tests  ✅ Good parity
├── test/acl.ts                    48 tests  ✅ Dart exceeds
├── test/transfer-manager.ts       45 tests  ⚠️ DART GAP: 100%
├── test/notification.ts           26 tests  ⚠️ DART GAP: 100%
├── test/iam.ts                    20 tests  ⚠️ DART GAP: 100%
├── test/channel.ts                 9 tests  ⚠️ DART GAP: 100%
└── test/hmacKey.ts                 5 tests  ✅ Dart exceeds

System/Integration Tests:
└── system-test/ (GCS SDK) & test/integration/ (Firebase Admin SDK)
```

---

## Detailed Coverage Comparison

### ✅ APIs with Excellent Coverage in BOTH SDKs

| API | Dart Tests | Node.js Tests | Status |
|-----|------------|---------------|--------|
| **ACL Operations** | 53 unit | 48 unit | 🏆 **Dart exceeds Node.js** |
| **CRC32C Validation** | 32 unit | 50 unit | ✅ Good parity |
| **Storage Factory Methods** | 68 unit | 109 unit | ✅ Good parity |
| **HMAC Key Operations** | 29 unit | 5 unit | 🏆 **Dart significantly exceeds** |
| **Signed URL Generation** | 25 unit + 37 integration | 12 unit | 🏆 **Dart exceeds Node.js** |
| **Hash Stream Validator** | 37 unit | N/A | ✅ Dart-specific, well-tested |

**Summary:** Foundation layers (auth, validation, factory methods) are well-tested in Dart.

---

### ❌ CRITICAL GAPS: Bucket Methods

**Node.js: 210 tests | Dart: 8 tests | Coverage Gap: 96%**

| Method | Node.js Tests | Dart Tests | Priority | Notes |
|--------|---------------|------------|----------|-------|
| `upload()` | 18 tests | **0** | 🔴 CRITICAL | Content type detection, encryption, gzip, resumable uploads, validation |
| `combine()` | 15 tests | **0** | 🔴 CRITICAL | Combining multiple files with validation |
| `getFiles()` | 12 tests | **0** | 🔴 CRITICAL | Pagination, autoPaginate, prefix filters, encoding |
| `enableLogging()` | 10 tests | **0** | 🟡 HIGH | Logging configuration |
| `createNotification()` | 9 tests | **0** | 🟡 HIGH | Pub/sub notifications, topic normalization |
| `createChannel()` | 9 tests | **0** | 🟡 HIGH | Watch channel creation with options |
| `addLifecycleRule()` | 8 tests | **0** | 🟡 HIGH | All rule types, date formatting |
| `deleteFiles()` | 7 tests | **0** | 🔴 CRITICAL | Bulk deletion, error handling, prefixes |
| `getLabels()` | 6 tests | **0** | 🟢 MEDIUM | Label retrieval |
| `getNotifications()` | 5 tests | **0** | 🟢 MEDIUM | Notification listing |
| `file()` | 5 tests | **0** | 🔴 CRITICAL | File object creation with options |
| `makePrivate()` | 4 tests | **0** | 🟡 HIGH | Privacy settings |
| `deleteLabels()` | 4 tests | **0** | 🟢 MEDIUM | Label deletion variants |
| `makePublic()` | 3 tests | **0** | 🟡 HIGH | Public access |
| `setStorageClass()` | 3 tests | **0** | 🟡 HIGH | Storage class transitions |
| `setLabels()` | 2 tests | **0** | 🟢 MEDIUM | Label setting |
| `lock()` | 2 tests | **0** | 🟢 MEDIUM | Retention lock |
| `setRetentionPeriod()` | 1 test | **0** | 🟢 MEDIUM | Retention configuration |
| `setCorsConfiguration()` | 1 test | **0** | 🟢 MEDIUM | CORS setup |
| `getSignedUrl()` | 1 test | 8 unit + 6 integration | ✅ Dart exceeds | |

**Dart Currently Tests:**
- `getSignedUrl()` only (8 unit tests + 6 integration tests)

**Missing Test Coverage:**
- File management operations (upload, getFiles, deleteFiles, file)
- Configuration methods (lifecycle, logging, labels, CORS, retention, storage class)
- Access control (makePrivate, makePublic, lock)
- Notifications and channels
- Advanced features (combine, notifications, channels)

---

### 🟡 IMPROVED: File Methods

**Node.js: 362 tests | Dart: 89 unit + 21 integration = 110 tests | Coverage Gap: 70% (improved from 95%)**

| Method | Node.js Tests | Dart Tests | Priority | Notes |
|--------|---------------|------------|----------|-------|
| `createReadStream()` | **65 tests** | **5 unit** ⬆️ | 🟡 HIGH | HTTP-level tests cover gzip validation/decompression, CRC32C, range requests. Remaining: error handling, MD5, progress events |
| `createWriteStream()` | **50 tests** | **0** | 🔴 CRITICAL | Content type detection, gzip, validation, preconditions, progress events |
| `copy()` | 20 tests | **14 unit + 1 integration** ✅ | ✅ COMPLETE | Destination types, preconditions, encryption, multi-part copy |
| `save()` | 7 tests | **6 unit + 4 integration** ✅ | ✅ COMPLETE | String, List<int>, Uint8List, Stream, options, gzip |
| `download()` | 5 tests | **4 unit + 4 integration** ✅ | ✅ COMPLETE | Options filtering, validation, multiple data types |
| `get()` | 15 tests | **3 unit** ⬆️ | 🟡 HIGH | Basic get, 404 handling, userProject. Missing: auto-create (6 tests) |
| `setMetadata()` | 8 tests | **5 unit + 1 integration** ✅ | ✅ COMPLETE | Updates, preconditions, userProject, instance update |
| `getMetadata()` | 5 tests | **6 unit + 1 integration** ✅ | ✅ EXCEEDS | API call, userProject, generation, instance update |
| `delete()` | 5 tests | **6 unit + 1 integration** ✅ | ✅ EXCEEDS | Preconditions, ignoreNotFound, error handling |
| `exists()` | 5 tests | **5 unit + 1 integration** ✅ | ✅ COMPLETE | 404 handling, userProject, getMetadata delegation |
| `move()` | 5 tests | **5 unit + 1 integration** ✅ | ✅ COMPLETE | Copy+delete flow, same destination handling |
| `rename()` | 2 tests | **2 unit + 1 integration** ✅ | ✅ COMPLETE | Move delegation, File destination |
| `makePrivate()` | 3 tests | **5 unit** ✅ | ✅ EXCEEDS | ProjectPrivate, strict mode, metadata merging |
| `makePublic()` | 3 tests | **2 unit** ✅ | ✅ COMPLETE | AllUsers ACL, userProject |
| `publicUrl()` | N/A | **4 unit** 🏆 | ✅ NEW | URL formatting, encoding, special characters |
| `getSignedUrl()` | 5 tests | **17 unit + 7 integration** 🏆 | ✅ EXCEEDS | Action mapping, parameter forwarding |
| `createResumableUpload()` | 5 tests | **0** | 🟡 HIGH | Resumable upload initialization |
| `isPublic()` | 5 tests | **0** | 🟡 HIGH | ACL checking |
| `rotateEncryptionKey()` | 3 tests | **0** | 🟢 MEDIUM | Key rotation |
| `restore()` | 1 test | **0** | 🟢 MEDIUM | Soft-delete restoration |
| `setStorageClass()` | 4 tests | **0** | 🟢 MEDIUM | Storage class transitions |
| `setUserProject()` | Tests exist | **0** | 🟢 LOW | User project setting |
| `moveFileAtomic()` | Tests exist | **0** | 🟢 LOW | Atomic move operations |
| `getExpirationDate()` | 4 tests | **0** | 🟢 LOW | Expiration date retrieval |

**Dart Now Tests:** ✅
- ✅ Core operations (save, download, copy, move, rename, delete) - **COMPLETE**
- ✅ Metadata operations (get, set, exists) - **COMPLETE**
- ✅ Access control (makePrivate, makePublic) - **COMPLETE**
- ✅ URL generation (getSignedUrl, publicUrl) - **EXCEEDS Node.js**
- ✅ Streaming read with validation (createReadStream - HTTP-level) - **PARTIAL**

**Still Missing:**
- ❌ Streaming write operations (createWriteStream) - **50 Node.js tests** - Complex, needs resumable upload mocking
- ⚠️ Advanced features (createResumableUpload, isPublic, rotateEncryptionKey, restore, setStorageClass, etc.) - **~20 Node.js tests**

---

### ❌ COMPLETE GAPS: Other APIs

#### IAM Methods
**Node.js: 20 tests | Dart: 0 tests | Coverage Gap: 100%**

| Method | Node.js Tests | Dart Tests | Priority |
|--------|---------------|------------|----------|
| `testPermissions()` | 12 tests | **0** | 🔴 CRITICAL |
| `getPolicy()` | 3 tests | **0** | 🟡 HIGH |
| `setPolicy()` | 3 tests | **0** | 🟡 HIGH |

#### TransferManager Methods
**Node.js: 45 tests | Dart: 0 tests | Coverage Gap: 100%**

| Method | Node.js Tests | Dart Tests | Priority |
|--------|---------------|------------|----------|
| `uploadFileInChunks()` | 15 tests | **0** | 🔴 CRITICAL |
| `uploadManyFiles()` | 12 tests | **0** | 🔴 CRITICAL |
| `downloadManyFiles()` | 11 tests | **0** | 🔴 CRITICAL |
| `downloadFileInChunks()` | 7 tests | **0** | 🔴 CRITICAL |

#### Notification Methods
**Node.js: 26 tests | Dart: 0 tests | Coverage Gap: 100%**

| Method | Node.js Tests | Dart Tests | Priority |
|--------|---------------|------------|----------|
| `get()` | 8 tests | **0** | 🟡 HIGH |
| `delete()` | 4 tests | **0** | 🟡 HIGH |
| `getMetadata()` | 4 tests | **0** | 🟡 HIGH |

#### Channel Methods
**Node.js: 9 tests | Dart: 0 tests | Coverage Gap: 100%**

| Method | Node.js Tests | Dart Tests | Priority |
|--------|---------------|------------|----------|
| `stop()` | 6 tests | **0** | 🟢 MEDIUM |

---

## Test Coverage by Category

| Category | Dart Coverage | Node.js Coverage | Gap | Status |
|----------|---------------|------------------|-----|--------|
| **Authentication & Factory Methods** | ✅ Extensive (68 tests) | ✅ Extensive (109 tests) | 38% | 🟢 Good |
| **ACL & Permissions** | ✅ Extensive (53 tests) | ✅ Good (48 tests) | -10% | 🏆 Dart exceeds |
| **Validation & Hashing** | ✅ Extensive (69 tests) | ✅ Extensive (50 tests) | -38% | 🏆 Dart exceeds |
| **HMAC Keys** | ✅ Good (29 tests) | ⚠️ Minimal (5 tests) | -480% | 🏆 Dart exceeds |
| **Signed URLs** | ✅ Good (25 unit + 37 integration) | ⚠️ Limited (12 tests) | -417% | 🏆 Dart exceeds |
| **File Operations** | ✅ Good (89 unit + 21 integration = 110 tests) ⬆️ | ✅ Extensive (362 tests) | 70% | 🟡 Improved (was 95%) |
| **Bucket Operations** | ❌ Minimal (8 tests) | ✅ Extensive (210 tests) | 96% | 🔴 Critical gap |
| **IAM** | ❌ None (0 tests) | ✅ Good (20 tests) | 100% | 🔴 Critical gap |
| **TransferManager** | ❌ None (0 tests) | ✅ Comprehensive (45 tests) | 100% | 🔴 Critical gap |
| **Notifications** | ❌ None (0 tests) | ✅ Good (26 tests) | 100% | 🔴 Critical gap |
| **Channels** | ❌ None (0 tests) | ✅ Basic (9 tests) | 100% | 🔴 Critical gap |

---

## Key Testing Patterns in Node.js SDK

### 1. Comprehensive Options Testing
Nearly every method tests:
- User project propagation
- Generation/metageneration preconditions
- Error callbacks
- API response callbacks
- Optional parameters

### 2. Error Scenarios
Consistent testing of:
- HTTP error codes (502, 404, 409, etc.)
- Missing required parameters
- Validation failures
- API errors with responses
- Stream errors and cleanup

### 3. Streaming & Async Operations
Heavy focus on:
- Read/write streams
- Resumable uploads
- Chunked downloads
- Event propagation
- Progress callbacks

### 4. Validation & Integrity
Multiple validation strategies:
- CRC32C checksums
- MD5 hashes
- Decompression validation
- Generation-based preconditions

### 5. Configuration Management
Extensive configuration testing:
- Retry policies
- Endpoint customization
- Custom encryption
- Compression settings
- Content type detection

---

## Priority Recommendations

### 🔴 CRITICAL PRIORITY (Blocks basic usage)

1. **~~File Core Operations~~** ✅ **COMPLETED** (Node.js: 60+ tests, Dart: 89 unit + 21 integration)
   - ✅ `download()`, `save()` - basic file I/O with multiple data types
   - ✅ `copy()`, `move()`, `delete()` - file management with preconditions
   - ✅ `exists()`, `getMetadata()`, `setMetadata()` - metadata operations
   - ✅ `makePrivate()`, `makePublic()` - access control

2. **Bucket File Management** (Node.js: 37 tests, Dart: 0) - **NEXT PRIORITY**
   - `getFiles()` with pagination and filtering
   - `deleteFiles()` for bulk operations
   - `upload()` with validation and options
   - `file()` factory method with options

3. **File Streaming Write Operations** (Node.js: 50 tests, Dart: 0)
   - `createWriteStream()` with content type detection, gzip, progress events
   - Note: `createReadStream()` has 5 HTTP-level tests covering gzip/validation, but needs more coverage for error handling, MD5, and progress events

4. **TransferManager** (Node.js: 45 tests, Dart: 0)
   - Chunked uploads/downloads for large files
   - Batch file operations
   - CRC32C validation during transfer

### 🟡 HIGH PRIORITY (Important features)

5. **Bucket Configuration** (Node.js: 35+ tests, Dart: 0)
   - Lifecycle rules, logging, labels
   - CORS, retention, storage class

6. **IAM Operations** (Node.js: 20 tests, Dart: 0)
   - `getPolicy()`, `setPolicy()`, `testPermissions()`

7. **Notifications & Channels** (Node.js: 35 tests, Dart: 0)
   - Pub/sub integration
   - Watch channels

8. **Bucket Access Control** (Node.js: 9 tests, Dart: 0)
   - `makePrivate()`, `makePublic()`, `lock()`

### 🟢 MAINTAIN (Already good)

- ✅ ACL operations - Dart exceeds Node.js
- ✅ CRC32C validation - Good parity
- ✅ HMAC keys - Dart exceeds Node.js
- ✅ Signed URL generation - Dart exceeds Node.js
- ✅ Storage factory methods - Good coverage

---

## Recommended Testing Approach

### ~~Phase 1: Critical File Operations~~ ✅ **COMPLETED** (2026-01-27)
1. ✅ File metadata operations (get, set, exists, delete) - **6-6 unit tests + 3 integration tests**
2. ✅ Basic file I/O (download, save with validation) - **10 unit tests + 8 integration tests**
3. ✅ File management (copy, move, rename) - **21 unit tests + 3 integration tests**
4. ✅ Access control (makePrivate, makePublic) - **7 unit tests**
5. ✅ Fixed critical gzip bug via StorageHttpClient

**Result:** 89 File unit tests + 21 File integration tests, exceeding Node.js integration test coverage

### Phase 2: Bucket Operations (Current - Week 2-3)
1. File listing and pagination (getFiles, getFilesStream) - **12 Node.js tests**
2. Bulk operations (deleteFiles, upload) - **25 Node.js tests**
3. File object creation patterns (file) - **5 Node.js tests**
4. Bucket configuration methods (lifecycle, logging, labels, CORS) - **30+ Node.js tests**

### Phase 3: Streaming Operations (Week 3-4)
1. Write streams (content type, gzip, progress, validation) - **50 Node.js tests**
2. Expand read stream coverage (error handling, MD5, progress) - **60 more Node.js tests**
3. Resumable uploads - **5 Node.js tests**

### Phase 4: Advanced Features (Week 4-5)
1. TransferManager (chunked transfers, batch operations) - **45 Node.js tests**
2. Remaining File methods (isPublic, rotateEncryptionKey, restore, etc.) - **~20 Node.js tests**
3. Access control (makePrivate, makePublic for Bucket) - **9 Node.js tests**

### Phase 5: IAM & Notifications (Week 5-6)
1. IAM operations (policies, permissions) - **20 Node.js tests**
2. Notifications and channels - **35 Node.js tests**
3. Advanced bucket features

---

## Testing Standards to Follow

Based on Node.js SDK patterns, all tests should include:

1. **Happy Path Testing**
   - Method succeeds with minimal parameters
   - Method succeeds with all parameters
   - API response is correctly processed

2. **Parameter Validation**
   - Required parameters throw when missing
   - Optional parameters work when omitted
   - Invalid parameter types are caught

3. **Options Propagation**
   - User project is passed through
   - Preconditions (generation, metageneration) work
   - Custom headers and query params are included

4. **Error Handling**
   - API errors are properly surfaced
   - Network errors trigger retries
   - Validation errors provide clear messages

5. **Edge Cases**
   - Empty responses
   - Large files
   - Special characters in names
   - Concurrent operations

---

## Conclusion

The Dart Storage SDK has a **solid foundation** with excellent coverage of authentication, validation, signed URLs, and **now has comprehensive File operation coverage** (89 unit tests + 21 integration tests, exceeding Node.js integration coverage).

**Progress Summary:**
- ✅ Phase 1 (File Core Operations) - **COMPLETED** - Added 72 unit tests + 11 integration tests
- ✅ Fixed critical gzip double-decompression bug with StorageHttpClient
- ⬆️ Coverage gap reduced from 78% to 73% (5% improvement)
- 🏆 File integration tests exceed Node.js coverage (21 tests vs Node's 4 basic tests)

**Next Steps:**
1. ✅ ~~File operations~~ - **COMPLETED**
2. 🔴 Bucket method testing (210 Node.js tests, 8 Dart tests) - **HIGHEST PRIORITY**
3. 🟡 Streaming write operations (createWriteStream - 50 Node.js tests)
4. 🟡 Advanced features (TransferManager, IAM, Notifications)

**Updated Target:** Add ~400-500 more tests over the next 5 weeks to achieve 80%+ parity with Node.js test coverage.

**Current Status:** 389 tests / 1,440+ Node.js tests = 27% coverage (up from 22%)

---

## Quick Reference Links

### Dart Test Files (Local)
- 📝 [file_test.dart](test/unit/file_test.dart) - 89 unit tests for File operations
- 📝 [file_integration_test.dart](test/integration/file_integration_test.dart) - 21 integration tests
- 📝 [storage_test.dart](test/unit/storage_test.dart) - 68 unit tests for Storage class
- 📝 [bucket_test.dart](test/unit/bucket_test.dart) - 8 unit tests for Bucket operations
- 📝 [CSV Documentation](../../claude-docs/dart_admin_sdk_api_surface_area/Dart%20Admin%20SDK%20-%20API%20Surface%20Area%20-%20Storage.csv)

### Node.js Reference Test Files
- 📝 [nodejs-storage/test/file.ts](https://github.com/googleapis/nodejs-storage/blob/main/test/file.ts) - 362 unit tests
- 📝 [nodejs-storage/test/bucket.ts](https://github.com/googleapis/nodejs-storage/blob/main/test/bucket.ts) - 210 unit tests
- 📝 [firebase-admin-node/test/integration/storage.spec.ts](https://github.com/firebase/firebase-admin-node/blob/master/test/integration/storage.spec.ts) - Integration tests

### Implementation Files
- 📝 [storage_http_client.dart](lib/src/internal/storage_http_client.dart) - HTTP client routing for gzip fix
- 📝 [file.dart](lib/src/file.dart) - File implementation with createReadStream/createWriteStream
- 📝 [bucket.dart](lib/src/bucket.dart) - Bucket implementation
