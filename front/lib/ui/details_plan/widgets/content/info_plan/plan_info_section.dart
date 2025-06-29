import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as plan_steps;
import 'package:front/domain/models/user/user.dart';
import 'package:share_plus/share_plus.dart';

// Providers pour l'état de la section plan info
final planFavoriteStateProvider =
    StateProvider.family<bool, String>((ref, planId) => false);
final planFavoritesCountProvider =
    StateProvider.family<int, String>((ref, planId) => 0);
final planAuthorProvider =
    StateProvider.family<User?, String>((ref, planId) => null);
final planFollowStateProvider =
    StateProvider.family<bool, String>((ref, userId) => false);
final planProcessingStateProvider =
    StateProvider.family<bool, String>((ref, planId) => false);

class PlanInfoSection extends ConsumerStatefulWidget {
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
  ConsumerState<PlanInfoSection> createState() => _PlanInfoSectionState();
}

class _PlanInfoSectionState extends ConsumerState<PlanInfoSection> {
  @override
  void initState() {
    super.initState();
    // Initialiser les providers avec les valeurs du plan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planFavoriteStateProvider(widget.plan.id!).notifier).state =
          widget.plan.isFavorite;
      ref.read(planFavoritesCountProvider(widget.plan.id!).notifier).state =
          widget.plan.favorites.length;
      _loadAuthorProfile();
    });
  }

  Future<void> _loadAuthorProfile() async {
    if (widget.plan.userId == null || widget.plan.userId!.isEmpty) {
      return;
    }

    try {
      // Simuler le chargement du profil utilisateur
      // Dans une vraie app, ceci ferait appel à un repository
      final mockUser = User(
        id: widget.plan.userId!,
        username: 'Utilisateur Plany',
        email: 'user@plany.com',
        followersCount: 42,
      );

      ref.read(planAuthorProvider(widget.plan.id!).notifier).state = mockUser;
    } catch (e) {
      print('Erreur lors du chargement du profil de l\'auteur: $e');
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
    final isProcessing = ref.read(planProcessingStateProvider(widget.plan.id!));
    if (isProcessing) return;

    ref.read(planProcessingStateProvider(widget.plan.id!).notifier).state =
        true;

    try {
      final isFavorite = ref.read(planFavoriteStateProvider(widget.plan.id!));
      final favoritesCount =
          ref.read(planFavoritesCountProvider(widget.plan.id!));

      if (isFavorite) {
        // Simuler la suppression des favoris
        ref.read(planFavoriteStateProvider(widget.plan.id!).notifier).state =
            false;
        ref.read(planFavoritesCountProvider(widget.plan.id!).notifier).state =
            favoritesCount - 1;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Plan retiré de vos favoris"),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 2),
        ));
      } else {
        // Simuler l'ajout aux favoris
        ref.read(planFavoriteStateProvider(widget.plan.id!).notifier).state =
            true;
        ref.read(planFavoritesCountProvider(widget.plan.id!).notifier).state =
            favoritesCount + 1;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(
            children: [
              Icon(Icons.favorite, color: Colors.white),
              SizedBox(width: 8),
              Text("Plan ajouté à vos favoris"),
            ],
          ),
          backgroundColor: Colors.grey[850],
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      ref.read(planProcessingStateProvider(widget.plan.id!).notifier).state =
          false;
    }
  }

  Future<void> _toggleFollow() async {
    final authorProfile = ref.read(planAuthorProvider(widget.plan.id!));
    if (authorProfile == null) return;

    try {
      final isFollowing = ref.read(planFollowStateProvider(authorProfile.id));
      ref.read(planFollowStateProvider(authorProfile.id).notifier).state =
          !isFollowing;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(!isFollowing
            ? 'Vous suivez maintenant ${authorProfile.username}'
            : 'Vous ne suivez plus ${authorProfile.username}'),
        backgroundColor: Colors.grey[800],
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(planFavoriteStateProvider(widget.plan.id!));
    final favoritesCount =
        ref.watch(planFavoritesCountProvider(widget.plan.id!));
    final isProcessing =
        ref.watch(planProcessingStateProvider(widget.plan.id!));
    final authorProfile = ref.watch(planAuthorProvider(widget.plan.id!));
    final isFollowing = authorProfile != null
        ? ref.watch(planFollowStateProvider(authorProfile.id))
        : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlanHeaderCard(context, isFavorite, favoritesCount, isProcessing),
        const SizedBox(height: 16),
        _buildAuthorSection(context, authorProfile, isFollowing),
        const SizedBox(height: 16),
        _buildPlanIndicators(context),
        const SizedBox(height: 16),
        _buildPlanDescription(context, authorProfile),
      ],
    );
  }

  Widget _buildPlanHeaderCard(BuildContext context, bool isFavorite,
      int favoritesCount, bool isProcessing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  capitalizedTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: isProcessing ? null : _toggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _sharePlan(context),
                    icon: const Icon(Icons.share),
                  ),
                ],
              ),
            ],
          ),
          if (favoritesCount > 0)
            Text(
              '$favoritesCount favoris',
              style: TextStyle(color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection(
      BuildContext context, User? authorProfile, bool isFollowing) {
    if (authorProfile == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text('Auteur non disponible'),
      );
    }

    final String followers = "${authorProfile.followersCount ?? 0}";

    // Pour simuler si c'est le plan de l'utilisateur actuel
    const isOwnPlan = false; // Peut être modifié selon la logique métier

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: authorProfile.photoUrl != null
                ? NetworkImage(authorProfile.photoUrl!)
                : null,
            child: authorProfile.photoUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authorProfile.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$followers abonnés',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (!isOwnPlan)
            ElevatedButton(
              onPressed: _toggleFollow,
              child: Text(isFollowing ? 'Abonné' : 'S\'abonner'),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanIndicators(BuildContext context) {
    String formattedDate = "Non défini";
    if (widget.plan.createdAt != null) {
      final date = widget.plan.createdAt!;
      formattedDate =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    return Row(
      children: [
        Expanded(
          child: _buildIndicatorBadge(
            context: context,
            icon: Icons.schedule,
            label: 'Durée',
            value: formattedDuration,
            bgColor: Colors.blue.withOpacity(0.1),
            iconColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildIndicatorBadge(
            context: context,
            icon: Icons.euro,
            label: 'Coût',
            value: '${totalCost.toStringAsFixed(0)}€',
            bgColor: Colors.green.withOpacity(0.1),
            iconColor: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildIndicatorBadge(
            context: context,
            icon: Icons.calendar_today,
            label: 'Créé le',
            value: formattedDate,
            bgColor: Colors.orange.withOpacity(0.1),
            iconColor: Colors.orange,
          ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDescription(BuildContext context, User? authorProfile) {
    final String authorName = authorProfile?.username ?? "Utilisateur Plany";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos de ce plan',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            capitalizedDescription,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            'Par $authorName',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePlan(BuildContext context) async {
    try {
      await Share.share(
        'Découvrez ce plan: ${widget.plan.title}\n${widget.plan.description}',
        subject: widget.plan.title,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du partage: $e')),
      );
    }
  }

  Map<String, dynamic> _calculatePlanDataSync() {
    if (widget.steps == null || widget.steps!.isEmpty) {
      return {
        'cost': 0.0,
        'duration': '0 min',
      };
    }

    try {
      double totalCost = 0.0;
      int totalDurationMinutes = 0;
      for (final step in widget.steps!) {
        totalCost += step.cost ?? 0.0;
        final stepDuration = step.duration;
        if (stepDuration != null) {
          // Convertir la durée en int selon son type
          final parsed = int.tryParse(stepDuration.toString());
          if (parsed != null) {
            totalDurationMinutes += parsed;
          }
        }
      }

      String formattedDuration;
      if (totalDurationMinutes < 60) {
        formattedDuration = '${totalDurationMinutes} min';
      } else {
        final hours = totalDurationMinutes ~/ 60;
        final minutes = totalDurationMinutes % 60;
        if (minutes == 0) {
          formattedDuration = '${hours}h';
        } else {
          formattedDuration = '${hours}h ${minutes}min';
        }
      }

      return {
        'cost': totalCost,
        'duration': formattedDuration,
      };
    } catch (e) {
      print('Erreur dans le calcul des données du plan: $e');
      return {
        'cost': 0.0,
        'duration': '0 min',
      };
    }
  }
}
