# Ghost Cleaning System

A Progressive Web App for yacht cleaning crews to manage tasks, capture photos, and work offline with automatic sync.

## Features

- PIN-based authentication for crew members
- Daily job assignments and task checklists
- Photo documentation and issue reporting
- Offline-first architecture with automatic sync
- Installable as mobile/desktop PWA

## Tech Stack

Vue 3 • Vite • Tailwind CSS • Pinia • Supabase • PWA

## Setup

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Configure Supabase**
   - Create a Supabase project
   - Run `supabase/schema.sql` in SQL Editor
   - Create a Storage bucket: `task-photos`

3. **Environment variables**
   ```bash
   cp .env.example .env
   # Add your Supabase URL and anon key
   ```

4. **Run development server**
   ```bash
   npm run dev
   ```

## Deployment

Deploy to Vercel or any static hosting platform. Ensure environment variables are configured in your hosting dashboard.

## License

MIT
