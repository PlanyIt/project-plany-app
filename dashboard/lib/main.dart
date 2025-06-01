import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/firebase_options.dart';
import 'package:dashboard/providers/auth_provider.dart' as app_auth;
import 'package:dashboard/providers/category_provider.dart';
import 'package:dashboard/providers/plan_provider.dart';
import 'package:dashboard/providers/user_provider.dart';
import 'package:dashboard/providers/theme_provider.dart';
import 'package:dashboard/screens/auth/login_screen.dart';
import 'package:dashboard/screens/dashboard_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print('Env file loaded successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error loading .env file: $e');
    }
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const PlanyDashboard(),
    ),
  );
}

class PlanyDashboard extends StatelessWidget {
  const PlanyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Plany Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3425B5),
          brightness:
              themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // In debug mode, check if we're using development credentials
    if (kDebugMode) {
      // Check if we're in development mode with a special flag
      final devMode = dotenv.env['DEV_MODE'] == 'true';
      if (devMode) {
        return const DashboardScreen();
      }
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Check if the user is an admin
          final authProvider =
              Provider.of<app_auth.AuthProvider>(context, listen: false);
          return FutureBuilder<bool>(
            future: authProvider.checkAdminRole(snapshot.data!.uid),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (adminSnapshot.hasData && adminSnapshot.data == true) {
                return const DashboardScreen();
              } else {
                // Not admin, show access denied
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Access Denied',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                            'You need admin privileges to access this dashboard.'),
                        SizedBox(height: 24),
                        Text('Please contact the system administrator.'),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
