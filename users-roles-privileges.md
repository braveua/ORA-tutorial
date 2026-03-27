# Пользователи, роли и права в Oracle Database

Полное руководство по системе безопасности Oracle: пользователи, профили, роли, привилегии и управление доступом.

---

## Содержание

1. [Введение](#введение)
2. [Профили (Profiles)](#профили-profiles)
3. [Пользователи (Users)](#пользователи-users)
4. [Роли (Roles)](#роли-roles)
5. [Привилегии (Privileges)](#привилегии-privileges)
6. [Привилегии на пакеты](#привилегии-на-пакеты)
7. [Практические запросы для просмотра прав](#практические-запросы-для-просмотра-прав)
8. [Словарь представлений](#словарь-представлений)
9. [Лучшие практики безопасности](#лучшие-практики-безопасности)
10. [Приложения](#приложения)

---

## Введение

### Система безопасности Oracle

Система безопасности Oracle Database предназначена для защиты данных от несанкционированного доступа и управления правами пользователей. Основные компоненты системы:

- **Пользователи (Users)** — учётные записи для доступа к базе данных
- **Профили (Profiles)** — наборы параметров для ограничения ресурсов и управления паролями
- **Роли (Roles)** — именованные группы привилегий
- **Привилегии (Privileges)** — права на выполнение операций или доступ к объектам

### Иерархия объектов: кто первичен?

```
┌─────────────────────────────────────────────────────────┐
│                    БАЗА ДАННЫХ                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │              ПРОФИЛИ (Profiles)                   │  │
│  │  — параметры ресурсов и паролей                   │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                              │
│                          ▼                              │
│  ┌───────────────────────────────────────────────────┐  │
│  │           ПОЛЬЗОВАТЕЛИ (Users)                    │  │
│  │  — учётные записи, привязанные к профилю          │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                              │
│              ┌───────────┴───────────┐                  │
│              ▼                       ▼                  │
│  ┌───────────────────┐   ┌───────────────────────┐     │
│  │    РОЛИ (Roles)   │   │   ПРИВИЛЕГИИ          │     │
│  │  — группы прав    │   │   — права на объекты  │     │
│  └───────────────────┘   └───────────────────────┘     │
│              │                       │                  │
│              └───────────┬───────────┘                  │
│                          ▼                              │
│              Назначаются пользователю                   │
└─────────────────────────────────────────────────────────┘
```

**Ответ на вопрос «кто первичен»:** 

- **Пользователь и роль независимы** — их можно создавать друг без друга
- **Пользователь** — это учётная запись для входа в БД
- **Роль** — это контейнер для привилегий, который существует независимо от пользователей
- Связь между ними устанавливается при назначении роли пользователю

### Можно ли создать роль без пользователя?

**Да, можно.** Роли создаются независимо от пользователей:

```sql
CREATE ROLE my_role;
```

Роль существует в базе данных, пока не будет удалена, даже если ни одному пользователю не назначена.

### Можно ли создать пользователя без роли?

**Да, можно.** Пользователь может существовать без явно назначенных ролей:

```sql
CREATE USER test_user IDENTIFIED BY password;
```

Такой пользователь сможет подключиться к БД, но не будет иметь никаких привилегий (кроме базовых, таких как `CREATE SESSION`, если они предоставлены).

---

## Профили (Profiles)

### Назначение профилей

**Профиль** — это именованный набор параметров, который ограничивает:
- **Ресурсы базы данных**, доступные пользователю
- **Парольную политику** (срок действия, сложность, история)

Каждому пользователю назначается ровно один профиль. Если профиль не указан явно, используется профиль `DEFAULT`.

### Параметры ресурсов

| Параметр | Описание |
|----------|----------|
| `SESSIONS_PER_USER` | Максимальное количество одновременных сессий |
| `CPU_PER_SESSION` | Лимит CPU времени на сессию (в сотых долях секунды) |
| `CPU_PER_CALL` | Лимит CPU времени на один вызов SQL |
| `CONNECT_TIME` | Максимальная длительность сессии (в минутах) |
| `IDLE_TIME` | Максимальное время простоя сессии (в минутах) |
| `LOGICAL_READS_PER_SESSION` | Максимальное количество читаемых блоков данных |
| `LOGICAL_READS_PER_CALL` | Максимальное количество читаемых блоков на вызов |
| `COMPOSITE_LIMIT` | Общий лимит ресурсов (weighted sum) |

### Параметры паролей

| Параметр | Описание |
|----------|----------|
| `FAILED_LOGIN_ATTEMPTS` | Количество неудачных попыток входа до блокировки |
| `PASSWORD_LOCK_TIME` | Время блокировки после неудачных попыток (в днях) |
| `PASSWORD_LIFE_TIME` | Срок действия пароля (в днях) |
| `PASSWORD_REUSE_TIME` | Время, через которое можно reused старый пароль (в днях) |
| `PASSWORD_REUSE_MAX` | Количество использований пароля перед тем, как его можно reused |
| `PASSWORD_VERIFY_FUNCTION` | Функция проверки сложности пароля |
| `PASSWORD_MIN_LENGTH` | Минимальная длина пароля |
| `PASSWORD_GRACE_TIME` | Период предупреждения об истечении пароля (в днях) |

### Создание профиля

```sql
CREATE PROFILE app_user_profile LIMIT
    -- Параметры ресурсов
    SESSIONS_PER_USER 5
    CPU_PER_SESSION 10000
    CPU_PER_CALL 1000
    CONNECT_TIME 480
    IDLE_TIME 30
    LOGICAL_READS_PER_SESSION 100000
    -- Параметры паролей
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1
    PASSWORD_LIFE_TIME 90
    PASSWORD_REUSE_TIME 365
    PASSWORD_MIN_LENGTH 12
    PASSWORD_VERIFY_FUNCTION ora12g_verify_function;
```

### Назначение профиля пользователю

```sql
-- При создании пользователя
CREATE USER john IDENTIFIED BY secret_password
    PROFILE app_user_profile;

-- Изменение профиля существующего пользователя
ALTER USER john PROFILE app_user_profile;
```

### Просмотр профилей

```sql
-- Все профили в базе данных
SELECT profile_name, resource_name, limit, resource_type
FROM dba_profiles
ORDER BY profile_name, resource_type, resource_name;

-- Параметры конкретного профиля
SELECT resource_name, limit, resource_type
FROM dba_profiles
WHERE profile_name = 'APP_USER_PROFILE';

-- Пользователи и их профили
SELECT username, profile, account_status, expiry_date
FROM dba_users
ORDER BY profile, username;
```

### Изменение и удаление профиля

```sql
-- Изменение параметра профиля
ALTER PROFILE app_user_profile LIMIT
    SESSIONS_PER_USER 10
    IDLE_TIME 60;

-- Удаление профиля (пользователи получают DEFAULT)
DROP PROFILE app_user_profile;

-- Удаление профиля с каскадным изменением пользователей
DROP PROFILE app_user_profile CASCADE;
```

### Предопределённые профили

- **DEFAULT** — профиль по умолчанию для всех пользователей
- **MONITORING_PROFILE** — для пользователей мониторинга

---

## Пользователи (Users)

### Что такое пользователь в Oracle

**Пользователь** — это учётная запись в базе данных Oracle, которая:
- Имеет уникальное имя в пределах БД
- Связана с профилем (явно или DEFAULT)
- Может владеть объектами (таблицами, индексами, процедурами)
- Имеет собственное пространство имён объектов

### Создание пользователя

```sql
-- Базовый синтаксис
CREATE USER username
    IDENTIFIED BY password
    [DEFAULT TABLESPACE tablespace_name]
    [TEMPORARY TABLESPACE tablespace_name]
    [QUOTA [size] ON tablespace_name]
    [PROFILE profile_name]
    [PASSWORD EXPIRE]
    [ACCOUNT LOCK | UNLOCK];
```

### Примеры создания пользователей

```sql
-- Простой пользователь с паролем
CREATE USER developer IDENTIFIED BY DevPass123;

-- Пользователь с указанием tablespaces и квот
CREATE USER app_owner
    IDENTIFIED BY OwnerPass456
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA 1G ON users
    QUOTA UNLIMITED ON temp
    PROFILE app_user_profile;

-- Пользователь с истёкшим паролем (требует смены при первом входе)
CREATE USER new_user
    IDENTIFIED BY TempPass789
    PASSWORD EXPIRE;

-- Заблокированный пользователь (создаётся, но не может войти)
CREATE USER suspended_user
    IDENTIFIED BY SuspPass
    ACCOUNT LOCK;

-- Пользователь без пароля (для внешней аутентификации)
CREATE USER ext_user IDENTIFIED EXTERNALLY;

-- Пользователь для аутентификации через OS
CREATE USER ops_user IDENTIFIED GLOBALLY AS 'CN=ops_user,O=company,C=RU';
```

### Аутентификация пользователей

| Тип | Синтаксис | Описание |
|-----|-----------|----------|
| Пароль | `IDENTIFIED BY password` | Стандартная аутентификация по паролю |
| Внешняя | `IDENTIFIED EXTERNALLY` | Через внешнюю службу (LDAP, Kerberos) |
| Глобальная | `IDENTIFIED GLOBALLY AS 'DN'` | Через Oracle Internet Directory |
| OS | `IDENTIFIED EXTERNALLY` | Через операционную систему (ops$) |

### Квоты на таблицы

```sql
-- Назначение квоты при создании
CREATE USER user1 IDENTIFIED BY pass
    QUOTA 500M ON users
    QUOTA 100M ON data_ts;

-- Изменение квоты существующему пользователю
ALTER USER user1 QUOTA 1G ON users;

-- Снятие квоты (запрет создания объектов)
ALTER USER user1 QUOTA 0 ON data_ts;

-- Неограниченная квота
ALTER USER user1 QUOTA UNLIMITED ON users;
```

### Изменение пользователя

```sql
-- Смена пароля
ALTER USER developer IDENTIFIED BY NewPass456;

-- Разблокировка пользователя
ALTER USER suspended_user ACCOUNT UNLOCK;

-- Принудительная смена пароля
ALTER USER developer PASSWORD EXPIRE;

-- Изменение default tablespace
ALTER USER app_owner DEFAULT TABLESPACE data_ts;

-- Изменение временного tablespace
ALTER USER app_owner TEMPORARY TABLESPACE temp2;
```

### Удаление пользователя

```sql
-- Удаление пользователя (ошибка, если есть объекты)
DROP USER username;

-- Удаление пользователя со всеми объектами (каскадное)
DROP USER username CASCADE;
```

### Просмотр пользователей

```sql
-- Все пользователи в БД
SELECT username, account_status, profile, 
       default_tablespace, temporary_tablespace,
       created, expiry_date
FROM dba_users
ORDER BY username;

-- Пользователи с истёкшим паролем
SELECT username, expiry_date, account_status
FROM dba_users
WHERE expiry_date < SYSDATE
  AND account_status = 'OPEN';

-- Пользователи с заблокированными учётками
SELECT username, account_status, lock_date
FROM dba_users
WHERE account_status LIKE '%LOCKED%';

-- Квоты пользователей
SELECT u.username, q.tablespace_name, q.bytes/1024/1024 as used_mb,
       q.max_bytes/1024/1024 as quota_mb, q.blocks
FROM dba_users u
JOIN dba_ts_quotas q ON u.username = q.username
ORDER BY u.username, q.tablespace_name;
```

---

## Роли (Roles)

### Назначение ролей

**Роль** — это именованная группа привилегий, которая:
- Упрощает управление правами (группировка привилегий)
- Может назначаться множеству пользователей
- Может содержать другие роли (иерархия)
- Может быть защищена паролем

### Создание роли

```sql
-- Простая роль
CREATE ROLE app_reader;

-- Роль с паролем (требуется для активации)
CREATE ROLE app_admin IDENTIFIED BY RolePass123;

-- Роль для внешней аутентификации
CREATE ROLE ext_role IDENTIFIED EXTERNALLY;
```

### Предопределённые роли Oracle

| Роль | Описание |
|------|----------|
| `DBA` | Все системные привилегии (администратор) |
| `CONNECT` | Базовые привилегии для подключения (устарела в 12c+) |
| `RESOURCE` | Привилегии для создания объектов (устарела в 12c+) |
| `SELECT_CATALOG_ROLE` | Доступ к словарю данных (DBA_* представления) |
| `EXECUTE_CATALOG_ROLE` | Выполнение пакетов словаря данных |
| `DELETE_CATALOG_ROLE` | Удаление записей из аудита |
| `GATHER_SYSTEM_STATISTICS` | Сбор статистики оптимизатора |
| `SCHEDULER_ADMIN` | Управление Oracle Scheduler |
| `IMP_FULL_DATABASE` | Полный импорт базы данных |
| `EXP_FULL_DATABASE` | Полный экспорт базы данных |
| `AUDIT_ADMIN` | Управление аудитом |
| `AUDIT_VIEWER` | Просмотр записей аудита |

> **Важно:** В Oracle 12c и выше роли `CONNECT` и `RESOURCE` считаются устаревшими. Рекомендуется создавать собственные роли с минимальным набором привилегий.

### Назначение привилегий ролям

```sql
-- Системные привилегии
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW TO app_developer;

-- Объектные привилегии
GRANT SELECT, INSERT, UPDATE ON hr.employees TO app_developer;

-- Привилегии на пакеты
GRANT EXECUTE ON dbms_output TO app_developer;

-- Другие роли
GRANT select_catalog_role TO app_developer;
```

### Назначение ролей пользователям

```sql
-- Назначение роли пользователю
GRANT app_reader TO john;
GRANT app_developer TO jane;

-- Назначение нескольких ролей
GRANT app_reader, app_writer TO user1;

-- Роль с ADMIN OPTION (может передавать роль другим)
GRANT app_admin TO senior_dev WITH ADMIN OPTION;

-- Назначение роли с указанием DEFAULT
GRANT app_reader, app_writer TO user1;
ALTER USER user1 DEFAULT ROLE app_reader, app_writer;

-- Назначение всех ролей по умолчанию
ALTER USER user1 DEFAULT ROLE ALL;

-- Без ролей по умолчанию (требуется SET ROLE)
ALTER USER user1 DEFAULT ROLE NONE;
```

### Активация и деактивация ролей

```sql
-- Просмотр активных ролей в текущей сессии
SELECT * FROM session_roles;

-- Активация роли (если не DEFAULT)
SET ROLE app_admin IDENTIFIED BY RolePass123;

-- Активация всех доступных ролей
SET ROLE ALL;

-- Деактивация всех ролей
SET ROLE NONE;

-- Деактивация конкретной роли
SET ROLE app_reader;
```

### Иерархия ролей (роли в ролях)

```sql
-- Создание иерархии ролей
CREATE ROLE app_base_role;
CREATE ROLE app_extended_role;

-- Назначение привилегий базовой роли
GRANT CREATE SESSION, SELECT ANY TABLE TO app_base_role;

-- Включение базовой роли в расширенную
GRANT app_base_role TO app_extended_role;
GRANT INSERT ANY TABLE TO app_extended_role;

-- Назначение расширенной роли пользователю
GRANT app_extended_role TO user1;
-- user1 получает привилегии обеих ролей
```

### Удаление роли

```sql
DROP ROLE role_name;
```

> При удалении роли все пользователи, которым она была назначена, теряют соответствующие привилегии.

### Просмотр ролей

```sql
-- Все роли в базе данных
SELECT role, password_required
FROM dba_roles
ORDER BY role;

-- Роли, назначенные пользователю
SELECT grantee, granted_role, admin_option, default_role
FROM dba_role_privs
WHERE grantee = 'JOHN'
ORDER BY granted_role;

-- Привилегии, назначенные роли
SELECT privilege, admin_option
FROM dba_sys_privs
WHERE grantee = 'APP_DEVELOPER'
UNION ALL
SELECT table_name || '.' || privilege, grantable
FROM dba_tab_privs
WHERE grantee = 'APP_DEVELOPER';

-- Иерархия ролей (какие роли содержат другие роли)
SELECT grantee, granted_role
FROM dba_role_privs
WHERE grantee IN (SELECT role FROM dba_roles)
ORDER BY grantee, granted_role;

-- Активные роли в текущей сессии
SELECT * FROM session_roles;
```

---

## Привилегии (Privileges)

### Типы привилегий

#### Системные привилегии (SYSTEM Privileges)

Права на выполнение системных операций или операций с любыми объектами определённого типа:

```sql
-- Примеры системных привилегий
CREATE SESSION          -- Подключение к базе данных
CREATE TABLE            -- Создание таблиц
CREATE VIEW             -- Создание представлений
CREATE PROCEDURE        -- Создание процедур
CREATE SEQUENCE         -- Создание последовательностей
CREATE TRIGGER          -- Создание триггеров
CREATE TYPE             -- Создание типов
CREATE SYNONYM          -- Создание синонимов

ALTER ANY TABLE         -- Изменение любой таблицы
DROP ANY TABLE          -- Удаление любой таблицы
SELECT ANY TABLE        -- Выборка из любой таблицы
INSERT ANY TABLE        -- Вставка в любую таблицу
UPDATE ANY TABLE        -- Обновление любой таблицы
DELETE ANY TABLE        -- Удаление из любой таблицы

EXECUTE ANY PROCEDURE   -- Выполнение любой процедуры
EXECUTE ANY FUNCTION    -- Выполнение любой функции
EXECUTE ANY TYPE        -- Использование любого типа

CREATE USER             -- Создание пользователей
ALTER USER              -- Изменение пользователей
DROP USER               -- Удаление пользователей
CREATE ROLE             -- Создание ролей
DROP ROLE               -- Удаление ролей
GRANT ANY PRIVILEGE     -- Предоставление любых привилегий
GRANT ANY ROLE          -- Предоставление любых ролей

DBA                     -- Все системные привилегии
```

#### Объектные привилегии (OBJECT Privileges)

Права на доступ к конкретному объекту базы данных:

| Объект | Привилегии |
|--------|-----------|
| Таблица/Представление | `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `ALTER`, `INDEX`, `REFERENCES` |
| Последовательность | `SELECT`, `ALTER` |
| Процедура/Функция/Пакет | `EXECUTE`, `DEBUG` |
| Тип | `EXECUTE` |
| Синоним | `SELECT` (для синонима таблицы) |
| Directory | `READ`, `WRITE` |

### Предоставление привилегий (GRANT)

```sql
-- Системные привилегии
GRANT CREATE SESSION, CREATE TABLE TO developer;

-- Объектные привилегии на таблицу
GRANT SELECT, INSERT, UPDATE ON hr.employees TO developer;

-- Объектные привилегии на все колонки
GRANT SELECT ON hr.employees TO reader;

-- Привилегии на конкретные колонки
GRANT UPDATE (salary, commission_pct) ON hr.employees TO hr_manager;

-- Привилегии на последовательность
GRANT SELECT, ALTER ON hr.emp_seq TO developer;

-- Привилегии на пакет
GRANT EXECUTE ON dbms_output TO developer;

-- Привилегии на directory
GRANT READ ON directory data_dir TO loader;
GRANT WRITE ON directory data_dir TO loader;
```

### WITH ADMIN OPTION vs WITH GRANT OPTION

| Опция | Для чего | Возможность передачи |
|-------|----------|---------------------|
| `WITH ADMIN OPTION` | Системные привилегии и роли | Получатель может передавать привилегию/роль другим |
| `WITH GRANT OPTION` | Объектные привилегии | Получатель может передавать привилегию другим |

```sql
-- Системная привилегия с ADMIN OPTION
GRANT CREATE TABLE TO developer WITH ADMIN OPTION;
-- developer может предоставить CREATE TABLE другому пользователю

-- Роль с ADMIN OPTION
GRANT app_admin TO senior_dev WITH ADMIN OPTION;
-- senior_dev может назначить роль app_admin другому

-- Объектная привилегия с GRANT OPTION
GRANT SELECT ON hr.employees TO analyst WITH GRANT OPTION;
-- analyst может предоставить SELECT на hr.employees другому
```

> **Важно:** При отзыве привилегии с `ADMIN OPTION` или `GRANT OPTION` все переданные привилегии также отзываются (каскадный отзыв).

### Отзыв привилегий (REVOKE)

```sql
-- Отзыв системных привилегий
REVOKE CREATE TABLE FROM developer;

-- Отзыв ролей
REVOKE app_reader FROM john;

-- Отзыв объектных привилегий
REVOKE INSERT, UPDATE ON hr.employees FROM developer;

-- Отзыв привилегий на конкретные колонки
REVOKE UPDATE (salary) ON hr.employees FROM hr_manager;

-- Отзыв всех привилегий на объект
REVOKE ALL ON hr.employees FROM developer;

-- Отзыв с каскадом (для GRANT OPTION)
REVOKE GRANT OPTION FOR SELECT ON hr.employees FROM analyst CASCADE;
```

### Просмотр привилегий

```sql
-- Системные привилегии пользователя
SELECT grantee, privilege, admin_option
FROM dba_sys_privs
WHERE grantee = 'DEVELOPER';

-- Объектные привилегии пользователя (как получатель)
SELECT owner, table_name, privilege, grantable, grantor
FROM dba_tab_privs
WHERE grantee = 'DEVELOPER';

-- Объектные привилегии на объект (кто имеет доступ)
SELECT grantee, privilege, grantable, grantor
FROM dba_tab_privs
WHERE owner = 'HR' AND table_name = 'EMPLOYEES';

-- Привилегии на колонки
SELECT grantee, table_name, column_name, privilege
FROM dba_col_privs
WHERE grantee = 'DEVELOPER';
```

---

## Привилегии на пакеты

### Просмотр определений пакетов

Для просмотра кода пакетов необходимы следующие привилегии:

| Привилегия | Описание |
|------------|----------|
| `EXECUTE` на пакет | Выполнение процедур/функций пакета |
| `DEBUG` на пакет | Отладка кода пакета |
| `SELECT ANY DICTIONARY` | Просмотр определений в словаре |
| `EXECUTE ANY PROCEDURE` | Выполнение любой процедуры (системная) |

### Просмотр исходного кода пакетов

```sql
-- Исходный код пакетов (требуется доступ к DBA_SOURCE или ALL_SOURCE)
SELECT name, type, line, text
FROM dba_source
WHERE owner = 'SYS' 
  AND name = 'DBMS_OUTPUT'
  AND type = 'PACKAGE'
ORDER BY line;

-- Заголовок пакета (PACKAGE SPEC)
SELECT text
FROM dba_source
WHERE owner = 'SYS' 
  AND name = 'DBMS_OUTPUT'
  AND type = 'PACKAGE'
ORDER BY line;

-- Тело пакета (PACKAGE BODY)
SELECT text
FROM dba_source
WHERE owner = 'SYS' 
  AND name = 'DBMS_OUTPUT'
  AND type = 'PACKAGE BODY'
ORDER BY line;
```

### Предоставление привилегий на пакеты

```sql
-- Привилегия EXECUTE на пакет
GRANT EXECUTE ON dbms_output TO developer;
GRANT EXECUTE ON dbms_scheduler TO app_admin;

-- Привилегия DEBUG для отладки
GRANT DEBUG ON hr.calc_salary TO developer;

-- Системная привилегия для выполнения любых процедур
GRANT EXECUTE ANY PROCEDURE TO app_developer;

-- Системная привилегия для отладки любых процедур
GRANT DEBUG ANY PROCEDURE TO senior_developer;
```

### Просмотр привилегий на пакеты

```sql
-- Кто имеет привилегии на конкретный пакет
SELECT grantee, privilege, grantable, grantor
FROM dba_tab_privs
WHERE owner = 'SYS' 
  AND table_name = 'DBMS_OUTPUT'
  AND type = 'PACKAGE';

-- Все пакеты, на которые у пользователя есть привилегии
SELECT owner, table_name as package_name, privilege
FROM dba_tab_privs
WHERE grantee = 'DEVELOPER'
  AND type IN ('PACKAGE', 'PROCEDURE', 'FUNCTION');

-- Системные привилегии на выполнение любых процедур
SELECT grantee, privilege, admin_option
FROM dba_sys_privs
WHERE privilege IN ('EXECUTE ANY PROCEDURE', 'DEBUG ANY PROCEDURE');
```

### DBMS_METADATA для просмотра определений

```sql
-- Получение DDL пакета через DBMS_METADATA
SET LONG 100000;
SELECT DBMS_METADATA.GET_DDL('PACKAGE', 'DBMS_OUTPUT', 'SYS') FROM dual;

-- Получение DDL тела пакета
SELECT DBMS_METADATA.GET_DDL('PACKAGE_BODY', 'DBMS_OUTPUT', 'SYS') FROM dual;
```

---

## Практические запросы для просмотра прав

### Просмотр прав пользователя на конкретную таблицу

```sql
-- Все привилегии пользователя на конкретную таблицу
SELECT privilege, grantable, grantor
FROM dba_tab_privs
WHERE grantee = 'DEVELOPER'
  AND owner = 'HR'
  AND table_name = 'EMPLOYEES';

-- Привилегии пользователя (прямые + через роли)
-- Прямые привилегии
SELECT 'DIRECT' as source, privilege, owner, table_name
FROM dba_tab_privs
WHERE grantee = 'DEVELOPER'
  AND owner = 'HR'
  AND table_name = 'EMPLOYEES'
UNION ALL
-- Привилегии через роли
SELECT 'VIA ROLE: ' || r.granted_role, t.privilege, t.owner, t.table_name
FROM dba_role_privs r
JOIN dba_tab_privs t ON r.granted_role = t.grantee
WHERE r.grantee = 'DEVELOPER'
  AND t.owner = 'HR'
  AND t.table_name = 'EMPLOYEES';
```

### Просмотр всех прав на таблицу (кто может читать/писать)

```sql
-- Все пользователи и роли с привилегиями на таблицу
SELECT grantee, privilege, grantable, grantor, hierarchy
FROM dba_tab_privs
WHERE owner = 'HR'
  AND table_name = 'EMPLOYEES'
ORDER BY privilege, grantee;

-- Детализированный отчёт по таблице
SELECT 
    grantee as "Пользователь/Роль",
    privilege as "Привилегия",
    CASE grantable WHEN 'YES' THEN '✓' ELSE '' END as "Может передать",
    grantor as "Кто предоставил"
FROM dba_tab_privs
WHERE owner = 'HR'
  AND table_name = 'EMPLOYEES'
ORDER BY 
    CASE privilege 
        WHEN 'SELECT' THEN 1 
        WHEN 'INSERT' THEN 2 
        WHEN 'UPDATE' THEN 3 
        WHEN 'DELETE' THEN 4 
        ELSE 5 
    END,
    grantee;

-- Кто может читать (SELECT)
SELECT grantee, grantor
FROM dba_tab_privs
WHERE owner = 'HR'
  AND table_name = 'EMPLOYEES'
  AND privilege = 'SELECT';

-- Кто может писать (INSERT, UPDATE, DELETE)
SELECT grantee, privilege, grantor
FROM dba_tab_privs
WHERE owner = 'HR'
  AND table_name = 'EMPLOYEES'
  AND privilege IN ('INSERT', 'UPDATE', 'DELETE');

-- Полный доступ (ALL PRIVILEGES)
SELECT grantee, grantor
FROM dba_tab_privs
WHERE owner = 'HR'
  AND table_name = 'EMPLOYEES'
  AND privilege = 'ALL';
```

### Просмотр всех привилегий пользователя

```sql
-- Системные привилегии пользователя
SELECT privilege, admin_option
FROM dba_sys_privs
WHERE grantee = 'DEVELOPER'
ORDER BY privilege;

-- Объектные привилегии пользователя
SELECT owner, table_name, privilege, grantable
FROM dba_tab_privs
WHERE grantee = 'DEVELOPER'
ORDER BY owner, table_name, privilege;

-- Роли пользователя
SELECT granted_role, admin_option, default_role
FROM dba_role_privs
WHERE grantee = 'DEVELOPER'
ORDER BY granted_role;

-- Полный отчёт по привилегиям пользователя
SELECT 'SYSTEM PRIVILEGE' as type, privilege as detail, admin_option as option_flag
FROM dba_sys_privs
WHERE grantee = 'DEVELOPER'
UNION ALL
SELECT 'ROLE', granted_role, admin_option
FROM dba_role_privs
WHERE grantee = 'DEVELOPER'
UNION ALL
SELECT 'OBJECT: ' || privilege, owner || '.' || table_name, grantable
FROM dba_tab_privs
WHERE grantee = 'DEVELOPER'
ORDER BY type, detail;
```

### Просмотр всех привилегий роли

```sql
-- Системные привилегии роли
SELECT privilege, admin_option
FROM dba_sys_privs
WHERE grantee = 'APP_DEVELOPER'
ORDER BY privilege;

-- Объектные привилегии роли
SELECT owner, table_name, privilege, grantable
FROM dba_tab_privs
WHERE grantee = 'APP_DEVELOPER'
ORDER BY owner, table_name, privilege;

-- Вложенные роли (роли внутри роли)
SELECT granted_role, admin_option
FROM dba_role_privs
WHERE grantee = 'APP_DEVELOPER'
ORDER BY granted_role;

-- Полный отчёт по привилегиям роли
SELECT 'SYSTEM PRIVILEGE' as type, privilege as detail
FROM dba_sys_privs
WHERE grantee = 'APP_DEVELOPER'
UNION ALL
SELECT 'ROLE', granted_role
FROM dba_role_privs
WHERE grantee = 'APP_DEVELOPER'
UNION ALL
SELECT 'OBJECT: ' || privilege, owner || '.' || table_name
FROM dba_tab_privs
WHERE grantee = 'APP_DEVELOPER'
ORDER BY type, detail;
```

### Просмотр иерархии ролей

```sql
-- Рекурсивный запрос для иерархии ролей
WITH role_hierarchy AS (
    -- Базовый случай: роли, назначенные пользователю
    SELECT grantee, granted_role, 1 as level_num
    FROM dba_role_privs
    WHERE grantee = 'DEVELOPER'
    
    UNION ALL
    
    -- Рекурсивный случай: роли внутри ролей
    SELECT r.grantee, r.granted_role, h.level_num + 1
    FROM dba_role_privs r
    JOIN role_hierarchy h ON r.grantee = h.granted_role
    WHERE h.level_num < 10  -- защита от циклов
)
SELECT grantee, granted_role, level_num
FROM role_hierarchy
ORDER BY level_num, granted_role;
```

### Аудит: кто предоставил привилегии

```sql
-- История предоставления/отзыва привилегий (если включён аудит)
SELECT action_name, obj_name, privilege, grantee, grantor, timestamp
FROM dba_audit_trail
WHERE action_name IN ('GRANT', 'REVOKE')
ORDER BY timestamp DESC;
```

---

## Словарь представлений

### Обзор представлений словаря данных

| Представление | Описание | Доступ |
|---------------|----------|--------|
| `DBA_*` | Все объекты в БД | Требуется привилегия |
| `ALL_*` | Объекты, доступные пользователю | Все пользователи |
| `USER_*` | Объекты, принадлежащие пользователю | Все пользователи |

### Основные представления для управления правами

#### Пользователи и профили

```sql
-- DBA_USERS — все пользователи
SELECT username, account_status, profile, 
       default_tablespace, temporary_tablespace,
       created, expiry_date
FROM dba_users;

-- DBA_PROFILES — все профили и их параметры
SELECT profile, resource_name, limit, resource_type
FROM dba_profiles;

-- DBA_TS_QUOTAS — квоты пользователей на tablespace
SELECT username, tablespace_name, bytes, max_bytes, blocks
FROM dba_ts_quotas;
```

#### Привилегии

```sql
-- DBA_SYS_PRIVS — системные привилегии
SELECT grantee, privilege, admin_option
FROM dba_sys_privs;

-- DBA_TAB_PRIVS — объектные привилегии
SELECT grantee, owner, table_name, privilege, grantable, grantor
FROM dba_tab_privs;

-- DBA_COL_PRIVS — привилегии на колонки
SELECT grantee, owner, table_name, column_name, privilege, grantable
FROM dba_col_privs;

-- USER_TAB_PRIVS — привилегии текущего пользователя
SELECT owner, table_name, privilege, grantable
FROM user_tab_privs;

-- USER_SYS_PRIVS — системные привилегии текущего пользователя
SELECT privilege, admin_option
FROM user_sys_privs;
```

#### Роли

```sql
-- DBA_ROLES — все роли в БД
SELECT role, password_required
FROM dba_roles;

-- DBA_ROLE_PRIVS — назначенные роли
SELECT grantee, granted_role, admin_option, default_role
FROM dba_role_privs;

-- ROLE_ROLE_PRIVS — роли внутри ролей (для текущей роли)
SELECT granted_role, admin_option
FROM role_role_privs;

-- ROLE_SYS_PRIVS — системные привилегии роли
SELECT privilege, admin_option
FROM role_sys_privs;

-- ROLE_TAB_PRIVS — объектные привилегии роли
SELECT owner, table_name, privilege, grantable
FROM role_tab_privs;

-- SESSION_ROLES — активные роли в текущей сессии
SELECT role
FROM session_roles;
```

#### Исходный код объектов

```sql
-- DBA_SOURCE — исходный код всех объектов
SELECT owner, name, type, line, text
FROM dba_source
WHERE type = 'PACKAGE';

-- ALL_SOURCE — доступный пользователю код
SELECT owner, name, type, line, text
FROM all_source;

-- USER_SOURCE — код объектов пользователя
SELECT name, type, line, text
FROM user_source;

-- DBA_OBJECTS — все объекты в БД
SELECT owner, object_name, object_type, status, created
FROM dba_objects;

-- DBA_PROCEDURES — процедуры и функции
SELECT owner, object_name, procedure_name, object_type
FROM dba_procedures;
```

### Полезные запросы к словарю

```sql
-- Найти все объекты пользователя
SELECT object_name, object_type, status, created
FROM dba_objects
WHERE owner = 'HR'
ORDER BY object_type, object_name;

-- Найти все синонимы к таблице
SELECT owner, synonym_name, table_owner, table_name
FROM dba_synonyms
WHERE table_owner = 'HR' AND table_name = 'EMPLOYEES';

-- Проверить, существует ли пользователь
SELECT username, account_status
FROM dba_users
WHERE username = 'DEVELOPER';

-- Проверить, существует ли роль
SELECT role, password_required
FROM dba_roles
WHERE role = 'APP_ADMIN';
```

---

## Лучшие практики безопасности

### Принцип наименьших привилегий

> Пользователь должен иметь минимальный набор привилегий, необходимых для выполнения его задач.

```sql
-- ❌ ПЛОХО: предоставление избыточных прав
GRANT dba TO app_user;

-- ✅ ХОРОШО: создание роли с минимальным набором
CREATE ROLE app_minimal_role;
GRANT CREATE SESSION TO app_minimal_role;
GRANT SELECT ON hr.employees TO app_minimal_role;
GRANT app_minimal_role TO app_user;
```

### Использование ролей вместо прямого назначения

```sql
-- ❌ ПЛОХО: прямое назначение привилегий пользователям
GRANT SELECT ON hr.employees TO user1;
GRANT SELECT ON hr.employees TO user2;
GRANT SELECT ON hr.employees TO user3;

-- ✅ ХОРОШО: назначение через роль
CREATE ROLE hr_reader;
GRANT SELECT ON hr.employees TO hr_reader;
GRANT hr_reader TO user1, user2, user3;

-- При изменении прав достаточно обновить роль
```

### Регулярный аудит прав доступа

```sql
-- Запрос для аудита: пользователи с привилегией DBA
SELECT grantee, admin_option
FROM dba_sys_privs
WHERE privilege = 'DBA';

-- Пользователи с неограниченными квотами
SELECT username, tablespace_name
FROM dba_ts_quotas
WHERE max_bytes = -1;

-- Пользователи с устаревшими паролями
SELECT username, expiry_date, account_status
FROM dba_users
WHERE expiry_date < SYSDATE
  AND account_status = 'OPEN';

-- Роли без пароля (требующие защиты)
SELECT role, password_required
FROM dba_roles
WHERE password_required = 'NO'
  AND role NOT IN ('CONNECT', 'RESOURCE', 'DBA');
```

### Управление профилями паролей

```sql
-- Создание строгого профиля паролей
CREATE PROFILE secure_profile LIMIT
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 1
    PASSWORD_LIFE_TIME 60
    PASSWORD_REUSE_TIME 365
    PASSWORD_MIN_LENGTH 14
    PASSWORD_VERIFY_FUNCTION ora12g_strong_verify_function;

-- Назначение профиля критическим пользователям
ALTER USER admin_user PROFILE secure_profile;
```

### Разделение обязанностей (Separation of Duties)

```sql
-- Создание отдельных ролей для разных операций
CREATE ROLE app_read_role;
CREATE ROLE app_write_role;
CREATE ROLE app_admin_role;

GRANT SELECT ON hr.employees TO app_read_role;
GRANT INSERT, UPDATE, DELETE ON hr.employees TO app_write_role;
GRANT ALTER, INDEX ON hr.employees TO app_admin_role;

-- Назначение ролей разным пользователям
GRANT app_read_role TO analyst;
GRANT app_write_role TO operator;
GRANT app_admin_role TO dba;
```

### Мониторинг подозрительной активности

```sql
-- Неудачные попытки входа
SELECT username, returncode, logon_time, action_name
FROM dba_audit_trail
WHERE action_name = 'LOGON'
  AND returncode != 0
ORDER BY logon_time DESC;

-- Изменения привилегий
SELECT action_name, obj_name, grantee, grantor, timestamp
FROM dba_audit_trail
WHERE action_name IN ('GRANT', 'REVOKE')
ORDER BY timestamp DESC;
```

---

## Приложения

### Таблица распространённых системных привилегий

| Привилегия | Описание |
|------------|----------|
| `CREATE SESSION` | Подключение к базе данных |
| `CREATE TABLE` | Создание таблиц в своей схеме |
| `CREATE VIEW` | Создание представлений |
| `CREATE PROCEDURE` | Создание процедур, функций, пакетов |
| `CREATE SEQUENCE` | Создание последовательностей |
| `CREATE TRIGGER` | Создание триггеров |
| `CREATE TYPE` | Создание пользовательских типов |
| `CREATE SYNONYM` | Создание синонимов |
| `CREATE DATABASE LINK` | Создание ссылок на другие БД |
| `ALTER SESSION` | Изменение параметров сессии |
| `ALTER SYSTEM` | Изменение системных параметров |
| `ALTER ANY TABLE` | Изменение любой таблицы |
| `DROP ANY TABLE` | Удаление любой таблицы |
| `SELECT ANY TABLE` | Выборка из любой таблицы |
| `INSERT ANY TABLE` | Вставка в любую таблицу |
| `UPDATE ANY TABLE` | Обновление любой таблицы |
| `DELETE ANY TABLE` | Удаление из любой таблицы |
| `EXECUTE ANY PROCEDURE` | Выполнение любой процедуры |
| `CREATE USER` | Создание пользователей |
| `ALTER USER` | Изменение пользователей |
| `DROP USER` | Удаление пользователей |
| `CREATE ROLE` | Создание ролей |
| `DROP ROLE` | Удаление ролей |
| `GRANT ANY PRIVILEGE` | Предоставление любых привилегий |
| `GRANT ANY ROLE` | Предоставление любых ролей |
| `AUDIT SYSTEM` | Включение системного аудита |
| `BACKUP ANY TABLE` | Экспорт любой таблицы |

### Таблица объектных привилегий

| Объект | Доступные привилегии |
|--------|---------------------|
| **Таблица** | `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `ALTER`, `INDEX`, `REFERENCES` |
| **Представление** | `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `REFERENCES` |
| **Последовательность** | `SELECT`, `ALTER` |
| **Процедура** | `EXECUTE`, `DEBUG` |
| **Функция** | `EXECUTE`, `DEBUG` |
| **Пакет** | `EXECUTE`, `DEBUG` |
| **Тип** | `EXECUTE` |
| **Синоним** | `SELECT` (для синонима таблицы) |
| **Directory** | `READ`, `WRITE` |
| **Mview** | `SELECT` |

### Список предопределённых ролей

| Роль | Назначение |
|------|-----------|
| `DBA` | Все системные привилегии |
| `CONNECT` | Базовые привилегии подключения |
| `RESOURCE` | Привилегии для разработки |
| `SELECT_CATALOG_ROLE` | Доступ к словарю данных |
| `EXECUTE_CATALOG_ROLE` | Выполнение пакетов словаря |
| `DELETE_CATALOG_ROLE` | Управление аудитом |
| `GATHER_SYSTEM_STATISTICS` | Сбор статистики |
| `SCHEDULER_ADMIN` | Управление планировщиком |
| `IMP_FULL_DATABASE` | Полный импорт |
| `EXP_FULL_DATABASE` | Полный экспорт |
| `AUDIT_ADMIN` | Администрирование аудита |
| `AUDIT_VIEWER` | Просмотр аудита |
| `DATAPUMP_EXP_FULL_DATABASE` | Data Pump экспорт |
| `DATAPUMP_IMP_FULL_DATABASE` | Data Pump импорт |

### Шпаргалка: полезные SQL-запросы для аудита

```sql
-- 1. Все привилегии пользователя
SELECT 'SYS' as type, privilege as detail FROM dba_sys_privs WHERE grantee = '&USER'
UNION ALL
SELECT 'ROLE', granted_role FROM dba_role_privs WHERE grantee = '&USER'
UNION ALL
SELECT 'OBJ: ' || privilege, owner || '.' || table_name FROM dba_tab_privs WHERE grantee = '&USER';

-- 2. Кто имеет доступ к таблице
SELECT grantee, privilege, grantable FROM dba_tab_privs 
WHERE owner = '&OWNER' AND table_name = '&TABLE';

-- 3. Пользователи с привилегией DBA
SELECT grantee FROM dba_sys_privs WHERE privilege = 'DBA';

-- 4. Все роли и их привилегии
SELECT r.role, s.privilege as sys_priv, t.privilege as obj_priv
FROM dba_roles r
LEFT JOIN dba_sys_privs s ON r.role = s.grantee
LEFT JOIN dba_tab_privs t ON r.role = t.grantee;

-- 5. Просмотр кода пакета
SELECT text FROM dba_source WHERE name = '&PACKAGE' AND type = 'PACKAGE' ORDER BY line;

-- 6. Активные роли сессии
SELECT * FROM session_roles;

-- 7. Иерархия ролей
SELECT grantee, granted_role FROM dba_role_privs 
WHERE grantee IN (SELECT role FROM dba_roles);

-- 8. Пользователи с истёкшим паролем
SELECT username, expiry_date FROM dba_users WHERE expiry_date < SYSDATE;

-- 9. Квоты пользователей
SELECT username, tablespace_name, bytes/1024/1024 as used_mb, max_bytes/1024/1024 as quota_mb 
FROM dba_ts_quotas;

-- 10. Параметры профиля пользователя
SELECT p.resource_name, p.limit, p.resource_type
FROM dba_users u
JOIN dba_profiles p ON u.profile = p.profile
WHERE u.username = '&USER';
```

---

## См. также

- [[oracle-security-audit|Аудит безопасности в Oracle]]
- [[oracle-multitenant-security|Безопасность в Multitenant]]
- [[oracle-vpd|Virtual Private Database (VPD)]]
- [[oracle-label-security|Oracle Label Security]]

---

*Последнее обновление: {{date}}*
*Теги: #oracle #security #users #roles #privileges #dbms*
