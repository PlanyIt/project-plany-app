import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/providers/user_provider.dart';
import 'package:dashboard/models/user.dart' as app_user;

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final filteredUsers = userProvider.users.where((user) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return (user.username?.toLowerCase().contains(query) ?? false) ||
          (user.email?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Users',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showUserDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add User'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Loading indicator
            if (userProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (userProvider.error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading users',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(userProvider.error!),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        userProvider.fetchUsers();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (filteredUsers.isEmpty)
              const Center(
                child: Text('No users found'),
              )
            else
              // User list
              Expanded(
                child: Card(
                  child: ListView.separated(
                    itemCount: filteredUsers.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          child: Text(
                            user.username != null && user.username!.isNotEmpty
                                ? user.username![0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(user.username ?? 'Unknown'),
                        subtitle: Text(user.email ?? 'No email'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(user.role ?? 'user'),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showUserDialog(context, user: user);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                user.isActive == true
                                    ? Icons.lock_open
                                    : Icons.lock,
                                color: user.isActive == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              onPressed: () {
                                _toggleUserStatus(context, user);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          userProvider.setSelectedUser(user);
                          _showUserDetailsDialog(context, user);
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleUserStatus(BuildContext context, app_user.User user) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (user.id != null) {
      userProvider.changeUserStatus(user.id!, !(user.isActive ?? true));
    }
  }

  void _showUserDialog(BuildContext context, {app_user.User? user}) {
    final formKey = GlobalKey<FormState>();
    final usernameController =
        TextEditingController(text: user?.username ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    String? selectedRole = user?.role ?? 'user';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user != null ? 'Edit User' : 'Add User'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter username',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                          value: 'moderator', child: Text('Moderator')),
                    ],
                    onChanged: (value) {
                      selectedRole = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Save user
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  final updatedUser = user != null
                      ? user.copyWith(
                          username: usernameController.text,
                          email: emailController.text,
                          role: selectedRole,
                        )
                      : app_user.User(
                          username: usernameController.text,
                          email: emailController.text,
                          role: selectedRole,
                          isActive: true,
                        );

                  if (user != null && user.id != null) {
                    userProvider.updateUser(user.id!, updatedUser);
                  } else {
                    // In a real app, you would create a new user here
                    // This is just a placeholder since we don't have all the required
                    // auth functionality in this example
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Creating new users requires additional setup'),
                      ),
                    );
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text(user != null ? 'Save' : 'Create'),
            ),
          ],
        );
      },
    );
  }

  void _showUserDetailsDialog(BuildContext context, app_user.User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('User Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Username', user.username ?? 'Unknown'),
                _buildDetailRow('Email', user.email ?? 'No email'),
                _buildDetailRow('Role', user.role ?? 'user'),
                _buildDetailRow(
                    'Status', user.isActive == true ? 'Active' : 'Inactive'),
                _buildDetailRow(
                    'Firebase UID', user.firebaseUid ?? 'Not linked'),
                _buildDetailRow('Location', user.location ?? 'Not specified'),
                _buildDetailRow(
                    'Registration Date',
                    user.registrationDate != null
                        ? '${user.registrationDate!.day}/${user.registrationDate!.month}/${user.registrationDate!.year}'
                        : 'Unknown'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showUserDialog(context, user: user);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
