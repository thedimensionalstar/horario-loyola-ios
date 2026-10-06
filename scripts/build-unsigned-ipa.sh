#!/usr/bin/env bash
# Compila la app sin firmar y la empaqueta como .ipa para instalarla con Sideloadly o AltStore.
set -euo pipefail
ROOT="${CM_BUILD_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
OUT="$ROOT/build"
rm -rf "$OUT" && mkdir -p "$OUT"
cd "$ROOT/ios/App"

if [ -d App.xcworkspace ]; then TARGET=(-workspace App.xcworkspace); else TARGET=(-project App.xcodeproj); fi

xcodebuild "${TARGET[@]}" \
  -scheme App \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -archivePath "$OUT/App.xcarchive" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  archive

mkdir -p "$OUT/Payload"
cp -R "$OUT/App.xcarchive/Products/Applications/App.app" "$OUT/Payload/"
cd "$OUT" && zip -qry HorarioLoyola-sin-firmar.ipa Payload
echo "✓ $OUT/HorarioLoyola-sin-firmar.ipa"
