# API: Создание заказа клиентским приложением

Документ описывает последовательность действий мобильного приложения клиента для формирования заказа через REST API. В основе лежит актуальная логика контроллера `app/Http/Controllers/Api/Client/ClientOrderController.php`.

## 1. Исходные данные
- ID города клиента (`city_id`) уже известен.
- **Клиент авторизован в приложении** (обязательно): требуется токен Sanctum и роль `user`.
- Все запросы к API клиентского приложения должны содержать заголовок: `Authorization: Bearer {token}`

## 2. Получение шаблонов для города

### 2.1. Список шаблонов
- **Маршрут:** `GET /api/order-templates`
- **Query-параметры:** `city_id={CITY_ID}`
- **Назначение:** получить краткий список доступных шаблонов заказа по городу.

```http
GET /api/order-templates?city_id=3
```

### 2.2. Подробности выбранного шаблона
- **Маршрут:** `GET /api/client/{template_id}` (публичный, не требует авторизации)
- **Query-параметры:** `city_id={CITY_ID}`
- **Ответ:** полная структура шаблона с услугами и всеми связанными данными (включая pivot-таблицы):
  - `template` — объект с **всеми** полями `order_templates` (`id`, `name`, `name_crm`, `html_content`, `subtitle`, `button_text`, `image_url`, `thumbnail_url`, `mop`, `cleaner_skills`, `base_time`, `position`, `created_at`, `updated_at`, и т. д.). Внутри — массив `cities`, где первый элемент содержит `pivot.price` для выбранного города.
  - `base_services` — массив объектов `BaseService`. Каждый элемент содержит собственные поля (`id`, `name`, `name_crm`, `type`, `base_time`, `value`, `discounts`, временные метки и т. п.), массив `cities` с ценой для города и объект `pivot` (`order_template_id`, `base_service_id`, `city_id`, `price`, `position`, timestamps) плюс вложенный `pivot.city`, где продублированы данные города.
  - `additional_services` — массив объектов `AdditionalService`. Аналогичная структура: поля услуги (`id`, `name`, `name_crm`, `type`, `time`, timestamps), массив `cities` и объект `pivot` (`order_template_id`, `additional_service_id`, `city_id`, `price`, `position`, timestamps) с вложенным `pivot.city`.

Пример усечённого ответа:

```json
{
  "success": true,
  "data": {
    "template": {
      "id": 12,
      "name": "Генеральная уборка",
      "name_crm": "gen-cleaning",
      "html_content": "<p>Описание</p>",
      "mop": true,
      "cleaner_skills": ["glass", "floor"],
      "base_time": 180,
      "position": 3,
      "cities": [
        {
          "id": 3,
          "name": "Москва",
          "short_name": "msk",
          "latitude": 55.7558,
          "longitude": 37.6173,
          "pivot": {
            "order_template_id": 12,
            "city_id": 3,
            "price": 3200
          }
        }
      ]
    },
    "base_services": [
      {
        "id": 101,
        "name": "Основная площадь",
        "name_crm": "base_area",
        "type": "number",
        "base_time": 120,
        "value": 0,
        "discounts": [],
        "cities": [
          {
            "id": 3,
            "name": "Москва",
            "pivot": {
              "price": 3200
            }
          }
        ],
        "pivot": {
          "order_template_id": 12,
          "base_service_id": 101,
          "city_id": 3,
          "price": 3200,
          "position": 1,
          "created_at": "2025-11-01T10:00:00Z",
          "updated_at": "2025-11-01T10:00:00Z",
          "city": {
            "id": 3,
            "name": "Москва",
            "short_name": "msk",
            "latitude": 55.7558,
            "longitude": 37.6173
          }
        }
      }
    ],
    "additional_services": [
      {
        "id": 201,
        "name": "Мытьё окон",
        "name_crm": "windows",
        "type": "toggle",
        "time": 60,
        "cities": [
          {
            "id": 3,
            "name": "Москва",
            "pivot": {
              "price": 700
            }
          }
        ],
        "pivot": {
          "order_template_id": 12,
          "additional_service_id": 201,
          "city_id": 3,
          "price": 700,
          "position": 2,
          "created_at": "2025-11-01T10:00:00Z",
          "updated_at": "2025-11-01T10:00:00Z",
          "city": {
            "id": 3,
            "name": "Москва",
            "short_name": "msk",
            "latitude": 55.7558,
            "longitude": 37.6173
          }
        }
      }
    ]
  }
}
```

