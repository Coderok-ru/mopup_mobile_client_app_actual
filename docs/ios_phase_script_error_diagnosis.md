# Диагностика ошибки: Command PhaseScriptExecution failed with a nonzero exit code

## Общее описание

Ошибка "Command PhaseScriptExecution failed with a nonzero exit code" возникает, когда один из скриптов сборки в Xcode завершается с ненулевым кодом возврата. Это означает, что скрипт выполнился, но завершился с ошибкой.

## Быстрая диагностика

Запустите скрипт диагностики:

```bash
bash ios_diagnose.sh
```

Этот скрипт проверит все возможные причины ошибки и даст рекомендации по исправлению.

## Основные причины

### 1. Проблемы с переменными окружения Flutter

**Симптомы:**
- Скрипт не может найти `FLUTTER_ROOT`
- Ошибки типа "FLUTTER_ROOT not found"
- Скрипт `xcode_backend.sh` не найден

**Причины:**
- Переменная `FLUTTER_ROOT` не загружена из `Generated.xcconfig`
- Файл `Generated.xcconfig` не существует или поврежден
- Неправильный путь к Flutter SDK

**Решение:**
```bash
# Проверьте существование файла
ls -la ios/Flutter/Generated.xcconfig

# Проверьте содержимое
cat ios/Flutter/Generated.xcconfig

# Если файл отсутствует, выполните:
flutter clean
flutter pub get
```

**Исправление (уже применено):**
Скрипты сборки обновлены для автоматической загрузки переменных:
```bash
source "${SRCROOT}/Flutter/Generated.xcconfig"
```

### 2. Проблемы с CocoaPods

**Симптомы:**
- Ошибки в скриптах "[CP] Copy Pods Resources"
- Ошибки "[CP] Embed Pods Frameworks"
- Ошибки "[CP] Check Pods Manifest.lock"
- "Podfile.lock" и "Manifest.lock" не синхронизированы

**Причины:**
- Pods не установлены или установлены неправильно
- Версии Pods не совпадают с Podfile.lock
- Поврежденный кеш CocoaPods

**Решение:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod deintegrate  # если установлен
pod cache clean --all
pod repo update
pod install --repo-update
cd ..
```

### 3. Проблемы с путями и правами доступа

**Симптомы:**
- "Permission denied"
- "No such file or directory"
- Скрипты не могут найти файлы

**Причины:**
- Недостаточные права доступа к файлам
- Неправильные пути к скриптам
- Проблемы с пробелами в путях

**Решение:**
```bash
# Проверьте права доступа
chmod +x ios/Flutter/ephemeral/flutter_export_environment.sh
chmod +x "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"

# Проверьте существование скриптов
ls -la "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"
```

### 4. Проблемы с DerivedData Xcode

**Симптомы:**
- Неожиданные ошибки сборки
- Устаревшие файлы в кеше
- Конфликты между сборками

**Причины:**
- Поврежденный кеш DerivedData
- Конфликты между разными версиями Xcode
- Недостаточно места на диске

**Решение:**
```bash
# Очистите DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# В Xcode: Product → Clean Build Folder (Shift+Cmd+K)
```

### 5. Проблемы с версиями инструментов

**Симптомы:**
- Несовместимость версий Flutter и Xcode
- Ошибки компиляции Swift
- Проблемы с CocoaPods

**Причины:**
- Устаревшая версия Flutter
- Устаревшая версия CocoaPods
- Несовместимость версий Xcode и iOS SDK

**Решение:**
```bash
# Проверьте версии
flutter --version
pod --version
xcodebuild -version

# Обновите при необходимости
flutter upgrade
sudo gem install cocoapods
```

### 6. Проблемы с зависимостями плагинов

**Симптомы:**
- Ошибки при компиляции конкретных плагинов
- Проблемы с нативными библиотеками
- Конфликты версий зависимостей

**Причины:**
- Несовместимые версии плагинов
- Проблемы с нативными зависимостями (например, YandexMapKit)
- Отсутствующие системные библиотеки

**Решение:**
```bash
# Обновите зависимости
flutter pub upgrade

