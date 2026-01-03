-- Additional Sample Jobs for Ghost Cleaning System
-- Run this in your Supabase SQL Editor to add more job postings
-- This bypasses RLS since it runs as the postgres user

-- Create jobs for the past week (completed jobs)
INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status, started_at, completed_at)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Sea Breeze' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Sarah Interior' LIMIT 1),
  CURRENT_DATE - 5,
  'completed',
  (CURRENT_DATE - 5)::timestamp + interval '8 hours',
  (CURRENT_DATE - 5)::timestamp + interval '12 hours';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status, started_at, completed_at)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Ocean Pearl' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Mike Exterior' LIMIT 1),
  CURRENT_DATE - 4,
  'completed',
  (CURRENT_DATE - 4)::timestamp + interval '9 hours',
  (CURRENT_DATE - 4)::timestamp + interval '13 hours';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status, started_at, completed_at)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Wave Rider' LIMIT 1),
  (SELECT id FROM users WHERE name = 'John Doe' LIMIT 1),
  CURRENT_DATE - 3,
  'completed',
  (CURRENT_DATE - 3)::timestamp + interval '8 hours',
  (CURRENT_DATE - 3)::timestamp + interval '11 hours 30 minutes';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status, started_at, completed_at, reviewed_by, reviewed_at)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Sea Breeze' LIMIT 1),
  (SELECT id FROM users WHERE name = 'John Doe' LIMIT 1),
  CURRENT_DATE - 2,
  'reviewed',
  (CURRENT_DATE - 2)::timestamp + interval '8 hours',
  (CURRENT_DATE - 2)::timestamp + interval '12 hours',
  (SELECT id FROM users WHERE name = 'Jane Smith' LIMIT 1),
  (CURRENT_DATE - 2)::timestamp + interval '14 hours';

-- Create jobs for yesterday (some completed, some in progress)
INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status, started_at, completed_at)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Ocean Pearl' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Sarah Interior' LIMIT 1),
  CURRENT_DATE - 1,
  'completed',
  (CURRENT_DATE - 1)::timestamp + interval '8 hours',
  (CURRENT_DATE - 1)::timestamp + interval '13 hours';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status, started_at)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Wave Rider' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Mike Exterior' LIMIT 1),
  CURRENT_DATE - 1,
  'in_progress',
  (CURRENT_DATE - 1)::timestamp + interval '9 hours';

-- Create jobs for today (various statuses)
INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status, started_at, notes)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Ocean Pearl' LIMIT 1),
  (SELECT id FROM users WHERE name = 'John Doe' LIMIT 1),
  CURRENT_DATE,
  'in_progress',
  NOW() - interval '2 hours',
  'Deep clean requested by owner';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Wave Rider' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Sarah Interior' LIMIT 1),
  CURRENT_DATE,
  'pending';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Sea Breeze' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Mike Exterior' LIMIT 1),
  CURRENT_DATE,
  'pending';

-- Create jobs for tomorrow (all pending)
INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Sea Breeze' LIMIT 1),
  (SELECT id FROM users WHERE name = 'John Doe' LIMIT 1),
  CURRENT_DATE + 1,
  'pending';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Ocean Pearl' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Sarah Interior' LIMIT 1),
  CURRENT_DATE + 1,
  'pending';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status, notes)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Wave Rider' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Mike Exterior' LIMIT 1),
  CURRENT_DATE + 1,
  'pending',
  'Focus on exterior deck areas';

-- Create jobs for next week (all pending)
INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Sea Breeze' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Sarah Interior' LIMIT 1),
  CURRENT_DATE + 3,
  'pending';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Ocean Pearl' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Mike Exterior' LIMIT 1),
  CURRENT_DATE + 4,
  'pending';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Wave Rider' LIMIT 1),
  (SELECT id FROM users WHERE name = 'John Doe' LIMIT 1),
  CURRENT_DATE + 5,
  'pending';

INSERT INTO jobs (yacht_id, assigned_to, scheduled_date, status, notes)
SELECT 
  (SELECT id FROM yachts WHERE name = 'Sea Breeze' LIMIT 1),
  (SELECT id FROM users WHERE name = 'Jane Smith' LIMIT 1),
  CURRENT_DATE + 7,
  'pending',
  'VIP charter - extra attention to detail required';

-- Show summary of created jobs
SELECT 
  status,
  COUNT(*) as count,
  MIN(scheduled_date) as earliest,
  MAX(scheduled_date) as latest
FROM jobs
GROUP BY status
ORDER BY 
  CASE status
    WHEN 'reviewed' THEN 1
    WHEN 'completed' THEN 2
    WHEN 'in_progress' THEN 3
    WHEN 'pending' THEN 4
  END;
