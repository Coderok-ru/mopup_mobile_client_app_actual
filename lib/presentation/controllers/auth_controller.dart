import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/auth/auth_session_entity.dart';
import '../../data/models/auth/city_entity.dart';
import '../../data/models/auth/user_entity.dart';
import '../../data/models/auth/login_payload.dart';
import '../../data/models/auth/profile_update_payload.dart';
import '../../data/models/auth/registration_payload.dart';
import '../../data/repositories/auth/auth_repository.dart';

/// Контроллер авторизации и профиля.
class AuthController extends GetxController {
  /// Поле телефона для входа.
  final TextEditingController loginPhoneController = TextEditingController();

  /// Поле пароля для входа.
  final TextEditingController loginPasswordController = TextEditingController();

  /// Поле имени регистрации.
  final TextEditingController registrationNameController =
      TextEditingController();

  /// Поле фамилии регистрации.
  final TextEditingController registrationSurnameController =
      TextEditingController();

  /// Поле почты регистрации.
  final TextEditingController registrationEmailController =
      TextEditingController();

  /// Поле телефона регистрации.
  final TextEditingController registrationPhoneController =
      TextEditingController();

  /// Поле пароля регистрации.
  final TextEditingController registrationPasswordController =
      TextEditingController();

  /// Поле подтверждения пароля.
  final TextEditingController registrationPasswordConfirmController =
      TextEditingController();

  /// Поле имени профиля.
  final TextEditingController profileNameController = TextEditingController();

  /// Поле фамилии профиля.
  final TextEditingController profileSurnameController =
      TextEditingController();

  /// Поле телефона профиля.
  final TextEditingController profilePhoneController = TextEditingController();

  /// Поле почты профиля.
  final TextEditingController profileEmailController = TextEditingController();

  /// Признак заполнения телефона при входе.
  final RxBool hasLoginPhone = false.obs;

  /// Признак заполнения имени.
  final RxBool hasRegistrationName = false.obs;

  /// Признак заполнения фамилии.
  final RxBool hasRegistrationSurname = false.obs;

  /// Признак заполнения телефона.
  final RxBool hasRegistrationPhone = false.obs;

  /// Признак принятия соглашения.
  final RxBool hasAcceptedAgreement = false.obs;

  /// Текущий пользователь.
  final Rxn<UserEntity> currentUser = Rxn<UserEntity>();

  /// Признак авторизации.
  final RxBool isAuthenticated = false.obs;

  /// Список городов.
  final RxList<CityEntity> cities = <CityEntity>[].obs;

  /// Выбранный город.
  final RxnInt selectedCityId = RxnInt();

  /// Индикатор загрузки.
  final RxBool isBusy = false.obs;

  /// Сообщение об ошибке.
  final RxnString errorMessage = RxnString();

  /// Байты аватара регистрации.
  final Rxn<Uint8List> registrationAvatarBytes = Rxn<Uint8List>();

  /// Путь к файлу аватара регистрации.
  final RxnString registrationAvatarPath = RxnString();

  /// Имя файла аватара регистрации.
  final RxnString registrationAvatarFileName = RxnString();

  /// Байты аватара профиля.
  final Rxn<Uint8List> profileAvatarBytes = Rxn<Uint8List>();

  /// Путь к файлу аватара профиля.
  final RxnString profileAvatarPath = RxnString();

  /// Имя файла аватара профиля.
  final RxnString profileAvatarFileName = RxnString();

  /// Маска телефона авторизации.
  final MaskTextInputFormatter loginPhoneFormatter = MaskTextInputFormatter(
    mask: '+7(###)###-####',
    filter: <String, RegExp>{'#': RegExp(r'\d')},
  );

  /// Маска телефона регистрации.
  final MaskTextInputFormatter registrationPhoneFormatter =
      MaskTextInputFormatter(
        mask: '+7(###)###-####',
        filter: <String, RegExp>{'#': RegExp(r'\d')},
      );

  /// Маска телефона профиля.
  final MaskTextInputFormatter profilePhoneFormatter = MaskTextInputFormatter(
    mask: '+7(###)###-####',
    filter: <String, RegExp>{'#': RegExp(r'\d')},
  );

  /// Репозиторий авторизации.
  final AuthRepository authRepository;

  final ImagePicker _imagePicker = ImagePicker();

  /// Completer для отслеживания процесса восстановления сессии.
  Completer<bool>? _sessionRestoreCompleter;

  /// Флаг, указывающий, был ли последний вызов hasSession с silent.
  bool _lastHasSessionWasSilent = false;

