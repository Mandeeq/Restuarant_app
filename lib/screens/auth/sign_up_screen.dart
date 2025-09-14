import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'sign_in_screen.dart';

import '../../components/buttons/socal_button.dart';
import '../../components/welcome_text.dart';
import '../../theme.dart';
import '../signUp/components/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(2),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Curved background (same as sign in screen)
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: ClipPath(
                    clipper: CurvedClipper(),
                    child: Container(color: primaryColor),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(color: backgroundColor),
                ),
              ],
            ),
          ),

          // Foreground content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Title centered on the curve
                  Center(
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/onboarding2-removebg-preview.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Welcome section with restaurant branding
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const WelcomeText(
                      title: 'Create Account',
                      text: 'Enter your Name, Email and Password for sign up.',
                      titleStyle: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Sign Up Form
                  const SignUpForm(),
                  const SizedBox(height: 8),

                  // Sign Up Button

                  const SizedBox(height: 16),

                  // Already have account
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          color: bodyTextColor,
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignInScreen(),
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider with OR text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: primaryColor.withOpacity(0.3),
                          thickness: 1.2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: bodyTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: primaryColor.withOpacity(0.3),
                          thickness: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Social buttons
                  // Facebook
                  SocalButton(
                    press: () {},
                    text: "Connect with Facebook",
                    color: const Color(0xFF395998),
                    icon: SvgPicture.asset(
                      'assets/icons/facebook.svg',
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF395998),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Google
                  SocalButton(
                    press: () {},
                    text: "Connect with Google",
                    color: const Color(0xFF4285F4),
                    icon: SvgPicture.asset(
                      'assets/icons/google.svg',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms and conditions
                  Center(
                    child: Text(
                      "By Signing up you agree to our Terms \nConditions & Privacy Policy.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: bodyTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}