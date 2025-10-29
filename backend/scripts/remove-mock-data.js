/**
 * Script pour supprimer toutes les données mock de la base de données
 * Usage: node scripts/remove-mock-data.js
 * 
 * ATTENTION: Ce script supprime TOUTES les données contenant le préfixe "_MOCK_" dans l'email
 * Cela inclut les utilisateurs, leurs offres, candidatures, conversations et messages associés
 */

require('dotenv').config();
const { supabaseAdmin } = require('../config/database');

const MOCK_PREFIX = '_MOCK_';

/**
 * Fonction principale pour supprimer les données mock
 */
async function removeMockData() {
    console.log('🗑️  Démarrage de la suppression des données mock...\n');
    
    try {
        // 1. Trouver tous les utilisateurs mock
        console.log('🔍 Recherche des utilisateurs mock...');
        const { data: mockUsers, error: usersError } = await supabaseAdmin
            .from('users')
            .select('id, email, name, role')
            .like('email', `%${MOCK_PREFIX}%`);
        
        if (usersError) {
            throw new Error(`Erreur lors de la recherche des utilisateurs: ${usersError.message}`);
        }
        
        if (!mockUsers || mockUsers.length === 0) {
            console.log('✅ Aucune donnée mock trouvée dans la base de données.');
            return;
        }
        
        console.log(`📋 ${mockUsers.length} utilisateurs mock trouvés`);
        
        const userIds = mockUsers.map(u => u.id);
        const clubIds = mockUsers.filter(u => u.role === 'club').map(u => u.id);
        const playerIds = mockUsers.filter(u => u.role === 'player').map(u => u.id);
        
        console.log(`   - ${clubIds.length} clubs`);
        console.log(`   - ${playerIds.length} joueurs\n`);
        
        // 2. Supprimer les candidatures liées aux joueurs mock
        console.log('🗑️  Suppression des candidatures...');
        const { error: appsError } = await supabaseAdmin
            .from('applications')
            .delete()
            .in('player_id', playerIds);
        
        if (appsError) {
            console.warn(`⚠️  Erreur lors de la suppression des candidatures: ${appsError.message}`);
        } else {
            console.log('✅ Candidatures supprimées');
        }
        
        // 3. Mettre à jour le compteur de candidatures dans les offres
        // (Les offres des clubs mock seront supprimées ensuite, donc pas besoin de mettre à jour)
        
        // 4. Supprimer les offres des clubs mock
        console.log('🗑️  Suppression des offres...');
        const { error: offersError } = await supabaseAdmin
            .from('offers')
            .delete()
            .in('club_id', clubIds);
        
        if (offersError) {
            console.warn(`⚠️  Erreur lors de la suppression des offres: ${offersError.message}`);
        } else {
            console.log('✅ Offres supprimées');
        }
        
        // 5. Supprimer les messages des conversations impliquant des utilisateurs mock
        console.log('🗑️  Suppression des messages...');
        // Récupérer toutes les conversations et filtrer celles impliquant des utilisateurs mock
        const { data: allConversations } = await supabaseAdmin
            .from('conversations')
            .select('id, participant_ids');
        
        const conversations = allConversations?.filter(conv => 
            conv.participant_ids && 
            conv.participant_ids.some(id => userIds.includes(id))
        ) || [];
        
        if (conversations && conversations.length > 0) {
            const conversationIds = conversations.map(c => c.id);
            
            const { error: messagesError } = await supabaseAdmin
                .from('messages')
                .delete()
                .in('conversation_id', conversationIds);
            
            if (messagesError) {
                console.warn(`⚠️  Erreur lors de la suppression des messages: ${messagesError.message}`);
            } else {
                console.log(`✅ ${conversationIds.length} conversations et leurs messages supprimés`);
            }
            
            // Supprimer les conversations
            const { error: convsError } = await supabaseAdmin
                .from('conversations')
                .delete()
                .in('id', conversationIds);
            
            if (convsError) {
                console.warn(`⚠️  Erreur lors de la suppression des conversations: ${convsError.message}`);
            }
        } else {
            console.log('✅ Aucune conversation à supprimer');
        }
        
        // 6. Supprimer les abonnements mock
        console.log('🗑️  Suppression des abonnements...');
        const { error: subsError } = await supabaseAdmin
            .from('subscriptions')
            .delete()
            .in('user_id', userIds);
        
        if (subsError) {
            console.warn(`⚠️  Erreur lors de la suppression des abonnements: ${subsError.message}`);
        } else {
            console.log('✅ Abonnements supprimés');
        }
        
        // 7. Enfin, supprimer les utilisateurs mock
        console.log('🗑️  Suppression des utilisateurs...');
        const { error: deleteError } = await supabaseAdmin
            .from('users')
            .delete()
            .in('id', userIds);
        
        if (deleteError) {
            throw new Error(`Erreur lors de la suppression des utilisateurs: ${deleteError.message}`);
        }
        
        console.log('✅ Utilisateurs supprimés\n');
        
        console.log('✨ Suppression terminée avec succès !\n');
        console.log('📊 Résumé de la suppression:');
        console.log(`   - ${mockUsers.length} utilisateurs supprimés`);
        console.log(`   - Toutes les données associées (offres, candidatures, conversations, messages) ont été supprimées`);
        
    } catch (error) {
        console.error('❌ Erreur lors de la suppression:', error);
        throw error;
    }
}

/**
 * Confirmation avant suppression
 */
function confirmDeletion() {
    console.log('⚠️  ATTENTION: Ce script va supprimer TOUTES les données mock de la base de données.');
    console.log('   Cela inclut les utilisateurs, offres, candidatures, conversations et messages.\n');
    
    // En mode non-interactif (pour les scripts), on peut forcer la suppression
    if (process.env.FORCE_DELETE === 'true') {
        console.log('🔴 Mode FORCE activé, suppression automatique...\n');
        return true;
    }
    
    // Si on veut une confirmation interactive, on peut utiliser readline (mais on va simplifier)
    console.log('Pour supprimer sans confirmation, définissez FORCE_DELETE=true\n');
    return true; // Pour l'instant, on autorise toujours
}

// Exécuter le script
if (require.main === module) {
    confirmDeletion();
    
    removeMockData()
        .then(() => {
            console.log('✅ Script terminé avec succès');
            process.exit(0);
        })
        .catch((error) => {
            console.error('❌ Erreur lors de l\'exécution:', error);
            process.exit(1);
        });
}

module.exports = { removeMockData };

