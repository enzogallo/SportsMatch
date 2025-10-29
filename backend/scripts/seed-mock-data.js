/**
 * Script pour insérer des données de test (mock data) dans la base de données
 * Usage: node scripts/seed-mock-data.js
 * 
 * ATTENTION: Ce script utilise supabaseAdmin pour bypasser RLS
 * Les données mock sont identifiables par le préfixe "_MOCK_" dans les emails
 */

require('dotenv').config();
const { supabaseAdmin } = require('../config/database');
const bcrypt = require('bcryptjs');

// Préfixe pour identifier facilement les données mock
const MOCK_PREFIX = '_MOCK_';
const MOCK_PASSWORD = 'mock123456'; // Mot de passe par défaut pour tous les comptes mock

// Tous les sports disponibles
const SPORTS = [
    'football', 'basketball', 'tennis', 'rugby', 'volleyball', 
    'handball', 'badminton', 'table_tennis', 'swimming', 'athletics',
    'cycling', 'martial_arts', 'hockey', 'baseball', 'golf'
];

// Positions par sport
const POSITIONS = {
    football: ['Gardien', 'Défenseur', 'Milieu', 'Attaquant'],
    basketball: ['Meneur', 'Arrière', 'Ailier', 'Pivot'],
    rugby: ['Pilier', 'Talonneur', 'Deuxième ligne', 'Troisième ligne', 'Demi de mêlée', 'Demi d\'ouverture', 'Centre', 'Ailier', 'Arrière'],
    volleyball: ['Passeur', 'Attaquant', 'Réceptionneur', 'Central', 'Libero'],
    handball: ['Gardien', 'Ailier gauche', 'Ailier droit', 'Arrière gauche', 'Arrière droit', 'Demi-centre', 'Pivot'],
    tennis: ['Joueur simple', 'Joueur double'],
    swimming: ['Nageur libre', 'Spécialiste dos', 'Spécialiste brasse', 'Spécialiste papillon'],
    athletics: ['Sprinter', 'Coureur de fond', 'Saut', 'Lancer'],
    cycling: ['Route', 'VTT', 'Piste'],
    martial_arts: ['Karaté', 'Judo', 'Taekwondo', 'Boxe'],
    hockey: ['Gardien', 'Défenseur', 'Attaquant'],
    baseball: ['Lanceur', 'Receveur', 'Base', 'Champ extérieur'],
    golf: ['Golfeur'],
    badminton: ['Simple', 'Double'],
    table_tennis: ['Joueur']
};

// Niveaux disponibles
const LEVELS = ['beginner', 'intermediate', 'advanced', 'expert'];

// Villes françaises
const CITIES = [
    { city: 'Paris', location: 'Île-de-France' },
    { city: 'Lyon', location: 'Auvergne-Rhône-Alpes' },
    { city: 'Marseille', location: 'Provence-Alpes-Côte d\'Azur' },
    { city: 'Toulouse', location: 'Occitanie' },
    { city: 'Nice', location: 'Provence-Alpes-Côte d\'Azur' },
    { city: 'Nantes', location: 'Pays de la Loire' },
    { city: 'Strasbourg', location: 'Grand Est' },
    { city: 'Montpellier', location: 'Occitanie' },
    { city: 'Bordeaux', location: 'Nouvelle-Aquitaine' },
    { city: 'Lille', location: 'Hauts-de-France' },
    { city: 'Rennes', location: 'Bretagne' },
    { city: 'Reims', location: 'Grand Est' }
];

// Messages de candidature
const APPLICATION_MESSAGES = [
    "Bonjour, je suis très intéressé par cette offre et j'aimerais rejoindre votre équipe.",
    "Je possède une expérience solide dans ce sport et serais ravi de contribuer à votre club.",
    "Après avoir consulté votre offre, je pense correspondre parfaitement à vos critères.",
    "Passionné depuis de nombreuses années, je suis motivé à intégrer votre structure.",
    "Je souhaite postuler pour cette opportunité qui me paraît idéale.",
    "Votre offre a retenu mon attention, je serais honoré de rejoindre votre équipe.",
    "Avec mon expérience et ma motivation, je pense pouvoir apporter beaucoup à votre club."
];

