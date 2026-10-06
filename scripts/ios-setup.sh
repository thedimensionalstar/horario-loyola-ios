#!/usr/bin/env bash
# Crea (si hace falta) y configura el proyecto de Xcode. Se ejecuta en el Mac de Codemagic.
set -euo pipefail
ROOT="${CM_BUILD_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

if [ ! -d ios ]; then
  echo "→ Creando la plataforma iOS"
  npx cap add ios
fi

APP_DIR="ios/App/App"
PLIST="$APP_DIR/Info.plist"
ASSETS="$APP_DIR/Assets.xcassets"

echo "→ Icono de la app"
ICONSET="$ASSETS/AppIcon.appiconset"
rm -rf "$ICONSET" && mkdir -p "$ICONSET"
cp resources/ios/AppIcon-1024.png "$ICONSET/AppIcon-1024.png"
cat > "$ICONSET/Contents.json" <<'JSON'
{
  "images" : [
    { "filename" : "AppIcon-1024.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
JSON

echo "→ Pantalla de carga"
SPLASH="$ASSETS/Splash.imageset"
rm -rf "$SPLASH" && mkdir -p "$SPLASH"
for s in "" "@2x" "@3x"; do cp resources/ios/splash.png "$SPLASH/splash$s.png"; done
cat > "$SPLASH/Contents.json" <<'JSON'
{
  "images" : [
    { "idiom" : "universal", "filename" : "splash.png", "scale" : "1x" },
    { "idiom" : "universal", "filename" : "splash@2x.png", "scale" : "2x" },
    { "idiom" : "universal", "filename" : "splash@3x.png", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
JSON

echo "→ Ajustes de Info.plist"
pb() { /usr/libexec/PlistBuddy -c "$1" "$PLIST"; }
setkey() { pb "Delete :$1" 2>/dev/null || true; pb "Add :$1 $2 $3"; }
setkey CFBundleDisplayName string Horario
setkey CFBundleDevelopmentRegion string es
setkey ITSAppUsesNonExemptEncryption bool false
setkey UIStatusBarStyle string UIStatusBarStyleLightContent
pb "Delete :UISupportedInterfaceOrientations" 2>/dev/null || true
pb "Add :UISupportedInterfaceOrientations array"
pb "Add :UISupportedInterfaceOrientations:0 string UIInterfaceOrientationPortrait"

echo "→ Copiando la web y los plugins al proyecto"
npx cap sync ios
echo "✓ Proyecto iOS listo"
