import 'package:get/get.dart';

import '../../data/models/favorite_cleaner/favorite_cleaner_entity.dart';
import '../../data/repositories/favorite_cleaner/favorite_cleaner_repository.dart';

/// Контроллер экрана избранных клинеров.
class FavoritesController extends GetxController {
  /// Репозиторий избранных клинеров.
  final FavoriteCleanerRepository favoriteCleanerRepository;

  /// Список избранных клинеров.
  final RxList<FavoriteCleanerEntity> favoriteCleaners =
      <FavoriteCleanerEntity>[].obs;

  /// Флаг загрузки.
  final RxBool isLoading = true.obs;

  /// Флаг ошибки.
  final RxBool hasError = false.obs;

  /// Создает контроллер избранных клинеров.
  FavoritesController({
    required this.favoriteCleanerRepository,
  });

  @override
  void onInit() {
    super.onInit();
    executeLoadFavorites();
  }

  /// Загружает список избранных клинеров.
  Future<void> executeLoadFavorites() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final List<FavoriteCleanerEntity> loaded =
          await favoriteCleanerRepository.getFavorites();
      favoriteCleaners
        ..clear()
        ..addAll(loaded);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Удаляет клинера из избранных.
  Future<void> executeRemoveFromFavorites(int cleanerId) async {
    final FavoriteCleanerEntity? existing = favoriteCleaners
        .firstWhereOrNull((FavoriteCleanerEntity e) => e.id == cleanerId);
    if (existing == null) {
      return;
    }
    favoriteCleaners.remove(existing);
    try {
      await favoriteCleanerRepository.removeFavorite(cleanerId);
    } catch (_) {
      if (!favoriteCleaners.contains(existing)) {
        favoriteCleaners.add(existing);
      }
    }
  }
}


