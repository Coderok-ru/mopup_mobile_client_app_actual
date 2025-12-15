import 'package:get/get.dart';

import '../../data/repositories/rating/rating_repository.dart';
import '../../data/repositories/rating/rating_repository_impl.dart';
import '../controllers/rating_controller.dart';
import '../controllers/auth_controller.dart';

/// Привязка зависимостей для экрана рейтинга.
class RatingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RatingRepository>()) {
      Get.lazyPut<RatingRepository>(RatingRepositoryImpl.new);
    }
    Get.lazyPut<RatingController>(
      () => RatingController(
        ratingRepository: Get.find<RatingRepository>(),
        authController: Get.find<AuthController>(),
      ),
    );
  }
}
