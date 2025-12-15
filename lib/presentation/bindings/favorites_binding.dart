import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/repositories/favorite_cleaner/favorite_cleaner_repository.dart';
import '../../data/repositories/favorite_cleaner/favorite_cleaner_repository_impl.dart';
import '../controllers/favorites_controller.dart';

/// Привязка зависимостей для экрана избранных клинеров.
class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    GlobalBinding().dependencies();
    if (!Get.isRegistered<FavoriteCleanerRepository>()) {
      Get.put<FavoriteCleanerRepository>(
        FavoriteCleanerRepositoryImpl(dio: Get.find<Dio>()),
        permanent: true,
      );
    }
    Get.lazyPut<FavoritesController>(
      () => FavoritesController(
        favoriteCleanerRepository: Get.find<FavoriteCleanerRepository>(),
      ),
      fenix: true,
    );
  }
}



