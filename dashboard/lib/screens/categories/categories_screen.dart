import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/providers/category_provider.dart';
import 'package:dashboard/models/category.dart' as app_category;

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final filteredCategories = categoryProvider.categories.where((category) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return category.name.toLowerCase().contains(query) ||
          (category.description?.toLowerCase().contains(query) ?? false);
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
                  'Categories',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showCategoryDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Category'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
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
            if (categoryProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (categoryProvider.error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading categories',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(categoryProvider.error!),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        categoryProvider.fetchCategories();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (filteredCategories.isEmpty)
              const Center(
                child: Text('No categories found'),
              )
            else
              // Category grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 1200
                        ? 4
                        : MediaQuery.of(context).size.width > 800
                            ? 3
                            : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return _buildCategoryCard(context, category);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, app_category.Category category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Provider.of<CategoryProvider>(context, listen: false)
              .setSelectedCategory(category);
          _showCategoryDetailsDialog(context, category);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      _showCategoryDialog(context, category: category);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (category.description != null &&
                  category.description!.isNotEmpty)
                Expanded(
                  child: Text(
                    category.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Show the icon
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Text(
                      category.icon,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  // Status indicator
                  Chip(
                    label: Text(
                      category.isActive == true ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: category.isActive == true
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: category.isActive == true
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context,
      {app_category.Category? category}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.name ?? '');
    final iconController = TextEditingController(text: category?.icon ?? '🏷️');
    final descriptionController =
        TextEditingController(text: category?.description ?? '');
    bool isActive = category?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category != null ? 'Edit Category' : 'Add Category'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter category name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: iconController,
                    decoration: const InputDecoration(
                      labelText: 'Icon (Emoji)',
                      hintText: 'Enter an emoji as icon',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an icon';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter category description',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (value) {
                      isActive = value;
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
                  // Save category
                  final categoryProvider =
                      Provider.of<CategoryProvider>(context, listen: false);
                  final updatedCategory = app_category.Category(
                    id: category?.id,
                    name: nameController.text,
                    icon: iconController.text,
                    description: descriptionController.text,
                    isActive: isActive,
                  );

                  if (category != null && category.id != null) {
                    categoryProvider.updateCategory(
                        category.id!, updatedCategory);
                  } else {
                    categoryProvider.createCategory(updatedCategory);
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text(category != null ? 'Save' : 'Create'),
            ),
          ],
        );
      },
    );
  }

  void _showCategoryDetailsDialog(
      BuildContext context, app_category.Category category) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Category Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Text(
                      category.icon,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    category.isActive == true ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color:
                          category.isActive == true ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const Divider(),
                if (category.description != null &&
                    category.description!.isNotEmpty) ...[
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(category.description!),
                  const Divider(),
                ],
                // Here you could add more information like number of plans in this category
                const Text(
                  'Associated Plans:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Loading plans count...'),
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (category.id != null) {
                  categoryProvider.deleteCategory(category.id!);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCategoryDialog(context, category: category);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }
}
