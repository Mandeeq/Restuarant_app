import 'package:flutter/material.dart';

import '../../theme.dart';

import '../../components/welcome_text.dart';

class ResetEmailSentScreen extends StatelessWidget {
  const ResetEmailSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeText(
                title: "Reset email sent",
                text:
                    "We have sent a instructions email to \ntheflutterway@email.com.",titleStyle: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.brown,
              letterSpacing: 1.2,
            ),
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.6,
              ),),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Send again"),
            ),
          ],
        ),
      ),
    );
  }
}
