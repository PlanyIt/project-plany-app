import 'dart:io';
import 'package:flutter/material.dart';
import '../../../widgets/card/compact_plan_card.dart';
import '../../core/themes/app_theme.dart';
import '../view_models/create_plan_view_model.dart';
import 'step_card_timeline.dart';

class StepThreeContent extends StatefulWidget {
  const StepThreeContent({super.key, required this.viewModel});

  final CreatePlanViewModel viewModel;

  @override
  State<StepThreeContent> createState() => _StepThreeContentState();
}

class _StepThreeContentState extends State<StepThreeContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      physics: const BouncingScrollPhysics(),
      // On utilise Container avec fond blanc pour assurer la cohérence
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Aperçu final'),
            const SizedBox(height: 16),
            _buildPlanPreview(context),
            const SizedBox(height: 24),
            if (widget.viewModel.stepCards.isNotEmpty) ...[
              _buildSectionTitle(context, 'Étapes'),
              const SizedBox(height: 16),
              _buildStepsList(),
              const SizedBox(height: 24),
            ],
            _buildPublishCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentColor,
            const Color(0xFFFF5A85),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presque terminé !',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Vérifiez les détails de votre plan avant de le publier. Vous pourrez le modifier ultérieurement.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanPreview(BuildContext context) {
    final stepImages = widget.viewModel.stepCards
        .where((step) => step.imageUrl.isNotEmpty)
        .map((step) => step.imageUrl)
        .toList();

    // Calculate total cost and duration from step cards
    double totalCost = 0;
    var totalDurationMinutes = 0;

    for (final step in widget.viewModel.stepCards) {
      if (step.cost != null) {
        totalCost += step.cost!;
      }

      if (step.duration != null && step.duration!.isNotEmpty) {
        // Convert duration to minutes based on unit
        final durationValue = int.tryParse(step.duration!) ?? 0;
        if (step.durationUnit == 'Heures') {
          totalDurationMinutes += durationValue * 60;
        } else if (step.durationUnit == 'Minutes') {
          totalDurationMinutes += durationValue;
        } else if (step.durationUnit == 'Jours') {
          totalDurationMinutes += durationValue * 24 * 60;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CompactPlanCard(
            title: widget.viewModel.titlePlanController.text,
            description: widget.viewModel.descriptionPlanController.text,
            category: widget.viewModel.selectedCategory,
            stepsCount: widget.viewModel.stepCards.length,
            borderRadius: BorderRadius.circular(16),
            imageUrls: stepImages.isEmpty ? null : stepImages,
            totalCost: totalCost > 0 ? totalCost : null,
            totalDuration:
                totalDurationMinutes > 0 ? totalDurationMinutes : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.viewModel.stepCards.length,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemBuilder: (context, index) {
          final step = widget.viewModel.stepCards[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StepCardTimeline(
              index: index,
              isFirst: index == 0,
              isLast: index == widget.viewModel.stepCards.length - 1,
              title: step.title,
              description: step.description,
              imagePath: step.imageUrl.isNotEmpty ? step.imageUrl : null,
              duration: step.duration,
              durationUnit: step.durationUnit,
              cost: step.cost,
              locationName: step.locationName,
              themeColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPublishCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.public,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Prêt à publier ?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'En publiant ce plan, vous le rendez visible par tous les utilisateurs de l\'application. Vous pourrez le modifier ou le supprimer ultérieurement depuis votre profil.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Vos coordonnées ne sont pas partagées',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Vous pouvez modifier ce plan à tout moment',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  final List<String> images;

  const ImageCarousel({
    super.key,
    required this.images,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          // Images du carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final imagePath = widget.images[index];
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildErrorImage(),
                      )
                    : Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildErrorImage(),
                      ),
              );
            },
          ),

          // Indicateurs de pagination
          if (widget.images.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.primaryColor
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 3,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Numéro de l'image actuelle
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey.shade200,
      height: 180,
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
