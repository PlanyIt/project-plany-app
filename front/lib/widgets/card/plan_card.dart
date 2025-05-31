import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front/models/categorie.dart';
import 'package:front/utils/icon_utils.dart';

class PlanCard extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final List<String>? imageUrls; // Liste d'URLs pour le carousel
  final String title;
  final String description;
  final Category? category;
  final int stepsCount;
  final String? cost; // Coût total
  final String? duration; // Durée totale
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;

  const PlanCard({
    Key? key,
    this.imagePath,
    this.imageUrl,
    this.imageUrls,
    required this.title,
    required this.description,
    this.category,
    this.stepsCount = 0,
    this.cost,
    this.duration,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    // Réduire la hauteur de l'image de 180 à 150
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: _ImageCarousel(
            imageUrls: imageUrls!,
          ),
        ),
      );
    } else if (imagePath != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Image.file(
          File(imagePath!),
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Image.network(
          imageUrl!,
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 150,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderImage(),
        ),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 100, // Placeholder plus petit
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.image,
          size: 30, // Icône plus petite
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), // Padding réduit
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Première ligne: Titre et badge catégorie
          Row(
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? 'Sans titre' : title,
                  style: const TextStyle(
                    fontSize: 16, // Taille réduite
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (category != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getIconData(category!.icon),
                        size: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category!.name,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6), // Espacement réduit

          // Description
          Text(
            description.isEmpty ? 'Aucune description' : description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Ligne informations: coût, durée et étapes
          Row(
            children: [
              // Coût
              if (cost != null)
                _buildCompactInfo(context, null, "Environ $cost"),

              if (cost != null) const SizedBox(width: 16),

              // Durée
              if (duration != null)
                _buildCompactInfo(context, Icons.access_time, duration!),

              if (duration != null) const SizedBox(width: 16),

              // Nombre d'étapes
              _buildCompactInfo(context, Icons.list_alt, "$stepsCount étapes"),
            ],
          ),

        ],
      ),
    );
  }

  // Version compacte des infos
  Widget _buildCompactInfo(BuildContext context, IconData? icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 14,
              color: Colors.grey[600],
            ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}

// Carousel d'images avec moins d'espace
class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const _ImageCarousel({
    required this.imageUrls,
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (_controller.page != null && _controller.page!.round() != _currentPage) {
      setState(() {
        _currentPage = _controller.page!.round();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPageChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            final imageUrl = widget.imageUrls[index];

            return Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 30, // Plus petit
                    color: Colors.grey[400],
                  ),
                ),
              ),
            );
          },
        ),

        // Indicateurs de pagination plus compacts
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 6, // Plus proche du bord
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == index ? 12 : 6, // Plus petit
                  height: 6, // Plus petit
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _currentPage == index
                        ? const Color(0xFF3425B5)
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
