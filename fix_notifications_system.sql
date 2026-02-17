-- Fix notifications system - handle existing table gracefully
-- Run this in Supabase SQL Editor

-- First, check if notifications table exists and what columns it has
DO $$
BEGIN
    -- Drop existing notifications table if it exists (to ensure clean schema)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'notifications' AND table_schema = 'public') THEN
        DROP TABLE IF EXISTS notifications CASCADE;
        RAISE NOTICE 'Dropped existing notifications table';
    END IF;
    
    -- Drop notification_settings table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'notification_settings' AND table_schema = 'public') THEN
        DROP TABLE IF EXISTS notification_settings CASCADE;
        RAISE NOTICE 'Dropped existing notification_settings table';
    END IF;
END $$;

-- Create clean notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info' CHECK (type IN ('info', 'success', 'warning', 'error', 'system')),
    is_read BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    read_at TIMESTAMPTZ,
    archived_at TIMESTAMPTZ,
    created_by UUID REFERENCES auth.users(id), -- Admin who sent it
    metadata JSONB DEFAULT '{}'::jsonb -- Additional data for rich notifications
);

-- Create notification_settings table
CREATE TABLE notification_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    email_deposits BOOLEAN DEFAULT TRUE,
    email_withdrawals BOOLEAN DEFAULT TRUE,
    email_trades BOOLEAN DEFAULT TRUE,
    email_kyc BOOLEAN DEFAULT TRUE,
    email_system BOOLEAN DEFAULT TRUE,
    push_deposits BOOLEAN DEFAULT TRUE,
    push_withdrawals BOOLEAN DEFAULT TRUE,
    push_trades BOOLEAN DEFAULT TRUE,
    push_kyc BOOLEAN DEFAULT TRUE,
    push_system BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Create indexes for performance
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_notifications_created_by ON notifications(created_by);

-- Add notification preferences to profiles table if not exists
DO $$
BEGIN
    -- Add columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email_notifications') THEN
        ALTER TABLE profiles ADD COLUMN email_notifications BOOLEAN DEFAULT TRUE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'push_notifications') THEN
        ALTER TABLE profiles ADD COLUMN push_notifications BOOLEAN DEFAULT TRUE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'notification_preferences') THEN
        ALTER TABLE profiles ADD COLUMN notification_preferences JSONB DEFAULT '{"email": true, "push": true, "types": ["system", "warning", "error"]}'::jsonb;
    END IF;
END $$;

-- Create trigger to update updated_at on notification_settings
CREATE OR REPLACE FUNCTION update_notification_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS notification_settings_updated_at ON notification_settings;
CREATE TRIGGER notification_settings_updated_at
    BEFORE UPDATE ON notification_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_notification_settings_updated_at();

-- Verify table creation
SELECT 
    'notifications' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'notifications' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT 
    'notification_settings' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'notification_settings' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

DO $$
BEGIN
    RAISE NOTICE 'Notifications system created successfully!';
    RAISE NOTICE 'Tables are ready for use. You can now send notifications from the admin panel.';
END $$;
