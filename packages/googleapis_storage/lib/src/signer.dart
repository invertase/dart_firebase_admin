part of '../googleapis_storage.dart';

class _InternalSignedUrlConfig {
  final SignedUrlConfig signedConfig;
  final Bucket bucket;
  final BucketFile? file;

  _InternalSignedUrlConfig({
    required this.signedConfig,
    required this.bucket,
    this.file,
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

  Future<String> getSignedUrl(SignedUrlConfig config) async {
    final expiresInSeconds = (config.expires.millisecondsSinceEpoch / 1000)
        .floor();
    final accessibleAtInSeconds =
        (config.accessibleAt?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch / 1000)
            .floor();

    if (expiresInSeconds < accessibleAtInSeconds) {
      throw ArgumentError(
        'Expiration must be >= accessibleAt (in seconds since epoch).',
      );
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
    final internalConfig = _InternalSignedUrlConfig(
      signedConfig: config,
      bucket: bucket,
      file: file,
    );

    final version = config.version ?? SignedUrlVersion.v2;

    final queryParams = await switch (version) {
      SignedUrlVersion.v2 => _getSignedUrlV2(internalConfig),
      SignedUrlVersion.v4 => _getSignedUrlV4(internalConfig),
    };

    // Build the signed URL
    final baseUrl =
        config.host?.toString() ??
        internalConfig.signedConfig.cname ??
        bucket.storage.config.apiEndpoint;

    final signedUrl = Uri.parse(baseUrl);
    final resourcePath = _getResourcePath(
      internalConfig.signedConfig.cname != null,
      internalConfig.bucket,
      internalConfig.file,
    );

    // Convert query params to query string
    final queryString = queryParams.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}',
        )
        .join('&');

    final finalUrl = signedUrl.replace(path: resourcePath, query: queryString);

    // TODO: Implement this
    // We need to sign a blob using iam credentials service, which doesn't
    // exist in Dart, so we'd need to port the following somehow:
    // https://github.com/googleapis/google-auth-library-nodejs/blob/e664d9b06ff77f4d04127435b605323cb549c8f2/src/auth/googleauth.ts#L1272-L1320
    throw UnimplementedError('Not implemented');

    return finalUrl.toString();
  }

  Future<Map<String, Object>> _getSignedUrlV2(
    _InternalSignedUrlConfig config,
  ) async {
    return {};
  }

  Future<Map<String, Object>> _getSignedUrlV4(
    _InternalSignedUrlConfig config,
  ) async {
    return {};
  }

  /// Get the resource path for the signed URL.
  ///
  /// - If [cname] is true: returns `/${file || ''}`
  /// - Else if [file] exists: returns `/${bucket}/${file}`
  /// - Else: returns `/${bucket}`
  // TODO: Check this is correct / encoded
  String _getResourcePath(bool cname, Bucket bucket, BucketFile? file) {
    if (cname) {
      return '/${file?.id ?? ''}';
    } else if (file != null) {
      return '/${bucket.id}/${file.id}';
    } else {
      return '/${bucket.id}';
    }
  }
}
