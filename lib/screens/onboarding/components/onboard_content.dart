import 'package:flutter/material.dart';
import '../../../theme.dart';

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });

  final String illustration;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration with decorative container
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                // BoxShadow(
                //   // color: primaryColor.withOpacity(0.1),
                //   blurRadius: 15,
                //   offset: const Offset(0, 8),
                // ),
              ],
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   // colors: [
              //   //   Colors.white,
              //   //   backgroundColor.withOpacity(0.3),
              //   // ],
              // ),
            ),
            padding: const EdgeInsets.all(0),
            child: Image.asset(
              illustration,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: 24,
              fontFamily: 'Grotesk',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Text content
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: primaryColor.withOpacity(0.7),
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
