import 'dart:convert';
import 'dart:typed_data';

import 'package:web5/src/crypto/secp256k1.dart';
import 'package:test/test.dart';

void main() {
  group('Secp256k1', () {
    test('should verify public key', () async {
      final secp256k1 = Secp256k1();

      final privateKeyJwk = await secp256k1.generatePrivateKey();
      final payload = Uint8List.fromList(utf8.encode('hello'));
      final signature = await secp256k1.sign(privateKeyJwk, payload);

      final publicKeyJwk = await secp256k1.computePublicKey(privateKeyJwk);
      await secp256k1.verify(publicKeyJwk, payload, signature);
    });
  });
}
