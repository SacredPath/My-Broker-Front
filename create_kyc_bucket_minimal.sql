-- Create KYC documents storage bucket (Minimal Version)
-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor)

-- 1. Create the storage bucket only
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'kyc-documents',
  'kyc-documents',
  false, -- Private bucket
  5242880, -- 5MB file size limit (in bytes)
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'application/pdf']
);

-- Note: RLS policies will be set up automatically by Supabase
-- If you need custom policies, create them through the Dashboard UI instead
