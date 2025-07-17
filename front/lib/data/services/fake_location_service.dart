import 'package:geolocator/geolocator.dart';

import 'location_service.dart';

class FakeLocationService extends LocationService {
  FakeLocationService() : super.test();

  @override
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    return null;
  }

  @override
  Future<bool> requestLocationService() async {
    return true;
  }

}
