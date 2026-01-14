import 'package:get/get.dart';

import '../../data/models/checklist/checklist_entity.dart';
import '../../data/repositories/checklist/checklist_repository.dart';
import '../../data/repositories/settings/mobile_settings_repository.dart';

/// Контроллер экрана информации об услугах.
class InfoController extends GetxController {
  /// Репозиторий мобильных настроек.
  final MobileSettingsRepository mobileSettingsRepository;
  /// Репозиторий чек-листа.
  final ChecklistRepository checklistRepository;
  /// Признак загрузки данных.
  final RxBool isBusy = false.obs;
  /// Сообщение об ошибке.
  final RxnString errorMessage = RxnString();
  /// Чек-лист.
  final Rxn<ChecklistEntity> checklist = Rxn<ChecklistEntity>();
  /// Создает контроллер.
  InfoController({
    required this.mobileSettingsRepository,
    required this.checklistRepository,
  });

  @override
  void onInit() {
    super.onInit();
    loadInfo();
  }

  /// Загружает информацию об услугах.
  Future<void> loadInfo() async {
    if (isBusy.value) {
      return;
    }
    isBusy.value = true;
    errorMessage.value = null;
    try {
      final ChecklistEntity entity = await checklistRepository.loadMainChecklist();
      checklist.value = entity;
    } catch (_) {
      errorMessage.value =
          'Не удалось загрузить информацию. Пожалуйста, попробуйте ещё раз.';
    } finally {
      isBusy.value = false;
    }
  }
}


