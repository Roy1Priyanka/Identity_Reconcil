-- Identity Reconciliation Service - Supabase Setup
-- Run this script in your Supabase SQL Editor

-- Drop existing table if you need to recreate it
-- DROP TABLE IF EXISTS contacts CASCADE;

-- Create the contacts table
CREATE TABLE IF NOT EXISTS contacts (
  id BIGSERIAL PRIMARY KEY,
  phone_number TEXT,
  email TEXT,
  linked_id BIGINT,
  link_precedence TEXT CHECK(link_precedence IN ('secondary', 'primary')) DEFAULT 'primary',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  FOREIGN KEY (linked_id) REFERENCES contacts(id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_contacts_email ON contacts(email) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_contacts_phone ON contacts(phone_number) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_contacts_linked_id ON contacts(linked_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_contacts_precedence ON contacts(link_precedence) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_contacts_deleted ON contacts(deleted_at);
CREATE INDEX IF NOT EXISTS idx_contacts_created_at ON contacts(created_at) WHERE deleted_at IS NULL;

-- Create composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_contacts_email_phone ON contacts(email, phone_number) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_contacts_precedence_created ON contacts(link_precedence, created_at) WHERE deleted_at IS NULL;

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at on row updates
DROP TRIGGER IF EXISTS update_contacts_updated_at ON contacts;
CREATE TRIGGER update_contacts_updated_at
    BEFORE UPDATE ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS) for additional security
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS (adjust based on your authentication needs)
-- For now, allow all operations for service role
CREATE POLICY "Enable all operations for service role" ON contacts
  FOR ALL USING (auth.role() = 'service_role');

-- If you want to allow authenticated users to manage contacts:
-- CREATE POLICY "Enable all operations for authenticated users" ON contacts
--   FOR ALL USING (auth.role() = 'authenticated');

-- If you want to allow anonymous access (not recommended for production):
-- CREATE POLICY "Enable all operations for anonymous users" ON contacts
--   FOR ALL USING (true);

-- Create a function for executing arbitrary SQL (useful for migrations)
CREATE OR REPLACE FUNCTION exec_sql(sql TEXT)
RETURNS TEXT AS $$
BEGIN
    EXECUTE sql;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON contacts TO anon, authenticated;