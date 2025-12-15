import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/constants/app_strings.dart';
import '../../data/models/auth/user_entity.dart';
import '../../data/models/rating/rating_info_entity.dart';
import '../../data/repositories/rating/rating_repository.dart';
import 'auth_controller.dart';

/// Контроллер экрана рейтинга.
class RatingController extends GetxController {
  /// Репозиторий рейтинга.
  final RatingRepository ratingRepository;

  /// Контроллер авторизации.
  final AuthController authController;

  /// Признак загрузки данных.
  final RxBool isBusy = false.obs;

  /// Сообщение об ошибке.
  final RxnString errorMessage = RxnString();

  /// Информация о рейтинге.
  final Rxn<RatingInfoEntity> ratingInfo = Rxn<RatingInfoEntity>();

  static bool _isLocaleConfigured = false;

  /// Создает контроллер.
  RatingController({
    required this.ratingRepository,
    required this.authController,
  }) {
    if (!_isLocaleConfigured) {
      timeago.setLocaleMessages('ru', timeago.RuMessages());
      timeago.setLocaleMessages('ru_short', timeago.RuShortMessages());
      timeago.setDefaultLocale('ru');
      _isLocaleConfigured = true;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadRating();
  }

  /// Загружает рейтинг.
  Future<void> loadRating() async {
    if (isBusy.value) {
      return;
    }
    isBusy.value = true;
    errorMessage.value = null;
    try {
      await authController.refreshProfile();
      final RatingInfoEntity info = await _loadFromCurrentUser();
      ratingInfo.value = info;
    } catch (error) {
      errorMessage.value = 'Не удалось загрузить рейтинг. Повторите попытку.';
    } finally {
      isBusy.value = false;
    }
  }

  Future<RatingInfoEntity> _loadFromCurrentUser() async {
    final UserEntity? user = authController.currentUser.value;
    if (user == null) {
      throw Exception('Профиль пользователя недоступен');
    }
    return ratingRepository.loadRating(user);
  }

  /// Возвращает форматированную дату обновления.
  String getLastUpdateLabel() {
    final RatingInfoEntity? info = ratingInfo.value;
    if (info == null) {
      return '';
    }
    final DateTime date = info.updatedAt.toLocal();
    final String formatted = timeago.format(date, locale: 'ru');
    return '${AppStrings.ratingLastUpdatePrefix} $formatted';
  }

  /// Возвращает нормализованное значение рейтинга.
  double getProgress() {
    final RatingInfoEntity? info = ratingInfo.value;
    return info == null ? 0 : info.value.clamp(0, 5) / 5;
  }

  /// Возвращает значение рейтинга в виде текста.
  String getRatingValueLabel() {
    final RatingInfoEntity? info = ratingInfo.value;
    return info == null ? '--' : info.value.toStringAsFixed(1);
  }
}
