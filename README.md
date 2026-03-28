# Oracle DB — структура проекта

## Структура каталогов

```
ORA-tutorial/
├── .env                      # Переменные окружения (DB_USER, DB_PASSWORD, DB_TNS)
├── .gitignore                # Игнорируемые файлы
├── download_all_packages.py  # Скрипт выгрузки объектов БД в файлы
│
├── PKG/                      # Пакеты (спецификации и тела)
│   ├── <PACKAGE_NAME>.pks   # Спецификация пакета
│   └── <PACKAGE_NAME>.pkb   # Тело пакета
│
├── TABLES/                   # Таблицы
│   ├── <TABLE_NAME>.sql     # DDL таблиц
│   └── <TABLE_NAME>_HIST.sql # Таблицы истории изменений
│
├── PROCEDURES/               # Процедуры
│   └── <PROCEDURE_NAME>.sql
│
├── FUNCTIONS/                # Функции
│   └── <FUNCTION_NAME>.sql
│
├── TRIGGERS/                 # Триггеры
│   ├── TRG_<TABLE>_INSERT.sql  # Триггер на INSERT
│   ├── TRG_<TABLE>_UPDATE.sql  # Триггер на UPDATE
│   ├── TRG_<TABLE>_DELETE.sql  # Триггер на DELETE
│   └── TRG_<TABLE>_LOG.sql     # Все триггеры логирования в одном файле
│
├── VIEWS/                    # Представления
│   └── <VIEW_NAME>.sql
│
├── INDEXES/                  # Индексы
│   └── <INDEX_NAME>.sql
│
├── SEQUENCES/                # Последовательности
│   └── <SEQUENCE_NAME>.sql
│
├── SYNONYMS/                 # Синонимы
│   └── <SYNONYM_NAME>.sql
│
├── DIRECTORIES/              # Directory объекты
│   └── <DIRECTORY_NAME>.sql
│
├── ROLES/                    # Роли
│   └── <ROLE_NAME>.sql      # Роль + её привилегии
│
└── PRIVILEGES/               # Привилегии
    ├── system_privileges.sql    # Системные привилегии
    └── object_privileges.sql    # Привилегии на объекты
```

## Быстрый старт

### 1. Настроить подключение

Отредактировать `.env`:
```bash
DB_USER=<your_user>
DB_PASSWORD=<your_password>
DB_TNS=<your_tns>
```

### 2. Выгрузить объекты из БД

```bash
uv run python download_all_packages.py
```

### 3. Развернуть на другой БД

```bash
# Таблицы
sqlplus <user>/<password>@<tns> @TABLES/SH_PROD.sql
sqlplus <user>/<password>@<tns> @TABLES/SH_PROD_HIST.sql

# Триггеры
sqlplus <user>/<password>@<tns> @TRIGGERS/TRG_SH_PROD_LOG.sql

# Пакеты
sqlplus <user>/<password>@<tns> @PKG/<PACKAGE_NAME>.pks
sqlplus <user>/<password>@<tns> @PKG/<PACKAGE_NAME>.pkb
```

## Логирование изменений

Для каждой таблицы создаётся таблица истории `_HIST`:

| Таблица | История | Триггеры |
|---------|---------|----------|
| `SH_PROD` | `SH_PROD_HIST` | `TRG_SH_PROD_LOG.sql` |
| `SH_AKC` | `SH_AKC_HIST` | `TRG_SH_AKC_LOG.sql` |
| `SH_SHOP` | `SH_SHOP_HIST` | `TRG_SH_SHOP_LOG.sql` |

### Структура `_HIST` таблиц

```sql
CREATE TABLE <TABLE>_HIST (
    ID NUMBER GENERATED ALWAYS AS IDENTITY,  -- ID события
    EVENT_DATE TIMESTAMP DEFAULT SYSTIMESTAMP, -- Дата/время
    PROD_ID NUMBER NOT NULL,                   -- ID изменённой записи
    OPERATION VARCHAR2(10) NOT NULL,           -- INSERT/UPDATE/DELETE
    DB_USER VARCHAR2(128),                     -- Пользователь БД
    NEW_<COLUMN1>,                             -- Новые значения
    NEW_<COLUMN2>
);
```

### Триггеры

- **INSERT** — записывает новые значения
- **UPDATE** — записывает только если есть реальные изменения (проверка в `WHEN`)
- **DELETE** — записывает только метаданные (кто, когда, ID)

## Git

```bash
# Коммит изменений
git add .
git commit -m "Описание изменений"

# Push
git push
```

Файлы `.env` и `shop/` игнорируются.

Комитить нужно после каждого изменения

## Зависимости

```bash
uv add python-dotenv  # Для загрузки .env
uv run python download_all_packages.py
```
