import 'package:dio/dio.dart';

import '../constants/app_urls.dart';

/// Создает и настраивает экземпляр Dio.
Dio createDioClient() {
  final BaseOptions options = BaseOptions(
    baseUrl: AppUrls.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    responseType: ResponseType.json,
    contentType: Headers.jsonContentType,
  );
  return Dio(options);
}
