import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../core/constants/map_constants.dart';
import '../../data/models/address/address_selection_model.dart';
import '../../data/repositories/address/address_repository.dart';
import '../../data/services/location/location_service.dart';
import '../../data/services/location/yandex_geocode_service.dart';

/// Контроллер экрана выбора адреса.
class AddressPickerController extends GetxController {
  /// Репозиторий сохранения адреса.
  final AddressRepository addressRepository;

  /// Сервис геолокации.
  final LocationService locationService;

  /// Сервис обратного геокодирования.
  final YandexGeocodeService geocodeService;

  /// Текущий адрес.
  final RxString address = ''.obs;

  /// Признак выполнения геокодирования.
  final RxBool isFetchingAddress = false.obs;

  /// Текущая точка камеры.
  final Rx<Point> cameraTarget = MapConstants.defaultPoint.obs;

  /// Текущее значение зума.
  final RxDouble cameraZoom = MapConstants.defaultZoom.obs;

  /// Контроллер карты.
  YandexMapController? mapController;

  AddressSelectionModel? _selection;
  Timer? _debounceTimer;

  /// Создает контроллер.
  AddressPickerController({
    required this.addressRepository,
    required this.locationService,
    required this.geocodeService,
  });

  @override
  void onInit() {
    super.onInit();
    final AddressSelectionModel? savedSelection = addressRepository
        .loadSelection();
    if (savedSelection != null) {
      _selection = savedSelection;
      address.value = savedSelection.formattedAddress;
      cameraTarget.value = savedSelection.point;
    }
  }

  @override
  void onReady() {
    super.onReady();
    _moveToInitialPosition();
    if (_selection != null) {
      _selectAddress(saved: _selection!);
    } else {
      _scheduleGeocode(cameraTarget.value, cameraZoom.value);
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Обрабатывает создание карты.
  void onMapCreated(YandexMapController controller) {
    mapController = controller;
    _moveCamera(cameraTarget.value, cameraZoom.value);
  }

  /// Обрабатывает изменение позиции камеры.
  void onCameraPositionChanged(CameraPosition position) {
    cameraTarget.value = position.target;
    cameraZoom.value = position.zoom;
    _scheduleGeocode(position.target, position.zoom);
  }

  /// Перемещает камеру к текущей геопозиции.
  Future<void> executeCenterToCurrentLocation() async {
    final Point? currentPoint = await locationService.fetchCurrentPoint();
    if (currentPoint == null) {
      Get.snackbar(
        'Геолокация недоступна',
        'Разрешите доступ к геопозиции или включите определение местоположения.',
      );
      return;
    }
    cameraTarget.value = currentPoint;
    await _moveCamera(currentPoint, MapConstants.defaultZoom);
    _scheduleGeocode(currentPoint, MapConstants.defaultZoom);
  }

  /// Подтверждает выбор адреса.
  Future<void> executeConfirmSelection() async {
    AddressSelectionModel? selection = await _ensureSelectionReady();
    debugPrint(
      '[AddressPicker] confirm selection=$_selection, address="${address.value}"',
    );
    if (selection == null || selection.formattedAddress.isEmpty) {
      Get.snackbar(
        'Адрес не выбран',
        'Переместите карту, чтобы выбрать адрес.',
      );
      return;
    }
    await addressRepository.saveSelection(selection);
    Get.back<AddressSelectionModel>(result: selection);
  }

  void _scheduleGeocode(Point target, double zoom) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      MapConstants.geocodeDebounce,
      () => _fetchAddress(target, zoom.floor()),
    );
  }

  /// Увеличивает масштаб карты.
  Future<void> executeZoomIn() => _changeZoom(delta: 1.0);

  /// Уменьшает масштаб карты.
  Future<void> executeZoomOut() => _changeZoom(delta: -1.0);

  Future<void> _fetchAddress(Point target, int zoom) async {
    await _resolveAddressAt(target: target, zoom: zoom);
  }

  Future<void> _moveToInitialPosition() async {
    final Point? currentPoint = await locationService.fetchCurrentPoint();
    if (_selection != null || currentPoint == null) {
      await _moveCamera(cameraTarget.value, cameraZoom.value);
      return;
    }
    cameraTarget.value = currentPoint;
    await _moveCamera(currentPoint, MapConstants.defaultZoom);
  }

  Future<void> _moveCamera(Point point, double zoom) async {
    if (mapController == null) {
      return;
    }
    await mapController!.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: point, zoom: zoom)),
    );
  }

  void _selectAddress({required AddressSelectionModel saved}) {
    _selection = saved;
    address.value = saved.formattedAddress;
    _scheduleGeocode(saved.point, MapConstants.defaultZoom);
  }

  Future<AddressSelectionModel?> _ensureSelectionReady() async {
    if (_selection != null && _selection!.formattedAddress.isNotEmpty) {
      return _selection;
    }
    final AddressSelectionModel? resolved = await _resolveAddressAt(
      target: cameraTarget.value,
      zoom: cameraZoom.value.round(),
    );
    return resolved ??
        (address.value.isEmpty
            ? null
            : AddressSelectionModel(
                formattedAddress: address.value,
                latitude: cameraTarget.value.latitude,
                longitude: cameraTarget.value.longitude,
              ));
  }

  Future<AddressSelectionModel?> _resolveAddressAt({
    required Point target,
    required int zoom,
  }) async {
    final bool shouldToggleLoader = !isFetchingAddress.value;
    if (shouldToggleLoader) {
      isFetchingAddress.value = true;
    }
    final String? formatted = await geocodeService.fetchAddress(
      point: target,
      zoom: zoom.clamp(10, 19),
    );
    if (shouldToggleLoader) {
      isFetchingAddress.value = false;
    }
    if (formatted == null || formatted.isEmpty) {
      return null;
    }
    final AddressSelectionModel selection = AddressSelectionModel(
      formattedAddress: formatted,
      latitude: target.latitude,
      longitude: target.longitude,
    );
    _selection = selection;
    address.value = formatted;
    return selection;
  }

  Future<void> _changeZoom({required double delta}) async {
    final YandexMapController? controller = mapController;
    if (controller == null) {
      return;
    }
    final CameraPosition current = await controller.getCameraPosition();
    final double newZoom = (current.zoom + delta).clamp(3.0, 20.0);
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: current.target,
          zoom: newZoom,
          azimuth: current.azimuth,
          tilt: current.tilt,
        ),
      ),
    );
  }
}
