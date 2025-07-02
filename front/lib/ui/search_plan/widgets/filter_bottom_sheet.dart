import 'package:flutter/material.dart';

import '../view_models/search_view_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final SearchViewModel viewModel;

  const FilterBottomSheet({
    super.key,
    required this.viewModel,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues? _tempDistanceRange;
  late RangeValues? _tempCostRange;
  late RangeValues? _tempDurationRange;
  late int? _tempFavoritesThreshold;
  late SortOption _tempSortBy;

  @override
  void initState() {
    super.initState();
    _tempDistanceRange = widget.viewModel.distanceRange;
    _tempCostRange = widget.viewModel.costRange;
    _tempDurationRange = widget.viewModel.durationRange;
    _tempFavoritesThreshold = widget.viewModel.favoritesThreshold;
    _tempSortBy = widget.viewModel.sortBy;
  }

  void _applyFilters() {
    widget.viewModel.distanceRange = _tempDistanceRange;
    widget.viewModel.costRange = _tempCostRange;
    widget.viewModel.durationRange = _tempDurationRange;
    widget.viewModel.favoritesThreshold = _tempFavoritesThreshold;
    widget.viewModel.sortBy = _tempSortBy;
    widget.viewModel.search.execute();
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _tempDistanceRange = null;
      _tempCostRange = null;
      _tempDurationRange = null;
      _tempFavoritesThreshold = null;
      _tempSortBy = SortOption.recent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
          ),

          // Filters content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSortSection(),
                  const SizedBox(height: 24),
                  _buildDistanceSection(),
                  const SizedBox(height: 24),
                  _buildCostSection(),
                  const SizedBox(height: 24),
                  _buildDurationSection(),
                  const SizedBox(height: 24),
                  _buildFavoritesSection(),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Appliquer les filtres',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trier par',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...SortOption.values.map((option) => RadioListTile<SortOption>(
              value: option,
              groupValue: _tempSortBy,
              onChanged: (value) => setState(() => _tempSortBy = value!),
              title: Text(_getSortLabel(option)),
              dense: true,
            )),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distance totale (mètres)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: _tempDistanceRange ?? const RangeValues(0, 10000),
          min: 0,
          max: 50000,
          divisions: 50,
          labels: RangeLabels(
            '${(_tempDistanceRange?.start ?? 0).toInt()}m',
            '${(_tempDistanceRange?.end ?? 10000).toInt()}m',
          ),
          onChanged: (values) => setState(() => _tempDistanceRange = values),
        ),
      ],
    );
  }

  Widget _buildCostSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coût total (€)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: _tempCostRange ?? const RangeValues(0, 100),
          min: 0,
          max: 500,
          divisions: 50,
          labels: RangeLabels(
            '${(_tempCostRange?.start ?? 0).toInt()}€',
            '${(_tempCostRange?.end ?? 100).toInt()}€',
          ),
          onChanged: (values) => setState(() => _tempCostRange = values),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durée totale (heures)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: _tempDurationRange ??
              const RangeValues(0, 7200), // 0-2h in seconds
          min: 0,
          max: 86400, // 24h in seconds
          divisions: 24,
          labels: RangeLabels(
            '${((_tempDurationRange?.start ?? 0) / 3600).toInt()}h',
            '${((_tempDurationRange?.end ?? 7200) / 3600).toInt()}h',
          ),
          onChanged: (values) => setState(() => _tempDurationRange = values),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre minimum de favoris',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Slider(
          value: (_tempFavoritesThreshold ?? 0).toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          label: '${_tempFavoritesThreshold ?? 0}',
          onChanged: (value) =>
              setState(() => _tempFavoritesThreshold = value.toInt()),
        ),
      ],
    );
  }

  String _getSortLabel(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.distance:
        return 'Distance';
      case SortOption.cost:
        return 'Coût';
      case SortOption.duration:
        return 'Durée';
      case SortOption.favorites:
        return 'Favoris';
      case SortOption.recent:
        return 'Plus récent';
    }
  }
}