# Переустановите Pods
cd ios
pod install --repo-update
cd ..
```

### 7. Проблемы с архитектурами (Architectures)

**Симптомы:**
- Ошибки при сборке для симулятора
- Проблемы с arm64/x86_64
- Ошибки линковки

**Причины:**
- Неправильные настройки архитектур в Xcode
- Конфликты между архитектурами симулятора и устройства
- Проблемы с универсальными бинарниками

**Решение:**
Проверьте настройки в Xcode:
- Build Settings → Architectures
- Build Settings → Excluded Architectures
- Build Settings → Valid Architectures

### 8. Проблемы с подписью кода (Code Signing)

**Симптомы:**
- Ошибки подписи кода
- Проблемы с сертификатами
- Ошибки provisioning profiles

**Причины:**
- Неправильные настройки подписи
- Отсутствующие сертификаты
- Проблемы с provisioning profiles

**Решение:**
В Xcode проверьте:
- Signing & Capabilities → Team
- Signing & Capabilities → Bundle Identifier
- Signing & Capabilities → Provisioning Profile

## Как определить конкретную причину

### Шаг 1: Проверьте логи Xcode

1. Откройте Xcode
2. View → Navigators → Show Report Navigator (Cmd+9)
3. Найдите последнюю сборку с ошибкой
4. Раскройте детали ошибки
5. Найдите конкретный скрипт, который упал

### Шаг 2: Включите подробный вывод скриптов

В Xcode:
1. Откройте проект
2. Выберите target "Runner"
3. Build Phases → найдите проблемный скрипт
4. Раскройте скрипт и добавьте в начало:
   ```bash
   set -x  # Включить отладочный вывод
   set -e  # Остановить при ошибке
   ```

### Шаг 3: Запустите скрипт вручную

Попробуйте выполнить скрипт вручную в терминале:

```bash
cd /Users/coderok/AndroidStudioProjects/mopup/ios

# Для скрипта "Run Script"
source Flutter/Generated.xcconfig
/bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" build

# Для скрипта "Thin Binary"
source Flutter/Generated.xcconfig
/bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" embed_and_thin
```

Это покажет точную ошибку.

## Типичные скрипты и их проблемы

### 1. "Run Script" (Flutter build)

**Что делает:** Собирает Flutter приложение

**Типичные ошибки:**
- `FLUTTER_ROOT not found`
- `Dart SDK not found`
- Проблемы с путями к файлам

**Решение:** Убедитесь, что `Generated.xcconfig` существует и содержит правильный `FLUTTER_ROOT`

### 2. "Thin Binary" (Flutter embed_and_thin)

**Что делает:** Встраивает Flutter framework и оптимизирует бинарник

**Типичные ошибки:**
- Проблемы с путями к framework
- Ошибки при копировании файлов
- Проблемы с архитектурами

**Решение:** Проверьте, что Flutter framework собран правильно

### 3. "[CP] Copy Pods Resources"

**Что делает:** Копирует ресурсы из CocoaPods

**Типичные ошибки:**
- Файлы ресурсов не найдены
- Проблемы с путями
- Конфликты версий Pods

**Решение:** Переустановите Pods

### 4. "[CP] Embed Pods Frameworks"

**Что делает:** Встраивает frameworks из CocoaPods

**Типичные ошибки:**
- Frameworks не найдены
- Проблемы с архитектурами
- Конфликты версий

**Решение:** Проверьте установку Pods и совместимость версий

### 5. "[CP] Check Pods Manifest.lock"

**Что делает:** Проверяет синхронизацию Podfile.lock и Manifest.lock

**Типичные ошибки:**
- Файлы не синхронизированы
- Разные версии Pods

**Решение:** Выполните `pod install`

## Полная диагностика

Выполните следующую последовательность команд для полной диагностики:

```bash
# 1. Проверка Flutter
flutter doctor -v

# 2. Проверка путей
echo "FLUTTER_ROOT: $FLUTTER_ROOT"
ls -la "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"

# 3. Проверка Generated.xcconfig
cat ios/Flutter/Generated.xcconfig

# 4. Проверка CocoaPods
cd ios
pod --version
pod repo list
ls -la Podfile.lock
ls -la Pods/Manifest.lock
cd ..

# 5. Проверка прав доступа
ls -la ios/Flutter/ephemeral/flutter_export_environment.sh
chmod +x ios/Flutter/ephemeral/flutter_export_environment.sh

# 6. Очистка и переустановка
flutter clean
flutter pub get
cd ios
pod install --repo-update
cd ..
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

## Быстрое решение (если ничего не помогает)

1. **Полная очистка:**
   ```bash
   flutter clean
   cd ios
   rm -rf Pods Podfile.lock .symlinks
   rm -rf Flutter/Flutter.framework Flutter/Flutter.podspec
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   cd ..
   ```

2. **Переустановка:**
   ```bash
   flutter pub get
   cd ios
   pod install --repo-update
   cd ..
   ```

3. **Сборка через Flutter:**
   ```bash
   flutter build ios --no-codesign
   ```

4. **Если не помогло, откройте в Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Product → Clean Build Folder (Shift+Cmd+K)
   - Product → Build (Cmd+B)
   - Проверьте логи ошибок в Report Navigator

## Контакты

Если проблема не решается, обратитесь к разработчику:
- Email: info@coderok.ru
- Сайт: https://coderok.ru

