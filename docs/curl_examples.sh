#!/bin/bash

# Примеры отправки push-уведомлений через cURL
# 
# ИНСТРУКЦИЯ:
# 1. Замените YOUR_SERVER_KEY на Server Key из Firebase Console
#    (Project Settings > Cloud Messaging > Server key)
# 2. Замените FCM_TOKEN_УСТРОЙСТВА на FCM токен устройства
#    (выводится в консоль при запуске приложения)
# 3. Запустите скрипт: bash curl_examples.sh

# Настройки (замените на свои значения)
SERVER_KEY="YOUR_SERVER_KEY"
FCM_TOKEN="FCM_TOKEN_УСТРОЙСТВА"

# Пример 1: Уведомление о создании заказа с переходом на детали
echo "Пример 1: Уведомление о создании заказа"
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"$FCM_TOKEN\",
    \"notification\": {
      \"title\": \"Заказ создан\",
      \"body\": \"Ваш заказ #123 успешно создан\"
    },
    \"data\": {
      \"type\": \"order_created\",
      \"order_id\": \"123\"
    }
  }"

echo -e "\n\n"

# Пример 2: Уведомление об изменении статуса заказа
echo "Пример 2: Уведомление об изменении статуса заказа"
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"$FCM_TOKEN\",
    \"notification\": {
      \"title\": \"Статус заказа изменен\",
      \"body\": \"Ваш заказ #123 выполнен\"
    },
    \"data\": {
      \"type\": \"order_status\",
      \"order_id\": \"123\"
    }
  }"

echo -e "\n\n"

# Пример 3: Уведомление с переходом на экран оплаты
echo "Пример 3: Уведомление с переходом на экран оплаты"
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"$FCM_TOKEN\",
    \"notification\": {
      \"title\": \"Требуется оплата\",
      \"body\": \"Оплатите заказ #123\"
    },
    \"data\": {
      \"type\": \"payment\"
    }
  }"

echo -e "\n\n"

# Пример 4: Уведомление с переходом на список заказов
echo "Пример 4: Уведомление с переходом на список заказов"
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"$FCM_TOKEN\",
    \"notification\": {
      \"title\": \"Новые заказы\",
      \"body\": \"У вас есть новые заказы\"
    },
    \"data\": {
      \"screen\": \"/orders\"
    }
  }"

echo -e "\n\n"

# Пример 5: Уведомление с прямым указанием экрана деталей заказа
echo "Пример 5: Уведомление с прямым указанием экрана деталей заказа"
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"$FCM_TOKEN\",
    \"notification\": {
      \"title\": \"Детали заказа\",
      \"body\": \"Просмотрите детали заказа #123\"
    },
    \"data\": {
      \"screen\": \"/order-details\",
      \"order_id\": \"123\"
    }
  }"

echo -e "\n\n"

# Пример 6: Уведомление с переходом на настройки
echo "Пример 6: Уведомление с переходом на настройки"
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"$FCM_TOKEN\",
    \"notification\": {
      \"title\": \"Настройки\",
      \"body\": \"Обновите настройки приложения\"
    },
    \"data\": {
      \"type\": \"settings\"
    }
  }"

echo -e "\n\n"

# Пример 7: Только data payload (без notification) - для фоновых уведомлений
echo "Пример 7: Только data payload (фоновое уведомление)"
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"$FCM_TOKEN\",
    \"data\": {
      \"type\": \"order_status\",
      \"order_id\": \"123\",
      \"title\": \"Статус заказа изменен\",
      \"body\": \"Ваш заказ #123 выполнен\"
    }
  }"

echo -e "\n\n"

# Пример 8: Уведомление с изображением
echo "Пример 8: Уведомление с изображением"
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"$FCM_TOKEN\",
    \"notification\": {
      \"title\": \"Заказ готов\",
      \"body\": \"Ваш заказ #123 готов к выдаче\"
    },
    \"data\": {
      \"type\": \"order_status\",
      \"order_id\": \"123\",
      \"image_url\": \"https://example.com/order-image.jpg\"
    }
  }"

echo -e "\n\n"

echo "Готово! Проверьте устройство на наличие уведомлений."

