import 'package:flutter/material.dart';
import '../../../utils/validation_utils.dart';

/// Critères de tri disponibles
enum SortOption { cost, duration, favorites, recent }

/// ViewModel pour la gestion des filtres de recherche
class SearchFiltersViewModel extends ChangeNotifier {
  // --- Filtres actifs ---
  String? selectedCategory;
  String? searchQuery;
  RangeValues? distanceRange; // en mètres
  RangeValues? costRange; // unités monétaires
  RangeValues? durationRange; // en secondes
  int? favoritesThreshold; // nb minimum de favoris
  SortOption sortBy = SortOption.recent;

  // --- Valeurs temporaires pour le formulaire ---
  RangeValues? _tempDistanceRange;
  String? _tempSelectedCategory;
  String _tempMinCost = '';
  String _tempMaxCost = '';
  String _tempMinDuration = '';
  String _tempMaxDuration = '';
  String _tempDurationUnit = 'h';
  int? _tempFavoritesThreshold;
  SortOption _tempSortBy = SortOption.recent;

  // Getters pour les valeurs temporaires
  RangeValues? get tempDistanceRange => _tempDistanceRange;
  String? get tempSelectedCategory => _tempSelectedCategory;
  String get tempMinCost => _tempMinCost;
  String get tempMaxCost => _tempMaxCost;
  String get tempMinDuration => _tempMinDuration;
  String get tempMaxDuration => _tempMaxDuration;
  String get tempDurationUnit => _tempDurationUnit;
  int? get tempFavoritesThreshold => _tempFavoritesThreshold;
  SortOption get tempSortBy => _tempSortBy;

  /// Définit la catégorie sélectionnée
  void setSelectedCategory(String? categoryId) {
    selectedCategory = categoryId;
    notifyListeners();
  }

  /// Définit la requête de recherche
  void setSearchQuery(String? query) {
    final newQuery = query?.trim().isEmpty == true ? null : query?.trim();
    if (searchQuery != newQuery) {
      searchQuery = newQuery;
      notifyListeners();
    }
  }

  /// Initialise les valeurs temporaires avec les valeurs actuelles
  void initializeTempValues() {
    _tempDistanceRange = distanceRange;
    _tempSortBy = sortBy;
    _tempSelectedCategory = selectedCategory;
    _tempDurationUnit = 'h';

    // Cost
    if (costRange != null) {
      _tempMinCost = costRange!.start.toInt().toString();
      _tempMaxCost = costRange!.end.toInt().toString();
    } else {
      _tempMinCost = '';
      _tempMaxCost = '';
    }

    // Duration
    if (durationRange != null) {
      final startMinutes = (durationRange!.start / 60).round();
      final endMinutes = (durationRange!.end / 60).round();
      _tempMinDuration = (startMinutes / 60).round().toString();
      _tempMaxDuration = (endMinutes / 60).round().toString();
    } else {
      _tempMinDuration = '';
      _tempMaxDuration = '';
    }

    _tempFavoritesThreshold = favoritesThreshold;

    // Ne pas notifier ici pour éviter les cycles
    // notifyListeners();
  }

  /// Met à jour les valeurs temporaires
  void updateTempDistanceRange(RangeValues? values) {
    _tempDistanceRange = values;
    notifyListeners();
  }

  void updateTempSelectedCategory(String? categoryId) {
    _tempSelectedCategory = categoryId;
    notifyListeners();
  }

  void updateTempCost({String? minCost, String? maxCost}) {
    if (minCost != null) _tempMinCost = minCost;
    if (maxCost != null) _tempMaxCost = maxCost;
    notifyListeners();
  }

  void updateTempDuration({String? minDuration, String? maxDuration}) {
    if (minDuration != null) _tempMinDuration = minDuration;
    if (maxDuration != null) _tempMaxDuration = maxDuration;
    notifyListeners();
  }

  void updateTempDurationUnit(String unit) {
    _tempDurationUnit = unit;
    notifyListeners();
  }

  void updateTempFavoritesThreshold(int? threshold) {
    _tempFavoritesThreshold = threshold;
    notifyListeners();
  }

