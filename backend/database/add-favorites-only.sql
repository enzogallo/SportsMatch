-- Ajouter uniquement la table favorites au schéma existant
-- Ce script est sûr à exécuter car il utilise CREATE IF NOT EXISTS

-- Créer la table favorites
CREATE TABLE IF NOT EXISTS favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('offer', 'player', 'club')),
    item_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, item_type, item_id)
);

-- Créer les index pour les performances
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_item_type ON favorites(item_type);
CREATE INDEX IF NOT EXISTS idx_favorites_item_id ON favorites(item_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user_item ON favorites(user_id, item_type);

-- Activer RLS pour la table favorites
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Supprimer la policy si elle existe déjà (pour éviter les erreurs)
DROP POLICY IF EXISTS "Backend handles authentication" ON favorites;

-- Créer la policy pour la table favorites
CREATE POLICY "Backend handles authentication" ON favorites 
    FOR ALL 
    USING (true) 
    WITH CHECK (true);

