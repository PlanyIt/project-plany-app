import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChooseLocation extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;
  final LatLng? initialLocation;

  const ChooseLocation({
    Key? key,
    required this.onLocationSelected,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<ChooseLocation> createState() => ChooseLocationState();
}

class ChooseLocationState extends State<ChooseLocation> {
  LatLng? currentLocation;
  final MapController mapController = MapController();
  final List<Marker> _markers = [];
  String addressName = "";
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _isLoading = false;
            currentLocation = LatLng(48.8566, 2.3522); // Default to Paris
          });
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() {
            _isLoading = false;
            currentLocation = LatLng(48.8566, 2.3522); // Default to Paris
          });
          return;
        }
      }

      final locationData = await location.getLocation();
      final position = LatLng(locationData.latitude!, locationData.longitude!);

      setState(() {
        currentLocation = position;
        _isLoading = false;
      });

      await _getAddressFromLatLng(position);
    } catch (e) {
      setState(() {
        _isLoading = false;
        currentLocation = LatLng(48.8566, 2.3522); // Default to Paris
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng point) async {
    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          addressName = data['display_name'] ?? "Unknown location";
          _markers.clear();
          _markers.add(
            Marker(
              point: point,
              width: 80,
              height: 80,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        addressName = "Unable to get address";
      });
    }
  }

  void _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final location = data[0];
          final newLocation = LatLng(
              double.parse(location['lat']), double.parse(location['lon']));

          setState(() {
            currentLocation = newLocation;
            addressName = location['display_name'];
            _markers.clear();
            _markers.add(
              Marker(
                point: newLocation,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
            );
          });

          mapController.move(newLocation, 15.0);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchLocation(_searchController.text),
                ),
              ),
              onSubmitted: _searchLocation,
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentLocation ?? LatLng(48.8566, 2.3522),
                initialZoom: 15.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    currentLocation = point;
                    _markers.clear();
                    _markers.add(
                      Marker(
                        point: point,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    );
                  });
                  _getAddressFromLatLng(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.plany.app',
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Location:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(addressName),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: currentLocation != null
                        ? () => widget.onLocationSelected(
                            currentLocation!, addressName)
                        : null,
                    child: Text('Use This Location'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
