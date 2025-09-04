# 🧪 CFM Bot Testing

## Test Structure

```
tests/
├── unit/           # Unit tests for individual functions
├── integration/    # Integration tests for workflows
├── e2e/           # End-to-end tests with real bot
└── fixtures/      # Test data and mocks
```

## Test Scenarios

### 1. User Registration Tests

#### Test Case: New User Registration
```javascript
// Test: User sends /start for the first time
Input: {
  message: {
    text: "/start",
    from: { id: 123456, username: "testuser" },
    chat: { id: 123456 }
  }
}

Expected:
- User created in database
- Welcome message sent
- First question presented
- Session created
```

#### Test Case: Existing User Returns
```javascript
// Test: Existing user sends /start
Input: {
  message: {
    text: "/start",
    from: { id: 123456 },
    chat: { id: 123456 }
  }
}

Expected:
- User state retrieved
- Continue from last question
- No duplicate user created
```

### 2. Question Flow Tests

#### Test Case: Answer Question
```javascript
// Test: User clicks answer button
Input: {
  callback_query: {
    data: "answer_1_3",
    from: { id: 123456 },
    message: { chat: { id: 123456 } }
  }
}

Expected:
- Answer saved to database
- Callback acknowledged
- Next question loaded
```

#### Test Case: Skip Question
```javascript
// Test: User skips question
Input: {
  callback_query: {
    data: "skip_1",
    from: { id: 123456 }
  }
}

Expected:
- No answer saved
- Next question presented
- Progress updated
```

### 3. Matching Tests

#### Test Case: Calculate Match Score
```sql
-- Test data setup
INSERT INTO users (telegram_id) VALUES (111), (222);
INSERT INTO user_answers (user_id, question_id, my_answer, importance, partner_answer)
VALUES 
  (1, 1, 2, 3, '2'),  -- Perfect match
  (1, 2, 1, 2, 'any'), -- Any answer accepted
  (2, 1, 2, 3, '2'),
  (2, 2, 3, 2, '1');

-- Expected match score: ~75%
```

### 4. Database Tests

#### Test: Concurrent User Sessions
```javascript
// Test multiple users answering simultaneously
const users = [123, 456, 789];
const promises = users.map(userId => 
  simulateUserAnswer(userId, questionId, answer)
);

await Promise.all(promises);
// Verify all answers saved correctly
```

## Manual Testing Checklist

### Bot Commands
- [ ] `/start` - Creates new user or continues session
- [ ] `/profile` - Shows user profile and progress
- [ ] `/matches` - Displays available matches
- [ ] `/help` - Shows help message
- [ ] `/restart` - Resets user progress

### Inline Keyboards
- [ ] Question answer buttons work
- [ ] Skip button works
- [ ] Importance rating buttons work
- [ ] Match like/skip buttons work
- [ ] Navigation buttons work

### Database Operations
- [ ] User creation
- [ ] Answer storage
- [ ] Session management
- [ ] Match calculation
- [ ] Duplicate prevention

### Error Handling
- [ ] Invalid callback data
- [ ] Database connection loss
- [ ] Telegram API errors
- [ ] Timeout handling
- [ ] Rate limiting

## Automated Testing Setup

### Install Dependencies
```bash
npm install --save-dev jest @types/jest
npm install --save-dev supertest
npm install --save-dev @faker-js/faker
```

### Run Tests
```bash
# Run all tests
npm test

# Run specific test suite
npm test -- user-registration

# Run with coverage
npm test -- --coverage

# Watch mode
npm test -- --watch
```

## Test Database Setup

```sql
-- Create test database
CREATE DATABASE cfm_test;

-- Run migrations
\c cfm_test;
\i database/schema.sql;
\i database/seeds/test_data.sql;
```

## Performance Testing

### Load Testing with Artillery
```yaml
# artillery.yml
config:
  target: "https://n8n.1int.tech"
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Warm up"
    - duration: 120
      arrivalRate: 50
      name: "Load test"

scenarios:
  - name: "User Registration Flow"
    flow:
      - post:
          url: "/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db"
          json:
            message:
              text: "/start"
              from:
                id: "{{ $randomNumber() }}"
              chat:
                id: "{{ $randomNumber() }}"
```

## Debugging

### Enable Debug Logging
```javascript
// In Code nodes
console.log('Debug:', JSON.stringify($json, null, 2));
```

### Common Issues

1. **Callback not working**
   - Check `callback_query` in Telegram Trigger
   - Verify callback_data format
   - Check answerCallbackQuery response

2. **Database errors**
   - Check connection credentials
   - Verify table structures
   - Check for unique constraints

3. **Keyboard not showing**
   - Use HTTP Request instead of Telegram node
   - Verify reply_markup structure
   - Check parse_mode compatibility

## Test Coverage Goals

- Unit Tests: 80%
- Integration Tests: 70%
- E2E Tests: Critical paths only
- Manual Testing: All user flows

---

**Last Updated**: 2025-09-04
**Test Framework**: Jest + Manual Testing