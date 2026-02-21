-- Add missing columns to profiles table
-- This fixes "Could not find column 'bio'" error

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS bio TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS display_name TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS address_line1 TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS address_line2 TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS city TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS state TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS country TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS postal_code TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS occupation TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS new_to_investing TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS pep TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS pep_details TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS dob DATE;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS referral_code TEXT;

-- Verify columns were added
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
    AND column_name IN ('bio', 'display_name', 'address_line1', 'address_line2', 'city', 'state', 'country', 'postal_code', 'occupation', 'new_to_investing', 'pep', 'pep_details', 'dob', 'referral_code')
ORDER BY column_name;
