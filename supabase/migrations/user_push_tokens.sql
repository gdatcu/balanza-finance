-- Migration: Create user_push_tokens table and Row Level Security (RLS) policies

CREATE TABLE IF NOT EXISTS user_push_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL UNIQUE,
    language TEXT NOT NULL DEFAULT 'en',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE user_push_tokens ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can select their own push tokens
CREATE POLICY "Users can select their own push tokens"
    ON user_push_tokens FOR SELECT
    USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own push tokens
CREATE POLICY "Users can insert their own push tokens"
    ON user_push_tokens FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own push tokens
CREATE POLICY "Users can update their own push tokens"
    ON user_push_tokens FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own push tokens
CREATE POLICY "Users can delete their own push tokens"
    ON user_push_tokens FOR DELETE
    USING (auth.uid() = user_id);
