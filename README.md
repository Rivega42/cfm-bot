# 🤖 CFM Bot - CoFounder Matching System v3.0

[![n8n Version](https://img.shields.io/badge/n8n-1.108.2-blue)](https://n8n.io)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791)](https://postgresql.org)
[![Telegram Bot](https://img.shields.io/badge/Telegram-Bot-26A5E4)](https://t.me/CFmatch_bot)
[![Project Status](https://img.shields.io/badge/Status-Development%20v3.0-yellow)](https://github.com/Rivega42/cfm-bot)
[![Database](https://img.shields.io/badge/Tables-38-green)](docs/DATABASE.md)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## 📋 Project Overview

CFM Bot v3.0 - комплексная платформа для подбора кофаундеров, команд и проектов с AI-матчингом, системой интервью и монетизацией через подписки.

### 🎯 Current Progress: **55%**

| Component | Status | Progress | v3.0 Features |
|-----------|--------|----------|---------------|
| Database Schema | ✅ Complete | 100% | 38 tables, full migration |
| Documentation | ✅ Complete | 100% | All docs updated to v3.0 |
| Main Bot Router | ⚠️ Active | 90% | Needs node prefix fix |
| User Management | ⚠️ In Progress | 70% | Multi-type users support |
| Question System | ⚠️ In Progress | 60% | 40 questions, 3-stage flow |
| Matching Engine | ⏳ Not Started | 0% | Pairs, teams, projects |
| Interview System | ⏳ Not Started | 0% | HR automation ready |
| Payment System | ⏳ Not Started | 0% | Robokassa integrated |
| Analytics | ⏳ Not Started | 0% | 7 tables ready |

## 🆕 What's New in v3.0

### 🚀 Major Features
- **Multi-type Matching**: Pairs (2), Teams (3-4), Project-Team matching
- **Interview Platform**: Automated HR interviews with AI evaluation
- **Monetization**: Subscription plans with Robokassa payment gateway
- **Team Management**: Create and manage startup teams
- **Project Registry**: Projects seeking cofounders
- **Advanced Analytics**: Comprehensive tracking and reporting

### 💾 Database Expansion
- **38 Tables** (from 8 in v2.0)
- **400+ Columns** total
- **50+ Indexes** for performance
- **5+ Stored Functions**
- **3+ Triggers** for automation
- **2+ Views** for analytics

## 🏗 System Architecture

```
┌─────────────────────────────────────────────────┐
│         Presentation Layer (Multi-channel)       │
│  Telegram Bot │ Web App │ Mobile App (planned)  │
└─────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│        n8n Orchestration (8 Workflows)          │
│  Router │ Registration │ Questions │ Matching   │
│  Payments │ Interviews │ Analytics │ Notifs    │
└─────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│      PostgreSQL Database (38 Tables)            │
│  Users │ Teams │ Matches │ Payments │ Analytics │
└─────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- n8n v1.108.2+
- PostgreSQL 15+
- Node.js 18+
- Telegram Bot Token
- Robokassa Account (for payments)

### Installation

1. **Clone repository:**
```bash
git clone https://github.com/Rivega42/cfm-bot.git
cd cfm-bot
```

2. **Setup database v3.0:**
```bash
# Create database
createdb cfm_database

# Run v3.0 schema
psql -U postgres -d cfm_database -f database/schema_v3.sql

# Or migrate from v2.x
psql -U postgres -d cfm_database -f database/migrations/002_update_to_v3.sql

# Load sample questions
psql -U postgres -d cfm_database -f database/seeds/questions.sql
```

3. **Configure environment:**
```env
# .env file
TELEGRAM_BOT_TOKEN=6864357679:AAGneJy48H7CfeBpgOSYsWjwIGv4KUNf7x0
N8N_WEBHOOK_URL=https://n8n.1int.tech/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cfm_database
DB_USER=cfm_user
DB_PASSWORD=secure_password
ROBOKASSA_MERCHANT=your_merchant_id
ROBOKASSA_PASSWORD1=your_password1
ROBOKASSA_PASSWORD2=your_password2
```

4. **Import n8n workflows:**
- Import workflows from `workflows/` folder
- Configure PostgreSQL credentials in n8n
- Set environment variables
- Activate workflows

5. **Configure Telegram webhook:**
```bash
curl -X POST "https://api.telegram.org/bot{BOT_TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://n8n.1int.tech/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db"}'
```

## 📊 Database Structure v3.0

### Database Categories (38 Tables)

| Category | Tables | Purpose |
|----------|--------|---------|
| **User Management** | 4 | users, profiles, types, skills |
| **Teams & Projects** | 3 | teams, members, projects |
| **Questions & Interviews** | 4 | questions, answers, sessions |
| **Matching** | 2 | matches, interactions |
| **Monetization** | 5 | plans, subscriptions, payments |
| **Bot & Communication** | 3 | sessions, state, notifications |
| **Analytics** | 7 | actions, reports, scores |
| **Additional** | 3 | batches, messages, feedback |

### Key Features
- UUID primary keys for distributed systems
- JSONB fields for flexible data
- Array fields for multi-participant matches
- Full-text search with pg_trgm
- Optimized indexes on all foreign keys
- Stored procedures for complex operations

## 🔧 n8n Workflows

| Workflow | ID | Status | Description |
|----------|-----|--------|-------------|
| CFM.1 Main Router | 82NNfa65ImefYweQ | ✅ Active | Central routing |
| CFM.2 Registration | - | ⏳ Planned | User onboarding |
| CFM.3 Questions | - | ⏳ Planned | 40-question flow |
| CFM.4 Matching | - | ⏳ Planned | AI matching engine |
| CFM.5 Match Viewer | - | ⏳ Planned | Display matches |
| CFM.6 Contact Exchange | - | ⏳ Planned | Share contacts |
| CFM.7 Payments | - | ⏳ Planned | Robokassa handler |
| CFM.8 Analytics | - | ⏳ Planned | Reports generator |

## 📦 API Endpoints

### Telegram Bot
- `/start` - Start registration
- `/profile` - Edit profile
- `/questions` - Answer matching questions
- `/matches` - View your matches
- `/subscribe` - Upgrade subscription
- `/help` - Get help

### Internal APIs
- `GET /api/users/{id}` - Get user profile
- `GET /api/matches/user/{id}` - Get user matches
- `POST /api/questions/answer` - Submit answer
- `POST /api/payments/create` - Create payment
- `GET /api/analytics/report` - Get analytics

## 💳 Subscription Plans

| Plan | Price/Month | Matches | Messages | AI Features |
|------|------------|---------|----------|-------------|
| **Free** | 0₽ | 5 | 10 | ❌ |
| **Pro** | 990₽ | 100 | 1000 | ✅ |
| **Enterprise** | 4990₽ | Unlimited | Unlimited | ✅ |

## 📈 Performance Targets

- **Response Time**: < 100ms
- **Concurrent Users**: 1000+
- **Database Size**: 100MB-1GB
- **Uptime**: 99.9%
- **Match Calculation**: < 500ms

## 🐛 Known Issues

1. **CRITICAL**: Node types need migration from `n8n-nodes-base.` to `nodes-base.`
2. **HIGH**: Inline keyboards not fully implemented
3. **MEDIUM**: Session timeout not handled

## 📝 Documentation

- [Architecture Overview](docs/ARCHITECTURE.md) - System design and components
- [Database Schema](docs/DATABASE.md) - Complete 38-table structure
- [API Documentation](docs/API.md) - All endpoints and functions
- [Workflows Guide](docs/WORKFLOWS.md) - n8n workflow documentation
- [Deployment Guide](docs/DEPLOYMENT.md) - Production setup
- [GitHub Pages](https://cfmatch.com) - Landing page

## 🚧 Development Roadmap

📍 **[View Full Interactive Roadmap →](ROADMAP.md)**  
🌐 **[Live Roadmap Dashboard →](https://cfm.mixbase.ru/roadmap)**

### Phase 1 - Core MVP (Current)
- [x] Database v3.0 schema
- [x] Documentation update
- [ ] Fix n8n node issues
- [ ] Complete question flow
- [ ] Basic matching algorithm

### Phase 2 - Enhanced Features (Q2 2025)
- [ ] Web interface
- [ ] Advanced AI matching
- [ ] Team formation (3-4 people)
- [ ] Project marketplace
- [ ] Interview automation

### Phase 3 - Scale & Monetize (Q3 2025)
- [ ] Mobile app
- [ ] B2B features
- [ ] API for partners
- [ ] White-label solution
- [ ] Analytics dashboard

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📊 Project Statistics

- **Total Commits**: 20+
- **Database Tables**: 38
- **Code Lines**: ~10,000
- **Documentation Pages**: 7
- **Workflows**: 8 planned
- **API Endpoints**: 25+

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Telegram Bot**: [@CFmatch_bot](https://t.me/CFmatch_bot)
- **Issues**: [GitHub Issues](https://github.com/Rivega42/cfm-bot/issues)
- **Wiki**: [Project Wiki](https://github.com/Rivega42/cfm-bot/wiki)
- **Website**: [cfm.mixbase.ru](https://cfm.mixbase.ru)
- **Roadmap**: [Interactive Roadmap](https://cfm.mixbase.ru/roadmap)

## 🙏 Acknowledgments

- n8n.io for workflow automation
- PostgreSQL community
- Telegram Bot API
- Robokassa payment system

## 📊 Migration from v2.x

If upgrading from v2.x:

1. Backup your database
2. Run migration script: `database/migrations/002_update_to_v3.sql`
3. Update n8n workflows to use new tables
4. Test all integrations

---

**Version**: 3.0.0  
**Last Updated**: 2025-01-05  
**Status**: Active Development  
**Next Milestone**: Fix n8n nodes and complete question flow
