import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front/firebase_options.dart';
import 'package:front/providers/plan_provider.dart';
import 'package:front/routes/routes.dart';
import 'package:front/screens/auth/home_screen.dart';
import 'package:front/screens/dashboard/dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print('Fichier .env chargé avec succès');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erreur lors du chargement du fichier .env: $e');
    }
  }

  // Specify the options to ensure Firebase initializes properly
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PlanProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plany App',
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
        primaryColor: const Color(0xFF3425B5),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Color(0xFF3425B5),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      // Use AuthWrapper as the home widget to reliably handle auth state
      home: const AuthWrapper(),
      // Add routes from AppRoutes
      routes: AppRoutes.routes(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// New AuthWrapper widget that actively listens to authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder to actively listen to auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for the initial state, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // When there's an error, show an error message
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erreur: ${snapshot.error}'),
            ),
          );
        }

        // Depending on authentication state, show appropriate screen
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
