import 'package:flutter/material.dart';
import 'package:front/screens/create-plan/create_plans_screen.dart';
import 'package:front/ui/dashboard/widgets/dashboard_home_screen.dart';
import 'package:front/screens/profile/profile_screen.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/ui/home/widgets/home_screen.dart';
import 'package:front/widgets/drawer/profile_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  late final String? userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  void getUserId() async {
    userId = await _authService.getCurrentUserId();
  }

  Widget get _currentPage {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen();

      /// Todo à changer en dashboard
      case 1:
        return const CreatePlansScreen();
      case 2:
        return ProfileScreen(
          userId: userId,
        );
      default:
        return HomeScreen();

      ///Todo à changer en dashboard
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
