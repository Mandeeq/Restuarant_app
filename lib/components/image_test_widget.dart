import 'package:flutter/material.dart';

class ImageTestWidget extends StatelessWidget {
  const ImageTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Loading Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Testing Image Loading from Backend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Test food.jpg
          const Text('Testing food.jpg:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Image.network(
            'http://192.2.1.118:5000/images/food.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.red[100],
                child: const Center(
                  child: Text('Error loading food.jpg'),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Test drink.jpg
          const Text('Testing drink.jpg:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Image.network(
            'http://192.2.1.118:5000/images/drink.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.red[100],
                child: const Center(
                  child: Text('Error loading drink.jpg'),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Test non-existent image
          const Text('Testing non-existent image (should show error):',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Image.network(
            'http://192.2.1.118:5000/images/nonexistent.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.red[100],
                child: const Center(
                  child: Text('Error loading nonexistent.jpg (expected)'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
