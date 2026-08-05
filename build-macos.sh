#!/usr/bin/env bash
set -e

APP=macos/Toasty.app

rm -rf "$APP"
cp -R macos/love.app "$APP"

cp toasty.love "$APP/Contents/Resources/"

# embed SRAL dependency
mkdir -p "$APP/Contents/Resources/sral"
cp sral/libSRAL.dylib "$APP/Contents/Resources/sral/"

# copy our template Info.plist
cp macos/Info.plist "$APP/Contents/"

# codesign logic (for local or release)
IDENTITY="Developer ID Application: Jesse Jurman (AQ6X48UC8X)"
SIGNED=0
if security find-identity -v -p codesigning | grep -q "$IDENTITY"; then
      # Sign inside out -- nested code first, bundle last. The vendored frameworks
      # arrive in three different states (some unsigned, some with broken seals),
      # so --force on each is what makes the top-level signature possible.
      codesign --force --timestamp --options runtime --sign "$IDENTITY" \
              "$APP/Contents/Resources/sral/libSRAL.dylib"

      for fw in "$APP"/Contents/Frameworks/*.framework; do
              codesign --force --timestamp --options runtime --sign "$IDENTITY" "$fw"
      done

      codesign --force --timestamp --options runtime \
              --entitlements macos/Toasty.entitlements --sign "$IDENTITY" "$APP"

      codesign --verify --strict "$APP"

			# indicate we need to sign the app in the next step
			SIGNED=1
else
      echo "No Developer ID cert -- ad-hoc signing (local build only)"
      codesign --force --deep --sign - \
              --entitlements macos/Toasty.entitlements "$APP"
fi

rm -f Toasty-macOS.zip
ditto -c -k --sequesterRsrc --keepParent "$APP" Toasty-macOS.zip

if [ "$SIGNED" = "1" ]; then
      xcrun notarytool submit Toasty-macOS.zip \
              --keychain-profile "toasty-notary" --wait

      # Stapling writes the ticket into the .app itself, so the archive has to be
      # rebuilt afterwards -- otherwise we ship a zip with no ticket in it.
      xcrun stapler staple "$APP"
      rm -f Toasty-macOS.zip
      ditto -c -k --sequesterRsrc --keepParent "$APP" Toasty-macOS.zip

      spctl -a -vvv -t exec "$APP"
fi
