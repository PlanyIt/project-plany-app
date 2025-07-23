# Plany Flutter App

Plany is the mobile client for the Plany project, built with Flutter. It allows users to browse, create, and manage collaborative plans, steps, comments, and categories, with real-time data from the backend API.

---

## Features

- User authentication (JWT, secure storage)
- Browse and manage plans, steps, categories, comments
- Map integration (flutter_map, geolocation)
- Image caching and optimized loading
- Local data caching for offline support
- Responsive UI, theming, and animations

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10+ recommandé)
- Backend API access (voir `/back`)

### Installation & Setup

1. Clone le dépôt et va dans `/front` :
   ```bash
   cd front
   ```
2. Installe les dépendances :

   ```bash
   flutter pub get
   ```

3. Crée un fichier `.env` dans `/front` :

   ```env
   BASE_URL=https://your-backend-api-url.com
   ```

   **Si tu lances le backend en local (et pas via Render), ajoute aussi `.env.local` dans la section `assets` de ton `pubspec.yaml` :**

   ```yaml
   flutter:
     assets:
       - .env.local
   ```

4. (Optionnel) Configure la signature Android/iOS pour les builds release.

### Lancer l'application

- Développement :
  ```bash
  flutter run
  ```
- Avec environnement :
  ```bash
  flutter run --dart-define=ENV=local
  flutter run --dart-define=ENV=staging
  ```

### Commandes utiles

- Générer le code :
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- Lancer les tests :
  ```bash
  flutter test
  flutter test integration_test/app_test.dart --dart-define=IS_TEST=true
  ```

---

## Structure du projet

```
front/
  lib/         # Code principal de l'app (UI, data, domain, utils)
  assets/      # Images et assets statiques
  test/        # Tests unitaires et widgets
  integration_test/ # Tests d'intégration
```

---

## CI/CD

- Voir le fichier racine `codemagic.yaml` pour l'intégration build, test et SonarCloud.

---

## Backend

Cette application mobile communique avec l'API backend Plany (NestJS/MongoDB). Voir [`/back`](../back/README.md) pour la configuration et le lancement du serveur.

---

## Licence

MIT

---

## Auteurs

Plany Team
