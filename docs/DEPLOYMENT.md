# 🚀 CFM Bot Deployment Guide

## Prerequisites

- [ ] VPS with Ubuntu 22.04+ or similar
- [ ] Domain name (optional, for custom webhook URL)
- [ ] PostgreSQL 15+ installed
- [ ] n8n instance (self-hosted or cloud)
- [ ] Node.js 18+ (if running additional services)
- [ ] Nginx (for reverse proxy)

## Environment Setup

### 1. System Preparation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y git nginx postgresql postgresql-contrib certbot python3-certbot-nginx

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install n8n globally (if self-hosting)
npm install n8n -g
```

### 2. PostgreSQL Setup

```bash
# Switch to postgres user
sudo -u postgres psql

-- Create database and user
CREATE USER cfm_user WITH PASSWORD 'your_secure_password';
CREATE DATABASE cfm_database OWNER cfm_user;
GRANT ALL PRIVILEGES ON DATABASE cfm_database TO cfm_user;
\q

# Configure PostgreSQL for remote connections (if needed)
sudo nano /etc/postgresql/15/main/postgresql.conf
# Set: listen_addresses = '*'

sudo nano /etc/postgresql/15/main/pg_hba.conf
# Add: host all all 0.0.0.0/0 md5

# Restart PostgreSQL
sudo systemctl restart postgresql
```

### 3. Database Migration

```bash
# Clone repository
git clone https://github.com/Rivega42/cfm-bot.git
cd cfm-bot

# Run database setup
psql -U cfm_user -d cfm_database -f database/schema.sql
psql -U cfm_user -d cfm_database -f database/migrations/001_initial_setup.sql
psql -U cfm_user -d cfm_database -f database/seeds/questions.sql
```

## n8n Configuration

### Option A: Self-Hosted n8n

#### 1. Create n8n Service

```bash
# Create n8n user
sudo useradd -m -s /bin/bash n8n

# Create n8n directory
sudo mkdir /home/n8n/.n8n
sudo chown -R n8n:n8n /home/n8n/.n8n

# Create systemd service
sudo nano /etc/systemd/system/n8n.service
```

```ini
[Unit]
Description=n8n - Workflow Automation
After=network.target

