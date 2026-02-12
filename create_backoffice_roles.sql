-- Create Missing Backoffice Roles Table
-- Simple script to create the backoffice_roles table that's missing

-- Create the backoffice_roles table
CREATE TABLE IF NOT EXISTS backoffice_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('superadmin', 'admin', 'support', 'user')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_backoffice_roles_user_id ON backoffice_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_backoffice_roles_role ON backoffice_roles(role);

-- Enable RLS
ALTER TABLE backoffice_roles ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own backoffice role" ON backoffice_roles
    FOR ALL USING (auth.uid() = user_id);

-- Grant permissions
GRANT ALL ON backoffice_roles TO authenticated;
GRANT SELECT ON backoffice_roles TO authenticated;
GRANT INSERT ON backoffice_roles TO authenticated;
GRANT UPDATE ON backoffice_roles TO authenticated;
GRANT DELETE ON backoffice_roles TO authenticated;

-- Verify creation
SELECT 
    'SUCCESS' as status,
    'backoffice_roles table created' as message,
    NOW() as created_at;
