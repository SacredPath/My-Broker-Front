-- Add missing basic profile columns for KYC
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS first_name TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS last_name TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS date_of_birth DATE;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS nationality TEXT;

-- Add KYC submission timestamp (missing)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS kyc_submitted_at TIMESTAMPTZ;

-- Add KYC review timestamp (missing)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS kyc_reviewed_at TIMESTAMPTZ;

-- Add KYC rejection reason (missing)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS kyc_rejection_reason TEXT;

-- Add KYC documents JSON field (missing)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS kyc_documents JSONB;

-- Add KYC status if it doesn't exist
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS kyc_status TEXT DEFAULT 'not_submitted';

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_kyc_status ON profiles(kyc_status);
CREATE INDEX IF NOT EXISTS idx_profiles_kyc_submitted_at ON profiles(kyc_submitted_at);

-- Verify all required columns were added
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
    AND (
        column_name LIKE 'kyc_%' 
        OR column_name IN ('first_name', 'last_name', 'date_of_birth', 'nationality')
    )
ORDER BY column_name;
