-- Create missing profile for user angela@porn.com
-- Run this in Supabase SQL Editor

INSERT INTO public.profiles (
    id,
    email,
    first_name,
    last_name,
    phone,
    country,
    bio,
    avatar_url,
    created_at,
    updated_at
) VALUES (
    '29425569-a981-471d-8817-17293c88b9b9',
    'angela@porn.com',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Verify the profile was created
SELECT * FROM public.profiles WHERE id = '29425569-a981-471d-8817-17293c88b9b9';
