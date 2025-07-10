import 'package:flutter/material.dart';

class ProfileInfoScreen extends StatelessWidget {
  const ProfileInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Information')),
      body: const Center(child: Text('Profile editing coming soon!')),
    );
  }
}