// Messages de conversation
const CONVERSATION_MESSAGES = [
    "Bonjour, avez-vous bien reçu ma candidature ?",
    "Merci pour votre retour rapide !",
    "Quand pouvons-nous organiser un entretien ?",
    "Parfait, je suis disponible cette semaine.",
    "Je vous remercie pour cette opportunité.",
    "À bientôt !",
    "Très bien, à lundi alors."
];

/**
 * Génère un mot de passe hashé
 */
async function hashPassword(password) {
    return await bcrypt.hash(password, 10);
}

/**
 * Crée un joueur mock
 */
async function createMockPlayer(sport, index) {
    const cityData = CITIES[Math.floor(Math.random() * CITIES.length)];
    const level = LEVELS[Math.floor(Math.random() * LEVELS.length)];
    const positions = POSITIONS[sport] || ['Joueur'];
    const position = positions[Math.floor(Math.random() * positions.length)];
    const age = Math.floor(Math.random() * 20) + 18; // Entre 18 et 38 ans
    const statuses = ['available', 'looking', 'busy'];
    const status = statuses[Math.floor(Math.random() * statuses.length)];
    
    const names = [
        'Lucas', 'Thomas', 'Hugo', 'Nathan', 'Alexandre', 'Louis', 'Mathis', 'Ethan',
        'Emma', 'Léa', 'Chloé', 'Manon', 'Inès', 'Camille', 'Sarah', 'Julie'
    ];
    const firstNames = [
        'Martin', 'Bernard', 'Dubois', 'Durand', 'Moreau', 'Laurent', 'Simon', 'Michel',
        'Petit', 'Leroy', 'Moreau', 'Garcia', 'Roux', 'Fournier', 'Girard', 'Bonnet'
    ];
    
    const firstName = names[Math.floor(Math.random() * names.length)];
    const lastName = firstNames[Math.floor(Math.random() * firstNames.length)];
    const name = `${firstName} ${lastName}`;
    const email = `mock.player.${sport}.${index}${MOCK_PREFIX}@sportsmatch.test`;
    
    const sportsList = [sport];
    // Parfois ajouter un sport secondaire
    if (Math.random() > 0.5) {
        const otherSport = SPORTS[Math.floor(Math.random() * SPORTS.length)];
        if (otherSport !== sport) sportsList.push(otherSport);
    }
    
    const { data: user, error } = await supabaseAdmin
        .from('users')
        .insert([{
            email,
            password: await hashPassword(MOCK_PASSWORD),
            name,
            role: 'player',
            age,
            city: cityData.city,
            sports: sportsList,
            position,
            level,
            status,
            bio: `Passionné de ${sport}, je recherche une équipe pour progresser et m'amuser. Niveau ${level}, je suis ${status === 'looking' ? 'en recherche active' : status === 'available' ? 'disponible' : 'occupé'}.`,
            created_at: new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000).toISOString(), // Créé il y a jusqu'à 90 jours
            updated_at: new Date().toISOString()
        }])
        .select()
        .single();
    
    if (error) {
        console.error(`❌ Erreur création joueur ${name}:`, error.message);
        return null;
    }
    
    console.log(`✅ Joueur créé: ${name} (${sport})`);
    return user;
}

/**
 * Crée un club mock
 */
