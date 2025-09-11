import { initTRPC, TRPCError } from '@trpc/server'
import { type NextRequest } from 'next/server'
import superjson from 'superjson'
import { ZodError } from 'zod'
import { db } from '@/server/db'
import { validateTelegramWebAppData } from '@/lib/telegram'
import type { Session } from '@/types/auth'

/**
 * 1. CONTEXT
 * This section defines the "contexts" that are available in the backend API.
 */
interface CreateContextOptions {
  session: Session | null
  req?: NextRequest
}

/**
 * This helper generates the "internals" for a tRPC context.
 */
export const createInnerTRPCContext = (opts: CreateContextOptions) => {
  return {
    session: opts.session,
    db,
    req: opts.req,
  }
}

/**
 * This is the actual context you will use in your router.
 */
export const createTRPCContext = async (opts: { req: NextRequest }) => {
  // Get session from Telegram Web App data
  const authHeader = opts.req.headers.get('authorization')
  let session: Session | null = null

  if (authHeader?.startsWith('Bearer ')) {
    const token = authHeader.substring(7)
    try {
      const userData = await validateTelegramWebAppData(token)
      if (userData) {
        session = {
          user: {
            id: userData.id.toString(),
            telegramId: userData.id,
            username: userData.username || null,
            firstName: userData.first_name,
            lastName: userData.last_name || null,
            photoUrl: userData.photo_url || null,
          },
        }
      }
    } catch (error) {
      console.error('Invalid Telegram auth:', error)
    }
  }

  return createInnerTRPCContext({
    session,
    req: opts.req,
  })
}

/**
 * 2. INITIALIZATION
 */
const t = initTRPC.context<typeof createTRPCContext>().create({
  transformer: superjson,
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        zodError:
          error.cause instanceof ZodError ? error.cause.flatten() : null,
      },
    }
  },
})

/**
 * Create a server-side caller.
 */
export const createCallerFactory = t.createCallerFactory

/**
 * 3. ROUTER & PROCEDURE
 */
export const createTRPCRouter = t.router

/**
 * Public (unauthenticated) procedure
 */
export const publicProcedure = t.procedure

/**
 * Protected (authenticated) procedure
 */
export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.session || !ctx.session.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' })
  }
  return next({
    ctx: {
      // infers the `session` as non-nullable
      session: { ...ctx.session, user: ctx.session.user },
    },
  })
})