> В реальном ответе присутствуют все дополнительные поля (`created_at`, `updated_at`, `html_content` и т. д.), здесь они частично опущены для краткости.

```http
GET /api/client/12?city_id=3
```

> **Примечание:** Для клиентского приложения используется эндпоинт `/api/client/{template_id}`. 
> 
> При необходимости можно дополнительно запросить услуги отдельными эндпоинтами (публичные):
> - `GET /api/order-templates/{template_id}/base-services?city_id={CITY_ID}`
> - `GET /api/order-templates/{template_id}/additional-services?city_id={CITY_ID}`

## 3. Сбор пользовательского ввода
1. Клиент выбирает шаблон заказа (ID шаблона).
2. Приложение отображает базовые (`base_services`) и дополнительные (`additional_services`) услуги из ответа п.2.2.
3. Пользователь задаёт значения:
   - Количество/объём для базовых услуг.
   - Значения/переключатели для дополнительных услуг.
4. **Обязательное правило:** при отправке заказа нужно передать **всю матрицу услуг**, даже если пользователь ничего не изменил. Для невыбранных услуг передаём нули (см. п.4.4 и 4.5).

## 4. Отправка заказа
- **Маршрут:** `POST /api/client/orders` (требует авторизации: `auth:sanctum`, `role:user`)
- **Заголовки:** `Authorization: Bearer {token}`, `Content-Type: application/json`
- **Тело запроса:** JSON c обязательными полями контроллера `ClientOrderController::store`.

### 4.1. Обязательные поля заказа
| Поле | Тип | Описание |
| --- | --- | --- |
| `city_id` | int | ID города клиента |
| `template_id` | int\|null | ID выбранного шаблона или `null` (если заказ полностью кастомный) |
| `order_type` | string | `single` или `multy` |
| `public_status` | bool | Публиковать заказ для поиска клинера |
| `dates` | string | Дата основной уборки в формате `дд.мм.гггг` |
| `times` | string | Время начала уборки `чч:мм` |
| `name` | string\|null | Имя клиента (опционально, если не указано — берётся из профиля пользователя) |
| `phone` | string\|null | Телефон клиента (опционально, если не указано — берётся из профиля пользователя) |
| `address_address` | string | Адрес |
| `address_kv` | string\|null | Номер квартиры/офиса |
| `latitude`, `longitude` | float | Координаты |
| `base_price`, `discount`, `total_price` | float | Стоимостные показатели (рассчитываются на клиенте) |
| `total_time` | int | Общее время в минутах |

### 4.2. Необязательные поля
- `dopinfo` — дополнительная информация о заказе
- `income` — процент выплаты клинеру (по умолчанию: 40% для single, 50% для multy)
- `status_id` — ID статуса заказа (по умолчанию: 1 — "Ищем клинера")
- Для подписок (`order_type = multy`) можно передать массив доп. дат `order_dates`
- `name`, `phone` — если не указаны, автоматически берутся из профиля авторизованного пользователя

### 4.3. Формат `order_dates`
```json
"order_dates": [
  { "date": "15.11.2025", "time": "10:00" },
  { "date": "22.11.2025", "time": "10:00" }
]
```

> Для заказов с `order_type = multy` обязательно передаём `order_dates` — расписание повторяющихся уборок. Количество элементов соответствует числу доп. визитов.

### 4.3.1. Структура ответа для multy-заказов
В ответах API, когда `order_type = "multy"`, объект заказа дополнительно содержит массив `orderDates`. Каждый элемент описывает отдельный визит подписки:

| Поле | Тип | Описание |
| --- | --- | --- |
| `id` | int | Идентификатор записи | 
| `order_id` | int | Связь с заказом |
| `scheduled_date` | string | Запланированная дата (`дд.мм.гггг`) |
| `scheduled_time` | string | Запланированное время (`чч:мм:сс`) |
| `date_time` | string | Полный `datetime` (ISO) |
| `status` | string | Состояние визита (`pending`, `completed`, и т. д.) |
| `created_at` / `updated_at` | string | Временные метки |

