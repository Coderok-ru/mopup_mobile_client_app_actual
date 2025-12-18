import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/auth/city_entity.dart';
import '../../data/models/auth/user_entity.dart';
import '../../data/services/location/yandex_geocode_service.dart';
import '../../data/services/location/yandex_search_service.dart';
import '../controllers/auth_controller.dart';

/// Контроллер экрана поиска адреса.
class AddressSearchController extends GetxController {
  /// Сервис поиска адресов.
  final YandexSearchService searchService;

  /// Сервис геокодинга.
  final YandexGeocodeService geocodeService;

  /// Контроллер ввода адреса.
  final TextEditingController searchController = TextEditingController();

  /// Контроллер города (только для отображения).
  final TextEditingController cityController = TextEditingController();

  /// Список результатов поиска.
  final RxList<AddressSearchResult> searchResults = <AddressSearchResult>[].obs;

  /// Признак выполнения поиска.
  final RxBool isSearching = false.obs;

  /// Название города пользователя.
  final RxString cityName = ''.obs;

  Timer? _debounceTimer;

  /// Создает контроллер.
  AddressSearchController({
    required this.searchService,
    required this.geocodeService,
  });

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchTextChanged);
  }

  @override
  void onReady() {
    super.onReady();
    _loadUserCity();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    cityController.dispose();
    super.onClose();
  }

  Future<void> _loadUserCity() async {
    try {
      final AuthController? authController = Get.find<AuthController>();
      if (authController == null) {
        debugPrint('[AddressSearchController] AuthController не найден');
        return;
      }
      final UserEntity? user = authController.currentUser.value;
      if (user == null) {
        debugPrint('[AddressSearchController] Пользователь не авторизован');
        return;
      }
      final int? userCityId = user.cityId;
      if (userCityId == null) {
        debugPrint('[AddressSearchController] У пользователя не указан cityId');
        return;
      }
      if (authController.cities.isEmpty) {
        debugPrint('[AddressSearchController] Загрузка городов...');
        await authController.loadCities();
      }
      final List<CityEntity> cities = authController.cities;
      if (cities.isEmpty) {
        debugPrint('[AddressSearchController] Список городов пуст');
        return;
      }
      final CityEntity? city = cities.firstWhereOrNull(
        (CityEntity c) => c.id == userCityId,
      );
      if (city != null) {
        cityName.value = city.name;
        cityController.text = city.name;
        debugPrint('[AddressSearchController] Город загружен: ${city.name}');
      } else {
        debugPrint('[AddressSearchController] Город с id $userCityId не найден в списке');
      }
    } catch (e) {
      debugPrint('[AddressSearchController] Ошибка загрузки города: $e');
    }
  }

  void _onSearchTextChanged() {
    final String query = searchController.text.trim();
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      return;
    }
    if (cityName.value.isEmpty) {
      debugPrint('[AddressSearchController] Город не указан, поиск не выполнен');
      return;
    }
    isSearching.value = true;
    try {
      debugPrint('[AddressSearchController] Выполняется поиск: "$query" в городе "${cityName.value}"');
      final List<AddressSearchResult> results =
          await searchService.searchAddresses(
        query: query,
        cityName: cityName.value,
      );
      debugPrint('[AddressSearchController] Получено результатов: ${results.length}');
      searchResults.value = results;
    } catch (e) {
      debugPrint('[AddressSearchController] Ошибка при поиске: $e');
    } finally {
      isSearching.value = false;
    }
  }

  /// Обрабатывает выбор адреса.
  void selectAddress(AddressSearchResult result) {
    Get.back<String>(result: result.formattedAddress);
  }

  /// Форматирует адрес для отображения, убирая лишние слова.
  /// Полный адрес сохраняется в result.formattedAddress.
  String formatAddress(String address, String cityName) {
    if (cityName.isEmpty) {
      return address;
    }
    String formatted = address;
    formatted = formatted.replaceAll(RegExp(r'\bРоссия\b', caseSensitive: false), '');
    formatted = formatted.replaceAll(RegExp(r'\bГород\b', caseSensitive: false), '');
    formatted = formatted.replaceAll(RegExp('\\b$cityName\\b', caseSensitive: false), '');
    formatted = formatted.replaceAll(RegExp(r'\s+'), ' ');
    formatted = formatted.replaceAll(RegExp(r'^[,\s]+|[,\s]+$'), '');
    formatted = formatted.replaceAll(RegExp(r',\s*,', caseSensitive: false), ',');
    return formatted.trim();
  }
}


