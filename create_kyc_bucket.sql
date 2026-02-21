-- Create KYC documents storage bucket
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

-- 2. Create Row Level Security (RLS) policies for the bucket
-- Policy to allow users to upload their own files
CREATE POLICY "Users can upload their own KYC documents" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'kyc-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()
);

-- Policy to allow users to read their own files
CREATE POLICY "Users can read their own KYC documents" ON storage.objects
FOR SELECT USING (
  bucket_id = 'kyc-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()
);

-- Policy to allow users to update their own files
CREATE POLICY "Users can update their own KYC documents" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'kyc-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()
);

-- Policy to allow users to delete their own files
CREATE POLICY "Users can delete their own KYC documents" ON storage.objects
FOR DELETE USING (
  bucket_id = 'kyc-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()
);

-- 3. Grant necessary permissions
GRANT ALL ON storage.buckets TO authenticated;
GRANT ALL ON storage.objects TO authenticated;

-- 4. Enable RLS on storage objects (if not already enabled)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
