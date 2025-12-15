import '../../data/models/order/order_template_summary_entity.dart';

/// Аргументы открытия экрана шаблона заказа.
class OrderTemplateDetailArgs {
  /// Краткая информация о шаблоне.
  final OrderTemplateSummaryEntity template;

  /// Создает аргументы экрана шаблона.
  const OrderTemplateDetailArgs({required this.template});
}
