import 'package:get_storage/get_storage.dart';

import '../../../core/constants/storage_keys.dart';
import '../../models/address/address_selection_model.dart';

/// Работает с локальным хранилищем адреса доставки.
class AddressLocalDataSource {
  /// Экземпляр локального хранилища.
  final GetStorage storage;

  /// Создает источник локальных данных.
  AddressLocalDataSource({required this.storage});

  /// Сохраняет выбранный адрес.
  Future<void> saveSelection(AddressSelectionModel selection) {
    return storage.write(StorageKeys.orderAddress, selection.toJsonString());
  }

  /// Возвращает сохраненный адрес.
  AddressSelectionModel? loadSelection() {
    final String? raw = storage.read<String>(StorageKeys.orderAddress);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return AddressSelectionModel.fromJsonString(raw);
  }

  /// Очищает сохраненный адрес.
  Future<void> clearSelection() {
    return storage.remove(StorageKeys.orderAddress);
  }
}
