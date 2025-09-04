# 🗜 CFM Bot Database Schema

## Overview

PostgreSQL database with 8 core tables supporting the cofounder matching system.

## Connection Details

```javascript
{
  host: 'localhost',
  port: 5432,
  database: 'cfm_database',
  user: 'cfm_user',
  password: 'secure_password',
  schema: 'public'
}
```

## Table Schemas

### 1. users

**Purpose**: Store user accounts and current state

```sql
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    telegram_username VARCHAR(100),
    full_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    state VARCHAR(50) DEFAULT 'new',
    profile_completed BOOLEAN DEFAULT false,
    onboarding_step INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_users_telegram_id ON users(telegram_id);
CREATE INDEX idx_users_state ON users(state);
```

### 2. questions

**Purpose**: Question bank with 40+ questions

```sql
CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    batch_number INTEGER NOT NULL,
    order_index INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    question_key VARCHAR(50) UNIQUE,
    answer_type VARCHAR(20) DEFAULT 'choice',
    options JSONB NOT NULL,
    category VARCHAR(50),
    weight DECIMAL(3,2) DEFAULT 1.0,
    is_critical BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_questions_batch ON questions(batch_number);
CREATE INDEX idx_questions_order ON questions(batch_number, order_index);
```

### 3. user_answers

**Purpose**: Store user responses to questions

```sql
CREATE TABLE user_answers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    question_id INTEGER REFERENCES questions(id),
    my_answer INTEGER NOT NULL,
    importance INTEGER DEFAULT 1,
    partner_answer VARCHAR(10) DEFAULT 'any',
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, question_id)
);

CREATE INDEX idx_user_answers_user ON user_answers(user_id);
CREATE INDEX idx_user_answers_question ON user_answers(question_id);
```

### 4. matches

**Purpose**: Store calculated match pairs and scores

```sql
CREATE TABLE matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
    match_score DECIMAL(5,2),
    user1_score DECIMAL(5,2),
    user2_score DECIMAL(5,2),
    status VARCHAR(20) DEFAULT 'pending',
    user1_liked BOOLEAN,
    user2_liked BOOLEAN,
    matched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revealed_at TIMESTAMP,
    UNIQUE(user1_id, user2_id)
);

CREATE INDEX idx_matches_user1 ON matches(user1_id);
CREATE INDEX idx_matches_user2 ON matches(user2_id);
CREATE INDEX idx_matches_score ON matches(match_score DESC);
```

### 5. user_profiles

**Purpose**: Extended user profile information

```sql
CREATE TABLE user_profiles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    bio TEXT,
    location VARCHAR(255),
    skills JSONB DEFAULT '[]',
    experience_years INTEGER,
    looking_for JSONB DEFAULT '[]',
    industries JSONB DEFAULT '[]',
    commitment_level VARCHAR(50),
    linkedin_url VARCHAR(255),
    website_url VARCHAR(255),
    photo_url VARCHAR(500),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_profiles_user ON user_profiles(user_id);
```

### 6. user_sessions

**Purpose**: Track active user sessions

```sql
CREATE TABLE user_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(100) UNIQUE,
    current_step VARCHAR(100) DEFAULT 'main_menu',
    current_question_id INTEGER,
    session_data JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP
);

CREATE INDEX idx_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_sessions_active ON user_sessions(is_active);
```

### 7. user_actions

**Purpose**: Log all user interactions

```sql
CREATE TABLE user_actions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL,
    action_data JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_actions_user ON user_actions(user_id);
CREATE INDEX idx_actions_type ON user_actions(action_type);
CREATE INDEX idx_actions_created ON user_actions(created_at DESC);
```

### 8. question_batches

**Purpose**: Organize questions into batches

```sql
CREATE TABLE question_batches (
    id SERIAL PRIMARY KEY,
    batch_number INTEGER UNIQUE NOT NULL,
    batch_name VARCHAR(100),
    description TEXT,
    min_questions INTEGER DEFAULT 5,
    max_questions INTEGER DEFAULT 10,
    is_required BOOLEAN DEFAULT true,
    order_index INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_batches_number ON question_batches(batch_number);
```

## Functions & Procedures

### Calculate Match Score

