# Scripts de données mock - SportsMatch

Ce dossier contient les scripts pour gérer les données de test (mock data) dans la base de données.

## 📋 Scripts disponibles

### 🌱 `seed-mock-data.js` - Insérer des données de test

Ce script crée des données de test complètes pour alimenter toutes les vues de l'application :

- **Joueurs** : 3-5 joueurs par sport (15 sports = ~60 joueurs)
- **Clubs** : 2-3 clubs par sport (15 sports = ~37 clubs)
- **Offres** : 2-4 offres par club (~110 offres)
- **Candidatures** : Chaque joueur postule à 1-3 offres correspondantes
- **Conversations** : Conversations entre joueurs et clubs
- **Messages** : 2-6 messages par conversation

#### Caractéristiques des données mock

- **Identification** : Tous les emails mock contiennent le préfixe `_MOCK_`
- **Mot de passe** : `mock123456` (identique pour tous les comptes mock)
- **Couverture** : Tous les 15 sports sont représentés
- **Variété** : Différents niveaux, positions, statuts, types d'offres

#### Utilisation

```bash
# Depuis le dossier backend
npm run seed:mock

# Ou directement
node scripts/seed-mock-data.js
```

#### Exemple d'emails créés

- `mock.player.football.0_MOCK_@sportsmatch.test`
- `mock.club.basketball.1_MOCK_@sportsmatch.test`

### 🗑️ `remove-mock-data.js` - Supprimer les données mock

Ce script supprime **toutes** les données mock de la base de données :

- Utilisateurs mock (joueurs et clubs)
- Offres créées par les clubs mock
- Candidatures des joueurs mock
- Conversations impliquant des utilisateurs mock
- Messages dans ces conversations
- Abonnements mock

#### Utilisation

```bash
# Depuis le dossier backend
npm run remove:mock

# Ou directement
node scripts/remove-mock-data.js

# Mode force (sans confirmation)
FORCE_DELETE=true npm run remove:mock
```

#### ⚠️ Attention

Ce script supprime **définitivement** toutes les données mock. Assurez-vous que :
- Vous avez bien créé vos propres comptes de test
- Vous n'avez pas de données importantes stockées dans les comptes mock

## 🎯 Cas d'usage

### Scénario 1 : Tester l'application avec des données réalistes

```bash
# 1. Insérer les données mock
npm run seed:mock

# 2. Se connecter avec un compte mock
# Email: mock.player.football.0_MOCK_@sportsmatch.test
# Password: mock123456

# 3. Explorer toutes les fonctionnalités avec des données complètes
```

### Scénario 2 : Réinitialiser après les tests

```bash
# Supprimer toutes les données mock
npm run remove:mock

# Réinsérer des données fraîches si besoin
npm run seed:mock
```

### Scénario 3 : Préparer l'app pour la production

```bash
# Avant le déploiement, supprimer toutes les données de test
npm run remove:mock

# Vérifier qu'il ne reste aucune donnée mock dans la base
```

## 📊 Statistiques des données mock

Après l'exécution du script `seed-mock-data.js`, vous devriez avoir environ :

- **60-75 joueurs** répartis sur 15 sports
- **30-45 clubs** répartis sur 15 sports
- **80-150 offres** variées (recrutement, tournoi, entraînement, remplacement)
- **60-200 candidatures** (selon les matches sport/joueur)
- **50-100 conversations** avec messages

## 🔍 Identifier les données mock

Toutes les données mock sont identifiables par :

1. **Emails** : Contiennent le préfixe `_MOCK_`
2. **Nom des comptes** : Patterns reconnaissables (`mock.player.*`, `mock.club.*`)
3. **Dates** : Créées récemment (dans les 90 derniers jours)

## 📝 Notes techniques

- Les scripts utilisent `supabaseAdmin` pour bypasser RLS (Row Level Security)
- Les mots de passe sont hashés avec `bcryptjs`
- Les données sont créées avec des timestamps aléatoires pour simuler une utilisation réelle
- Les relations entre données (offres -> candidatures -> conversations) sont cohérentes

## 🚀 Avant la production

Avant de rendre l'application live :

```bash
# 1. Vérifier qu'il n'y a plus de données mock
node scripts/remove-mock-data.js

# 2. Vérifier dans Supabase qu'il ne reste aucune donnée avec "_MOCK_" dans l'email

# 3. Créer des comptes de test réels si nécessaire
```