Фрагмент ответа `GET /api/my-orders` (усечённый):

```json
{
  "orders": [
    {
      "id": 501,
      "order_type": "multy",
      "dates": "15.11.2025",
      "times": "10:00",
      "orderDates": [
        {
          "id": 9001,
          "order_id": 501,
          "scheduled_date": "22.11.2025",
          "scheduled_time": "10:00:00",
          "date_time": "2025-11-22T10:00:00+03:00",
          "status": "pending",
          "created_at": "2025-11-01T10:00:00Z",
          "updated_at": "2025-11-01T10:00:00Z"
        },
        {
          "id": 9002,
          "order_id": 501,
          "scheduled_date": "29.11.2025",
          "scheduled_time": "10:00:00",
          "date_time": "2025-11-29T10:00:00+03:00",
          "status": "pending",
          "created_at": "2025-11-01T10:00:00Z",
          "updated_at": "2025-11-01T10:00:00Z"
        }
      ]
    }
  ]
}
```

### Рекомендации по работе с подписками
- Отображайте в приложении основную дату/время (поля `dates`, `times`) и список `orderDates` как последующие посещения.
- При отмене или переносе визита обновляйте соответствующий элемент `orderDates` через бекенд (см. эндпоинты управление расписанием).
- Для single-заказов массив `orderDates` отсутствует.

### 4.4. Формат `order_base_services`
- Передаём **все** базовые услуги шаблона.
- Если пользователь не менял количество — `quantity = 0` (требование: «все с нулевыми значениями, кроме введённых вручную»).
- Поля, которые обязательно передавать для каждой услуги:
  - `id` — из шаблона.
  - `quantity` — выбранное значение либо `0`.
  - `applied_discount` — скидка (если не используется, `0`).
  - `price` — цена услуги для города.
  - `position` — позиция услуги в шаблоне.

```json
"order_base_services": [
  {
    "id": 101,
    "quantity": 45,
    "applied_discount": 0,
    "price": 3200,
    "position": 1
  },
  {
    "id": 102,
    "quantity": 0,
    "applied_discount": 0,
    "price": 600,
    "position": 2
  },
  {
    "id": 103,
    "quantity": 0,
    "applied_discount": 0,
    "price": 400,
    "position": 3
  }
]
```

> ID услуг берём из `data.base_services[].id` ответа `GET /api/order-templates/{id}`.

### 4.5. Формат `order_additional_services`
- Для каждого элемента из `data.additional_services[]` отправляем объект со всеми полями, чтобы заполнить pivot-таблицу `order_additional_service`:
  - `id` — идентификатор услуги.
  - `value` — числовое значение (если не выбрано, `0`).
  - `toggle_value` — для `type = toggle` (0 или 1). Если тип не toggle, передаём `0`.
  - `price` — цена для города.
  - `position` — позиция услуги в шаблоне.
  - `type` — передаём только когда услуга типа `toggle`, чтобы ноль корректно трактовался.

```json
"order_additional_services": [
  {
    "id": 201,
    "value": 2,
    "toggle_value": 0,
    "price": 500,
    "position": 1
  },
  {
    "id": 202,
    "value": 0,
    "toggle_value": 0,
    "price": 0,
    "position": 2
  },
  {
    "id": 203,
    "type": "toggle",
    "value": 0,
    "toggle_value": 1,
    "price": 700,
    "position": 3
  }
]
```

### 4.6. Пример полного запроса

