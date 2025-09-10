# 🔄 Migration Guide: n8n v3 to Next.js v4

## Overview

This guide provides step-by-step instructions for migrating from the n8n-based CFM Bot v3 to the new Next.js-based v4 architecture.

## Migration Timeline

```mermaid
gantt
    title Migration Timeline
    dateFormat  YYYY-MM-DD
    section Phase 1
    Project Setup           :2025-09-10, 2d
    Database Connection     :2d
    Basic API              :3d
    
    section Phase 2
    Authentication         :3d
    Questions System       :4d
    User Profiles         :3d
    
    section Phase 3
    Matching Engine        :5d
    Mini App UI           :5d
    WebSocket             :3d
    
    section Phase 4
    Payments              :3d
    Analytics             :3d
    Testing               :4d
    
    section Phase 5
    Production Deploy     :2d
    Monitoring           :2d
    Documentation        :2d
```

## Pre-Migration Checklist

- [ ] Backup current database
- [ ] Document active webhooks
- [ ] Export n8n workflows
- [ ] List environment variables
- [ ] Identify active users
- [ ] Plan downtime window

## Phase 1: Environment Setup

### 1.1 Clone and Setup Repository

```bash
# Clone repository
git clone https://github.com/Rivega42/cfm-bot.git
cd cfm-bot

# Install dependencies
npm install

# Setup environment
cp .env.example .env.local
```

### 1.2 Configure Environment Variables

```env
# Database (same as v3)
DATABASE_URL="postgresql://user:password@localhost:5432/cfm_database"

# Telegram
TELEGRAM_BOT_TOKEN="6864357679:AAGneJy48H7CfeBpgOSYsWjwIGv4KUNf7x0"
TELEGRAM_WEBAPP_URL="https://your-domain.vercel.app/twa"

# Authentication
NEXTAUTH_SECRET="generate-secret-here"
NEXTAUTH_URL="http://localhost:3000"

# Optional: Payments
STRIPE_SECRET_KEY="sk_test_..."
ROBOKASSA_MERCHANT="your_merchant"
```

### 1.3 Database Connection

```bash
# Generate Prisma client
npx prisma generate

# Verify database connection
npx prisma db pull

# Run any new migrations
npx prisma migrate deploy
```

## Phase 2: Data Migration

### 2.1 Database Compatibility

The v4 database schema is fully compatible with v3. No schema changes required.

### 2.2 User Data Migration

```sql
-- Verify user data
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM user_profiles;
SELECT COUNT(*) FROM user_answers;

-- No migration needed - data remains intact
```

### 2.3 Session Migration

```javascript
// Clear old n8n sessions
await prisma.user_sessions.deleteMany({
  where: {
    created_at: {
      lt: new Date()
    }
  }
});
```

## Phase 3: Feature Migration

### 3.1 Authentication

#### Old (n8n):
```javascript
// Webhook node processed Telegram updates
```

#### New (Next.js):
```typescript
// app/api/auth/telegram/route.ts
export async function POST(req: Request) {
  const { initData } = await req.json();
  const user = await validateTelegramAuth(initData);
  const token = await generateJWT(user);
  return Response.json({ token, user });
}
```

### 3.2 Questions System

#### Old (n8n):
```javascript
// Complex workflow with multiple nodes
```

#### New (Next.js):
```typescript
// services/questions.service.ts
export class QuestionsService {
  async getNextQuestion(userId: string) {
    // Direct database query
    return await prisma.question.findFirst({
      // ... logic
    });
  }
}
```

### 3.3 Matching Engine

```typescript
// Port matching algorithm from n8n Code nodes
// to services/matching.service.ts
```

## Phase 4: Webhook Migration

### 4.1 Remove Old Webhook

```bash
# Remove n8n webhook
curl -X POST "https://api.telegram.org/bot${TOKEN}/deleteWebhook"
```

### 4.2 Setup New Webhook (Optional)

