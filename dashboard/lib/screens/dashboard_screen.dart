import 'package:flutter/material.dart';
import 'package:dashboard/providers/auth_provider.dart' as app_auth;
import 'package:dashboard/providers/theme_provider.dart';
import 'package:dashboard/widgets/responsive_layout.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const PlaceholderScreen(title: 'Overview', icon: Icons.dashboard),
    const PlaceholderScreen(title: 'Users', icon: Icons.people),
    const PlaceholderScreen(title: 'Categories', icon: Icons.category),
    const PlaceholderScreen(title: 'Plans', icon: Icons.map),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Users',
    'Categories',
    'Plans',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        leading: ResponsiveLayout.isSmallScreen(context)
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Toggle theme',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 56),
              icon: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: const Icon(Icons.person_outline),
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_outlined,
                          color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      const Text('Logout'),
                    ],
                  ),
                ),
              ],
              onSelected: (String value) {
                if (value == 'logout') {
                  authProvider.signOut();
                }
              },
            ),
          ),
        ],
      ),
      drawer: ResponsiveLayout.isSmallScreen(context)
          ? _buildDrawer(context, theme)
          : null,
      body: Row(
        children: [
          // Side navigation for medium and large screens
          if (!ResponsiveLayout.isSmallScreen(context))
            _buildSideNavigation(theme),

          // Main content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation(ThemeData theme) {
    return NavigationRail(
      extended: ResponsiveLayout.isLargeScreen(context),
      minExtendedWidth: 240,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: NavigationRailLabelType.none,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: theme.colorScheme.primary),
          label: const Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people, color: theme.colorScheme.primary),
          label: const Text('Users'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.category_outlined),
          selectedIcon: Icon(Icons.category, color: theme.colorScheme.primary),
          label: const Text('Categories'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map, color: theme.colorScheme.primary),
          label: const Text('Plans'),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.map,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  'Plany Admin',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dashboard',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            selected: _selectedIndex == 0,
            leading: Icon(
              _selectedIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined,
              color: _selectedIndex == 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            title: const Text('Dashboard'),
            onTap: () {
              _onItemTapped(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: _selectedIndex == 1,
            leading: Icon(
              _selectedIndex == 1 ? Icons.people : Icons.people_outlined,
              color: _selectedIndex == 1
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            title: const Text('Users'),
            onTap: () {
              _onItemTapped(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: _selectedIndex == 2,
            leading: Icon(
              _selectedIndex == 2 ? Icons.category : Icons.category_outlined,
              color: _selectedIndex == 2
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            title: const Text('Categories'),
            onTap: () {
              _onItemTapped(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: _selectedIndex == 3,
            leading: Icon(
              _selectedIndex == 3 ? Icons.map : Icons.map_outlined,
              color: _selectedIndex == 3
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            title: const Text('Plans'),
            onTap: () {
              _onItemTapped(3);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout_outlined,
              color: theme.colorScheme.error,
            ),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<app_auth.AuthProvider>(context, listen: false)
                  .signOut();
            },
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 72,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This page is under construction',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title functionality coming soon!'),
                ),
              );
            },
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }
}
