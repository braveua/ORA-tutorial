import os
from pathlib import Path

import oracledb
from dotenv import load_dotenv

"""
Примечание: Для DIRECTORY используется ALL_DIRECTORIES,
т.к. USER_OBJECTS не содержит этот тип объектов.
Если будут ошибки с правами доступа к directory,
может потребоваться доступ к DBA_DIRECTORIES.
"""

# Загрузка переменных окружения из .env
load_dotenv()

PACKAGES_DIR = Path("PKG")
TABLES_DIR = Path("TABLES")
PROCEDURES_DIR = Path("PROCEDURES")
FUNCTIONS_DIR = Path("FUNCTIONS")
TRIGGERS_DIR = Path("TRIGGERS")
VIEWS_DIR = Path("VIEWS")
INDEXES_DIR = Path("INDEXES")
SEQUENCES_DIR = Path("SEQUENCES")
SYNONYMS_DIR = Path("SYNONYMS")
DIRECTORIES_DIR = Path("DIRECTORIES")
ROLES_DIR = Path("ROLES")
PRIVILEGES_DIR = Path("PRIVILEGES")
USER = os.getenv("DB_USER")
PASSWORD = os.getenv("DB_PASSWORD")
TNS = os.getenv("DB_TNS")

# Создаём директории
PACKAGES_DIR.mkdir(exist_ok=True)
TABLES_DIR.mkdir(exist_ok=True)
PROCEDURES_DIR.mkdir(exist_ok=True)
FUNCTIONS_DIR.mkdir(exist_ok=True)
TRIGGERS_DIR.mkdir(exist_ok=True)
VIEWS_DIR.mkdir(exist_ok=True)
INDEXES_DIR.mkdir(exist_ok=True)
SEQUENCES_DIR.mkdir(exist_ok=True)
SYNONYMS_DIR.mkdir(exist_ok=True)
DIRECTORIES_DIR.mkdir(exist_ok=True)
ROLES_DIR.mkdir(exist_ok=True)
PRIVILEGES_DIR.mkdir(exist_ok=True)

conn = oracledb.connect(user=USER, password=PASSWORD, dsn=TNS)
cursor = conn.cursor()

# ==================== ПАКЕТЫ ====================
cursor.execute("""
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'PACKAGE'
    ORDER BY OBJECT_NAME
""")

packages = cursor.fetchall()

for (package_name,) in packages:
    print(f"Выгрузка пакета: {package_name}")

    # Выгрузка спецификации
    cursor.execute(
        """
        SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', :pkg, USER) FROM DUAL
    """,
        pkg=package_name,
    )
    clob = cursor.fetchone()[0]
    with open(PACKAGES_DIR / f"{package_name}.pks", "w", encoding="utf8") as f:
        f.write(clob.read())

    # Выгрузка тела
    cursor.execute(
        """
        SELECT DBMS_METADATA.GET_DDL('PACKAGE_BODY', :pkg, USER) FROM DUAL
    """,
        pkg=package_name,
    )
    clob = cursor.fetchone()[0]
    with open(PACKAGES_DIR / f"{package_name}.pkb", "w", encoding="utf8") as f:
        f.write(clob.read())

print(f"Готово! Выгружено {len(packages)} пакетов.")

# ==================== ТАБЛИЦЫ ====================
cursor.execute("""
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'TABLE'
    ORDER BY OBJECT_NAME
""")

tables = cursor.fetchall()

for (table_name,) in tables:
    print(f"Выгрузка таблицы: {table_name}")

    cursor.execute(
        """
        SELECT DBMS_METADATA.GET_DDL('TABLE', :tbl, USER) FROM DUAL
    """,
        tbl=table_name,
    )
    clob = cursor.fetchone()[0]
    with open(TABLES_DIR / f"{table_name}.sql", "w", encoding="utf8") as f:
        f.write(clob.read())

print(f"Готово! Выгружено {len(tables)} таблиц.")

# ==================== ПРОЦЕДУРЫ ====================
cursor.execute("""
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'PROCEDURE'
    ORDER BY OBJECT_NAME
""")

procedures = cursor.fetchall()

