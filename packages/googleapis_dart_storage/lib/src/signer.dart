part of '../googleapis_dart_storage.dart';

enum SignedUrlMethod {
  get('GET'),
  put('PUT'),
  delete('DELETE'),
  post('POST');

  const SignedUrlMethod(this.value);
  final String value;
}

enum SignedUrlVersion {
  v2,
  v4,
}

/// Configuration for generating a signed URL, modeled after the Node SDK's
/// `SignerGetSignedUrlConfig` but simplified for v4 signing.
class SignedUrlConfig {
  final SignedUrlMethod method; // 'GET', 'PUT', etc.
  final DateTime expires;
  final DateTime? accessibleAt;
  final bool? virtualHostedStyle;
  final SignedUrlVersion? version;
  final String? cname;
  final Map<String, String>? extensionHeaders;
  final Map<String, String>? queryParams;
  final String? contentMd5;
  final String? contentType;
  final Uri? host;
  final Uri? signingEndpoint;

  const SignedUrlConfig({
    required this.method,
    required this.expires,
    this.accessibleAt,
    this.virtualHostedStyle,
    this.cname,
    this.version,
    this.extensionHeaders,
    this.queryParams,
    this.contentMd5,
    this.contentType,
    this.host,
    this.signingEndpoint,
  });
}

class _InternalSignedUrlConfig extends SignedUrlConfig {
  final Bucket bucket;
  final File? file;

  _InternalSignedUrlConfig._({
    required this.bucket,
    this.file,
    required super.method,
    required super.expires,
    super.accessibleAt,
    super.virtualHostedStyle,
    super.cname,
    super.version,
    super.extensionHeaders,
    super.queryParams,
    super.contentMd5,
    super.contentType,
    super.host,
    super.signingEndpoint,
  });
}

/// Function used to sign the v4 `blobToSign` string.
///
/// The function must return a **base64-encoded** signature string (as Node's
/// `GoogleAuth.sign` does). In production you should implement this using an
/// RSA‑SHA256 signature with the service account's private key, or by calling
/// the IAM Credentials `signBlob` API.
typedef BlobSigner = Future<String> Function(String blobToSign);

/// Helper for generating signed URLs for GCS, roughly analogous to the Node
/// SDK `URLSigner` but for Dart.
class URLSigner {
  final Bucket bucket;
  final File? file;

  /// [clientEmail] is the service account email used in `X-Goog-Credential`.
  ///
  /// [signBlob] must produce a base64-encoded RSA-SHA256 signature for the
  /// given string. For testing you can use [UrlSigner.insecureHmacSigner],
  /// but for production use RSA or IAM Credentials.
  URLSigner._(this.bucket, this.file);

  getSignedUrl(SignedUrlConfig config) async {
    final expiresInSeconds =
        (config.expires.millisecondsSinceEpoch / 1000).floor();
    final accessibleAtInSeconds =
        (config.accessibleAt?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch / 1000)
            .floor();

    if (expiresInSeconds < accessibleAtInSeconds) {
      // TODO: proper error
      throw ArgumentError(
          'Expiration must be >= accessibleAt (in seconds since epoch).');
    }

    final isVirtualHostedStyle = config.virtualHostedStyle ?? false;
    final customHost = config.cname != null
        ? config.cname!
        : isVirtualHostedStyle
            // TODO: Check bucket id vs name
            // TODO: Why is universeDomain optional?
            ? 'https://${bucket.id}.storage.${bucket.storage.options.universeDomain}'
            : null;

    const secondsToMilliseconds = 1000;
    // Create internal config object with merged values
    final internalConfig = _InternalSignedUrlConfig._(
      method: config.method,
      expires: config.expires,
      accessibleAt: DateTime.fromMillisecondsSinceEpoch(
        secondsToMilliseconds * accessibleAtInSeconds,
      ),
      virtualHostedStyle: config.virtualHostedStyle,
      version: config.version,
      cname: customHost ?? config.cname,
      extensionHeaders: config.extensionHeaders,
      queryParams: config.queryParams,
      contentMd5: config.contentMd5,
      contentType: config.contentType,
      host: config.host,
      signingEndpoint: config.signingEndpoint,
      bucket: bucket,
      file: file,
    );

    final version = config.version ?? SignedUrlVersion.v2;

    final queryParams = await switch (version) {
      SignedUrlVersion.v2 => _getSignedUrlV2(internalConfig),
      SignedUrlVersion.v4 => _getSignedUrlV4(internalConfig),
    };

    // Build the signed URL
    final baseUrl = config.host?.toString() ??
        internalConfig.cname ??
        bucket.storage.config.apiEndpoint;

    final signedUrl = Uri.parse(baseUrl);
    final resourcePath = _getResourcePath(
      internalConfig.cname != null,
      internalConfig.bucket,
      internalConfig.file,
    );

    // Convert query params to query string
    final queryString = queryParams.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}')
        .join('&');

