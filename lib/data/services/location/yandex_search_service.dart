import 'package:flutter/foundation.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Модель результата поиска адреса.
class AddressSearchResult {
  /// Форматированный адрес.
  final String formattedAddress;

  /// Создает результат поиска.
  const AddressSearchResult({
    required this.formattedAddress,
  });
}

/// Сервис поиска адресов через Yandex MapKit.
class YandexSearchService {
  /// Выполняет поиск адресов по запросу в указанном городе.
  Future<List<AddressSearchResult>> searchAddresses({
    required String query,
    required String cityName,
  }) async {
    try {
      final String searchQuery = '$query, $cityName';
      final (
        SearchSession session,
        Future<SearchSessionResult> resultFuture,
      ) = await YandexSearch.searchByText(
        searchText: searchQuery,
        geometry: Geometry.fromPoint(
          const Point(latitude: 0, longitude: 0),
        ),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: false,
        ),
      );
      final SearchSessionResult result = await resultFuture;
      await session.close();
      if (result.items == null || result.items!.isEmpty) {
        debugPrint(
          '[YandexSearchService] Нет результатов для "$searchQuery"',
        );
        return <AddressSearchResult>[];
      }
      final List<AddressSearchResult> results = <AddressSearchResult>[];
      for (final SearchItem item in result.items!) {
        final String? formattedAddress =
            item.toponymMetadata?.address.formattedAddress;
        if (formattedAddress != null && formattedAddress.isNotEmpty) {
          results.add(
            AddressSearchResult(
              formattedAddress: formattedAddress,
            ),
          );
        }
      }
      debugPrint(
        '[YandexSearchService] Найдено ${results.length} результатов для "$searchQuery"',
      );
      return results;
    } on Exception catch (error) {
      debugPrint(
        '[YandexSearchService] Ошибка ${error.runtimeType}: $error',
      );
      return <AddressSearchResult>[];
    }
  }
}

