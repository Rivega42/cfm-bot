# 📚 API Documentation - CFM Bot v4.0

## Обзор

API построен на tRPC v11, обеспечивая type-safe взаимодействие между клиентом и сервером.

## Base URL

```
Production: https://api.cfmbot.com/trpc
Staging: https://staging-api.cfmbot.com/trpc
Local: http://localhost:3000/api/trpc
```

## Authentication

### Telegram InitData

```typescript
// Вход через Telegram
const { data } = await trpc.auth.telegram.mutate({
  initData: window.Telegram.WebApp.initData
});

// Response
{
  user: User;
  token: string;
  refreshToken: string;
}
```

### JWT Token

Все защищенные endpoints требуют Bearer token:

```typescript
headers: {
  'Authorization': 'Bearer YOUR_JWT_TOKEN'
}
```

## API Endpoints

### Authentication

#### `auth.telegram`
```typescript
// Вход через Telegram
trpc.auth.telegram.mutate({
  initData: string
}): Promise<{
  user: User;
  token: string;
  refreshToken: string;
}>
```

#### `auth.refresh`
```typescript
// Обновление токена
trpc.auth.refresh.mutate({
  refreshToken: string
}): Promise<{
  token: string;
  refreshToken: string;
}>
```

#### `auth.logout`
```typescript
// Выход
trpc.auth.logout.mutate(): Promise<void>
```

### Users

#### `users.me`
```typescript
// Получить текущего пользователя
trpc.users.me.query(): Promise<User>
```

#### `users.profile`
```typescript
// Получить профиль
trpc.users.profile.query({
  userId?: string // optional, default: current user
}): Promise<Profile>
```

#### `users.updateProfile`
```typescript
// Обновить профиль
trpc.users.updateProfile.mutate({
  name?: string;
  bio?: string;
  skills?: string[];
  experience?: string;
  goals?: string[];
  location?: string;
  availability?: string;
  avatar?: string;
}): Promise<Profile>
```

#### `users.uploadAvatar`
```typescript
// Загрузить аватар
trpc.users.uploadAvatar.mutate({
  file: File
}): Promise<{ url: string }>
```

### Questions & Onboarding

#### `questions.list`
```typescript
// Получить вопросы
trpc.questions.list.query({
  category?: string;
  language?: 'ru' | 'en';
}): Promise<Question[]>
```

#### `questions.answer`
```typescript
// Ответить на вопрос
trpc.questions.answer.mutate({
  questionId: number;
  answer: string | string[] | number;
}): Promise<Answer>
```

#### `questions.progress`
```typescript
// Прогресс onboarding
trpc.questions.progress.query(): Promise<{
  completed: number;
  total: number;
  percentage: number;
}>
```

### Matching

#### `matching.candidates`
```typescript
// Получить кандидатов для матчинга
trpc.matching.candidates.query({
  limit?: number; // default: 10
  offset?: number;
}): Promise<{
  candidates: MatchCandidate[];
  hasMore: boolean;
}>
```

#### `matching.action`
```typescript
// Like или Pass
trpc.matching.action.mutate({
  targetUserId: string;
  action: 'like' | 'pass';
}): Promise<{
  match: boolean; // true если mutual match
  matchId?: string;
}>
```

#### `matching.matches`
```typescript
// Получить matches
trpc.matching.matches.query({
  status?: 'active' | 'archived';
  limit?: number;
  offset?: number;
}): Promise<{
  matches: Match[];
  total: number;
}>
```

### Chat

#### `chat.list`
```typescript
// Список чатов
trpc.chat.list.query({
  limit?: number;
  offset?: number;
}): Promise<{
  chats: Chat[];
  total: number;
}>
```

#### `chat.messages`
```typescript
// Сообщения в чате
trpc.chat.messages.query({
  chatId: string;
  limit?: number;
  before?: Date;
}): Promise<{
  messages: Message[];
  hasMore: boolean;
}>
```

#### `chat.send`
```typescript
// Отправить сообщение
trpc.chat.send.mutate({
  chatId: string;
  text?: string;
  media?: {
    type: 'image' | 'video' | 'file';
    url: string;
  };
}): Promise<Message>
```

#### `chat.markRead`
```typescript
// Отметить как прочитанное
trpc.chat.markRead.mutate({
  chatId: string;
  messageId?: string; // до какого сообщения
}): Promise<void>
```

### Notifications

#### `notifications.list`
```typescript
// Список уведомлений
trpc.notifications.list.query({
  unreadOnly?: boolean;
  limit?: number;
}): Promise<Notification[]>
```

#### `notifications.markRead`
```typescript
// Отметить прочитанным
trpc.notifications.markRead.mutate({
  notificationId: string | 'all';
}): Promise<void>
```

#### `notifications.settings`
```typescript
// Настройки уведомлений
trpc.notifications.settings.query(): Promise<NotificationSettings>

trpc.notifications.updateSettings.mutate({
  matches?: boolean;
  messages?: boolean;
  reminders?: boolean;
  marketing?: boolean;
}): Promise<NotificationSettings>
```

### Subscriptions

#### `subscriptions.current`
```typescript
// Текущая подписка
trpc.subscriptions.current.query(): Promise<Subscription | null>
```

