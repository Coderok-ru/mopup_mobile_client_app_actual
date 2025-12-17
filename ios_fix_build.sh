#!/bin/bash

# Скрипт для исправления ошибки сборки iOS проекта Flutter
# Ошибка: Command PhaseScriptExecution failed with a nonzero exit code

echo "🔧 Начинаю исправление ошибки сборки iOS..."

# Определяем корневую директорию проекта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
IOS_DIR="$PROJECT_ROOT/ios"

cd "$PROJECT_ROOT"

# 1. Очистка кеша Flutter
echo "📦 Очищаю кеш Flutter..."
flutter clean

# 2. Удаление старых Pods
echo "🗑️  Удаляю старые Pods..."
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

# 3. Получение зависимостей Flutter
echo "📥 Получаю зависимости Flutter..."
flutter pub get

# 4. Обновление CocoaPods
echo "☕ Обновляю CocoaPods..."
cd "$IOS_DIR"
pod repo update

# 5. Установка Pods
echo "📦 Устанавливаю Pods..."
pod install --repo-update
cd "$PROJECT_ROOT"

# 6. Проверка прав доступа к скриптам
echo "🔐 Проверяю права доступа..."
chmod +x "${PWD}/Flutter/ephemeral/flutter_export_environment.sh" 2>/dev/null || true

# 7. Очистка DerivedData Xcode
echo "🧹 Очищаю DerivedData Xcode..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo ""
echo "✅ Готово! Теперь попробуйте собрать проект снова:"
echo "   flutter build ios"
echo "   или откройте Runner.xcworkspace в Xcode и соберите там"

