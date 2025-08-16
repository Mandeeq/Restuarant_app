import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'screens/onboarding/onboarding_scrreen.dart';
import 'services/app_state_service.dart';
import 'entry_point.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'The Flutter Way - Foodly UI Kit',
        theme: ThemeData(
          useMaterial3: false,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF603D35)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF603D35),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Color(0xFF603D35)),
            bodySmall: TextStyle(color: Color(0xFF603D35)),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.all(defaultPadding),
            hintStyle: TextStyle(color: Color(0xFF603D35)),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Block all auth-related routes if user is authenticated
          if (settings.name == '/onboarding' || settings.name == '/login' || settings.name == '/register') {
            return MaterialPageRoute(
              builder: (context) => const AppInitializer(),
            );
          }
          
          // Handle root route
          if (settings.name == '/') {
            return MaterialPageRoute(
              builder: (context) => const AppInitializer(),
            );
          }
          
          // Block any other routes that might be accessed directly
          return MaterialPageRoute(
            builder: (context) => const AppInitializer(),
          );
        },
        navigatorObservers: [
          RouteObserver<Route<dynamic>>(),
        ],
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}



class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final appState = Provider.of<AppStateService>(context, listen: false);

    try {
      await appState.initialize();
    } catch (e) {
              debugPrint('❌ App initialization failed: $e');
    } finally {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing app...'),
            ],
          ),
        ),
      );
    }

    return Consumer<AppStateService>(
      builder: (context, appState, child) {
        // Check if user is already authenticated
        if (appState.isAuthenticated) {
          // Redirect to admin dashboard if user is admin
          if (appState.isAdmin) {
            return const PopScope(
              canPop: false, // Prevent back navigation
              child: AdminDashboardScreen(),
            );
          } else {
            // Redirect to main app for regular users
            return const PopScope(
              canPop: false, // Prevent back navigation
              child: EntryPoint(),
            );
          }
        }

        // Show onboarding for new users
        return const OnboardingScreen();
      },
    );
  }
}
