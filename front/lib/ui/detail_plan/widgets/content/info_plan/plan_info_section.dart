import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../domain/models/plan/plan.dart';
import '../../../../../domain/models/step/step.dart' as plan_steps;
import '../../../../../screens/profile/profile_screen.dart';
import '../../../../../utils/helpers.dart';
import '../../../../../utils/icon_utils.dart';
import '../../../view_models/plan_details_viewmodel.dart';

class PlanInfoSection extends StatefulWidget {
  final Plan plan;
  final String? categoryName;
  final String? categoryIcon;
  final List<plan_steps.Step>? steps;
  final PlanDetailsViewModel viewModel;

  const PlanInfoSection({
    super.key,
    required this.plan,
    this.categoryName,
    this.categoryIcon,
    this.steps,
    required this.viewModel,
  });

  @override
  PlanInfoSectionState createState() => PlanInfoSectionState();
}

class PlanInfoSectionState extends State<PlanInfoSection> {
  bool _isFavorite = false;
  bool _isProcessing = false;
  int _favoritesCount = 0;
  bool _isFollowing = false;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.plan.isFavorite;
    _favoritesCount = widget.plan.favorites?.length ?? 0;

    _initializeFollowStatus();
  }

  Future<void> _initializeFollowStatus() async {
    if (widget.plan.user != null && !_isCurrentUserPlan) {
      try {
        final isFollowing =
            await widget.viewModel.isFollowing(widget.plan.user!.id ?? '');
        setState(() => _isFollowing = isFollowing);
      } catch (e) {
        print('Erreur lors de la vérification du statut de suivi: $e');
      }
    }
  }

  bool get _isCurrentUserPlan =>
      widget.viewModel.currentUser?.id == widget.plan.user?.id;

  String get _capitalizedTitle => widget.plan.title.isNotEmpty
      ? widget.plan.title[0].toUpperCase() + widget.plan.title.substring(1)
      : widget.plan.title;

  String get _capitalizedDescription => widget.plan.description.isNotEmpty
      ? widget.plan.description[0].toUpperCase() +
          widget.plan.description.substring(1)
      : widget.plan.description;

  // Optimize: Calculate plan data only once
  late final Map<String, dynamic> _planData = _calculatePlanData();

  Map<String, dynamic> _calculatePlanData() {
    if (widget.steps == null || widget.steps!.isEmpty) {
      return {'cost': 0.0, 'duration': "0 minutes"};
    }

    try {
      final totalCost = calculateTotalStepsCost(widget.steps!);
      final totalDuration =
          formatDurationToString(widget.plan.totalDuration ?? 0);
      return {'cost': totalCost, 'duration': totalDuration};
    } catch (e) {
      print("Erreur calcul données plan: $e");
      return {'cost': 0.0, 'duration': "0 minutes"};
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (_isFavorite) {
        widget.viewModel.removeFromFavorites();
        setState(() {
          _isFavorite = false;
          _favoritesCount--;
        });
        _showSnackBar("Plan retiré de vos favoris", Colors.grey[800]!);
      } else {
        widget.viewModel.addToFavorites();
        setState(() {
          _isFavorite = true;
          _favoritesCount++;
        });
        _showFavoriteAddedSnackBar();
      }
    } catch (e) {
      _showSnackBar("Erreur: $e", Colors.red);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  void _showFavoriteAddedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Plan ajouté à vos favoris",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Retrouvez-le dans votre profil",
                      style: TextStyle(fontSize: 12, color: Colors.grey[300])),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VOIR',
          textColor: Colors.amber,
          onPressed: () => _navigateToProfile(isCurrentUser: true),
        ),
      ),
    );
  }

  Future<void> _toggleFollow() async {
    if (_isLoadingFollow || widget.plan.user == null || _isCurrentUserPlan)
      return;

    setState(() => _isLoadingFollow = true);

    try {
      if (_isFollowing) {
        await widget.viewModel.unfollowUser(widget.plan.user!.id ?? '');
      } else {
        await widget.viewModel.followUser(widget.plan.user!.id ?? '');
      }

      setState(() => _isFollowing = !_isFollowing);
      _showSnackBar(
        _isFollowing
            ? 'Vous suivez maintenant ${widget.plan.user!.username}'
            : 'Vous ne suivez plus ${widget.plan.user!.username}',
        colorFromPlanCategory(widget.plan.category?.color) ?? Colors.blue,
      );
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    } finally {
      setState(() => _isLoadingFollow = false);
    }
  }

  void _navigateToProfile({bool isCurrentUser = false}) {
    final userId =
        isCurrentUser ? widget.viewModel.currentUser?.id : widget.plan.user?.id;
    if (userId == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userId: userId,
          isCurrentUser: isCurrentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlanHeaderCard(),
        const SizedBox(height: 20),
        _buildAuthorSection(),
        const SizedBox(height: 20),
        _buildPlanIndicators(),
        const SizedBox(height: 24),
        _buildPlanDescription(),
      ],
    );
  }

  Widget _buildPlanHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorFromPlanCategory(widget.plan.category?.color) ??
                Colors.blue.withValues(alpha: 0.6),
            colorFromPlanCategory(widget.plan.category?.color) ??
                Colors.blue.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                  _capitalizedTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.amber.shade400.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 18, color: Colors.amber.shade100),
                    const SizedBox(width: 4),
                    Text(
                      "$_favoritesCount",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getIconData(widget.categoryIcon ?? "category"),
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.categoryName ?? widget.plan.category?.id ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildActionButton(
                icon: Icons.share,
                onPressed: _sharePlan,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: _isFavorite ? Icons.star : Icons.star_border,
                onPressed: _toggleFavorite,
                isLoading: _isProcessing,
                iconColor: _isFavorite ? Colors.amber : Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: isLoading
          ? Container(
              padding: const EdgeInsets.all(8),
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: iconColor ?? Colors.white, size: 20),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
    );
  }

  Widget _buildAuthorSection() {
    if (widget.plan.user == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Center(
          child: Text("Informations sur l'auteur non disponibles"),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: _cardDecoration(),
      child: InkWell(
        onTap: () => _navigateToProfile(),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: widget.plan.user!.photoUrl?.isNotEmpty == true
                  ? ClipOval(
                      child: Image.network(
                        widget.plan.user!.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey[600]),
                      ),
                    )
                  : Icon(Icons.person, size: 30, color: Colors.grey[600]),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.plan.user?.username ?? "Auteur inconnu",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.plan.user?.isPremium == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorFromPlanCategory(
                                    widget.plan.category?.color) ??
                                Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  size: 14,
                                  color: colorFromPlanCategory(
                                          widget.plan.category?.color) ??
                                      Colors.blue),
                              const SizedBox(width: 2),
                              Text(
                                "Premium",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorFromPlanCategory(
                                          widget.plan.category?.color) ??
                                      Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.plan.user!.followers.length} abonnés",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (!_isCurrentUserPlan)
              _buildFollowButton()
            else
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  "Votre plan",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorFromPlanCategory(widget.plan.category?.color) ?? Colors.blue,
            colorFromPlanCategory(widget.plan.category?.color) ??
                Colors.blue.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorFromPlanCategory(widget.plan.category?.color) ??
                Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleFollow,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _isLoadingFollow
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isFollowing
                        ? Icons.person_remove
                        : Icons.person_add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanIndicators() {
    final formattedDate = widget.plan.createdAt != null
        ? "${widget.plan.createdAt!.day}/${widget.plan.createdAt!.month}/${widget.plan.createdAt!.year}"
        : "Non défini";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIndicatorBadge(
          icon: Icons.calendar_today,
          label: "Ajouté le",
          value: formattedDate,
          bgColor: Colors.purple.shade50,
          iconColor: Colors.purple.shade700,
        ),
        _buildIndicatorBadge(
          icon: Icons.euro_rounded,
          label: "Coût total",
          value: "${(_planData['cost'] as double).toStringAsFixed(2)} €",
          bgColor: Colors.green.shade50,
          iconColor: Colors.green.shade700,
        ),
        _buildIndicatorBadge(
          icon: Icons.timelapse_rounded,
          label: "Durée",
          value: _planData['duration'] as String,
          bgColor: Colors.blue.shade50,
          iconColor: Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildIndicatorBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDescription() {
    final authorName = widget.plan.user?.username ?? "Utilisateur Plany";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorFromPlanCategory(widget.plan.category?.color) ??
              Colors.blue.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Icon(
              Icons.format_quote,
              size: 30,
              color: colorFromPlanCategory(widget.plan.category?.color) ??
                  Colors.blue.withValues(alpha: 0.3),
            ),
          ),
          Text(
            _capitalizedDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.8,
              letterSpacing: 0.3,
              fontStyle: FontStyle.italic,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorFromPlanCategory(widget.plan.category?.color) ??
                              Colors.blue.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Par $authorName",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
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
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Future<void> _sharePlan() async {
    try {
      final String planUrl = "https://plany.app/plans/${widget.plan.id}";
      final String shareText =
          "🗺️ Découvrez ce plan \"$_capitalizedTitle\" sur Plany!\n\n"
          "📍 ${widget.categoryName}\n"
          "⏱️ ${_planData['duration']}\n"
          "💰 ${(_planData['cost'] as double).toStringAsFixed(2)} €\n\n"
          "${_capitalizedDescription.length > 100 ? '${_capitalizedDescription.substring(0, 100)}...' : _capitalizedDescription}\n\n"
          "Voir le plan complet: $planUrl";

      await Share.share(shareText, subject: 'Découvrez ce plan Plany');
    } catch (e) {
      _showSnackBar("Erreur lors du partage: $e", Colors.red);
    }
  }
}
