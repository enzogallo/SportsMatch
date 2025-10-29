-- ⚠️ SCRIPT MINIMAL - Ajoute UNIQUEMENT la table favorites
-- N'exécute PAS le schema.sql complet, utilise seulement ce script !

-- Table favorites
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

-- RLS
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Policy (supprime d'abord si existe)
DROP POLICY IF EXISTS "Backend handles authentication" ON favorites;
CREATE POLICY "Backend handles authentication" ON favorites FOR ALL USING (true) WITH CHECK (true);