  /// Последняя ошибка при восстановлении сессии.
  Object? _lastSessionError;

  /// Создает контроллер.
  AuthController({required this.authRepository});

  @override
  void onInit() {
    super.onInit();
    loginPhoneController.addListener(_handleLoginPhoneChanged);
    registrationNameController.addListener(_handleRegistrationNameChanged);
    registrationSurnameController.addListener(
      _handleRegistrationSurnameChanged,
    );
    registrationPhoneController.addListener(_handleRegistrationPhoneChanged);
    _restoreSession();
    if (GetPlatform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_recoverLostRegistrationAvatar());
      });
    }
  }

  @override
  void onClose() {
    loginPhoneController.dispose();
    loginPasswordController.dispose();
    registrationNameController.dispose();
    registrationSurnameController.dispose();
    registrationEmailController.dispose();
    registrationPhoneController.dispose();
    registrationPasswordController.dispose();
    registrationPasswordConfirmController.dispose();
    profileNameController.dispose();
    profileSurnameController.dispose();
    profilePhoneController.dispose();
    profileEmailController.dispose();
    super.onClose();
  }

  /// Переключает соглашение.
  void toggleAgreement() {
    hasAcceptedAgreement.toggle();
  }

  /// Открывает регистрацию.
  Future<void> openRegistration() async {
    await loadCities();
    Get.toNamed(AppRoutes.registration);
  }

  /// Возвращает к авторизации.
  void openLogin() {
    Get.back();
  }

  /// Выбирает город.
  void selectCity(int? cityId) {
    selectedCityId.value = cityId;
  }

  /// Сбрасывает выбранный аватар регистрации.
  void clearRegistrationAvatar() {
    registrationAvatarBytes.value = null;
    registrationAvatarPath.value = null;
    registrationAvatarFileName.value = null;
  }

  /// Сбрасывает выбранный аватар профиля.
  void clearProfileAvatar() {
    profileAvatarBytes.value = null;
    profileAvatarPath.value = null;
    profileAvatarFileName.value = null;
  }

  /// Загружает изображение для аватара.
  Future<void> pickRegistrationAvatar(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file == null) {
        return;
      }
      final Uint8List bytes = await file.readAsBytes();
      registrationAvatarBytes.value = bytes;
      registrationAvatarFileName.value = file.name;
      registrationAvatarPath.value = kIsWeb ? null : file.path;
    } on PlatformException catch (error) {
      _showToast('Ошибка', error.message ?? 'Не удалось получить изображение.');
    } catch (error) {
      _handleUnknownError(error);
    }
  }

  /// Загружает изображение профиля.
  Future<void> pickProfileAvatar(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file == null) {
        return;
      }
      final Uint8List bytes = await file.readAsBytes();
      profileAvatarBytes.value = bytes;
      profileAvatarFileName.value = file.name;
      profileAvatarPath.value = kIsWeb ? null : file.path;
    } on PlatformException catch (error) {
      _showToast('Ошибка', error.message ?? 'Не удалось получить изображение.');
    } catch (error) {
      _handleUnknownError(error);
    }
  }

  /// Выполняет загрузку городов.
  Future<void> loadCities({bool force = false}) async {
    if (cities.isNotEmpty && !force) {
      _applyCitySelection(preferredCityId: currentUser.value?.cityId);
      return;
    }
    try {
      final List<CityEntity> loadedCities = await authRepository.loadCities();
      loadedCities.sort((CityEntity a, CityEntity b) => a.id.compareTo(b.id));
      cities.assignAll(loadedCities);
      _applyCitySelection(preferredCityId: currentUser.value?.cityId);
    } on DioException catch (error) {
      _handleError(error);
    } catch (error) {
      _handleUnknownError(error);
    }
  }

  /// Выполняет авторизацию.
  Future<void> executeLogin() async {
    if (isBusy.value) {
      return;
    }
    final String normalizedPhone = _normalizePhone(loginPhoneFormatter);
    if (normalizedPhone.isEmpty) {
      _showToast('Ошибка', 'Введите корректный номер телефона.');
      return;
    }
    isBusy.value = true;
    errorMessage.value = null;
    try {
      final LoginPayload payload = LoginPayload(
        phone: normalizedPhone,
        password: loginPasswordController.text,
      );
      final AuthSessionEntity session = await authRepository.login(payload);
      _applySession(session);
      await refreshProfile();
      Get.offAllNamed(AppRoutes.main);
    } on DioException catch (error) {
      _handleError(error);
    } catch (error) {
      _handleUnknownError(error);
    } finally {
      isBusy.value = false;
    }
  }

  /// Выполняет регистрацию.
  Future<void> executeRegistration() async {
    if (isBusy.value) {
      return;
    }
    if (registrationPasswordController.text !=
        registrationPasswordConfirmController.text) {
      _showToast('Ошибка', 'Пароли не совпадают.');
      return;
    }
    if (registrationPasswordController.text.length < 6) {
      _showToast('Ошибка', 'Пароль должен содержать не менее 6 символов.');
      return;
    }
    if (!hasAcceptedAgreement.value) {
      _showToast('Ошибка', 'Необходимо принять условия оферты.');
      return;
    }
    if (selectedCityId.value == null) {
      _showToast('Ошибка', 'Выберите город.');
      return;
    }
    final String normalizedPhone = _normalizePhone(registrationPhoneFormatter);
    if (normalizedPhone.isEmpty) {
      _showToast('Ошибка', 'Введите корректный номер телефона.');
      return;
    }
    isBusy.value = true;
    errorMessage.value = null;
    try {
      final RegistrationPayload payload = RegistrationPayload(
        name: registrationNameController.text.trim(),
        lastName: registrationSurnameController.text.trim(),
        phone: normalizedPhone,
        email: registrationEmailController.text.trim(),
        password: registrationPasswordController.text,
        passwordConfirmation: registrationPasswordConfirmController.text,
        cityId: selectedCityId.value!,
        avatarPath: registrationAvatarPath.value,
        avatarBytes: registrationAvatarBytes.value,
        avatarFileName: registrationAvatarFileName.value,
      );
      final AuthSessionEntity session = await authRepository.register(payload);
      _applySession(session);
      await refreshProfile();
      clearRegistrationAvatar();
      Get.offAllNamed(AppRoutes.main);
    } on DioException catch (error) {
      _handleError(error);
    } catch (error) {
      _handleUnknownError(error);
    } finally {
      isBusy.value = false;
    }
  }

  /// Загружает профиль.
  Future<void> refreshProfile({bool silent = false}) async {
    try {
      final UserEntity profile = await authRepository.loadProfile();
      debugPrint('Получен профиль: avatar=${profile.avatarUrl}');
      currentUser.value = profile;
      _fillProfileFields(profile);
      clearProfileAvatar();
    } on DioException catch (error) {
      if (!silent) {
        _handleError(error);
      }
    } catch (error) {
      if (!silent) {
        _handleUnknownError(error);
      }
    }
  }

  /// Обновляет данные главного экрана.
  Future<void> refreshHomeData() async {
    await Future.wait(<Future<void>>[
      refreshProfile(),
      loadCities(force: true),
    ]);
  }

  /// Обновляет профиль.
  Future<void> executeProfileUpdate() async {
    if (isBusy.value) {
      return;
    }
    final String normalizedPhone = _normalizePhone(profilePhoneFormatter);
    if (profilePhoneController.text.trim().isNotEmpty &&
        normalizedPhone.isEmpty) {
      _showToast('Ошибка', 'Введите корректный номер телефона.');
      return;
    }
    isBusy.value = true;
    errorMessage.value = null;
    try {
      final ProfileUpdatePayload payload = ProfileUpdatePayload(
        name: profileNameController.text.trim(),
        lastName: profileSurnameController.text.trim(),
        phone: normalizedPhone.isEmpty ? null : normalizedPhone,
        email: profileEmailController.text.trim(),
        cityId: selectedCityId.value,
        avatarPath: profileAvatarPath.value,
        avatarBytes: profileAvatarBytes.value,
        avatarFileName: profileAvatarFileName.value,
      );
      final UserEntity updated = await authRepository.updateProfile(payload);
      currentUser.value = updated;
      _fillProfileFields(updated);
      clearProfileAvatar();
      _showToast('Готово', 'Профиль обновлен.');
    } on DioException catch (error) {
      _handleError(error);
    } catch (error) {
      _handleUnknownError(error);
    } finally {
      isBusy.value = false;
    }
  }

  /// Выполняет выход.
  Future<void> executeLogout() async {
    if (isBusy.value) {
      return;
    }
    isBusy.value = true;
    try {
      await authRepository.logout();
    } catch (_) {}
    await authRepository.clearSession();
    currentUser.value = null;
    isAuthenticated.value = false;
    selectedCityId.value = null;
    loginPhoneFormatter.clear();
    registrationPhoneFormatter.clear();
    profilePhoneFormatter.clear();
    loginPhoneController.clear();
    loginPasswordController.clear();
    registrationNameController.clear();
    registrationSurnameController.clear();
    registrationEmailController.clear();
    registrationPhoneController.clear();
    registrationPasswordController.clear();
    registrationPasswordConfirmController.clear();
    clearRegistrationAvatar();
    clearProfileAvatar();
    profileNameController.clear();
    profileSurnameController.clear();
    profilePhoneController.clear();
    profileEmailController.clear();
    isBusy.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  /// Удаляет аккаунт.
  Future<void> executeDeleteAccount() async {
    if (isBusy.value) {
      return;
    }
    isBusy.value = true;
    errorMessage.value = null;
    try {
      await authRepository.deleteAccount();
      await authRepository.clearSession();
      currentUser.value = null;
      isAuthenticated.value = false;
      selectedCityId.value = null;
      loginPhoneFormatter.clear();
      registrationPhoneFormatter.clear();
      profilePhoneFormatter.clear();
      loginPhoneController.clear();
      loginPasswordController.clear();
      registrationNameController.clear();
      registrationSurnameController.clear();
      registrationEmailController.clear();
      registrationPhoneController.clear();
      registrationPasswordController.clear();
      registrationPasswordConfirmController.clear();
      clearRegistrationAvatar();
      clearProfileAvatar();
      profileNameController.clear();
      profileSurnameController.clear();
      profilePhoneController.clear();
      profileEmailController.clear();
      Get.offAllNamed(AppRoutes.login);
      _showToast('Готово', 'Аккаунт удален.');
    } on DioException catch (error) {
      _handleError(error);
    } catch (error) {
      _handleUnknownError(error);
    } finally {
      isBusy.value = false;
    }
  }

  /// Проверяет наличие сессии.
  Future<bool> hasSession({bool silent = false}) async {
    if (_sessionRestoreCompleter != null) {
      final bool result = await _sessionRestoreCompleter!.future;
      if (!silent && _lastHasSessionWasSilent && _lastSessionError != null) {
        if (_lastSessionError is DioException) {
          _handleError(_lastSessionError as DioException);
        } else {
          _handleUnknownError(_lastSessionError!);
        }
      }
      return result;
    }
    _sessionRestoreCompleter = Completer<bool>();
    _lastHasSessionWasSilent = silent;
    _lastSessionError = null;
    try {
      final AuthSessionEntity? session = authRepository.readSession();
      if (session == null) {
        _sessionRestoreCompleter!.complete(false);
        _sessionRestoreCompleter = null;
        return false;
      }
      _applySession(session);
      await refreshProfile(silent: silent);
      _sessionRestoreCompleter!.complete(true);
      _sessionRestoreCompleter = null;
      return true;
    } catch (error) {
      _lastSessionError = error;
      _sessionRestoreCompleter!.complete(false);
      _sessionRestoreCompleter = null;
      if (!silent) {
        rethrow;
      }
      return false;
    }
  }

  void _restoreSession() {
    if (_sessionRestoreCompleter == null) {
      _sessionRestoreCompleter = Completer<bool>();
      _lastHasSessionWasSilent = true;
      _lastSessionError = null;
      unawaited(_restoreSessionInternal());
    }
  }

  Future<void> _restoreSessionInternal() async {
    try {
      final AuthSessionEntity? session = authRepository.readSession();
      if (session == null) {
        _sessionRestoreCompleter!.complete(false);
        _sessionRestoreCompleter = null;
        return;
      }
      _applySession(session);
      await refreshProfile(silent: true);
      _sessionRestoreCompleter!.complete(true);
      _sessionRestoreCompleter = null;
    } catch (error) {
      _lastSessionError = error;
      _sessionRestoreCompleter!.complete(false);
      _sessionRestoreCompleter = null;
    }
  }

  Future<void> _recoverLostRegistrationAvatar() async {
    if (!GetPlatform.isAndroid) {
      return;
    }
    LostDataResponse response;
    try {
      response = await _imagePicker.retrieveLostData();
    } on PlatformException catch (error) {
      debugPrint(
        'ImagePicker retrieveLostData error: ${error.message ?? error.code}',
      );
      return;
    } catch (error) {
      debugPrint('ImagePicker retrieveLostData unexpected error: $error');
      return;
    }
    if (response.isEmpty) {
      return;
    }
    if (response.files != null && response.files!.isNotEmpty) {
      final XFile file = response.files!.first;
      final Uint8List bytes = await file.readAsBytes();
      registrationAvatarBytes.value = bytes;
      registrationAvatarFileName.value = file.name;
      registrationAvatarPath.value = kIsWeb ? null : file.path;
      return;
    }
    final PlatformException? exception = response.exception;
    if (exception != null) {
      _showToast(
        'Ошибка',
        exception.message ?? 'Не удалось восстановить изображение.',
      );
    }
  }

  void _applySession(AuthSessionEntity session) {
    debugPrint('Auth token: ${session.token}');
    currentUser.value = session.user;
    isAuthenticated.value = true;
    _fillProfileFields(session.user);
  }

  void _fillProfileFields(UserEntity user) {
    profileNameController.text = user.name;
    profileSurnameController.text = user.lastName;
    _applyMaskedPhone(
      formatter: profilePhoneFormatter,
      controller: profilePhoneController,
      rawValue: user.phone,
    );
    profileEmailController.text = user.email;
    _applyCitySelection(preferredCityId: user.cityId);
  }

  String _normalizePhone(MaskTextInputFormatter formatter) {
    final String digits = formatter.getUnmaskedText();
    if (digits.length != 10) {
      return '';
    }
    return '+7$digits';
  }

  void _applyMaskedPhone({
    required MaskTextInputFormatter formatter,
    required TextEditingController controller,
    required String rawValue,
  }) {
    formatter.clear();
    final String digits = rawValue.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      controller.clear();
      return;
    }
    final String normalized = _extractCorePhoneDigits(digits);
    if (normalized.isEmpty) {
      controller.clear();
      return;
    }
    final TextEditingValue maskedValue = formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: normalized),
    );
    controller.value = maskedValue;
  }

  String _extractCorePhoneDigits(String digits) {
    String result = digits.replaceAll(RegExp(r'\D'), '');
    if (result.length >= 11 &&
        (result.startsWith('7') || result.startsWith('8'))) {
      result = result.substring(1);
    }
    if (result.length > 10) {
      result = result.substring(result.length - 10);
    }
    return result.length == 10 ? result : '';
  }

  void _applyCitySelection({int? preferredCityId}) {
    if (cities.isEmpty) {
      if (preferredCityId != null) {
        selectedCityId.value = preferredCityId;
      }
      return;
    }
    if (preferredCityId != null &&
        cities.any((CityEntity city) => city.id == preferredCityId)) {
      selectedCityId.value = preferredCityId;
      return;
    }
    if (selectedCityId.value != null &&
        cities.any((CityEntity city) => city.id == selectedCityId.value)) {
      return;
    }
    selectedCityId.value = cities.first.id;
  }

  void _handleLoginPhoneChanged() {
    hasLoginPhone.value = loginPhoneFormatter.isFill();
  }

  void _handleRegistrationNameChanged() {
    hasRegistrationName.value = registrationNameController.text.isNotEmpty;
  }

  void _handleRegistrationSurnameChanged() {
    hasRegistrationSurname.value =
        registrationSurnameController.text.isNotEmpty;
  }

  void _handleRegistrationPhoneChanged() {
    hasRegistrationPhone.value = registrationPhoneFormatter.isFill();
  }

  void _handleError(DioException error) {
    final String message = error.response?.data is Map<String, dynamic>
        ? _extractError(error.response!.data as Map<String, dynamic>)
        : error.message ?? 'Неизвестная ошибка';
    errorMessage.value = message;
    _showToast('Ошибка', message);
  }

  String _extractError(Map<String, dynamic> data) {
    if (data.containsKey('errors')) {
      final Map<String, dynamic> errors =
          data['errors'] as Map<String, dynamic>;
      final Iterable<dynamic> firstField =
          errors.values.first as Iterable<dynamic>;
      return firstField.first.toString();
    }
    if (data.containsKey('message')) {
      return data['message'].toString();
    }
    return 'Произошла ошибка запроса.';
  }

  void _handleUnknownError(Object error) {
    final String message = error.toString();
    errorMessage.value = message;
    _showToast('Ошибка', message);
  }

  void _showToast(String title, String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    final bool isError = title == 'Ошибка';
    final bool isSuccess = title == 'Готово';
    final Color backgroundColor = isError
        ? AppColors.errorRed
        : isSuccess
        ? AppColors.accentGreen
        : AppColors.white;
    final Color textColor = isError || isSuccess
        ? AppColors.white
        : AppColors.grayDark;
    Get.snackbar(
      title,
      message,
      duration: const Duration(seconds: 4),
      backgroundColor: backgroundColor,
      colorText: textColor,
    );
  }
}
