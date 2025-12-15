import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/models/address/address_selection_model.dart';
import '../../data/repositories/address/address_repository.dart';
import '../../data/services/notifications/notification_service.dart';
import '../../routes/app_routes.dart';
import '../controllers/order_template_controller.dart';

/// Контроллер экрана выбора даты и времени.
class OrderScheduleController extends GetxController {
  /// Контроллер шаблона заказа.
  final OrderTemplateController templateController;

  /// Хранилище.
  final GetStorage storage;

  /// Репозиторий адреса.
  final AddressRepository addressRepository;

  /// Сервис уведомлений.
  final NotificationService notificationService;

  /// Выбранная дата.
  final Rx<DateTime> selectedDate = DateTime.now()
      .add(const Duration(days: 1))
      .obs;

  /// Форматированная дата.
  final RxString formattedDate = ''.obs;

  /// Выбранный слот времени.
  final RxnString selectedTimeSlot = RxnString();

  /// Текст выбранного времени.
  final RxString selectedTimeSlotText = ''.obs;

  /// Флаг регулярной уборки.
  final RxBool isRegular = false.obs;

  /// Флаг публикации заказа.
  final RxBool isPublic = true.obs;

  /// Дополнительные визиты мультизаказа.
  final RxList<OrderMultiVisitState> additionalVisitStates =
      <OrderMultiVisitState>[].obs;

  /// Доступные временные слоты.
  late final List<String> timeSlots;

  /// Адрес.
  final RxString address = ''.obs;

  /// Домофон.
  final RxString doorCode = ''.obs;

  /// Контроллер поля номера квартиры.
  late final TextEditingController doorCodeController;

  /// Наблюдатель номера квартиры.
  late final Worker doorCodeWorker;

  /// Создает контроллер.
  OrderScheduleController({
    required this.templateController,
    required this.addressRepository,
    required this.storage,
    required this.notificationService,
  });

  static bool _localeInitialized = false;

