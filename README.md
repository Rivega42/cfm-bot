# 🚀 CFM Bot - CoFounder Matching Platform v4.0

[![Next.js](https://img.shields.io/badge/Next.js-15.0-black)](https://nextjs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)](https://www.typescriptlang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791)](https://postgresql.org)
[![Telegram Mini App](https://img.shields.io/badge/Telegram-Mini%20App-26A5E4)](https://t.me/CFmatch_bot)
[![Project Status](https://img.shields.io/badge/Status-v4.0%20Production-green)](https://github.com/Rivega42/cfm-bot)

> **✅ Статус:** Проект работает на современном стеке Next.js + tRPC + PostgreSQL

## 📋 Содержание

- [О проекте](#о-проекте)
- [Архитектура v4.0](#архитектура-v40)
- [Технологический стек](#технологический-стек)
- [Быстрый старт](#быстрый-старт)
- [Структура проекта](#структура-проекта)
- [API документация](#api-документация)
- [База данных](#база-данных)
- [Telegram Mini App](#telegram-mini-app)
- [Deployment](#deployment)

## 🎯 О проекте

**CFM Bot** - платформа для поиска со-основателей стартапов через Telegram Mini App. Система использует интеллектуальный матчинг на основе навыков, опыта и целей.

### Ключевые функции

- 🔐 **Авторизация через Telegram** - безопасный вход без паролей
- 🎯 **Умный матчинг** - алгоритм подбора со-основателей с 40 критериями
- 💬 **Чат в Telegram** - общение прямо в мессенджере
- 📊 **Аналитика** - статистика и инсайты
- 🌍 **Мультиязычность** - поддержка RU/EN
- 💎 **Премиум функции** - расширенные возможности

## 🏗️ Архитектура v4.0

```mermaid
graph TB
    subgraph "Frontend"
        TMA[Telegram Mini App]
        WEB[Web Dashboard]
    end
    
    subgraph "Backend"
        API[Next.js API Routes]
        TRPC[tRPC Server]
        AUTH[Auth Service]
        MATCH[Matching Engine]
        NOTIFY[Notification Service]
    end
    
    subgraph "Infrastructure"
        DB[(PostgreSQL)]
        REDIS[(Redis)]
        S3[S3 Storage]
        QUEUE[Bull Queue]
    end
    
    subgraph "External"
        TG[Telegram Bot API]
        SMTP[Email Service]
        PAY[Payment Gateway]
    end
    
    TMA -->|WebSocket| API
    WEB -->|HTTPS| API
    API --> TRPC
    TRPC --> AUTH
    TRPC --> MATCH
    TRPC --> NOTIFY
    
    AUTH --> DB
    MATCH --> DB
    MATCH --> REDIS
    NOTIFY --> QUEUE
    
    QUEUE --> TG
    QUEUE --> SMTP
    API --> PAY
```

### Преимущества архитектуры

- ✅ **Type Safety** - полная типизация с TypeScript
- ✅ **Real-time** - WebSocket поддержка
- ✅ **Scalability** - горизонтальное масштабирование
- ✅ **Performance** - кэширование и оптимизация
- ✅ **Developer Experience** - современные инструменты
- ✅ **Testing** - покрытие тестами >80%

## 🛠️ Технологический стек

### Frontend
- **Framework:** Next.js 15.0 (App Router)
- **Language:** TypeScript 5.0
- **Styling:** Tailwind CSS 3.4
- **State:** Zustand + React Query
- **Telegram:** @telegram-apps/sdk
- **UI:** Radix UI + CVA

### Backend
- **Runtime:** Node.js 20 LTS
- **API:** tRPC v11
- **ORM:** Prisma 6.0
- **Auth:** NextAuth.js v5
- **Validation:** Zod
- **Queue:** Bull + Redis
- **Database:** PostgreSQL 15

### Infrastructure
- **Cache:** Redis 7
- **Storage:** S3-compatible
- **Hosting:** Vercel / VPS
- **Monitoring:** Sentry + Grafana
- **CI/CD:** GitHub Actions

## 🚀 Быстрый старт

### Требования

- Node.js 20+
- PostgreSQL 15+
- Redis 7+
- pnpm 9+

### Установка

```bash
# Клонирование репозитория
git clone https://github.com/rivega42/cfm-bot.git
cd cfm-bot

# Установка зависимостей
pnpm install

# Настройка переменных окружения
cp .env.example .env.local
# Отредактируйте .env.local с вашими настройками

# Инициализация базы данных
pnpm db:push
pnpm db:seed

# Запуск в режиме разработки
pnpm dev
```

### Переменные окружения

```env
# Database
DATABASE_URL="postgresql://n8n:l0d2EuhCrwMb@31.207.75.253:5432/cofoundermatch_1"

# Redis
REDIS_URL="redis://localhost:6379"

# Telegram
TELEGRAM_BOT_TOKEN="your_bot_token"
TELEGRAM_WEBHOOK_SECRET="your_webhook_secret"
TELEGRAM_BOT_USERNAME="CFmatch_bot"

# NextAuth
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your_secret_key"

# S3 Storage
S3_ENDPOINT="your_s3_endpoint"
S3_ACCESS_KEY="your_access_key"
S3_SECRET_KEY="your_secret_key"
S3_BUCKET="cfm-bot"

# Monitoring
SENTRY_DSN="your_sentry_dsn"
```

## 📁 Структура проекта

```
cfm-bot/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── api/                # API Routes
│   │   ├── auth/               # Auth pages
│   │   ├── dashboard/          # Dashboard pages
│   │   └── telegram/           # Telegram Mini App
│   ├── server/                 # Backend logic
│   │   ├── api/               # tRPC routers
│   │   ├── auth/              # Auth config
│   │   ├── db/                # Database client
│   │   └── services/          # Business logic
│   ├── lib/                   # Shared utilities
│   ├── components/            # React components
│   └── styles/               # Global styles
├── prisma/                    # Database schema
├── public/                   # Static assets
├── tests/                    # Test files
├── docs/                     # Documentation
└── scripts/                  # Utility scripts
```

## 📚 API документация

### Основные endpoints

#### Authentication
```typescript
// Вход через Telegram
POST /api/auth/telegram
Body: { initData: string }

// Обновление профиля
PATCH /api/users/profile
Body: { name?, skills?, bio?, ... }
```

#### Matching
```typescript
// Получить матчи
GET /api/matches
Query: { limit?, offset?, filters? }

// Отправить like/pass
POST /api/matches/:userId/action
Body: { action: 'like' | 'pass' }
```

#### Messages
```typescript
// Получить чаты
GET /api/chats

// Отправить сообщение
POST /api/chats/:chatId/messages
Body: { text: string }
```

#### Questions (40 критериев матчинга)
```typescript
// Получить вопросы анкеты
GET /api/questions

// Сохранить ответы
POST /api/users/answers
Body: { answers: Record<string, any> }
```

Полная документация API: [/docs/API.md](/docs/API.md)

## 💾 База данных

### Текущее подключение
- **Host:** 31.207.75.253
- **Database:** cofoundermatch_1
- **User:** n8n
- **Password:** l0d2EuhCrwMb
- **Port:** 5432

### Основные таблицы

- **users** - профили пользователей
- **profiles** - расширенная информация
- **questions** - 40 вопросов анкеты
- **user_answers** - ответы пользователей
- **matches** - связи между пользователей
- **messages** - сообщения в чатах
- **subscriptions** - премиум подписки
- **notifications** - уведомления

Полная схема: [/docs/DATABASE.md](/docs/DATABASE.md)

### Миграции

```bash
# Создать новую миграцию
pnpm db:migrate:dev

# Применить миграции
pnpm db:migrate

# Откатить миграцию
pnpm db:migrate:reset
```

## 📱 Telegram Mini App

### Инициализация

```typescript
import { initMiniApp } from '@telegram-apps/sdk'

const miniApp = initMiniApp()
miniApp.ready()

// Получить данные пользователя
const initData = miniApp.initDataUnsafe
```

### Навигация

```typescript
// Показать кнопку "Назад"
miniApp.BackButton.show()

// Открыть ссылку
miniApp.openLink('https://example.com')

// Закрыть приложение
miniApp.close()
```

### Темизация

```css
:root {
  --tg-theme-bg-color: var(--tg-theme-bg-color);
  --tg-theme-text-color: var(--tg-theme-text-color);
  --tg-theme-hint-color: var(--tg-theme-hint-color);
  --tg-theme-link-color: var(--tg-theme-link-color);
  --tg-theme-button-color: var(--tg-theme-button-color);
  --tg-theme-button-text-color: var(--tg-theme-button-text-color);
}
```

## 🚢 Deployment

### Vercel (рекомендуется)

1. Подключите репозиторий к Vercel
2. Настройте переменные окружения
3. Deploy!

### VPS

```bash
# Build проекта
pnpm build

# Запуск через PM2
pm2 start ecosystem.config.js

# Настройка Nginx
sudo nginx -t
sudo systemctl reload nginx
```

Подробная инструкция: [/docs/DEPLOYMENT.md](/docs/DEPLOYMENT.md)

## 📊 Статус проекта

### Completed ✅
- Структура базы данных (v3.0)
- 40 вопросов анкеты загружены
- Архитектура приложения
- Базовая настройка проекта
- Telegram Bot (@CFmatch_bot)

### In Progress 🚧
- API endpoints (40%)
- Telegram Mini App UI (25%)
- Matching алгоритм (30%)
- Интеграция с существующей БД (50%)
- Тестирование (10%)

### Planned 📅
- Payment интеграция
- Email уведомления
- Расширенная аналитика
- Admin панель
- ML-оптимизация матчинга

## 🤝 Контрибьютинг

1. Fork репозитория
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменения (`git commit -m 'Add AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

## 📝 Лицензия

MIT License - см. [LICENSE](LICENSE) файл

## 📞 Контакты

- Telegram Bot: [@CFmatch_bot](https://t.me/CFmatch_bot)
- GitHub: [rivega42/cfm-bot](https://github.com/rivega42/cfm-bot)

---

<div align="center">
  <strong>CFM Bot v4.0</strong> - Современная платформа для поиска со-основателей
  <br>
  Built with ❤️ using Next.js, TypeScript, PostgreSQL and Telegram Mini Apps
</div>