# 🤖 CFM Bot - CoFounder Matching System

[![n8n Version](https://img.shields.io/badge/n8n-1.108.2-blue)](https://n8n.io)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791)](https://postgresql.org)
[![Telegram Bot](https://img.shields.io/badge/Telegram-Bot-26A5E4)](https://t.me/CFmatch_bot)
[![Project Status](https://img.shields.io/badge/Status-MVP%20Development-yellow)](https://github.com/Rivega42/cfm-bot)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## 📋 Project Overview

CFM Bot - комплексная система подбора кофаундеров через Telegram с использованием n8n для автоматизации и PostgreSQL для хранения данных.

### 🎯 Current Progress: **45%**

| Component | Status | Progress |
|-----------|--------|----------|
| Database Setup | ✅ Complete | 100% |
| Main Bot Router | ✅ Complete | 100% |
| User Registration | ⚠️ In Progress | 70% |
| Question Flow | ⚠️ In Progress | 60% |
| Matching Engine | ⏳ Not Started | 0% |
| Match Viewer | ⏳ Not Started | 0% |
| Contact Exchange | ⏳ Not Started | 0% |

## 🏗 Architecture

```
Telegram Bot (@CFmatch_bot)
        ↓
   n8n Webhooks
        ↓
  PostgreSQL DB
        ↓
 Matching Engine
        ↓
   User Matches
```

## 🚀 Quick Start

### Prerequisites

- n8n v1.108.2+
- PostgreSQL 15+
- Telegram Bot Token
- Node.js 18+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Rivega42/cfm-bot.git
cd cfm-bot
```

2. Setup database:
```bash
psql -U postgres -f database/schema.sql
psql -U postgres -f database/migrations/001_initial_setup.sql
psql -U postgres -f database/seeds/questions.sql
```

3. Import n8n workflows:
- Import workflows from `workflows/` folder into your n8n instance
- Configure credentials for PostgreSQL and Telegram

4. Configure Telegram webhook:
```bash
curl -X POST "https://api.telegram.org/bot{BOT_TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://n8n.1int.tech/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db"}'
```

## 📊 Database Structure

8 core tables:
- `users` - User accounts and states
- `questions` - Question bank (40+ questions)
- `user_answers` - User responses
- `matches` - Calculated matches
- `user_profiles` - Extended profiles
- `user_sessions` - Session management
- `user_actions` - Activity tracking
- `question_batches` - Question organization

## 🔧 Configuration

### Environment Variables

```env
TELEGRAM_BOT_TOKEN=6864357679:AAGneJy48H7CfeBpgOSYsWjwIGv4KUNf7x0
N8N_WEBHOOK_URL=https://n8n.1int.tech/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cfm_database
DB_USER=cfm_user
DB_PASSWORD=secure_password
```

## 📦 n8n Workflows

| Workflow ID | Name | Status | Description |
|------------|------|--------|-------------|
| 82NNfa65ImefYweQ | CFM Bot v8 - Main | ✅ Active | Main router and handler |
| CFM.2 | User Registration | ⚠️ Testing | New user onboarding |
| CFM.3 | Question Flow | ⚠️ Testing | Question presentation |
| CFM.4 | Matching Engine | ⏳ Development | Match calculation |
| CFM.5 | Match Viewer | ⏳ Planned | View matches |

## 📝 Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [API Documentation](docs/API.md)
- [Database Schema](docs/DATABASE.md)
- [Workflow Documentation](docs/WORKFLOWS.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

## 🐛 Known Issues

1. **CRITICAL**: Node types need migration from `n8n-nodes-base.` to `nodes-base.`
2. **HIGH**: Inline keyboards not implemented for questions
3. **MEDIUM**: Session timeout not handled

## 🚧 Roadmap

### Phase 1 - MVP (Current)
- [x] Database setup
- [x] Basic bot structure
- [ ] User registration flow
- [ ] Question system
- [ ] Basic matching

### Phase 2 - Enhanced Features
- [ ] Advanced matching algorithm
- [ ] User preferences
- [ ] Notification system
- [ ] Analytics dashboard

### Phase 3 - Scale
- [ ] Multi-language support
- [ ] Web interface
- [ ] Mobile app
- [ ] Premium features

## 📊 Project Statistics

- **Total Commits**: 12
- **Open Issues**: 8
- **Closed Issues**: 3
- **Contributors**: 1
- **Lines of Code**: ~5,000

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Telegram Bot**: @CFmatch_bot
- **Issues**: [GitHub Issues](https://github.com/Rivega42/cfm-bot/issues)
- **Wiki**: [Project Wiki](https://github.com/Rivega42/cfm-bot/wiki)

## 🙏 Acknowledgments

- n8n.io for workflow automation
- Telegram Bot API
- PostgreSQL community

---

**Last Updated**: 2025-09-04
**Version**: 1.0.0-alpha