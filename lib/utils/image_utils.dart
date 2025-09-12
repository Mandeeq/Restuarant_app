class ImageUtils {
  static const String baseUrl = 'http://192.168.1.104:5000';
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