async function createMockClub(sport, index) {
    const cityData = CITIES[Math.floor(Math.random() * CITIES.length)];
    
    const clubNames = [
        `${cityData.city} ${sport.charAt(0).toUpperCase() + sport.slice(1)} Club`,
        `FC ${cityData.city}`,
        `${cityData.city} Sporting Club`,
        `Les ${cityData.city}iens`,
        `${cityData.city} United`,
        `AS ${cityData.city}`,
        `Club Sportif de ${cityData.city}`
    ];
    
    const clubName = clubNames[Math.floor(Math.random() * clubNames.length)];
    const name = clubName;
    const email = `mock.club.${sport}.${index}${MOCK_PREFIX}@sportsmatch.test`;
    
    const sportsOffered = [sport];
    // Parfois offrir plusieurs sports
    if (Math.random() > 0.3) {
        const otherSport = SPORTS[Math.floor(Math.random() * SPORTS.length)];
        if (otherSport !== sport && Math.random() > 0.7) {
            sportsOffered.push(otherSport);
        }
    }
    
    const { data: user, error } = await supabaseAdmin
        .from('users')
        .insert([{
            email,
            password: await hashPassword(MOCK_PASSWORD),
            name: name,
            role: 'club',
            club_name: clubName,
            city: cityData.city,
            location: cityData.location,
            sports_offered: sportsOffered,
            club_description: `Club de ${sport} basé à ${cityData.city}. Nous cherchons des joueurs motivés pour renforcer notre équipe et participer à des compétitions locales et régionales.`,
            contact_email: email,
            contact_phone: `0${Math.floor(Math.random() * 9) + 1}${Math.floor(Math.random() * 100000000).toString().padStart(8, '0')}`,
            created_at: new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000).toISOString(),
            updated_at: new Date().toISOString()
        }])
        .select()
        .single();
    
    if (error) {
        console.error(`❌ Erreur création club ${clubName}:`, error.message);
        return null;
    }
    
    console.log(`✅ Club créé: ${clubName} (${sport})`);
    return user;
}

/**
 * Crée une offre mock
 */
async function createMockOffer(club, sport) {
    const cityData = CITIES[Math.floor(Math.random() * CITIES.length)];
    const level = LEVELS[Math.floor(Math.random() * LEVELS.length)];
    const positions = POSITIONS[sport] || ['Joueur'];
    const position = positions[Math.floor(Math.random() * positions.length)];
    
    const offerTypes = ['recruitment', 'tournament', 'training', 'replacement'];
    const type = offerTypes[Math.floor(Math.random() * offerTypes.length)];
    
    const statuses = ['active', 'active', 'active', 'paused', 'active']; // Plus d'offres actives
    const status = statuses[Math.floor(Math.random() * statuses.length)];
    
    const titles = {
        recruitment: [`Recherche ${position.toLowerCase()}`, `${position} recherché`, `Poste de ${position.toLowerCase()} disponible`],
        tournament: [`Tournoi de ${sport}`, `Compétition ${sport}`, `Championnat ${sport}`],
        training: [`Entraînement ${sport}`, `Session d'entraînement`, `Stage de ${sport}`],
        replacement: [`Remplaçant recherché`, `Urgent: ${position}`, `Remplacement immédiat`]
    };
    
    const title = titles[type][Math.floor(Math.random() * titles[type].length)];
    
    const descriptions = {
        recruitment: `Nous recherchons un ${position.toLowerCase()} pour renforcer notre équipe. Niveau ${level} requis. Rejoignez-nous pour partager votre passion !`,
        tournament: `Tournoi de ${sport} organisé dans notre région. Ouvert à tous niveaux, venez participer à cette compétition amicale.`,
        training: `Entraînement régulier de ${sport} pour tous niveaux. Amélioration technique et physique garantie !`,
        replacement: `URGENT: Nous recherchons un ${position.toLowerCase()} en remplacement. Disponibilité immédiate requise.`
    };
    
    const description = descriptions[type];
    
    const isUrgent = type === 'replacement' || (type === 'recruitment' && Math.random() > 0.7);
    
    const minAge = Math.floor(Math.random() * 5) + 16;
    const maxAge = minAge + Math.floor(Math.random() * 15) + 5;
    
    const { data: offer, error } = await supabaseAdmin
        .from('offers')
        .insert([{
            club_id: club.id,
            title,
            description,
            sport,
            position,
            level,
            type,
            location: cityData.location,
            city: cityData.city,
            min_age: Math.random() > 0.3 ? minAge : null,
            max_age: Math.random() > 0.3 ? maxAge : null,
            is_urgent: isUrgent,
            status,
            max_applications: Math.random() > 0.7 ? Math.floor(Math.random() * 10) + 5 : null,
            current_applications: 0,
            created_at: new Date(Date.now() - Math.random() * 60 * 24 * 60 * 60 * 1000).toISOString(), // Créé il y a jusqu'à 60 jours
            updated_at: new Date().toISOString(),
            expires_at: status === 'active' ? new Date(Date.now() + Math.random() * 30 * 24 * 60 * 60 * 1000).toISOString() : null
        }])
        .select()
        .single();
    
    if (error) {
        console.error(`❌ Erreur création offre:`, error.message);
        return null;
    }
    
    console.log(`   ✅ Offre créée: ${title}`);
    return offer;
}

