# MarIA Willy RPG

This repository contains the initial scaffolding for the **MarIA Willy RPG** iOS application. The project is organised into several modules (`App`, `Core`, `Services`, `Tests`) to keep business logic separate from user interface and platform integrations.

## Structure

- **App** – SwiftUI entry point and scenes. This module wires together view models and services.
- **Core** – Pure Swift code containing data models and the `GameEngine`. The engine applies game rules to mutate the `AppState`.
- **Services** – Protocol‐based abstractions for platform features such as HealthKit, notifications, storage and meal analysis. Each service has at least a real implementation and a mock.
- **Tests** – Unit tests targeting the game engine and rotation logic.

The project is not yet a complete application. Further steps will add concrete implementations, UI, storage rotation, reports and unit tests.

## Getting Started

1. Open the Xcode project (to be created) in Xcode 15 or later.
2. Select the `MarIAWillyRPG` scheme and run on the iOS 17 simulator.
3. Use Swift Package Manager if you prefer to build the `Core` module in isolation.

## Enable Capabilities

Certain platform features require explicit entitlements and privacy descriptions:

1. **HealthKit (lecture seule)** — activez la capacité *HealthKit* dans l’onglet **Signing & Capabilities** de votre cible et associez‑y le fichier `App/MarIAWillyRPG.entitlements`. Les clés `NSHealthShareUsageDescription` et `NSHealthUpdateUsageDescription` déjà présentes dans *Info.plist* décrivent pourquoi ces données sont nécessaires.
2. **Notifications locales** — aucune capacité supplémentaire n’est requise pour les notifications locales, mais veillez à demander l’autorisation à l’utilisateur via `UNUserNotificationCenter` avant de programmer les rapports de 14 h et 23 h.
3. **Modes en arrière‑plan** — si vous souhaitez que l’application effectue des opérations périodiques en arrière‑plan (par exemple, synchroniser des données ou générer des rapports), activez l’option *Background fetch* dans les modes d’exécution en arrière‑plan.
4. **Appareil photo et photothèque** — l’application peut capturer des photos de repas et enregistrer des captures ou des bandes dessinées. Les clés `NSCameraUsageDescription` et `NSPhotoLibraryAddUsageDescription` du *Info.plist* expliquent ces usages.

Après avoir activé ces capacités dans Xcode et configuré vos profils de signature, l’application sera prête à tourner sur un appareil réel.

## Export / Import

Le menu **Réglages** (accessible depuis l’icône en forme d’engrenage dans l’écran d’accueil) permet :

1. **Exporter l’état en JSON** : écrit le fichier `state.json` dans `Documents/export/`.
2. **Exporter l’état en YAML** : convertit l’état en YAML et l’enregistre dans `Documents/export/state.yaml`.
3. **Quota de stockage** : ajuster la taille maximale de stockage local entre 25 et 500 Mo via un `Stepper`.
4. **Afficher l’usage** : rafraîchir et afficher l’espace occupé (en Mo) par l’application et comparer avec le quota configuré.

⚠️ L’importation d’un fichier JSON ou YAML n’est pas encore implémentée ; un message d’information est affiché dans la vue Réglages.

## Tests et CI locale

Le dépôt comprend plusieurs tests unitaires couvrant le moteur de jeu (`GameEngine`), la rotation du stockage et un test d’interface placeholder pour les rapports.

Pour exécuter les tests :

1. Ouvrez le projet dans Xcode et créez un schéma appelé **MarIAWillyRPG** qui inclut les cibles d’app et de tests.
2. Assurez‑vous de disposer d’un simulateur iOS 17 (ex. iPhone 15).
3. Dans un terminal, exécutez :

```bash
./scripts/run_tests.sh
```

Ce script appelle `xcodebuild` pour lancer les tests sur le simulateur. Les résultats sont formatés via `xcpretty` (que vous pouvez installer via Homebrew). Vous pouvez également lancer les tests directement depuis Xcode en sélectionnant le schéma et en appuyant sur ⌘U.
