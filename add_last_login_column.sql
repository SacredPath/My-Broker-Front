-- Add the missing last_login column to the profiles table
ALTER TABLE public.profiles 
ADD COLUMN last_login TIMESTAMP WITH TIME ZONE;

-- Create an index on last_login for better query performance
CREATE INDEX IF NOT EXISTS profiles_last_login_idx ON public.profiles(last_login);
