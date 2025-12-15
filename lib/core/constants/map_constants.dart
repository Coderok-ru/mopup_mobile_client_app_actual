import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Константы конфигурации карт Yandex.
class MapConstants {
  /// API-ключ Yandex MapKit и Геокодера.
  static const String mapApiKey = '55da3a31-a0c0-4799-86e7-1644e4d7a47a';

  /// Начальное положение камеры (Москва, проспект Королёва).
  static const Point defaultPoint = Point(
    latitude: 59.938784,
    longitude: 30.314997,
  );

  /// Начальное значение зума подбора адреса.
  static const double defaultZoom = 17;

  /// Минимальная задержка перед запросом обратного геокодирования.
  static const Duration geocodeDebounce = Duration(milliseconds: 800);
}
