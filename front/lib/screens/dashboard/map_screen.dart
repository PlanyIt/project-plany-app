import 'package:flutter/material.dart';
import 'package:front/models/step.dart' as step_plan;
import 'package:front/services/step_service.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  loc.Location location = loc.Location();
  GeoPoint? currentLocation;
  MapController? mapController;
  final List<GeoPoint> _markers = [];
  StepService stepService = StepService();
  step_plan.Step? selectedStep;
  final TextEditingController _addressController = TextEditingController();

  // Method to get current location
  void _getCurrentLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    final locData = await location.getLocation();

    print(locData.latitude);
    print(locData.longitude);
    setState(() {
      currentLocation = GeoPoint(
        latitude: locData.latitude!,
        longitude: locData.longitude!,
      );
      _markers.add(currentLocation!);
    });

    // Initialize mapController only after currentLocation is set
    if (currentLocation != null) {
      mapController = MapController(
        initMapWithUserPosition: UserTrackingOption(
          enableTracking: true,
        ),
      );
    }
  }

  // Fetch steps from the server
  void _fetchSteps() async {
    try {
      List<step_plan.Step> steps = await stepService.fetchSteps();
      setState(() {
        for (var step in steps) {
          _markers.add(step.position);
        }
      });
    } catch (e) {
      print('Failed to load steps: $e');
    }
  }

  // Search address using the API
  void _searchAddress() async {
    if (mapController == null) return; // Check if mapController is initialized

    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${_addressController.text}&format=json&addressdetails=1'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final location = data.first;
          final newLocation = GeoPoint(
              latitude: double.parse(location['lat']),
              longitude: double.parse(location['lon']));
          mapController!
              .goToLocation(newLocation); // Move the map to the new location
          setState(() {
            _markers.add(newLocation);
          });
        }
      }
    } catch (e) {
      print('Failed to search address: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize map controller after currentLocation is fetched
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Displaying map
          if (mapController != null)
            OSMFlutter(
              controller: mapController!,
              osmOption: OSMOption(
                staticPoints: [
                  StaticPositionGeoPoint(
                    'markers',
                    MarkerIcon(
                      icon: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    _markers,
                  ),
                ],
                userLocationMarker: UserLocationMaker(
                  personMarker: MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  directionArrowMarker: MarkerIcon(
                    icon: Icon(
                      Icons.double_arrow,
                      size: 48,
                    ),
                  ),
                ),
                roadConfiguration: RoadOption(
                  roadColor: Colors.yellowAccent,
                ),
              ),
              onMapIsReady: (isReady) {
                if (isReady && currentLocation != null) {
                  mapController!.moveTo(currentLocation!);
                }
              },
            ),

          // Address search input
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _searchAddress,
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: 'Enter address',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searchAddress,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // Step details sheet
          if (selectedStep != null)
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.2,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedStep!.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(selectedStep!.description),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => print('Go to step detail'),
                          child: const Text('Voir les détails'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