/**
 * Crée une candidature mock
 */
async function createMockApplication(offer, player) {
    const message = APPLICATION_MESSAGES[Math.floor(Math.random() * APPLICATION_MESSAGES.length)];
    
    const statuses = ['pending', 'pending', 'pending', 'accepted', 'rejected']; // Plus de pending
    const status = statuses[Math.floor(Math.random() * statuses.length)];
    
    const { data: application, error } = await supabaseAdmin
        .from('applications')
        .insert([{
            offer_id: offer.id,
            player_id: player.id,
            message,
            status,
            created_at: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000).toISOString(),
            updated_at: new Date().toISOString()
        }])
        .select()
        .single();
    
    if (error) {
        // Peut-être une candidature existe déjà (UNIQUE constraint)
        if (error.code === '23505') {
            return null;
        }
        console.error(`❌ Erreur création candidature:`, error.message);
        return null;
    }
    
    // Mettre à jour le compteur de candidatures
    await supabaseAdmin
        .from('offers')
        .update({ current_applications: offer.current_applications + 1 })
        .eq('id', offer.id);
    
    return application;
}

/**
 * Crée une conversation et des messages mock
 */
async function createMockConversation(user1, user2) {
    // Vérifier si une conversation existe déjà
    const { data: existingConvs } = await supabaseAdmin
        .from('conversations')
        .select('id, participant_ids');
    
    const existing = existingConvs?.find(conv => 
        conv.participant_ids && 
        conv.participant_ids.includes(user1.id) && 
        conv.participant_ids.includes(user2.id) &&
        conv.participant_ids.length === 2
    );
    
    if (existing) {
        return existing.id;
    }
    
    const { data: conversation, error: convError } = await supabaseAdmin
        .from('conversations')
        .insert([{
            participant_ids: [user1.id, user2.id],
            last_activity_at: new Date().toISOString(),
            unread_count: 0,
            created_at: new Date(Date.now() - Math.random() * 20 * 24 * 60 * 60 * 1000).toISOString(),
            updated_at: new Date().toISOString()
        }])
        .select()
        .single();
    
    if (convError) {
        console.error(`❌ Erreur création conversation:`, convError.message);
        return null;
    }
    
    // Créer quelques messages
    const numMessages = Math.floor(Math.random() * 5) + 2; // Entre 2 et 6 messages
    
    for (let i = 0; i < numMessages; i++) {
        const sender = i % 2 === 0 ? user1 : user2;
        const message = CONVERSATION_MESSAGES[Math.floor(Math.random() * CONVERSATION_MESSAGES.length)];
        
        await supabaseAdmin
            .from('messages')
            .insert([{
                conversation_id: conversation.id,
                sender_id: sender.id,
                content: message,
                type: 'text',
                is_read: i < numMessages - 1, // Dernier message non lu
                created_at: new Date(Date.now() - (numMessages - i) * 2 * 24 * 60 * 60 * 1000).toISOString()
            }]);
        
        // Mettre à jour la conversation
        await supabaseAdmin
            .from('conversations')
            .update({
                last_message: message,
                last_activity_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
            })
            .eq('id', conversation.id);
    }
    
    return conversation.id;
}

/**
 * Fonction principale
 */
