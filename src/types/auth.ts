export interface Session {
  user: {
    id: string
    telegramId: number
    username: string | null
    firstName: string
    lastName: string | null
    photoUrl: string | null
  }
}

export interface AuthState {
  isAuthenticated: boolean
  user: Session['user'] | null
  loading: boolean
}

export interface TelegramAuthData {
  id: number
  first_name: string
  last_name?: string
  username?: string
  photo_url?: string
  auth_date: number
  hash: string
}