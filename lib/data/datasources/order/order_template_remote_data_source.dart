import 'package:dio/dio.dart';

import '../../../core/constants/app_urls.dart';
import '../../models/order/order_template_detail_entity.dart';
import '../../models/order/order_template_summary_entity.dart';

/// Загружает шаблоны заказов через REST API.
class OrderTemplateRemoteDataSource {
  /// Клиент HTTP.
  final Dio dio;

  /// Создает источник данных шаблонов заказов.
  const OrderTemplateRemoteDataSource({required this.dio});

  /// Загружает шаблоны по идентификатору города.
  Future<List<OrderTemplateSummaryEntity>> loadTemplates({
    required int cityId,
  }) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      AppUrls.orderTemplates,
      queryParameters: <String, dynamic>{'city_id': cityId},
    );
    final List<dynamic> rawItems = _extractItems(response.data);
    final List<OrderTemplateSummaryEntity> templates = rawItems
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) {
          return OrderTemplateSummaryEntity.fromJson(item);
        })
        .where((OrderTemplateSummaryEntity entity) => entity.id > 0)
        .toList();
    return templates;
  }

  /// Загружает детальный шаблон.
  Future<OrderTemplateDetailEntity> loadTemplateDetail({
    required int templateId,
    required int cityId,
  }) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      '${AppUrls.orderTemplates}/$templateId',
      queryParameters: <String, dynamic>{'city_id': cityId},
    );
    final Map<String, dynamic> rawData = _extractMap(response.data);
    return OrderTemplateDetailEntity.fromJson(rawData);
  }

  List<dynamic> _extractItems(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final List<String> keys = <String>['data', 'templates', 'items'];
      for (final String key in keys) {
        final dynamic value = data[key];
        if (value is List<dynamic>) {
          return value;
        }
      }
    }
    return <dynamic>[];
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    return <String, dynamic>{};
  }
}
