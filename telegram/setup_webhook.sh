#!/bin/bash

# CFM Bot Webhook Setup Script
# Usage: ./setup_webhook.sh [environment]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default environment
ENV=${1:-production}

echo -e "${GREEN}CFM Bot Webhook Setup${NC}"
echo "Environment: $ENV"
echo "------------------------"

# Load configuration based on environment
if [ "$ENV" = "production" ]; then
    BOT_TOKEN="6864357679:AAGneJy48H7CfeBpgOSYsWjwIGv4KUNf7x0"
    WEBHOOK_URL="https://n8n.1int.tech/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db"
elif [ "$ENV" = "development" ]; then
    BOT_TOKEN="YOUR_DEV_BOT_TOKEN"
    WEBHOOK_URL="https://your-ngrok-url.ngrok.io/webhook/test"
else
    echo -e "${RED}Unknown environment: $ENV${NC}"
    exit 1
fi

API_URL="https://api.telegram.org/bot$BOT_TOKEN"

# Function to make API call
api_call() {
    local method=$1
    local data=$2
    
    if [ -z "$data" ]; then
        curl -s "$API_URL/$method"
    else
        curl -s -X POST "$API_URL/$method" \
            -H "Content-Type: application/json" \
            -d "$data"
    fi
}

# Get current webhook info
echo "Checking current webhook..."
CURRENT=$(api_call "getWebhookInfo")
echo "Current webhook info:"
echo "$CURRENT" | python3 -m json.tool

# Delete existing webhook
echo -e "\n${YELLOW}Deleting existing webhook...${NC}"
DELETE_RESULT=$(api_call "deleteWebhook")
echo "$DELETE_RESULT" | python3 -m json.tool

# Set new webhook
echo -e "\n${GREEN}Setting new webhook...${NC}"
echo "URL: $WEBHOOK_URL"

WEBHOOK_DATA='{
    "url": "'$WEBHOOK_URL'",
    "max_connections": 100,
    "allowed_updates": ["message", "callback_query", "inline_query"]
}'

SET_RESULT=$(api_call "setWebhook" "$WEBHOOK_DATA")
echo "$SET_RESULT" | python3 -m json.tool

# Verify webhook was set
echo -e "\n${GREEN}Verifying webhook...${NC}"
sleep 2
VERIFY=$(api_call "getWebhookInfo")
echo "$VERIFY" | python3 -m json.tool

# Set bot commands
echo -e "\n${GREEN}Setting bot commands...${NC}"
COMMANDS='{
    "commands": [
        {"command": "start", "description": "Начать работу с ботом"},
        {"command": "profile", "description": "Мой профиль и прогресс"},
        {"command": "matches", "description": "Посмотреть матчи"},
        {"command": "help", "description": "Помощь и поддержка"},
        {"command": "settings", "description": "Настройки аккаунта"},
        {"command": "restart", "description": "Начать заново"}
    ]
}'

COMMAND_RESULT=$(api_call "setMyCommands" "$COMMANDS")
echo "$COMMAND_RESULT" | python3 -m json.tool

# Test webhook
echo -e "\n${GREEN}Testing webhook with getMe...${NC}"
TEST=$(api_call "getMe")
echo "$TEST" | python3 -m json.tool

echo -e "\n${GREEN}✅ Webhook setup complete!${NC}"
echo "Bot URL: https://t.me/CFmatch_bot"
echo "Webhook URL: $WEBHOOK_URL"