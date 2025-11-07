# ScreenSnap 📸

Application macOS native pour prendre des captures d'écran rapides et les coller directement dans vos IDEs (VSCode, Cursor, Zed, etc.). Design moderne avec interface Liquid Glass et workflow optimisé.

## ✨ Fonctionnalités

### 🎯 Capture rapide
- **Raccourci clavier global** : `⌥⌘S` pour capturer une zone instantanément
- **Capture de fenêtre** : Sélectionnez une fenêtre spécifique dans la liste
- **Sélection interactive** : Cliquez et glissez pour définir la zone
- **Copie automatique** : L'image est copiée dans le presse-papiers (`⌘V` direct)
- **Sauvegarde optionnelle** : Enregistrez vos captures dans un dossier de votre choix

### 🎨 Interface moderne
- **Menu bar discret** : Icône personnalisée dans la barre de menu
- **Dynamic Island** : Notification "pill" temporaire dans la menu bar
- **Liquid Glass UI** : Design moderne avec effets de transparence
- **Onboarding** : Tutoriel au premier lancement

### ⚙️ Options complètes
- **Formats multiples** : PNG (sans perte) ou JPEG (compressé)
- **Dossier temporaire** : Stockage dans `/tmp` par défaut (parfait pour les IDE)
- **Accès rapide** : Menu "Voir la dernière capture" pour ouvrir dans le Finder
- **Sons et feedback** : Retour audio et visuel lors de la capture
- **Gestion des permissions** : Assistant pour configurer les autorisations macOS

## 🚀 Installation

### Prérequis
- macOS 13.0 (Ventura) ou supérieur
- Xcode 15+ avec Swift 5.9+

### Compilation

1. **Cloner le repository** :
   ```bash
   git clone https://github.com/votre-username/ScreenSnap.git
   cd ScreenSnap
   ```

2. **Ouvrir le projet dans Xcode** :
   ```bash
   open ScreenSnap/ScreenSnap.xcodeproj
   ```

3. **Configurer le projet** :
   - Sélectionnez votre équipe de développement dans "Signing & Capabilities"
   - Vérifiez que le Bundle Identifier est unique (ex: `com.augiefra.ScreenSnap`)

4. **Compiler et lancer** :
   - Appuyez sur `⌘R` pour compiler et lancer
   - L'icône apparaîtra dans la barre de menu

### Installation permanente

Pour installer l'application de manière permanente :

1. **Créer une archive** :
   - Product → Archive dans Xcode
   - Distribuez l'application localement

2. **Copier vers Applications** :
   ```bash
   cp -r ~/Library/Developer/Xcode/DerivedData/.../ScreenSnap.app /Applications/
   ```

3. **Ajouter au démarrage automatique** (optionnel) :
   - Préférences Système → Utilisateurs et groupes → Éléments de connexion
   - Ajoutez ScreenSnap

## 🎯 Utilisation

### Premier lancement

Au premier démarrage, un tutoriel vous guidera à travers les fonctionnalités principales. Si vous souhaitez le revoir, cliquez sur "Afficher le tutoriel de démarrage" dans les Préférences.

### Prendre une capture

**Méthode 1 : Raccourci clavier (recommandé)**
1. Appuyez sur `⌥⌘S` (Option + Command + S)
2. Sélectionnez la zone à capturer en cliquant et glissant
3. La capture est automatiquement copiée dans le presse-papiers
4. Une notification "pill" apparaît brièvement dans la menu bar

**Méthode 2 : Menu bar**
1. Cliquez sur l'icône dans la barre de menu
2. Sélectionnez "📸 Capturer une zone"
3. Sélectionnez la zone à capturer

**Méthode 3 : Capture de fenêtre**
1. Cliquez sur l'icône dans la barre de menu
2. Sélectionnez "🪟 Capturer une fenêtre"
3. Choisissez la fenêtre dans la liste

### Coller dans votre IDE

