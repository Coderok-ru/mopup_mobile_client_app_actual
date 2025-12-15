import 'package:get/get.dart';

import '../../data/models/settings/mobile_settings_entity.dart';
import '../../data/repositories/settings/mobile_settings_repository.dart';

/// Контроллер экрана договора оферты.
class OfferController extends GetxController {
  /// Репозиторий мобильных настроек.
  final MobileSettingsRepository mobileSettingsRepository;

  /// Признак загрузки данных.
  final RxBool isBusy = false.obs;

  /// Сообщение об ошибке.
  final RxnString errorMessage = RxnString();

  /// Мобильные настройки приложения.
  final Rxn<MobileSettingsEntity> settings = Rxn<MobileSettingsEntity>();

  /// Создает контроллер.
  OfferController({required this.mobileSettingsRepository});

  @override
  void onInit() {
    super.onInit();
    loadOffer();
  }

  /// Загружает текст договора оферты.
  Future<void> loadOffer() async {
    if (isBusy.value) {
      return;
    }
    isBusy.value = true;
    errorMessage.value = null;
    try {
      final MobileSettingsEntity entity =
          await mobileSettingsRepository.loadMobileSettings();
      settings.value = entity;
    } catch (_) {
      errorMessage.value =
          'Не удалось загрузить договор оферты. Пожалуйста, попробуйте ещё раз.';
    } finally {
      isBusy.value = false;
    }
  }

  /// Возвращает сырой HTML текста договора.
  String getOfferHtml() {
    final MobileSettingsEntity? entity = settings.value;
    if (entity == null || entity.offer.isEmpty) {
      return '';
    }
    return entity.offer;
  }
}


