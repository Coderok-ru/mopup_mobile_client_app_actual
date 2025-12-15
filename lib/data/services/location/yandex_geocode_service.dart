import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Сервис обратного геокодирования через Yandex MapKit.
class YandexGeocodeService {
  /// Выполняет обратное геокодирование точки.
  Future<String?> fetchAddress({
    required Point point,
    required int zoom,
  }) async {
    try {
      final (
        SearchSession session,
        Future<SearchSessionResult> resultFuture,
      ) = await YandexSearch.searchByPoint(
        point: point,
        zoom: zoom,
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: false,
        ),
      );

      final SearchSessionResult result = await resultFuture;
      await session.close();
      if (result.items == null || result.items!.isEmpty) {
        debugPrint(
          '[YandexGeocodeService] Нет результатов для $point (zoom $zoom)',
        );
        return null;
      }
      final String? rawAddress =
          result.items!.first.toponymMetadata?.address.formattedAddress;
      if (rawAddress == null || rawAddress.isEmpty) {
        debugPrint(
          '[YandexGeocodeService] Пустой адрес для $point (zoom $zoom)',
        );
        return null;
      }
      final String formatted = rawAddress.trim();
      debugPrint(
        '[YandexGeocodeService] Найден адрес "$formatted" для $point',
      );
      return formatted;
    } on Exception catch (error) {
      debugPrint(
        '[YandexGeocodeService] Ошибка ${error.runtimeType}: $error',
      );
      return null;
    }
  }
}