```http
POST /api/client/orders
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "city_id": 3,
  "template_id": 12,
  "order_type": "single",
  "public_status": true,
  "dates": "14.11.2025",
  "times": "09:30",
  "name": "Алексей",
  "phone": "+79991234567",
  "address_address": "Москва, ул. Примерная, д.1",
  "address_kv": "12",
  "latitude": 55.751244,
  "longitude": 37.618423,
  "base_price": 3200,
  "discount": 0,
  "total_price": 3200,
  "total_time": 180,
  "dopinfo": "Домофон 123",
  "order_base_services": [
    {
      "id": 101,
      "quantity": 45,
      "applied_discount": 0,
      "price": 3200,
      "position": 1
    },
    {
      "id": 102,
      "quantity": 0,
      "applied_discount": 0,
      "price": 600,
      "position": 2
    }
  ],
  "order_additional_services": [
    {
      "id": 201,
      "value": 0,
      "toggle_value": 0,
      "price": 0,
      "position": 1
    },
    {
      "id": 202,
      "value": 1,
      "toggle_value": 0,
      "price": 700,
      "position": 2
    },
    {
      "id": 203,
      "type": "toggle",
      "value": 0,
      "toggle_value": 1,
      "price": 500,
      "position": 3
    }
  ]
}
```

### 4.7. Ответ

