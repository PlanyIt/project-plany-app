import 'package:flutter/material.dart';

import 'view_models/detail/favorite_viewmodel.dart';
import 'view_models/detail/follow_user_viewmodel.dart';
import 'view_models/detail/plan_details_viewmodel.dart';
import 'widgets/content/plan_content.dart';
import 'widgets/header/details_header.dart';

class PlanDetailsScreen extends StatefulWidget {
  final String planId;
  final PlanDetailsViewModel planVM;
  final FavoriteViewModel favoriteVM;
  final FollowUserViewModel followVM;

  const PlanDetailsScreen({
    super.key,
    required this.planId,
    required this.planVM,
    required this.favoriteVM,
    required this.followVM,
  });

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  final DraggableScrollableController _bottomSheetController =
      DraggableScrollableController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await widget.planVM.loadPlan(widget.planId);

    if (widget.planVM.plan != null) {
      await widget.favoriteVM.initFavoriteStatus(widget.planId);
      await widget.followVM.initFollowStatus(widget.planVM.plan!.user);
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _bottomSheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.planVM,
        widget.favoriteVM,
        widget.followVM,
      ]),
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              DetailsHeader(
                planViewModel: widget.planVM,
                favoriteViewModel: widget.favoriteVM,
                followViewModel: widget.followVM,
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.2,
                minChildSize: 0.2,
                maxChildSize: 0.9,
                controller: _bottomSheetController,
                builder: (context, scrollController) {
                  return PlanContent(
                    scrollController: scrollController,
                    planViewModel: widget.planVM,
                    favoriteViewModel: widget.favoriteVM,
                    followViewModel: widget.followVM,
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
