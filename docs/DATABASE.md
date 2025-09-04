# 🗄️ CFM Bot Database Schema v3.0

## 📊 Overview

PostgreSQL database with **38+ tables** supporting a complete cofounder matching, team building, and interview platform with monetization capabilities.

### Key Statistics
- **Tables**: 38 core tables
- **Functions**: 5+ stored procedures  
- **Triggers**: 3+ automated triggers
- **Views**: 2+ reporting views
- **Indexes**: 50+ optimized indexes
- **Total Columns**: 400+

## 🔌 Connection Details

```javascript
{
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: 'cfm_database',
  user: 'cfm_user',
  password: process.env.DB_PASSWORD,
  schema: 'public',
  ssl: process.env.NODE_ENV === 'production',
  max: 20, // connection pool size
  idleTimeoutMillis: 30000
}
```

## 📋 Table Structure by Category

### SECTION 1: USER MANAGEMENT

#### 1.1 `users` - Core User Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    telegram_username VARCHAR(100),
    full_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    user_type VARCHAR(50), -- founder, employee, investor, mentor, hr
    state VARCHAR(50) DEFAULT 'new',
    role VARCHAR(50) DEFAULT 'user', -- user, admin, moderator
    profile_completed BOOLEAN DEFAULT false,
    onboarding_step INTEGER DEFAULT 0,
    trust_score INTEGER DEFAULT 0,
    created_at TIMESTAMP,
    last_active TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);
```

Continue with full content as shown in artifact cfm-database-docs-v3...