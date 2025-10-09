// Test script pour vérifier l'API SportsMatch
const axios = require('axios');

const BASE_URL = process.env.API_URL || 'http://localhost:3000';

async function testAPI() {
  console.log('🧪 Test de l\'API SportsMatch');
  console.log('================================\n');

  try {
    // Test 1: Health check
    console.log('1. Test Health Check...');
    const healthResponse = await axios.get(`${BASE_URL}/api/health`);
    console.log('✅ Health Check:', healthResponse.data);
    console.log('');

    // Test 2: Inscription
    console.log('2. Test Inscription...');
    const registerData = {
      email: 'test@example.com',
      password: 'password123',
      name: 'Test User',
      role: 'player'
    };
    
    try {
      const registerResponse = await axios.post(`${BASE_URL}/api/auth/register`, registerData);
      console.log('✅ Inscription réussie:', registerResponse.data.message);
      console.log('👤 Utilisateur créé:', registerResponse.data.user.name);
      console.log('🔑 Token:', registerResponse.data.token.substring(0, 20) + '...');
      console.log('');
    } catch (error) {
      if (error.response?.status === 400 && error.response?.data?.error?.includes('already exists')) {
        console.log('⚠️  Utilisateur existe déjà, test de connexion...');
      } else {
        throw error;
      }
    }

    // Test 3: Connexion
    console.log('3. Test Connexion...');
    const loginData = {
      email: 'test@example.com',
      password: 'password123'
    };
    
    const loginResponse = await axios.post(`${BASE_URL}/api/auth/login`, loginData);
    console.log('✅ Connexion réussie:', loginResponse.data.message);
    console.log('👤 Utilisateur connecté:', loginResponse.data.user.name);
    console.log('🔑 Token:', loginResponse.data.token.substring(0, 20) + '...');
    console.log('');

    const token = loginResponse.data.token;

    // Test 4: Profil utilisateur
    console.log('4. Test Profil Utilisateur...');
    const profileResponse = await axios.get(`${BASE_URL}/api/auth/me`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Profil récupéré:', profileResponse.data.user.name);
    console.log('');

    // Test 5: Recherche d'offres
    console.log('5. Test Recherche d\'Offres...');
    const offersResponse = await axios.get(`${BASE_URL}/api/offers`);
    console.log('✅ Offres récupérées:', offersResponse.data.offers.length, 'offres');
    console.log('📄 Pagination:', offersResponse.data.pagination);
    console.log('');

    // Test 6: Recherche d'utilisateurs
    console.log('6. Test Recherche d\'Utilisateurs...');
    const usersResponse = await axios.get(`${BASE_URL}/api/users`);
    console.log('✅ Utilisateurs trouvés:', usersResponse.data.users.length, 'utilisateurs');
    console.log('');

    console.log('🎉 Tous les tests sont passés avec succès !');
    console.log('🚀 Votre API SportsMatch est opérationnelle !');

  } catch (error) {
    console.error('❌ Erreur lors du test:', error.message);
    if (error.response) {
      console.error('📄 Détails:', error.response.data);
      console.error('🔢 Status:', error.response.status);
    }
    process.exit(1);
  }
}

// Installation d'axios si nécessaire
if (!require('fs').existsSync('./node_modules/axios')) {
  console.log('📦 Installation d\'axios pour les tests...');
  require('child_process').execSync('npm install axios', { stdio: 'inherit' });
}

testAPI();
