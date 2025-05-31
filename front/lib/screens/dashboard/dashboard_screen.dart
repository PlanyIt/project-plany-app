import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/screens/create-plan/create_plans_screen.dart';
import 'package:front/screens/dashboard/plans_screen.dart';
import 'package:front/screens/dashboard/dashboard_home_screen.dart';
//import 'package:front/screens/profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instead of static pages, use a getter that returns the current page
  Widget get _currentPage {
    switch (_selectedIndex) {
      case 0:
        return const DashboardHomeScreen();
      case 1:
        return const CreatePlansScreen();
      case 2:
        return const PlansScreen();
      // case 3:
      //   return const ProfileScreen();
      default:
        return const DashboardHomeScreen();
    }
  }

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
      print(index);
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _currentPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.dashboard_customize_outlined),
            label: 'Tableau de bord',
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
          // BottomNavigationBarItem(
          //   backgroundColor: Colors.white,
          //   icon: Icon(Icons.person),
          //   label: 'Profil',
          // ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
