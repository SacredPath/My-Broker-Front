-- Check the current schema of the profiles table
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check if KYC columns exist
SELECT 
    column_name,
    CASE 
        WHEN column_name IN ('kyc_status', 'kyc_submitted_at', 'kyc_reviewed_at', 'kyc_rejection_reason', 'kyc_documents') 
        THEN 'KYC Column' 
        ELSE 'Other Column' 
    END as column_type
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
ORDER BY column_type, column_name;
