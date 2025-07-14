import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../utils/validation_utils.dart';

enum SortOption { cost, duration, recent, favorites }

class SearchFiltersViewModel extends ChangeNotifier {
  // --- Filtres actifs ---
  String? selectedCategory;
  RangeValues? distanceRange;
  RangeValues? costRange;
  RangeValues? durationRange;
  int? favoritesThreshold;
  SortOption sortBy = SortOption.favorites;
  bool? pmrOnly;
  LatLng? selectedLocation;
  String? selectedLocationName;
  String? keywordQuery;
  String? locationSearchQuery;

  // --- Valeurs temporaires ---
  RangeValues? _tempDistanceRange;
  String? _tempSelectedCategory;
  String _tempMinCost = '';
  String _tempMaxCost = '';
  String _tempMinDuration = '';
  String _tempMaxDuration = '';
  String _tempDurationUnit = 'h';
  int? _tempFavoritesThreshold;
  SortOption _tempSortBy = SortOption.favorites;
  bool? _tempPmrOnly;

  RangeValues? get tempDistanceRange => _tempDistanceRange;
  String? get tempSelectedCategory => _tempSelectedCategory;
  String get tempMinCost => _tempMinCost;
  String get tempMaxCost => _tempMaxCost;
  String get tempMinDuration => _tempMinDuration;
  String get tempMaxDuration => _tempMaxDuration;
  String get tempDurationUnit => _tempDurationUnit;
  int? get tempFavoritesThreshold => _tempFavoritesThreshold;
  SortOption get tempSortBy => _tempSortBy;
  bool? get tempPmrOnly => _tempPmrOnly;

  void setSelectedCategory(String? categoryId) {
    selectedCategory = categoryId;
    notifyListeners();
  }

  void setKeywordQuery(String? query) {
    final newQuery = query?.trim().isEmpty == true ? null : query?.trim();
    if (keywordQuery != newQuery) {
      keywordQuery = newQuery;
      notifyListeners();
    }
  }

  void setSelectedLocation(LatLng? location, String? name) {
    selectedLocation = location;
    selectedLocationName = name;

    if (location == null) {
      distanceRange = null;
    }

    notifyListeners();
  }

  RangeValues? get effectiveDistanceRange {
    if (selectedLocation != null) {
      return distanceRange ?? const RangeValues(0, 5000);
    }
    return null;
  }

  void setLocationSearchQuery(String? query) {
    locationSearchQuery = query;
    notifyListeners();
  }

  void initializeTempValues() {
    _tempDistanceRange = distanceRange;
    _tempSortBy = sortBy;
    _tempSelectedCategory = selectedCategory;
    _tempDurationUnit = 'h';
    _tempPmrOnly = pmrOnly;

    if (costRange != null) {
      _tempMinCost = costRange!.start.toInt().toString();
      _tempMaxCost = costRange!.end.toInt().toString();
    } else {
      _tempMinCost = '';
      _tempMaxCost = '';
    }

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
  }

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

  void updateTempPmrOnly(bool? value) {
    _tempPmrOnly = value;
    notifyListeners();
  }

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

  void setSelectedLocationWithDefaultDistance(LatLng location, String name) {
    selectedLocation = location;
    selectedLocationName = name;
    distanceRange = const RangeValues(0, 5000);
    notifyListeners();
  }

  bool applyTempFilters() {
    if (hasTempValidationErrors) return false;

    distanceRange = _tempDistanceRange;
    selectedCategory = _tempSelectedCategory;
    pmrOnly = _tempPmrOnly;

    if (_tempMinCost.isNotEmpty || _tempMaxCost.isNotEmpty) {
      final minCostValue =
          _tempMinCost.isNotEmpty ? int.tryParse(_tempMinCost) : null;
      final maxCostValue =
          _tempMaxCost.isNotEmpty ? int.tryParse(_tempMaxCost) : null;

      if (minCostValue != null || maxCostValue != null) {
        final minCost = minCostValue?.toDouble() ?? 0.0;
        final maxCost = maxCostValue?.toDouble() ?? 999999.0;
        costRange = RangeValues(minCost, maxCost);
      }
    } else {
      costRange = null;
    }

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

  void clearAllFilters() {
    selectedCategory = null;
    keywordQuery = null;
    distanceRange = null;
    costRange = null;
    durationRange = null;
    favoritesThreshold = null;
    sortBy = SortOption.favorites;
    pmrOnly = null;
    notifyListeners();
  }

  void resetTempValues() {
    _tempDistanceRange = null;
    _tempSelectedCategory = null;
    _tempMinCost = '';
    _tempMaxCost = '';
    _tempMinDuration = '';
    _tempMaxDuration = '';
    _tempDurationUnit = 'h';
    _tempFavoritesThreshold = null;
    _tempSortBy = SortOption.favorites;
    _tempPmrOnly = null;
    notifyListeners();
  }
}
