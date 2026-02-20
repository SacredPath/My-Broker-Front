-- Safe profiles table creation
-- Handles existing tables gracefully

-- First, check if table exists and show current structure
SELECT '=== CHECKING CURRENT PROFILES TABLE ===' as info;

DO $$
BEGIN
    -- Only create table if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
        
        -- Create the table
        CREATE TABLE public.profiles (
            id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
            email TEXT,
            phone TEXT,
            first_name TEXT,
            last_name TEXT,
            username TEXT UNIQUE,
            avatar_url TEXT,
            kyc_status VARCHAR(20) DEFAULT 'pending' CHECK (kyc_status IN ('pending', 'submitted', 'verified', 'rejected')),
            tier_level INTEGER DEFAULT 1,
            balance DECIMAL(20,8) DEFAULT 0,
            is_active BOOLEAN DEFAULT true,
            email_verified BOOLEAN DEFAULT false,
            phone_verified BOOLEAN DEFAULT false,
            two_factor_enabled BOOLEAN DEFAULT false,
            last_login TIMESTAMP WITH TIME ZONE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Create indexes
        CREATE INDEX idx_profiles_email ON public.profiles(email);
        CREATE INDEX idx_profiles_phone ON public.profiles(phone);
        CREATE INDEX idx_profiles_username ON public.profiles(username);
        CREATE INDEX idx_profiles_kyc_status ON public.profiles(kyc_status);
        CREATE INDEX idx_profiles_tier_level ON public.profiles(tier_level);
        CREATE INDEX idx_profiles_is_active ON public.profiles(is_active);
        
        RAISE NOTICE 'Profiles table created successfully';
        
    ELSE
        -- Table exists, add missing columns if needed
        RAISE NOTICE 'Profiles table already exists, checking for missing columns...';
        
        -- Add missing columns one by one
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS username TEXT UNIQUE;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS first_name TEXT;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_name TEXT;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS kyc_status VARCHAR(20) DEFAULT 'pending';
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS tier_level INTEGER DEFAULT 1;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS balance DECIMAL(20,8) DEFAULT 0;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT false;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT false;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS two_factor_enabled BOOLEAN DEFAULT false;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        BEGIN
            ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        EXCEPTION WHEN duplicate_column THEN NULL; END;
        
        RAISE NOTICE 'Missing columns added to existing profiles table';
    END IF;
END $$;

-- Create or replace the updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger (drop if exists first)
DROP TRIGGER IF EXISTS handle_profiles_updated_at ON public.profiles;
CREATE TRIGGER handle_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_profiles_updated_at();

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Service role full access" ON public.profiles;

-- Create RLS Policies
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Service role full access" ON public.profiles
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO service_role;

-- Show final structure
SELECT '=== FINAL PROFILES STRUCTURE ===' as info;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'profiles'
ORDER BY ordinal_position;
