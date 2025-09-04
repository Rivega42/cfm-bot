-- CFM Bot Database Schema v3.0
-- PostgreSQL 15+
-- Created: 2025-09-04

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create database
CREATE DATABASE cfm_database
    WITH 
    OWNER = cfm_user
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Connect to database
\c cfm_database;

-- ==========================================
-- CORE TABLES
-- ==========================================

-- 1. Users table
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

-- 2. Questions table
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

-- 3. User Answers table
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

-- 4. Matches table
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

-- 5. User Profiles table
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

-- 6. User Sessions table
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
CREATE INDEX idx_sessions_active ON user_sessions(is_active) WHERE is_active = true;

-- 7. User Actions table
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

-- 8. Question Batches table
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

-- ==========================================
-- FUNCTIONS
-- ==========================================

-- Calculate match score between two users
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
                WHEN a1.my_answer = a2.partner_answer::INTEGER 
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

-- Update last active timestamp
CREATE OR REPLACE FUNCTION update_last_active()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users 
    SET last_active = CURRENT_TIMESTAMP 
    WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TRIGGERS
-- ==========================================

CREATE TRIGGER trigger_update_activity
AFTER INSERT ON user_actions
FOR EACH ROW
EXECUTE FUNCTION update_last_active();

-- ==========================================
-- VIEWS
-- ==========================================

-- Active users view
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

-- Match statistics view
CREATE VIEW v_match_stats AS
SELECT 
    COUNT(*) as total_matches,
    AVG(match_score) as avg_score,
    COUNT(*) FILTER (WHERE user1_liked = true AND user2_liked = true) as mutual_likes,
    COUNT(*) FILTER (WHERE status = 'revealed') as revealed_matches
FROM matches
WHERE matched_at > NOW() - INTERVAL '30 days';

-- ==========================================
-- PERMISSIONS
-- ==========================================

GRANT ALL PRIVILEGES ON DATABASE cfm_database TO cfm_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO cfm_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO cfm_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO cfm_user;