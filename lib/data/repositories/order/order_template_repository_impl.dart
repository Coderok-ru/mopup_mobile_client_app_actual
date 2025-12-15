import '../../datasources/order/order_template_remote_data_source.dart';
import '../../models/order/order_template_detail_entity.dart';
import '../../models/order/order_template_summary_entity.dart';
import 'order_template_repository.dart';

/// Репозиторий шаблонов заказов.
class OrderTemplateRepositoryImpl implements OrderTemplateRepository {
  /// Удаленный источник данных.
  final OrderTemplateRemoteDataSource remoteDataSource;

  /// Создает репозиторий шаблонов заказов.
  const OrderTemplateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrderTemplateSummaryEntity>> loadTemplates(int cityId) {
    return remoteDataSource.loadTemplates(cityId: cityId);
  }

  @override
  Future<OrderTemplateDetailEntity> loadTemplate(int templateId, int cityId) {
    return remoteDataSource.loadTemplateDetail(
      templateId: templateId,
      cityId: cityId,
    );
  }
}
