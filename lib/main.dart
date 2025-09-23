import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/onboarding/onboarding_scrreen.dart';
import 'services/app_state_service.dart';
import 'entry_point.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
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
          textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
            bodyMedium: const TextStyle(color: Color(0xFF603D35)),
            bodySmall: const TextStyle(color: Color(0xFF603D35)),
          ),
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
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.all(defaultPadding),
            hintStyle: TextStyle(color: Color(0xFF603D35)),
          ),
        ),
        home: const AppInitializer(),
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
      print('❌ App initialization failed: $e');
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
            return const AdminDashboardScreen();
          } else {
            // Redirect to main app for regular users
            return const EntryPoint();
          }
        }

        // Show onboarding for new users
        return const OnboardingScreen();
      },
    );
  }
}
