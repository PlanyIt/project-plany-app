import 'package:flutter/material.dart';

class GridSelectorModal<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final Function(T) onItemSelected;
  final String title;
  final Widget Function(BuildContext, T, bool) itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;
  final Color? backgroundColor;
  final double? maxHeightFactor;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const GridSelectorModal({
    super.key,
    required this.items,
    this.selectedItem,
    required this.onItemSelected,
    required this.title,
    required this.itemBuilder,
    this.crossAxisCount = 3,
    this.childAspectRatio = 0.8,
    this.backgroundColor,
    this.maxHeightFactor = 0.7,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeightFactor != null
            ? screenSize.height * maxHeightFactor!
            : double.infinity,
      ),
      padding: EdgeInsets.only(
        top: 16.0,
        left: 24.0,
        right: 24.0,
        bottom: 24.0 + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
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
          const SizedBox(height: 16),

          // Title with close button
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (showCloseButton)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (onClose != null) {
                      onClose!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  tooltip: 'Fermer',
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Items grid - now with SingleChildScrollView for better scrolling experience
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
                physics: const NeverScrollableScrollPhysics(),
                children: items.map((item) {
                  final bool isSelected = selectedItem == item;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onItemSelected(item);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: itemBuilder(context, item, isSelected),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to show the modal
  static Future<T?> show<T>({
    required BuildContext context,
    required List<T> items,
    T? selectedItem,
    required Function(T) onItemSelected,
    required String title,
    required Widget Function(BuildContext, T, bool) itemBuilder,
    int crossAxisCount = 3,
    double childAspectRatio = 0.8,
    Color? backgroundColor,
    double? maxHeightFactor = 0.7,
    bool showCloseButton = true,
    bool barrierDismissible = true,
    RouteSettings? routeSettings,
  }) {
    // Fermer le clavier avant d'afficher la modale
    FocusScope.of(context).unfocus();

    return showModalBottomSheet<T>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      barrierColor: Colors.black54,
      elevation: 16,
      isDismissible: barrierDismissible,
      enableDrag: true,
      routeSettings: routeSettings,
      builder: (context) {
        return SafeArea(
          bottom: false,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: GridSelectorModal<T>(
              items: items,
              selectedItem: selectedItem,
              onItemSelected: onItemSelected,
              title: title,
              itemBuilder: itemBuilder,
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              backgroundColor: backgroundColor,
              maxHeightFactor: maxHeightFactor,
              showCloseButton: showCloseButton,
              onClose: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}
