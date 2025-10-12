import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageUtils {
  static  String baseUrl = dotenv.env['baseUrl'] ?? "";
  static const String imagesPath = '/images';

  /// Constructs a full image URL from a relative path
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      final defaultUrl = '$baseUrl$imagesPath/food.jpg';
      print('🖼️ Using default image URL: $defaultUrl');
      return defaultUrl; // Default fallback image
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      print('🖼️ Using full URL as is: $imagePath');
      return imagePath;
    }

    // Construct full URL from relative path
    final fullUrl = '$baseUrl$imagesPath/$imagePath';
    print('🖼️ Constructed image URL: $fullUrl from path: $imagePath');
    return fullUrl;
  }

  /// Gets the default fallback image URL
  static String getDefaultImageUrl() {
    return '$baseUrl$imagesPath';
  }

  /// Checks if an image URL is valid
  static bool isValidImageUrl(String url) {
    return url.isNotEmpty &&
        (url.startsWith('http') ||
            url.endsWith('.jpg') ||
            url.endsWith('.png') ||
            url.endsWith('.jpeg'));
  }

  /// Returns an ImageProvider for the given image path.
  /// If the path resolves to a network URL it returns [NetworkImage],
  /// otherwise falls back to a bundled placeholder asset.
  static ImageProvider getImageProvider(String? imagePath) {
    // If no path provided, return bundled placeholder
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage('assets/images/placeholder.png');
    }

    // If the incoming path is already a full URL, use it directly
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    }

    // If we have a configured baseUrl (usually set via .env), construct a network URL
    if (baseUrl.isNotEmpty && baseUrl.startsWith('http')) {
      // Avoid duplicate slashes
      final normalizedPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
      final fullUrl = '$baseUrl$imagesPath/$normalizedPath';
      return NetworkImage(fullUrl);
    }

    // Otherwise fall back to bundled placeholder
    return const AssetImage('assets/images/placeholder.png');
  }
}
