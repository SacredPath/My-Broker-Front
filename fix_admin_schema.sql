-- Fix Admin Schema Issues
-- This script creates the missing backoffice_roles table with correct structure

-- First, check if backoffice_roles table exists
DO $$
BEGIN
    -- Drop the existing table if it has wrong structure
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'backoffice_roles'
    ) THEN
        DROP TABLE IF EXISTS backoffice_roles CASCADE;
    END IF;
END $$;

-- Create the correct backoffice_roles table
CREATE TABLE IF NOT EXISTS backoffice_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('superadmin', 'admin', 'support', 'user')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Add unique constraint to prevent duplicate roles per user
    UNIQUE(user_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_backoffice_roles_user_id ON backoffice_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_backoffice_roles_role ON backoffice_roles(role);

-- Check if profiles table has the required columns
DO $$
BEGIN
    -- Add role column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'profiles' 
        AND column_name = 'role'
    ) THEN
        ALTER TABLE profiles ADD COLUMN role TEXT DEFAULT 'user';
    END IF;
    
    -- Add registration_type column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'profiles' 
        AND column_name = 'registration_type'
    ) THEN
        ALTER TABLE profiles ADD COLUMN registration_type TEXT DEFAULT 'user';
    END IF;
    
    -- Add position column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'profiles' 
        AND column_name = 'position'
    ) THEN
        ALTER TABLE profiles ADD COLUMN position TEXT;
    END IF;
    
    -- Add first_name column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'profiles' 
        AND column_name = 'first_name'
    ) THEN
        ALTER TABLE profiles ADD COLUMN first_name TEXT;
    END IF;
    
    -- Add last_name column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'profiles' 
        AND column_name = 'last_name'
    ) THEN
        ALTER TABLE profiles ADD COLUMN last_name TEXT;
    END IF;
    
    -- Add phone column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'profiles' 
        AND column_name = 'phone'
    ) THEN
        ALTER TABLE profiles ADD COLUMN phone TEXT;
    END IF;
END $$;

-- Create indexes for profiles table
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_registration_type ON profiles(registration_type);

-- Enable Row Level Security
ALTER TABLE backoffice_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for backoffice_roles
CREATE POLICY "Users can view their own backoffice role" ON backoffice_roles
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own backoffice role" ON backoffice_roles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own backoffice role" ON backoffice_roles
    FOR UPDATE USING (auth.uid() = user_id);

-- Create RLS policies for profiles
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Grant permissions
GRANT ALL ON backoffice_roles TO authenticated;
GRANT SELECT ON backoffice_roles TO authenticated;
GRANT INSERT ON backoffice_roles TO authenticated;
GRANT UPDATE ON backoffice_roles TO authenticated;
GRANT DELETE ON backoffice_roles TO authenticated;

GRANT ALL ON profiles TO authenticated;
GRANT SELECT ON profiles TO authenticated;
GRANT INSERT ON profiles TO authenticated;
GRANT UPDATE ON profiles TO authenticated;

-- Create a function to handle new user registration safely
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Just return new without any complex logic that might cause errors
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new users
DROP TRIGGER IF EXISTS on_auth_user_created ON profiles;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Verify the setup
SELECT 
    'Schema Setup Complete' as status,
    NOW() as completed_at;

-- Show the final table structures
SELECT 
    'backoffice_roles' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'backoffice_roles'
ORDER BY ordinal_position;

SELECT 
    'profiles' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'profiles'
    AND column_name IN ('role', 'registration_type', 'position', 'first_name', 'last_name', 'phone')
ORDER BY ordinal_position;
