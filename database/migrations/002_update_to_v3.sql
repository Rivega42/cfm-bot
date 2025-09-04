-- ================================================================
-- CFM Database Migration Script
-- From: v2.x
-- To: v3.0
-- Date: 2025-09-04
-- ================================================================

BEGIN TRANSACTION;

-- ================================================================
-- STEP 1: ADD NEW COLUMNS TO EXISTING TABLES
-- ================================================================

-- Update users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS user_type VARCHAR(50) DEFAULT 'founder',
ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user',
ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS onboarding_step INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS trust_score INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';

-- Update user_profiles table (if exists)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_profiles') THEN
        ALTER TABLE user_profiles
        ADD COLUMN IF NOT EXISTS remote_work_preference VARCHAR(50),
        ADD COLUMN IF NOT EXISTS availability VARCHAR(50),
        ADD COLUMN IF NOT EXISTS commitment_level VARCHAR(50),
        ADD COLUMN IF NOT EXISTS equity_expectations VARCHAR(100),
        ADD COLUMN IF NOT EXISTS salary_expectations VARCHAR(100),
        ADD COLUMN IF NOT EXISTS completed_batches INTEGER DEFAULT 0,
        ADD COLUMN IF NOT EXISTS profile_vector JSONB;
    END IF;
END $$;

-- Continue with all migration steps as shown in artifact cfm-migration-v3...