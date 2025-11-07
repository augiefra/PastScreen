#!/bin/bash

# Script pour créer un DMG pour ScreenSnap
# Usage: ./create-dmg.sh

APP_NAME="ScreenSnap"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}"
APP_PATH="build/${APP_NAME}.app"
DMG_PATH="build/${DMG_NAME}.dmg"
VOLUME_NAME="${APP_NAME} ${VERSION}"

# Vérifier que l'app existe
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Erreur: ${APP_PATH} n'existe pas"
    echo "Veuillez d'abord archiver l'app dans Xcode (Product → Archive → Export)"
    exit 1
fi

# Créer le dossier temporaire
TMP_DIR=$(mktemp -d)
echo "📁 Création du dossier temporaire: ${TMP_DIR}"

# Copier l'app
cp -R "$APP_PATH" "$TMP_DIR/"

# Créer un lien vers Applications
ln -s /Applications "$TMP_DIR/Applications"

# Créer le DMG
echo "📦 Création du DMG..."
hdiutil create -volname "$VOLUME_NAME" \
    -srcfolder "$TMP_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

# Nettoyer
rm -rf "$TMP_DIR"

echo "✅ DMG créé: ${DMG_PATH}"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Testez le DMG en le montant"
echo "2. Pour distribution publique, signez l'app (voir README)"
echo "3. Pour distribution hors App Store, faites notariser par Apple"
