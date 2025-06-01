import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/providers/plan_provider.dart';
import 'package:dashboard/providers/category_provider.dart';
import 'package:dashboard/models/plan.dart';
import 'package:intl/intl.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlanProvider>(context, listen: false).fetchPlans();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    // Filter plans based on search query and selected category
    final filteredPlans = planProvider.plans.where((plan) {
      // Filter by search query
      final matchesQuery = _searchQuery.isEmpty ||
          plan.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          plan.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by selected category
      final matchesCategory =
          _selectedCategory == null || plan.category == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header and filters row
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Plans',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                if (!categoryProvider.isLoading &&
                    categoryProvider.categories.isNotEmpty)
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String?>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Filter by Category',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...categoryProvider.categories.map((category) {
                          return DropdownMenuItem<String?>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement plan creation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Plan creation is not implemented in this demo'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Plan'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search plans...',
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

            // Loading indicator or error message
            if (planProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (planProvider.error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading plans',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(planProvider.error!),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        planProvider.fetchPlans();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (filteredPlans.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No plans found matching your criteria'),
                ),
              )
            else
              // Plans list
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPlans.length,
                  itemBuilder: (context, index) {
                    final plan = filteredPlans[index];
                    return _buildPlanCard(context, plan, categoryProvider);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
      BuildContext context, Plan plan, CategoryProvider categoryProvider) {
    // Find the category name from the ID
    String categoryName = 'Unknown Category';
    final category = categoryProvider.categories.firstWhere(
      (c) => c.id == plan.category,
      orElse: () => categoryProvider.categories.first,
    );
    categoryName = category.name;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          plan.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Category: $categoryName',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Created: ${plan.createdAt != null ? DateFormat.yMMMd().format(plan.createdAt!) : 'Unknown'}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showPlanDetailsDialog(context, plan);
              },
            ),
            IconButton(
              icon: Icon(
                plan.isPublic ? Icons.public : Icons.public_off,
                color: plan.isPublic ? Colors.green : Colors.red,
              ),
              onPressed: () {
                // Toggle plan visibility
                if (plan.id != null) {
                  final updatedPlan = plan.copyWith(isPublic: !plan.isPublic);
                  Provider.of<PlanProvider>(context, listen: false)
                      .updatePlan(plan.id!, updatedPlan);
                }
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(plan.description),
                const SizedBox(height: 16),
                const Text(
                  'Steps:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (plan.steps.isEmpty)
                  const Text('No steps available')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: plan.steps.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(plan.steps[index]),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Views: ${plan.viewCount ?? 0}'),
                    Text('Likes: ${plan.likeCount ?? 0}'),
                    Text('Saves: ${plan.saveCount ?? 0}'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Delete plan
                        if (plan.id != null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: Text(
                                  'Are you sure you want to delete "${plan.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Provider.of<PlanProvider>(context,
                                            listen: false)
                                        .deletePlan(plan.id!);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showPlanDetailsDialog(context, plan);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Plan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanDetailsDialog(BuildContext context, Plan plan) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: plan.title);
    final descriptionController = TextEditingController(text: plan.description);
    bool isPublic = plan.isPublic;
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    String selectedCategory = plan.category;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Plan'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter plan title',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter plan description',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: categoryProvider.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id ?? '',
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Public'),
                    value: isPublic,
                    onChanged: (value) {
                      isPublic = value;
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
                if (formKey.currentState!.validate() && plan.id != null) {
                  // Save plan
                  final planProvider =
                      Provider.of<PlanProvider>(context, listen: false);
                  final updatedPlan = plan.copyWith(
                    title: titleController.text,
                    description: descriptionController.text,
                    category: selectedCategory,
                    isPublic: isPublic,
                  );

                  planProvider.updatePlan(plan.id!, updatedPlan);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
