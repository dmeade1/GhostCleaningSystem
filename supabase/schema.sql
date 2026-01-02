-- Ghost Cleaning System Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (crew members)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  pin TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL CHECK (role IN ('crew', 'supervisor', 'admin')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Yachts table
CREATE TABLE yachts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  model TEXT,
  length_feet INTEGER,
  location TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Jobs table (daily assignments)
CREATE TABLE jobs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  yacht_id UUID REFERENCES yachts(id) ON DELETE CASCADE,
  assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
  scheduled_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'reviewed')),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Zones table (cleaning areas per yacht)
CREATE TABLE zones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  yacht_id UUID REFERENCES yachts(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tasks table (checklist items per zone)
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  requires_photo BOOLEAN DEFAULT false,
  reference_image_url TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Task completions table
CREATE TABLE task_completions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  completed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  photo_url TEXT,
  notes TEXT,
  synced BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(job_id, task_id)
);

-- Issues table (flagged problems)
CREATE TABLE issues (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
  task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
  reported_by UUID REFERENCES users(id) ON DELETE SET NULL,
  priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  title TEXT NOT NULL,
  description TEXT,
  photo_url TEXT,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
  resolved_by UUID REFERENCES users(id) ON DELETE SET NULL,
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sync queue table (for offline actions)
CREATE TABLE sync_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  action_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  synced BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

-- Create indexes for performance
CREATE INDEX idx_jobs_yacht_id ON jobs(yacht_id);
CREATE INDEX idx_jobs_assigned_to ON jobs(assigned_to);
CREATE INDEX idx_jobs_scheduled_date ON jobs(scheduled_date);
CREATE INDEX idx_zones_yacht_id ON zones(yacht_id);
CREATE INDEX idx_tasks_zone_id ON tasks(zone_id);
CREATE INDEX idx_task_completions_job_id ON task_completions(job_id);
CREATE INDEX idx_issues_job_id ON issues(job_id);
CREATE INDEX idx_sync_queue_user_id ON sync_queue(user_id);
CREATE INDEX idx_sync_queue_synced ON sync_queue(synced);

-- Row Level Security (RLS) Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE yachts ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_queue ENABLE ROW LEVEL SECURITY;

-- Users can read all users (for crew lists)
CREATE POLICY "Users can read all users" ON users
  FOR SELECT USING (true);

-- Users can read all yachts
CREATE POLICY "Users can read all yachts" ON yachts
  FOR SELECT USING (true);

-- Users can read jobs assigned to them or all jobs if supervisor/admin
CREATE POLICY "Users can read their jobs" ON jobs
  FOR SELECT USING (
    assigned_to = auth.uid() OR 
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('supervisor', 'admin'))
  );

-- Users can update jobs assigned to them
CREATE POLICY "Users can update their jobs" ON jobs
  FOR UPDATE USING (assigned_to = auth.uid());

-- Users can read all zones and tasks
CREATE POLICY "Users can read zones" ON zones FOR SELECT USING (true);
CREATE POLICY "Users can read tasks" ON tasks FOR SELECT USING (true);

-- Users can insert/update their own task completions
CREATE POLICY "Users can manage their task completions" ON task_completions
  FOR ALL USING (completed_by = auth.uid());

-- Users can read task completions for their jobs
CREATE POLICY "Users can read task completions" ON task_completions
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM jobs WHERE id = job_id AND assigned_to = auth.uid())
  );

-- Users can manage their own issues
CREATE POLICY "Users can manage their issues" ON issues
  FOR ALL USING (reported_by = auth.uid());

-- Users can read all issues
CREATE POLICY "Users can read issues" ON issues FOR SELECT USING (true);

-- Users can manage their own sync queue
CREATE POLICY "Users can manage their sync queue" ON sync_queue
  FOR ALL USING (user_id = auth.uid());

-- Sample data for testing
INSERT INTO users (name, pin, role) VALUES
  ('John Doe', '1234', 'crew'),
  ('Jane Smith', '5678', 'supervisor'),
  ('Admin User', '0000', 'admin');

INSERT INTO yachts (name, model, length_feet, location) VALUES
  ('Sea Breeze', 'Sunseeker 76', 76, 'Marina Bay'),
  ('Ocean Pearl', 'Azimut 80', 80, 'Harbor Point'),
  ('Wave Rider', 'Princess 75', 75, 'Yacht Club');

-- Create sample zones for first yacht
INSERT INTO zones (yacht_id, name, description, order_index)
SELECT 
  id,
  zone_name,
  zone_desc,
  zone_order
FROM yachts, (VALUES
  ('Main Deck', 'Exterior deck and seating areas', 1),
  ('Salon', 'Main living and dining area', 2),
  ('Galley', 'Kitchen and food prep area', 3),
  ('Master Cabin', 'Primary bedroom suite', 4),
  ('Guest Cabins', 'Guest sleeping quarters', 5),
  ('Bathrooms', 'All heads and bathrooms', 6),
  ('Engine Room', 'Mechanical spaces', 7)
) AS z(zone_name, zone_desc, zone_order)
WHERE yachts.name = 'Sea Breeze';

-- Create sample tasks for Main Deck zone
INSERT INTO tasks (zone_id, title, description, requires_photo, order_index)
SELECT 
  z.id,
  task_title,
  task_desc,
  task_photo,
  task_order
FROM zones z, (VALUES
  ('Sweep and mop deck', 'Remove debris and clean with appropriate cleaner', true, 1),
  ('Clean railings', 'Wipe down all stainless steel railings', false, 2),
  ('Wash windows', 'Clean all exterior windows and glass', true, 3),
  ('Organize deck furniture', 'Arrange cushions and furniture properly', false, 4),
  ('Check safety equipment', 'Verify life rings and safety gear are in place', false, 5)
) AS t(task_title, task_desc, task_photo, task_order)
WHERE z.name = 'Main Deck';

-- Create a sample job for today
INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status)
SELECT 
  y.id,
  u.id,
  CURRENT_DATE,
  'pending'
FROM yachts y, users u
WHERE y.name = 'Sea Breeze' AND u.name = 'John Doe';
