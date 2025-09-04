-- ================================================================
-- CFM Bot Database Schema v3.0
-- Complete PostgreSQL Structure for CoFounder Matching System
-- Generated: 2025-09-04
-- ================================================================

-- Create database if not exists
-- CREATE DATABASE cfm_database;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- ================================================================
-- SECTION 1: USERS AND PROFILES
-- ================================================================

-- Drop existing tables if needed (careful in production!)
DROP TABLE IF EXISTS user_sessions CASCADE;
DROP TABLE IF EXISTS bot_state CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS user_actions CASCADE;
DROP TABLE IF EXISTS match_analytics CASCADE;
DROP TABLE IF EXISTS interview_reports CASCADE;
DROP TABLE IF EXISTS category_scores CASCADE;
DROP TABLE IF EXISTS user_addons CASCADE;
DROP TABLE IF EXISTS addon_services CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS user_subscriptions CASCADE;
DROP TABLE IF EXISTS subscription_plans CASCADE;
DROP TABLE IF EXISTS match_interactions CASCADE;
DROP TABLE IF EXISTS matches CASCADE;
DROP TABLE IF EXISTS user_answers CASCADE;
DROP TABLE IF EXISTS interview_answers CASCADE;
DROP TABLE IF EXISTS interview_sessions CASCADE;
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS team_members CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS skill_profiles CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
DROP TABLE IF EXISTS user_types CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1.1 Users (main user table)
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    telegram_username VARCHAR(100),
    full_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    user_type VARCHAR(50) DEFAULT 'founder', -- founder, employee, investor, mentor, hr, candidate
    state VARCHAR(50) DEFAULT 'new',
    role VARCHAR(50) DEFAULT 'user', -- user, admin, moderator
    profile_completed BOOLEAN DEFAULT false,
    onboarding_step INTEGER DEFAULT 0,
    trust_score INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_users_telegram_id ON users(telegram_id);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_users_state ON users(state);
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;

-- 1.2 User Types (detailed user categorization)
CREATE TABLE user_types (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    user_type VARCHAR(50),
    is_looking_for_team BOOLEAN DEFAULT false,
    is_looking_for_cofounders BOOLEAN DEFAULT false,
    is_hiring BOOLEAN DEFAULT false,
    is_looking_for_job BOOLEAN DEFAULT false,
    preferred_team_size INTEGER,
    preferred_roles TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_types_user ON user_types(user_id);
CREATE INDEX idx_user_types_looking ON user_types(is_looking_for_cofounders) WHERE is_looking_for_cofounders = true;

-- 1.3 User Profiles (extended profiles)
CREATE TABLE user_profiles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    bio TEXT,
    location VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    remote_work_preference VARCHAR(50), -- remote, hybrid, office
    skills JSONB DEFAULT '[]',
    interests JSONB DEFAULT '[]',
    experience_years INTEGER,
    looking_for JSONB DEFAULT '[]',
    availability VARCHAR(50), -- full-time, part-time, advisory
    commitment_level VARCHAR(50), -- full-time, part-time, weekends
    equity_expectations VARCHAR(100),
    salary_expectations VARCHAR(100),
    linkedin_url VARCHAR(255),
    website_url VARCHAR(255),
    github_url VARCHAR(255),
    portfolio_url VARCHAR(255),
    completed_batches INTEGER DEFAULT 0,
    profile_vector JSONB,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_profiles_user ON user_profiles(user_id);
CREATE INDEX idx_profiles_location ON user_profiles(city, country);
CREATE INDEX idx_profiles_skills ON user_profiles USING gin(skills);

-- Continue with all other tables as shown in the artifact cfm-schema-v3...