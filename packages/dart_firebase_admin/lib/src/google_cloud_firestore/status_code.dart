import 'package:meta/meta.dart';

@internal
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

  // Imported from https://github.com/googleapis/nodejs-firestore/blob/fba4949be5be8b26720f0fefcf176e549829e382/dev/src/v1/firestore_client_config.json
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

  final int value;
}
