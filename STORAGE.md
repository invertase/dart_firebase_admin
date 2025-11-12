# Storage Namespace Implementation Plan

## Problem Statement

The Firebase Admin SDK for Node.js provides a `storage()` namespace that wraps the `@google-cloud/storage` package. Unlike other Firebase services (auth, messaging, firestore) which are simple REST API wrappers, storage is more complex because:

1. **Full API Surface Exposure**: Firebase Admin's `storage.bucket()` returns a `Bucket` object from `@google-cloud/storage`, and `bucket.file()` returns a `File` object. Users can call **any method** on these objects, meaning we must implement the complete API surface.

2. **Complex Underlying Package**: The `@google-cloud/storage` package is a full-featured client library (~10,000+ lines) with:
   - Resumable uploads with chunking and retry logic
   - Stream-based file operations
   - CRC32C integrity validation
   - Signed URL generation (V2 and V4)
   - Advanced retry strategies with idempotency
   - Transfer managers for parallel operations
   - ACL, IAM, notifications, channels, HMAC keys

3. **Architecture Difference**: In Node.js, `firebase-admin` wraps a separate `@google-cloud/storage` package. For Dart, we'll keep everything in the same `dart_firebase_admin` package to match existing patterns.

## Key Questions Answered

### 1. Should storage be a separate package?
**No.** Keep it in `packages/dart_firebase_admin/lib/src/storage/` to match the existing architecture where all services (auth, messaging, firestore) are in the same package.

### 2. Does the current auth client work for storage?
**Yes, with modifications.** The current `googleapis_auth` implementation is compatible, but we need to:
- Add storage-specific OAuth scopes:
  - `https://www.googleapis.com/auth/cloud-platform`
  - `https://www.googleapis.com/auth/devstorage.full_control`
  - `https://www.googleapis.com/auth/iam` (for HMAC keys)
- Verify the `ServiceAccountCredentials` and `clientViaApplicationDefaultCredentials` work with GCS APIs
- Add storage emulator support (similar to existing auth/firestore emulators)

## Architecture Overview

### Node.js Structure
```
firebase-admin/
  └── src/storage/
      ├── storage.ts          # Thin wrapper around @google-cloud/storage
      ├── index.ts            # getStorage(), getDownloadURL()
      └── utils.ts            # getFirebaseMetadata()

@google-cloud/storage/        # Separate package
  └── src/
      ├── storage.ts          # Main Storage class
      ├── bucket.ts           # Bucket class (~4500 lines)
      ├── file.ts             # File class (~4600 lines)
      ├── resumable-upload.ts  # Resumable upload logic
      ├── signer.ts           # Signed URL generation
      ├── crc32c.ts           # CRC32C validation
      └── nodejs-common/      # Base service infrastructure
```

### Dart Structure (Proposed)
```
packages/dart_firebase_admin/lib/
  ├── storage.dart            # Export file
  └── src/
      └── storage/
          ├── storage.dart              # Storage class
          ├── bucket.dart               # Bucket class
          ├── file.dart                 # File class
          ├── storage_api_request_internal.dart  # HTTP handler
          ├── storage_exception.dart    # Exceptions
          ├── utils.dart                # getDownloadURL(), getFirebaseMetadata()
          ├── resumable_upload.dart     # Resumable uploads
          ├── signer.dart               # Signed URLs
          ├── crc32c.dart               # CRC32C validation
          ├── acl.dart                  # ACL operations
          ├── channel.dart              # Channels
          ├── notification.dart         # Notifications
          ├── hmac_key.dart             # HMAC keys
          └── iam.dart                  # IAM operations
```

## Implementation Plan

### Phase 1: Foundation & Infrastructure

#### 1.1 Base Service Infrastructure
Port the `nodejs-common` patterns:
- **Service class**: Base class for authenticated HTTP requests
  - Handles OAuth token management
  - Request/response processing
  - Error handling and retry logic
  - Interceptor support
- **ServiceObject class**: Base for `Bucket` and `File`
  - Metadata management
  - CRUD operation patterns
  - Request decoration

**Complexity**: Medium. Need to adapt Node.js callback/Promise patterns to Dart Futures/Streams.

#### 1.2 HTTP Request Handler
Create `StorageApiRequestHandler` similar to `FirebaseMessagingRequestHandler`:
- Authenticated requests using app's HTTP client
- Error parsing and exception mapping
- Retry logic for transient errors
- Stream handling for uploads/downloads

**Complexity**: Low. Similar to existing messaging/firestore patterns.

