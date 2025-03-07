import 'package:flutter/material.dart';
import 'package:front/providers/create_plan_provider.dart';
import 'package:provider/provider.dart';

Widget buildTagSelector(BuildContext context) {
  final provider = Provider.of<CreatePlanProvider>(context);
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        TextField(
          controller: provider.tagSearchPlanController,
          decoration: InputDecoration(
            hintText: "Rechercher tags",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: provider.tagSearchPlanController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: provider.clearTagSearch,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(12),
                bottom: Radius.circular(provider.showTagContainer ? 0 : 12),
              ),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(12),
                bottom: Radius.circular(provider.showTagContainer ? 0 : 12),
              ),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(12),
                bottom: Radius.circular(provider.showTagContainer ? 0 : 12),
              ),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
          onChanged: provider.filterTags,
          onTap: () => provider.setShowTagContainer(true),
        ),
        if (provider.showTagContainer)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              border: Border.all(
                color: Colors.grey[300]!,
              ),
            ),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            child: provider.filteredTags.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Aucun tag trouvé',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: provider.filteredTags.length > 5
                        ? 5
                        : provider.filteredTags.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey[200],
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final tag = provider.filteredTags[index];
                      final isSelected = provider.selectedTags.contains(tag);
                      return ListTile(
                        dense: true,
                        title: Text(
                          tag.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : const Icon(Icons.add_circle_outline),
                        onTap: () {
                          provider.toggleTag(tag);
                          provider.setShowTagContainer(false);
                        },
                      );
                    },
                  ),
          ),
      ],
    ),
  );
}
