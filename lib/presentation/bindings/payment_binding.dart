import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/repositories/payment_card/payment_card_repository.dart';
import '../../data/repositories/payment_card/payment_card_repository_impl.dart';
import '../controllers/payment_controller.dart';

/// Привязка зависимостей для экрана оплаты.
class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    GlobalBinding().dependencies();
    if (!Get.isRegistered<PaymentCardRepository>()) {
      Get.put<PaymentCardRepository>(
        PaymentCardRepositoryImpl(dio: Get.find<Dio>()),
        permanent: true,
      );
    }
    Get.lazyPut<PaymentController>(
      () => PaymentController(
        paymentCardRepository: Get.find<PaymentCardRepository>(),
      ),
      fenix: true,
    );
  }
}


