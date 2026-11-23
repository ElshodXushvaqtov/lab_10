import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// The three ways to get image bytes. Every method only returns bytes;
/// classification happens in one place (MainShell.handleImage).
class ImageSources {
  final _picker = ImagePicker();

  /// Returns null if the user cancels the camera.
  Future<Uint8List?> fromCamera() async {
    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
    );
    if (shot == null) return null;
    return await shot.readAsBytes();
  }

  /// Returns null if the user closes the gallery without picking.
  Future<Uint8List?> fromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
    );
    if (picked == null) return null;
    return await picked.readAsBytes();
  }

  /// Downloads an image. Throws an Exception with a readable message
  /// when something goes wrong.
  Future<Uint8List> fromUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw Exception('That does not look like a web address. '
          'It should start with http:// or https://');
    }

    http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('The download took too long. Try again or use another link.');
    } on SocketException {
      throw Exception('No internet connection, or the site could not be found.');
    } on http.ClientException {
      throw Exception('Could not connect to that address.');
    }

    if (response.statusCode != 200) {
      throw Exception('The server answered with code ${response.statusCode}. '
          'Check the address.');
    }

    final type = response.headers['content-type'] ?? '';
    if (!type.startsWith('image/')) {
      throw Exception('That link is not a picture (it is "$type"). '
          'Use a link that ends in .jpg or .png.');
    }

    return response.bodyBytes;
  }
}
