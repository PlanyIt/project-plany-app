import 'package:flutter/material.dart';

class GridSelectorModal<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final Function(T) onItemSelected;
  final String title;
  final Widget Function(BuildContext, T, bool) itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;

  const GridSelectorModal({
    super.key,
    required this.items,
    this.selectedItem,
    required this.onItemSelected,
    required this.title,
    required this.itemBuilder,
    this.crossAxisCount = 3,
    this.childAspectRatio = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16.0,
        left: 24.0,
        right: 24.0,
        bottom: 24.0 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Items grid
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
            childAspectRatio: childAspectRatio,
            physics: const NeverScrollableScrollPhysics(),
            children: items.map((item) {
              final bool isSelected = selectedItem == item;

              return InkWell(
                onTap: () {
                  onItemSelected(item);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: itemBuilder(context, item, isSelected),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Helper method to show the modal
  static void show<T>({
    required BuildContext context,
    required List<T> items,
    T? selectedItem,
    required Function(T) onItemSelected,
    required String title,
    required Widget Function(BuildContext, T, bool) itemBuilder,
    int crossAxisCount = 3,
    double childAspectRatio = 0.8,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => GridSelectorModal<T>(
        items: items,
        selectedItem: selectedItem,
        onItemSelected: onItemSelected,
        title: title,
        itemBuilder: itemBuilder,
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
      ),
    );
  }
}
