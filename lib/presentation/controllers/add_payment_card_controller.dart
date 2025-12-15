import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../data/models/payment_card/payment_card_payload.dart';
import '../../data/repositories/payment_card/payment_card_repository.dart';

/// Контроллер экрана добавления банковской карты.
class AddPaymentCardController extends GetxController {
  /// Репозиторий банковских карт.
  final PaymentCardRepository paymentCardRepository;

  /// Поле номера карты (маскированный вид).
  final TextEditingController cardNumberController = TextEditingController();

  /// Поле владельца карты.
  final TextEditingController cardHolderController = TextEditingController();

  /// Маска номера карты.
  final MaskTextInputFormatter cardNumberFormatter = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: <String, RegExp>{'#': RegExp(r'\d')},
  );

  /// Признак использования карты по умолчанию.
  final RxBool isDefault = false.obs;

  /// Индикатор загрузки.
  final RxBool isBusy = false.obs;

  /// Сообщение об ошибке.
  final RxnString errorMessage = RxnString();

  /// Создаёт контроллер.
  AddPaymentCardController({required this.paymentCardRepository});

  @override
  void onClose() {
    cardNumberController.dispose();
    cardHolderController.dispose();
    super.onClose();
  }

  /// Выполняет сохранение карты.
  Future<void> executeSaveCard() async {
    if (isBusy.value) {
      return;
    }
    final String rawDigits = cardNumberFormatter.getUnmaskedText();
    if (rawDigits.length != 16) {
      errorMessage.value = 'Введите полный номер карты.';
      return;
    }
    final String maskedPan =
        '${rawDigits.substring(0, 4)} ${rawDigits.substring(4, 8)} '
        '${rawDigits.substring(8, 12)} ${rawDigits.substring(12, 16)}';
    final String lastFour = rawDigits.substring(12, 16);
    final String holder = cardHolderController.text.trim();
    isBusy.value = true;
    errorMessage.value = null;
    try {
      final PaymentCardPayload payload = PaymentCardPayload(
        cardToken: rawDigits,
        maskedPan: maskedPan,
        lastFour: lastFour,
        holderName: holder.isEmpty ? null : holder.toUpperCase(),
        isDefault: isDefault.value,
      );
      await paymentCardRepository.createCard(payload);
      Get.back<bool>(result: true);
    } on DioException catch (error) {
      final String message =
          error.response?.data is Map<String, dynamic>
              ? _extractError(error.response!.data as Map<String, dynamic>)
              : error.message ?? 'Неизвестная ошибка';
      errorMessage.value = message;
    } catch (error) {
      final String message = error.toString();
      errorMessage.value = message;
    } finally {
      isBusy.value = false;
    }
  }

  String _extractError(Map<String, dynamic> data) {
    if (data.containsKey('errors')) {
      final Map<String, dynamic> errors =
          data['errors'] as Map<String, dynamic>;
      final Iterable<dynamic> firstField =
          errors.values.first as Iterable<dynamic>;
      return firstField.first.toString();
    }
    if (data.containsKey('message')) {
      return data['message'].toString();
    }
    return 'Произошла ошибка запроса.';
  }

}

