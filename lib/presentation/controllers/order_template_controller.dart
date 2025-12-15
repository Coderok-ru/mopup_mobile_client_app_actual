import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../data/models/order/order_additional_service_entity.dart';
import '../../data/models/order/order_base_service_entity.dart';
import '../../data/models/order/order_template_detail_entity.dart';
import '../../data/models/order/order_template_summary_entity.dart';
import '../../data/repositories/order/order_template_repository.dart';
import '../models/order_template_detail_args.dart';
import '../../routes/app_routes.dart';
import 'auth_controller.dart';

/// Контроллер экрана шаблона заказа.
class OrderTemplateController extends GetxController {
  /// Репозиторий шаблонов.
  final OrderTemplateRepository orderTemplateRepository;

  /// Контроллер авторизации.
  final AuthController authController;

  /// Текущий шаблон.
  final Rxn<OrderTemplateDetailEntity> template =
      Rxn<OrderTemplateDetailEntity>();

  /// Состояние загрузки.
  final RxBool isLoading = false.obs;

  /// Сообщение об ошибке.
  final RxnString errorMessage = RxnString();

  /// Значения базовых услуг.
  final RxList<OrderBaseServiceState> baseServiceStates =
      <OrderBaseServiceState>[].obs;

  /// Дополнительные услуги.
  final RxList<OrderAdditionalServiceState> additionalServiceStates =
      <OrderAdditionalServiceState>[].obs;

  /// Стоимость базовых услуг.
  final RxDouble baseTotal = 0.0.obs;

  /// Стоимость дополнительных услуг.
  final RxDouble additionalTotal = 0.0.obs;

  /// Общая стоимость.
  final RxDouble totalPrice = 0.0.obs;

  /// Общее время выполнения.
  final RxInt totalTime = 0.obs;

  /// Состояние секции допуслуг.
  final RxBool isAdditionalExpanded = false.obs;

  /// Черновик заказа.
  final OrderTemplateDraft draft = OrderTemplateDraft();

  late final OrderTemplateSummaryEntity _summary;
  double _templateBasePrice = 0;
  int _templateBaseTime = 0;
  OrderMultiSelection _currentMultiSelection =
      const OrderMultiSelection(multiplier: 1, discountPercent: 0);

  /// Название шаблона.
  String get templateTitle => _summary.title;

  /// Идентификатор шаблона.
  int get templateId => draft.templateId ?? _summary.id;

  /// Текущий выбор мультизаказа.
  OrderMultiSelection get currentMultiSelection => _currentMultiSelection;

  /// Создает контроллер экранa шаблона.
  OrderTemplateController({
    required this.orderTemplateRepository,
    required this.authController,
  });

  @override
  void onInit() {
    super.onInit();
    final Object? arguments = Get.arguments;
    if (arguments is OrderTemplateDetailArgs) {
      _summary = arguments.template;
    } else {
      throw ArgumentError('Отсутствуют аргументы шаблона.');
    }
    unawaited(_loadTemplate());
  }

  /// Обновляет значение базовой услуги.
  void changeBaseServiceValue(int serviceId, double value) {
    final OrderBaseServiceState? state = baseServiceStates
        .firstWhereOrNull(
          (OrderBaseServiceState item) => item.service.id == serviceId,
        );
    if (state == null) {
      return;
    }
    final double normalized = state.normalizeValue(value);
    state.value.value = normalized;
    draft.baseQuantities[serviceId] = state.value.value.round();
    _updateTotals();
  }

  /// Переключает дополнительную услугу.
  void toggleAdditionalService(int serviceId, bool enabled) {
    final OrderAdditionalServiceState? state = additionalServiceStates
        .firstWhereOrNull(
          (OrderAdditionalServiceState item) => item.service.id == serviceId,
        );
    if (state == null) {
      return;
    }
    state.isEnabled.value = enabled;
    if (state.service.type == 'toggle') {
      state.quantity.value = enabled ? 1 : 0;
    }
    draft.additionalQuantities[serviceId] = state.service.type == 'toggle'
        ? (enabled ? 1 : 0)
        : state.quantity.value;
    _updateTotals();
  }

  /// Увеличивает количество числовой услуги.
  void increaseAdditionalQuantity(int serviceId) {
    _changeAdditionalQuantity(serviceId, 1);
  }

  /// Уменьшает количество числовой услуги.
  void decreaseAdditionalQuantity(int serviceId) {
    _changeAdditionalQuantity(serviceId, -1);
  }

