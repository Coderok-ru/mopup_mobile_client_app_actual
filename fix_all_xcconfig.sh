#!/bin/bash

# Комплексный скрипт для исправления всех проблем с .xcconfig файлами
# Исправляет проблемы с GCC_PREPROCESSOR_DEFINITIONS и другими настройками

echo "🔧 Комплексное исправление проблем с .xcconfig файлами..."

IOS_DIR="ios/Pods/Target Support Files"

if [ ! -d "$IOS_DIR" ]; then
  echo "❌ Директория $IOS_DIR не найдена!"
  exit 1
fi

FIXED_COUNT=0

# Находим все .xcconfig файлы
find "$IOS_DIR" -name "*.xcconfig" -type f | while read -r file; do
  HAS_CHANGES=false
  ORIGINAL_CONTENT=$(cat "$file")
  
  # Временный файл для сохранения изменений
  TMP_FILE=$(mktemp)
  cp "$file" "$TMP_FILE"
  
  # Исправление 1: Удаляем пробелы в конце строк
  sed -i '' 's/[[:space:]]*$//' "$TMP_FILE"
  
  # Исправление 2: Убираем только лишние пробелы, но оставляем один пробел вокруг =
  # Заменяем множественные пробелы вокруг = на один пробел
  sed -i '' 's/[[:space:]]*=[[:space:]]*/ = /' "$TMP_FILE"
  
  # Исправление 3: Исправляем дублирующиеся $(inherited)
  # Удаляем "$(inherited) COCOAPODS=1 $(inherited)" -> "$(inherited) COCOAPODS=1"
  sed -i '' 's/\$(inherited)[[:space:]]*COCOAPODS=1[[:space:]]*\$(inherited)/$(inherited) COCOAPODS=1/g' "$TMP_FILE"
  
  # Удаляем любые другие дублирующиеся $(inherited) подряд
  while grep -q '\$(inherited)[[:space:]]\+\$(inherited)' "$TMP_FILE"; do
    sed -i '' 's/\$(inherited)[[:space:]]\+\$(inherited)/$(inherited)/g' "$TMP_FILE"
  done
  
  # Исправление 4: Исправляем отсутствие пробела между определениями
  # Исправляем =1[A-Z] -> =1 [A-Z] (но не версии типа =10.1.0)
  sed -i '' 's/=1\([A-Z_]\)/=1 \1/g' "$TMP_FILE"
  
  # Исправление 5: Исправляем конкретный случай с GDTCOR_VERSION
  sed -i '' 's/GDTCOR_VERSION=1[[:space:]]\+0\.1\.0/GDTCOR_VERSION=10.1.0/g' "$TMP_FILE"
  sed -i '' 's/GDTCOR_VERSION=1[[:space:]]\+0\.1\.0/GDTCOR_VERSION=10.1.0/g' "$TMP_FILE"
  
  # Исправление 6: Проверяем и исправляем проблемы с кавычками в GCC_PREPROCESSOR_DEFINITIONS
  # Xcode требует, чтобы кавычки в значениях были правильно экранированы
  # Но в .xcconfig файлах кавычки обычно должны быть экранированы как \"
  # Проверяем строки с LIBRARY_VERSION или LIBRARY_NAME
  if grep -q "LIBRARY_VERSION\|LIBRARY_NAME" "$TMP_FILE"; then
    # Убеждаемся, что кавычки экранированы правильно
    # Заменяем " на \" только в значениях после =
    sed -i '' 's/\(LIBRARY_VERSION\|LIBRARY_NAME\)=\([^ ]*\)"\([^ ]*\)"/\1=\2\\"\3\\"/g' "$TMP_FILE" || true
  fi
  
  # Исправление 7: Убеждаемся, что после = есть значение (не пустое)
  # Это более сложная проверка, делаем её осторожно
  
  # Проверяем, были ли изменения
  NEW_CONTENT=$(cat "$TMP_FILE")
  if [ "$ORIGINAL_CONTENT" != "$NEW_CONTENT" ]; then
    HAS_CHANGES=true
    mv "$TMP_FILE" "$file"
    FIXED_COUNT=$((FIXED_COUNT + 1))
    echo "✅ Исправлен: $file"
  else
    rm "$TMP_FILE"
  fi
done

echo ""
echo "✅ Обработка завершена! Исправлено файлов: $FIXED_COUNT"

# Дополнительная проверка на наличие проблемных паттернов
echo ""
echo "🔍 Проверяю наличие оставшихся проблем..."

PROBLEMS_FOUND=0

# Проверяем дублирующиеся $(inherited)
DUPLICATES=$(find "$IOS_DIR" -name "*.xcconfig" -exec grep -l "GCC_PREPROCESSOR_DEFINITIONS.*\$(inherited).*\$(inherited)" {} \; 2>/dev/null || true)
if [ -n "$DUPLICATES" ]; then
  echo "⚠️  Найдены дублирующиеся \$(inherited):"
  echo "$DUPLICATES"
  PROBLEMS_FOUND=$((PROBLEMS_FOUND + 1))
fi

# Проверяем проблемы с GDTCOR_VERSION
GDTCOR_PROBLEMS=$(find "$IOS_DIR" -name "*.xcconfig" -exec grep -l "GDTCOR_VERSION=1[[:space:]]\+0" {} \; 2>/dev/null || true)
if [ -n "$GDTCOR_PROBLEMS" ]; then
  echo "⚠️  Найдены проблемы с GDTCOR_VERSION:"
  echo "$GDTCOR_PROBLEMS"
  PROBLEMS_FOUND=$((PROBLEMS_FOUND + 1))
fi

# Проверяем строки без пробелов вокруг =
SPACE_PROBLEMS=$(find "$IOS_DIR" -name "*.xcconfig" -exec grep -E "GCC_PREPROCESSOR_DEFINITIONS.*=[^[:space:]]" {} \; 2>/dev/null | grep -v "COCOAPODS=1\|PB_FIELD_32BIT=1\|PB_NO_PACKED_STRUCTS=1\|PB_ENABLE_MALLOC=1\|GDTCOR_VERSION=" || true)
if [ -n "$SPACE_PROBLEMS" ]; then
  echo "⚠️  Найдены потенциальные проблемы с пробелами:"
  echo "$SPACE_PROBLEMS" | head -5
  PROBLEMS_FOUND=$((PROBLEMS_FOUND + 1))
fi

if [ $PROBLEMS_FOUND -eq 0 ]; then
  echo "✅ Серьезных проблем не обнаружено!"
else
  echo "⚠️  Обнаружено проблем: $PROBLEMS_FOUND"
fi

