/// Описывает город регистрации.
class CityEntity {
  /// Идентификатор города.
  final int id;

  /// Название города.
  final String name;

  /// Создает сущность города.
  const CityEntity({required this.id, required this.name});

  /// Создает сущность из JSON.
  factory CityEntity.fromJson(Map<String, dynamic> json) {
    return CityEntity(id: json['id'] as int, name: json['name'] as String);
  }

  /// Преобразует сущность в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name};
  }
}
