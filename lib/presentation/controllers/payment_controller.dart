import 'package:get/get.dart';

import '../../data/models/payment_card/payment_card_entity.dart';
import '../../data/repositories/payment_card/payment_card_repository.dart';

/// Контроллер экрана методов оплаты.
class PaymentController extends GetxController {
  /// Репозиторий банковских карт.
  final PaymentCardRepository paymentCardRepository;

  /// Список карт.
  final RxList<PaymentCardEntity> cards = <PaymentCardEntity>[].obs;

  /// Флаг загрузки.
  final RxBool isLoading = true.obs;

  /// Флаг ошибки.
  final RxBool hasError = false.obs;

  /// Создает контроллер экрана оплаты.
  PaymentController({required this.paymentCardRepository});

  @override
  void onInit() {
    super.onInit();
    executeLoadCards();
  }

  /// Загружает список карт.
  Future<void> executeLoadCards() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final List<PaymentCardEntity> loaded =
          await paymentCardRepository.getCards();
      cards
        ..clear()
        ..addAll(loaded);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Устанавливает карту по умолчанию.
  Future<void> executeSetDefaultCard(PaymentCardEntity card) async {
    final int index =
        cards.indexWhere((PaymentCardEntity element) => element.id == card.id);
    if (index == -1) {
      return;
    }
    final List<PaymentCardEntity> previous = List<PaymentCardEntity>.from(cards);
    for (int i = 0; i < cards.length; i++) {
      cards[i] = cards[i].copyWith(isDefault: cards[i].id == card.id);
    }
    try {
      await paymentCardRepository.setDefaultCard(card.id);
    } catch (_) {
      cards
        ..clear()
        ..addAll(previous);
    }
  }

  /// Удаляет карту.
  Future<void> executeDeleteCard(PaymentCardEntity card) async {
    final List<PaymentCardEntity> previous = List<PaymentCardEntity>.from(cards);
    cards.removeWhere((PaymentCardEntity element) => element.id == card.id);
    try {
      await paymentCardRepository.deleteCard(card.id);
    } catch (_) {
      cards
        ..clear()
        ..addAll(previous);
    }
  }
}


