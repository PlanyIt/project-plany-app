import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/services/location_service.dart';

import '../view_models/search_view_model.dart';

class LocationIconButton extends StatelessWidget {
  final SearchViewModel viewModel;
  final LocationService locationService;
  final VoidCallback? onResetSearchField;

  const LocationIconButton({
    super.key,
    required this.viewModel,
    required this.locationService,
    this.onResetSearchField,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Ma position',
      icon: const Icon(Icons.my_location),
      onPressed: () async {
        final position =
            await locationService.getCurrentLocation(forceRefresh: true);
        if (position != null) {
          final location = LatLng(position.latitude, position.longitude);
          final name = await locationService.reverseGeocode(location) ??
              'Ma position actuelle';
          viewModel.filtersViewModel.setSelectedLocation(location, name);
          viewModel.filtersViewModel.distanceRange =
              const RangeValues(0, 10000);
          viewModel.search.execute();
          onResetSearchField?.call();
        }
      },
    );
  }
}
