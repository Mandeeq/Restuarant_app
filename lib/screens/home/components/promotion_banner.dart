import 'package:flutter/material.dart';
import '../../../components/scalton/scalton_rounded_container.dart';
import '../../../constants.dart';
import '../../../services/api_service.dart';

class PromotionBanner extends StatefulWidget {
  const PromotionBanner({super.key});

  @override
  State<PromotionBanner> createState() => _PromotionBannerState();
}

class _PromotionBannerState extends State<PromotionBanner> {
  bool isLoading = true;
  bool isUserVerified = false;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final verified = await ApiService.isUserVerified();
      setState(() {
        isUserVerified = verified;
      });
    } catch (e) {
      setState(() {
        isUserVerified = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: isLoading
          ? Container(
              height: 120, // Fixed height instead of aspect ratio
              child: const ScaltonRoundedContainer(radious: 12),
            )
          : Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isUserVerified
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.orange.shade400, Colors.orange.shade600],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isUserVerified
                                ? "🎉 Verified Account!"
                                : "🔒 Unlock Special Offers",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isUserVerified
                                ? "You're eligible for exclusive discounts and rewards!"
                                : "Verify your account to get 10% off your first order",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isUserVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Verify Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
