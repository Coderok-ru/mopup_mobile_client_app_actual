#!/bin/bash

# Комплексный скрипт для исправления проблем с iOS сборкой

set -e

PROJECT_ROOT="/Users/coderok/AndroidStudioProjects/mopup"
IOS_DIR="$PROJECT_ROOT/ios"
DERIVED_DATA_DIR="$HOME/Library/Developer/Xcode/DerivedData"

echo "🧹 Очистка и исправление проблем с iOS сборкой..."
echo ""

cd "$PROJECT_ROOT"

# 1. Очистка Flutter кэша
echo "1️⃣ Очищаю Flutter кэш..."
flutter clean

# 2. Очистка iOS build директории
echo "2️⃣ Очищаю iOS build директорию..."
rm -rf "$IOS_DIR/build"
rm -rf "$IOS_DIR/.symlinks"
rm -rf "$IOS_DIR/Pods"

# 3. Очистка Xcode DerivedData
echo "3️⃣ Очищаю Xcode DerivedData..."
find "$DERIVED_DATA_DIR" -name "*Runner*" -type d -exec rm -rf {} + 2>/dev/null || true
rm -rf "$DERIVED_DATA_DIR"/*/Build/Intermediates.noindex 2>/dev/null || true

# 4. Получение Flutter зависимостей
echo "4️⃣ Получаю Flutter зависимости..."
flutter pub get

# 5. Переустановка Pods
echo "5️⃣ Переустанавливаю CocoaPods зависимости..."
cd "$IOS_DIR"
pod deintegrate 2>/dev/null || true
pod install

# 6. Проверка и исправление .xcconfig файлов
echo "6️⃣ Проверяю и исправляю .xcconfig файлы..."
cd "$PROJECT_ROOT"

python3 <<PYTHON_SCRIPT
import re
import os
import glob

ios_dir = "$IOS_DIR/Pods/Target Support Files"
fixed_count = 0

def fix_gcc_definitions(line):
    """Исправляет определения в GCC_PREPROCESSOR_DEFINITIONS"""
    original = line
    match = re.match(r'^(GCC_PREPROCESSOR_DEFINITIONS\s*=\s*)(.*)$', line)
    if not match:
        return line, False
    
    prefix = match.group(1)
    definitions = match.group(2)
    
    # Исправляем пробелы вокруг = в определениях
    # Паттерн: NAME = VALUE -> NAME=VALUE (но сохраняем пробелы между определениями)
    # Учитываем кавычки и дефисы в значениях
    fixed = re.sub(r'([A-Za-z0-9_]+)\s*=\s*([^\s]+|"[^"]*"|\'[^\']*\')', r'\1=\2', definitions)
    
    # Удаляем дублирующиеся $(inherited)
    fixed = re.sub(r'\$\(inherited\)\s*COCOAPODS=1\s*\$\(inherited\)', r'\$(inherited) COCOAPODS=1', fixed)
    while '$(inherited) $(inherited)' in fixed:
        fixed = re.sub(r'\$\(inherited\)\s+\$\(inherited\)', r'\$(inherited)', fixed)
    
    # Исправляем отсутствие пробела между определениями (=1[A-Z] -> =1 [A-Z])
    fixed = re.sub(r'=1([A-Z_])', r'=1 \1', fixed)
    
    # Исправляем GDTCOR_VERSION
    fixed = re.sub(r'GDTCOR_VERSION=1\s+0\.1\.0', r'GDTCOR_VERSION=10.1.0', fixed)
    
    result = prefix + fixed
    return result, result != original

xcconfig_files = glob.glob(os.path.join(ios_dir, "**", "*.xcconfig"), recursive=True)

for file_path in xcconfig_files:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        new_lines = []
        
        for line in lines:
            original_line = line
            # Удаляем пробелы в конце строки
            line = line.rstrip()
            
            # Обрабатываем GCC_PREPROCESSOR_DEFINITIONS
            if line.startswith('GCC_PREPROCESSOR_DEFINITIONS'):
                fixed_line, was_modified = fix_gcc_definitions(line)
                line = fixed_line
                if was_modified:
                    modified = True
            else:
                # Для остальных строк нормализуем формат (NAME = VALUE)
                if '=' in line and not line.strip().startswith('#'):
                    line = re.sub(r'^([A-Za-z0-9_]+)\s*=\s*(.*)$', r'\1 = \2', line)
            
            new_lines.append(line + '\n')
        
        if modified:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            print(f"✅ Исправлен: {os.path.relpath(file_path, '$PROJECT_ROOT')}")
            fixed_count += 1
    except Exception as e:
        print(f"⚠️  Ошибка при обработке {file_path}: {e}")

print(f"\n✅ Исправлено файлов: {fixed_count}")
PYTHON_SCRIPT

echo ""
echo "✅ Очистка и исправление завершены!"
echo ""
echo "📝 Следующие шаги:"
echo "   1. Откройте проект в Xcode"
echo "   2. Выберите Product > Clean Build Folder (Shift+Cmd+K)"
echo "   3. Попробуйте собрать проект снова"