  void updateTempSortBy(SortOption sortOption) {
    _tempSortBy = sortOption;
    notifyListeners();
  }

  /// Validation
  String? validateCostRange(String? minValue, String? maxValue) {
    return ValidationUtils.validateRange(
      minValue: minValue,
      maxValue: maxValue,
      fieldName: 'prix',
    );
  }

  String? validateDurationRange(String? minValue, String? maxValue) {
    return ValidationUtils.validateRange(
      minValue: minValue,
      maxValue: maxValue,
      fieldName: 'durée',
    );
  }

  String? get costValidationError =>
      validateCostRange(_tempMinCost, _tempMaxCost);
  String? get durationValidationError =>
      validateDurationRange(_tempMinDuration, _tempMaxDuration);

  bool get hasTempValidationErrors =>
      costValidationError != null || durationValidationError != null;

  String? getFieldError(String fieldName) {
    switch (fieldName) {
      case 'prix':
        return costValidationError;
      case 'durée':
        return durationValidationError;
      default:
        return null;
    }
  }

  /// Applique les valeurs temporaires comme filtres définitifs
  bool applyTempFilters() {
    if (hasTempValidationErrors) return false;

    distanceRange = _tempDistanceRange;
    selectedCategory = _tempSelectedCategory;

    // Cost range - support pour min ou max seul
    if (_tempMinCost.isNotEmpty || _tempMaxCost.isNotEmpty) {
      final minCostValue =
          _tempMinCost.isNotEmpty ? int.tryParse(_tempMinCost) : null;
      final maxCostValue =
          _tempMaxCost.isNotEmpty ? int.tryParse(_tempMaxCost) : null;

      if (minCostValue != null || maxCostValue != null) {
        // Utiliser 0 comme minimum par défaut et une valeur très élevée comme maximum par défaut
        final minCost = minCostValue?.toDouble() ?? 0.0;
        final maxCost = maxCostValue?.toDouble() ?? 999999.0;
        costRange = RangeValues(minCost, maxCost);
      }
    } else {
      costRange = null;
    }

    // Duration range - support pour min ou max seul
    if (_tempMinDuration.isNotEmpty || _tempMaxDuration.isNotEmpty) {
      final minDurationValue =
          _tempMinDuration.isNotEmpty ? int.tryParse(_tempMinDuration) : null;
      final maxDurationValue =
          _tempMaxDuration.isNotEmpty ? int.tryParse(_tempMaxDuration) : null;

      if (minDurationValue != null || maxDurationValue != null) {
        final minMinutes = minDurationValue != null
            ? _convertToMinutes(minDurationValue, _tempDurationUnit)
            : 0;
        final maxMinutes = maxDurationValue != null
            ? _convertToMinutes(maxDurationValue, _tempDurationUnit)
            : 999999;
        // Stocker en secondes comme avant
        durationRange = RangeValues(
            (minMinutes * 60).toDouble(), (maxMinutes * 60).toDouble());
      }
    } else {
      durationRange = null;
    }

    favoritesThreshold = _tempFavoritesThreshold;
    sortBy = _tempSortBy;

    notifyListeners();
    return true;
  }

  /// Convertit une valeur vers des minutes selon l'unité
  int _convertToMinutes(int value, String unit) {
    switch (unit.toLowerCase()) {
      case 'min':
        return value;
      case 'h':
        return value * 60;
      case 'j':
        return value * 24 * 60;
      default:
        return value;
    }
  }

  /// Remet à zéro tous les filtres
  void clearAllFilters() {
    selectedCategory = null;
    searchQuery = null;
    distanceRange = null;
    costRange = null;
    durationRange = null;
    favoritesThreshold = null;
    sortBy = SortOption.recent;
    notifyListeners();
  }

  /// Remet à zéro les valeurs temporaires
  void resetTempValues() {
    _tempDistanceRange = null;
    _tempSelectedCategory = null;
    _tempMinCost = '';
    _tempMaxCost = '';
    _tempMinDuration = '';
    _tempMaxDuration = '';
    _tempDurationUnit = 'h';
    _tempFavoritesThreshold = null;
    _tempSortBy = SortOption.recent;
    notifyListeners();
  }
}
