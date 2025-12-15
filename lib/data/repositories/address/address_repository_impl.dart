import '../../datasources/address/address_local_data_source.dart';
import '../../models/address/address_selection_model.dart';
import 'address_repository.dart';

/// Реализация репозитория выбора адреса.
class AddressRepositoryImpl implements AddressRepository {
  /// Источник локальных данных.
  final AddressLocalDataSource localDataSource;

  /// Создает репозиторий.
  AddressRepositoryImpl({required this.localDataSource});

  @override
  AddressSelectionModel? loadSelection() {
    return localDataSource.loadSelection();
  }

  @override
  Future<void> saveSelection(AddressSelectionModel selection) {
    return localDataSource.saveSelection(selection);
  }

  @override
  Future<void> clearSelection() {
    return localDataSource.clearSelection();
  }
}
