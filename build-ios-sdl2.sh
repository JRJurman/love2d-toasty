#!/bin/bash
# Rebuilds ios/platform/xcode/ios/libraries/SDL2.xcframework from the SDL2 2.28.5
# source in the Android megasource, which is patched for the UIScene life cycle
# that iOS 27 SDK builds need (search for "Xcode 27:" in src/video/uikit).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SDL="$ROOT/android/app/src/main/cpp/megasource/libs/SDL2"
OUT="$ROOT/ios/platform/xcode/ios/libraries/SDL2.xcframework"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# The .metal source needs the separately-downloaded Metal toolchain, and the
# renderer uses the precompiled SDL_shaders_metal_ios.h anyway.
for dest in "generic/platform=iOS" "generic/platform=iOS Simulator"; do
	xcodebuild -quiet -project "$SDL/Xcode/SDL/SDL.xcodeproj" -scheme "Static Library-iOS" \
		-configuration Release -destination "$dest" -derivedDataPath "$WORK/build" \
		IPHONEOS_DEPLOYMENT_TARGET=15.0 EXCLUDED_SOURCE_FILE_NAMES=SDL_shaders_metal.metal build
done

# Same public headers as the original love-apple-dependencies build.
mkdir "$WORK/headers"
cp "$SDL"/include/*.h "$WORK/headers/"
rm "$WORK"/headers/SDL_test*.h
find "$WORK/headers" -name "SDL_config_*.h" ! -name "SDL_config_iphoneos.h" -delete

rm -rf "$OUT"
xcodebuild -create-xcframework \
	-library "$WORK/build/Build/Products/Release-iphoneos/libSDL2.a" -headers "$WORK/headers" \
	-library "$WORK/build/Build/Products/Release-iphonesimulator/libSDL2.a" -headers "$WORK/headers" \
	-output "$OUT"
