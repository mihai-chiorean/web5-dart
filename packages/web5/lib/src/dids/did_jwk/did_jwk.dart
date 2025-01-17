import 'dart:convert';

import 'package:web5/src/crypto.dart';
import 'package:web5/src/dids/did.dart';
import 'package:web5/src/extensions.dart';
import 'package:web5/src/dids/did_uri.dart';
import 'package:web5/src/dids/data_models.dart';
import 'package:web5/src/dids/did_method_resolver.dart';

final base64UrlEncoder = Base64Codec.urlSafe().encoder;

/// Class that can be used to create and resolve `did:jwk` DIDs.
/// `did:jwk` is useful in scenarios where:
/// * Offline resolution is preferred
/// * Key rotation is not required
/// * [Service](https://www.w3.org/TR/did-core/#services) endpoints are not necessary
///
/// [Specification](https://github.com/quartzjer/did-jwk/blob/main/spec.md)
class DidJwk implements Did {
  @override
  final String uri;

  @override
  final KeyManager keyManager;

  static const String methodName = 'jwk';

  static final resolver = DidMethodResolver(name: methodName, resolve: resolve);

  DidJwk({required this.uri, required this.keyManager});

  /// Creates a new `did:jwk`. Stores associated private key in provided
  /// key manager.
  static Future<DidJwk> create({required KeyManager keyManager}) async {
    final keyAlias = await keyManager.generatePrivateKey(DsaName.ed25519);

    final publicKeyJwk = await keyManager.getPublicKey(keyAlias);
    final publicKeyJwkBase64Url = json.toBase64Url(publicKeyJwk);

    return DidJwk(
      uri: 'did:jwk:$publicKeyJwkBase64Url',
      keyManager: keyManager,
    );
  }

  /// Resolves a `did:jwk` URI into a [DidResolutionResult].
  ///
  /// This method parses the provided `didUri` to extract the JWK information.
  /// It validates the method of the DID URI and then attempts to parse the
  /// JWK from the URI. If successful, it constructs a [DidDocument] with the
  /// resolved JWK, generating a [DidResolutionResult].
  ///
  /// The method ensures that the DID URI adheres to the `did:jwk` method
  /// specification and handles exceptions that may arise during the parsing
  /// and resolution process.
  ///
  /// Returns a [DidResolutionResult] containing the resolved DID document.
  /// If the DID URI is invalid, not conforming to the `did:jwk` method, or
  /// if any other error occurs during the resolution process, it returns
  /// an invalid [DidResolutionResult].
  ///
  /// Throws [FormatException] if the JWK parsing fails.
  static Future<DidResolutionResult> resolve(String didUri) {
    final DidUri parsedDidUri;

    try {
      parsedDidUri = DidUri.parse(didUri);
    } on Exception {
      return Future.value(DidResolutionResult.invalidDid());
    }

    if (parsedDidUri.method != 'jwk') {
      return Future.value(DidResolutionResult.invalidDid());
    }

    final dynamic jwk;

    try {
      jwk = json.fromBase64Url(parsedDidUri.id);
    } on FormatException {
      return Future.value(DidResolutionResult.invalidDid());
    }

    final verificationMethod = DidVerificationMethod(
      id: '$didUri#0',
      type: 'JsonWebKey2020',
      controller: didUri,
      publicKeyJwk: Jwk.fromJson(jwk),
    );

    final didDocument = DidDocument(
      id: didUri,
      verificationMethod: [verificationMethod],
      assertionMethod: [verificationMethod.id],
      authentication: [verificationMethod.id],
      capabilityInvocation: [verificationMethod.id],
      capabilityDelegation: [verificationMethod.id],
    );

    final didResolutionResult = DidResolutionResult(didDocument: didDocument);

    return Future.value(didResolutionResult);
  }
}
