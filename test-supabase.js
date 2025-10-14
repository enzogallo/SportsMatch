const { createClient } = require('@supabase/supabase-js');

// Test de connexion Supabase
async function testSupabase() {
    console.log('🧪 Test de connexion Supabase...');
    
    // Récupérer les variables d'environnement
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_ANON_KEY;
    
    console.log('URL:', supabaseUrl);
    console.log('Key (premiers 20 chars):', supabaseKey?.substring(0, 20) + '...');
    
    if (!supabaseUrl || !supabaseKey) {
        console.error('❌ Variables d\'environnement manquantes');
        return;
    }
    
    const supabase = createClient(supabaseUrl, supabaseKey);
    
    try {
        // Test 1: Vérifier la connexion
        console.log('\n1️⃣ Test de connexion...');
        const { data, error } = await supabase.from('users').select('count').limit(1);
        
        if (error) {
            console.error('❌ Erreur de connexion:', error.message);
            return;
        }
        
        console.log('✅ Connexion réussie');
        
        // Test 2: Vérifier la structure de la table
        console.log('\n2️⃣ Test de structure de table...');
        const { data: users, error: usersError } = await supabase
            .from('users')
            .select('*')
            .limit(1);
            
        if (usersError) {
            console.error('❌ Erreur de structure:', usersError.message);
            return;
        }
        
        console.log('✅ Structure de table OK');
        
        // Test 3: Essayer d'insérer un utilisateur de test
        console.log('\n3️⃣ Test d\'insertion...');
        const testUser = {
            email: 'test-' + Date.now() + '@example.com',
            password: 'test123',
            name: 'Test User',
            role: 'player'
        };
        
        const { data: newUser, error: insertError } = await supabase
            .from('users')
            .insert([testUser])
            .select()
            .single();
            
        if (insertError) {
            console.error('❌ Erreur d\'insertion:', insertError.message);
            console.error('Détails:', insertError);
            return;
        }
        
        console.log('✅ Insertion réussie:', newUser);
        
        // Nettoyer
        await supabase.from('users').delete().eq('id', newUser.id);
        console.log('✅ Test terminé avec succès');
        
    } catch (error) {
        console.error('❌ Erreur générale:', error.message);
    }
}

testSupabase();

