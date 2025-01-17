import 'dart:convert';
import 'dart:typed_data';

import 'package:web5/src/extensions/base64url.dart';

final _base64UrlEncoder = Base64Codec.urlSafe().encoder;
final _base64UrlDecoder = Base64Codec.urlSafe().decoder;

/// Extension on [JsonCodec] to provide additional encoding functionalities.
///
/// This extension adds methods to the [JsonCodec] class to support converting
/// JSON objects to byte arrays and Base64 URL encoded strings.
extension Encoders on JsonCodec {
  /// Converts a JSON object into a byte array.
  ///
  /// This method first encodes the given [object] into a JSON string and then
  /// converts that string into a list of bytes using UTF-8 encoding.
  ///
  ///
  /// Returns a [List<int>] representing the byte array.
  Uint8List toBytes(Object object) {
    final stringified = encode(object);

    return utf8.encoder.convert(stringified);
  }

  /// Converts a JSON object into a Base64 URL encoded string.
  ///
  /// This method first converts the given [object] into a byte array and then
  /// encodes that array into a Base64 URL encoded string. The [padding]
  /// parameter determines whether the encoded string includes padding.
  ///
  ///
  /// Returns a [String] representing the Base64 URL encoded value.
  String toBase64Url(Object object, {bool padding = false}) {
    final bytes = toBytes(object);

    return padding
        ? _base64UrlEncoder.convert(bytes)
        : _base64UrlEncoder.convertNoPadding(bytes);
  }

  dynamic fromBase64Url(String input, {bool padding = false}) {
    final bytes = padding
        ? _base64UrlDecoder.convert(input)
        : _base64UrlDecoder.convertNoPadding(input);

    final stringified = utf8.decode(bytes);

    return json.decode(stringified);
  }
}