Une fois la capture effectuée :
- **VSCode** : `⌘V` dans un fichier Markdown ou dans le chat
- **Cursor** : `⌘V` dans l'éditeur ou le chat
- **Zed** : `⌘V` dans l'éditeur
- **Tout autre éditeur** : `⌘V` fonctionne partout !

### Accéder à la dernière capture

1. Cliquez sur l'icône dans la barre de menu
2. Sélectionnez "📁 Voir la dernière capture"
3. Le Finder s'ouvre et sélectionne votre fichier

## ⚙️ Configuration

Cliquez sur l'icône dans la barre de menu, puis "⚙️ Préférences..."

### Onglet Général
- ✅ **Copier dans le presse-papiers** : Copie automatique pour `⌘V`
- ✅ **Jouer un son lors de la capture** : Feedback audio
- ✅ **Afficher les dimensions** : Affiche la taille pendant la sélection
- ✅ **Activer les annotations** : (À venir) Annotations avant sauvegarde

### Onglet Capture
- **Format d'image** : PNG (recommandé) ou JPEG
- **Raccourci clavier** : Toggle pour activer/désactiver `⌥⌘S`
- **Status** : Affiche l'état du raccourci et des permissions

### Onglet Stockage
- ✅ **Enregistrer sur le disque** : Active/désactive la sauvegarde
- **Dossier de sauvegarde** : Choisissez votre dossier (défaut: `/tmp`)
- **Ouvrir le dossier** : Accès rapide à vos captures
- **Vider le dossier** : Supprime toutes les captures

## 🔐 Permissions requises

L'application nécessite deux permissions macOS :

### 1. Enregistrement d'écran (obligatoire)
Pour capturer le contenu de l'écran.

**Configuration** :
- Préférences Système → Confidentialité et sécurité → Enregistrement d'écran
- Cocher "ScreenSnap"
- Redémarrer l'application

### 2. Accessibilité (pour raccourci global)
Pour que le raccourci `⌥⌘S` fonctionne globalement.

**Configuration pour builds de développement** :
1. Préférences Système → Confidentialité et sécurité → Accessibilité
2. Cliquez sur "+" pour ajouter manuellement
3. Naviguez vers l'emplacement de ScreenSnap.app
4. Cochez la case à côté de ScreenSnap
5. Redémarrez l'application

**Note** : Les builds signées apparaissent automatiquement dans la liste.

## 🏗️ Architecture

### Structure du projet

```
ScreenSnap/
├── ScreenSnap/
│   ├── ScreenSnapApp.swift              # Point d'entrée, AppDelegate
│   ├── Models/
│   │   └── AppSettings.swift            # Gestion des préférences (@AppStorage)
│   ├── Services/
│   │   ├── ScreenshotService.swift      # Capture d'écran CGDisplay
│   │   ├── WindowCaptureService.swift   # Capture de fenêtres (ScreenCaptureKit)
│   │   ├── PermissionManager.swift      # Gestion centralisée des permissions
│   │   └── DynamicIslandManager.swift   # Notification "pill" dans menu bar
│   ├── Views/
│   │   ├── SettingsView.swift           # Fenêtre de préférences (3 tabs)
│   │   ├── MenuBarPopoverView.swift     # Popover Liquid Glass
│   │   ├── OnboardingView_Simple.swift  # Tutoriel premier lancement
│   │   └── SelectionWindow.swift        # Fenêtre de sélection de zone
│   └── Assets.xcassets/
│       ├── AppIcon.appiconset/          # Icône de l'application
│       └── MenuBarIcon.imageset/        # Icône menu bar personnalisée
├── Info.plist                           # Configuration app (LSUIElement, permissions)
└── ScreenSnap.entitlements             # Sandboxing et autorisations
```

### Technologies utilisées

- **SwiftUI** : Interface utilisateur moderne
- **AppKit** : Menu bar, fenêtres système, NSStatusItem
- **ScreenCaptureKit** : Capture de fenêtres (macOS 12.3+)
- **CoreGraphics** : Capture d'écran via CGDisplayCreateImage
- **UserNotifications** : Notifications macOS modernes
- **Carbon API** : Enregistrement des raccourcis clavier globaux

