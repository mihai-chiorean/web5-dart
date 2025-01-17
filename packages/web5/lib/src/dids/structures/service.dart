import 'package:web5/src/dids/structures/did_resource.dart';

/// Services are used in DID documents to express ways of communicating with
/// the DID subject or associated entities.
/// A service can be any type of service the DID subject wants to advertise.
///
/// [Specification Reference](https://www.w3.org/TR/did-core/#services)
class DidService implements DidResource {
  /// The value of the id property MUST be a URI conforming to [RFC3986].
  /// A conforming producer MUST NOT produce multiple service entries with
  /// the same id. A conforming consumer MUST produce an error if it detects
  /// multiple service entries with the same id.
  @override
  final String id;

  /// examples of registered types can be found
  /// [here](https://www.w3.org/TR/did-spec-registries/#service-types)
  final String type;

  /// A network address, such as an HTTP URL, at which services operate on behalf
  /// of a DID subject.
  final String serviceEndpoint;

  DidService({
    required this.id,
    required this.type,
    required this.serviceEndpoint,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'serviceEndpoint': serviceEndpoint,
    };
  }
}
