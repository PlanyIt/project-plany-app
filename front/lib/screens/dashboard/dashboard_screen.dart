import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/screens/create-plan/create_plans_screen.dart';
import 'package:front/screens/dashboard/dashboard_home_screen.dart';
import 'package:front/screens/profile/profile_screen.dart';
import 'package:front/widgets/drawer/profile_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget get _currentPage {
    switch (_selectedIndex) {
      case 0:
        return DashboardHomeScreen(
          onProfileTap: () => _scaffoldKey.currentState?.openEndDrawer(),
        );
      case 1:
        return const CreatePlansScreen();
      case 2:
        return const ProfileScreen();
      default:
        return DashboardHomeScreen(
          onProfileTap: () => _scaffoldKey.currentState?.openEndDrawer(),
        );
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
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: _currentPage,
      ),
      endDrawer: ProfileDrawer(
        onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
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
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
