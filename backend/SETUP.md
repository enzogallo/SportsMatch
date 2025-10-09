# 🚀 Guide de configuration - SportsMatch Backend

## 📋 Étapes de configuration

### 1. 🗄️ Configuration Supabase

#### Créer un projet Supabase
1. **Allez** sur [supabase.com](https://supabase.com)
2. **Créez** un compte (gratuit)
3. **Cliquez** sur "New Project"
4. **Choisissez** une organisation
5. **Nommez** votre projet : `sportsmatch`
6. **Générez** un mot de passe fort
7. **Sélectionnez** une région proche (Europe West)
8. **Cliquez** sur "Create new project"

#### Configurer la base de données
1. **Allez** dans l'onglet "SQL Editor"
2. **Cliquez** sur "New query"
3. **Copiez-collez** le contenu de `database/schema.sql`
4. **Exécutez** le script (bouton "Run")
5. **Vérifiez** que toutes les tables sont créées

#### Récupérer les clés API
1. **Allez** dans "Settings" → "API"
2. **Copiez** :
   - `Project URL` → `SUPABASE_URL`
   - `anon public` → `SUPABASE_ANON_KEY`
   - `service_role` → `SUPABASE_SERVICE_ROLE_KEY`

### 2. 🚂 Configuration Railway (Optionnel)

#### Créer un compte Railway
1. **Allez** sur [railway.app](https://railway.app)
2. **Connectez** avec GitHub
3. **Autorisez** l'accès à vos repositories

#### Déployer l'API
1. **Cliquez** sur "New Project"
2. **Sélectionnez** "Deploy from GitHub repo"
3. **Choisissez** votre repository `SportsMatch`
4. **Sélectionnez** le dossier `backend`
5. **Cliquez** sur "Deploy"

#### Configurer les variables d'environnement
Dans Railway, ajoutez ces variables :
```
SUPABASE_URL=votre_url_supabase
SUPABASE_ANON_KEY=votre_cle_anon
SUPABASE_SERVICE_ROLE_KEY=votre_cle_service
JWT_SECRET=votre_secret_jwt_securise
NODE_ENV=production
CORS_ORIGIN=https://votre-domaine.com
```

### 3. 🔧 Configuration locale

#### Créer le fichier .env
```bash
cd backend
cp env.example .env
```

#### Modifier .env
```bash
# Supabase Configuration
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre_cle_anon
SUPABASE_SERVICE_ROLE_KEY=votre_cle_service

# JWT Secret (générez une clé sécurisée)
JWT_SECRET=votre_secret_jwt_tres_securise

# Server Configuration
PORT=3000
NODE_ENV=development

# CORS
CORS_ORIGIN=http://localhost:3000
```

#### Tester l'API localement
```bash
# Installation des dépendances
npm install

# Démarrage en mode développement
npm run dev

# Test de l'API
curl http://localhost:3000/api/health
```

### 4. 📱 Configuration iOS

#### Mettre à jour l'URL de l'API
Dans votre app iOS, modifiez `AppConfig.swift` :
```swift
static let baseURL = "https://votre-api.railway.app" // ou localhost:3000 pour le dev
```

#### Tester la connexion
L'API devrait répondre à :
- `GET /api/health` - Vérification de santé
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion

## ✅ Vérification

### Test de l'API
```bash
# Health check
curl https://votre-api.railway.app/api/health

# Inscription test
curl -X POST https://votre-api.railway.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User","role":"player"}'
```

### Test de la base de données
1. **Allez** dans Supabase → Table Editor
2. **Vérifiez** que les tables sont créées
3. **Testez** l'insertion d'un utilisateur

## 🆘 Dépannage

### Erreurs courantes

#### "Missing Supabase environment variables"
- Vérifiez que vos variables d'environnement sont correctement définies
- Redémarrez votre serveur après modification du .env

#### "Invalid token"
- Vérifiez que JWT_SECRET est défini
- Vérifiez que le token n'est pas expiré

#### "User not found"
- Vérifiez que l'utilisateur existe dans la base de données
- Vérifiez que l'ID utilisateur est correct

#### Erreurs CORS
- Vérifiez que CORS_ORIGIN est correctement configuré
- Ajoutez votre domaine iOS dans les origines autorisées

### Logs utiles
```bash
# Logs Railway
railway logs

# Logs locaux
npm run dev
```

## 🎯 Prochaines étapes

1. **Testez** tous les endpoints
2. **Intégrez** l'API dans votre app iOS
3. **Déployez** en production
4. **Configurez** les notifications push
5. **Ajoutez** la gestion d'erreurs

---

**Votre backend SportsMatch est maintenant prêt !** 🏆
