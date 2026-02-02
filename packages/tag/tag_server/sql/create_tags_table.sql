-- Tags table for tag management feature
-- This table stores global tags that can be used across projects, tasks, and notebooks

CREATE TABLE IF NOT EXISTS tags (
  -- Primary key (UUID auto-generated)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Soft delete and active status flags
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  
  -- Audit timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Tag data
  name VARCHAR(50) NOT NULL UNIQUE,  -- Tag name (unique constraint)
  description VARCHAR(200),          -- Optional description
  color VARCHAR(9),                  -- Optional hex color (e.g., #FF5722 or #FF5722AA)
  usage_count INTEGER NOT NULL DEFAULT 0  -- How many times this tag is used
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name);
CREATE INDEX IF NOT EXISTS idx_tags_active_deleted ON tags(is_active, is_deleted);
CREATE INDEX IF NOT EXISTS idx_tags_usage_count ON tags(usage_count DESC);

-- Trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_tags_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_tags_updated_at
  BEFORE UPDATE ON tags
  FOR EACH ROW
  EXECUTE FUNCTION update_tags_updated_at();

-- Comments for documentation
COMMENT ON TABLE tags IS 'Global tags used across projects, tasks, and notebooks';
COMMENT ON COLUMN tags.id IS 'Unique identifier (UUID)';
COMMENT ON COLUMN tags.is_deleted IS 'Soft delete flag';
COMMENT ON COLUMN tags.is_active IS 'Active status flag';
COMMENT ON COLUMN tags.created_at IS 'Creation timestamp';
COMMENT ON COLUMN tags.updated_at IS 'Last update timestamp (auto-updated)';
COMMENT ON COLUMN tags.name IS 'Tag name (unique)';
COMMENT ON COLUMN tags.description IS 'Optional tag description';
COMMENT ON COLUMN tags.color IS 'Optional hex color for UI';
COMMENT ON COLUMN tags.usage_count IS 'Counter of how many times this tag is used';
