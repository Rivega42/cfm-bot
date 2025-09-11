import { redirect } from 'next/navigation'

export default function HomePage() {
  // Redirect to Telegram Mini App
  redirect('/telegram')
}