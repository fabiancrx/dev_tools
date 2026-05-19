import 'dart:convert';

import 'package:crypto/crypto.dart';

enum HashAlgorithm { md5, sha1, sha224, sha256, sha384, sha512 }

extension HashAlgorithmX on HashAlgorithm {
  String get label => switch (this) {
        HashAlgorithm.md5 => 'MD5',
        HashAlgorithm.sha1 => 'SHA-1',
        HashAlgorithm.sha224 => 'SHA-224',
        HashAlgorithm.sha256 => 'SHA-256',
        HashAlgorithm.sha384 => 'SHA-384',
        HashAlgorithm.sha512 => 'SHA-512',
      };

  Hash get _hash => switch (this) {
        HashAlgorithm.md5 => md5,
        HashAlgorithm.sha1 => sha1,
        HashAlgorithm.sha224 => sha224,
        HashAlgorithm.sha256 => sha256,
        HashAlgorithm.sha384 => sha384,
        HashAlgorithm.sha512 => sha512,
      };

  Hmac hmac(List<int> key) => Hmac(_hash, key);
}

class HashResult {
  final String hex;
  final String base64;

  const HashResult({required this.hex, required this.base64});

  static const empty = HashResult(hex: '', base64: '');
}

HashResult computeHash(String input, HashAlgorithm algorithm, {String? hmacKey}) {
  if (input.isEmpty) return HashResult.empty;
  final bytes = utf8.encode(input);
  final Digest digest;
  if (hmacKey != null && hmacKey.isNotEmpty) {
    digest = algorithm.hmac(utf8.encode(hmacKey)).convert(bytes);
  } else {
    digest = algorithm._hash.convert(bytes);
  }
  return HashResult(
    hex: digest.toString(),
    base64: base64.encode(digest.bytes),
  );
}
