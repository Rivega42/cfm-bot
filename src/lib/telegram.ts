import crypto from 'crypto'
import { env } from '@/env'

export interface TelegramUser {
  id: number
  is_bot?: boolean
  first_name: string
  last_name?: string
  username?: string
  language_code?: string
  is_premium?: boolean
  photo_url?: string
}

export interface WebAppInitData {
  query_id?: string
  user?: TelegramUser
  receiver?: TelegramUser
  chat?: {
    id: number
    type: string
    title?: string
    username?: string
    photo_url?: string
  }
  chat_type?: string
  chat_instance?: string
  start_param?: string
  can_send_after?: number
  auth_date: number
  hash: string
}

/**
 * Validates Telegram Web App data
 * @param initData - The initData string from Telegram Web App
 * @returns Parsed user data if valid, null otherwise
 */
export async function validateTelegramWebAppData(
  initData: string
): Promise<TelegramUser | null> {
  try {
    const urlParams = new URLSearchParams(initData)
    const hash = urlParams.get('hash')
    urlParams.delete('hash')

    // Create data check string
    const dataCheckString = Array.from(urlParams.entries())
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, value]) => `${key}=${value}`)
      .join('\n')

    // Create secret key
    const secretKey = crypto
      .createHmac('sha256', 'WebAppData')
      .update(env.TELEGRAM_BOT_TOKEN)
      .digest()

    // Calculate hash
    const calculatedHash = crypto
      .createHmac('sha256', secretKey)
      .update(dataCheckString)
      .digest('hex')

    // Verify hash
    if (calculatedHash !== hash) {
      console.error('Invalid Telegram hash')
      return null
    }

    // Check auth date (data is valid for 1 day)
    const authDate = parseInt(urlParams.get('auth_date') || '0')
    if (Date.now() - authDate * 1000 > 86400000) {
      console.error('Telegram auth data expired')
      return null
    }

    // Parse user data
    const userParam = urlParams.get('user')
    if (!userParam) {
      console.error('No user data in Telegram auth')
      return null
    }

    const user = JSON.parse(userParam) as TelegramUser
    return user
  } catch (error) {
    console.error('Error validating Telegram data:', error)
    return null
  }
}

/**
 * Sends a message via Telegram Bot API
 */
export async function sendTelegramMessage(
  chatId: number | string,
  text: string,
  options?: {
    parse_mode?: 'HTML' | 'Markdown' | 'MarkdownV2'
    reply_markup?: any
  }
) {
  const url = `https://api.telegram.org/bot${env.TELEGRAM_BOT_TOKEN}/sendMessage`
  
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      chat_id: chatId,
      text,
      ...options,
    }),
  })

  if (!response.ok) {
    throw new Error(`Failed to send Telegram message: ${response.statusText}`)
  }

  return response.json()
}