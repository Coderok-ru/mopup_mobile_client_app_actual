import '../../models/payment_card/payment_card_entity.dart';
import '../../models/payment_card/payment_card_payload.dart';

/// Контракт работы с банковскими картами клиента.
abstract class PaymentCardRepository {
  /// Возвращает список сохранённых карт.
  Future<List<PaymentCardEntity>> getCards();

  /// Создает новую карту.
  Future<PaymentCardEntity> createCard(PaymentCardPayload payload);

  /// Устанавливает карту по умолчанию.
  Future<void> setDefaultCard(int cardId);

  /// Удаляет карту.
  Future<void> deleteCard(int cardId);
}


