# 📦 Guide de distribution ScreenSnap

Guide complet pour créer un DMG installable et distribuer ScreenSnap.

## 🎯 Options de distribution

### Option 1 : Distribution simple (amis, beta testeurs)
- Signature automatique Xcode
- Pas de notarisation
- ⚠️ Les utilisateurs verront "Développeur non vérifié"
- Temps : **5 minutes**

### Option 2 : Distribution publique (recommandé)
- Signature avec certificat Developer ID
- Notarisation Apple obligatoire
- ✅ Installation sans avertissement
- Temps : **30 minutes** (première fois)

---

## 📋 Prérequis

### Pour Option 1 (Simple)
- ✅ Compte développeur Apple (gratuit suffit)
- ✅ Xcode configuré avec votre Team

### Pour Option 2 (Publique)
- ✅ **Apple Developer Program** ($99/an) - OBLIGATOIRE
- ✅ Certificat "Developer ID Application"
- ✅ App-specific password pour notarization

---

## 🚀 Option 1 : DMG Simple (Beta/Test)

### Étape 1 : Archiver l'application

Dans Xcode :
1. Sélectionnez **"Any Mac (Apple Silicon, Intel)"** comme destination
2. **Product → Archive**
3. Attendez la fin de la compilation
4. La fenêtre "Organizer" s'ouvre

### Étape 2 : Exporter l'application

Dans Organizer :
1. Sélectionnez votre archive
2. Cliquez **"Distribute App"**
3. Choisissez **"Copy App"**
4. **"Export"** (laissez les options par défaut)
5. Sauvegardez dans : `/Users/ecologni/Desktop/Clemadel/ScreenSnap/build/`
6. Vous obtenez : `ScreenSnap.app`

### Étape 3 : Créer le DMG

```bash
cd /Users/ecologni/Desktop/Clemadel/ScreenSnap

# Exécuter le script
./scripts/create-dmg.sh
```

Résultat : `build/ScreenSnap-1.0.0.dmg`

### Étape 4 : Tester

```bash
# Monter le DMG
open build/ScreenSnap-1.0.0.dmg

# Dans le Finder, glissez ScreenSnap vers Applications
```

⚠️ **Note** : Les utilisateurs devront faire **clic droit → Ouvrir** la première fois (message "Développeur non vérifié").

---

## 🔐 Option 2 : DMG Notarisé (Distribution publique)

### Étape 1 : Obtenir un certificat Developer ID

1. Aller sur https://developer.apple.com
2. **Certificates, Identifiers & Profiles**
3. **Certificates** → **+** (Créer)
4. Choisir **"Developer ID Application"**
5. Suivre les instructions pour créer une CSR
6. Télécharger et installer le certificat (double-clic)

### Étape 2 : Configurer Xcode pour signature

Dans Xcode :
1. Sélectionnez le projet **ScreenSnap**
2. Onglet **"Signing & Capabilities"**
3. **Signing Certificate** → Choisir **"Developer ID Application"**
4. Décochez **"Automatically manage signing"**

### Étape 3 : Archiver avec Developer ID

```bash
# Archiver en ligne de commande
cd /Users/ecologni/Desktop/Clemadel/ScreenSnap/ScreenSnap

xcodebuild archive \
  -scheme ScreenSnap \
  -archivePath build/ScreenSnap.xcarchive \
  CODE_SIGN_IDENTITY="Developer ID Application"
```

### Étape 4 : Exporter l'app signée

```bash
xcodebuild -exportArchive \
  -archivePath build/ScreenSnap.xcarchive \
  -exportPath build \
  -exportOptionsPlist exportOptions.plist
```

Créez d'abord `exportOptions.plist` :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>VOTRE_TEAM_ID</string>
</dict>
</plist>
```

### Étape 5 : Créer le DMG signé

```bash
./scripts/create-dmg.sh

# Signer le DMG
codesign --sign "Developer ID Application" build/ScreenSnap-1.0.0.dmg
```

### Étape 6 : Notarisation Apple

```bash
# Créer un app-specific password sur appleid.apple.com
# Puis soumettre pour notarization

xcrun notarytool submit build/ScreenSnap-1.0.0.dmg \
  --apple-id "votre@email.com" \
  --team-id "VOTRE_TEAM_ID" \
  --password "xxxx-xxxx-xxxx-xxxx"

# Attendre 2-5 minutes, puis vérifier le statut
xcrun notarytool history --apple-id "votre@email.com"

# Une fois approuvé, stapler le ticket
xcrun stapler staple build/ScreenSnap-1.0.0.dmg
```

### Étape 7 : Vérifier

```bash
# Vérifier la signature
codesign -dvv build/ScreenSnap-1.0.0.dmg

# Vérifier la notarization
spctl -a -vv -t install build/ScreenSnap-1.0.0.dmg
```

✅ Si vous voyez `accepted`, c'est prêt pour distribution publique !

---

## 🎨 DMG Avancé (avec fond personnalisé)

Pour un DMG professionnel avec arrière-plan stylé, utilisez **create-dmg** :

```bash
# Installer l'outil
brew install create-dmg

# Créer un DMG stylé
create-dmg \
  --volname "ScreenSnap" \
  --volicon "ScreenSnap/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "ScreenSnap.app" 200 190 \
  --hide-extension "ScreenSnap.app" \
  --app-drop-link 600 185 \
  "build/ScreenSnap-1.0.0.dmg" \
  "build/ScreenSnap.app"
```

---

## 📤 Distribution

### GitHub Releases (recommandé)

```bash
# Créer une release sur GitHub
gh release create v1.0.0 \
  build/ScreenSnap-1.0.0.dmg \
  --title "ScreenSnap v1.0.0" \
  --notes "Première version publique"
```

### Site web

Uploadez le DMG sur votre hébergeur et créez un lien de téléchargement.

### Homebrew Cask (avancé)

Pour permettre l'installation via `brew install --cask screensnap`, créez un Cask.

---

## 🐛 Résolution de problèmes

### "Développeur non vérifié"
→ L'utilisateur doit faire **clic droit → Ouvrir** la première fois
→ Ou vous devez notariser l'app (Option 2)

### "App endommagée"
→ Supprimez les attributs étendus : `xattr -cr ScreenSnap.app`

### Notarization échoue
→ Vérifiez que le Hardened Runtime est activé
→ Vérifiez que toutes les librairies sont signées

---

## 📊 Checklist finale

Avant de distribuer :

- [ ] L'app fonctionne sur une machine vierge
- [ ] Toutes les permissions sont demandées correctement
- [ ] L'icône apparaît dans le menu bar
- [ ] Les captures fonctionnent
- [ ] La copie clipboard fonctionne dans les IDEs
- [ ] Le DMG se monte correctement
- [ ] L'installation par glisser-déposer fonctionne
- [ ] L'app se lance depuis /Applications
- [ ] (Option 2) L'app est notarisée et validée

---

## 💡 Conseils

1. **Testez sur une machine propre** (sans Xcode)
2. **Testez sur Intel ET Apple Silicon** si possible
3. **Versionnez correctement** (semantic versioning : 1.0.0, 1.1.0, etc.)
4. **Créez un README** pour l'installation
5. **Fournissez des screenshots** dans la documentation

---

## 🔗 Ressources

- [Apple Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [create-dmg tool](https://github.com/create-dmg/create-dmg)
- [Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Introduction/Introduction.html)
