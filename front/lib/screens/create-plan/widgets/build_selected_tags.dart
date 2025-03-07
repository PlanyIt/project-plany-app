import 'package:flutter/material.dart';
import 'package:front/providers/create_plan_provider.dart';
import 'package:front/widgets/tag/chip_list.dart';
import 'package:provider/provider.dart';

Widget buildSelectedTags(BuildContext context) {
  final provider = Provider.of<CreatePlanProvider>(context);
  return ChipList(
    items: provider.selectedTags,
    labelBuilder: (tag) => tag.name,
    onDeleted: provider.removeTag,
  );
}