#### 1.3 Authentication & Scopes
- Update `FirebaseAdminApp` to support storage scopes
- Verify `googleapis_auth` works with GCS APIs
- Add storage emulator support (`FIREBASE_STORAGE_EMULATOR_HOST`)

**Complexity**: Low. Mostly configuration.

### Phase 2: Core Storage Classes

#### 2.1 Storage Class
```dart
class Storage {
  Storage(this.app);
  Bucket bucket([String? name]);
  // Static ACL constants
  // Bucket listing (can defer pagination initially)
}
```

**Complexity**: Low. Mostly a thin wrapper around bucket creation.

#### 2.2 Bucket Class
Core methods to implement:
- `file(name, options?)` → `File`
- `exists()` → `Future<bool>`
- `getFiles()` → `Future<List<File>>` (with pagination)
- `deleteFiles()` → `Future<void>`
- `getMetadata()` / `setMetadata()` → Bucket metadata
- ACL operations (`acl.add()`, `acl.delete()`, etc.)

**Complexity**: Medium. Many methods but straightforward REST API calls.

#### 2.3 File Class - Core Methods
Priority 1 (essential):
- `save(data)` → Upload file
- `download()` → Download file as bytes
- `delete()` → Delete file
- `exists()` → Check existence
- `getMetadata()` / `setMetadata()` → File metadata
- `getSignedUrl()` → Generate signed URLs
- `makePublic()` / `makePrivate()` → ACL operations
- `copy()` / `move()` → File operations

**Complexity**: Medium. Mix of simple REST calls and more complex operations (signed URLs).

### Phase 3: Advanced Features

#### 3.1 Stream Operations
- `createReadStream()` → `Stream<List<int>>` for downloads
- `createWriteStream()` → `StreamSink<List<int>>` for uploads

**Complexity**: **High**. 
- Need to convert Node.js streams to Dart streams
- Handle backpressure
- Progress tracking
- Error handling in streams

#### 3.2 Resumable Uploads
- Chunk-based upload logic
- Resume interrupted uploads
- Progress tracking
- CRC32C validation during upload

**Complexity**: **Very High**.
- Complex state management
- Chunk coordination
- Resume logic requires tracking upload state
- Error recovery
- Integration with CRC32C validation

#### 3.3 CRC32C Validation
- CRC32C hashing implementation
- Validation during uploads/downloads
- Integration with resumable uploads

**Complexity**: **High**.
- Need CRC32C library (check if Dart package exists, or port implementation)
- Must match Google's CRC32C algorithm exactly
- Performance critical for large files

#### 3.4 Signed URLs
- V2 signed URLs (HMAC-SHA256)
- V4 signed URLs (more complex, includes headers, query params)
- Cryptographic signing with service account keys

**Complexity**: **High**.
- Cryptographic operations
- Complex URL construction
- V4 signing involves canonical request signing
- Need to handle expiration, access control

#### 3.5 Supporting Features
- Transfer Manager (parallel uploads)
- HMAC Keys
- IAM operations
- Notifications
- Channels

**Complexity**: Medium to High depending on feature.

## Complex Parts Deep Dive

### 1. Resumable Uploads

**Why it's complex:**
- Multi-step process: initiate → upload chunks → finalize
- State management: track uploaded chunks, resume from interruption
- Chunk coordination: ensure chunks uploaded in order, handle failures
- CRC32C integration: validate each chunk and final file

**Implementation approach:**
1. Start with simple upload (non-resumable)
2. Add resumable initiation
3. Add chunk upload logic
4. Add resume capability
5. Add CRC32C validation

**Reference**: `nodejs-storage/src/resumable-upload.ts` (~1350 lines)

### 2. Stream Handling

**Why it's complex:**
- Node.js uses `Readable`/`Writable` streams
- Dart uses `Stream<List<int>>` and `StreamSink<List<int>>`
- Need to handle:
  - Backpressure
  - Progress events
  - Error propagation
  - Stream cancellation

**Implementation approach:**
- Use Dart's `StreamController` for creating streams
- Implement `StreamTransformer` for processing
- Handle `StreamSubscription` cancellation
- Emit progress events via stream or callbacks

### 3. Signed URLs

**Why it's complex:**
- V2: HMAC-SHA256 signing (relatively straightforward)
- V4: More complex canonical request signing:
  - Canonical headers
  - Signed headers list
  - Canonical query string
  - String to sign construction
  - Signature calculation

**Implementation approach:**
- Use `pointycastle` or `crypto` package for HMAC-SHA256
- Carefully implement canonical request construction
- Test against Node.js implementation for compatibility

### 4. CRC32C Validation

**Why it's complex:**
- Must match Google's CRC32C implementation exactly
- Performance critical for large files
- Integration with resumable uploads (validate chunks + final)

