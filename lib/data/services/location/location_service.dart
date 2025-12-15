import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Сервис для работы с геолокацией устройства.
class LocationService {
  /// Определяет текущую позицию, запрашивая разрешения при необходимости.
  Future<Point?> fetchCurrentPoint() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final Position currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return Point(
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
    );
  }
}
