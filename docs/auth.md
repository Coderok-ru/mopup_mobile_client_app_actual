# API документация для Пользовательской авторизации

## Описание
API-маршруты для регистрации, авторизации и управления профилем пользователей приложения.

## Базовый URL
```
https://admin.mopup.ru
```

---

## Требования
- Laravel Sanctum: авторизация защищённых маршрутов выполняется через Bearer-токен.
- Роль `user` должна существовать и назначаться автоматически при регистрации.
- Все ответы возвращаются в формате JSON.
- Все маршруты клиентского приложения находятся под префиксом `/api/client`.
- Перед регистрацией необходимо получить список доступных городов и передать идентификатор выбранного города.

---

## Маршруты без авторизации

### Получение списка городов
**Endpoint:** `GET /api/cities`

**Описание:** Возвращает перечень городов, доступных для выбора пользователем.

**Успешный ответ (200):**
```json
[
  {
    "id": 1,
    "name": "Москва"
  },
  {
    "id": 2,
    "name": "Санкт-Петербург"
  }
]
```

**Дополнительно:** при необходимости можно получить конкретный город по `GET /api/cities/{id}`.

---

### Регистрация пользователя
**Endpoint:** `POST /api/client/register`

**Тело запроса (JSON или form-data):**
| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| `name` | string | Да | Имя пользователя |
| `lname` | string | Да | Фамилия пользователя |
| `phone` | string | Да | Уникальный телефон в международном формате |
| `email` | string | Да | Уникальная почта |
| `password` | string | Да | Пароль минимум 6 символов |
| `passwordV` | string | Да | Подтверждение пароля, должно совпадать с `password` |
| `city` | integer | Да | ID города из `/api/cities` |
| `profile_photo_path` | file | Нет | Изображение аватара (jpeg/png/jpg/gif/svg, до 2 МБ) |

**Пример запроса:**
```bash
curl -X POST https://example.com/api/client/register \
     -F "name=Иван" \
     -F "lname=Иванов" \
     -F "phone=+79990001122" \
     -F "email=ivan@example.com" \
     -F "password=secret123" \
     -F "passwordV=secret123" \
     -F "city=1" \
     -F "profile_photo_path=@/path/to/avatar.jpg"
```

**Успешный ответ (201):**
```json
{
  "user": {
    "id": 123,
    "name": "Иван",
    "lname": "Иванов",
    "phone": "+79990001122",
    "email": "ivan@example.com",
    "roles": [
      {
        "name": "user"
      }
    ],
    "credit_cards": [],
    "profile_photo_url": "https://example.com/storage/images/avatars/1700000000_123.jpg"
  },
  "token": "1|4Kqz..."
}
```

**Ошибки (422):**
```json
{
  "errors": {
    "email": [
      "The email has already been taken."
    ]
  }
}
```

---

### Авторизация пользователя
**Endpoint:** `POST /api/client/login`

**Тело запроса:**
| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| `phone` | string | Да | Телефон с поддержкой форматов `+7...`, `7...`, а также с пробелом в начале (будет нормализован) |
| `password` | string | Да | Пароль |
| `device_token` | string | Нет | Токен устройства для push-уведомлений |

**Пример:**
```bash
curl -X POST https://example.com/api/client/login \
     -H "Content-Type: application/json" \
     -d '{
       "phone": "+79990001122",
       "password": "secret123",
       "device_token": "device-token-uuid"
     }'
```

**Успешный ответ (200):**
```json
{
  "user": {
    "id": 123,
    "name": "Иван",
    "lname": "Иванов",
    "roles": [
      {
        "name": "user"
      }
    ],
    "credit_cards": []
  },
  "token": "2|N9yl..."
}
```

**Ошибки:**
- `401` — неверные учётные данные
- `403` — аккаунт заблокирован или роль отличается от `user`
- `422` — ошибки валидации

---

## Маршруты под авторизацией

Все запросы ниже требуют заголовок:
```
Authorization: Bearer {token}
```