**Успешный ответ (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "order_type": "single",
    "user_id": 5,
    "city_id": 3,
    "template_id": 12,
    "public_status": true,
    "dates": "14.11.2025",
    "times": "09:30",
    "date_time": "2025-11-14T09:30:00+03:00",
    "name": "Алексей",
    "phone": "+79991234567",
    "address_address": "Москва, ул. Примерная, д.1",
    "address_kv": "12",
    "latitude": 55.751244,
    "longitude": 37.618423,
    "base_price": 3200,
    "discount": 0,
    "total_price": 3200,
    "total_time": 180,
    "status_id": 1,
    "user_url": "abc123xyz",
    "orderBaseServices": [...],
    "orderAdditionalServices": [...],
    "city": {...},
    "template": {...}
  }
}
```

**Ошибки:**
- **401 Unauthorized**: отсутствует или невалидный токен авторизации
- **403 Forbidden**: у пользователя нет роли `user`
- **422 Unprocessable Entity**: ошибки валидации (например, не указан шаблон и услуги)
- **500 Internal Server Error**: внутренняя ошибка (смотрите лог сервера)

## 5. Поведение на бэкенде
- Валидация выполняется `ClientOrderController::store`.
- Заказ создаётся в транзакции.
- `user_id` автоматически берётся из авторизованного пользователя (`$request->user()->id`).
- Если `name` или `phone` не указаны в запросе, они автоматически берутся из профиля пользователя.
- Если массивы услуг переданы — используются они (без повторного подтягивания шаблона).
- Если услуг нет, но указан `template_id` — бэкенд сам синхронизирует услуги шаблона (значения по умолчанию = 0).
- Для подписок (`order_type = multy`) доп. даты сохраняются в `order_dates`.
- После создания заказа автоматически генерируется `user_url` через SqidsService.

## 6. Получение списка заказов

### 6.1. Маршрут и авторизация
- **Маршрут:** `GET /api/client/orders`
- **Требует авторизации:** `auth:sanctum`, `role:user`
- **Заголовки:** `Authorization: Bearer {token}`
- **Пагинация:** отсутствует, возвращаются все заказы пользователя

### 6.2. Описание
Метод возвращает все заказы текущего авторизованного пользователя. Заказы фильтруются по `user_id` или по `phone` (если у пользователя указан телефон). Результаты отсортированы по дате и времени заказа в порядке убывания (новые первыми).

### 6.3. Загружаемые отношения
Для каждого заказа автоматически загружаются следующие связанные данные:
- `city` — информация о городе
- `status` — статус заказа
- `template` — шаблон заказа (если указан)
- `orderDates` — дополнительные даты для подписок (multy-заказов)
- `payment` — информация о платеже по заказу (если есть)
- `cleaner` — краткая информация о назначенном клинере (если есть)

### 6.4. Пример запроса

```http
GET /api/client/orders
Authorization: Bearer {your_token}
```

### 6.5. Пример ответа (200 OK)

```json
[
  {
    "id": 123,
    "status_id": 2,
    "user_id": 5,
    "city_id": 3,
    "template_id": 12,
    "order_type": "single",
    "base_price": 3200,
    "discount": 0,
    "total_price": 3200,
    "total_time": 180,
    "is_app": true,
    "dates": "14.11.2025",
    "times": "09:30",
    "dopinfo": "Домофон 123",
    "name": "Алексей",
    "phone": "+79991234567",
    "address_address": "Москва, ул. Примерная, д.1",
    "address_kv": "12",
    "latitude": 55.751244,
    "longitude": 37.618423,
    "public_status": true,
    "income": 40,
    "cleaner_id": null,
    "date_time": "2025-11-14 09:30:00",
    "user_url": "abc123xyz",
    "created_at": "2025-11-01T10:00:00.000000Z",
    "updated_at": "2025-11-01T10:00:00.000000Z",
    "city": {
      "id": 3,
      "name": "Москва",
      "short_name": "msk",
      "latitude": 55.7558,
      "longitude": 37.6173
    },
    "status": {
      "id": 2,
      "name": "Принят",
      "slug": "accepted"
    },
    "template": {
      "id": 12,
      "name": "Генеральная уборка",
      "name_crm": "gen-cleaning"
    },
    "orderDates": [],
    "payment": {
      "id": 10,
      "order_id": 123,
      "amount": 320000,
      "status": "CONFIRMED"
    },
    "cleaner": {
      "id": 42,
      "name": "Иван",
      "lname": "Иванов",
      "rating": 4.8,
      "profile_photo_path": "cleaners/42.jpg",
      "profile_photo_url": "https://example.com/storage/images/avatars/cleaners/42.jpg"
    }
  },
  {
    "id": 124,
    "order_type": "multy",
    "dates": "15.11.2025",
    "times": "10:00",
    "orderDates": [
      {
        "id": 9001,
        "order_id": 124,
        "scheduled_date": "22.11.2025",
        "scheduled_time": "10:00:00",
        "date_time": "2025-11-22T10:00:00+03:00",
        "status": "pending",
        "created_at": "2025-11-01T10:00:00Z",
        "updated_at": "2025-11-01T10:00:00Z"
      }
    ]
  }
]
```

### 6.6. Ошибки
- **401 Unauthorized**: отсутствует или невалидный токен авторизации
- **500 Internal Server Error**: внутренняя ошибка сервера (смотрите лог сервера)

## 7. Просмотр детальной информации о заказе

### 7.1. Маршрут и авторизация
- **Маршрут:** `GET /api/client/orders/{order_id}`
- **Требует авторизации:** `auth:sanctum`, `role:user`
- **Заголовки:** `Authorization: Bearer {token}`
- **Параметры:** `{order_id}` — ID заказа

### 7.2. Описание
Метод возвращает детальную информацию о конкретном заказе. Доступ к заказу разрешён только если:
- Заказ принадлежит текущему пользователю (`user_id` совпадает), или
- Телефон заказа совпадает с телефоном текущего пользователя

Если заказ не принадлежит пользователю, возвращается ошибка 404.

### 7.3. Загружаемые отношения
Для заказа автоматически загружаются следующие связанные данные:
- `city` — информация о городе
- `status` — статус заказа
- `template` — шаблон заказа (если указан)
- `payment` — информация о платеже (если есть)
- `orderDates` — дополнительные даты для подписок (multy-заказов)
- `orderBaseServices` — базовые услуги заказа
- `orderAdditionalServices` — дополнительные услуги заказа
 - `cleaner` — клинер, назначенный на заказ (если есть), с краткой информацией для отображения

### 7.4. Пример запроса

```http
GET /api/client/orders/123
Authorization: Bearer {your_token}
```

### 7.5. Пример ответа (200 OK)

```json
{
  "data": {
    "id": 123,
    "status_id": 2,
    "user_id": 5,
    "city_id": 3,
    "template_id": 12,
    "order_type": "single",
    "base_price": 3200,
    "discount": 0,
    "total_price": 3200,
    "total_time": 180,
    "is_app": true,
    "dates": "14.11.2025",
    "times": "09:30",
    "dopinfo": "Домофон 123",
    "name": "Алексей",
    "phone": "+79991234567",
    "address_address": "Москва, ул. Примерная, д.1",
    "address_kv": "12",
    "latitude": 55.751244,
    "longitude": 37.618423,
    "public_status": true,
    "income": 40,
    "cleaner_id": 42,
    "date_time": "2025-11-14 09:30:00",
    "user_url": "abc123xyz",
    "created_at": "2025-11-01T10:00:00.000000Z",
    "updated_at": "2025-11-01T10:00:00.000000Z",
    "city": {
      "id": 3,
      "name": "Москва",
      "short_name": "msk",
      "latitude": 55.7558,
      "longitude": 37.6173
    },
    "status": {
      "id": 2,
      "name": "Принят",
      "slug": "accepted"
    },
    "template": {
      "id": 12,
      "name": "Генеральная уборка",
      "name_crm": "gen-cleaning",
      "mop": true,
      "base_time": 180
    },
    "payment": {
      "id": 1,
      "order_id": 123,
      "amount": 320000,
      "status": "CONFIRMED"
    },
    "cleaner": {
      "id": 42,
      "name": "Иван",
      "lname": "Иванов",
      "rating": "4.8",
      "profile_photo_path": "cleaners/42.jpg",
      "profile_photo_url": "https://example.com/storage/images/avatars/cleaners/42.jpg"
    },
    "orderDates": [],
    "orderBaseServices": [
      {
        "id": 101,
        "name": "Основная площадь",
        "pivot": {
          "order_id": 123,
          "base_service_id": 101,
          "quantity": 45,
          "applied_discount": 0,
          "price": 3200,
          "position": 1
        }
      }
    ],
    "orderAdditionalServices": [
      {
        "id": 201,
        "name": "Мытьё окон",
        "type": "toggle",
        "pivot": {
          "order_id": 123,
          "additional_service_id": 201,
          "value": 0,
          "toggle_value": 1,
          "price": 700,
          "position": 1
        }
      }
    ]
  }
}
```

### 7.6. Ошибки
- **401 Unauthorized**: отсутствует или невалидный токен авторизации
- **404 Not Found**: заказ не найден или не принадлежит текущему пользователю
- **500 Internal Server Error**: внутренняя ошибка сервера (смотрите лог сервера)

## 8. Дополнительные рекомендации
- **Обязательно** отправляйте токен авторизации в заголовке `Authorization: Bearer {token}` для всех запросов создания заказов.
- Перед отправкой пересчитывайте `total_price`, `total_time`, `base_price` на клиенте, чтобы значения согласовывались с выбранными услугами.
- Следите за форматами дат/времени: `d.m.Y` и `H:i`.
- Поля `name` и `phone` можно не передавать — они автоматически возьмутся из профиля пользователя.
- При обновлении заказа используйте `PUT /api/orders/{id}` (админский эндпоинт) с аналогичной структурой услуг (полное пересоздание массивов).
- **Список заказов** (`GET /api/client/orders`) возвращает все заказы без пагинации — учитывайте это при работе с большим количеством заказов.
- **Детали заказа** (`GET /api/client/orders/{order_id}`) включают полную информацию об услугах, платежах и назначенном клинере (ФИО, фото, рейтинг), что удобно для отображения детального экрана заказа.

## 9. Удаление заказа клиентом

### 9.1. Маршрут и авторизация
- **Маршрут:** `DELETE /api/client/orders/{order_id}`
- **Требует авторизации:** `auth:sanctum`, `role:user`
- **Заголовки:** `Authorization: Bearer {token}`
- **Параметры:** `{order_id}` — ID заказа

### 9.2. Описание
Клиент может удалить **только свой** заказ. Доступ к операции разрешён, если:
- `user_id` заказа совпадает с ID текущего пользователя, или
- телефон заказа совпадает с телефоном текущего пользователя.

В противном случае возвращается 404 (чтобы не раскрывать факт существования заказа).

### 9.3. Пример запроса

```http
DELETE /api/client/orders/123
Authorization: Bearer {your_token}
```

### 9.4. Успешный ответ

```json
{
  "success": true,
  "message": "Заказ успешно удалён"
}
```

### 9.5. Ошибки
- **401 Unauthorized**: отсутствует или невалидный токен авторизации
- **404 Not Found**: заказ не найден или не принадлежит текущему пользователю
- **500 Internal Server Error**: не удалось удалить заказ (см. лог сервера)

