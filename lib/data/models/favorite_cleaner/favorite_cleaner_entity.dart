/// Сущность избранного клинера.
class FavoriteCleanerEntity {
  /// Идентификатор клинера.
  final int id;

  /// Имя клинера.
  final String name;

  /// Фамилия клинера.
  final String lastName;

  /// Рейтинг клинера.
  final double rating;

  /// URL аватара клинера.
  final String? profilePhotoUrl;

  /// Создает сущность избранного клинера.
  const FavoriteCleanerEntity({
    required this.id,
    required this.name,
    required this.lastName,
    required this.rating,
    required this.profilePhotoUrl,
  });

  /// Создает сущность из JSON-данных API.
  factory FavoriteCleanerEntity.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'];
    final int parsedId = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    final String rawName = (json['name'] as String? ?? '').trim();
    final String rawLastName = (json['lname'] as String? ?? '').trim();
    final dynamic rawRating = json['rating'];
    double parsedRating = 0.0;
    if (rawRating is num) {
      parsedRating = rawRating.toDouble();
    } else if (rawRating is String) {
      parsedRating = double.tryParse(rawRating) ?? 0.0;
    }
    final String? photoUrl = (json['profile_photo_url'] as String?)?.trim();
    return FavoriteCleanerEntity(
      id: parsedId,
      name: rawName,
      lastName: rawLastName,
      rating: parsedRating,
      profilePhotoUrl: photoUrl?.isEmpty == true ? null : photoUrl,
    );
  }
}