#### `subscriptions.plans`
```typescript
// Доступные планы
trpc.subscriptions.plans.query(): Promise<Plan[]>
```

#### `subscriptions.subscribe`
```typescript
// Оформить подписку
trpc.subscriptions.subscribe.mutate({
  planId: string;
  paymentMethod: 'card' | 'crypto';
}): Promise<{
  paymentUrl: string;
  sessionId: string;
}>
```

#### `subscriptions.cancel`
```typescript
// Отменить подписку
trpc.subscriptions.cancel.mutate(): Promise<void>
```

### Analytics

#### `analytics.stats`
```typescript
// Статистика пользователя
trpc.analytics.stats.query(): Promise<{
  totalMatches: number;
  totalMessages: number;
  responseRate: number;
  avgResponseTime: number;
  profileViews: number;
}>
```

## WebSocket Events

### Подключение

```typescript
import { createWSClient } from '@trpc/client';

const wsClient = createWSClient({
  url: 'wss://api.cfmbot.com',
});
```

### События

```typescript
// Новый match
wsClient.on('match:new', (data: {
  matchId: string;
  user: User;
}) => {
  // Handle new match
});

// Новое сообщение
wsClient.on('message:new', (data: {
  chatId: string;
  message: Message;
}) => {
  // Handle new message
});

// Пользователь печатает
wsClient.on('user:typing', (data: {
  chatId: string;
  userId: string;
  isTyping: boolean;
}) => {
  // Handle typing indicator
});

// Пользователь онлайн
wsClient.on('user:online', (data: {
  userId: string;
  isOnline: boolean;
}) => {
  // Handle online status
});
```

## Типы данных

### User
```typescript
interface User {
  id: string;
  telegramId: string;
  username?: string;
  firstName: string;
  lastName?: string;
  languageCode: string;
  isPremium: boolean;
  createdAt: Date;
  updatedAt: Date;
}
```

### Profile
```typescript
interface Profile {
  userId: string;
  name: string;
  bio?: string;
  avatar?: string;
  skills: string[];
  experience: string;
  goals: string[];
  location?: string;
  availability: string;
  linkedIn?: string;
  github?: string;
  website?: string;
  isComplete: boolean;
}
```

### Match
```typescript
interface Match {
  id: string;
  user1Id: string;
  user2Id: string;
  score: number;
  status: 'pending' | 'active' | 'archived';
  chatId?: string;
  createdAt: Date;
}
```

### Message
```typescript
interface Message {
  id: string;
  chatId: string;
  senderId: string;
  text?: string;
  media?: {
    type: 'image' | 'video' | 'file';
    url: string;
    thumbnail?: string;
  };
  isRead: boolean;
  isEdited: boolean;
  createdAt: Date;
  updatedAt: Date;
}
```

## Обработка ошибок

### Формат ошибок

```typescript
interface TRPCError {
  code: string;
  message: string;
  details?: any;
}
```

### Коды ошибок

| Code | Description |
|------|-------------|
| UNAUTHORIZED | Требуется авторизация |
| FORBIDDEN | Нет доступа к ресурсу |
| NOT_FOUND | Ресурс не найден |
| BAD_REQUEST | Неверные параметры |
| CONFLICT | Конфликт данных |
| TOO_MANY_REQUESTS | Rate limit превышен |
| INTERNAL_SERVER_ERROR | Внутренняя ошибка |

### Пример обработки

```typescript
try {
  const result = await trpc.users.updateProfile.mutate(data);
} catch (error) {
  if (error.code === 'UNAUTHORIZED') {
    // Redirect to login
  } else if (error.code === 'BAD_REQUEST') {
    // Show validation errors
  } else {
    // Generic error handling
  }
}
```

## Rate Limiting

### Лимиты

| Endpoint | Limit | Window |
|----------|-------|--------|
| auth.* | 10 | 1 час |
| users.updateProfile | 20 | 1 час |
| matching.action | 100 | 1 час |
| chat.send | 60 | 1 минута |
| Default | 100 | 1 минута |

### Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1625097600
```

## Примеры использования

### React + tRPC

```typescript
import { trpc } from '@/lib/trpc';

function ProfilePage() {
  const { data: profile, isLoading } = trpc.users.profile.useQuery();
  
  const updateProfile = trpc.users.updateProfile.useMutation({
    onSuccess: () => {
      toast.success('Профиль обновлен');
    },
  });
  
  if (isLoading) return <Spinner />;
  
  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      updateProfile.mutate(formData);
    }}>
      {/* Form fields */}
    </form>
  );
}
```

### Vanilla JavaScript

```javascript
// Setup
const client = createTRPCProxyClient({
  links: [
    httpBatchLink({
      url: 'http://localhost:3000/api/trpc',
      headers: () => ({
        authorization: `Bearer ${getToken()}`,
      }),
    }),
  ],
});

// Usage
async function loadProfile() {
  try {
    const profile = await client.users.profile.query();
    console.log(profile);
  } catch (error) {
    console.error('Failed to load profile:', error);
  }
}
```

---

*Последнее обновление: 2025-01-10*
*API Version: 4.0.0*