  /// Переключает секцию допуслуг.
  void toggleAdditional() {
    isAdditionalExpanded.toggle();
  }

  /// Обрабатывает продолжение оформления.
  void proceed() {
    Get.toNamed(AppRoutes.orderSchedule);
  }

  Future<void> _loadTemplate() async {
    final int? cityId =
        authController.selectedCityId.value ??
        authController.currentUser.value?.cityId;
    if (cityId == null) {
      errorMessage.value = 'Выберите город для загрузки шаблона.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final OrderTemplateDetailEntity detail = await orderTemplateRepository
          .loadTemplate(_summary.id, cityId);
      template.value = detail;
      _templateBasePrice = detail.basePrice;
      _templateBaseTime = detail.baseTime;
      final bool templateIsMulti =
          detail.isMulti ||
          detail.baseServices.any(
            (OrderBaseServiceEntity service) => service.isMulti,
          );
      baseServiceStates.assignAll(
        detail.baseServices.map((OrderBaseServiceEntity service) {
          final double initial = _clamp(
            service.defaultValue,
            service.minValue,
            service.maxValue,
          );
          return OrderBaseServiceState(
            service: service,
            initialValue: initial,
            templateIsMulti: templateIsMulti,
          );
        }),
      );
      additionalServiceStates.assignAll(
        detail.additionalServices.map(OrderAdditionalServiceState.new),
      );
      _updateDraft(cityId, detail, templateIsMulti);
      _updateTotals();
    } on DioException catch (error) {
      errorMessage.value = _resolveDioMessage(error);
    } catch (_) {
      errorMessage.value = 'Не удалось загрузить шаблон.';
    } finally {
      isLoading.value = false;
    }
  }

  OrderTemplateDraft snapshotDraft() {
    return draft.clone();
  }

  void clearDraft() {
    draft.clear();
    baseServiceStates.clear();
    additionalServiceStates.clear();
    baseTotal.value = 0;
    additionalTotal.value = 0;
    totalPrice.value = 0;
    totalTime.value = 0;
    isAdditionalExpanded.value = false;
  }

