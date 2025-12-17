# Исправление ошибки сборки iOS: "Command PhaseScriptExecution failed with a nonzero exit code"

## Быстрое решение

### Автоматическое исправление

Запустите скрипт исправления:

```bash
bash ios_fix_build.sh
```

### Ручное исправление

Выполните следующие команды в терминале:

```bash
cd ios
rm -rf Pods Podfile.lock .symlinks
rm -rf Flutter/Flutter.framework Flutter/Flutter.podspec
cd ..
flutter clean
flutter pub get
cd ios
pod install --repo-update
cd ..
rm -rf ~/Library/Developer/Xcode/DerivedData/*
flutter build ios
```

**Важно:** После выполнения команд откройте `ios/Runner.xcworkspace` в Xcode и выполните:
- Product → Clean Build Folder (Shift+Cmd+K)
- Product → Build (Cmd+B)

## Детальное решение

### Шаг 1: Очистка проекта

```bash
# Из корня проекта
flutter clean
cd ios
rm -rf Pods Podfile.lock .symlinks
rm -rf Flutter/Flutter.framework Flutter/Flutter.podspec
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### Шаг 2: Переустановка зависимостей

```bash
# Из корня проекта
flutter pub get
cd ios
pod deintegrate  # Если установлен
pod install --repo-update
```

### Шаг 3: Проверка путей Flutter

Убедитесь, что переменная `FLUTTER_ROOT` правильно установлена:

```bash
echo $FLUTTER_ROOT
# Должен показать путь к Flutter SDK, например:
# /Users/yourname/flutter
```

Если переменная не установлена, добавьте в `~/.zshrc` или `~/.bash_profile`:

```bash
export FLUTTER_ROOT=/path/to/flutter
export PATH="$FLUTTER_ROOT/bin:$PATH"
```

### Шаг 4: Проверка прав доступа к скриптам

```bash
cd ios
chmod +x Flutter/ephemeral/flutter_export_environment.sh
chmod +x "${FLUTTER_ROOT}/packages/flutter_tools/bin/xcode_backend.sh"
```

### Шаг 5: Сборка через Xcode

1. Откройте `ios/Runner.xcworkspace` (не `.xcodeproj`!)
2. Выберите схему `Runner`
3. Выберите устройство или симулятор
4. Product → Clean Build Folder (Shift+Cmd+K)
5. Product → Build (Cmd+B)

### Шаг 6: Если проблема сохраняется

#### Проверка версии CocoaPods

```bash
pod --version
# Рекомендуется версия 1.15.0 или выше
sudo gem install cocoapods
```

#### Проверка версии Flutter

```bash
flutter --version
flutter doctor -v
```

Убедитесь, что все компоненты установлены правильно.

#### Проверка Xcode Command Line Tools

```bash
xcode-select --print-path
# Должен показать путь к Xcode
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

#### Очистка кеша CocoaPods

```bash
pod cache clean --all
pod repo update
```

## Исправление скриптов сборки (уже применено)

Если ошибка "Command PhaseScriptExecution failed" связана с переменной `FLUTTER_ROOT`, скрипты сборки были исправлены для автоматической загрузки переменных из `Generated.xcconfig`:

- Скрипт "Run Script" теперь загружает переменные перед выполнением
- Скрипт "Thin Binary" также обновлен для правильной работы

Если проблема сохраняется после очистки, проверьте, что файл `ios/Flutter/Generated.xcconfig` существует и содержит правильный путь к Flutter SDK.

## Частые причины ошибки

1. **Проблемы с путями к Flutter SDK**
   - Решение: Скрипты сборки обновлены для автоматической загрузки переменных из `Generated.xcconfig`
   - Если проблема сохраняется, проверьте переменную `FLUTTER_ROOT` в `ios/Flutter/Generated.xcconfig`

2. **Устаревшие или поврежденные Pods**
   - Решение: Удалите Pods и переустановите их

3. **Проблемы с правами доступа**
   - Решение: Убедитесь, что скрипты имеют права на выполнение

4. **Конфликты версий зависимостей**
   - Решение: Обновите Flutter и зависимости до совместимых версий

5. **Проблемы с DerivedData Xcode**
   - Решение: Очистите DerivedData

6. **Проблемы с подписью кода (Code Signing)**
   - Решение: Проверьте настройки подписи в Xcode (Signing & Capabilities)

## Дополнительные проверки

### Проверка скрипта сборки Flutter

Откройте Xcode → Runner target → Build Phases → "Thin Binary"

Убедитесь, что скрипт выглядит так:

```bash
/bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" embed_and_thin
```

### Проверка Info.plist

Убедитесь, что в `ios/Runner/Info.plist` правильно указаны:
- `CFBundleIdentifier`
- `CFBundleVersion`
- `CFBundleShortVersionString`

### Проверка GoogleService-Info.plist

Убедитесь, что файл `ios/Runner/GoogleService-Info.plist` существует и правильно настроен для Firebase.

## Если ничего не помогает

1. Создайте новый проект Flutter:
   ```bash
   flutter create test_app
   cd test_app
   flutter build ios
   ```

2. Если новый проект собирается, сравните конфигурации:
   - `ios/Podfile`
   - `ios/Runner.xcodeproj/project.pbxproj`
   - Настройки в Xcode

3. Попробуйте собрать проект на другом Mac или в CI/CD окружении для диагностики

## Контакты

Если проблема не решается, обратитесь к разработчику:
- Email: info@coderok.ru
- Сайт: https://coderok.ru

