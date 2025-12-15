import '../../models/order/order_template_detail_entity.dart';
import '../../models/order/order_template_summary_entity.dart';

/// Контракт загрузки шаблонов заказов.
abstract class OrderTemplateRepository {
  /// Загружает список шаблонов по городу.
  Future<List<OrderTemplateSummaryEntity>> loadTemplates(int cityId);

  /// Загружает детальный шаблон по городу.
  Future<OrderTemplateDetailEntity> loadTemplate(int templateId, int cityId);
}