### Выход из системы
**Endpoint:** `POST /api/client/logout`

**Ответ (200):**
```json
{
  "message": "Выход успешен"
}
```

---

### Получение профиля
**Endpoint:** `GET /api/client/profile`

**Ответ (200):**
```json
{
  "user": {
    "id": 123,
    "name": "Иван",
    "lname": "Иванов",
    "phone": "+79990001122",
    "email": "ivan@example.com",
    "roles": [
      {
        "name": "user"
      }
    ],
    "credit_cards": [],
    "profile_photo_url": "https://example.com/storage/images/avatars/1700000000_123.jpg"
  }
}
```

---

### Обновление профиля
**Endpoint:** `PUT /api/client/update`

**Тело запроса (любая комбинация полей):**
| Поле | Тип | Описание |
|------|-----|----------|
| `name` | string | Новое имя |
| `lname` | string | Новая фамилия |
| `email` | string | Уникальная почта |
| `phone` | string | Уникальный телефон |
| `city` | integer | ID города из `/api/cities` |
| `profile_photo_path` | file | Новый аватар (форматы и ограничения как при регистрации) |

**Пример (form-data):**
```bash
curl -X PUT https://example.com/api/client/update \
     -H "Authorization: Bearer 2|N9yl..." \
     -F "name=Иван" \
     -F "profile_photo_path=@/path/to/new-avatar.png"
```

**Успешный ответ (200):**
```json
{
  "message": "Информация успешно обновлена!",
  "user": {
    "id": 123,
    "name": "Иван",
    "profile_photo_url": "https://example.com/storage/images/avatars/1700000500_123.png"
  }
}
```

**Ошибки (422 / 404):** при нарушении уникальности или если пользователь не найден.

---

### Обновление push-токена устройства
**Endpoint:** `PUT /api/client/update-device-token`

**Тело запроса:**
| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| `device_token` | string | Да | Токен устройства (OneSignal/FCM и т.п.) |

**Ответ (200):**
```json
{
  "message": "Device token обновлен!",
  "user": {
    "id": 123,
    "device_token": "device-token-uuid"
  }
}
```

---

### Удаление аккаунта
**Endpoint:** `DELETE /api/client/delete-account`

**Ответ (200):**
```json
{
  "message": "Аккаунт успешно удален"
}
```

**Примечания:**
- Аватар удаляется из `public/images/avatars`.
- Все токены Sanctum ревокируются.

---

## Управление избранными клинерами

Все маршруты требуют `Authorization: Bearer {token}` и доступно только для роли `user`.

### Список избранных клинеров
**Endpoint:** `GET /api/client/favorites/cleaners`

**Ответ (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 77,
      "name": "Анна",
      "lname": "Смирнова",
      "rating": 4.9,
      "profile_photo_url": "https://example.com/storage/images/avatars/1700000200_77.jpg",
      "skills": [
        { "id": 3, "name": "Окна" }
      ],
      "pivot": {
        "created_at": "2025-11-11T08:15:00Z",
        "updated_at": "2025-11-11T08:15:00Z"
      }
    }
  ]
}
```

### Добавление клинера в избранное
**Endpoint:** `POST /api/client/favorites/cleaners`

**Тело запроса:**
| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| `cleaner_id` | integer | Да | ID пользователя с ролью `cleaner` |

**Ответ (201):**
```json
{
  "success": true,
  "message": "Клинер добавлен в избранное"
}
```

### Удаление клинера из избранного
**Endpoint:** `DELETE /api/client/favorites/cleaners/{cleaner_id}`

**Ответ (200):**
```json
{
  "success": true,
  "message": "Клинер удалён из избранного"
}
```

---

## Банковские карты клиента

Сохраняются только маскированные данные и токены карты. Для операций с картами пользователь должен быть авторизован.

### Список карт
**Endpoint:** `GET /api/client/payment-cards`

**Ответ (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 12,
      "masked_pan": "4300 **** **** 1234",
      "last_four": "1234",
      "brand": "VISA",
      "holder_name": "IVAN IVANOV",
      "exp_month": 12,
      "exp_year": 2027,
      "is_default": true,
      "created_at": "2025-11-11T08:20:00Z",
      "updated_at": "2025-11-11T08:20:00Z"
    }
  ]
}
```

