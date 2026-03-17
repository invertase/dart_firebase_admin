// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:test/test.dart';
import 'helpers.dart';

void main() {
  group(
    'QueryPartition Tests [Production]',
    () {
      late Firestore firestore;
      final collectionGroupsToCleanup = <String>{};

      setUp(() async {
        firestore = Firestore(
          settings: const Settings(projectId: 'dart-firebase-admin'),
        );
      });

      tearDown(() async {
        // Clean up all test collection group documents
        try {
          for (final collectionGroupId in collectionGroupsToCleanup) {
            try {
              final snapshot = await firestore
                  .collectionGroup(collectionGroupId)
                  .get();

              // Delete all documents in this collection group
              // Use a batch for more efficient deletion
              if (snapshot.docs.isNotEmpty) {
                final batch = firestore.batch();
                for (final doc in snapshot.docs) {
                  batch.delete(doc.ref);
                }
                await batch.commit();

                // ignore: avoid_print
                print(
                  'Cleaned up ${snapshot.docs.length} documents from collection group: $collectionGroupId',
                );
              }
            } catch (e) {
              // Log error but continue cleanup of other collection groups
              // ignore: avoid_print
              print(
                'Error cleaning up collection group $collectionGroupId: $e',
              );
            }
          }
        } finally {
          collectionGroupsToCleanup.clear();

          // Always terminate the Firestore instance
          await firestore.terminate();
        }
      });

      /// Helper to collect all partitions into a list
      Future<List<QueryPartition<T>>> getPartitions<T extends Object?>(
        CollectionGroup<T> collectionGroup,
        int desiredPartitionCount,
      ) async {
        final partitions = <QueryPartition<T>>[];
        await collectionGroup
            .getPartitions(desiredPartitionCount)
            .forEach(partitions.add);
        return partitions;
      }

      // test(
      //   'does not issue RPC if only a single partition is requested',
      //   () async {
      //     final collectionGroup = firestore.collectionGroup('single-partition');
      //
      //     final partitions = await getPartitions(collectionGroup, 1);
      //
      //     expect(partitions, hasLength(1));
      //     expect(partitions[0].startAt, isNull);
      //     expect(partitions[0].endBefore, isNull);
      //   },
      // );

      test('empty partition query', () async {
        await runZoned(
          () async {
            const desiredPartitionCount = 3;

            // Use a unique collection group ID that has no documents
            final collectionGroupId =
                'empty-${DateTime.now().millisecondsSinceEpoch}';
            final collectionGroup = firestore.collectionGroup(
              collectionGroupId,
            );

            final partitions = await getPartitions(
              collectionGroup,
              desiredPartitionCount,
            );

            expect(partitions, hasLength(1));
            expect(partitions[0].startAt, isNull);
            expect(partitions[0].endBefore, isNull);
          },
          zoneValues: {
            envSymbol: <String, String>{}, // Clear FIRESTORE_EMULATOR_HOST
          },
        );
      });

      test('partition query', () async {
        await runZoned(() async {
          const documentCount = 20;
          const desiredPartitionCount = 3;

          // Create documents in a collection group
          final collectionGroupId =
              'partition-test-${DateTime.now().millisecondsSinceEpoch}';
          collectionGroupsToCleanup.add(collectionGroupId);

          // Create documents in different parent collections
          for (var i = 0; i < documentCount; i++) {
            final parentPath = 'parent${i % 5}'; // Create 5 different parents
            await firestore.doc('$parentPath/doc/$collectionGroupId/doc$i').set(
              {'value': i},
            );
          }

          final collectionGroup = firestore.collectionGroup(collectionGroupId);
          final partitions = await getPartitions(
            collectionGroup,
            desiredPartitionCount,
          );

          // Verify partition structure
          expect(partitions.length, lessThanOrEqualTo(desiredPartitionCount));
          expect(partitions[0].startAt, isNull);

          for (var i = 0; i < partitions.length - 1; i++) {
            // Each partition's endBefore should equal the next partition's startAt
            expect(partitions[i].endBefore, isNotNull);
            expect(partitions[i + 1].startAt, isNotNull);
          }

          expect(partitions.last.endBefore, isNull);

          // Validate that we can use the partitions to read the original documents
          final allDocuments = <QueryDocumentSnapshot<Map<String, Object?>>>[];
          for (final partition in partitions) {
            final snapshot = await partition.toQuery().get();
            allDocuments.addAll(snapshot.docs);
          }

          expect(allDocuments, hasLength(documentCount));
        }, zoneValues: {envSymbol: <String, String>{}});
      });

      test('partition query with manual cursors', () async {
        await runZoned(() async {
          const documentCount = 15;
          const desiredPartitionCount = 4;

          // Create documents in a collection group
          final collectionGroupId =
              'manual-cursors-${DateTime.now().millisecondsSinceEpoch}';
          collectionGroupsToCleanup.add(collectionGroupId);

          for (var i = 0; i < documentCount; i++) {
            final parentPath = 'parent${i % 3}';
            await firestore.doc('$parentPath/doc/$collectionGroupId/doc$i').set(
              {'index': i},
            );
          }

          final collectionGroup = firestore.collectionGroup(collectionGroupId);
          final partitions = await getPartitions(
            collectionGroup,
            desiredPartitionCount,
          );

          // Use manual cursors to query each partition
          final allDocuments = <QueryDocumentSnapshot<Map<String, Object?>>>[];
          for (final partition in partitions) {
            var partitionedQuery = collectionGroup.orderBy(
              FieldPath.documentId,
            );

            if (partition.startAt != null) {
              partitionedQuery = partitionedQuery.startAt(partition.startAt!);
            }

            if (partition.endBefore != null) {
              partitionedQuery = partitionedQuery.endBefore(
                partition.endBefore!,
              );
            }

            final snapshot = await partitionedQuery.get();
            allDocuments.addAll(snapshot.docs);
          }

          expect(allDocuments, hasLength(documentCount));
        }, zoneValues: {envSymbol: <String, String>{}});
      });

      test('partition query with converter', () async {
        await runZoned(() async {
          const documentCount = 12;
          const desiredPartitionCount = 3;

          // Create documents
          final collectionGroupId =
              'converter-test-${DateTime.now().millisecondsSinceEpoch}';
          collectionGroupsToCleanup.add(collectionGroupId);

          for (var i = 0; i < documentCount; i++) {
            await firestore.doc('parent/doc/$collectionGroupId/doc$i').set({
              'title': 'Post $i',
              'author': 'Author $i',
            });
          }

          // Define a converter
          final converter = FirestoreConverter<Post>(
            fromFirestore: (snapshot) {
              final data = snapshot.data()!;
              return Post(
                title: data['title']! as String,
                author: data['author']! as String,
              );
            },
            toFirestore: (post) => {'title': post.title, 'author': post.author},
          );

          final collectionGroupWithConverter = firestore
              .collectionGroup(collectionGroupId)
              .withConverter(
                fromFirestore: converter.fromFirestore,
                toFirestore: converter.toFirestore,
              );

          final partitions = await getPartitions(
            collectionGroupWithConverter,
            desiredPartitionCount,
          );

          // Verify all documents can be retrieved with converter
          final allDocuments = <QueryDocumentSnapshot<Post>>[];
          for (final partition in partitions) {
            final snapshot = await partition.toQuery().get();
            allDocuments.addAll(snapshot.docs);
          }

          expect(allDocuments, hasLength(documentCount));

          // Verify converter was applied
          for (final doc in allDocuments) {
            expect(doc.data(), isA<Post>());
            expect(doc.data().title, startsWith('Post '));
            expect(doc.data().author, startsWith('Author '));
          }
        }, zoneValues: {envSymbol: <String, String>{}});
      });

      test('requests one less than desired partitions', () async {
        await runZoned(() async {
          const documentCount = 30;
          const desiredPartitionCount = 5;

          // Create enough documents to get multiple partitions
          final collectionGroupId =
              'partition-count-${DateTime.now().millisecondsSinceEpoch}';
          collectionGroupsToCleanup.add(collectionGroupId);

          for (var i = 0; i < documentCount; i++) {
            await firestore
                .doc(
                  'parent/doc/$collectionGroupId/doc${i.toString().padLeft(3, '0')}',
                )
                .set({'value': i});
          }

          final collectionGroup = firestore.collectionGroup(collectionGroupId);
          final partitions = await getPartitions(
            collectionGroup,
            desiredPartitionCount,
          );

          // The actual number of partitions may be fewer than requested
          expect(partitions.length, greaterThan(0));
          expect(partitions.length, lessThanOrEqualTo(desiredPartitionCount));

          // Verify partition continuity
          expect(partitions[0].startAt, isNull);
          for (var i = 0; i < partitions.length - 1; i++) {
            expect(partitions[i].endBefore, isNotNull);
            expect(partitions[i + 1].startAt, isNotNull);
          }
          expect(partitions.last.endBefore, isNull);
        }, zoneValues: {envSymbol: <String, String>{}});
      });

      test(
        'partitions are sorted',
        timeout: const Timeout(Duration(minutes: 3)),
        () async {
          await runZoned(() async {
            const documentCount = 25;
            const desiredPartitionCount = 4;

            // Create documents in a collection group
            final collectionGroupId =
                'sorted-partitions-${DateTime.now().millisecondsSinceEpoch}';
            collectionGroupsToCleanup.add(collectionGroupId);

            // Create documents across multiple parent collections
            for (var i = 0; i < documentCount; i++) {
              final parentPath = 'parent${i % 4}';
              await firestore
                  .doc(
                    '$parentPath/doc/$collectionGroupId/doc${i.toString().padLeft(3, '0')}',
                  )
                  .set({'value': i});
            }

            final collectionGroup = firestore.collectionGroup(
              collectionGroupId,
            );
            final partitions = await getPartitions(
              collectionGroup,
              desiredPartitionCount,
            );

            // Verify partitions are properly sorted
            // Each partition's endBefore should be less than or equal to next partition's startAt
            for (var i = 0; i < partitions.length - 1; i++) {
              final currentEnd = partitions[i].endBefore;
              final nextStart = partitions[i + 1].startAt;

              if (currentEnd != null && nextStart != null) {
                // Verify the partition boundaries are in order
                // The endBefore of partition i should equal the startAt of partition i+1
                expect(
                  currentEnd,
                  equals(nextStart),
                  reason:
                      'Partition $i endBefore should equal partition ${i + 1} startAt',
                );
              }
            }

            // Verify all documents can be read across sorted partitions
            final allDocuments =
                <QueryDocumentSnapshot<Map<String, Object?>>>[];
            for (final partition in partitions) {
              final snapshot = await partition.toQuery().get();
              allDocuments.addAll(snapshot.docs);
            }

            expect(
              allDocuments,
              hasLength(documentCount),
              reason: 'Should retrieve all documents across partitions',
            );

            // Verify no duplicates (each document appears exactly once)
            final docIds = allDocuments.map((doc) => doc.id).toSet();
            expect(
              docIds,
              hasLength(documentCount),
              reason: 'No duplicate documents across partitions',
            );
          }, zoneValues: {envSymbol: <String, String>{}});
        },
      );

      test(
        'handles paginated partition responses with large partition counts',
        timeout: const Timeout(Duration(minutes: 3)),
        () async {
          await runZoned(() async {
            // Create enough documents to potentially trigger pagination
            // The API typically paginates around 128-256 partitions
            const documentCount = 500;
            const desiredPartitionCount = 300;

            final collectionGroupId =
                'pagination-test-${DateTime.now().millisecondsSinceEpoch}';
            collectionGroupsToCleanup.add(collectionGroupId);

            // Create documents across multiple parents to maximize partition points
            for (var i = 0; i < documentCount; i++) {
              final parentPath = 'parent${i % 10}';
              await firestore
                  .doc(
                    '$parentPath/doc/$collectionGroupId/doc${i.toString().padLeft(4, '0')}',
                  )
                  .set({'value': i});
            }

            final collectionGroup = firestore.collectionGroup(
              collectionGroupId,
            );
            final partitions = await getPartitions(
              collectionGroup,
              desiredPartitionCount,
            );

            // Verify we got partitions
            expect(partitions.length, greaterThan(0));
            expect(partitions.length, lessThanOrEqualTo(desiredPartitionCount));

            // Verify partition structure
            expect(
              partitions[0].startAt,
              isNull,
              reason: 'First partition starts at beginning',
            );
            expect(
              partitions.last.endBefore,
              isNull,
              reason: 'Last partition ends at end',
            );

            // Verify all partitions are continuous (no gaps)
            for (var i = 0; i < partitions.length - 1; i++) {
              expect(partitions[i].endBefore, isNotNull);
              expect(partitions[i + 1].startAt, isNotNull);
              expect(
                partitions[i].endBefore,
                equals(partitions[i + 1].startAt),
                reason:
                    'Partition $i endBefore must equal partition ${i + 1} startAt',
              );
            }

            // Verify all documents can be retrieved (no data loss)
            final allDocuments =
                <QueryDocumentSnapshot<Map<String, Object?>>>[];
            for (final partition in partitions) {
              final snapshot = await partition.toQuery().get();
              allDocuments.addAll(snapshot.docs);
            }

            expect(
              allDocuments,
              hasLength(documentCount),
              reason: 'All documents must be retrievable across partitions',
            );

            // Verify no duplicates
            final docIds = allDocuments.map((doc) => doc.id).toSet();
            expect(
              docIds,
              hasLength(documentCount),
              reason: 'No document should appear in multiple partitions',
            );
          }, zoneValues: {envSymbol: <String, String>{}});
        },
      );
    },
    skip: hasProdEnv
        ? false
        : 'Partition queries require production Firestore (not supported in emulator)',
  );
}

/// Test class for converter tests
class Post {
  Post({required this.title, required this.author});

  final String title;
  final String author;
}

/// Firestore converter for testing
class FirestoreConverter<T> {
  FirestoreConverter({required this.fromFirestore, required this.toFirestore});

  final T Function(DocumentSnapshot<Map<String, Object?>>) fromFirestore;
  final Map<String, Object?> Function(T) toFirestore;
}
