import 'package:flutter/material.dart';
import 'view_models/plan_details_viewmodel.dart';
import 'widgets/content/plan_content.dart';
import 'widgets/header/details_header.dart';

class PlanDetailsScreen extends StatefulWidget {
  const PlanDetailsScreen({
    super.key,
    required this.vm,
  });

  final PlanDetailsViewModel vm;

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  final DraggableScrollableController _bottomSheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _bottomSheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, _) {
        if (!widget.vm.isPlanInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              DetailsHeader(
                viewModel: widget.vm,
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.2,
                minChildSize: 0.2,
                maxChildSize: 0.9,
                controller: _bottomSheetController,
                builder: (context, scrollController) {
                  return PlanContent(
                    scrollController: scrollController,
                    planViewModel: widget.vm,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
