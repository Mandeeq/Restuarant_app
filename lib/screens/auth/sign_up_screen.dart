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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              
              // Welcome section with restaurant branding
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const WelcomeText(
                  title: 'Create Account',
                  text: 'Enter your Name, Email and Password for sign up.',
                ),
              ),
              const SizedBox(height: 40),
              
              // Sign Up Form
              const SignUpForm(),
              const SizedBox(height: 30),
              
              // Sign Up Button
              // SizedBox(
              //   width: double.infinity,
              //   height: 54,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Handle sign up logic
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: primaryColor,
              //       foregroundColor: Colors.white,
              //       elevation: 3,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(14),
              //       ),
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //     ),
              //     child: const Text(
              //       'SIGN UP',
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //         letterSpacing: 0.5,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 30),
              
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
              const SizedBox(height: 30),
              
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
              const SizedBox(height: 30),
              
              // Divider with OR text
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: bodyTextColor.withOpacity(0.3),
                      thickness: 1,
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
                      color: bodyTextColor.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}