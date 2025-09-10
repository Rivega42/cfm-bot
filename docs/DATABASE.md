# 🗄️ Database Schema - CFM Bot v4.0

## Обзор

База данных PostgreSQL 15 с 38 таблицами, полностью нормализованная структура.

## Схема базы данных

### 1. Users & Authentication

#### users
```sql
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    username VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    language_code VARCHAR(10) DEFAULT 'ru',
    is_premium BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    is_banned BOOLEAN DEFAULT false,
    ban_reason TEXT,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_telegram ON users(telegram_id);
CREATE INDEX idx_users_active ON users(is_active) WHERE is_active = true;
```

#### auth_tokens
```sql
CREATE TABLE auth_tokens (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL, -- access, refresh
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_auth_tokens_user ON auth_tokens(user_id);
CREATE INDEX idx_auth_tokens_token ON auth_tokens(token);
```

### 2. User Profiles

#### profiles
```sql
CREATE TABLE profiles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255),
    bio TEXT,
    avatar VARCHAR(500),
    location VARCHAR(255),
    timezone VARCHAR(100),
    birth_date DATE,
    gender VARCHAR(50),
    phone VARCHAR(50),
    email VARCHAR(255),
    linkedin_url VARCHAR(500),
    github_url VARCHAR(500),
    website_url VARCHAR(500),
    twitter_url VARCHAR(500),
    is_complete BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_profiles_user ON profiles(user_id);
```

#### user_skills
```sql
CREATE TABLE user_skills (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    skill_id UUID REFERENCES skills(id),
    level VARCHAR(50), -- beginner, intermediate, expert
    years_experience INTEGER,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_skills_user ON user_skills(user_id);
CREATE INDEX idx_user_skills_skill ON user_skills(skill_id);
```

### 3. Professional Information

