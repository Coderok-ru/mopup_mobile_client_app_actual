import 'package:geolocator/geolocator.dart';

/// Сервис для централизованного запроса разрешений.
class PermissionsService {
  /// Проверяет, предоставлено ли разрешение на доступ к местоположению.
  Future<bool> executeCheckLocationPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Запрашивает разрешение на доступ к местоположению.
  Future<bool> executeRequestLocationPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    }

  /// Запрашивает все необходимые приложению разрешения.
  Future<void> executeRequestAllPermissions() async {
    await executeRequestLocationPermission();
  }
}


