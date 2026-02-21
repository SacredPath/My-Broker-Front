# Create KYC Documents Storage Bucket

## Option 1: Through Supabase Dashboard (Recommended)

1. Go to your Supabase Dashboard: https://app.supabase.com
2. Select your project
3. Go to Storage in the left sidebar
4. Click "New bucket"
5. Enter these details:
   - **Name**: `kyc-documents`
   - **Public bucket**: Unchecked (private)
   - **File size limit**: 5242880 (5MB)
   - **Allowed MIME types**: 
     - `image/jpeg`
     - `image/jpg` 
     - `image/png`
     - `application/pdf`
6. Click "Save"

## Option 2: Through SQL Editor (Simple Version)

1. Go to your Supabase Dashboard
2. Select your project
3. Go to SQL Editor in the left sidebar
4. Click "New query"
5. Copy and paste the SQL from `create_kyc_bucket_simple.sql`
6. Click "Run"

## Option 3: Through SQL Editor (Advanced Version with User Isolation)

1. Go to your Supabase Dashboard
2. Select your project
3. Go to SQL Editor in the left sidebar
4. Click "New query"
5. Copy and paste the SQL from `create_kyc_bucket.sql`
6. Click "Run"

## What This Does:

- Creates a private storage bucket named `kyc-documents`
- Limits file size to 5MB
- Only allows image and PDF files
- Sets up Row Level Security (RLS) so users can only access their own files
- Files will be stored in paths like: `kyc/{user_id}/{timestamp}_{filename}`

## After Creation:

Once the bucket is created, the KYC upload functionality should work properly. Users will be able to:
- Upload ID documents (front/back)
- Upload selfie photos
- Upload address verification documents
- Each user can only see/access their own files

## Security:

The bucket is private by default, meaning:
- Files are not publicly accessible via URL
- Only authenticated users can access their own files
- File paths include the user ID for isolation

## Troubleshooting:

If you get a UUID comparison error, use the simple version (Option 2) which avoids complex folder name parsing.
