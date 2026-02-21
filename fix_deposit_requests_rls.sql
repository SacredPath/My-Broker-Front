-- Fix RLS Policy for deposit_requests table
-- Allow authenticated users to create deposit requests

-- Enable RLS on deposit_requests table
ALTER TABLE deposit_requests ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can create deposit requests" ON deposit_requests;
DROP POLICY IF EXISTS "Users can view own deposit requests" ON deposit_requests;
DROP POLICY IF EXISTS "Admins can manage deposit requests" ON deposit_requests;

-- Create policies for deposit_requests
CREATE POLICY "Users can create deposit requests" ON deposit_requests
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own deposit requests" ON deposit_requests
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage deposit requests" ON deposit_requests
    FOR ALL USING (auth.jwt() ->> 'role' IN ('support', 'superadmin'));

-- Verify the policies were created
SELECT 'DEPOSIT_REQUESTS_RLS_FIXED' as status,
       schemaname,
       tablename,
       policyname,
       permissive,
       roles,
       cmd,
       qual
FROM pg_policies 
WHERE tablename = 'deposit_requests' AND schemaname = 'public'
ORDER BY policyname;
