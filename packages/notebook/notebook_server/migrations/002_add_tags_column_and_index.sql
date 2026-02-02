-- Migration: Add tags column and GIN index for notebooks
-- Description: Adds tags column as TEXT (stores JSON array) and creates GIN index for fast searches
-- Date: 2026-02-01

-- Add tags column if it doesn't exist
ALTER TABLE notebooks ADD COLUMN IF NOT EXISTS tags TEXT;

-- Add comment explaining the column
COMMENT ON COLUMN notebooks.tags IS 'JSON array of tag IDs (stored as TEXT). Example: ["tag-id-1","tag-id-2"]';

-- Create GIN index for fast tag searches using jsonb containment operator (@>)
-- First, we need to ensure the column can be cast to jsonb
CREATE INDEX IF NOT EXISTS idx_notebooks_tags_gin
  ON notebooks USING GIN ((tags::jsonb))
  WHERE tags IS NOT NULL AND tags != '';

-- Validate existing data (optional: convert empty strings to NULL)
UPDATE notebooks SET tags = NULL WHERE tags = '';
