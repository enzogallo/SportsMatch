-- Script minimal pour créer UNIQUEMENT la table favorites
-- À utiliser si les policies causent des problèmes

-- Supprimer la table si elle existe (ATTENTION: supprime les données)
-- DÉCOMMENTE la ligne suivante seulement si tu veux réinitialiser la table
-- DROP TABLE IF EXISTS favorites CASCADE;

-- Créer la table
CREATE TABLE IF NOT EXISTS favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('offer', 'player', 'club')),
    item_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, item_type, item_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_item_type ON favorites(item_type);
CREATE INDEX IF NOT EXISTS idx_favorites_item_id ON favorites(item_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user_item ON favorites(user_id, item_type);

-- RLS (optionnel - peut être ajouté après)
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Policy (supprime d'abord si existe)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'favorites' AND policyname = 'Backend handles authentication') THEN
        DROP POLICY "Backend handles authentication" ON favorites;
    END IF;
END $$;

CREATE POLICY "Backend handles authentication" ON favorites FOR ALL USING (true) WITH CHECK (true);

