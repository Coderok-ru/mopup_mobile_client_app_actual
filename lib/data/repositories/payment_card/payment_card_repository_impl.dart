import 'package:dio/dio.dart';

import '../../../core/constants/app_urls.dart';
import '../../models/payment_card/payment_card_entity.dart';
import '../../models/payment_card/payment_card_payload.dart';
import 'payment_card_repository.dart';

/// Репозиторий банковских карт, работающий через REST API.
class PaymentCardRepositoryImpl implements PaymentCardRepository {
  /// HTTP-клиент.
  final Dio dio;

  /// Создаёт репозиторий банковских карт.
  const PaymentCardRepositoryImpl({required this.dio});

  @override
  Future<PaymentCardEntity> createCard(PaymentCardPayload payload) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      AppUrls.paymentCards,
      data: payload.toJson(),
    );
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data =
          response.data as Map<String, dynamic>;
      final dynamic raw = data['data'];
      if (raw is Map<String, dynamic>) {
        return PaymentCardEntity.fromJson(raw);
      }
    }
    throw DioException(
      requestOptions: RequestOptions(path: AppUrls.paymentCards),
      error: 'Не удалось создать карту',
    );
  }

  @override
  Future<List<PaymentCardEntity>> getCards() async {
    final Response<dynamic> response = await dio.get<dynamic>(
      AppUrls.paymentCards,
    );
    if (response.data is! Map<String, dynamic>) {
      return <PaymentCardEntity>[];
    }
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    final dynamic rawList = data['data'];
    if (rawList is! List<dynamic>) {
      return <PaymentCardEntity>[];
    }
    final List<PaymentCardEntity> cards = <PaymentCardEntity>[];
    for (final dynamic item in rawList) {
      if (item is Map<String, dynamic>) {
        cards.add(PaymentCardEntity.fromJson(item));
      }
    }
    return cards;
  }

  @override
  Future<void> setDefaultCard(int cardId) async {
    await dio.patch<dynamic>(
      AppUrls.createPaymentCardDefaultPath(cardId),
    );
  }

  @override
  Future<void> deleteCard(int cardId) async {
    await dio.delete<dynamic>(
      '${AppUrls.paymentCards}/$cardId',
    );
  }
}


