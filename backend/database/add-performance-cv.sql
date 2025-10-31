-- Add performance_cv JSONB column to users
ALTER TABLE users
ADD COLUMN IF NOT EXISTS performance_cv JSONB;


