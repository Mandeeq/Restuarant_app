class ImageUtils {
  static const String baseUrl = 'http://192.2.1.118:5000';
  static const String imagesPath = '/images';

  /// Constructs a full image URL from a relative path
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '$baseUrl$imagesPath/food.jpg'; // Default fallback image
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Construct full URL from relative path
    return '$baseUrl$imagesPath/$imagePath';
  }

  /// Gets the default fallback image URL
  static String getDefaultImageUrl() {
    return '$baseUrl$imagesPath/food.jpg';
  }

  /// Checks if an image URL is valid
  static bool isValidImageUrl(String url) {
    return url.isNotEmpty &&
        (url.startsWith('http') ||
            url.endsWith('.jpg') ||
            url.endsWith('.png') ||
            url.endsWith('.jpeg'));
  }
}