### Patterns architecturaux

- **MVVM** : Séparation modèle/vue/services
- **Singleton** : AppSettings, PermissionManager, DynamicIslandManager
- **NotificationCenter** : Communication inter-services
- **@AppStorage** : Persistence automatique via UserDefaults

## 🐛 Dépannage

### L'icône n'apparaît pas dans la barre de menu
- Vérifiez que l'application est bien lancée
- Vérifiez que `LSUIElement = YES` dans Info.plist
- Redémarrez l'application

### Le raccourci clavier ne fonctionne pas
1. Vérifiez que le raccourci est activé dans Préférences → Capture
2. Vérifiez les permissions Accessibilité (voir section Permissions)
3. Pour les builds de développement, ajoutez manuellement l'app avec "+"
4. Assurez-vous qu'aucune autre app n'utilise `⌥⌘S`

### La capture ne se colle pas dans mon IDE
- Vérifiez que "Copier dans le presse-papiers" est activé
- Testez dans un autre éditeur pour confirmer
- Vérifiez les permissions "Enregistrement d'écran"

### La capture de fenêtre ne fonctionne pas
- Nécessite macOS 12.3+ pour ScreenCaptureKit
- Certaines fenêtres système ne peuvent pas être capturées (sécurité)
- Vérifiez les permissions "Enregistrement d'écran"

### Le Dynamic Island (pill) n'apparaît pas
- C'est normal - la pill est temporaire (2 secondes)
- Elle apparaît juste devant l'icône menu bar
- Vérifiez la console pour les logs `[ISLAND]`

## 🎨 Personnalisation

### Changer le dossier de sauvegarde

1. Ouvrez les Préférences
2. Onglet "Stockage"
3. Cliquez sur "Changer..."
4. Sélectionnez votre dossier

**Dossiers recommandés** :
- `/tmp/ScreenSnap/` : Temporaire (par défaut)
- `~/Desktop/Screenshots/` : Bureau
- `~/Documents/Screenshots/` : Documents
- `~/Pictures/ScreenSnap/` : Photos

### Changer le format d'image

1. Ouvrez les Préférences
2. Onglet "Capture"
3. Sélectionnez "PNG (sans perte)" ou "JPEG (compressé)"

**Recommandations** :
- **PNG** : Code, texte, interface (qualité maximale)
- **JPEG** : Photos, images (fichiers plus légers)

## 📝 Feuille de route

### Phase 1 (P0) : Stabilité ✅
- [x] Capture d'écran avec sélection de zone
- [x] Capture de fenêtres spécifiques
- [x] Copie automatique dans le presse-papiers
- [x] Raccourci clavier global
- [x] Gestion complète des permissions
- [x] Onboarding au premier lancement
- [x] Dynamic Island notification

### Phase 2 (P1) : Modernisation
- [ ] Migration vers ScreenCaptureKit uniquement
- [ ] Refactoring MVVM complet
- [ ] Tests unitaires et d'intégration
- [ ] Historique des captures

### Phase 3 (P2) : Fonctionnalités avancées
- [ ] Outils d'annotation (flèches, texte, blur)
- [ ] OCR automatique (Vision framework)
- [ ] Détection QR codes
- [ ] Scrolling capture
- [ ] Export vers le cloud

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Ouvrir une issue pour signaler un bug
- Proposer une pull request pour une amélioration
- Suggérer de nouvelles fonctionnalités

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

## 💡 Conseils d'utilisation

### Pour les développeurs
- Parfait pour partager des captures de code ou d'erreurs dans les chats AI
- Intégration transparente avec VSCode, Cursor, Zed
- Raccourci rapide pour capturer des bugs visuels

### Pour les designers
- Capture rapide d'inspirations
- Annotations à venir pour feedback visuel
- Export vers le cloud planifié

### Pour les formateurs
- Excellent pour créer des tutoriels
- Capture de fenêtres spécifiques
- Qualité PNG pour des screenshots nets

---

Développé avec ❤️ et Claude Code
