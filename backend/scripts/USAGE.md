# 🚀 Guide rapide - Données mock

## Insérer des données de test

```bash
cd backend
npm run seed:mock
```

**Durée estimée** : 2-5 minutes selon la connexion à Supabase

**Résultat** : 
- ~60-75 joueurs dans tous les sports
- ~30-45 clubs dans tous les sports  
- ~100-150 offres variées
- ~100-200 candidatures
- ~50-100 conversations avec messages

## Se connecter avec un compte mock

Après avoir exécuté le script, vous pouvez vous connecter avec :

**Email** : `mock.player.football.0_MOCK_@sportsmatch.test`  
**Mot de passe** : `mock123456`

Ou n'importe quel autre compte mock (consultez les logs du script pour voir tous les emails créés).

## Supprimer les données mock

```bash
cd backend
npm run remove:mock
```

⚠️ **Attention** : Supprime définitivement toutes les données mock !

## Tester toutes les vues de l'app

Les données mock alimentent :

✅ **Feed des offres** - Offres variées dans tous les sports  
✅ **Recherche** - Joueurs et clubs dans tous les sports  
✅ **Mes candidatures** - Candidatures pour les joueurs  
✅ **Mes offres** - Offres créées par les clubs  
✅ **Messages** - Conversations entre joueurs et clubs  
✅ **Profil** - Profils complets avec toutes les infos  

## Format des emails mock

- Joueurs : `mock.player.{sport}.{index}_MOCK_@sportsmatch.test`
- Clubs : `mock.club.{sport}.{index}_MOCK_@sportsmatch.test`

Tous les comptes ont le mot de passe : **`mock123456`**