for (proc_name,) in procedures:
    print(f"Выгрузка процедуры: {proc_name}")

    cursor.execute(
        """
        SELECT DBMS_METADATA.GET_DDL('PROCEDURE', :proc, USER) FROM DUAL
    """,
        proc=proc_name,
    )
    clob = cursor.fetchone()[0]
    with open(PROCEDURES_DIR / f"{proc_name}.sql", "w", encoding="utf8") as f:
        f.write(clob.read())

print(f"Готово! Выгружено {len(procedures)} процедур.")

# ==================== ФУНКЦИИ ====================
cursor.execute("""
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'FUNCTION'
    ORDER BY OBJECT_NAME
""")

functions = cursor.fetchall()

for (func_name,) in functions:
    print(f"Выгрузка функции: {func_name}")

    cursor.execute(
        """
        SELECT DBMS_METADATA.GET_DDL('FUNCTION', :func, USER) FROM DUAL
    """,
        func=func_name,
    )
    clob = cursor.fetchone()[0]
    with open(FUNCTIONS_DIR / f"{func_name}.sql", "w", encoding="utf8") as f:
        f.write(clob.read())

print(f"Готово! Выгружено {len(functions)} функций.")

# ==================== ТРИГГЕРЫ ====================
cursor.execute("""
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'TRIGGER'
    ORDER BY OBJECT_NAME
""")

triggers = cursor.fetchall()

for (trigger_name,) in triggers:
    print(f"Выгрузка триггера: {trigger_name}")

    cursor.execute(
        """
        SELECT DBMS_METADATA.GET_DDL('TRIGGER', :trig, USER) FROM DUAL
    """,
        trig=trigger_name,
    )
    clob = cursor.fetchone()[0]
    with open(TRIGGERS_DIR / f"{trigger_name}.sql", "w", encoding="utf8") as f:
        f.write(clob.read())

print(f"Готово! Выгружено {len(triggers)} триггеров.")

# ==================== ПРЕДСТАВЛЕНИЯ ====================
cursor.execute("""
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'VIEW'
    ORDER BY OBJECT_NAME
""")

views = cursor.fetchall()

for (view_name,) in views:
    print(f"Выгрузка представления: {view_name}")

    cursor.execute(
        """
        SELECT DBMS_METADATA.GET_DDL('VIEW', :v, USER) FROM DUAL
    """,
        v=view_name,
    )
    clob = cursor.fetchone()[0]
    with open(VIEWS_DIR / f"{view_name}.sql", "w", encoding="utf8") as f:
        f.write(clob.read())

print(f"Готово! Выгружено {len(views)} представлений.")

# ==================== ИНДЕКСЫ ====================
cursor.execute("""
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'INDEX'
    ORDER BY OBJECT_NAME
""")

indexes = cursor.fetchall()

for (index_name,) in indexes:
    print(f"Выгрузка индекса: {index_name}")

    cursor.execute(
        """
        SELECT DBMS_METADATA.GET_DDL('INDEX', :idx, USER) FROM DUAL
    """,
        idx=index_name,
    )
    clob = cursor.fetchone()[0]
    with open(INDEXES_DIR / f"{index_name}.sql", "w", encoding="utf8") as f:
        f.write(clob.read())

print(f"Готово! Выгружено {len(indexes)} индексов.")

# ==================== ПОСЛЕДОВАТЕЛЬНОСТИ ====================
cursor.execute("""
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'SEQUENCE'
      AND OBJECT_NAME NOT LIKE 'ISEQ$$_%'
    ORDER BY OBJECT_NAME
""")

sequences = cursor.fetchall()

for (seq_name,) in sequences:
    print(f"Выгрузка последовательности: {seq_name}")

    cursor.execute(
        """
        SELECT DBMS_METADATA.GET_DDL('SEQUENCE', :seq, USER) FROM DUAL
    """,
        seq=seq_name,
    )
    clob = cursor.fetchone()[0]
    with open(SEQUENCES_DIR / f"{seq_name}.sql", "w", encoding="utf8") as f:
        f.write(clob.read())

print(f"Готово! Выгружено {len(sequences)} последовательностей.")

# ==================== СИНОНИМЫ ====================
cursor.execute("""
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'SYNONYM'
    ORDER BY OBJECT_NAME
""")

synonyms = cursor.fetchall()

