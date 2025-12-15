import '../../models/address/address_selection_model.dart';

/// Контракт репозитория выбранного адреса.
abstract class AddressRepository {
  /// Загружает сохраненный адрес.
  AddressSelectionModel? loadSelection();

  /// Сохраняет выбор.
  Future<void> saveSelection(AddressSelectionModel selection);

  /// Очищает сохраненный адрес.
  Future<void> clearSelection();
}
