// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

part of '../firestore.dart';

/// Distance measures for vector queries.
enum DistanceMeasure {
  /// Euclidean distance - straight-line distance between vectors.
  /// Good for spatial data.
  euclidean('EUCLIDEAN'),

  /// Cosine distance - measures the angle between vectors.
  /// Good for text embeddings where magnitude doesn't matter.
  cosine('COSINE'),

  /// Dot product distance - inner product of vectors.
  /// Good for normalized vectors.
  dotProduct('DOT_PRODUCT');

  const DistanceMeasure(this.value);

  final String value;
}

/// Options that configure the behavior of a vector query created by [Query.findNearest].
@immutable
class VectorQueryOptions {
  /// Creates options for a vector query.
  ///
  /// - [vectorField]: A string or [FieldPath] specifying the vector field to search on.
  /// - [queryVector]: The [VectorValue] or list of doubles used to measure distance from `vectorField` values.
  /// - [limit]: Maximum number of documents to return (required, max 1000).
  /// - [distanceMeasure]: The type of distance calculation to use.
  /// - [distanceResultField]: Optional field name to store the computed distance in results.
  /// - [distanceThreshold]: Optional threshold - only return documents within this distance.
  const VectorQueryOptions({
    required this.vectorField,
    required this.queryVector,
    required this.limit,
    required this.distanceMeasure,
    this.distanceResultField,
    this.distanceThreshold,
  });

  /// A string or [FieldPath] specifying the vector field to search on.
  final Object vectorField; // String or FieldPath

  /// The [VectorValue] or list of doubles used to measure the distance from [vectorField] values in the documents.
  final Object queryVector; // VectorValue or List<double>

  /// Specifies the upper bound of documents to return.
  /// Must be a positive integer with a maximum value of 1000.
  final int limit;

  /// Specifies what type of distance is calculated when performing the query.
  final DistanceMeasure distanceMeasure;

  /// Optionally specifies the name of a field that will be set on each returned DocumentSnapshot,
  /// which will contain the computed distance for the document.
  final Object? distanceResultField; // String or FieldPath or null

  /// Specifies a threshold for which no less similar documents will be returned.
  ///
  /// The behavior of the specified [distanceMeasure] will affect the meaning of the distance threshold:
  ///  - For [DistanceMeasure.euclidean]: SELECT docs WHERE euclidean_distance <= distanceThreshold
  ///  - For [DistanceMeasure.cosine]: SELECT docs WHERE cosine_distance <= distanceThreshold
  ///  - For [DistanceMeasure.dotProduct]: SELECT docs WHERE dot_product_distance >= distanceThreshold
  final double? distanceThreshold;

  @override
  bool operator ==(Object other) {
    return other is VectorQueryOptions &&
        vectorField == other.vectorField &&
        queryVector == other.queryVector &&
        limit == other.limit &&
        distanceMeasure == other.distanceMeasure &&
        distanceResultField == other.distanceResultField &&
        distanceThreshold == other.distanceThreshold;
  }

  @override
  int get hashCode => Object.hash(
    vectorField,
    queryVector,
    limit,
    distanceMeasure,
    distanceResultField,
    distanceThreshold,
  );
}
