import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme.dart';

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });

  final String? illustration, title, text;

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  backgroundColor.withOpacity(0.3),
                ],
              ),
            ),
            padding: const EdgeInsets.all(40),
            child: SvgPicture.asset(
              illustration!,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),

          // Title with decorative elements
          Stack(
            alignment: Alignment.center,
            children: [
              // Decorative background for title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  title!,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Text content with improved styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              text!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: bodyTextColor,
                height: 1.6,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),

          // Decorative dots (optional)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDecorativeDot(primaryColor),
              const SizedBox(width: 8),
              _buildDecorativeDot(secondaryColor),
              const SizedBox(width: 8),
              _buildDecorativeDot(accentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}