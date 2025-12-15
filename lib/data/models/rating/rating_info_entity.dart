import 'rating_faq_section_entity.dart';

/// Описывает агрегированную информацию о рейтинге пользователя.
class RatingInfoEntity {
  /// Текущее значение рейтинга.
  final double value;

  /// Дата и время последнего обновления.
  final DateTime updatedAt;

  /// Список разделов с пояснениями.
  final List<RatingFaqSectionEntity> faqSections;

  /// Создает сущность с информацией о рейтинге.
  const RatingInfoEntity({
    required this.value,
    required this.updatedAt,
    required this.faqSections,
  });
}