for (syn_name,) in synonyms:
    print(f"Выгрузка синонима: {syn_name}")

    cursor.execute(
        """
        SELECT DBMS_METADATA.GET_DDL('SYNONYM', :syn, USER) FROM DUAL
    """,
        syn=syn_name,
    )
    clob = cursor.fetchone()[0]
    with open(SYNONYMS_DIR / f"{syn_name}.sql", "w", encoding="utf8") as f:
        f.write(clob.read())

print(f"Готово! Выгружено {len(synonyms)} синонимов.")

# ==================== DIRECTORY ====================
cursor.execute("""
    SELECT DIRECTORY_NAME
    FROM ALL_DIRECTORIES
    ORDER BY DIRECTORY_NAME
""")

directories = cursor.fetchall()

for (dir_name,) in directories:
    print(f"Выгрузка directory: {dir_name}")

    try:
        cursor.execute(
            """
            SELECT DBMS_METADATA.GET_DDL('DIRECTORY', :dir, NULL) FROM DUAL
        """,
            dir=dir_name,
        )
        clob = cursor.fetchone()[0]
        with open(DIRECTORIES_DIR / f"{dir_name}.sql", "w", encoding="utf8") as f:
            f.write(clob.read())
    except oracledb.DatabaseError:
        print(f"  ⚠ Пропущено (нет прав): {dir_name}")

print("Готово! Выгружено directory.")

# ==================== РОЛИ ====================
cursor.execute("""
    SELECT GRANTED_ROLE
    FROM USER_ROLE_PRIVS
    ORDER BY GRANTED_ROLE
""")

roles = cursor.fetchall()

for (role_name,) in roles:
    print(f"Выгрузка роли: {role_name}")

    with open(ROLES_DIR / f"{role_name}.sql", "w", encoding="utf8") as f:
        f.write(f"-- Роль: {role_name}\n\n")
        f.write(f"GRANT {role_name} TO {USER};\n\n")

        # Привилегии роли
        f.write("-- Привилегии роли:\n")
        cursor.execute(
            """
            SELECT PRIVILEGE
            FROM ROLE_SYS_PRIVS
            WHERE ROLE = :role
            ORDER BY PRIVILEGE
        """,
            role=role_name,
        )
        for (priv,) in cursor.fetchall():
            f.write(f"GRANT {priv} TO {role_name};\n")

        # Привилегии на объекты
        cursor.execute(
            """
            SELECT TABLE_NAME, PRIVILEGE, OWNER
            FROM ROLE_TAB_PRIVS
            WHERE ROLE = :role
            ORDER BY TABLE_NAME, PRIVILEGE
        """,
            role=role_name,
        )
        for table_name, priv, owner in cursor.fetchall():
            f.write(f"GRANT {priv} ON {owner}.{table_name} TO {role_name};\n")

print(f"Готово! Выгружено {len(roles)} ролей.")

# ==================== СИСТЕМНЫЕ ПРИВИЛЕГИИ ====================
cursor.execute("""
    SELECT PRIVILEGE
    FROM USER_SYS_PRIVS
    ORDER BY PRIVILEGE
""")

sys_privs = cursor.fetchall()

with open(PRIVILEGES_DIR / "system_privileges.sql", "w", encoding="utf8") as f:
    f.write("-- Системные привилегии\n\n")
    for (priv,) in sys_privs:
        f.write(f"GRANT {priv} TO {USER};\n")

print(f"Готово! Выгружено {len(sys_privs)} системных привилегий.")

# ==================== ПРИВИЛЕГИИ НА ОБЪЕКТЫ ====================
cursor.execute("""
    SELECT TABLE_NAME, PRIVILEGE, OWNER
    FROM USER_TAB_PRIVS
    ORDER BY TABLE_NAME, PRIVILEGE
""")

tab_privs = cursor.fetchall()

with open(PRIVILEGES_DIR / "object_privileges.sql", "w", encoding="utf8") as f:
    f.write("-- Привилегии на объекты\n\n")
    for table_name, priv, owner in tab_privs:
        f.write(f"GRANT {priv} ON {owner}.{table_name} TO {USER};\n")

print(f"Готово! Выгружено {len(tab_privs)} привилегий на объекты.")

cursor.close()
conn.close()
