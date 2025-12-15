import 'package:get/get.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/repositories/payment_card/payment_card_repository.dart';
import '../controllers/add_payment_card_controller.dart';

/// Привязка зависимостей для экрана добавления карты.
class AddPaymentCardBinding extends Bindings {
  @override
  void dependencies() {
    GlobalBinding().dependencies();
    Get.lazyPut<AddPaymentCardController>(
      () => AddPaymentCardController(
        paymentCardRepository: Get.find<PaymentCardRepository>(),
      ),
    );
  }
}


