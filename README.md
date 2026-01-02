# Ghost Cleaning System

A Progressive Web App (PWA) for yacht cleaning crews to manage daily tasks, capture photos, report issues, and work offline with automatic sync.

## 🚀 Features

- **PIN Authentication** - Quick crew member login
- **Daily Job Management** - View assigned yachts and tasks
- **Zone-Based Checklists** - Organized cleaning tasks by yacht area
- **Photo Capture** - Document completed work
- **Issue Reporting** - Flag problems with priority levels
- **Offline-First** - Works without internet, syncs when online
- **PWA Support** - Install on mobile devices

## 🛠️ Tech Stack

- **Frontend**: Vue 3 + Vite
- **Styling**: Tailwind CSS
- **State Management**: Pinia
- **Backend**: Supabase (Auth, Database, Storage)
- **PWA**: Vite PWA Plugin + Workbox
- **Hosting**: Vercel (recommended)

## 📋 Prerequisites

- Node.js 18+ and npm
- Supabase account (free tier works)
- Git

## 🔧 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/dmeade1/GhostCleaningSystem.git
cd GhostCleaningSystem
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Run the SQL in `supabase/schema.sql` in your Supabase SQL Editor
3. Create a Storage bucket named `task-photos` with public access
4. Copy your project URL and anon key

### 4. Set Environment Variables

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Edit `.env` and add your Supabase credentials:

```
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### 5. Run Development Server

```bash
npm run dev
```

Visit `http://localhost:5173` in your browser.

### 6. Test Login

Use the sample PIN from the database:
- **Crew**: `1234` (John Doe)
- **Supervisor**: `5678` (Jane Smith)
- **Admin**: `0000` (Admin User)

## 📱 PWA Installation

### On Mobile (iOS/Android)

1. Open the app in Safari (iOS) or Chrome (Android)
2. Tap the share button
3. Select "Add to Home Screen"
4. The app will now work offline!

### On Desktop

1. Look for the install icon in the address bar
2. Click to install as a desktop app

## 🗄️ Database Schema

The app uses the following main tables:

- `users` - Crew members with PIN authentication
- `yachts` - Yacht information
- `jobs` - Daily assignments
- `zones` - Cleaning areas per yacht
- `tasks` - Checklist items
- `task_completions` - Completed tasks with photos
- `issues` - Flagged problems
- `sync_queue` - Offline actions to sync

## 🚢 Deployment

### Deploy to Vercel

1. Push your code to GitHub
2. Import project in Vercel
3. Add environment variables in Vercel dashboard
4. Deploy!

```bash
# Or use Vercel CLI
npm i -g vercel
vercel
```

## 📸 Reference Images

Upload quality standard photos to Supabase Storage in the `reference-images` bucket. These can be displayed in tasks to show crews what "done" looks like.

See `reference-images/README.md` for details.

## 🔒 Security Notes

- Row Level Security (RLS) is enabled on all tables
- Users can only access their assigned jobs
- Supervisors can review all jobs
- Photos are stored in Supabase Storage with public URLs

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - feel free to use for your yacht cleaning business!

## 🆘 Support

For issues or questions, please open a GitHub issue.

---

Built with ⚓ for yacht cleaning professionals
