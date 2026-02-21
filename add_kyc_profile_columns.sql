-- Add missing KYC columns to profiles table
-- Run this in your Supabase SQL Editor

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS kyc_status TEXT DEFAULT 'not_submitted',
ADD COLUMN IF NOT EXISTS kyc_submitted_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS kyc_approved_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS kyc_rejection_reason TEXT;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_kyc_status ON profiles(kyc_status);
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);
