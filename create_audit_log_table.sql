-- Create audit_log_entries table
-- This table is referenced by existing functions/triggers but was missing

CREATE TABLE IF NOT EXISTS public.audit_log_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON public.audit_log_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_action ON public.audit_log_entries(action);
CREATE INDEX IF NOT EXISTS idx_audit_log_table_name ON public.audit_log_entries(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON public.audit_log_entries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_record ON public.audit_log_entries(table_name, record_id);

-- Add RLS policy for audit log
ALTER TABLE public.audit_log_entries ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own audit entries
CREATE POLICY "Users can view own audit entries" ON public.audit_log_entries
    FOR SELECT USING (auth.uid() = user_id);

-- Policy: Service role can do everything
CREATE POLICY "Service role full access" ON public.audit_log_entries
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.audit_log_entries TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.audit_log_entries TO service_role;

-- Verify table creation
SELECT 
    'audit_log_entries' as table_name,
    'CREATED' as status,
    NOW() as created_at;
