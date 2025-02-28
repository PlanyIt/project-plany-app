import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/screens/auth/login_screen.dart';
import 'package:front/screens/auth/signup_screen.dart';
import 'package:front/screens/create-plan/plans_screen.dart';
import 'package:front/screens/dashboard/plans_screen.dart';
import 'package:front/screens/home/home_screen.dart';
import 'package:front/screens/dashboard/map_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Liste des pages pour chaque onglet de la barre de navigation
  static final List<Widget> _pages = <Widget>[
    HomeScreen(),
    const LoginScreen(),
    const SignupScreen(),
    const CreatePlansScreen(),
    const PlansScreen(),
    MapScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // Vérifie si l'utilisateur est connecté
  Future<void> _checkAuthStatus() async {
    User? user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex), // Affiche la page sélectionnée
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.view_list),
            label: 'Login',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.person),
            label: 'Signin',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.add_circle_outline),
            label: 'Créer',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.list),
            label: 'Plans',
          ),
            BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
