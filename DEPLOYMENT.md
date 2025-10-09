# 🚀 Guide de déploiement - SportsMatch

## 📋 Vue d'ensemble

Ce guide vous accompagne pour déployer votre application SportsMatch complète :
- **Backend API** : Node.js + Supabase + Railway
- **Frontend iOS** : SwiftUI connecté à l'API

## 🗄️ Étape 1 : Configuration Supabase

### 1.1 Créer un projet Supabase
1. **Allez** sur [supabase.com](https://supabase.com)
2. **Créez** un compte (gratuit)
3. **Cliquez** sur "New Project"
4. **Nommez** : `sportsmatch`
5. **Générez** un mot de passe fort
6. **Région** : Europe West (Paris)
7. **Créez** le projet

### 1.2 Configurer la base de données
1. **Allez** dans "SQL Editor"
2. **Cliquez** sur "New query"
3. **Copiez-collez** le contenu de `backend/database/schema.sql`
4. **Exécutez** le script
5. **Vérifiez** que les tables sont créées

### 1.3 Récupérer les clés API
1. **Allez** dans "Settings" → "API"
2. **Copiez** :
   - `Project URL` → `SUPABASE_URL`
   - `anon public` → `SUPABASE_ANON_KEY`
   - `service_role` → `SUPABASE_SERVICE_ROLE_KEY`

## 🚂 Étape 2 : Déploiement Railway

### 2.1 Créer un compte Railway
1. **Allez** sur [railway.app](https://railway.app)
2. **Connectez** avec GitHub
3. **Autorisez** l'accès à vos repositories

### 2.2 Déployer l'API
1. **Cliquez** sur "New Project"
2. **Sélectionnez** "Deploy from GitHub repo"
3. **Choisissez** votre repository `SportsMatch`
4. **Sélectionnez** le dossier `backend`
5. **Cliquez** sur "Deploy"

### 2.3 Configurer les variables d'environnement
Dans Railway, ajoutez ces variables :
```
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre_cle_anon
SUPABASE_SERVICE_ROLE_KEY=votre_cle_service
JWT_SECRET=votre_secret_jwt_tres_securise
NODE_ENV=production
CORS_ORIGIN=*
```

### 2.4 Tester l'API
1. **Récupérez** l'URL de votre API (ex: `https://sportsmatch-api.railway.app`)
2. **Testez** : `https://votre-api.railway.app/api/health`
3. **Vérifiez** que vous obtenez une réponse JSON

## 📱 Étape 3 : Configuration iOS

### 3.1 Mettre à jour l'URL de l'API
Dans `SportsMatch/Services/APIService.swift`, modifiez :
```swift
private let baseURL = "https://votre-api.railway.app"
```

### 3.2 Tester la connexion
1. **Compilez** l'application
2. **Lancez** sur un simulateur
3. **Testez** l'inscription/connexion
4. **Vérifiez** que les données se chargent

## 🧪 Étape 4 : Tests

### 4.1 Test de l'API
```bash
cd backend
node test-api.js
```

### 4.2 Test de l'application iOS
1. **Inscription** d'un nouveau joueur
2. **Connexion** avec les identifiants
3. **Navigation** dans l'application
4. **Création** d'une offre (club)
5. **Candidature** à une offre (joueur)

## 🔧 Étape 5 : Configuration avancée

### 5.1 Domaine personnalisé (Optionnel)
1. **Achetez** un domaine (ex: `sportsmatch.com`)
2. **Configurez** un sous-domaine (ex: `api.sportsmatch.com`)
3. **Mettez à jour** l'URL dans l'app iOS

### 5.2 Notifications push
1. **Configurez** Firebase Cloud Messaging
2. **Ajoutez** les certificats iOS
3. **Implémentez** les notifications dans l'API

### 5.3 Monitoring
1. **Configurez** les logs Railway
2. **Ajoutez** Sentry pour le monitoring
3. **Configurez** les alertes

## 📊 Étape 6 : Données de test

### 6.1 Créer des utilisateurs de test
```sql
-- Joueur de test
INSERT INTO users (email, password, name, role, age, city, sports, level, status)
VALUES (
  'joueur@test.com',
  '$2a$10$...', -- Mot de passe hashé
  'Joueur Test',
  'player',
  25,
  'Paris',
  ARRAY['football', 'basketball'],
  'intermediate',
  'available'
);

-- Club de test
INSERT INTO users (email, password, name, role, club_name, city, sports_offered)
VALUES (
  'club@test.com',
  '$2a$10$...', -- Mot de passe hashé
  'Club Test',
  'club',
  'FC Test',
  'Paris',
  ARRAY['football', 'basketball']
);
```

### 6.2 Créer des offres de test
```sql
INSERT INTO offers (club_id, title, description, sport, position, level, location, city)
VALUES (
  (SELECT id FROM users WHERE email = 'club@test.com'),
  'Recherche gardien de but',
  'Notre équipe cherche un gardien expérimenté',
  'football',
  'Gardien',
  'intermediate',
  'Stade Municipal',
  'Paris'
);
```

## 🚨 Dépannage

### Problèmes courants

#### API ne répond pas
- Vérifiez que Railway est déployé
- Vérifiez les logs Railway
- Vérifiez les variables d'environnement

#### Erreur de base de données
- Vérifiez que Supabase est configuré
- Vérifiez que le schéma est créé
- Vérifiez les clés API

#### Erreur CORS
- Vérifiez que CORS_ORIGIN est configuré
- Ajoutez votre domaine dans les origines autorisées

#### Erreur d'authentification
- Vérifiez que JWT_SECRET est défini
- Vérifiez que le token n'est pas expiré

### Logs utiles
```bash
# Logs Railway
railway logs

# Logs Supabase
# Allez dans Supabase → Logs
```

## 📈 Étape 7 : Optimisation

### 7.1 Performance
- **Cache** des requêtes fréquentes
- **Pagination** des listes
- **Compression** des images
- **CDN** pour les assets

### 7.2 Sécurité
- **HTTPS** obligatoire
- **Rate limiting** sur l'API
- **Validation** des données
- **Audit** des logs

### 7.3 Monitoring
- **Métriques** de performance
- **Alertes** en cas de problème
- **Backup** de la base de données

## 🎯 Étape 8 : Mise en production

### 8.1 Checklist finale
- [ ] API déployée et fonctionnelle
- [ ] Base de données configurée
- [ ] App iOS connectée à l'API
- [ ] Tests passés
- [ ] Monitoring configuré
- [ ] Backup configuré

### 8.2 Lancement
1. **Testez** tous les flux utilisateur
2. **Vérifiez** les performances
3. **Configurez** les alertes
4. **Lancez** l'application !

## 🆘 Support

En cas de problème :
- **GitHub Issues** : Créez une issue
- **Email** : support@sportsmatch.com
- **Documentation** : Consultez les README

---

**Félicitations ! Votre application SportsMatch est maintenant déployée !** 🏆

*Trouve ton équipe. Trouve ton match.*
