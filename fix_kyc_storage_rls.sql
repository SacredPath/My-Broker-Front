-- Fix RLS policies for kyc-documents storage bucket
-- Run this in your Supabase SQL Editor

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can upload KYC documents" ON storage.objects;
DROP POLICY IF EXISTS "Users can read KYC documents" ON storage.objects;
DROP POLICY IF EXISTS "Users can update KYC documents" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete KYC documents" ON storage.objects;

-- Create new policies that allow authenticated users to access the bucket
CREATE POLICY "Allow authenticated users to upload to kyc-documents" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'kyc-documents' AND 
  auth.role() = 'authenticated'
);

CREATE POLICY "Allow authenticated users to read from kyc-documents" ON storage.objects
FOR SELECT USING (
  bucket_id = 'kyc-documents' AND 
  auth.role() = 'authenticated'
);

CREATE POLICY "Allow authenticated users to update in kyc-documents" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'kyc-documents' AND 
  auth.role() = 'authenticated'
);

CREATE POLICY "Allow authenticated users to delete from kyc-documents" ON storage.objects
FOR DELETE USING (
  bucket_id = 'kyc-documents' AND 
  auth.role() = 'authenticated'
);
