import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../data/services/share_service.dart';
import '../../../../../domain/models/plan/plan.dart';
import '../../../../../domain/models/step/step.dart' as plan_steps;
import '../../../../../utils/helpers.dart';
import '../../../../../utils/icon_utils.dart';
import '../../../view_models/detail/favorite_viewmodel.dart';
import '../../../view_models/detail/follow_user_viewmodel.dart';
import '../../../view_models/detail/plan_details_viewmodel.dart';

class PlanInfoSection extends StatelessWidget {
  final PlanDetailsViewModel viewModel;
  final FavoriteViewModel favoriteViewModel;
  final FollowUserViewModel followViewModel;

  const PlanInfoSection({
    super.key,
    required this.viewModel,
    required this.favoriteViewModel,
    required this.followViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final planData =
        _calculatePlanData(viewModel.steps, viewModel.plan!.totalDuration);
    final formattedDate = viewModel.plan!.createdAt != null
        ? "${viewModel.plan!.createdAt!.day}/${viewModel.plan!.createdAt!.month}/${viewModel.plan!.createdAt!.year}"
        : "Non défini";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlanHeader(context, viewModel.plan!, planData),
        const SizedBox(height: 20),
        _buildAuthorSection(context, viewModel.plan!),
        const SizedBox(height: 20),
        _buildIndicators(formattedDate, planData),
        const SizedBox(height: 24),
        _buildDescription(viewModel.plan!),
      ],
    );
  }

  Map<String, dynamic> _calculatePlanData(
      List<plan_steps.Step>? steps, int? totalDuration) {
    if (steps == null || steps.isEmpty) {
      return {'cost': 0.0, 'duration': "0 minutes"};
    }
    final totalCost = calculateTotalStepsCost(steps);
    final duration = formatDurationToString(totalDuration ?? 0);
    return {'cost': totalCost, 'duration': duration};
  }

  Widget _buildPlanHeader(
      BuildContext context, Plan plan, Map<String, dynamic> planData) {
    final isFavorite = favoriteViewModel.isFavorite;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorFromPlanCategory(plan.category?.color) ??
                Colors.blue.withValues(alpha: 0.6),
            colorFromPlanCategory(plan.category?.color) ??
                Colors.blue.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  capitalize(plan.title),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              _favoritesBadge(plan.favorites?.length ?? 0),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _categoryChip(
                  plan.category?.id, plan.category?.name, plan.category?.icon),
              const Spacer(),
              _actionButton(
                icon: Icons.share,
                onPressed: () =>
                    ShareService.sharePlan(plan, plan.favorites?.length ?? 0),
              ),
              const SizedBox(width: 8),
              _actionButton(
                icon: isFavorite ? Icons.star : Icons.star_border,
                onPressed: () =>
                    favoriteViewModel.toggleFavorite(plan, viewModel),
                iconColor: isFavorite ? Colors.amber : Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _favoritesBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.shade400.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.star, size: 18, color: Colors.amber.shade100),
          const SizedBox(width: 4),
          Text('$count',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _categoryChip(String? id, String? categoryName, String? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(getIconData(icon ?? "category"), size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(categoryName ?? id ?? '',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor ?? Colors.white, size: 20),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildAuthorSection(BuildContext context, Plan plan) {
    final user = plan.user;
    if (user == null) {
      return _infoCard("Informations sur l'auteur non disponibles");
    }

    final isFollowing = followViewModel.isFollowing;
    final isLoading = followViewModel.isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: _cardDecoration(),
      child: InkWell(
        onTap: () => viewModel.navigateToUserProfile(context, user.id),
        child: Row(
          children: [
            _avatar(user.photoUrl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(user.username,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (user.isPremium) _premiumBadge(plan),
                  ]),
                  const SizedBox(height: 4),
                  Text("${user.followers.length} abonnés",
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            viewModel.isCurrentUserPlan
                ? _userPlanChip()
                : _followButton(isFollowing, isLoading, () {
                    followViewModel.toggleFollow(plan.user, viewModel);
                  }),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String? url) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: url != null && url.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.person, size: 30, color: Colors.grey[600]),
              ),
            )
          : Icon(Icons.person, size: 30, color: Colors.grey[600]),
    );
  }

  Widget _premiumBadge(Plan plan) {
    final color = colorFromPlanCategory(plan.category?.color) ?? Colors.blue;
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Icon(Icons.verified, size: 14, color: color),
          const SizedBox(width: 2),
          Text("Premium", style: TextStyle(fontSize: 12, color: color))
        ],
      ),
    );
  }

  Widget _followButton(bool isFollowing, bool isLoading, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Icon(
                isFollowing ? Icons.person_remove : Icons.person_add_rounded,
                color: Colors.white,
                size: 18),
          ),
        ),
      ),
    );
  }

  Widget _userPlanChip() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
      child: Text("Votre plan",
          style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 12)),
    );
  }

  Widget _infoCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Center(child: Text(message)),
    );
  }

  Widget _buildIndicators(String formattedDate, Map<String, dynamic> planData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _indicator(Icons.calendar_today, "Ajouté le", formattedDate,
            Colors.purple.shade50, Colors.purple.shade700),
        _indicator(
            Icons.euro_rounded,
            "Coût total",
            "${(planData['cost'] as double).toStringAsFixed(2)} €",
            Colors.green.shade50,
            Colors.green.shade700),
        _indicator(
            Icons.timelapse_rounded,
            "Durée",
            planData['duration'] as String,
            Colors.blue.shade50,
            Colors.blue.shade700),
      ],
    );
  }

  Widget _indicator(IconData icon, String label, String value, Color bgColor,
      Color iconColor) {
    return Container(
      width: 90,
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
          const SizedBox(height: 2),
          FittedBox(
              child: Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey[800]))),
        ],
      ),
    );
  }

  Widget _buildDescription(Plan plan) {
    final color = colorFromPlanCategory(plan.category?.color) ?? Colors.blue;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote, size: 30, color: color.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            capitalize(plan.description),
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.8,
                fontStyle: FontStyle.italic),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(child: Divider(color: color.withOpacity(0.2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                      "Par ${plan.user?.username ?? "Utilisateur Plany"}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.grey.withValues(alpha: .1), blurRadius: 8)
      ],
    );
  }

  String capitalize(String text) {
    return text.isNotEmpty ? text[0].toUpperCase() + text.substring(1) : text;
  }
}