```sql
CREATE OR REPLACE FUNCTION calculate_match_score(
    p_user1_id UUID,
    p_user2_id UUID
) RETURNS DECIMAL AS $$
DECLARE
    v_score DECIMAL := 0;
    v_total_weight DECIMAL := 0;
    v_match_count INTEGER := 0;
BEGIN
    SELECT 
        SUM(
            CASE 
                WHEN a1.my_answer = a2.partner_answer 
                  OR a2.partner_answer = 'any' THEN 
                    q.weight * a2.importance
                ELSE 0
            END
        ),
        SUM(q.weight * a2.importance),
        COUNT(*)
    INTO v_score, v_total_weight, v_match_count
    FROM user_answers a1
    JOIN user_answers a2 ON a1.question_id = a2.question_id
    JOIN questions q ON q.id = a1.question_id
    WHERE a1.user_id = p_user1_id 
      AND a2.user_id = p_user2_id;
    
    IF v_total_weight > 0 THEN
        RETURN (v_score / v_total_weight) * 100;
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;
```

### Update Last Active

```sql
CREATE OR REPLACE FUNCTION update_last_active()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users 
    SET last_active = CURRENT_TIMESTAMP 
    WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_activity
AFTER INSERT ON user_actions
FOR EACH ROW
EXECUTE FUNCTION update_last_active();
```

## Views

### Active Users View

```sql
CREATE VIEW v_active_users AS
SELECT 
    u.*,
    up.bio,
    up.location,
    COUNT(DISTINCT ua.id) as answers_count,
    COUNT(DISTINCT m.id) as matches_count
FROM users u
LEFT JOIN user_profiles up ON u.id = up.user_id
LEFT JOIN user_answers ua ON u.id = ua.user_id
LEFT JOIN matches m ON u.id = m.user1_id OR u.id = m.user2_id
WHERE u.last_active > NOW() - INTERVAL '30 days'
GROUP BY u.id, up.bio, up.location;
```

### Match Statistics View

```sql
CREATE VIEW v_match_stats AS
SELECT 
    COUNT(*) as total_matches,
    AVG(match_score) as avg_score,
    COUNT(*) FILTER (WHERE user1_liked = true AND user2_liked = true) as mutual_likes,
    COUNT(*) FILTER (WHERE status = 'revealed') as revealed_matches
FROM matches
WHERE matched_at > NOW() - INTERVAL '30 days';
```

## Sample Data

### Questions (First 5 of 40)

```sql
INSERT INTO questions (batch_number, order_index, question_text, question_key, options, category, weight) VALUES
(1, 1, 'Какова ваша основная роль в команде?', 'team_role', 
 '{"1": "🔧 Технический лидер (CTO)", "2": "💼 Бизнес-развитие (CEO)", "3": "🎨 Продукт и дизайн (CPO)", "4": "📊 Операции и финансы (COO/CFO)"}',
 'role', 2.0),

(1, 2, 'Сколько лет опыта в стартапах?', 'startup_experience',
 '{"1": "0-2 года", "2": "3-5 лет", "3": "5-10 лет", "4": "10+ лет"}',
 'experience', 1.5),

(1, 3, 'Готовность к full-time работе?', 'commitment_level',
 '{"1": "Готов сразу full-time", "2": "Могу начать part-time", "3": "Пока только evenings/weekends", "4": "Нужно время на переход"}',
 'commitment', 1.8),

(1, 4, 'Предпочитаемая индустрия?', 'preferred_industry',
 '{"1": "FinTech", "2": "HealthTech", "3": "EdTech", "4": "B2B SaaS"}',
 'industry', 1.2),

(1, 5, 'Предпочтения по финансированию?', 'funding_preference',
 '{"1": "Bootstrapping", "2": "Ангельские инвестиции", "3": "Венчурный капитал", "4": "Гранты и субсидии"}',
 'funding', 1.3);
```

## Indexes Summary

| Table | Index Count | Purpose |
|-------|-------------|----------|
| users | 2 | Fast lookup by telegram_id and state |
| questions | 2 | Batch and order optimization |
| user_answers | 2 | User and question lookups |
| matches | 3 | User lookups and score sorting |
| user_profiles | 1 | User reference |
| user_sessions | 2 | Active session tracking |
| user_actions | 3 | Activity analysis |
| question_batches | 1 | Batch lookup |

## Performance Optimizations

1. **Connection Pooling**: Max 10 connections
2. **Query Caching**: Enable for read-heavy operations
3. **Partitioning**: Consider for user_actions table at 1M+ rows
4. **Vacuum Schedule**: Daily at 3 AM
5. **Statistics Update**: After bulk inserts

---

**Document Version**: 1.0.0
**Last Updated**: 2025-09-04