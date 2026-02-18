part of '../googleapis_storage.dart';

class _InternalSignedUrlConfig {
  final SignedUrlConfig signedConfig;
  final Bucket bucket;
  final BucketFile? file;
  final int expiration;
  final DateTime accessibleAt;
  final String? cname;

  _InternalSignedUrlConfig({
    required this.signedConfig,
    required this.bucket,
    this.file,
    required this.expiration,
    required this.accessibleAt,
    this.cname,
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
  final BucketFile? file;

  /// [clientEmail] is the service account email used in `X-Goog-Credential`.
  ///
  /// [signBlob] must produce a base64-encoded RSA-SHA256 signature for the
  /// given string. For testing you can use [UrlSigner.insecureHmacSigner],
  /// but for production use RSA or IAM Credentials.
  URLSigner._(this.bucket, this.file);

  @visibleForTesting
  URLSigner.internal(this.bucket, this.file);

  Future<String> getSignedUrl(SignedUrlConfig config) async {
    final expiresInSeconds = (config.expires.millisecondsSinceEpoch / 1000)
        .floor();
    final accessibleAtInSeconds =
        ((config.accessibleAt?.millisecondsSinceEpoch ??
                    DateTime.now().millisecondsSinceEpoch) /
                1000)
            .floor();

    if (expiresInSeconds < accessibleAtInSeconds) {
      throw ArgumentError(
        'Expiration must be >= accessibleAt (in seconds since epoch).',
      );
    }

    final isVirtualHostedStyle = config.virtualHostedStyle ?? false;
    String? customHost;
    if (config.cname != null) {
      customHost = config.cname!;
    } else if (isVirtualHostedStyle) {
      final universeDomain =
          bucket.storage.options.universeDomain ?? 'googleapis.com';
      customHost = 'https://${bucket.id}.storage.$universeDomain';
    }

    const secondsToMilliseconds = 1000;
    // Create internal config object with merged values
    final internalConfig = _InternalSignedUrlConfig(
      signedConfig: config,
      bucket: bucket,
      file: file,
      expiration: expiresInSeconds,
      accessibleAt: DateTime.fromMillisecondsSinceEpoch(
        secondsToMilliseconds * accessibleAtInSeconds,
      ),
      cname: customHost,
    );

    final version = config.version ?? SignedUrlVersion.v2;

    final queryParams = await switch (version) {
      SignedUrlVersion.v2 => _getSignedUrlV2(internalConfig),
      SignedUrlVersion.v4 => _getSignedUrlV4(internalConfig),
    };

    // Merge with additional query params
    final allQueryParams = {...queryParams, ...?config.queryParams};

    // Build the signed URL
    final baseUrl =
        config.host?.toString() ??
        customHost ??
        bucket.storage.config.apiEndpoint;

    final signedUrl = Uri.parse(baseUrl);
    final resourcePath = _getResourcePath(
      customHost != null,
      internalConfig.bucket,
      internalConfig.file,
    );

    // Convert query params to query string
    final queryString = allQueryParams.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}',
        )
        .join('&');

    final finalUrl = signedUrl.replace(path: resourcePath, query: queryString);

    return finalUrl.toString();
  }

  Future<Map<String, Object>> _getSignedUrlV2(
    _InternalSignedUrlConfig config,
  ) async {
    final canonicalHeadersString = _getCanonicalHeaders(
      config.signedConfig.extensionHeaders ?? {},
    );
    final resourcePath = _getResourcePath(false, config.bucket, config.file);

    final blobToSign = [
      config.signedConfig.method.value,
      config.signedConfig.contentMd5 ?? '',
      config.signedConfig.contentType ?? '',
      config.expiration.toString(),
      canonicalHeadersString + resourcePath,
    ].join('\n');

    final authClient = await bucket.storage.authClient;
    final signature = await authClient.sign(
      utf8.encode(blobToSign),
      serviceAccountCredentials:
          bucket.storage.options.credential?.serviceAccountCredentials,
      endpoint: config.signedConfig.signingEndpoint?.toString(),
    );

    final clientEmail =
        bucket.storage.options.credential?.serviceAccountCredentials?.email ??
        await authClient.getServiceAccountEmail();

    return {
      'GoogleAccessId': clientEmail,
      'Expires': config.expiration.toString(),
      'Signature': signature,
    };
  }