async function seedMockData() {
    console.log('🌱 Démarrage de l\'insertion des données mock...\n');
    
    const allPlayers = [];
    const allClubs = [];
    const allOffers = [];
    
    // 1. Créer des joueurs pour chaque sport (3-5 joueurs par sport)
    console.log('📝 Création des joueurs...');
    for (const sport of SPORTS) {
        const numPlayers = Math.floor(Math.random() * 3) + 3; // 3 à 5 joueurs
        for (let i = 0; i < numPlayers; i++) {
            const player = await createMockPlayer(sport, i);
            if (player) allPlayers.push(player);
            // Petit délai pour éviter la surcharge
            await new Promise(resolve => setTimeout(resolve, 100));
        }
    }
    console.log(`✅ ${allPlayers.length} joueurs créés\n`);
    
    // 2. Créer des clubs pour chaque sport (2-3 clubs par sport)
    console.log('🏢 Création des clubs...');
    for (const sport of SPORTS) {
        const numClubs = Math.floor(Math.random() * 2) + 2; // 2 à 3 clubs
        for (let i = 0; i < numClubs; i++) {
            const club = await createMockClub(sport, i);
            if (club) allClubs.push(club);
            await new Promise(resolve => setTimeout(resolve, 100));
        }
    }
    console.log(`✅ ${allClubs.length} clubs créés\n`);
    
    // 3. Créer des offres pour chaque club (2-4 offres par club)
    console.log('📋 Création des offres...');
    for (const club of allClubs) {
        const sport = club.sports_offered?.[0] || SPORTS[0];
        const numOffers = Math.floor(Math.random() * 3) + 2; // 2 à 4 offres
        for (let i = 0; i < numOffers; i++) {
            const offer = await createMockOffer(club, sport);
            if (offer) allOffers.push(offer);
            await new Promise(resolve => setTimeout(resolve, 100));
        }
    }
    console.log(`✅ ${allOffers.length} offres créées\n`);
    
    // 4. Créer des candidatures (chaque joueur postule à 1-3 offres)
    console.log('📨 Création des candidatures...');
    let applicationsCount = 0;
    for (const player of allPlayers) {
        const playerSport = player.sports?.[0] || SPORTS[0];
        // Trouver des offres correspondantes
        const matchingOffers = allOffers.filter(offer => 
            offer.sport === playerSport && offer.status === 'active'
        );
        
        const numApplications = Math.min(Math.floor(Math.random() * 3) + 1, matchingOffers.length);
        const selectedOffers = matchingOffers
            .sort(() => Math.random() - 0.5)
            .slice(0, numApplications);
        
        for (const offer of selectedOffers) {
            const app = await createMockApplication(offer, player);
            if (app) applicationsCount++;
            await new Promise(resolve => setTimeout(resolve, 50));
        }
    }
    console.log(`✅ ${applicationsCount} candidatures créées\n`);
    
    // 5. Créer des conversations et messages
    console.log('💬 Création des conversations...');
    let conversationsCount = 0;
    // Créer des conversations entre joueurs et clubs ayant des candidatures
    const usedPairs = new Set();
    for (let i = 0; i < Math.min(allPlayers.length * 2, 50); i++) {
        const player = allPlayers[Math.floor(Math.random() * allPlayers.length)];
        const club = allClubs[Math.floor(Math.random() * allClubs.length)];
        const pairKey = `${player.id}-${club.id}`;
        
        if (!usedPairs.has(pairKey)) {
            usedPairs.add(pairKey);
            const convId = await createMockConversation(player, club);
            if (convId) conversationsCount++;
            await new Promise(resolve => setTimeout(resolve, 100));
        }
    }
    console.log(`✅ ${conversationsCount} conversations créées\n`);
    
    console.log('✨ Données mock insérées avec succès !\n');
    console.log('📊 Résumé:');
    console.log(`   - ${allPlayers.length} joueurs`);
    console.log(`   - ${allClubs.length} clubs`);
    console.log(`   - ${allOffers.length} offres`);
    console.log(`   - ${applicationsCount} candidatures`);
    console.log(`   - ${conversationsCount} conversations\n`);
    console.log(`🔑 Tous les comptes mock ont le mot de passe: ${MOCK_PASSWORD}`);
    console.log(`📧 Les emails mock contiennent le préfixe: ${MOCK_PREFIX}`);
    console.log(`🗑️  Pour supprimer ces données, utilisez: node scripts/remove-mock-data.js`);
}

// Exécuter le script
if (require.main === module) {
    seedMockData()
        .then(() => {
            console.log('✅ Script terminé avec succès');
            process.exit(0);
        })
        .catch((error) => {
            console.error('❌ Erreur lors de l\'exécution:', error);
            process.exit(1);
        });
}

module.exports = { seedMockData };