  String _resolveDioMessage(DioException error) {
    final dynamic data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final dynamic message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!.trim();
    }
    return 'Ошибка сети при загрузке шаблона.';
  }

  void _updateTotals() {
    final double templatePricePerVisit = _templateBasePrice;
    final double baseServicesPerVisit = _calculateBaseServicesPerVisitTotal();
    final double additionalPerVisit = _calculateAdditionalPerVisitTotal();
    final int perVisitTime = _calculatePerVisitTotalTime();
    final OrderMultiSelection selection = _resolveMultiSelection();
    _currentMultiSelection = selection;
    final int multiplier = selection.multiplier > 0 ? selection.multiplier : 1;
    final double visits = multiplier.toDouble();
    final double baseAggregated =
        (templatePricePerVisit + baseServicesPerVisit) * visits;
    final double additionalAggregated = additionalPerVisit * visits;
    final double totalBeforeDiscount =
        baseAggregated + additionalAggregated;
    final double discountAmount =
        totalBeforeDiscount * selection.discountPercent / 100;
    final double totalAfterDiscount = totalBeforeDiscount - discountAmount;
    baseTotal.value = baseAggregated;
    additionalTotal.value = additionalAggregated;
    totalPrice.value = totalAfterDiscount;
    totalTime.value = perVisitTime;
    draft.basePrice = baseAggregated;
    draft.additionalPrice = additionalAggregated;
    draft.totalPrice = totalAfterDiscount;
    draft.totalTime = perVisitTime;
    draft.discountAmount = discountAmount;
    draft.discountPercent = selection.discountPercent;
    draft.multiQuantity = multiplier;
  }

  double _calculateBaseServicesPerVisitTotal() {
    double sum = 0;
    for (final OrderBaseServiceState state in baseServiceStates) {
      sum += state.calculatePricePerVisit();
    }
    return sum;
  }

  double _calculateAdditionalPerVisitTotal() {
    double sum = 0;
    for (final OrderAdditionalServiceState state in additionalServiceStates) {
      sum += state.calculateTotal();
    }
    return sum;
  }

  int _calculatePerVisitTotalTime() {
    int sum = _templateBaseTime;
    for (final OrderBaseServiceState state in baseServiceStates) {
      sum += state.calculateDurationPerVisit();
    }
    for (final OrderAdditionalServiceState state in additionalServiceStates) {
      sum += state.calculateDuration();
    }
    return sum;
  }

  OrderMultiSelection _resolveMultiSelection() {
    final OrderBaseServiceState? multiState = baseServiceStates.firstWhereOrNull(
      (OrderBaseServiceState item) => item.usesCustomSteps,
    );
    if (multiState == null) {
      return const OrderMultiSelection(multiplier: 1, discountPercent: 0);
    }
    final int multiplier = multiState.multiplier > 0 ? multiState.multiplier : 1;
    final OrderBaseServiceDiscount? discount = multiState.currentDiscount;
    final int percent = discount?.percent ?? 0;
    return OrderMultiSelection(
      multiplier: multiplier,
      discountPercent: percent,
    );
  }

  void _changeAdditionalQuantity(int serviceId, int delta) {
    final OrderAdditionalServiceState? state = additionalServiceStates
        .firstWhereOrNull(
          (OrderAdditionalServiceState item) => item.service.id == serviceId,
        );
    if (state == null || state.service.type == 'toggle') {
      return;
    }
    final int current = state.quantity.value;
    final int next = _clampInt(
      current + delta,
      OrderAdditionalServiceState.minQuantity,
      OrderAdditionalServiceState.maxQuantity,
    );
    if (next == current) {
      return;
    }
    state.quantity.value = next;
    state.isEnabled.value = next > 0;
    draft.additionalQuantities[serviceId] = next;
    _updateTotals();
  }

  void _updateDraft(
    int cityId,
    OrderTemplateDetailEntity detail,
    bool templateIsMulti,
  ) {
    final DateTime? previousDate = draft.serviceDate;
    final String? previousTime = draft.serviceTimeSlot;
    final bool previousPublic = draft.isPublic;
    final String? previousAddress = draft.address;
    final String? previousDoor = draft.doorCode;
    final double previousBasePrice = draft.basePrice;
    final double previousAdditionalPrice = draft.additionalPrice;
    final double previousTotalPrice = draft.totalPrice;
    final int previousTotalTime = draft.totalTime;
    final double previousDiscountAmount = draft.discountAmount;
    final int previousDiscountPercent = draft.discountPercent;
    final int previousMultiQuantity = draft.multiQuantity;
    final List<OrderDraftScheduleVisit> previousVisits =
        draft.additionalVisits.map(OrderDraftScheduleVisit.copyOf).toList();
    draft.clear();
    draft.cityId = cityId;
    draft.templateId = detail.id;
    for (final OrderBaseServiceState state in baseServiceStates) {
      draft.baseQuantities[state.service.id] = state.value.value.round();
    }
    for (final OrderAdditionalServiceState state in additionalServiceStates) {
      draft.additionalQuantities[state.service.id] = state.isToggle
          ? (state.isEnabled.value ? 1 : 0)
          : state.quantity.value;
    }
    draft.serviceDate = previousDate;
    draft.serviceTimeSlot = previousTime;
    draft.isRegular = templateIsMulti;
    draft.isPublic = previousPublic;
    draft.address = previousAddress;
    draft.doorCode = previousDoor;
    draft.basePrice = previousBasePrice;
    draft.additionalPrice = previousAdditionalPrice;
    draft.totalPrice = previousTotalPrice;
    draft.totalTime = previousTotalTime;
    draft.discountAmount = previousDiscountAmount;
    draft.discountPercent = previousDiscountPercent;
    draft.multiQuantity = previousMultiQuantity;
    draft.additionalVisits.addAll(previousVisits);
  }

  double _clamp(double value, double min, double max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  int _clampInt(int value, int min, int max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }
}

/// Состояние базовой услуги.
class OrderBaseServiceState {
  /// Модель услуги.
  final OrderBaseServiceEntity service;

  /// Флаг мультишаблона.
  final bool templateIsMulti;

  /// Доступные значения слайдера.
  final List<int> sliderSteps;

  /// Текущее значение.
  final RxDouble value;

  /// Создает состояние базовой услуги.
  factory OrderBaseServiceState({
    required OrderBaseServiceEntity service,
    required double initialValue,
    required bool templateIsMulti,
  }) {
    final List<int> steps = service.resolveAllowedValues(templateIsMulti);
    final double resolved = _resolveInitialValue(
      initialValue,
      service,
      templateIsMulti,
      steps,
    );
    return OrderBaseServiceState._(
      service: service,
      templateIsMulti: templateIsMulti,
      sliderSteps: steps,
      value: resolved.obs,
    );
  }

