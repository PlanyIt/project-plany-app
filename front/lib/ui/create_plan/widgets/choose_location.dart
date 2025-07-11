import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../services/location_service.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/search_bar/search_bar.dart';
import '../view_models/choose_location_view_model.dart';

class ChooseLocation extends StatefulWidget {
  final Function(LatLng location, String locationName) onLocationSelected;
  final LatLng? initialLocation;

  const ChooseLocation({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late ChooseLocationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChooseLocationViewModel(
      locationService: Provider.of<LocationService>(context, listen: false),
    );
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initializeLocation(widget.initialLocation);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.selectedLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          _viewModel.selectedLocation!,
          _viewModel.selectedLocationName == 'Ma position actuelle'
              ? 15.0
              : 15.0,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un lieu'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (!_viewModel.isLoadingCurrentLocation)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _viewModel.getCurrentLocation,
              tooltip: 'Ma position',
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return Stack(
            children: [
              // Carte
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _viewModel.selectedLocation ??
                      const LatLng(48.856614, 2.3522219),
                  initialZoom:
                      _viewModel.selectedLocation != null ? 15.0 : 13.0,
                  onTap: (tapPosition, point) => _viewModel.onMapTap(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.app',
                    retinaMode: true,
                  ),
                  if (_viewModel.selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: _viewModel.selectedLocation!,
                          child: Icon(
                            Icons.location_on,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Loading indicator
              if (_viewModel.isLoadingCurrentLocation)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Barre de recherche et résultats
              _buildSearchSection(),

              // Bouton de confirmation
              if (_viewModel.canConfirmSelection) _buildConfirmButton(),

              // Instructions
              if (!_viewModel.canConfirmSelection &&
                  !_viewModel.isLoadingCurrentLocation)
                _buildInstructions(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchSection() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          DashboardSearchBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            hintText: 'Rechercher un lieu...',
            onChanged: _viewModel.onSearchChanged,
            autofocus: false,
          ),

          // Résultats de recherche
          if (_viewModel.searchResults.isNotEmpty || _viewModel.isSearching)
            _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _viewModel.isSearching
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _viewModel.searchResults.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final result = _viewModel.searchResults[index];
                return ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: AppTheme.primaryColor,
                  ),
                  title: Text(
                    result.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    result.description,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    _viewModel.selectSearchResult(result);
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                  },
                );
              },
            ),
    );
  }

  Widget _buildConfirmButton() {
    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: ElevatedButton(
        onPressed: () {
          widget.onLocationSelected(
            _viewModel.selectedLocation!,
            _viewModel.selectedLocationName,
          );
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Confirmer la sélection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Touchez la carte pour sélectionner un lieu ou utilisez la barre de recherche',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
