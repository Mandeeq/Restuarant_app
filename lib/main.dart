import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qaffee_clean/screens/statemanagement/cart_provider.dart';
import 'theme.dart';
import 'screens/onboarding/onboarding_scrreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // add other providers here if you have them
      ],
      child:
       MaterialApp(
        title: 'The Flutter Way - Foodly UI Kit',
        debugShowCheckedModeBanner: false,
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
          // Use Google Fonts Space Grotesk across the app
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme.apply(
                  bodyColor: const Color(0xFF603D35),
                  displayColor: const Color(0xFF603D35),
                ),
          ),
          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.all(defaultPadding),
            hintStyle: TextStyle(color: Color(0xFF603D35)),
          ),
        ),
        home: const OnboardingScreen(),
      ),
      );
    
  }
}
