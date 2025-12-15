import 'package:dio/dio.dart';

import '../../../data/models/auth/auth_session_entity.dart';
import '../../../data/datasources/auth/auth_local_data_source.dart';

/// Добавляет заголовок авторизации к защищенным запросам.
class AuthInterceptor extends Interceptor {
  /// Источник локальных данных авторизации.
  final AuthLocalDataSource localDataSource;

  /// Создает перехватчик авторизации.
  AuthInterceptor({required this.localDataSource});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final AuthSessionEntity? session = localDataSource.loadSession();
    if (session != null && session.token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${session.token}';
      print('Добавлен токен авторизации для запроса: ${options.path}');
    } else {
      print('Токен авторизации не найден для запроса: ${options.path}');
    }
    handler.next(options);
  }
}