For Mini App, webhook is optional. The app communicates via HTTPS.

```bash
# Optional: Setup webhook for bot commands
curl -X POST "https://api.telegram.org/bot${TOKEN}/setWebhook" \
  -d "url=https://your-domain.vercel.app/api/telegram/webhook"
```

## Phase 5: Testing

### 5.1 Unit Tests

```bash
# Run unit tests
npm run test:unit
```

### 5.2 Integration Tests

```bash
# Test database operations
npm run test:integration
```

### 5.3 E2E Tests

```bash
# Test complete user flows
npm run test:e2e
```

## Phase 6: Deployment

### 6.1 Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variables
vercel env add DATABASE_URL
vercel env add TELEGRAM_BOT_TOKEN
# ... add all required env vars
```

### 6.2 Configure Telegram Mini App

1. Open [@BotFather](https://t.me/botfather)
2. Select your bot
3. Bot Settings → Menu Button
4. Set URL: `https://your-domain.vercel.app/twa`

### 6.3 DNS Configuration (if custom domain)

```
Type: CNAME
Name: @
Value: cname.vercel-dns.com
```

## Phase 7: Cutover

### 7.1 Pre-Cutover

1. Final data backup
2. Test all critical paths
3. Prepare rollback plan
4. Notify users (optional)

### 7.2 Cutover Steps

```bash
# 1. Disable n8n workflows
# In n8n UI: Deactivate all CFM workflows

# 2. Clear Redis cache
npm run cache:clear

# 3. Verify new system
curl https://your-domain.vercel.app/api/health

# 4. Update Telegram bot settings
# Set Mini App URL in BotFather
```

### 7.3 Post-Cutover

1. Monitor error logs
2. Check performance metrics
3. Verify user flows
4. Document any issues

## Rollback Procedure

If critical issues arise:

```bash
# 1. Reactivate n8n workflows
# In n8n UI: Activate CFM workflows

# 2. Restore webhook
curl -X POST "https://api.telegram.org/bot${TOKEN}/setWebhook" \
  -d "url=https://n8n.1int.tech/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db"

# 3. Clear Mini App URL
# In BotFather: Remove Menu Button URL

# 4. Investigate issues
# Check logs, fix problems, retry migration
```

## Common Issues & Solutions

### Database Connection Issues

```bash
# Check connection string
npx prisma db push --force-reset

# Verify credentials
psql "$DATABASE_URL" -c "SELECT 1"
```

### Authentication Failures

```typescript
// Verify Telegram hash
console.log('InitData:', initData);
console.log('Validation:', validateTelegramAuth(initData));
```

### Performance Issues

```bash
# Check function logs
vercel logs --follow

# Monitor database
npx prisma studio
```

## Verification Checklist

### Functional Verification

- [ ] User registration works
- [ ] Authentication successful
- [ ] Questions load correctly
- [ ] Answers save properly
- [ ] Matching algorithm runs
- [ ] Notifications sent

### Performance Verification

- [ ] Response time < 100ms
- [ ] No memory leaks
- [ ] Database queries optimized
- [ ] Cache working properly

### Security Verification

- [ ] Telegram auth validated
- [ ] JWT tokens secure
- [ ] API rate limited
- [ ] SQL injection protected

## Support Resources

### Documentation
- [Architecture Guide](../architecture/README.md)
- [API Documentation](../api/README.md)
- [Database Schema](../database/README.md)

### Help Channels
- GitHub Issues: [Report problems](https://github.com/Rivega42/cfm-bot/issues)
- Discussions: [Ask questions](https://github.com/Rivega42/cfm-bot/discussions)

## Success Metrics

Migration is considered successful when:

1. ✅ All users can access the system
2. ✅ Response times < 100ms (p95)
3. ✅ Zero data loss
4. ✅ All critical features working
5. ✅ No security vulnerabilities
6. ✅ Monitoring in place

---

*Last updated: 2025-09-10*
