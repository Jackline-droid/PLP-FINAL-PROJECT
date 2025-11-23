import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Request location permissions
  static Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get last known location (faster, may be outdated)
  static Future<Position?> getLastKnownLocation() async {
    try {
      bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        return null;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      print('Error getting last known location: $e');
      return null;
    }
  }

  /// Fuzzify location for privacy (round to nearest block)
  static Map<String, double> fuzzifyLocation(double latitude, double longitude) {
    // Round to approximately 100m precision (roughly a city block)
    const double fuzzFactor = 0.001; // ~100m
    
    return {
      'latitude': (latitude / fuzzFactor).round() * fuzzFactor,
      'longitude': (longitude / fuzzFactor).round() * fuzzFactor,
    };
  }
}