  Future<Map<String, Object>> _getSignedUrlV4(
    _InternalSignedUrlConfig config,
  ) async {
    const sevenDays = 7 * 24 * 60 * 60;
    final millisecondsToSeconds = 1.0 / 1000.0;
    final expiresPeriodInSeconds =
        config.expiration -
        config.accessibleAt.millisecondsSinceEpoch * millisecondsToSeconds;

    // V4 limit expiration to be 7 days maximum
    if (expiresPeriodInSeconds > sevenDays) {
      throw ArgumentError(
        'Max allowed expiration is seven days ($sevenDays seconds).',
      );
    }

    final extensionHeaders = <String, String>{
      ...?config.signedConfig.extensionHeaders,
    };

    final fqdn = Uri.parse(
      config.signedConfig.host?.toString() ??
          config.cname ??
          bucket.storage.config.apiEndpoint,
    );
    extensionHeaders['host'] = fqdn.host;

    if (config.signedConfig.contentMd5 != null) {
      extensionHeaders['content-md5'] = config.signedConfig.contentMd5!;
    }
    if (config.signedConfig.contentType != null) {
      extensionHeaders['content-type'] = config.signedConfig.contentType!;
    }

    String? contentSha256;
    final sha256Header = extensionHeaders['x-goog-content-sha256'];
    if (sha256Header != null) {
      if (!RegExp(r'^[A-Fa-f0-9]{64}$').hasMatch(sha256Header)) {
        throw ArgumentError(
          'The header X-Goog-Content-SHA256 must be a hexadecimal string.',
        );
      }
      contentSha256 = sha256Header;
    }

    final signedHeaders =
        extensionHeaders.keys.map((h) => h.toLowerCase()).toList()..sort();
    final signedHeadersString = signedHeaders.join(';');

    final extensionHeadersString = _getCanonicalHeaders(extensionHeaders);
    final datestamp = _formatAsUTCISO(config.accessibleAt);
    final credentialScope = '$datestamp/auto/storage/goog4_request';

    final authClient = await bucket.storage.authClient;

    final clientEmail =
        bucket.storage.options.credential?.serviceAccountCredentials?.email ??
        await authClient.getServiceAccountEmail();

    final credentialString = '$clientEmail/$credentialScope';
    final dateISO = _formatAsUTCISO(config.accessibleAt, includeTime: true);

    final queryParams = <String, String>{
      'X-Goog-Algorithm': 'GOOG4-RSA-SHA256',
      'X-Goog-Credential': credentialString,
      'X-Goog-Date': dateISO,
      'X-Goog-Expires': expiresPeriodInSeconds.toInt().toString(),
      'X-Goog-SignedHeaders': signedHeadersString,
      ...?config.signedConfig.queryParams,
    };

    final canonicalQueryParams = _getCanonicalQueryParams(queryParams);
    final canonicalRequest = _getCanonicalRequest(
      config.signedConfig.method.value,
      _getResourcePath(config.cname != null, config.bucket, config.file),
      canonicalQueryParams,
      extensionHeadersString,
      signedHeadersString,
      contentSha256,
    );

    final hash = crypto.sha256
        .convert(utf8.encode(canonicalRequest))
        .toString();

    final blobToSign = [
      'GOOG4-RSA-SHA256',
      dateISO,
      credentialScope,
      hash,
    ].join('\n');

    final signature = await authClient.sign(
      utf8.encode(blobToSign),
      serviceAccountCredentials:
          bucket.storage.options.credential?.serviceAccountCredentials,
      endpoint: config.signedConfig.signingEndpoint?.toString(),
    );

    // Convert base64 signature to hex
    final signatureBytes = base64Decode(signature);
    final signatureHex = signatureBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    return {...queryParams, 'X-Goog-Signature': signatureHex};
  }

  /// Get the resource path for the signed URL.
  ///
  /// - If [cname] is true: returns `/${file || ''}`
  /// - Else if [file] exists: returns `/${bucket}/${file}`
  /// - Else: returns `/${bucket}`
  String _getResourcePath(bool cname, Bucket bucket, BucketFile? file) {
    if (cname) {
      return '/${file?.id ?? ''}';
    } else if (file != null) {
      return '/${bucket.id}/${file.id}';
    } else {
      return '/${bucket.id}';
    }
  }

  /// Create canonical headers for signing.
  ///
  /// The canonical headers for v4-signing demands header names are
  /// first lowercased, followed by sorting the header names.
  /// Then, construct the canonical headers part of the request:
  ///  `<lowercasedHeaderName>` + ":" + Trim(`<value>`) + "\n"
  String _getCanonicalHeaders(Map<String, String> headers) {
    // Sort headers by their lowercased names
    final sortedHeaders =
        headers.entries
            .map((e) => MapEntry(e.key.toLowerCase(), e.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return sortedHeaders.where((e) => e.value.isNotEmpty).map((e) {
      // Trim leading and trailing spaces.
      // Convert sequential (2+) spaces into a single space
      final canonicalValue = e.value.trim().replaceAll(RegExp(r'\s{2,}'), ' ');
      return '${e.key}:$canonicalValue\n';
    }).join();
  }

  /// Create canonical request for V4 signing.
  String _getCanonicalRequest(
    String method,
    String path,
    String query,
    String headers,
    String signedHeaders,
    String? contentSha256,
  ) {
    return [
      method,
      path,
      query,
      headers,
      signedHeaders,
      contentSha256 ?? 'UNSIGNED-PAYLOAD',
    ].join('\n');
  }

  /// Get canonical query params string.
  String _getCanonicalQueryParams(Map<String, String> query) {
    final pairs = query.entries
        .map(
          (e) => [
            Uri.encodeQueryComponent(e.key),
            Uri.encodeQueryComponent(e.value),
          ],
        )
        .toList();

    pairs.sort((a, b) => a[0].compareTo(b[0]));

    return pairs.map((pair) => '${pair[0]}=${pair[1]}').join('&');
  }

  /// Format date as UTC ISO string.
  ///
  /// If [includeTime] is false, returns YYYYMMDD format.
  /// If [includeTime] is true, returns YYYYMMDDTHHmmssZ format.
  String _formatAsUTCISO(DateTime date, {bool includeTime = false}) {
    final utc = date.toUtc();
    if (!includeTime) {
      return DateFormat('yyyyMMdd').format(utc);
    }
    return DateFormat("yyyyMMdd'T'HHmmss'Z'").format(utc);
  }
}
