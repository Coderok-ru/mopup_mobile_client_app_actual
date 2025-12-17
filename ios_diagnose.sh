#!/bin/bash

# Скрипт диагностики ошибки PhaseScriptExecution для iOS проекта Flutter

echo "🔍 Диагностика ошибки PhaseScriptExecution..."
echo ""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IOS_DIR="$PROJECT_ROOT/ios"

cd "$PROJECT_ROOT"

# 1. Проверка Flutter
echo "1️⃣ Проверка Flutter SDK..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -1)
    echo "   ✅ Flutter найден: $FLUTTER_VERSION"
    
    # Проверка FLUTTER_ROOT
    if [ -n "$FLUTTER_ROOT" ]; then
        echo "   ✅ FLUTTER_ROOT установлен: $FLUTTER_ROOT"
    else
        echo "   ⚠️  FLUTTER_ROOT не установлен в окружении"
    fi
    
    # Проверка скрипта xcode_backend.sh
    if [ -f "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" ]; then
        echo "   ✅ xcode_backend.sh найден"
    else
        FLUTTER_ROOT_FROM_CONFIG=$(grep "FLUTTER_ROOT" "$IOS_DIR/Flutter/Generated.xcconfig" 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
        if [ -n "$FLUTTER_ROOT_FROM_CONFIG" ] && [ -f "$FLUTTER_ROOT_FROM_CONFIG/packages/flutter_tools/bin/xcode_backend.sh" ]; then
            echo "   ✅ xcode_backend.sh найден через Generated.xcconfig: $FLUTTER_ROOT_FROM_CONFIG"
        else
            echo "   ❌ xcode_backend.sh НЕ найден!"
        fi
    fi
else
    echo "   ❌ Flutter не найден в PATH"
fi

echo ""

# 2. Проверка Generated.xcconfig
echo "2️⃣ Проверка Generated.xcconfig..."
if [ -f "$IOS_DIR/Flutter/Generated.xcconfig" ]; then
    echo "   ✅ Файл существует"
    echo "   Содержимое:"
    cat "$IOS_DIR/Flutter/Generated.xcconfig" | sed 's/^/      /'
    
    FLUTTER_ROOT_FROM_CONFIG=$(grep "FLUTTER_ROOT" "$IOS_DIR/Flutter/Generated.xcconfig" | cut -d'=' -f2 | tr -d ' ')
    if [ -n "$FLUTTER_ROOT_FROM_CONFIG" ]; then
        if [ -d "$FLUTTER_ROOT_FROM_CONFIG" ]; then
            echo "   ✅ FLUTTER_ROOT указывает на существующую директорию"
        else
            echo "   ❌ FLUTTER_ROOT указывает на несуществующую директорию: $FLUTTER_ROOT_FROM_CONFIG"
        fi
    fi
else
    echo "   ❌ Файл НЕ существует!"
    echo "   💡 Выполните: flutter clean && flutter pub get"
fi

echo ""

# 3. Проверка CocoaPods
echo "3️⃣ Проверка CocoaPods..."
if command -v pod &> /dev/null; then
    POD_VERSION=$(pod --version)
    echo "   ✅ CocoaPods найден: версия $POD_VERSION"
    
    cd "$IOS_DIR"
    if [ -f "Podfile.lock" ] && [ -f "Pods/Manifest.lock" ]; then
        if diff -q "Podfile.lock" "Pods/Manifest.lock" > /dev/null 2>&1; then
            echo "   ✅ Podfile.lock и Manifest.lock синхронизированы"
        else
            echo "   ❌ Podfile.lock и Manifest.lock НЕ синхронизированы!"
            echo "   💡 Выполните: cd ios && pod install"
        fi
    else
        echo "   ⚠️  Podfile.lock или Manifest.lock отсутствуют"
        echo "   💡 Выполните: cd ios && pod install"
    fi
    
    if [ -d "Pods" ]; then
        PODS_COUNT=$(find Pods -maxdepth 1 -type d | wc -l | tr -d ' ')
        echo "   ✅ Директория Pods существует ($PODS_COUNT поддиректорий)"
    else
        echo "   ❌ Директория Pods НЕ существует!"
        echo "   💡 Выполните: cd ios && pod install"
    fi
    cd "$PROJECT_ROOT"
else
    echo "   ❌ CocoaPods не найден"
    echo "   💡 Установите: sudo gem install cocoapods"
fi

echo ""

# 4. Проверка прав доступа
echo "4️⃣ Проверка прав доступа к скриптам..."
if [ -f "$IOS_DIR/Flutter/ephemeral/flutter_export_environment.sh" ]; then
    if [ -x "$IOS_DIR/Flutter/ephemeral/flutter_export_environment.sh" ]; then
        echo "   ✅ flutter_export_environment.sh исполняемый"
    else
        echo "   ⚠️  flutter_export_environment.sh не исполняемый"
        echo "   💡 Выполните: chmod +x $IOS_DIR/Flutter/ephemeral/flutter_export_environment.sh"
    fi
else
    echo "   ⚠️  flutter_export_environment.sh не найден"
fi

FLUTTER_ROOT_FROM_CONFIG=$(grep "FLUTTER_ROOT" "$IOS_DIR/Flutter/Generated.xcconfig" 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
if [ -n "$FLUTTER_ROOT_FROM_CONFIG" ] && [ -f "$FLUTTER_ROOT_FROM_CONFIG/packages/flutter_tools/bin/xcode_backend.sh" ]; then
    if [ -x "$FLUTTER_ROOT_FROM_CONFIG/packages/flutter_tools/bin/xcode_backend.sh" ]; then
        echo "   ✅ xcode_backend.sh исполняемый"
    else
        echo "   ⚠️  xcode_backend.sh не исполняемый"
        echo "   💡 Выполните: chmod +x $FLUTTER_ROOT_FROM_CONFIG/packages/flutter_tools/bin/xcode_backend.sh"
    fi
fi

echo ""

# 5. Проверка DerivedData
echo "5️⃣ Проверка DerivedData Xcode..."
DERIVED_DATA_SIZE=$(du -sh ~/Library/Developer/Xcode/DerivedData 2>/dev/null | cut -f1)
if [ -n "$DERIVED_DATA_SIZE" ]; then
    echo "   ℹ️  Размер DerivedData: $DERIVED_DATA_SIZE"
    echo "   💡 Для очистки выполните: rm -rf ~/Library/Developer/Xcode/DerivedData/*"
else
    echo "   ✅ DerivedData пуст или не существует"
fi

echo ""

# 6. Тест выполнения скриптов
echo "6️⃣ Тест выполнения скриптов Flutter..."
cd "$IOS_DIR"

if [ -f "Flutter/Generated.xcconfig" ]; then
    # Извлекаем FLUTTER_ROOT из .xcconfig файла (без использования source, т.к. файл содержит комментарии //)
    FLUTTER_ROOT_TEST=$(grep '^FLUTTER_ROOT=' "Flutter/Generated.xcconfig" | cut -d'=' -f2 | tr -d ' ')
    
    if [ -n "$FLUTTER_ROOT_TEST" ] && [ -f "$FLUTTER_ROOT_TEST/packages/flutter_tools/bin/xcode_backend.sh" ]; then
        echo "   ✅ FLUTTER_ROOT извлечен: $FLUTTER_ROOT_TEST"
        echo "   Тестирую скрипт build (только проверка существования)..."
        if [ -x "$FLUTTER_ROOT_TEST/packages/flutter_tools/bin/xcode_backend.sh" ]; then
            echo "   ✅ Скрипт xcode_backend.sh существует и исполняемый"
            echo "   ℹ️  Для полного теста выполните сборку в Xcode"
        else
            echo "   ⚠️  Скрипт существует, но не исполняемый"
            echo "   💡 Выполните: chmod +x $FLUTTER_ROOT_TEST/packages/flutter_tools/bin/xcode_backend.sh"
        fi
    else
        echo "   ⚠️  Не могу протестировать: FLUTTER_ROOT не найден или скрипт отсутствует"
        if [ -z "$FLUTTER_ROOT_TEST" ]; then
            echo "   ❌ FLUTTER_ROOT пустой в Generated.xcconfig"
        elif [ ! -f "$FLUTTER_ROOT_TEST/packages/flutter_tools/bin/xcode_backend.sh" ]; then
            echo "   ❌ Скрипт не найден по пути: $FLUTTER_ROOT_TEST/packages/flutter_tools/bin/xcode_backend.sh"
        fi
    fi
else
    echo "   ⚠️  Не могу протестировать: Generated.xcconfig не найден"
fi

cd "$PROJECT_ROOT"

echo ""
echo "✅ Диагностика завершена!"
echo ""
echo "📋 Рекомендации:"
echo "   1. Если есть ошибки выше, исправьте их"
echo "   2. Выполните: bash ios_fix_build.sh"
echo "   3. Откройте проект в Xcode: open ios/Runner.xcworkspace"
echo "   4. Product → Clean Build Folder (Shift+Cmd+K)"
echo "   5. Product → Build (Cmd+B)"

