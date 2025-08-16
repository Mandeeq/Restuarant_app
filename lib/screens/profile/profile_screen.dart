import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../services/api_service.dart';
import '../../services/app_state_service.dart';
import '../../screens/phoneLogin/number_verify_screen.dart';
import 'components/profile_info_screen.dart';
import 'components/change_password_screen.dart';
import 'components/payment_methods_screen.dart';
import 'components/locations_screen.dart';
import 'components/social_account_screen.dart';
import 'components/refer_friends_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, bool> _verificationStatus = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await ApiService.getVerificationStatus();
      setState(() {
        _verificationStatus = {
          'emailVerified': status['emailVerified'] ?? false,
          'phoneVerified': status['phoneVerified'] ?? false,
        };
      });
    } catch (e) {
      print('Error loading verification status: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Account Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow("Name", user?.name ?? "N/A"),
                  _buildInfoRow("Email", user?.email ?? "N/A"),
                  _buildInfoRow("Phone", user?.phone ?? "Not provided"),
                  _buildInfoRow("Role", user?.role ?? "customer"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Verification Status Section
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Verification Status",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildVerificationRow(
                    "Phone Number",
                    _verificationStatus['phoneVerified'] ?? false,
                    Icons.phone,
                  ),
                  _buildVerificationRow(
                    "Email Address",
                    _verificationStatus['emailVerified'] ?? false,
                    Icons.email,
                  ),
                  const SizedBox(height: 16),
                  if (!(_verificationStatus['emailVerified'] ?? false) ||
                      !(_verificationStatus['phoneVerified'] ?? false))
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Verify your account to unlock discounts and special offers!",
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
                  const SizedBox(height: 16),
                  if (!(_verificationStatus['phoneVerified'] ?? false))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NumberVerifyScreen(),
                            ),
                          ).then((_) {
                            // Refresh verification status when returning
                            _loadVerificationStatus();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Verify Phone Number"),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Account Settings Section
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Account Settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Update your settings like notifications, payments, profile edit etc.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsRow(
                    "Profile Information",
                    "Change your account information",
                    Icons.person,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileInfoScreen()),
                    ),
                  ),
                  _buildSettingsRow(
                    "Change Password",
                    "Change your password",
                    Icons.lock,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen()),
                    ),
                  ),
                  _buildSettingsRow(
                    "Payment Methods",
                    "Add your credit & debit cards",
                    Icons.credit_card,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentMethodsScreen()),
                    ),
                  ),
                  _buildSettingsRow(
                    "Locations",
                    "Add or remove your delivery locations",
                    Icons.location_on,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LocationsScreen()),
                    ),
                  ),
                  _buildSettingsRow(
                    "Add Social Account",
                    "Add Facebook, Twitter etc",
                    Icons.share,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SocialAccountScreen()),
                    ),
                  ),
                  _buildSettingsRow(
                    "Refer to Friends",
                    "Get \$10 for referring friends",
                    Icons.card_giftcard,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReferFriendsScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Account Actions Section
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Account Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionRow(
                    "Logout",
                    Icons.logout,
                    Colors.red,
                    () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: bodyTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(String label, bool isVerified, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isVerified ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isVerified ? "Verified" : "Not Verified",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor.withOpacity(0.64),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: titleColor.withOpacity(0.54),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: titleColor.withOpacity(0.54),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    final user = ApiService.currentUser;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to logout?'),
              if (user != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Current user: ${user.name} (${user.role})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Perform logout and navigate to auth screens
  void _performLogout(BuildContext context) {
    final appState = Provider.of<AppStateService>(context, listen: false);
    
    // Clear all app state
    appState.logout();
    
    // Navigate to root and clear all previous routes
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false, // This removes all previous routes
    );
  }
}
