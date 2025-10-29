-- Table pour les favoris (offres, joueurs, clubs)
CREATE TABLE IF NOT EXISTS favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('offer', 'player', 'club')),
    item_id UUID NOT NULL,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint: un utilisateur ne peut favoriser un item qu'une fois
    UNIQUE(user_id, item_type, item_id)
);

-- Indexes pour les performances
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_item_type ON favorites(item_type);
CREATE INDEX IF NOT EXISTS idx_favorites_item_id ON favorites(item_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user_item ON favorites(user_id, item_type);

-- RLS policies
-- Note: RLS est désactivé car l'authentification se fait via JWT dans le backend
-- Les routes API gèrent déjà la sécurité avec authenticateToken middleware
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Policy pour permettre toutes les opérations (la sécurité est gérée par le backend)
-- En production avec Supabase Auth, utiliser: USING (auth.uid() = user_id)
CREATE POLICY "Backend handles authentication" ON favorites FOR ALL USING (true) WITH CHECK (true);

