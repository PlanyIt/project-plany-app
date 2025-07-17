import 'package:front/data/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class FakeLocationService extends LocationService {
  Position? fakePosition;
  bool fakeLoading = false;
  String? fakeErrorMessage;
  bool fakePermissionDenied = false;
  bool fakeServiceDisabled = false;

  FakeLocationService({
    this.fakePosition,
    this.fakeLoading = false,
    this.fakeErrorMessage,
    this.fakePermissionDenied = false,
    this.fakeServiceDisabled = false,
  }) : super.test();

  @override
  Position? get currentPosition => fakePosition;

  @override
  bool get isLoading => fakeLoading;

  @override
  String? get errorMessage => fakeErrorMessage;

  @override
  bool get hasLocation => fakePosition != null;

  @override
  bool get permissionDenied => fakePermissionDenied;

  @override
  bool get serviceDisabled => fakeServiceDisabled;

  @override
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    return fakePosition;
  }

  @override
  Future<bool> requestLocationService() async {
    fakeServiceDisabled = false;
    notifyListeners();
    return true;
  }

  @override
  double? calculateDistanceToPoint(double latitude, double longitude) {
    if (fakePosition == null) return null;
    return Geolocator.distanceBetween(
      fakePosition!.latitude,
      fakePosition!.longitude,
      latitude,
      longitude,
    );
  }

  @override
  Future<List<LocationResult>> searchLocationByName(String query) async {
    return [
      LocationResult(
        name: 'Paris',
        description: 'France',
        location: LatLng(48.8566, 2.3522),
      ),
    ];
  }

  @override
  Future<String?> reverseGeocode(LatLng location) async {
    return 'Fake Address, Paris, France';
  }
}
