import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:front/routes/routes.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialisation de Firebase
  runApp(const MyApp());
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
        scaffoldBackgroundColor: Colors.grey[100],
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
      // Utilisation des routes définies dans le fichier routes.dart
      initialRoute: '/',
      routes: AppRoutes.routes(),
    );
  }
}