[Service]
Type=simple
User=n8n
WorkingDirectory=/home/n8n
ExecStart=/usr/bin/n8n start
Restart=on-failure
RestartSec=5
StartLimitInterval=0
Environment="N8N_BASIC_AUTH_ACTIVE=true"
Environment="N8N_BASIC_AUTH_USER=admin"
Environment="N8N_BASIC_AUTH_PASSWORD=your_password"
Environment="N8N_HOST=0.0.0.0"
Environment="N8N_PORT=5678"
Environment="N8N_WEBHOOK_URL=https://n8n.yourdomain.com"
Environment="N8N_ENCRYPTION_KEY=your_encryption_key"

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start service
sudo systemctl enable n8n
sudo systemctl start n8n
sudo systemctl status n8n
```

#### 2. Configure Nginx Reverse Proxy

```bash
sudo nano /etc/nginx/sites-available/n8n
```

```nginx
server {
    listen 80;
    server_name n8n.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Setup SSL
sudo certbot --nginx -d n8n.yourdomain.com
```

### Option B: n8n Cloud

1. Sign up at [n8n.cloud](https://n8n.cloud)
2. Create new workspace
3. Note your webhook URL format: `https://YOUR_INSTANCE.app.n8n.cloud/webhook/`

## Telegram Bot Setup

### 1. Create Bot with BotFather

```
1. Open Telegram and search for @BotFather
2. Send /newbot
3. Choose bot name: "CFM Bot"
4. Choose username: "CFmatch_bot"
5. Save the token: 6864357679:AAGneJy48H7CfeBpgOSYsWjwIGv4KUNf7x0
```

### 2. Configure Webhook

```bash
# Navigate to project
cd cfm-bot/telegram

# Make script executable
chmod +x setup_webhook.sh

# Run setup (production)
./setup_webhook.sh production

# Or manually set webhook
curl -X POST "https://api.telegram.org/bot6864357679:AAGneJy48H7CfeBpgOSYsWjwIGv4KUNf7x0/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://n8n.yourdomain.com/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db"}'
```

## Import Workflows to n8n

### 1. Access n8n UI
- Open: `https://n8n.yourdomain.com`
- Login with credentials

### 2. Setup Credentials

#### PostgreSQL Credential:
1. Go to Credentials → New
2. Search for "PostgreSQL"
3. Configure:
   - Name: `PostgreSQL CFM`
   - Host: `localhost` or database server IP
   - Database: `cfm_database`
   - User: `cfm_user`
   - Password: `your_password`
   - Port: `5432`
4. Test connection and save

#### Telegram Credential:
1. Go to Credentials → New
2. Search for "Telegram"
3. Configure:
   - Name: `Telegram CFM Bot`
   - Access Token: `6864357679:AAGneJy48H7CfeBpgOSYsWjwIGv4KUNf7x0`
4. Save

### 3. Import Workflows

1. Go to Workflows
2. Click "Add Workflow" → "Import from File"
3. Import each workflow from `cfm-bot/workflows/`
4. For each workflow:
   - Update credentials
   - Update webhook URLs if needed
   - Test execution
   - Activate

## Environment Variables

### Create .env file

```bash
nano /home/n8n/.env
```

```env
# n8n Configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=secure_password
N8N_ENCRYPTION_KEY=random_32_char_string
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_WEBHOOK_URL=https://n8n.yourdomain.com

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cfm_database
DB_USER=cfm_user
DB_PASSWORD=your_password

# Telegram
TELEGRAM_BOT_TOKEN=6864357679:AAGneJy48H7CfeBpgOSYsWjwIGv4KUNf7x0
TELEGRAM_BOT_USERNAME=@CFmatch_bot

# Webhook URLs
MAIN_WEBHOOK=https://n8n.yourdomain.com/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db
```

## Monitoring Setup

### 1. System Monitoring

```bash
# Install monitoring tools
sudo apt install -y htop netdata

# Access netdata at http://your-server:19999
```

### 2. Database Monitoring

```sql
-- Create monitoring queries
CREATE VIEW v_system_stats AS
SELECT 
  (SELECT COUNT(*) FROM users) as total_users,
  (SELECT COUNT(*) FROM users WHERE created_at > NOW() - INTERVAL '24 hours') as new_users_24h,
  (SELECT COUNT(*) FROM user_answers) as total_answers,
  (SELECT COUNT(*) FROM matches) as total_matches,
  (SELECT COUNT(*) FROM user_sessions WHERE is_active = true) as active_sessions;
```

### 3. n8n Monitoring

```bash
# Check workflow executions
curl https://n8n.yourdomain.com/api/v1/executions \
  -H "Authorization: Bearer YOUR_API_KEY"

# Monitor logs
journalctl -u n8n -f
```

## Backup Strategy

### 1. Database Backup

```bash
# Create backup script
nano /home/ubuntu/backup_cfm.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="cfm_database"
DB_USER="cfm_user"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
pg_dump -U $DB_USER -d $DB_NAME > $BACKUP_DIR/cfm_backup_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete

# Upload to S3 (optional)
# aws s3 cp $BACKUP_DIR/cfm_backup_$DATE.sql s3://your-backup-bucket/
```

```bash
# Make executable and add to cron
chmod +x /home/ubuntu/backup_cfm.sh
crontab -e
# Add: 0 3 * * * /home/ubuntu/backup_cfm.sh
```

### 2. n8n Workflow Backup

```bash
# Export all workflows via CLI
n8n export:workflow --all --output=/home/ubuntu/backups/workflows_$(date +%Y%m%d).json
```

## Security Hardening

### 1. Firewall Configuration

```bash
# Setup UFW firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 5432/tcp  # PostgreSQL (only if remote access needed)
sudo ufw enable
```

### 2. Fail2ban Setup

```bash
# Install fail2ban
sudo apt install fail2ban

# Configure for n8n
sudo nano /etc/fail2ban/jail.local
```

```ini
[n8n]
enabled = true
port = 80,443
filter = n8n
logpath = /var/log/nginx/access.log
maxretry = 5
bantime = 3600
```

### 3. SSL/TLS Configuration

```bash
# Strong SSL configuration for Nginx
sudo nano /etc/nginx/snippets/ssl-params.conf
```

```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256;
ssl_prefer_server_ciphers off;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:10m;
ssl_stapling on;
ssl_stapling_verify on;
add_header Strict-Transport-Security "max-age=63072000" always;
```

## Production Checklist

- [ ] Database migrated and seeded
- [ ] n8n installed and configured
- [ ] Workflows imported and tested
- [ ] Telegram webhook configured
- [ ] SSL certificates installed
- [ ] Firewall configured
- [ ] Backups scheduled
- [ ] Monitoring enabled
- [ ] Environment variables set
- [ ] Credentials secured
- [ ] Rate limiting configured
- [ ] Error logging enabled
- [ ] Health checks passing

## Troubleshooting

### Common Issues

1. **Webhook not receiving messages**
   - Check webhook URL is correct
   - Verify SSL certificate is valid
   - Check firewall rules
   - Test with curl

2. **Database connection errors**
   - Verify credentials
   - Check PostgreSQL is running
   - Review pg_hba.conf
   - Check connection pool settings

3. **n8n workflow errors**
   - Check execution logs
   - Verify credentials
   - Test each node individually
   - Check webhook URLs

4. **High memory usage**
   - Limit n8n executions
   - Increase swap space
   - Optimize database queries
   - Add more RAM

### Logs Location

- n8n logs: `journalctl -u n8n`
- PostgreSQL logs: `/var/log/postgresql/`
- Nginx logs: `/var/log/nginx/`
- Application logs: `/home/n8n/.n8n/logs/`

---

**Last Updated**: 2025-09-04
**Version**: 1.0.0
**Support**: Create issue on [GitHub](https://github.com/Rivega42/cfm-bot/issues)