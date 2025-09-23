// services/image_upload_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageUploadService {
  static Future<String> uploadImage(File imageFile) async {
    final baseUrl = dotenv.env['baseUrl']!;
    final url = Uri.parse('$baseUrl/images'); // adjust endpoint if different

    final request = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath(
      'image', // must match the field name your backend expects
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(file);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      // Expecting your server to return the uploaded image URL
      return responseData;
    } else {
      throw Exception(
          'Image upload failed with status: ${response.statusCode}');
    }
  }
}
