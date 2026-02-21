-- Add missing role column to profiles table
-- This fixes role field error in profile creation

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';

-- Also add any other missing columns that might be needed
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS username TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT false;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS two_factor_enabled BOOLEAN DEFAULT false;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;

-- Verify all profile columns are now present
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
    AND column_name IN ('role', 'username', 'avatar_url', 'phone_verified', 'two_factor_enabled', 'last_login')
ORDER BY column_name;