**Implementation approach:**
- Check if `crc32c` Dart package exists
- If not, port the algorithm (reference: `nodejs-storage/src/crc32c.ts`)
- Ensure compatibility with Google's implementation

## Recommended Implementation Order

### Incremental Approach

**Week 1-2: Foundation**
1. Create directory structure
2. Implement base Service/ServiceObject patterns
3. Create Storage class with basic bucket() method
4. Add storage scopes to FirebaseAdminApp
5. Basic HTTP request handler

**Week 3-4: Core Operations**
1. Implement Bucket class core methods
2. Implement File class: save(), download(), delete(), exists()
3. Implement metadata operations
4. Basic error handling

**Week 5-6: Essential Features**
1. Implement getSignedUrl() (V2 first, then V4)
2. Implement makePublic()/makePrivate()
3. Implement copy()/move()
4. Add ACL operations

**Week 7-8: Streams & Resumable**
1. Implement createReadStream() and createWriteStream()
2. Implement basic resumable upload (without resume capability)
3. Add resume capability to resumable uploads
4. Add progress tracking

**Week 9-10: Advanced Features**
1. Implement CRC32C validation
2. Integrate CRC32C with uploads
3. Add transfer manager (parallel uploads)
4. Add remaining features (HMAC keys, IAM, etc.)

**Week 11-12: Integration & Testing**
1. Create storage.dart export
2. Integrate with FirebaseAdminApp
3. Implement getStorage() and getDownloadURL() helpers
4. Comprehensive testing
5. Documentation

## Key Implementation Notes

### 1. Callback to Future Conversion
Node.js package uses callbacks extensively. Convert all to Dart Futures:
```typescript
// Node.js
bucket.exists(callback);
bucket.exists().then(...);
```
```dart
// Dart
Future<bool> exists();
```

### 2. Stream Conversion
Node.js streams → Dart streams:
```typescript
// Node.js
file.createReadStream().on('data', ...)
```
```dart
// Dart
Stream<List<int>> createReadStream();
```

### 3. Error Handling
Map GCS API errors to Dart exceptions:
- Create `StorageException` hierarchy
- Map HTTP status codes to error codes
- Parse API error responses

### 4. Testing Strategy
- Start with emulator (if available)
- Unit tests for individual methods
- Integration tests with real GCS buckets
- Test edge cases: large files, network failures, etc.

## Dependencies to Check

1. **CRC32C**: Check if `crc32c` package exists on pub.dev
2. **Crypto**: Verify `pointycastle` or `crypto` package for HMAC-SHA256
3. **Streams**: Use Dart's built-in `dart:async` streams

## References

### Node.js Files to Study
- `nodejs-storage/src/storage.ts` - Storage class initialization
- `nodejs-storage/src/bucket.ts` - Bucket implementation (~4500 lines)
- `nodejs-storage/src/file.ts` - File implementation (~4600 lines)
- `nodejs-storage/src/resumable-upload.ts` - Resumable upload logic
- `nodejs-storage/src/signer.ts` - Signed URL generation
- `nodejs-storage/src/nodejs-common/service.ts` - Base service
- `nodejs-storage/src/nodejs-common/service-object.ts` - Base service object

### Dart SDK Patterns to Follow
- `lib/src/messaging/messaging_api_request_internal.dart` - HTTP request pattern
- `lib/src/app/credential.dart` - Auth setup
- `lib/src/google_cloud_firestore/` - Complex service example with streams

### Firebase Admin Node.js
- `firebase-admin-node/src/storage/storage.ts` - Thin wrapper
- `firebase-admin-node/src/storage/index.ts` - getStorage(), getDownloadURL()
- `firebase-admin-node/src/storage/utils.ts` - getFirebaseMetadata()

## Success Criteria

1. ✅ `Storage` class can be instantiated with `FirebaseAdminApp`
2. ✅ `storage.bucket()` returns `Bucket` instance
3. ✅ `bucket.file()` returns `File` instance
4. ✅ Core file operations work: save, download, delete, exists
5. ✅ Signed URLs can be generated
6. ✅ Stream uploads/downloads work
7. ✅ Resumable uploads work with resume capability
8. ✅ CRC32C validation works
9. ✅ All methods match Node.js API surface
10. ✅ Comprehensive test coverage

## Estimated Effort

- **Total**: ~12 weeks for full implementation
- **Core functionality** (Phases 1-2): ~4 weeks
- **Advanced features** (Phase 3): ~6 weeks
- **Integration & testing** (Phase 4): ~2 weeks

This is a significant undertaking, but can be done incrementally with core functionality first, then advanced features.