  @override
  void onInit() {
    super.onInit();
    if (!_localeInitialized) {
      initializeDateFormatting('ru');
      _localeInitialized = true;
    }
    formattedDate.value = _formatDate(selectedDate.value);
    timeSlots = _generateTimeSlots();
    doorCodeController = TextEditingController();
    final OrderTemplateDraft draft = templateController.draft;
    if (draft.cityId != null) {
      if (draft.serviceDate != null) {
        selectedDate.value = draft.serviceDate!;
        formattedDate.value = _formatDate(draft.serviceDate!);
      }
      if (draft.serviceTimeSlot != null) {
        selectedTimeSlot.value = draft.serviceTimeSlot;
        selectedTimeSlotText.value = draft.serviceTimeSlot!;
      }
      isRegular.value = draft.isRegular;
      isPublic.value = draft.isPublic;
      address.value = draft.address ?? '';
      doorCode.value = draft.doorCode ?? '';
    } else {
      selectedTimeSlotText.value = '';
    }
    _initializeAdditionalVisits();
    final dynamic storedDoorCode = storage.read(StorageKeys.orderDoorCode);
    if (doorCode.value.isEmpty && storedDoorCode is String) {
      if (storedDoorCode.isNotEmpty) {
        doorCode.value = storedDoorCode;
      }
    }
    doorCodeController.text = doorCode.value;
    doorCodeWorker = ever<String>(doorCode, (String value) {
      if (doorCodeController.text != value) {
        doorCodeController.value = doorCodeController.value.copyWith(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
    });
    if (address.value.isEmpty) {
      final AddressSelectionModel? storedSelection = addressRepository
          .loadSelection();
      if (storedSelection != null) {
        address.value = storedSelection.formattedAddress;
      }
    }
    if (doorCode.value.isNotEmpty) {
      storage.write(StorageKeys.orderDoorCode, doorCode.value.trim());
    }
    if (selectedTimeSlot.value == null || selectedTimeSlotText.value.isEmpty) {
      _selectNearestTimeSlot();
    }
  }

  @override
  void onClose() {
    doorCodeWorker.dispose();
    doorCodeController.dispose();
    super.onClose();
  }

  /// Выбирает дату.
  void selectDate(DateTime date) {
    selectedDate.value = date;
    formattedDate.value = _formatDate(date);
    if (selectedTimeSlot.value == null) {
      _selectNearestTimeSlot();
    }
  }

  /// Выбирает дату дополнительного визита.
  void selectAdditionalDate(int index, DateTime date) {
    if (index < 0 || index >= additionalVisitStates.length) {
      return;
    }
    additionalVisitStates[index].setDate(date, _formatDate(date));
  }

  /// Выбирает слот времени.
  void selectTimeSlot(String slot) {
    selectedTimeSlot.value = slot;
    selectedTimeSlotText.value = slot;
  }

  /// Выбирает слот времени для дополнительного визита.
  void selectAdditionalTimeSlot(int index, String slot) {
    if (index < 0 || index >= additionalVisitStates.length) {
      return;
    }
    additionalVisitStates[index].setTime(slot);
  }

  /// Переключает регулярность.
  void toggleRegular() {
    isRegular.toggle();
    if (!isRegular.value) {
      additionalVisitStates.clear();
    } else {
      _initializeAdditionalVisits();
    }
  }

  /// Переключает видимость заказа.
  void togglePublic() {
    isPublic.toggle();
  }

  /// Проверяет, можно ли продолжить (заполнены адрес, дата и время).
  bool get canContinue {
    final String trimmedAddress = address.value.trim();
    final bool hasAddress = trimmedAddress.isNotEmpty;
    final bool hasTimeSlot = selectedTimeSlot.value != null &&
        selectedTimeSlot.value!.isNotEmpty;
    final bool hasDate = formattedDate.value.isNotEmpty;
    return hasAddress && hasTimeSlot && hasDate;
  }

  /// Сохраняет выбор и переходит дальше.
  Future<void> executeSave() async {
    final String trimmedAddress = address.value.trim();
    if (selectedTimeSlot.value == null || selectedTimeSlot.value!.isEmpty) {
      await notificationService.executeShowErrorNotification(
        'Пожалуйста, выберите время уборки.',
      );
      return;
    }
    if (trimmedAddress.isEmpty) {
      await notificationService.executeShowErrorNotification(
        'Пожалуйста, укажите адрес уборки.',
      );
      return;
    }
    final OrderTemplateDraft draft = templateController.draft;
    draft.serviceDate = selectedDate.value;
    draft.serviceTimeSlot = selectedTimeSlot.value;
    draft.isRegular = isRegular.value;
    draft.isPublic = isPublic.value;
    draft.address = trimmedAddress;
    draft.doorCode = doorCode.value.trim();
    if (!draft.isRegular || additionalVisitStates.isEmpty) {
      draft.additionalVisits.clear();
    } else {
      for (int i = 0; i < additionalVisitStates.length; i++) {
        final OrderMultiVisitState state = additionalVisitStates[i];
        if (!state.isComplete) {
          await notificationService.executeShowErrorNotification(
            'Пожалуйста, заполните дату и время для всех визитов.',
          );
          return;
        }
      }
      draft.setAdditionalVisits(
        additionalVisitStates.map((OrderMultiVisitState state) {
          return OrderDraftScheduleVisit(
            date: state.date.value!,
            time: state.timeSlot.value!,
          );
        }).toList(),
      );
    }
    Get.toNamed(AppRoutes.orderConfirmation);
  }

  /// Обновляет номер квартиры.
  void updateDoorCode(String value) {
    doorCode.value = value;
    storage.write(StorageKeys.orderDoorCode, value.trim());
  }

  /// Открывает выбор адреса.
  Future<void> executeSelectAddress() async {
    final dynamic result = await Get.toNamed(AppRoutes.addressPicker);
    if (result is! AddressSelectionModel) {
      return;
    }
    address.value = result.formattedAddress;
    templateController.draft.address = result.formattedAddress;
  }

  String _formatDate(DateTime date) {
    const List<String> months = <String>[
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  List<String> _generateTimeSlots() {
    final List<String> slots = <String>[];
    DateTime start = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      9,
      0,
    );
    final DateTime end = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      20,
      0,
    );
    while (!start.isAfter(end)) {
      final String hours = start.hour.toString().padLeft(2, '0');
      final String minutes = start.minute.toString().padLeft(2, '0');
      slots.add('$hours:$minutes');
      start = start.add(const Duration(minutes: 30));
    }
    return slots;
  }

  void _selectNearestTimeSlot() {
    if (timeSlots.isEmpty) {
      return;
    }
    final DateTime now = DateTime.now();
    final DateTime date = selectedDate.value;
    if (_isSameDay(now, date)) {
      final int nowMinutes = now.hour * 60 + now.minute;
      for (final String slot in timeSlots) {
        final int? slotMinutes = _convertSlotToMinutes(slot);
        if (slotMinutes == null) {
          continue;
        }
        if (slotMinutes >= nowMinutes) {
          selectTimeSlot(slot);
          return;
        }
      }
      selectTimeSlot(timeSlots.last);
      return;
    }
    selectTimeSlot(timeSlots.first);
  }

  void _initializeAdditionalVisits() {
    final int requiredCount = _resolveAdditionalVisitsCount();
    final List<OrderDraftScheduleVisit> stored =
        templateController.draft.additionalVisits;
    final List<OrderMultiVisitState> states = <OrderMultiVisitState>[];
    for (int i = 0; i < requiredCount; i++) {
      final OrderDraftScheduleVisit? visit =
          i < stored.length ? stored[i] : null;
      states.add(
        OrderMultiVisitState(
          initialDate: visit?.date,
          initialTime: visit?.time,
          formatDate: _formatDate,
        ),
      );
    }
    additionalVisitStates
      ..clear()
      ..addAll(states);
  }

  int _resolveAdditionalVisitsCount() {
    final int multiplier = templateController.draft.multiQuantity;
    if (multiplier <= 1) {
      return 0;
    }
    return multiplier - 1;
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  int? _convertSlotToMinutes(String slot) {
    final List<String> parts = slot.split(':');
    if (parts.length != 2) {
      return null;
    }
    final int? hours = int.tryParse(parts.first);
    final int? minutes = int.tryParse(parts.last);
    if (hours == null || minutes == null) {
      return null;
    }
    return hours * 60 + minutes;
  }
}

/// Состояние дополнительного визита мультизаказа.
class OrderMultiVisitState {
  /// Дата визита.
  final Rx<DateTime?> date = Rx<DateTime?>(null);

  /// Форматированная дата.
  final RxString formattedDate = ''.obs;

  /// Форматированное время.
  final RxString formattedTime = ''.obs;

  /// Выбранный слот времени.
  final RxnString timeSlot = RxnString();

  /// Создает состояние дополнительного визита.
  OrderMultiVisitState({
    DateTime? initialDate,
    String? initialTime,
    required String Function(DateTime date) formatDate,
  }) {
    if (initialDate != null) {
      setDate(initialDate, formatDate(initialDate));
    }
    if (initialTime != null && initialTime.isNotEmpty) {
      setTime(initialTime);
    }
  }

  /// Проверяет, заполнены ли дата и время.
  bool get isComplete => date.value != null && timeSlot.value != null;

  /// Устанавливает дату.
  void setDate(DateTime value, String formatted) {
    date.value = value;
    formattedDate.value = formatted;
  }

  /// Устанавливает время.
  void setTime(String value) {
    timeSlot.value = value;
    formattedTime.value = value;
  }
}
