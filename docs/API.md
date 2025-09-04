# 📡 CFM Bot API Documentation

## Webhook Endpoints

### Telegram Bot Webhook

**Endpoint**: `POST /webhook/telegram-bot`

**Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "update_id": 123456789,
  "message": {
    "message_id": 1234,
    "from": {
      "id": 987654321,
      "username": "user"
    },
    "chat": {
      "id": 987654321,
      "type": "private"
    },
    "text": "/start"
  }
}
```

**Response**:
```json
{
  "ok": true
}
```

### Callback Query Handler

**Endpoint**: `POST /webhook/callback-query`

**Request Body**:
```json
{
  "update_id": 123456790,
  "callback_query": {
    "id": "callback123",
    "from": {
      "id": 987654321
    },
    "data": "answer_yes"
  }
}
```

## n8n Workflow Triggers

### Main Router
- **ID**: 82NNfa65ImefYweQ
- **URL**: https://n8n.1int.tech/webhook/82NNfa65ImefYweQ

### Question Handler
- **URL**: https://n8n.1int.tech/webhook/question-handler

## Database API

### Get User
```sql
SELECT * FROM users WHERE telegram_id = $1;
```

### Create Session
```sql
INSERT INTO sessions (user_id, status) 
VALUES ($1, 'active') 
RETURNING *;
```

### Store Response
```sql
INSERT INTO responses (session_id, question_id, value) 
VALUES ($1, $2, $3);
```

## Error Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
| 500 | Server Error |

---

API Version: 1.0.0
Last Updated: September 4, 2025