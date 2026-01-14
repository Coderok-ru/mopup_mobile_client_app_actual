#!/bin/bash

# Скрипт для исправления всех проблем с GCC_PREPROCESSOR_DEFINITIONS в .xcconfig файлах

echo "🔧 Исправляю проблемы с GCC_PREPROCESSOR_DEFINITIONS..."

IOS_DIR="ios/Pods/Target Support Files"

if [ ! -d "$IOS_DIR" ]; then
  echo "❌ Директория $IOS_DIR не найдена!"
  exit 1
fi

# Находим все .xcconfig файлы
find "$IOS_DIR" -name "*.xcconfig" -type f | while read -r file; do
  echo "Обрабатываю: $file"
  
  # Исправление 1: Удаляем дублирующиеся $(inherited) в GCC_PREPROCESSOR_DEFINITIONS
  # Заменяем "$(inherited) COCOAPODS=1 $(inherited)" на "$(inherited) COCOAPODS=1"
  sed -i '' 's/\$(inherited)[[:space:]]*COCOAPODS=1[[:space:]]*\$(inherited)/$(inherited) COCOAPODS=1/g' "$file"
  
  # Исправление 2: Удаляем любые дублирующиеся $(inherited) подряд
  sed -i '' 's/\$(inherited)[[:space:]]\+\$(inherited)/$(inherited)/g' "$file"
  
  # Исправление 3: Исправляем отсутствие пробела между определениями типа =1GDTCOR (но не версиями типа =10.1.0)
  # Исправляем только когда после =1 идет заглавная буква (начало нового определения), но не цифра (версия)
  sed -i '' 's/=1\([A-Z_]\)/=1 \1/g' "$file"
  
  # Исправление 4: Исправляем конкретный случай с GDTCOR_VERSION=1 0.1.0 -> =10.1.0
  sed -i '' 's/GDTCOR_VERSION=1 0\.1\.0/GDTCOR_VERSION=10.1.0/g' "$file"
done

echo "✅ Исправление завершено!"

