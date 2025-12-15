/// Описывает пункт FAQ рейтинга.
class RatingFaqSectionEntity {
  /// Заголовок вопроса.
  final String title;

  /// Ответ на вопрос.
  final String description;

  /// Создает сущность FAQ для рейтинга.
  const RatingFaqSectionEntity({
    required this.title,
    required this.description,
  });
}
