import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state_service.dart';
import '../constants.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? requiredRole;
  final Widget? fallback;

  const AuthGuard({
    super.key,
    required this.child,
    this.requiredRole,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateService>(
      builder: (context, appState, child) {
        // Check if user is authenticated
        if (!appState.isAuthenticated) {
          return _buildAuthRequiredScreen(context);
        }

        // Check if specific role is required
        if (requiredRole != null && appState.currentUser?.role != requiredRole) {
          return _buildUnauthorizedScreen(context);
        }

        // User is authenticated and authorized
        return this.child;
      },
    );
  }

  Widget _buildAuthRequiredScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Authentication Required',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Please sign in to access this feature. You need to be logged in to continue.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: bodyTextColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Sign In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _navigateToAuth(context),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _navigateToAuth(context, isRegister: true),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthorizedScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_outlined,
                  size: 40,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'You don\'t have permission to access this feature. Please contact an administrator if you believe this is an error.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: bodyTextColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Go Back Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAuth(BuildContext context, {bool isRegister = false}) {
    // Navigate to root and clear all previous routes
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }
} 