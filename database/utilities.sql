-- ================================================
-- DATABASE UTILITIES AND QUERIES
-- ================================================
-- Автор: CFM Bot Team
-- Версия: 1.0.0
-- Обновлено: 2025-09-11
-- ================================================

-- ================================================
-- ИНФОРМАЦИЯ О БАЗЕ ДАННЫХ
-- ================================================

-- Получить имя текущей базы данных
SELECT current_database() AS database_name;

-- Альтернативный способ получить имя БД
SELECT datname FROM pg_database 
WHERE datname = current_database();

-- Получить полную информацию о текущей базе данных
SELECT 
    current_database() AS database_name,
    current_user AS current_user,
    version() AS postgresql_version,
    pg_database_size(current_database()) AS database_size_bytes,
    pg_size_pretty(pg_database_size(current_database())) AS database_size_formatted,
    current_timestamp AS query_time;

-- ================================================
-- ИНФОРМАЦИЯ О СХЕМАХ
-- ================================================

-- Список всех схем в базе данных
SELECT schema_name 
FROM information_schema.schemata
WHERE schema_name NOT IN ('pg_catalog', 'information_schema')
ORDER BY schema_name;

-- ================================================
-- ИНФОРМАЦИЯ О ТАБЛИЦАХ
-- ================================================

-- Список всех таблиц в текущей базе данных
SELECT 
    schemaname AS schema_name,
    tablename AS table_name,
    tableowner AS owner
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename;

-- Подсчет записей в каждой таблице
SELECT 
    schemaname,
    tablename,
    n_live_tup AS row_count,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;

-- ================================================
-- СТАТИСТИКА БАЗЫ ДАННЫХ
-- ================================================

-- Общая статистика по базе данных
SELECT 
    count(DISTINCT schemaname) AS schema_count,
    count(*) AS table_count,
    sum(n_live_tup) AS total_rows,
    pg_size_pretty(sum(pg_total_relation_size(schemaname||'.'||tablename))) AS total_size
FROM pg_stat_user_tables;

-- ================================================
-- АКТИВНЫЕ СОЕДИНЕНИЯ
-- ================================================

-- Показать активные соединения к базе данных
SELECT 
    pid,
    usename AS username,
    application_name,
    client_addr AS client_address,
    state,
    query_start,
    state_change
FROM pg_stat_activity
WHERE datname = current_database()
    AND pid <> pg_backend_pid()
ORDER BY query_start DESC;

-- ================================================
-- ПОЛЕЗНЫЕ ЗАПРОСЫ ДЛЯ CFM BOT
-- ================================================

-- Проверка существования таблиц CFM
SELECT 
    table_name,
    CASE 
        WHEN table_name IN ('users', 'questions', 'answers', 'matches', 'user_sessions') THEN '✅ Существует'
        ELSE '❌ Не найдена'
    END AS status
FROM (
    VALUES 
        ('users'),
        ('questions'),
        ('answers'),
        ('matches'),
        ('user_sessions'),
        ('user_stats'),
        ('question_categories'),
        ('match_feedback'),
        ('bot_analytics'),
        ('system_logs')
) AS required_tables(table_name)
LEFT JOIN information_schema.tables t 
    ON t.table_name = required_tables.table_name 
    AND t.table_schema = 'public'
ORDER BY required_tables.table_name;

-- ================================================
-- АНАЛИЗ СТРУКТУРЫ ТАБЛИЦ CFM
-- ================================================

-- Детальная информация о структуре таблиц CFM
SELECT 
    c.table_name,
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default,
    CASE 
        WHEN pk.column_name IS NOT NULL THEN 'PRIMARY KEY'
        WHEN fk.column_name IS NOT NULL THEN 'FOREIGN KEY'
        WHEN idx.column_name IS NOT NULL THEN 'INDEXED'
        ELSE ''
    END AS key_type
FROM information_schema.columns c
LEFT JOIN (
    SELECT ku.table_name, ku.column_name
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage ku
        ON tc.constraint_name = ku.constraint_name
    WHERE tc.constraint_type = 'PRIMARY KEY'
) pk ON c.table_name = pk.table_name AND c.column_name = pk.column_name
LEFT JOIN (
    SELECT ku.table_name, ku.column_name
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage ku
        ON tc.constraint_name = ku.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY'
) fk ON c.table_name = fk.table_name AND c.column_name = fk.column_name
LEFT JOIN (
    SELECT DISTINCT
        t.relname AS table_name,
        a.attname AS column_name
    FROM pg_class t
    JOIN pg_index ix ON t.oid = ix.indrelid
    JOIN pg_attribute a ON a.attrelid = t.oid
    WHERE a.attnum = ANY(ix.indkey)
) idx ON c.table_name = idx.table_name AND c.column_name = idx.column_name
WHERE c.table_schema = 'public'
    AND c.table_name IN ('users', 'questions', 'answers', 'matches', 'user_sessions')
ORDER BY 
    c.table_name,
    c.ordinal_position;

-- ================================================
-- КОНЕЦ ФАЙЛА
-- ================================================
