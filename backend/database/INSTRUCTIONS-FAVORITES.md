# Instructions pour activer les favoris

## Étape 1 : Créer la table dans Supabase

1. Va sur [supabase.com](https://supabase.com)
2. Connecte-toi à ton projet
3. Va dans **SQL Editor**
4. Copie-colle tout le contenu du fichier `add-favorites-table.sql`
5. Clique sur **Run** ou `Cmd/Ctrl + Enter`

## Étape 2 : Vérifier que la table est créée

Dans Supabase, va dans **Table Editor** → Tu devrais voir la table `favorites`

## Étape 3 : Redémarrer le serveur (si besoin)

Si ton serveur est déjà en cours d'exécution, il n'est pas nécessaire de le redémarrer car les routes sont déjà configurées.

Si tu dois redémarrer :
```bash
cd backend
npm start
```

## Vérification

Une fois la table créée, tu peux tester en :
1. Ouvrant l'app iOS
2. Consultant une offre
3. Cliquant sur le cœur ❤️
4. Allant dans Profil → Favoris → Onglet "Offres"

L'offre devrait apparaître dans tes favoris !

## Notes importantes

⚠️ **RLS (Row Level Security)** : Les policies sont configurées pour permettre toutes les opérations car l'authentification est gérée par le middleware JWT dans le backend. La sécurité est assurée par les routes API qui vérifient le token.

