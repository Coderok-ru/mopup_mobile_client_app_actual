import 'package:dio/dio.dart';

import '../../../core/constants/app_urls.dart';
import '../../models/favorite_cleaner/favorite_cleaner_entity.dart';
import 'favorite_cleaner_repository.dart';

/// Репозиторий любимых клинеров, работающий через REST API.
class FavoriteCleanerRepositoryImpl implements FavoriteCleanerRepository {
  /// HTTP-клиент.
  final Dio dio;

  /// Создает репозиторий любимых клинеров.
  const FavoriteCleanerRepositoryImpl({required this.dio});

  @override
  Future<List<FavoriteCleanerEntity>> getFavorites() async {
    final Response<dynamic> response = await dio.get<dynamic>(
      AppUrls.favoriteCleaners,
    );
    if (response.data is! Map<String, dynamic>) {
      return <FavoriteCleanerEntity>[];
    }
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    final dynamic rawList = data['data'];
    if (rawList is! List<dynamic>) {
      return <FavoriteCleanerEntity>[];
    }
    final List<FavoriteCleanerEntity> favorites = <FavoriteCleanerEntity>[];
    for (final dynamic item in rawList) {
      if (item is Map<String, dynamic>) {
        favorites.add(FavoriteCleanerEntity.fromJson(item));
      }
    }
    return favorites;
  }

  @override
  Future<bool> isFavorite(int cleanerId) async {
    try {
      final Response<dynamic> response = await dio.get<dynamic>(
        AppUrls.favoriteCleaners,
      );
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data =
            response.data as Map<String, dynamic>;
        final dynamic list = data['data'];
        if (list is List<dynamic>) {
          for (final dynamic item in list) {
            if (item is Map<String, dynamic>) {
              final dynamic id = item['id'];
              if (id is int && id == cleanerId) {
                return true;
              }
              if (id is String &&
                  int.tryParse(id) != null &&
                  int.parse(id) == cleanerId) {
                return true;
              }
            }
          }
        }
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  @override
  Future<void> addFavorite(int cleanerId) async {
    await dio.post<dynamic>(
      AppUrls.favoriteCleaners,
      data: <String, dynamic>{'cleaner_id': cleanerId},
    );
  }

  @override
  Future<void> removeFavorite(int cleanerId) async {
    await dio.delete<dynamic>(
      '${AppUrls.favoriteCleaners}/$cleanerId',
    );
  }
}


