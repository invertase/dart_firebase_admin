import 'package:xml/xml.dart' as xml;

/// Information about an uploaded part in a multipart upload.
class PartInfo {
  final int partNumber;
  final String etag;

  const PartInfo({required this.partNumber, required this.etag});
}

/// Utility class for parsing and building XML for multipart uploads.
///
/// This class can be reused for any XML multipart upload operations.
class XmlMultipartHelper {
  /// Extracts the UploadId from an InitiateMultipartUploadResult XML response.
  ///
  /// Example XML:
  /// ```xml
  /// <InitiateMultipartUploadResult>
  ///   <UploadId>abc123</UploadId>
  /// </InitiateMultipartUploadResult>
  /// ```
  static String parseUploadId(String xmlString) {
    final doc = xml.XmlDocument.parse(xmlString);
    final uploadIdElements = doc.findAllElements('UploadId');
    if (uploadIdElements.isEmpty) {
      throw ArgumentError('UploadId not found in XML response');
    }
    return uploadIdElements.first.innerText;
  }

  /// Builds the XML body for a CompleteMultipartUpload request.
  ///
  /// Example output:
  /// ```xml
  /// <CompleteMultipartUpload>
  ///   <Part>
  ///     <PartNumber>1</PartNumber>
  ///     <ETag>"etag1"</ETag>
  ///   </Part>
  ///   <Part>
  ///     <PartNumber>2</PartNumber>
  ///     <ETag>"etag2"</ETag>
  ///   </Part>
  /// </CompleteMultipartUpload>
  /// ```
  static String buildCompleteMultipartBody(List<PartInfo> parts) {
    final builder = xml.XmlBuilder();
    builder.element(
      'CompleteMultipartUpload',
      nest: () {
        for (final part in parts) {
          builder.element(
            'Part',
            nest: () {
              builder.element('PartNumber', nest: part.partNumber.toString());
              builder.element('ETag', nest: part.etag);
            },
          );
        }
      },
    );
    return builder.buildDocument().toXmlString(pretty: false);
  }
}
