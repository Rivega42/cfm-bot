-- Migration: 001_initial_setup.sql
-- Created: 2025-09-04
-- Purpose: Initial database setup for CFM Bot

-- This migration creates the initial database structure
-- Run this after creating the database

BEGIN;

-- Check if migration was already applied
CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) UNIQUE NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Check if this migration was already applied
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM migrations WHERE filename = '001_initial_setup.sql') THEN
        RAISE NOTICE 'Migration 001_initial_setup.sql already applied';
    ELSE
        -- Run the main schema creation
        RAISE NOTICE 'Applying migration 001_initial_setup.sql';
        
        -- The actual schema creation is in schema.sql
        -- This migration just tracks that it was applied
        
        -- Record migration
        INSERT INTO migrations (filename) VALUES ('001_initial_setup.sql');
        
        RAISE NOTICE 'Migration 001_initial_setup.sql completed successfully';
    END IF;
END $$;

COMMIT;