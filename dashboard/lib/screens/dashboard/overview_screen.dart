import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/providers/category_provider.dart';
import 'package:dashboard/providers/plan_provider.dart';
import 'package:dashboard/providers/user_provider.dart';
import 'package:intl/intl.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load data from providers
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      final planProvider = Provider.of<PlanProvider>(context, listen: false);

      await Future.wait([
        userProvider.fetchUsers(),
        categoryProvider.fetchCategories(),
        planProvider.fetchPlans(),
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Stats Cards
            _buildStatsCards(context),

            const SizedBox(height: 32),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildRecentActivityList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final planProvider = Provider.of<PlanProvider>(context);

    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 1200
          ? 4
          : MediaQuery.of(context).size.width > 800
              ? 2
              : 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          context: context,
          title: 'Total Users',
          value: userProvider.users.length.toString(),
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildStatCard(
          context: context,
          title: 'Total Categories',
          value: categoryProvider.categories.length.toString(),
          icon: Icons.category,
          color: Colors.orange,
        ),
        _buildStatCard(
          context: context,
          title: 'Total Plans',
          value: planProvider.plans.length.toString(),
          icon: Icons.map,
          color: Colors.green,
        ),
        _buildStatCard(
          context: context,
          title: 'New Users (Last Month)',
          value: '0', // TODO: Implement this with actual data
          icon: Icons.person_add,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            const Text('Last updated: Today'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(BuildContext context) {
    // This is a placeholder. In a real app, you would get this data from your providers.
    final activities = [
      {
        'type': 'user',
        'action': 'registered',
        'name': 'John Doe',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'type': 'plan',
        'action': 'created',
        'name': 'Trip to Paris',
        'time': DateTime.now().subtract(const Duration(hours: 5)),
      },
      {
        'type': 'category',
        'action': 'updated',
        'name': 'Travel',
        'time': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'type': 'user',
        'action': 'updated profile',
        'name': 'Jane Smith',
        'time': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final activity = activities[index];

          IconData icon;
          Color color;

          switch (activity['type']) {
            case 'user':
              icon = Icons.person;
              color = Colors.blue;
              break;
            case 'plan':
              icon = Icons.map;
              color = Colors.green;
              break;
            case 'category':
              icon = Icons.category;
              color = Colors.orange;
              break;
            default:
              icon = Icons.info;
              color = Colors.grey;
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            title: Text('${activity['name']}'),
            subtitle: Text('${activity['action']}'),
            trailing: Text(
              DateFormat.yMMMd().add_Hm().format(activity['time'] as DateTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        },
      ),
    );
  }
}
