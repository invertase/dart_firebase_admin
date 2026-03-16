// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

/// Status codes for Firestore operations.
///
/// These codes are used to indicate the result of Firestore operations and
/// correspond to standard gRPC status codes.
enum StatusCode {
  ok(0),
  cancelled(1),
  unknown(2),
  invalidArgument(3),
  deadlineExceeded(4),
  notFound(5),
  alreadyExists(6),
  permissionDenied(7),
  resourceExhausted(8),
  failedPrecondition(9),
  aborted(10),
  outOfRange(11),
  unimplemented(12),
  internal(13),
  unavailable(14),
  dataLoss(15),
  unauthenticated(16);

  const StatusCode(this.value);

  static const nonIdempotentRetryCodes = <StatusCode>[];
  static const idempotentRetryCodes = <StatusCode>[
    StatusCode.deadlineExceeded,
    StatusCode.unavailable,
  ];

  static const deadlineExceededResourceExhaustedInternalUnavailable =
      <StatusCode>[
        StatusCode.deadlineExceeded,
        StatusCode.resourceExhausted,
        StatusCode.internal,
        StatusCode.unavailable,
      ];

  static const resourceExhaustedUnavailable = <StatusCode>[
    StatusCode.resourceExhausted,
    StatusCode.unavailable,
  ];

  static const resourceExhaustedAbortedUnavailable = <StatusCode>[
    StatusCode.resourceExhausted,
    StatusCode.aborted,
    StatusCode.unavailable,
  ];

  static const commitRetryCodes = resourceExhaustedUnavailable;

  static const batchGetRetryCodes = <StatusCode>[
    StatusCode.deadlineExceeded,
    StatusCode.resourceExhausted,
    StatusCode.internal,
    StatusCode.unavailable,
  ];

  final int value;
}
