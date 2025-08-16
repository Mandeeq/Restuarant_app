import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/admin_models.dart';
import '../../services/api_service.dart';
import '../../services/app_state_service.dart';
import '../../components/auth_guard.dart';
import 'admin_orders_screen.dart';
import 'admin_menu_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_payments_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthGuard(
      requiredRole: 'admin',
      child: _AdminDashboardContent(),
    );
  }
}

class _AdminDashboardContent extends StatefulWidget {
  const _AdminDashboardContent({super.key});

  @override
  State<_AdminDashboardContent> createState() => __AdminDashboardContentState();
}

class __AdminDashboardContentState extends State<_AdminDashboardContent> {
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await ApiService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false, // Prevent back navigation to auth screens
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadDashboardStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Restaurant Statistics",
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Grid-based stats cards
              if (_stats != null)
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1, // Reduced to prevent overflow
                  ),
                  children: [
                    _buildStatCard(
                      "Total Orders",
                      _stats!.totalOrders.toString(),
                      Icons.shopping_cart,
                      theme.colorScheme.primary,
                    ),
                    _buildStatCard(
                      "Pending Orders",
                      _stats!.pendingOrders.toString(),
                      Icons.timelapse,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      "Total Revenue",
                      "\$${_stats!.totalRevenue.toStringAsFixed(2)}",
                      Icons.monetization_on,
                      Colors.green,
                    ),
                    _buildStatCard(
                      "Customers",
                      _stats!.totalCustomers.toString(),
                      Icons.people,
                      theme.colorScheme.secondary,
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              Text(
                "Quick Actions",
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Quick action cards
              _buildActionTile(
                "Manage Orders",
                Icons.shopping_cart,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminOrdersScreen(),
                  ),
                ),
              ),
              _buildActionTile(
                "Manage Menu",
                Icons.restaurant_menu,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminMenuScreen(),
                  ),
                ),
              ),
              _buildActionTile(
                "View Customers",
                Icons.people,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminCustomersScreen(),
                  ),
                ),
              ),
              _buildActionTile(
                "Payment History",
                Icons.payment,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPaymentsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern stat card
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Modern quick action tile
  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout from admin panel?'),
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