### Сохранение новой карты
**Endpoint:** `POST /api/client/payment-cards`

**Тело запроса:**
| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| `card_id` | string | Нет | Идентификатор карты платёжного провайдера |
| `card_token` | string | Нет | Токен карты (обязателен, если нет `card_id`) |
| `masked_pan` | string | Да | Маскированный PAN (например, `4300 **** **** 1234`) |
| `last_four` | string | Нет | Последние 4 цифры (если не переданы — возьмутся из `masked_pan`) |
| `brand` | string | Нет | Тип карты (`VISA`, `Mastercard` и т.п.) |
| `holder_name` | string | Нет | Имя владельца |
| `exp_month` | integer | Нет | Месяц истечения (1-12) |
| `exp_year` | integer | Нет | Год истечения |
| `is_default` | boolean | Нет | Признак карты по умолчанию |

**Ответ (201):**
```json
{
  "success": true,
  "message": "Карта успешно сохранена",
  "data": {
    "id": 12,
    "masked_pan": "4300 **** **** 1234",
    "brand": "VISA",
    "is_default": true
  }
}
```

### Назначение карты по умолчанию
**Endpoint:** `PATCH /api/client/payment-cards/{card_id}/default`

**Ответ (200):**
```json
{
  "success": true,
  "message": "Карта установлена по умолчанию"
}
```

### Удаление карты
**Endpoint:** `DELETE /api/client/payment-cards/{card_id}`

**Ответ (200):**
```json
{
  "success": true,
  "message": "Карта удалена"
}
```

---

## Заказы клиента

Заказы подтягиваются по `user_id` или, если не заполнен, по совпадению номера телефона.

### Список заказов
**Endpoint:** `GET /api/client/orders`

**Query-параметры:**
| Параметр | Тип | Описание |
|----------|-----|----------|
| `per_page` | integer | Размер страницы (по умолчанию 15) |

**Ответ (200):**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 501,
      "order_type": "multy",
      "status_id": 2,
      "total_price": 4200,
      "date_time": "2025-11-15 10:00:00",
      "city": {
        "id": 3,
        "name": "Москва"
      },
      "status": {
        "id": 2,
        "name": "Принят"
      }
    }
  ],
  "per_page": 15,
  "total": 1
}
```

### Детали заказа
**Endpoint:** `GET /api/client/orders/{order_id}`

**Ответ (200):**
```json
{
  "data": {
    "id": 501,
    "order_type": "multy",
    "total_price": 4200,
    "date_time": "2025-11-15 10:00:00",
    "city": { "id": 3, "name": "Москва" },
    "status": { "id": 2, "name": "Принят" },
    "order_base_services": [
      {
        "id": 101,
        "name": "Основная площадь",
        "pivot": {
          "quantity": 45,
          "price": 3200
        }
      }
    ],
    "order_additional_services": [
      {
        "id": 201,
        "name": "Мытьё окон",
        "pivot": {
          "value": 1,
          "price": 700
        }
      }
    ],
    "order_dates": [
      {
        "id": 9001,
        "scheduled_date": "22.11.2025",
        "scheduled_time": "10:00:00",
        "status": "pending"
      }
    ]
  }
}
```

**Ошибки:**
- `404` — если заказ не принадлежит пользователю или не найден.

---

## Дополнительные замечания
- Нормализация телефона происходит автоматически: номера вида `7XXXXXXXXXX` или начинающиеся с пробела будут преобразованы в формат `+7...`.
- Для загрузки файлов используйте `multipart/form-data`; при JSON-запросах аватар передать нельзя.
- При каждом входе старые токены Sanctum удаляются, поэтому поддерживается только один активный токен на пользователя.
- Для работы защищённых маршрутов добавьте middleware `auth:sanctum` в HTTP-запрос.

