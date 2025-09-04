# 🔌 CFM Bot API Documentation

## Overview

CFM Bot uses webhooks and internal APIs for communication between components. This document describes all available endpoints and their usage.

## Base URLs

- **n8n Instance**: `https://n8n.1int.tech`
- **Telegram Bot API**: `https://api.telegram.org/bot{BOT_TOKEN}`

## Webhook Endpoints

### Main Bot Webhook

**Endpoint**: `/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db`

**Method**: `POST`

**Purpose**: Receives all Telegram bot updates

**Request Body**:
```json
{
  "update_id": 123456789,
  "message": {
    "message_id": 1,
    "from": {
      "id": 123456,
      "first_name": "John",
      "username": "johndoe"
    },
    "chat": {
      "id": 123456,
      "type": "private"
    },
    "text": "/start"
  }
}
```

**Response**:
```json
{
  "status": "ok"
}
```

### Question Flow Webhook

**Endpoint**: `/webhook/cfm-question-flow`

**Method**: `POST`

**Purpose**: Handles question presentation logic

**Request Body**:
```json
{
  "user_id": "123456",
  "action": "next_question",
  "current_question_id": 5,
  "answer": {
    "my_answer": 3,
    "importance": 2,
    "partner_answer": "any"
  }
}
```

### Matching Engine Webhook

**Endpoint**: `/webhook/cfm-matching`

**Method**: `POST`

**Purpose**: Triggers matching calculation

**Request Body**:
```json
{
  "user_id": "123456",
  "trigger": "batch_complete",
  "batch_number": 1
}
```

## Telegram Bot API Commands

### Send Message

**Endpoint**: `https://api.telegram.org/bot{BOT_TOKEN}/sendMessage`

**Method**: `POST`

**Request**:
```json
{
  "chat_id": 123456,
  "text": "Hello, World!",
  "parse_mode": "Markdown",
  "reply_markup": {
    "inline_keyboard": [
      [
        {"text": "Option 1", "callback_data": "opt1"},
        {"text": "Option 2", "callback_data": "opt2"}
      ]
    ]
  }
}
```

### Answer Callback Query

**Endpoint**: `https://api.telegram.org/bot{BOT_TOKEN}/answerCallbackQuery`

**Method**: `POST`

**Request**:
```json
{
  "callback_query_id": "query_id_123",
  "text": "Answer selected!",
  "show_alert": false
}
```

### Edit Message

**Endpoint**: `https://api.telegram.org/bot{BOT_TOKEN}/editMessageText`

**Method**: `POST`

**Request**:
```json
{
  "chat_id": 123456,
  "message_id": 789,
  "text": "Updated message",
  "reply_markup": {
    "inline_keyboard": []
  }
}
```

## Database API (via n8n PostgreSQL nodes)

### User Operations

#### Get User
```sql
SELECT * FROM users WHERE telegram_id = $1;
```

#### Create User
```sql
INSERT INTO users (telegram_id, username, full_name, state)
VALUES ($1, $2, $3, 'new')
RETURNING *;
```

#### Update User State
```sql
UPDATE users 
SET state = $1, last_active = NOW()
WHERE telegram_id = $2;
```

### Question Operations

#### Get Next Question
```sql
SELECT q.* FROM questions q
LEFT JOIN user_answers ua ON q.id = ua.question_id 
  AND ua.user_id = $1
WHERE ua.id IS NULL
ORDER BY q.batch_number, q.order_index
LIMIT 1;
```

#### Save Answer
```sql
INSERT INTO user_answers 
  (user_id, question_id, my_answer, importance, partner_answer)
VALUES ($1, $2, $3, $4, $5);
```

### Matching Operations

#### Calculate Match
```sql
WITH user_data AS (
  SELECT * FROM user_answers WHERE user_id = $1
),
potential_matches AS (
  SELECT DISTINCT user_id FROM user_answers 
  WHERE user_id != $1
)
SELECT 
  pm.user_id,
  calculate_match_score($1, pm.user_id) as score
FROM potential_matches pm
ORDER BY score DESC
LIMIT 10;
```

## Internal n8n Communication

### Workflow Triggers

#### Manual Trigger
```json
{
  "endpoint": "/webhook-test/{workflow_id}",
  "method": "POST",
  "body": {
    "trigger_data": "any_json_data"
  }
}
```

#### Execute Workflow
```javascript
// In Code node
const result = await $workflow.execute('workflow_id', {
  input_data: 'value'
});
```

## Error Responses

### Standard Error Format
```json
{
  "error": true,
  "message": "Description of the error",
  "code": "ERROR_CODE",
  "details": {}
}
```

### Error Codes

| Code | Description |
|------|-------------|
| `USER_NOT_FOUND` | User doesn't exist in database |
| `INVALID_STATE` | User in wrong state for action |
| `DATABASE_ERROR` | PostgreSQL query failed |
| `WEBHOOK_ERROR` | Webhook processing failed |
| `TELEGRAM_API_ERROR` | Telegram API call failed |
| `VALIDATION_ERROR` | Input validation failed |
| `RATE_LIMIT` | Too many requests |

## Rate Limiting

- **Telegram API**: 30 messages/second per chat
- **Webhooks**: 100 requests/minute per user
- **Database**: Connection pool limited to 10 connections

## Authentication

All webhook endpoints verify the Telegram user ID from the request matches the database record.

```javascript
// Verification in n8n Code node
const telegramId = $json.message?.from?.id;
const dbUser = await db.query(
  'SELECT * FROM users WHERE telegram_id = $1',
  [telegramId]
);

if (!dbUser) {
  throw new Error('Unauthorized');
}
```

## Data Formats

### User State Enum
```typescript
type UserState = 
  | 'new'
  | 'onboarding'
  | 'answering_questions'
  | 'viewing_matches'
  | 'matched'
  | 'blocked';
```

### Answer Format
```typescript
interface Answer {
  my_answer: 1 | 2 | 3 | 4;
  importance: 0 | 1 | 2 | 3 | 4;
  partner_answer: '1' | '2' | '3' | '4' | 'any';
}
```

### Match Score
```typescript
interface MatchScore {
  user_id: string;
  match_user_id: string;
  score: number; // 0-100
  created_at: Date;
}
```

## Testing Endpoints

### Health Check
**Endpoint**: `/webhook/health`

**Response**:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2025-09-04T12:00:00Z"
}
```

### Test Webhook
**Endpoint**: `/webhook/test`

**Purpose**: Echo back the request for testing

---

**Document Version**: 1.0.0
**Last Updated**: 2025-09-04