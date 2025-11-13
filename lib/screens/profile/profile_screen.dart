// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../services/api_service.dart';
import '../../screens/phoneLogin/number_verify_screen.dart';
import 'components/profile_info_screen.dart';
import 'components/change_password_screen.dart';
import 'components/payment_methods_screen.dart';
import 'components/locations_screen.dart';
import 'components/social_account_screen.dart';
import 'components/refer_friends_screen.dart';
import '../home/home_screen.dart';

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 User Info Section
            _buildSection(
              title: "Account Information",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Name", user?.name ?? "N/A"),
                  _buildInfoRow("Email", user?.email ?? "N/A"),
                  _buildInfoRow("Phone", user?.phone ?? "Not provided"),
                  _buildInfoRow("Role", user?.role?.toUpperCase() ?? "CUSTOMER"),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding),

            // ✅ Verification Status Section
            _buildSection(
              title: "Verification Status",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: defaultPadding / 2),
                  if (!(_verificationStatus['emailVerified'] ?? false) ||
                      !(_verificationStatus['phoneVerified'] ?? false))
                    _buildVerificationBanner(),
                  const SizedBox(height: defaultPadding / 2),
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
                            _loadVerificationStatus();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text("Verify Phone Number"),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding),

            // ⚙️ Account Settings Section
            _buildSection(
              title: "Account Settings",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Update your settings like notifications, payments, and profile.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: bodyTextColor,
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  _buildSettingsRow(
                    "Profile Information",
                    "Edit name, email, phone",
                    Icons.person,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileInfoScreen(),
                      ),
                    ),
                  ),
                  _buildSettingsRow(
                    "Change Password",
                    "Secure your account",
                    Icons.lock,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    ),
                  ),
                  _buildSettingsRow(
                    "Payment Methods",
                    "Add credit & debit cards",
                    Icons.credit_card,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentMethodsScreen(),
                      ),
                    ),
                  ),
                  _buildSettingsRow(
                    "Locations",
                    "Manage delivery addresses",
                    Icons.location_on,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationsScreen(),
                      ),
                    ),
                  ),
                  _buildSettingsRow(
                    "Social Accounts",
                    "Connect Facebook, Google",
                    Icons.share_outlined,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SocialAccountScreen(),
                      ),
                    ),
                  ),
                  _buildSettingsRow(
                    "Refer Friends",
                    "Get Ksh 100 per referral",
                    Icons.card_giftcard,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReferFriendsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding),

            // 🚪 Account Actions
            _buildSection(
              title: "Account Actions",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionRow(
                    "Logout",
                    Icons.logout,
                    Colors.red,
                        () {
                      ApiService.clearAuthData();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding * 2),
          ],
        ),
      ),
    );
  }

  // ✅ Reusable Section Builder (matches MenuScreen card style)
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: defaultPadding),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bodyTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isVerified ? "Verified" : "Not verified",
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

  Widget _buildVerificationBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: primaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Verify your account to unlock discounts and special offers!",
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
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
                      color: bodyTextColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: bodyTextColor.withOpacity(0.6),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 0.8),
          ),
        ),
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
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}