  OrderBaseServiceState._({
    required this.service,
    required this.templateIsMulti,
    required this.sliderSteps,
    required this.value,
  });

  /// Возвращает true, если используются скидочные шаги.
  bool get usesCustomSteps => service.useDiscountSteps(templateIsMulti);

  /// Возвращает список значений для отображения.
  List<int> get effectiveSteps => usesCustomSteps ? sliderSteps : <int>[];

  /// Текущее количество.
  int get currentQuantity => normalizeValue(value.value).round();

  /// Множитель заказов.
  int get multiplier => usesCustomSteps ? currentQuantity : 1;

  /// Текущая скидка.
  OrderBaseServiceDiscount? get currentDiscount {
    if (service.discounts.isEmpty) {
      return null;
    }
    for (final OrderBaseServiceDiscount discount in service.discounts) {
      if (discount.value == currentQuantity) {
        return discount;
      }
    }
    return null;
  }

  /// Стоимость услуги за один визит.
  double calculatePricePerVisit() {
    if (usesCustomSteps) {
      return service.price;
    }
    final double quantity = normalizeValue(value.value);
    return quantity * service.price;
  }

  /// Длительность услуги за один визит.
  int calculateDurationPerVisit() {
    if (usesCustomSteps) {
      return service.durationMinutes;
    }
    final int quantity = normalizeValue(value.value).round();
    return quantity * service.durationMinutes;
  }

  /// Минимальное значение слайдера.
  int get minSliderValue =>
      usesCustomSteps && sliderSteps.isNotEmpty
          ? sliderSteps.first
          : service.minValue.round();

  /// Максимальное значение слайдера.
  int get maxSliderValue =>
      usesCustomSteps && sliderSteps.isNotEmpty
          ? sliderSteps.last
          : service.maxValue.round();

  /// Нормализует значение.
  double normalizeValue(double raw) {
    if (usesCustomSteps && sliderSteps.isNotEmpty) {
      final int nearest = _findNearest(raw.round(), sliderSteps);
      return nearest.toDouble();
    }
    return _clamp(raw, service.minValue, service.maxValue);
  }

  static double _resolveInitialValue(
    double initial,
    OrderBaseServiceEntity service,
    bool templateIsMulti,
    List<int> steps,
  ) {
    if (service.useDiscountSteps(templateIsMulti) && steps.isNotEmpty) {
      final int nearest = _findNearest(initial.round(), steps);
      return nearest.toDouble();
    }
    return _clamp(initial, service.minValue, service.maxValue);
  }

  static double _clamp(double value, double min, double max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  static int _findNearest(int target, List<int> values) {
    int nearest = values.first;
    int minDiff = (nearest - target).abs();
    for (int i = 1; i < values.length; i++) {
      final int candidate = values[i];
      final int diff = (candidate - target).abs();
      if (diff < minDiff) {
        nearest = candidate;
        minDiff = diff;
      } else if (diff == minDiff && candidate < nearest) {
        nearest = candidate;
      }
    }
    return nearest;
  }
}

/// Состояние дополнительной услуги.
class OrderAdditionalServiceState {
  static const int minQuantity = 0;
  static const int maxQuantity = 10;

  /// Модель услуги.
  final OrderAdditionalServiceEntity service;

  /// Флаг включения.
  final RxBool isEnabled;

  /// Количество услуги.
  final RxInt quantity;

  /// Создает состояние дополнительной услуги.
  OrderAdditionalServiceState(OrderAdditionalServiceEntity service)
    : service = service,
      isEnabled = false.obs,
      quantity = 0.obs {
    final int initialQuantity = _resolveInitialQuantity(service);
    quantity.value = initialQuantity;
    isEnabled.value = service.type == 'toggle'
        ? service.defaultToggle == 1
        : initialQuantity > 0;
  }

  bool get isToggle => service.type == 'toggle';

  double calculateTotal() {
    if (isToggle) {
      return isEnabled.value ? service.price : 0;
    }
    return quantity.value * service.price;
  }

  int calculateDuration() {
    if (isToggle) {
      return isEnabled.value ? service.durationMinutes : 0;
    }
    return quantity.value * service.durationMinutes;
  }