    final finalUrl = signedUrl.replace(
      path: resourcePath,
      query: queryString,
    );

    // TODO: Implement this
    // We need to sign a blob using iam credentials service, which doesn't
    // exist in Dart, so we'd need to port the following somehow:
    // https://github.com/googleapis/google-auth-library-nodejs/blob/e664d9b06ff77f4d04127435b605323cb549c8f2/src/auth/googleauth.ts#L1272-L1320
    throw UnimplementedError('Not implemented');

    return finalUrl.toString();
  }

  Future<Map<String, Object>> _getSignedUrlV2(
      _InternalSignedUrlConfig config) async {
    return {};
  }

  Future<Map<String, Object>> _getSignedUrlV4(
      _InternalSignedUrlConfig config) async {
    return {};
  }

  /// Get the resource path for the signed URL.
  ///
  /// - If [cname] is true: returns `/${file || ''}`
  /// - Else if [file] exists: returns `/${bucket}/${file}`
  /// - Else: returns `/${bucket}`
  // TODO: Check this is correct / encoded
  String _getResourcePath(bool cname, Bucket bucket, File? file) {
    if (cname) {
      return '/${file?.id ?? ''}';
    } else if (file != null) {
      return '/${bucket.id}/${file.id}';
    } else {
      return '/${bucket.id}';
    }
  }

  // /// Convenience signer that uses HMAC-SHA256 for testing/emulator scenarios.
  // ///
  // /// This is **NOT** spec-compliant for GCS v4 signed URLs (which require
  // /// RSA-SHA256), but can be useful in non-production environments.
  // static BlobSigner insecureHmacSigner(String secretKey) {
  //   return (String blobToSign) async {
  //     final keyBytes = utf8.encode(secretKey);
  //     final bytesToSign = utf8.encode(blobToSign);
  //     final sig = crypto.Hmac(
  //       crypto.sha256,
  //       keyBytes,
  //     ).convert(bytesToSign).bytes;
  //     return base64Encode(sig);
  //   };
  // }

  // /// Generate a v4 signed URL for this bucket/object using [config].
  // Future<String> getSignedUrlV4(SignedUrlConfig config) async {
  //   final now = config.accessibleAt ?? DateTime.now().toUtc();
  //   final expirationSeconds = _parseExpires(
  //     config.expires,
  //     current: now,
  //   ).toDouble();
  //   final accessibleAtSeconds = _parseAccessibleAt(
  //     config.accessibleAt ?? now,
  //   ).toDouble();

  //   if (expirationSeconds < accessibleAtSeconds) {
  //     throw ArgumentError(
  //       'Expiration must be >= accessibleAt (in seconds since epoch).',
  //     );
  //   }

  //   const sevenDays = 7 * 24 * 60 * 60;
  //   final expiresPeriodInSeconds = expirationSeconds - accessibleAtSeconds;
  //   if (expiresPeriodInSeconds > sevenDays) {
  //     throw ArgumentError(
  //       'Max allowed expiration is seven days ($sevenDays seconds).',
  //     );
  //   }

  //   // Build headers.
  //   final headers = Map<String, String>.from(config.extensionHeaders);
  //   final hostUri = config.host ?? Uri.parse(config.cname ?? apiEndpoint);
  //   headers['host'] = hostUri.host;
  //   if (config.contentMd5 != null) {
  //     headers['content-md5'] = config.contentMd5!;
  //   }
  //   if (config.contentType != null) {
  //     headers['content-type'] = config.contentType!;
  //   }

  //   // Optional x-goog-content-sha256 header.
  //   String? contentSha256;
  //   final sha256Header = headers['x-goog-content-sha256'];
  //   if (sha256Header != null) {
  //     final isHex = RegExp(r'^[A-Fa-f0-9]{40}$');
  //     if (!isHex.hasMatch(sha256Header)) {
  //       throw ArgumentError(
  //         'The header x-goog-content-sha256 must be a hexadecimal string.',
  //       );
  //     }
  //     contentSha256 = sha256Header;
  //   }

  //   // Canonical headers and signed headers.
  //   final signedHeaders = headers.keys.map((h) => h.toLowerCase()).toList()
  //     ..sort();
  //   final signedHeadersStr = signedHeaders.join(';');
  //   final canonicalHeaders = _canonicalHeaders(headers);

  //   // Timestamps and credential scope.
  //   final datestamp = _formatAsUtcIsoDate(now); // yyyyMMdd
  //   final dateTimeIso = _formatAsUtcIsoDateTime(now); // yyyyMMdd'T'HHmmss'Z'
  //   final credentialScope = '$datestamp/auto/storage/goog4_request';
  //   final credential = '$clientEmail/$credentialScope';

  //   // Query params.
  //   final query = <String, String>{
  //     'X-Goog-Algorithm': 'GOOG4-RSA-SHA256',
  //     'X-Goog-Credential': credential,
  //     'X-Goog-Date': dateTimeIso,
  //     'X-Goog-Expires': expiresPeriodInSeconds.toInt().toString(),
  //     'X-Goog-SignedHeaders': signedHeadersStr,
  //     ...config.queryParams,
  //   };
  //   final canonicalQuery = _canonicalQueryParams(query);

  //   // Resource path.
  //   final path = _resourcePath(
  //     config.virtualHostedStyle || config.cname != null,
  //     bucketName,
  //     objectName,
  //   );

  //   // Canonical request.
  //   final canonicalRequest = [
  //     config.method,
  //     path,
  //     canonicalQuery,
  //     canonicalHeaders,
  //     signedHeadersStr,
  //     contentSha256 ?? 'UNSIGNED-PAYLOAD',
  //   ].join('\n');

  //   final canonicalRequestHash =
  //       crypto.sha256.convert(utf8.encode(canonicalRequest)).toString(); // hex

  //   // String to sign.
  //   final blobToSign = [
  //     'GOOG4-RSA-SHA256',
  //     dateTimeIso,
  //     credentialScope,
  //     canonicalRequestHash,
  //   ].join('\n');

  //   // Sign via the provided signer (must return base64 signature).
  //   final base64Signature = await _signBlob(blobToSign);
  //   final signatureHex = base64Decode(
  //     base64Signature,
  //   ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  //   final finalQuery = Map<String, String>.from(query)
  //     ..['X-Goog-Signature'] = signatureHex;

  //   final signedUrl = Uri(
  //     scheme: hostUri.scheme,
  //     host: hostUri.host,
  //     port: hostUri.hasPort ? hostUri.port : null,
  //     path: path,
  //     query: _canonicalQueryParams(finalQuery),
  //   );

  //   return signedUrl.toString();
  // }

  // // --- Helpers --------------------------------------------------------------

  // int _parseExpires(DateTime expires, {DateTime? current}) {
  //   final currentTime =
  //       (current ?? DateTime.now().toUtc()).millisecondsSinceEpoch;
  //   final expiresMs = expires.toUtc().millisecondsSinceEpoch;
  //   if (expiresMs.isNaN) {
  //     throw ArgumentError('Invalid expiration date.');
  //   }
  //   if (expiresMs < currentTime) {
  //     throw ArgumentError('Expiration date must be in the future.');
  //   }
  //   return (expiresMs / 1000).floor();
  // }

  // int _parseAccessibleAt(DateTime accessibleAt) {
  //   final ms = accessibleAt.toUtc().millisecondsSinceEpoch;
  //   if (ms.isNaN) {
  //     throw ArgumentError('Invalid accessibleAt date.');
  //   }
  //   return (ms / 1000).floor();
  // }

  // String _canonicalHeaders(Map<String, String> headers) {
  //   final entries = headers.entries
  //       .map((e) => MapEntry(e.key.toLowerCase(), e.value))
  //       .toList()
  //     ..sort((a, b) => a.key.compareTo(b.key));

  //   return entries.where((e) => e.value.isNotEmpty).map((e) {
  //     final canonicalValue = e.value.trim().replaceAll(RegExp(r'\s{2,}'), ' ');
  //     return '${e.key}:$canonicalValue\n';
  //   }).join();
  // }

  // String _canonicalQueryParams(Map<String, String> query) {
  //   final entries = query.entries
  //       .map(
  //         (e) => MapEntry(
  //           Uri.encodeQueryComponent(e.key),
  //           Uri.encodeQueryComponent(e.value),
  //         ),
  //       )
  //       .toList()
  //     ..sort((a, b) => a.key.compareTo(b.key));

  //   return entries.map((e) => '${e.key}=${e.value}').join('&');
  // }

  // String _resourcePath(bool cname, String bucket, String? object) {
  //   if (cname) {
  //     return '/${object ?? ''}';
  //   } else if (object != null && object.isNotEmpty) {
  //     return '/$bucket/${Uri.encodeComponent(object)}';
  //   } else {
  //     return '/$bucket';
  //   }
  // }

  // String _formatAsUtcIsoDate(DateTime dt) {
  //   final d = dt.toUtc();
  //   return '${d.year.toString().padLeft(4, '0')}'
  //       '${d.month.toString().padLeft(2, '0')}'
  //       '${d.day.toString().padLeft(2, '0')}';
  // }

  // String _formatAsUtcIsoDateTime(DateTime dt) {
  //   final d = dt.toUtc();
  //   return '${_formatAsUtcIsoDate(d)}'
  //       'T'
  //       '${d.hour.toString().padLeft(2, '0')}'
  //       '${d.minute.toString().padLeft(2, '0')}'
  //       '${d.second.toString().padLeft(2, '0')}Z';
  // }
}
