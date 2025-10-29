-- Table pour les favoris (offres, joueurs, clubs)
-- Script sécurisé qui évite les conflits

-- Créer la table si elle n'existe pas
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

-- Indexes pour les performances (utilisent IF NOT EXISTS)
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_item_type ON favorites(item_type);
CREATE INDEX IF NOT EXISTS idx_favorites_item_id ON favorites(item_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user_item ON favorites(user_id, item_type);

-- Activer RLS
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Supprimer la policy si elle existe déjà, puis la créer
DROP POLICY IF EXISTS "Backend handles authentication" ON favorites;
CREATE POLICY "Backend handles authentication" ON favorites FOR ALL USING (true) WITH CHECK (true);

