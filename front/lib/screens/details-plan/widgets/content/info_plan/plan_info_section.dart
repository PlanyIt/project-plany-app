import 'package:flutter/material.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as plan_steps;
import 'package:front/domain/models/user.dart';
import 'package:front/screens/profile/profile_screen.dart';
import 'package:front/services/plan_service.dart';
import 'package:front/services/user_service.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/utils/helpers.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:share_plus/share_plus.dart';

class PlanInfoSection extends StatefulWidget {
  final Plan plan;
  final Color categoryColor;
  final String? categoryName;
  final String? categoryIcon;
  final List<plan_steps.Step>? steps;

  const PlanInfoSection({
    super.key,
    required this.plan,
    required this.categoryColor,
    this.categoryName,
    this.categoryIcon,
    this.steps,
  });

  @override
  PlanInfoSectionState createState() => PlanInfoSectionState();
}

class PlanInfoSectionState extends State<PlanInfoSection> {
  bool _isFavorite = false;
  bool _isProcessing = false;
  int _favoritesCount = 0;
  bool _isLoadingAuthor = true;
  bool _isFollowing = false;
  bool _isLoadingFollow = false;
  User? _authorProfile;
  String? _currentUserId;
  final PlanService _planService = PlanService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.plan.isFavorite;
    _favoritesCount = widget.plan.favorites?.length ?? 0;
    _loadCurrentUserAndAuthor();
  }

  Future<void> _loadCurrentUserAndAuthor() async {
    try {
      _currentUserId = await _authService.getCurrentUserId();
      _loadAuthorProfile();
    } catch (e) {
      print('Erreur lors du chargement de l\'ID utilisateur: $e');
      _loadAuthorProfile(); // Charger quand même le profil auteur
    }
  }

  String get capitalizedTitle => widget.plan.title.isNotEmpty
      ? widget.plan.title[0].toUpperCase() + widget.plan.title.substring(1)
      : widget.plan.title;

  String get capitalizedDescription => widget.plan.description.isNotEmpty
      ? widget.plan.description[0].toUpperCase() +
          widget.plan.description.substring(1)
      : widget.plan.description;

  double get totalCost {
    final data = _calculatePlanDataSync();
    return data['cost'] as double;
  }

  String get formattedDuration {
    final data = _calculatePlanDataSync();
    return data['duration'] as String;
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_isFavorite) {
        await _planService.removeFromFavorites(widget.plan.id!);
        setState(() {
          _isFavorite = false;
          _favoritesCount--;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Plan retiré de vos favoris"),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 2),
        ));
      } else {
        await _planService.addToFavorites(widget.plan.id!);
        setState(() {
          _isFavorite = true;
          _favoritesCount++;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[300])),
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
            onPressed: () async {
              final userId = await _authService.getCurrentUserId();
              if (userId != null && mounted) {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      userId: userId,
                      isCurrentUser: true,
                    ),
                  ),
                )
                    .then((_) {
                  Navigator.of(context)
                      .push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SizedBox(),
                    transitionDuration: Duration.zero,
                    opaque: false,
                    maintainState: true,
                  ))
                      .then((_) {
                    Navigator.of(context).pop();
                  });
                });
              }
            },
          ),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _loadAuthorProfile() async {
    if (widget.plan.userId == null || widget.plan.userId!.isEmpty) {
      setState(() => _isLoadingAuthor = false);
      return;
    }

    setState(() => _isLoadingAuthor = true);

    try {
      final author = await _userService.getUserProfile(widget.plan.userId!);

      bool isFollowing = false;
      if (_currentUserId != null && _currentUserId != widget.plan.userId) {
        isFollowing = await _userService.isFollowing(author.id);
      }

      setState(() {
        _authorProfile = author;
        _isFollowing = isFollowing;
        _isLoadingAuthor = false;
      });
    } catch (e) {
      print('Erreur lors du chargement du profil de l\'auteur: $e');
      setState(() => _isLoadingAuthor = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_isLoadingFollow || _authorProfile == null) return;

    setState(() => _isLoadingFollow = true);

    try {
      final success = _isFollowing
          ? await _userService.unfollowUser(_authorProfile!.id)
          : await _userService.followUser(_authorProfile!.id);

      if (success) {
        setState(() => _isFollowing = !_isFollowing);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFollowing
                ? 'Vous suivez maintenant ${_authorProfile!.username}'
                : 'Vous ne suivez plus ${_authorProfile!.username}'),
            backgroundColor: widget.categoryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'abonnement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => _isLoadingFollow = false);
    }
  }

  void _navigateToAuthorProfile(BuildContext context) {
    if (_authorProfile == null) return;

    // Utiliser directement _currentUserId au lieu de FirebaseAuth
    final isOwnPlan =
        _currentUserId != null && _currentUserId == widget.plan.userId;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userId: _authorProfile!.id,
          isCurrentUser: isOwnPlan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlanHeaderCard(context),
        const SizedBox(height: 20),
        _buildAuthorSection(context),
        const SizedBox(height: 20),
        _buildPlanIndicators(context),
        const SizedBox(height: 24),
        _buildPlanDescription(context),
      ],
    );
  }

  Widget _buildPlanHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.categoryColor.withValues(alpha: 0.6),
            widget.categoryColor.withValues(alpha: 0.5),
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
                  capitalizedTitle,
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
                      widget.categoryName ?? widget.plan.category,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _sharePlan(context),
                  icon: const Icon(Icons.share, color: Colors.white, size: 16),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: _isProcessing
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
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          _isFavorite ? Icons.star : Icons.star_border,
                          color: _isFavorite ? Colors.amber : Colors.white,
                          size: 22,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection(BuildContext context) {
    if (_isLoadingAuthor) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
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
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_authorProfile == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
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
        ),
        child: const Center(
          child: Text("Informations sur l'auteur non disponibles"),
        ),
      );
    }

    final String followers = "${_authorProfile!.followersCount ?? 0}";

    final isOwnPlan =
        _currentUserId != null && _currentUserId == widget.plan.userId;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
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
      ),
      child: InkWell(
        onTap: () => _navigateToAuthorProfile(context),
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
              child: _authorProfile!.photoUrl != null &&
                      _authorProfile!.photoUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        _authorProfile!.photoUrl!,
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
                          _authorProfile?.username ?? "Auteur inconnu",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_authorProfile != null &&
                          _authorProfile!.isPremium == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  size: 14, color: widget.categoryColor),
                              const SizedBox(width: 2),
                              Text(
                                "Premium",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.categoryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$followers abonnés",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (!isOwnPlan) ...{
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.categoryColor,
                      widget.categoryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: widget.categoryColor.withValues(alpha: 0.3),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: _isLoadingFollow
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
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
              ),
            } else ...{
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
            },
          ],
        ),
      ),
    );
  }

  Widget _buildPlanIndicators(BuildContext context) {
    String formattedDate = "Non défini";
    if (widget.plan.createdAt != null) {
      final DateTime createdAt = widget.plan.createdAt!;
      formattedDate = "${createdAt.day}/${createdAt.month}/${createdAt.year}";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        //TODO pour Premium
        // _buildIndicatorBadge(
        //   context: context,
        //   icon: Icons.workspace_premium,
        //   label: "Premium",
        //   Tode public:
        //   ignore: dead_code
        //   value: isPublic ? "Oui" : "Non",
        //   bgColor: Colors.amber.shade100,
        //   iconColor: Colors.amber.shade800,
        // ),
        _buildIndicatorBadge(
          context: context,
          icon: Icons.calendar_today,
          label: "Ajouté le",
          value: formattedDate,
          bgColor: Colors.purple.shade50,
          iconColor: Colors.purple.shade700,
        ),
        _buildIndicatorBadge(
          context: context,
          icon: Icons.euro_rounded,
          label: "Coût total",
          value: "${totalCost.toStringAsFixed(2)} €",
          bgColor: Colors.green.shade50,
          iconColor: Colors.green.shade700,
        ),
        _buildIndicatorBadge(
          context: context,
          icon: Icons.timelapse_rounded,
          label: "Durée",
          value: formattedDuration,
          bgColor: Colors.blue.shade50,
          iconColor: Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildIndicatorBadge({
    required BuildContext context,
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
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
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

  Widget _buildPlanDescription(BuildContext context) {
    final String authorName = _authorProfile?.username ?? "Utilisateur Plany";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
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
          color: widget.categoryColor.withValues(alpha: 0.1),
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
              color: widget.categoryColor.withValues(alpha: 0.3),
            ),
          ),
          Text(
            capitalizedDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.8,
              letterSpacing: 0.3,
              fontStyle: FontStyle.italic,
              shadows: [
                Shadow(
                  blurRadius: 0.5,
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 0.5),
                ),
              ],
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
                          widget.categoryColor.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
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

  Future<void> _sharePlan(BuildContext context) async {
    try {
      final String planUrl =
          "https://plany.app/plans/${widget.plan!.id}"; // TODO: Remplacez par le vrai URL
      final String shareText =
          "🗺️ Découvrez ce plan \"${capitalizedTitle}\" sur Plany!\n\n"
          "📍 ${widget.categoryName}\n"
          "⏱️ 10 min\n"
          "💰 10 €\n\n"
          "${capitalizedDescription.length > 100 ? '${capitalizedDescription.substring(0, 100)}...' : capitalizedDescription}\n\n"
          "Voir le plan complet: $planUrl";

      await Share.share(shareText, subject: 'Découvrez ce plan Plany');

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ouverture des options de partage...")));
    } catch (e) {
      print("Erreur lors du partage: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur lors du partage: $e")));
    }
  }

  Map<String, dynamic> _calculatePlanDataSync() {
    if (widget.steps == null || widget.steps!.isEmpty) {
      return {
        'cost': 0.0,
        'duration': "0 min",
      };
    }

    try {
      final totalCost = calculateTotalStepsCost(widget.steps!);
      final totalDuration = calculateTotalStepsDuration(widget.steps!);

      return {
        'cost': totalCost,
        'duration': totalDuration,
      };
    } catch (e) {
      print("_calculatePlanDataSync: Erreur - $e");
      return {
        'cost': 0.0,
        'duration': "0 min",
      };
    }
  }
}
