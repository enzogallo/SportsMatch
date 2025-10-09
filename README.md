# 🏆 SportsMatch - iOS App

## 📱 Description

SportsMatch est une application iOS qui connecte les joueurs et les clubs de tous les sports. C'est la plateforme qui simplifie la recherche d'équipe, de joueur ou de club, sans promesse de carrière pro — juste une mise en relation fluide, locale et multisport.

**"Parce que le sport, c'est avant tout une histoire de rencontres."**

## 🎯 Fonctionnalités principales

### Pour les Joueurs
- ✅ Création de profil personnalisé avec sports, niveau et position
- ✅ Découverte d'offres de recrutement avec filtres avancés
- ✅ Candidature directe aux offres avec message personnalisé
- ✅ Messagerie intégrée avec les clubs
- ✅ Recherche de clubs et autres joueurs
- ✅ Gestion des candidatures et favoris

### Pour les Clubs
- ✅ Création de profil club avec informations détaillées
- ✅ Publication d'offres de recrutement
- ✅ Gestion des candidatures reçues
- ✅ Messagerie avec les candidats
- ✅ Statistiques sur les offres publiées

### Fonctionnalités transverses
- ✅ Système d'authentification sécurisé
- ✅ Design moderne et fluide optimisé pour iOS
- ✅ Notifications push personnalisables
- ✅ Système d'abonnement freemium
- ✅ Support multilingue (français)

## 🏗️ Architecture technique

### Structure du projet
```
SportsMatch/
├── Models/                 # Modèles de données
│   ├── User.swift
│   ├── Offer.swift
│   ├── Message.swift
│   └── Subscription.swift
├── Views/                  # Vues SwiftUI
│   ├── Authentication/     # Connexion/Inscription
│   ├── Main/              # Navigation principale
│   ├── Feed/              # Feed des offres
│   ├── Search/            # Recherche
│   ├── Messages/          # Messagerie
│   ├── Profile/           # Profil utilisateur
│   └── Offers/            # Gestion des offres
├── Services/              # Services métier
│   ├── AuthService.swift
│   └── OfferService.swift
├── DesignSystem/          # Système de design
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Spacing.swift
│   └── Components/
└── Utils/                 # Utilitaires
    └── AppConfig.swift
```

### Technologies utilisées
- **SwiftUI** - Interface utilisateur moderne
- **Combine** - Gestion réactive des données
- **Async/Await** - Programmation asynchrone
- **MVVM** - Architecture Model-View-ViewModel

## 🎨 Design System

### Couleurs
- **Bleu principal** : #0066FF (confiance, sport, connexion)
- **Vert secondaire** : #00C27A (énergie, esprit positif)
- **Neutres** : Blanc et gris clair pour la lisibilité

### Typographie
- **Titres** : Police système avec poids bold et design rounded
- **Corps** : Police système standard pour la lisibilité
- **Boutons** : Police système avec poids semibold

### Composants
- **Cards** : Cartes avec coins arrondis et ombres subtiles
- **Boutons** : Styles primaire, secondaire et success
- **Champs de saisie** : Design cohérent avec validation visuelle

## 🚀 Installation et configuration

### Prérequis
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation
1. Cloner le repository
2. Ouvrir `SportsMatch.xcodeproj` dans Xcode
3. Configurer les certificats de développement
4. Compiler et lancer sur simulateur ou appareil

### Configuration
1. Modifier `AppConfig.swift` pour configurer l'API
2. Ajouter les clés de service (push notifications, etc.)
3. Configurer les environnements (dev, staging, prod)

## 📱 Captures d'écran

L'application propose une interface moderne et intuitive avec :
- Écran de connexion élégant
- Feed d'offres avec cartes attrayantes
- Profils détaillés pour joueurs et clubs
- Système de messagerie intégré
- Recherche avancée avec filtres

## 🔮 Roadmap

### Phase 1 - MVP (Actuelle)
- [x] Authentification de base
- [x] Profils joueurs et clubs
- [x] Système d'offres et candidatures
- [x] Messagerie simple
- [x] Interface utilisateur moderne

### Phase 2 - Engagement
- [ ] Notifications push avancées
- [ ] Système de matching IA
- [ ] Badges de vérification
- [ ] Statistiques détaillées
- [ ] Système de favoris

### Phase 3 - Expansion
- [ ] Version Android
- [ ] Support multilingue étendu
- [ ] Offres sponsorisées
- [ ] Intégration réseaux sociaux
- [ ] API publique

## 💰 Business Model

### Freemium
- **Gratuit** : 3 candidatures/semaine, fonctionnalités de base
- **Premium Joueur** : 2,99€/mois - Candidatures illimitées, sans pub, mise en avant
- **Premium Club** : 9,99€/mois - Offres illimitées, statistiques, visibilité

### Monétisation
- Abonnements premium
- Publicités discrètes (Google AdMob)
- Offres sponsorisées pour les clubs

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Contact

- **Développeur** : Enzo Gallo
- **Email** : contact@sportsmatch.com
- **Site web** : https://sportsmatch.com

---

**SportsMatch** - *Trouve ton équipe. Trouve ton match.* 🏆
