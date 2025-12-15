import '../../models/auth/user_entity.dart';
import '../../models/rating/rating_info_entity.dart';

/// Контракты получения рейтинга пользователя.
abstract class RatingRepository {
  /// Загружает информацию о рейтинге.
  Future<RatingInfoEntity> loadRating(UserEntity user);
}
