/// Stub implementations for dart:html types used in utils.dart,
/// used when compiling for non-web platforms.

class Blob {
  Blob(List<dynamic> blobParts, [String? type, String? endings]);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) {
    // Return an empty string or throw an error, as this shouldn't be called on non-web.
    print(
        "createObjectUrlFromBlob called on non-web platform. This shouldn't happen.");
    return '';
  }

  static void revokeObjectUrl(String url) {
    // No-op on non-web platforms.
  }
}

class AnchorElement {
  String? href;

  AnchorElement({this.href});

  void setAttribute(String name, String value) {
    // No-op on non-web platforms.
  }

  void click() {
    // No-op on non-web platforms.
  }
}