  static int _resolveInitialQuantity(OrderAdditionalServiceEntity service) {
    if (service.type == 'toggle') {
      return service.defaultToggle == 1 ? 1 : 0;
    }
    int raw = service.defaultValue.round();
    if (raw < minQuantity) {
      raw = minQuantity;
    } else if (raw > maxQuantity) {
      raw = maxQuantity;
    }
    return raw;
  }
}

/// Черновик шаблона заказа.
class OrderTemplateDraft {
  /// Количество базовых услуг.
  final Map<int, int> baseQuantities = <int, int>{};

  /// Количество дополнительных услуг.
  final Map<int, int> additionalQuantities = <int, int>{};

  /// Идентификатор шаблона.
  int? templateId;

  /// Идентификатор города.
  int? cityId;

  /// Выбранная дата.
  DateTime? serviceDate;

  /// Выбранный слот времени.
  String? serviceTimeSlot;

  /// Регулярность.
  bool isRegular = false;

  /// Публичность.
  bool isPublic = true;

  /// Адрес.
  String? address;

  /// Код домофона.
  String? doorCode;

  /// Стоимость базовых услуг.
  double basePrice = 0;

  /// Стоимость доп. услуг.
  double additionalPrice = 0;

  /// Итоговая стоимость.
  double totalPrice = 0;

  /// Итоговое время.
  int totalTime = 0;

  /// Примененная скидка.
  double discountAmount = 0;

  /// Процент скидки.
  int discountPercent = 0;

  /// Количество визитов мультизаказа.
  int multiQuantity = 1;

  /// Дополнительные визиты для регулярных заказов.
  final List<OrderDraftScheduleVisit> additionalVisits =
      <OrderDraftScheduleVisit>[];

  /// Сбрасывает черновик.
  void clear() {
    baseQuantities.clear();
    additionalQuantities.clear();
    templateId = null;
    cityId = null;
    serviceDate = null;
    serviceTimeSlot = null;
    isRegular = false;
    isPublic = true;
    address = null;
    doorCode = null;
    basePrice = 0;
    additionalPrice = 0;
    totalPrice = 0;
    totalTime = 0;
    discountAmount = 0;
    discountPercent = 0;
    multiQuantity = 1;
    additionalVisits.clear();
  }

  /// Возвращает копию черновика.
  OrderTemplateDraft clone() {
    final OrderTemplateDraft copy = OrderTemplateDraft();
    copy.templateId = templateId;
    copy.cityId = cityId;
    copy.baseQuantities.addAll(baseQuantities);
    copy.additionalQuantities.addAll(additionalQuantities);
    copy.serviceDate = serviceDate;
    copy.serviceTimeSlot = serviceTimeSlot;
    copy.isRegular = isRegular;
    copy.isPublic = isPublic;
    copy.address = address;
    copy.doorCode = doorCode;
    copy.basePrice = basePrice;
    copy.additionalPrice = additionalPrice;
    copy.totalPrice = totalPrice;
    copy.totalTime = totalTime;
    copy.discountAmount = discountAmount;
    copy.discountPercent = discountPercent;
    copy.multiQuantity = multiQuantity;
    copy.additionalVisits.addAll(
      additionalVisits.map(OrderDraftScheduleVisit.copyOf),
    );
    return copy;
  }

  /// Заменяет список дополнительных визитов.
  void setAdditionalVisits(List<OrderDraftScheduleVisit> visits) {
    additionalVisits
      ..clear()
      ..addAll(visits.map(OrderDraftScheduleVisit.copyOf));
  }
}

/// Дополнительный визит регулярного заказа.
class OrderDraftScheduleVisit {
  /// Дата визита.
  final DateTime date;

  /// Время визита.
  final String time;

  /// Создает дополнительный визит.
  OrderDraftScheduleVisit({
    required this.date,
    required this.time,
  });

  /// Возвращает копию визита.
  static OrderDraftScheduleVisit copyOf(OrderDraftScheduleVisit visit) {
    return OrderDraftScheduleVisit(date: visit.date, time: visit.time);
  }
}

/// Параметры мультизаказа.
class OrderMultiSelection {
  /// Количество визитов.
  final int multiplier;

  /// Скидка в процентах.
  final int discountPercent;

  /// Создает параметры мультизаказа.
  const OrderMultiSelection({
    required this.multiplier,
    required this.discountPercent,
  });

  /// Проверяет наличие скидки.
  bool get hasDiscount => discountPercent > 0;
}
