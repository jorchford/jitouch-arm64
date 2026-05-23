#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/build"
APP_DERIVED="$BUILD/JitouchApp"
PREF_DERIVED="$BUILD/JitouchPrefPane"
PACKAGE="$BUILD/package"
RELEASE="$ROOT/release"

APP_PRODUCT="$APP_DERIVED/Build/Products/Release/Jitouch.app"
PREF_PRODUCT="$PREF_DERIVED/Build/Products/Release/Jitouch.prefPane"
FINAL_APP="$PACKAGE/Jitouch.app"

rm -rf "$BUILD" "$RELEASE"
mkdir -p "$PACKAGE" "$RELEASE"

xcodebuild \
  -project "$ROOT/jitouch/Jitouch/Jitouch.xcodeproj" \
  -scheme Jitouch \
  -configuration Release \
  -derivedDataPath "$APP_DERIVED" \
  clean build \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGNING_ALLOWED=NO

rm -rf "$ROOT/prefpane/Jitouch.app"
/usr/bin/ditto "$APP_PRODUCT" "$ROOT/prefpane/Jitouch.app"

xcodebuild \
  -project "$ROOT/prefpane/Jitouch.xcodeproj" \
  -scheme Jitouch \
  -configuration Release \
  -derivedDataPath "$PREF_DERIVED" \
  clean build \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGNING_ALLOWED=NO

rm -rf "$FINAL_APP"
/usr/bin/ditto "$APP_PRODUCT" "$FINAL_APP"

rm -rf "$FINAL_APP/Contents/Resources/Jitouch.prefPane"
/usr/bin/ditto "$PREF_PRODUCT" "$FINAL_APP/Contents/Resources/Jitouch.prefPane"

# The original preference pane embeds its own runtime app. In the one-app
# package the outer app is the only runtime; keeping the nested copy makes
# Spotlight show duplicate Jitouch apps.
rm -rf "$FINAL_APP/Contents/Resources/Jitouch.prefPane/Contents/Resources/Jitouch.app"
rm -rf "$ROOT/prefpane/Jitouch.app"

codesign --force --deep --sign - "$FINAL_APP"

DMG_ROOT="$BUILD/dmgroot"
mkdir -p "$DMG_ROOT"
/usr/bin/ditto "$FINAL_APP" "$DMG_ROOT/Jitouch.app"
ln -s /Applications "$DMG_ROOT/Applications"

hdiutil create \
  -volname "Jitouch ARM64" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$RELEASE/Jitouch-arm64-universal.dmg"

(cd "$PACKAGE" && /usr/bin/ditto -c -k --keepParent Jitouch.app "$RELEASE/Jitouch-app-drag-to-Applications.zip")

(
  cd "$ROOT"
  shasum -a 256 \
    release/Jitouch-arm64-universal.dmg \
    release/Jitouch-app-drag-to-Applications.zip > release/SHA256SUMS
)

echo "Built $FINAL_APP"
cat "$RELEASE/SHA256SUMS"
