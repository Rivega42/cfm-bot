# 📚 Руководство по установке CFM Bot

## 📋 Содержание
1. [Требования](#требования)
2. [Подготовка окружения](#подготовка-окружения)
3. [Настройка базы данных](#настройка-базы-данных)
4. [Настройка Telegram бота](#настройка-telegram-бота)
5. [Настройка n8n](#настройка-n8n)
6. [Запуск системы](#запуск-системы)
7. [Проверка работоспособности](#проверка-работоспособности)
8. [Решение проблем](#решение-проблем)

## 🔧 Требования

### Системные требования
- **ОС**: Linux (рекомендуется Ubuntu 20.04+) или macOS
- **RAM**: Минимум 4GB (рекомендуется 8GB)
- **Диск**: Минимум 20GB свободного места
- **CPU**: 2+ ядра

### Программное обеспечение
- **Node.js**: версия 18.0.0 или выше
- **PostgreSQL**: версия 15.0 или выше
- **n8n**: версия 1.108.2
- **Git**: последняя версия
- **Docker** (опционально): для контейнеризации

## 🚀 Подготовка окружения

### 1. Клонирование репозитория
```bash
git clone https://github.com/Rivega42/cfm-bot.git
cd cfm-bot
```

### 2. Установка зависимостей
```bash
# Если используете npm
npm install

# Если используете yarn
yarn install
```

### 3. Создание файла окружения
```bash
cp .env.example .env
```

### 4. Редактирование .env файла
```bash
nano .env
# или
code .env
```

## 💾 Настройка базы данных

### 1. Установка PostgreSQL
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# macOS
brew install postgresql
brew services start postgresql
```

### 2. Создание базы данных
```bash
sudo -u postgres psql
```

```sql
-- Создание пользователя
CREATE USER cfm_user WITH PASSWORD 'ваш_безопасный_пароль';

-- Создание базы данных
CREATE DATABASE cfm_database OWNER cfm_user;

-- Предоставление прав
GRANT ALL PRIVILEGES ON DATABASE cfm_database TO cfm_user;

-- Выход
\q
```

### 3. Применение схемы
```bash
cd database
psql -U cfm_user -d cfm_database -f schema.sql
```

### 4. Загрузка начальных данных
```bash
psql -U cfm_user -d cfm_database -f seeds/questions.sql
```

## 🤖 Настройка Telegram бота

### 1. Создание бота
1. Откройте [@BotFather](https://t.me/botfather) в Telegram
2. Отправьте команду `/newbot`
3. Следуйте инструкциям:
   - Введите имя бота: `CFM Customer Feedback Bot`
   - Введите username: `CFmatch_bot` (или свой уникальный)
4. Сохраните полученный токен

### 2. Настройка команд бота
```bash
# Отправьте BotFather
/setcommands

# Выберите вашего бота и вставьте:
start - Начать опрос
help - Помощь
status - Статус опроса
language - Изменить язык
reset - Начать заново
cancel - Отменить опрос
```

### 3. Добавление токена в .env
```env
TELEGRAM_BOT_TOKEN=ваш_токен_здесь
```

## 🔄 Настройка n8n

### 1. Установка n8n

#### Вариант A: Глобальная установка
```bash
npm install n8n -g
```

#### Вариант B: Docker
```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:1.108.2
```

### 2. Запуск n8n
```bash
# Локально
n8n start --tunnel

# Или с конкретным портом
n8n start --port=5678 --tunnel
```

### 3. Импорт workflows

1. Откройте n8n в браузере: http://localhost:5678
2. Перейдите в "Workflows" → "Import"
3. Импортируйте файлы из папки `/workflows`:
   - `main-router.json`
   - `question-handler.json`
   - `analytics-processor.json`

### 4. Настройка учетных данных

#### PostgreSQL подключение
1. В n8n перейдите в "Credentials" → "New"
2. Выберите "Postgres"
3. Заполните:
   ```
   Host: localhost
   Database: cfm_database
   User: cfm_user
   Password: ваш_пароль
   Port: 5432
   SSL: Disable
   ```

#### Telegram подключение
1. В workflow найдите Telegram ноды
2. Добавьте credentials:
   ```
   Access Token: ваш_telegram_bot_token
   ```

### 5. Настройка Webhook

#### Получение webhook URL
1. В n8n откройте workflow "Main Router"
2. Кликните на "Webhook" ноду
3. Скопируйте Production URL

#### Установка webhook в Telegram
```bash
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d "{
    \"url\": \"https://ваш-n8n-url/webhook/telegram-bot\",
    \"allowed_updates\": [\"message\", \"callback_query\"]
  }"
```

## ▶️ Запуск системы

### 1. Запуск всех сервисов

```bash
# Создайте скрипт запуска
cat > start.sh << 'EOF'
#!/bin/bash

# Запуск PostgreSQL
sudo service postgresql start

# Запуск n8n
n8n start --tunnel &

# Ожидание запуска
sleep 5

echo "✅ Все сервисы запущены!"
echo "📊 n8n доступен по адресу: http://localhost:5678"
echo "🤖 Telegram бот: @CFmatch_bot"
EOF

chmod +x start.sh
./start.sh
```

### 2. Активация workflows

1. Откройте n8n интерфейс
2. Для каждого workflow:
   - Откройте workflow
   - Нажмите "Active" toggle
   - Убедитесь, что статус "Active"

## ✅ Проверка работоспособности

### 1. Проверка базы данных
```bash
psql -U cfm_user -d cfm_database -c "SELECT COUNT(*) FROM questions;"
# Должно вернуть: 40
```

### 2. Проверка webhook
```bash
curl "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getWebhookInfo"
# Должно показать ваш webhook URL
```

### 3. Проверка бота
1. Откройте Telegram
2. Найдите @CFmatch_bot
3. Отправьте `/start`
4. Должно прийти приветственное сообщение

### 4. Проверка n8n
```bash
curl http://localhost:5678/healthz
# Должно вернуть: {"status":"ok"}
```

## 🔧 Решение проблем

### Проблема: База данных не подключается
```bash
# Проверьте статус PostgreSQL
sudo service postgresql status

# Проверьте логи
sudo tail -f /var/log/postgresql/*.log

# Проверьте подключение
psql -U cfm_user -d cfm_database -c "SELECT 1;"
```

### Проблема: Telegram webhook не работает
```bash
# Удалите старый webhook
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/deleteWebhook"

# Установите заново
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/setWebhook" \
  -d "url=https://ваш-url/webhook/telegram-bot"
```

### Проблема: n8n не запускается
```bash
# Проверьте порт
lsof -i :5678

# Убейте процесс если занят
kill -9 $(lsof -t -i:5678)

# Запустите с отладкой
DEBUG=* n8n start
```

### Проблема: Workflow не активируется
1. Проверьте все credentials
2. Проверьте логи в n8n Execution
3. Тестируйте каждую ноду отдельно

## 📝 Дополнительные настройки

### Настройка SSL (для продакшена)
```bash
# Установка Certbot
sudo apt install certbot

# Получение сертификата
sudo certbot certonly --standalone -d ваш-домен.com
```

### Настройка Nginx (reverse proxy)
```nginx
server {
    listen 443 ssl;
    server_name ваш-домен.com;
    
    ssl_certificate /etc/letsencrypt/live/ваш-домен.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ваш-домен.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
    }
}
```

### Настройка мониторинга
```bash
# Установка PM2
npm install pm2 -g

# Запуск n8n через PM2
pm2 start n8n

# Настройка автозапуска
pm2 startup
pm2 save
```

---

**Документация обновлена**: 4 сентября 2025
**Версия**: 1.0.0

💡 **Совет**: Сохраните все пароли и токены в безопасном месте!