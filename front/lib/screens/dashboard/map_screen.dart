import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:front/services/step_service.dart';
import 'package:front/models/steps.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

const kGoogleApiKey = "AIzaSyA1UfERSP4_VsZducsVQo94S6ltS7XIUhg"; // Remplacez par votre clé API

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  loc.Location location = loc.Location();
  LatLng? currentLocation;
  Set<Marker> _markers = {};
  StepService stepService = StepService();
  Steps? selectedStep;
  TextEditingController _addressController = TextEditingController();
  late GoogleMapsPlaces places;

  @override
  void initState() {
    super.initState();
    places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
      _fetchSteps();
    });
  }

  void _getCurrentLocation() async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    final locData = await location.getLocation();
    setState(() {
      currentLocation = LatLng(locData.latitude!, locData.longitude!);
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: currentLocation!,
          infoWindow: InfoWindow(title: 'Ma position actuelle'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    if (mapController != null && currentLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(currentLocation!),
      );
    }
  }

  void _fetchSteps() async {
    try {
      List<Steps> steps = await stepService.fetchSteps(); // Remplacez 'planId' par l'ID réel du plan
      setState(() {
        for (var step in steps) {
          _markers.add(
            Marker(
              markerId: MarkerId(step.id),
              position: step.position,
              infoWindow: InfoWindow(title: step.title),
              onTap: () {
                setState(() {
                  selectedStep = step;
                });
              },
            ),
          );
        }
      });
    } catch (e) {
      print('Failed to load steps: $e');
    }
  }

  void _searchAddress() async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(_addressController.text);
      if (locations.isNotEmpty) {
        final LatLng newLocation = LatLng(locations.first.latitude, locations.first.longitude);
        mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId('searchedLocation'),
              position: newLocation,
              infoWindow: InfoWindow(title: 'Searched Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          );
        });
      }
    } catch (e) {
      print('Failed to search address: $e');
    }
  }

  Future<void> _handlePressButton() async {
    try {
      Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        mode: Mode.overlay, // Mode.fullscreen
        language: "fr",
        components: [Component(Component.country, "fr")],
      );

      if (p != null) {
        _displayPrediction(p);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _displayPrediction(Prediction p) async {
    try {
      PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('searchedLocation'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: p.description),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: currentLocation ?? LatLng(46.1603, -1.1515),
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _handlePressButton,
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _handlePressButton,
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          if (selectedStep != null)
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.2,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedStep!.title,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(selectedStep!.description),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => print('Go to step detail'),
                          child: Text('Voir les détails'),
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