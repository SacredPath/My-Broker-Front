-- Add missing KYC columns to profiles table
-- Run this in Supabase SQL Editor

-- Add KYC submission timestamp (missing)
ALTER TABLE profiles 
ADD COLUMN kyc_submitted_at TIMESTAMPTZ;

-- Add KYC review timestamp (missing)
ALTER TABLE profiles 
ADD COLUMN kyc_reviewed_at TIMESTAMPTZ;

-- Add KYC rejection reason (missing)
ALTER TABLE profiles 
ADD COLUMN kyc_rejection_reason TEXT;

-- Add KYC documents JSON field (missing)
ALTER TABLE profiles 
ADD COLUMN kyc_documents JSONB;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_kyc_status ON profiles(kyc_status);
CREATE INDEX IF NOT EXISTS idx_profiles_kyc_submitted_at ON profiles(kyc_submitted_at);

-- Verify all KYC columns were added
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
    AND column_name LIKE 'kyc_%'
ORDER BY column_name;
