# 🏆 SportsMatch Backend API

Backend API pour l'application iOS SportsMatch - Connecte les joueurs et les clubs de tous les sports.

## 🚀 Déploiement rapide

### Option 1 : Railway (Recommandé)
1. **Fork** ce repository
2. **Connectez** votre compte GitHub à [Railway](https://railway.app)
3. **Créez** un nouveau projet depuis ce repository
4. **Configurez** les variables d'environnement (voir ci-dessous)
5. **Déployez** ! 🎉

### Option 2 : Render
1. **Connectez** votre compte GitHub à [Render](https://render.com)
2. **Créez** un nouveau Web Service
3. **Sélectionnez** ce repository
4. **Configurez** les variables d'environnement
5. **Déployez** ! 🎉

## 🗄️ Base de données Supabase

1. **Créez** un compte sur [Supabase](https://supabase.com)
2. **Créez** un nouveau projet
3. **Exécutez** le script SQL dans `database/schema.sql`
4. **Récupérez** vos clés API dans les paramètres du projet

## ⚙️ Variables d'environnement

Créez un fichier `.env` basé sur `env.example` :

```bash
# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key_here

# JWT Secret (générez une clé sécurisée)
JWT_SECRET=your_jwt_secret_here

# Server Configuration
PORT=3000
NODE_ENV=production

# CORS
CORS_ORIGIN=https://your-frontend-domain.com
```

## 🛠️ Développement local

```bash
# Installation
npm install

# Démarrage en mode développement
npm run dev

# Démarrage en production
npm start
```

## 📚 API Endpoints

### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `GET /api/auth/me` - Profil utilisateur
- `POST /api/auth/logout` - Déconnexion

### Utilisateurs
- `GET /api/users` - Recherche d'utilisateurs
- `GET /api/users/:id` - Profil utilisateur
- `PUT /api/users/:id` - Mise à jour du profil
- `GET /api/users/:id/offers` - Offres d'un club

### Offres
- `GET /api/offers` - Liste des offres
- `GET /api/offers/:id` - Détails d'une offre
- `POST /api/offers` - Créer une offre (clubs)
- `PUT /api/offers/:id` - Modifier une offre
- `DELETE /api/offers/:id` - Supprimer une offre

### Candidatures
- `GET /api/applications/my` - Mes candidatures
- `GET /api/applications/offer/:offerId` - Candidatures d'une offre
- `POST /api/applications` - Postuler à une offre
- `PUT /api/applications/:id/status` - Modifier le statut
- `PUT /api/applications/:id/withdraw` - Retirer une candidature

### Messages
- `GET /api/messages/conversations` - Conversations
- `GET /api/messages/conversations/:id/messages` - Messages
- `POST /api/messages/conversations/:id/messages` - Envoyer un message
- `POST /api/messages/conversations` - Créer une conversation

## 🔒 Sécurité

- **JWT** pour l'authentification
- **bcrypt** pour le hachage des mots de passe
- **CORS** configuré
- **Helmet** pour la sécurité HTTP
- **Row Level Security** sur Supabase

## 📊 Base de données

### Tables principales
- `users` - Utilisateurs (joueurs et clubs)
- `offers` - Offres de recrutement
- `applications` - Candidatures
- `conversations` - Conversations
- `messages` - Messages
- `subscriptions` - Abonnements

### Fonctionnalités
- **Indexes** pour les performances
- **RLS** pour la sécurité
- **Triggers** pour les timestamps
- **Contraintes** d'intégrité

## 🚀 Déploiement

### Railway
1. Connectez votre GitHub
2. Créez un nouveau projet
3. Ajoutez les variables d'environnement
4. Déployez !

### Variables Railway
```
SUPABASE_URL=your_url
SUPABASE_ANON_KEY=your_key
SUPABASE_SERVICE_ROLE_KEY=your_service_key
JWT_SECRET=your_secret
NODE_ENV=production
```

## 📱 Intégration iOS

L'API est prête à être intégrée dans votre app iOS. Tous les endpoints sont documentés et testés.

## 🆘 Support

Pour toute question ou problème :
- **Issues** : Créez une issue sur GitHub
- **Email** : support@sportsmatch.com

---

**SportsMatch Backend** - *Trouve ton équipe. Trouve ton match.* 🏆
