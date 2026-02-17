-- KYC Storage Bucket RLS Policies
-- Run these in Supabase Dashboard → SQL Editor

-- 1. Allow users to upload files to their own folder
CREATE POLICY "Users can upload their own KYC files" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'KYC_KEEP' AND 
  auth.uid()::text = (string_to_array(name, '/'))[2]
);

-- 2. Allow users to read their own files
CREATE POLICY "Users can read their own KYC files" ON storage.objects
FOR SELECT USING (
  bucket_id = 'KYC_KEEP' AND 
  auth.uid()::text = (string_to_array(name, '/'))[2]
);

-- 3. Allow users to update their own files
CREATE POLICY "Users can update their own KYC files" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'KYC_KEEP' AND 
  auth.uid()::text = (string_to_array(name, '/'))[2]
);

-- 4. Allow users to delete their own files
CREATE POLICY "Users can delete their own KYC files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'KYC_KEEP' AND 
  auth.uid()::text = (string_to_array(name, '/'))[2]
);

-- Alternative simpler approach (less secure but easier for testing):
-- Allow any authenticated user to access KYC_KEEP bucket

-- CREATE POLICY "Allow authenticated users full access to KYC_KEEP" ON storage.objects
-- FOR ALL USING (bucket_id = 'KYC_KEEP')
-- WITH CHECK (bucket_id = 'KYC_KEEP');
