import '../../models/favorite_cleaner/favorite_cleaner_entity.dart';

/// Контракт работы с любимыми клинерами.
abstract class FavoriteCleanerRepository {
  /// Возвращает список избранных клинеров.
  Future<List<FavoriteCleanerEntity>> getFavorites();

  /// Проверяет, является ли клинер избранным.
  Future<bool> isFavorite(int cleanerId);

  /// Добавляет клинера в избранные.
  Future<void> addFavorite(int cleanerId);

  /// Удаляет клинера из избранных.
  Future<void> removeFavorite(int cleanerId);
}