#### professional_info
```sql
CREATE TABLE professional_info (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    current_role VARCHAR(255),
    company VARCHAR(255),
    industry VARCHAR(255),
    experience_years INTEGER,
    education_level VARCHAR(100),
    university VARCHAR(255),
    specialization VARCHAR(255),
    achievements TEXT[],
    certifications JSONB,
    portfolio_url VARCHAR(500),
    resume_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### startup_preferences
```sql
CREATE TABLE startup_preferences (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    role_seeking VARCHAR(100), -- co-founder, advisor, investor
    commitment_level VARCHAR(50), -- full-time, part-time, advisory
    equity_expectation VARCHAR(100),
    investment_capacity VARCHAR(100),
    preferred_industries TEXT[],
    preferred_stages TEXT[], -- idea, mvp, growth, scale
    availability_hours INTEGER,
    ready_to_start VARCHAR(50), -- immediately, 1month, 3months
    relocation_willing BOOLEAN DEFAULT false,
    remote_only BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. Questions & Answers

#### questions
```sql
CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    category VARCHAR(100),
    question_key VARCHAR(255) UNIQUE,
    question_text_ru TEXT NOT NULL,
    question_text_en TEXT NOT NULL,
    question_type VARCHAR(50), -- text, select, multiselect, scale, boolean
    options JSONB,
    is_required BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    order_index INTEGER,
    weight DECIMAL(3,2) DEFAULT 1.0,
    validation_rules JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_questions_category ON questions(category);
CREATE INDEX idx_questions_active ON questions(is_active) WHERE is_active = true;
```

#### user_answers
```sql
CREATE TABLE user_answers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    question_id INTEGER REFERENCES questions(id),
    answer_text TEXT,
    answer_value JSONB,
    answer_score DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, question_id)
);

CREATE INDEX idx_user_answers_user ON user_answers(user_id);
```

### 5. Matching System

#### matches
```sql
CREATE TABLE matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
    match_score DECIMAL(5,2),
    match_reasons JSONB,
    status VARCHAR(50) DEFAULT 'pending', -- pending, active, expired, archived
    is_mutual BOOLEAN DEFAULT false,
    chat_id UUID,
    matched_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user1_id, user2_id)
);

CREATE INDEX idx_matches_users ON matches(user1_id, user2_id);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_mutual ON matches(is_mutual) WHERE is_mutual = true;
```

#### user_actions
```sql
CREATE TABLE user_actions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    target_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL, -- like, pass, superlike, block
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, target_user_id)
);

CREATE INDEX idx_user_actions_user ON user_actions(user_id);
CREATE INDEX idx_user_actions_target ON user_actions(target_user_id);
```

### 6. Chat & Messages

#### chats
```sql
CREATE TABLE chats (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    match_id UUID UNIQUE REFERENCES matches(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    last_message_at TIMESTAMP,
    last_message_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chats_match ON chats(match_id);
CREATE INDEX idx_chats_active ON chats(is_active) WHERE is_active = true;
```

#### messages
```sql
CREATE TABLE messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
    text TEXT,
    media_type VARCHAR(50), -- image, video, audio, file
    media_url VARCHAR(500),
    reply_to_id UUID REFERENCES messages(id),
    is_read BOOLEAN DEFAULT false,
    is_edited BOOLEAN DEFAULT false,
    is_deleted BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    edited_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_chat ON messages(chat_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages(sender_id);
```

### 7. Subscriptions & Payments

#### subscription_plans
```sql
CREATE TABLE subscription_plans (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2),
    price_yearly DECIMAL(10,2),
    features JSONB,
    limits JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### user_subscriptions
```sql
CREATE TABLE user_subscriptions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES subscription_plans(id),
    status VARCHAR(50), -- active, cancelled, expired, paused
    billing_period VARCHAR(50), -- monthly, yearly
    current_period_start TIMESTAMP,
    current_period_end TIMESTAMP,
    cancel_at_period_end BOOLEAN DEFAULT false,
    cancelled_at TIMESTAMP,
    trial_end TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscriptions_user ON user_subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON user_subscriptions(status);
```

### 8. Notifications

#### notifications
```sql
CREATE TABLE notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- match_found, message_received, subscription_expiring
    channel VARCHAR(50) DEFAULT 'telegram', -- telegram, email, sms, push
    title VARCHAR(255),
    message TEXT,
    action_url TEXT,
    priority VARCHAR(20) DEFAULT 'normal', -- low, normal, high, urgent
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    is_sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
```

### 9. Analytics

#### user_analytics
```sql
CREATE TABLE user_analytics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    total_swipes INTEGER DEFAULT 0,
    total_likes INTEGER DEFAULT 0,
    total_passes INTEGER DEFAULT 0,
    total_matches INTEGER DEFAULT 0,
    total_messages_sent INTEGER DEFAULT 0,
    total_messages_received INTEGER DEFAULT 0,
    avg_response_time INTEGER, -- in minutes
    profile_views INTEGER DEFAULT 0,
    last_calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_analytics_user ON user_analytics(user_id);
```

## Миграции

### Применение миграций

```bash
# Создать новую миграцию
pnpm prisma migrate dev --name migration_name

# Применить миграции в production
pnpm prisma migrate deploy

# Сброс базы данных (осторожно!)
pnpm prisma migrate reset
```

## Индексы и оптимизация

### Критичные индексы

```sql
-- Для быстрого поиска матчей
CREATE INDEX idx_matches_composite ON matches(user1_id, user2_id, status);

-- Для сообщений в чате
CREATE INDEX idx_messages_chat_date ON messages(chat_id, created_at DESC);

-- Для уведомлений
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = false;

-- Для аналитики
CREATE INDEX idx_user_actions_date ON user_actions(user_id, created_at DESC);
```

### Партиционирование

```sql
-- Партиционирование таблицы messages по месяцам
CREATE TABLE messages_2025_01 PARTITION OF messages
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE messages_2025_02 PARTITION OF messages
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
```

## Backup & Recovery

### Backup стратегия

```bash
# Полный backup
pg_dump -h localhost -U postgres cfm_bot > backup_$(date +%Y%m%d).sql

# Только структура
pg_dump -h localhost -U postgres --schema-only cfm_bot > schema.sql

# Только данные
pg_dump -h localhost -U postgres --data-only cfm_bot > data.sql

# Восстановление
psql -h localhost -U postgres cfm_bot < backup_20250110.sql
```

### Point-in-Time Recovery

```bash
# Включить WAL архивирование
postgresql.conf:
wal_level = replica
archive_mode = on
archive_command = 'cp %p /backup/wal/%f'
```

## Мониторинг

### Полезные запросы

```sql
-- Размер таблиц
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Активные соединения
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    query
FROM pg_stat_activity
WHERE state != 'idle';

-- Медленные запросы
SELECT 
    query,
    calls,
    total_time,
    mean,
    max
FROM pg_stat_statements
ORDER BY mean DESC
LIMIT 10;
```

---

*Последнее обновление: 2025-01-10*
*Версия схемы: 4.0.0*