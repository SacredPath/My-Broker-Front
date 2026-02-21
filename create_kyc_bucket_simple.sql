-- Create KYC documents storage bucket (Simplified Version)
-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor)

-- 1. Create the storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'kyc-documents',
  'kyc-documents',
  false, -- Set to true if you want public access
  5242880, -- 5MB file size limit (in bytes)
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'application/pdf']
);

-- 2. Simple RLS policies - allow authenticated users to manage their own files
-- Users can upload files
CREATE POLICY "Users can upload KYC documents" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'kyc-documents' AND
  auth.role() = 'authenticated'
);

-- Users can read their own files
CREATE POLICY "Users can read KYC documents" ON storage.objects
FOR SELECT USING (
  bucket_id = 'kyc-documents' AND
  auth.role() = 'authenticated'
);

-- Users can update their own files
CREATE POLICY "Users can update KYC documents" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'kyc-documents' AND
  auth.role() = 'authenticated'
);

-- Users can delete their own files
CREATE POLICY "Users can delete KYC documents" ON storage.objects
FOR DELETE USING (
  bucket_id = 'kyc-documents' AND
  auth.role() = 'authenticated'
);

-- 3. Grant necessary permissions
GRANT ALL ON storage.buckets TO authenticated;
GRANT ALL ON storage.objects TO authenticated;

-- 4. Enable RLS on storage objects (if not already enabled)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
