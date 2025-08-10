import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../components/welcome_text.dart';
import '../../constants.dart';
import '../../entry_point.dart';
import '../../services/api_service.dart';
import 'components/otp_form.dart';

class NumberVerifyScreen extends StatefulWidget {
  const NumberVerifyScreen({super.key});

  @override
  State<NumberVerifyScreen> createState() => _NumberVerifyScreenState();
}

class _NumberVerifyScreenState extends State<NumberVerifyScreen> {
  bool _isLoading = true;
  String _phoneNumber = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserPhone();
  }

  Future<void> _loadUserPhone() async {
    try {
      final user = ApiService.currentUser;
      if (user?.phone != null && user!.phone!.isNotEmpty) {
        setState(() {
          _phoneNumber = user.phone!;
        });
        await _sendOtp();
      } else {
        setState(() {
          _errorMessage =
              'No phone number found. Please update your profile first.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user information: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendOtp() async {
    try {
      await ApiService.sendPhoneOtp(_phoneNumber);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login to Foodly"),
        actions: [
          TextButton(
            onPressed: () {
              // Skip verification and go to main app
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const EntryPoint(),
                ),
              );
            },
            child: const Text(
              "Skip",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WelcomeText(
                title: "Verify phone number",
                text: "Enter the 6-Digit code sent to you at",
              ),

              if (_phoneNumber.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _phoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Sending OTP..."),
                      ],
                    ),
                  ),
                )
              else if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _sendOtp,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              else
                OtpForm(phoneNumber: _phoneNumber),

              const SizedBox(height: defaultPadding),

              if (!_isLoading && _errorMessage.isEmpty)
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Didn't receive code? ",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontWeight: FontWeight.w500),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Resend Again.",
                          style: const TextStyle(color: primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _sendOtp();
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: defaultPadding),
              const Center(
                child: Text(
                  "By Signing up you agree to our Terms \nConditions & Privacy Policy.",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: defaultPadding),
              // Skip verification info
              Container(
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 24,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Verification is optional but required for discounts and special offers",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
