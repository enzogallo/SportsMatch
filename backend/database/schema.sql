-- SportsMatch Database Schema for Supabase
-- This file contains the SQL schema for creating the database tables

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('player', 'club')),
    
    -- Player specific fields
    age INTEGER,
    city VARCHAR(100),
    sports TEXT[],
    position VARCHAR(100),
    level VARCHAR(20) CHECK (level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    bio TEXT,
    profile_image_url TEXT,
    presentation_video_url TEXT,
    status VARCHAR(20) CHECK (status IN ('available', 'busy', 'looking')),
    
    -- Club specific fields
    club_name VARCHAR(255),
    club_logo_url TEXT,
    club_description TEXT,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    sports_offered TEXT[],
    location VARCHAR(255),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Offers table
CREATE TABLE IF NOT EXISTS offers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    sport VARCHAR(50) NOT NULL,
    position VARCHAR(100),
    level VARCHAR(20) CHECK (level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    type VARCHAR(20) DEFAULT 'recruitment' CHECK (type IN ('recruitment', 'tournament', 'training', 'replacement')),
    location VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    min_age INTEGER,
    max_age INTEGER,
    is_urgent BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'paused', 'closed', 'filled')),
    max_applications INTEGER,
    current_applications INTEGER DEFAULT 0,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Applications table
CREATE TABLE IF NOT EXISTS applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    offer_id UUID NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'withdrawn')),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure one application per player per offer
    UNIQUE(offer_id, player_id)
);

-- Conversations table
CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_ids UUID[] NOT NULL,
    last_message TEXT,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    unread_count INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    type VARCHAR(20) DEFAULT 'text' CHECK (type IN ('text', 'image', 'application', 'system')),
    is_read BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Conversation participants junction table
CREATE TABLE IF NOT EXISTS conversation_participants (
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (conversation_id, user_id)
);

-- Subscriptions table
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) DEFAULT 'free' CHECK (type IN ('free', 'player_premium', 'club_premium')),
    is_active BOOLEAN DEFAULT TRUE,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    auto_renew BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_city ON users(city);
CREATE INDEX IF NOT EXISTS idx_users_sports ON users USING GIN(sports);
CREATE INDEX IF NOT EXISTS idx_users_sports_offered ON users USING GIN(sports_offered);

CREATE INDEX IF NOT EXISTS idx_offers_club_id ON offers(club_id);
CREATE INDEX IF NOT EXISTS idx_offers_sport ON offers(sport);
CREATE INDEX IF NOT EXISTS idx_offers_city ON offers(city);
CREATE INDEX IF NOT EXISTS idx_offers_status ON offers(status);
CREATE INDEX IF NOT EXISTS idx_offers_created_at ON offers(created_at);

CREATE INDEX IF NOT EXISTS idx_applications_offer_id ON applications(offer_id);
CREATE INDEX IF NOT EXISTS idx_applications_player_id ON applications(player_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON applications(status);

CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

CREATE INDEX IF NOT EXISTS idx_conversations_participant_ids ON conversations USING GIN(participant_ids);

-- Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can read all profiles but only update their own
CREATE POLICY "Users can read all profiles" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- Offers are readable by all, but only clubs can create/update their own
CREATE POLICY "Offers are readable by all" ON offers FOR SELECT USING (true);
CREATE POLICY "Clubs can create offers" ON offers FOR INSERT WITH CHECK (auth.uid() = club_id);
CREATE POLICY "Clubs can update own offers" ON offers FOR UPDATE USING (auth.uid() = club_id);
CREATE POLICY "Clubs can delete own offers" ON offers FOR DELETE USING (auth.uid() = club_id);

-- Applications are readable by the player and the club that owns the offer
CREATE POLICY "Users can read own applications" ON applications FOR SELECT USING (auth.uid() = player_id);
CREATE POLICY "Clubs can read applications for their offers" ON applications FOR SELECT USING (
    EXISTS (SELECT 1 FROM offers WHERE offers.id = applications.offer_id AND offers.club_id = auth.uid())
);
CREATE POLICY "Players can create applications" ON applications FOR INSERT WITH CHECK (auth.uid() = player_id);
CREATE POLICY "Players can update own applications" ON applications FOR UPDATE USING (auth.uid() = player_id);

-- Conversations are readable by participants
CREATE POLICY "Users can read own conversations" ON conversations FOR SELECT USING (auth.uid() = ANY(participant_ids));
CREATE POLICY "Users can create conversations" ON conversations FOR INSERT WITH CHECK (auth.uid() = ANY(participant_ids));

-- Messages are readable by conversation participants
CREATE POLICY "Users can read messages in their conversations" ON messages FOR SELECT USING (
    EXISTS (SELECT 1 FROM conversations WHERE conversations.id = messages.conversation_id AND auth.uid() = ANY(conversations.participant_ids))
);
CREATE POLICY "Users can send messages to their conversations" ON messages FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (SELECT 1 FROM conversations WHERE conversations.id = messages.conversation_id AND auth.uid() = ANY(conversations.participant_ids))
);

-- Subscriptions are readable by the user
CREATE POLICY "Users can read own subscriptions" ON subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own subscriptions" ON subscriptions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Functions for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updating timestamps
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_offers_updated_at BEFORE UPDATE ON offers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON applications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
