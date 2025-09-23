import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qaffee_clean/theme.dart';


class WelcomeText extends StatelessWidget {
  final String title;
  final String text;

  const WelcomeText({
    super.key,
    required this.title,
    required this.text, required TextStyle titleStyle, required TextStyle textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(   // 👈 Apply font
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 216, 216),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: GoogleFonts.spaceGrotesk(   // 👈 Apply font
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color.fromARGB(255, 255, 191, 191),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
