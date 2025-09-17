# Changelog

Все значимые изменения в проекте CFM Bot документируются здесь.

## [4.0.1] - 2025-09-17

### Fixed
- 🐛 Исправлена проблема отображения главной страницы cfm.mixbase.ru
- 🐛 Разделение CSS стилей в отдельный файл styles.css
- 🐛 Корректная подгрузка стилей через внешний файл
- 📚 Обновлена структура Landing Page для правильного отображения

### Changed
- 🔄 index.html теперь использует внешний CSS файл вместо встроенных стилей
- 🔄 Улучшена производительность загрузки страницы

---

## [4.0.0-alpha] - 2025-01-10

### 🚀 MAJOR: Полная миграция архитектуры

#### Added
- ✨ Новый технологический стек: Next.js 15 + TypeScript + tRPC
- ✨ Telegram Mini App с полноценным UI
- ✨ Type-safe API с tRPC
- ✨ Prisma ORM для работы с БД
- ✨ Redis для кэширования и очередей
- ✨ Bull Queue для фоновых задач
- ✨ Полное покрытие TypeScript
- ✨ Jest + Playwright для тестирования
- ✨ Sentry для мониторинга ошибок

#### Changed
- 🔄 Миграция с n8n на Next.js backend
- 🔄 REST API → tRPC
- 🔄 JavaScript → TypeScript
- 🔄 Webhook-based → WebSocket поддержка
- 🔄 Структура проекта по FSD методологии

#### Deprecated
- ⚠️ n8n workflows перемещены в /archive/n8n
- ⚠️ Старые API endpoints будут удалены в v5.0

#### Migration Notes
- База данных остается совместимой
- Требуется обновление переменных окружения
- Новый процесс deployment через Vercel

---

## [3.0.0] - 2025-01-09 (Legacy)

### Added
- ✅ CFM Unified Database Structure v3.0
- ✅ 38 таблиц в PostgreSQL
- ✅ n8n workflow для Telegram бота
- ✅ Inline keyboards в Telegram
- ✅ Система вопросов и ответов
- ✅ Базовый matching алгоритм

### Fixed
- 🐛 Исправлена структура Switch узла в n8n
- 🐛 Корректная обработка callback_query
- 🐛 Проблемы с Message Router

### Known Issues
- ⚠️ Ограничения n8n для сложной логики
- ⚠️ Сложность отладки workflows
- ⚠️ Отсутствие type safety

---

## [2.0.0] - 2025-01-08 (Legacy)

### Added
- Первая версия n8n workflow
- Базовая интеграция с Telegram Bot API
- PostgreSQL база данных
- Структура таблиц v2.0

### Changed
- Миграция с прототипа на n8n

---

## [1.0.0] - 2025-01-07 (Legacy)

### Added
- Инициализация проекта
- Базовый Telegram бот
- Концепция CoFounder Matching

---

## Версионирование

Проект использует [Semantic Versioning](https://semver.org/):
- MAJOR версия - несовместимые изменения API
- MINOR версия - новая функциональность с обратной совместимостью
- PATCH версия - исправления багов с обратной совместимостью

## Легенда

- ✨ New Feature
- 🔄 Changed
- 🐛 Bug Fix
- ⚠️ Deprecated
- 🗑️ Removed
- 🔒 Security
- 📚 Documentation
- 🚀 Performance
- ✅ Added
- 🚧 Work in Progress